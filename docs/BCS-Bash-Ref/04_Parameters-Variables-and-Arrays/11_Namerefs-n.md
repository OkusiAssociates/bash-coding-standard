<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.11 Namerefs (`-n`)

A nameref is a variable whose value is the **name** of another variable;
reads and writes through the nameref are forwarded to the referenced
target. Bash's only pointer-like construct, namerefs are the canonical
mechanism for output parameters, indirect access to arrays, and
generic algorithms that operate on caller-supplied variable names.

### Declaration and basic use

```bash
# scenario: declaration, read, write
declare -- target='original'
declare -n ref=target

printf '%s\n' "$ref"         # ⇒ original   (read forwarded)
ref='via nameref'             # write forwarded
printf '%s\n' "$target"      # ⇒ via nameref
```

The nameref is itself a variable; what makes it special is the `-n`
attribute — its assigned value (`target`) is interpreted as the *name*
of another variable, and every read/write goes through that name.

`local -n` is the function-scoped form. The reference dies when the
function returns; the target is unaffected.

### The output-parameter pattern

The dominant use of namerefs in production Bash is to *return* values
from functions other than via stdout. Without namerefs, a function
that needs to "return" a non-trivial value (an array, a structured
object, multiple values) must echo and have the caller capture via
`$()` — which forks a subshell, loses array-ness, and serialises
everything to text. Namerefs fix this.

```bash
# scenario: output parameter — returning an array
fetch_records() {
  local -n out=$1            # caller-supplied array name
  out=()                     # reset
  out+=('alice|42')
  out+=('bob|17')
  out+=('carol|99')
}

declare -a results=()
fetch_records results
printf '%s\n' "${results[@]}"
# ⇒ alice|42
# ⇒ bob|17
# ⇒ carol|99
```

The contract is documented at the call site: "first argument is the
name of an array I will fill". Combine with `declare -n out=$1` as
the **first** line of the function so the indirection is unmissable.

### Indirect access to arrays and elements

```bash
# scenario: nameref to an array, and to a single element
declare -a colours=(red green blue)
declare -A by_id=([alice]=42 [bob]=17)

declare -n alias=colours
printf '%s\n' "${alias[1]}"      # ⇒ green
alias+=(yellow)
printf '%s\n' "${colours[3]}"    # ⇒ yellow

declare -n cell=by_id[alice]     # nameref to a single map element
cell='42 (admin)'
printf '%s\n' "${by_id[alice]}"  # ⇒ 42 (admin)
```

Note that `${!ref}` does **not** behave intuitively on a nameref. The
`${!name}` indirection form predates namerefs and looks up "the
variable whose name is the value of `name`" — for a nameref, this is
the *target's* value, but indirected one extra level (i.e. it expects
the target's *value* to itself be a variable name). Just write `$ref`
or `${ref}` and let the nameref do its job.

### Cycles and self-reference

Bash detects simple nameref cycles and refuses to follow them:

```bash
declare -n a=b
declare -n b=a
echo "$a"
# ⇒ bash: warning: a: circular name reference
```

The classic shadowing pitfall is more insidious: declaring a nameref
*with the same name* as its intended target. Inside a function, `local
-n self=self` (or whatever the caller passed) creates a local that
*shadows* the global `self`, and the nameref then refers to itself —
producing a circular reference. The fix is to choose a nameref name
that **cannot collide** with anything the caller might pass.

```bash
# wrong — caller passes "out" as the variable to fill, and the
#         function names its nameref "out" too
fill() {
  local -n out=$1     # if caller's variable is also named 'out',
  out=(a b c)         # 'out' shadows itself ⇒ circular reference
}

declare -a out=()
fill out 2>&1 | head -1   # → "warning: out: circular name reference" on stderr

# right — pick an unlikely internal name
fill() {
  local -n __fill_out=$1
  __fill_out=(a b c)
}
declare -a result=()
fill result
printf '%s\n' "${result[@]}"   # ⇒ a
                                # ⇒ b
                                # ⇒ c
```

The convention is to prefix the nameref's local name with the function
name and a leading underscore (`__fill_out`, `__merge_dest`) — ugly
but collision-proof.

### Pitfalls collected

- **Shadowing**: a nameref must not share its name with the variable
  it points to. Use a function-prefixed local.
- **`declare -n` after the value has been assigned**: combining
  attributes is order-sensitive — `declare -n ref; ref=target` works,
  but `declare ref=target; declare -n ref` does not retroactively make
  `ref` a nameref.
- **Empty target**: `declare -n ref=` is rejected. Initialise the
  reference at the moment of declaration.
- **Crossing scope boundaries**: a `local -n` that points at a *local*
  in a callee that has already returned is a dangling reference; Bash
  errors out on use.
- **`unset ref` removes the nameref, not the target**, **unless** you
  use `unset -n ref` — and even that varies by version. Prefer
  letting the local fall out of scope naturally.

### When *not* to use a nameref

- For pure-value return — echo to stdout and capture with `$()`. Cheaper
  to reason about.
- For configuration data shared across many functions — use a global
  with a documented name. Namerefs are for plumbing, not architecture.

### See also

- §4.5 — `declare` and the `-n` attribute
- §4.6 — `local` and dynamic scope (interaction with namerefs)
- §4.9, §4.10 — arrays (the most common nameref targets)
- BCS0202 (variable scoping), BCS0411 (subshell return-value patterns)

#fin
