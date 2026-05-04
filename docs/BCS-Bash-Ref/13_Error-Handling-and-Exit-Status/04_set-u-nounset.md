<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.4 `set -u` (nounset)

`set -u` (equivalently `set -o nounset`) treats any reference to an unset
variable as an error: bash prints `unbound variable` to stderr, returns
non-zero status, and (under `set -e`) exits. It is the second leg of the
strict-mode tripod (with `errexit` and `pipefail`) and the cheapest
single defence against typo-introduced bugs.

### What counts as "unset"

Unset means the variable was never assigned, was explicitly `unset`, or
is a positional parameter (`$1`, `$2`, …) that does not exist. *Empty*
is not unset: `var=""` declares the name and leaves it empty;
`echo "$var"` is fine under `set -u`. A `declare`d variable with no
value is also "set to empty" and not flagged.

```bash
# scenario: unset vs empty under set -u
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- empty=""
echo "empty: [$empty]"         # ⇒ empty: []   — empty is set; no error

unset empty
echo "unset: [$empty]"         # ⇒ unbound variable; EXITS

# Positional parameters:
echo "first: [$1]"             # ⇒ unbound if no $1 was passed
```

`declare -- name` (or `local -- name`) without an `=` *does* set the
variable to empty in current bash; relying on this is portable to bash
4.0+. Do not assume `declare -- name` leaves the variable in an unset
state — it does not.

### Default-expansion forms

The parameter-expansion family is the canonical way to read a possibly-
unset variable without disabling `set -u`:

| Form | Behaviour when unset | Behaviour when empty |
|------|----------------------|----------------------|
| `${var}` | error under `set -u` | empty string |
| `${var-default}` | yields `default` | empty string |
| `${var:-default}` | yields `default` | yields `default` |
| `${var=default}` | sets *and* yields `default` | empty string |
| `${var:=default}` | sets *and* yields `default` | sets *and* yields `default` |
| `${var?msg}` | error with `msg`, exits | empty string |
| `${var:?msg}` | error with `msg`, exits | error with `msg`, exits |
| `[[ -v var ]]` | tests "is it set?" | tests "is it set?" (returns true) |

The `:-` form is the one used in BCS templates for "may be unset, treat
as empty" — `"${OPTION:-}"` is the standard way to test or pass an
optional flag without tripping `set -u`. The `:?` form is the
canonical "required argument" assertion: `: "${1:?usage: foo PATH}"`.

`[[ -v var ]]` is bash 4.2+ and is the cleanest *test* form: it asks
"is this name bound?" without consuming the value. Use it where the
question is set-vs-unset rather than empty-vs-non-empty.

### Array gotchas

The most-tripped-over `set -u` rule concerns arrays. A *declared but
empty* array indexed by `[@]` or `[*]` errors under `set -u`. This is
the array equivalent of "unbound variable", and bites every script
that iterates over a result array that *might* be empty.

```bash
# scenario: empty-array iteration under set -u
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a results=()
# The naive loop:
#   for x in "${results[@]}"; do echo "$x"; done
# would abort with:
#   bash: results[@]: unbound variable
# (so we don't run it here — set -u + empty array + [@] = errexit). The
# next two forms run safely:

# Fix 1: default-expand the array
for x in "${results[@]:-}"; do        # → loop runs zero times, no error
  echo "$x"
done
echo "fix-1 ok"                       # ⇒ fix-1 ok

# Fix 2: gate the loop on length
if (( ${#results[@]} )); then
  for x in "${results[@]}"; do echo "$x"; done
fi
echo "fix-2 ok"                       # ⇒ fix-2 ok
```

The `${arr[@]:-}` workaround substitutes a single empty element when
the array is empty; for a true zero-iteration loop, the explicit
length-gate is cleaner. BCS0206 prefers the gate form for clarity.

Similarly, `"${arr[i]}"` errors when index `i` is unset; use
`"${arr[i]:-}"` if the slot may be vacant.

### Positional-parameter exception

`$@` and `$*` do **not** error under `set -u` when the script was
invoked with no arguments; they expand to nothing. This is intentional
— `for arg in "$@"; do ...; done` must work for zero-arg scripts.
However, *individual* positionals (`$1`, `$2`, …) error if not set:

```bash
# scenario: positional handling
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
foo() {
  : "${1:?missing PATH argument}"     # required: error with msg if unset
  local -- input="$1"
  local -- output="${2:-/tmp/out}"    # optional: default
  echo "$input -> $output"
}
foo "$@"                              # safe; "$@" empty-on-no-args
```

This pattern is the BCS-recommended argument validation idiom (BCS0803).

### Interaction with `local`/`declare`

A `local -- name` inside a function brings `name` into scope; if you
read it before assigning a value, the rule depends on bash version. In
modern bash (4.4+), `local -- name` initialises to empty and `set -u`
will not flag a read. Do not rely on this for clarity — assign at
declaration: `local -- name=""`.

`local -n ref=other` (nameref) under `set -u` errors if `other` is
unset *at the time the nameref is dereferenced*, not at declaration.

### When to disable

Almost never. The only legitimate reasons are:
- Sourcing a third-party file that violates `set -u` and cannot be
  patched: wrap in `set +u; source file; set -u`.
- A specific block reading completion-style data where unbound is the
  signalling convention. Document the disable.

`set +u` and `set -u` may be toggled at any point. Prefer to bracket
the violation as narrowly as possible.

### Practical guidance

The BCS strict-mode preamble enables `set -u` unconditionally. Combined
with explicit `declare`/`local --` (BCS0201) at the top of every
function, `set -u` reduces typo bugs to zero — `if [[ $resluts ]];`
errors immediately rather than silently testing an empty string.

**See also**: §13.2 (errexit), §13.9 (strict-mode contract), §13.11
(propagation), BCS0101 (strict mode), BCS0201 (type-specific
declarations), BCS0206 (arrays), BCS0803 (argument validation),
BCS-bash `13_03_Parameter-Expansion.md`.

#fin
