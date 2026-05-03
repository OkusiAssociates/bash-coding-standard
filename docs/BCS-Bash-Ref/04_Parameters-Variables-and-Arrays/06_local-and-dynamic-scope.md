<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.6 `local` and dynamic scope

`local` declares a variable whose lifetime ends when the enclosing
function returns. Bash's scope is **dynamic**, not lexical: a function
can see locals declared by **any function above it on the call stack**.
This is the property most likely to surprise a programmer arriving from
C, Python, JavaScript, or any other language with lexical scope.

### Syntax — always `local --`

```bash
# right — terminate option processing first
my_function() {
  local -- name=$1
  local -i count=0
  local -a items=()
}

# wrong — value beginning with - or -- is misparsed as an option
my_function() {
  local file="--help"   # ⇒ local thinks --help is its own flag
}
```

The BCS rule is: **always begin a `local` declaration with an attribute
flag** (`local --`, `local -i`, `local -a`, `local -A`, `local -n`).
This terminates option processing before the variable name and prevents
values like `--help` or `-x` from being interpreted as flags. See
BCS0201 and BCS0202.

`local` accepts the same attribute flags as `declare`: `-i` integer,
`-a` indexed array, `-A` associative, `-r` readonly, `-n` nameref.
`local -p` prints declarations of all current locals — a debugging aid
inside complex functions.

### Dynamic scope — the visibility chain

Locals declared in a caller are visible to **every callee**, transitively,
until the caller returns. There is no "encapsulation" — a deeply nested
helper can read (and modify) any local of any function on the stack.

```bash
# scenario: dynamic scope visibility
top() {
  local -- secret='from top'
  middle
}

middle() {
  # No 'secret' declared here — but $secret is visible
  printf 'middle sees: %s\n' "$secret"
  bottom
}

bottom() {
  # Still visible, two frames down
  printf 'bottom sees: %s\n' "$secret"
  secret='mutated by bottom'   # writes back to top's local!
}

top
# ⇒ middle sees: from top
# ⇒ bottom sees: from top
# After top() returns, $secret is unset again at script scope.
```

Two consequences worth pinning down:

1. **A callee shadows a caller's local with `local`**, not by plain
   assignment. Inside `bottom`, `local -- secret='x'` would create a
   new local hiding `top`'s; bare `secret='x'` writes through to
   `top`'s.
2. **A function relying on a caller's local is fragile**. The
   convention is to pass values explicitly via positionals or, for
   output parameters, via namerefs (§4.11) — never to depend on an
   ambient name.

### Locals shadow globals

A `local name=…` inside a function hides any global of the same name
for the duration of the call. Callees see the local; the global
re-emerges after return.

```bash
# scenario: function-local shadows a global
declare -- mode='production'

run() {
  local -- mode='test'
  helper
}

helper() {
  printf 'helper mode: %s\n' "$mode"
}

helper             # ⇒ helper mode: production  (sees global)
run                # ⇒ helper mode: test        (sees run's local)
helper             # ⇒ helper mode: production  (back to global)
```

### Interaction with namerefs

`local -n ref=name` creates a function-scoped reference to `name`. The
reference itself is local; the *target* lives wherever it was declared.
Once the function returns, the nameref is destroyed — the target is
unaffected. The shadowing pitfall — naming the nameref the same as its
target — is detailed in §4.11.

### Declaring typed locals

Use the strongest typed declaration available; it documents intent and
catches mistakes early.

```bash
process() {
  local -- file=$1            # explicit string
  local -i count=0            # integer counter
  local -a errors=()          # indexed array
  local -A by_key=()          # associative array
  local -ar tiers=(a b c)     # readonly array
  local -n out=$2             # output parameter (nameref)
}
```

### When *not* to use `local`

- At script scope (outside any function) — `local` is invalid there;
  use `declare`.
- For values you intentionally want visible to callees — but this is
  fragile design; prefer explicit parameters.
- For constants — use `local -r` (function-scoped) or `readonly`/`-r`
  at script scope.

### See also

- §4.5 — `declare` and the full attribute set
- §4.7 — `readonly` and immutability
- §4.11 — namerefs and the output-parameter idiom
- §4.13 — variable assignment semantics
- BCS0201 (type-specific declarations), BCS0202 (variable scoping)

#fin
