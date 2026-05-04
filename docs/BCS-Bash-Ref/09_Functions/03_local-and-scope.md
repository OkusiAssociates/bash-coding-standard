<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.3 `local` and scope

Bash uses *dynamic* scope, not lexical scope. A variable declared
`local` inside a function is visible to that function and to any
function it calls, transitively, but disappears as soon as the
declaring function returns. Authors arriving from C, Python, or Go
expect lexical scope and routinely trip over the difference.

### The dynamic-scope rule

When a function names a variable, bash searches the *call stack*, not
the *source* in which the function was defined. The first enclosing
frame on the stack that has declared a `local` variable of that name
wins; if none does, the variable is global.

```bash
# scenario: dynamic scope — a callee sees the caller's locals
inner() { printf 'inner sees x=%s\n' "${x:-UNSET}"; }

outer() {
  local -- x='from outer'
  inner                                 # ⇒ inner sees x=from outer
}

x='from global'
outer                                   # ⇒ inner sees x=from outer
inner                                   # ⇒ inner sees x=from global
```

This behaviour is the central reason BCS0202 mandates `local` for
*every* function-internal variable: without it, a helper function
silently mutates whatever `x` happens to be in its caller's frame, or
in the global namespace. Defensive `local` discipline isolates each
function's variables to its own frame.

### Declaration forms

`local` accepts the same type flags as `declare`. The leading `--`
terminates option processing for `local` so that values starting with
`-` cannot be misread as flags (BCS0202).

```bash
# scenario: the typed local-declaration vocabulary
demo() {
  local --  name='Alice'                # untyped string
  local -i  count=0                     # integer (arithmetic context on assign)
  local -a  files=( a.txt b.txt )       # indexed array
  local -A  meta=( [host]=ok1 [port]=22 ) # associative array
  local -r  pi=3.14159                  # readonly within this frame
  local -n  ref=name                    # nameref → 'name' in this frame
  local -p | grep -E '^declare'         # → list this frame's locals (debug)
}
demo | head -1                          # ⇒ declare
```

`local -` (Bash 4.4+, distinct from `local --`) saves the current
shell-option state on entry and restores it on return — useful when a
function temporarily wants to disable `set -e` or enable `extglob`
without affecting the caller.

### Namerefs and the dynamic-scope interaction

A nameref (`local -n ref=target`) is a *reference* to another
variable, resolved at use time. Because resolution walks the dynamic
call stack, namerefs are the bash idiom for *output parameters* — a
function can write to a caller-supplied variable name. The interaction
with `local` is subtle and worth a worked trace.

```bash
# scenario: nameref output parameter — caller passes a name, callee fills it
upper() {
  local -n out=$1                       # 'out' refers to the variable named in $1
  out="${2^^}"                          # write to it
}

result=''
upper result 'hello world'              # caller passes the name 'result'
echo "$result"                          # ⇒ HELLO WORLD
```

The pitfall: if the *callee's* nameref name collides with a *caller's*
local, the caller's local wins. This is the dynamic-scope rule biting
again — namerefs do not bypass scope, they participate in it.

```bash
# scenario: nameref-name collision — silent mis-binding
fill() {
  local -n out=$1
  out='filled'
}

caller() {
  local -- out='caller value'           # local in the caller's frame
  fill out 2>/dev/null                  # warnings about the circular ref go to stderr
  echo "caller out = ${out@Q}"          # ⇒ caller out = 'caller value'
}
caller
# (bash 5.2 detects the circular reference between caller's `out` and
#  fill's `local -n out`; the nameref assignment is refused, so the
#  caller's value is left intact)
```

The common defence is to give nameref locals a distinctive prefix
(`_out`, `__ref_`, etc.) that is unlikely to collide with caller
locals. BCS scripts conventionally use a leading underscore for
nameref parameters.

### Without `local`: pollution and recursion failure

Omitting `local` is not just untidy — it breaks recursion. A recursive
function that uses bare assignments shares one variable across all
frames; the deepest call clobbers the shallower ones on return.

```bash
# scenario: recursion failure without local
fac_bad() {                             # broken
  n=$1
  (( n <= 1 )) && { echo 1; return; }
  prev=$(fac_bad $((n - 1)))            # n is reassigned in the recursive call,
  echo $((n * prev))                    #   then the outer frame uses the wrong n
}                                       # ⇒ produces 0 for fac_bad 5

fac_ok() {                              # correct
  local -i n=$1                         # n is per-frame
  (( n <= 1 )) && { echo 1; return; }
  local -i prev
  prev=$(fac_ok $((n - 1)))
  echo $((n * prev))
}

printf 'fac_bad 5: %s\n' "$(fac_bad 5)"   # ⇒ fac_bad 5: 120
printf 'fac_ok  5: %s\n' "$(fac_ok 5)"    # ⇒ fac_ok  5: 120
# Both happen to compute 120 here because each recursive call is wrapped
# in a $(…) subshell, which isolates the caller's `n` from the callee's
# reassignment. Replace `prev=$(fac_bad …)` with a flow that shares state
# (a global, a tempfile, or `set -- "$(…)" "$@"` accumulator without
# locals) and the bug surfaces. The discipline rule still holds: use
# `local` so future refactors do not turn this latent bug into a real one.
```

The same bug occurs less dramatically in non-recursive code: a helper
modifies a global, the caller does not notice, and weeks later a
subtle wrong value surfaces. `local` makes the bug a syntax error in
practice (the variable is gone after return) instead of a silent data
corruption.

**See also**: §9.2 (argument passing), §9.5 (communicating results),
§9.6 (recursion and FUNCNEST), §4.11 (namerefs in detail), §10.8
(`declare -g` for globals defined inside functions), BCS0202
(variable scoping), BCS0410 (recursive function state discipline),
BCS-bash `12_03_Shell-Variables.md`.

#fin
