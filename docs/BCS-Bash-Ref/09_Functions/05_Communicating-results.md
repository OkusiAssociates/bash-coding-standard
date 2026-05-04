<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.5 Communicating results

A function returning data to its caller has four mechanisms in bash,
each with its own performance, composability, and coupling
trade-offs. Picking the right one is a routine design decision; the
wrong choice leaks state, costs forks, or ties the function to a
specific variable name.

### The four mechanisms

| Mechanism | Caller pattern | Cost | Coupling | Use when |
|-----------|----------------|------|----------|----------|
| **stdout** | `result=$(func args)` | One subshell fork (~1 ms on Linux) | None — interface is a string | Default for data-returning functions; composable, testable. |
| **Nameref output parameter** | `func dest_var args; use "$dest_var"` | No fork | Caller must supply a variable name | Hot paths where the fork dominates; binary or large outputs. |
| **Global variable** | `func args; use "$RESULT"` | No fork | Function and caller share a global name | Last resort. Only when stdout and nameref are both unsuitable. |
| **Exit status** | `if func args; then …` | No fork | Boolean only | Predicates: `is_valid`, `has_dependency`. Never for data. |

Each is illustrated below with the *same* underlying computation —
upper-casing a string — so the trade-offs are directly comparable.

### Pattern 1 — stdout (the default)

```bash
# scenario: stdout return — composable, testable, costs one fork per call
upper_stdout() {
  local -- s="${1:?usage: upper_stdout STRING}"
  printf '%s' "${s^^}"
}

result=$(upper_stdout 'hello')          # → captures the upper-cased string
echo "$result"                          # ⇒ HELLO
```

stdout is the right answer most of the time. The function reads as a
pure transformation; the caller sees a string. The cost is the
subshell fork that command substitution always entails — measurable
in tight loops, irrelevant otherwise. Errors propagate naturally: a
non-zero exit from the function makes the substitution carry that
status, and `set -e` (with `inherit_errexit`, BCS0101) catches it.

### Pattern 2 — nameref output parameter

```bash
# scenario: nameref output — no fork, caller passes the destination by name
upper_nameref() {
  local -n _out=$1                      # leading underscore avoids name collision (§9.3)
  local -- s="${2:?usage: upper_nameref OUT IN}"
  _out="${s^^}"
}

upper_nameref result 'hello'            # caller names its destination
echo "$result"                          # ⇒ HELLO
```

The nameref form trades composability for speed. A pipeline of three
nameref-style functions cannot be written as `c $(b $(a x))`; the
caller must declare temporaries. In return, no subshell is forked,
which matters in inner loops processing many thousands of items.

The collision pitfall (§9.3) applies: pick a unique nameref local
name, conventionally with a leading underscore, so that a caller
declaring its own `out` does not silently shadow your output binding.

### Pattern 3 — global variable

```bash
# scenario: global return — fastest, most coupled, hardest to test
declare -- UPPER_RESULT=''              # documented global

upper_global() {
  local -- s="${1:?usage: upper_global STRING}"
  UPPER_RESULT="${s^^}"                 # mutate the documented global
}

upper_global 'hello'
echo "$UPPER_RESULT"                    # ⇒ HELLO
```

Globals are a code smell, not a crime. Two situations justify them:
the function is logically a singleton (e.g. populating a config
struct on first call) and the global name is unambiguously
namespace-prefixed; or the function returns *several* values that
would be awkward to encode in stdout. In both cases the global must
be declared at script top with a comment naming every function that
touches it (BCS0204 governs constant naming). Untracked globals are
the most common source of "why did this change?" debugging sessions.

### Pattern 4 — exit status (boolean only)

```bash
# scenario: exit status as the answer — predicates only, never for data
is_uppercase() {
  local -- s="${1:?usage: is_uppercase STRING}"
  [[ $s == "${s^^}" ]]                  # exit status of [[ … ]] is the answer
}

if is_uppercase 'HELLO'; then           # ⇒ branch taken
  echo 'all upper'
fi
```

`return N` from a function yields exit status `N` to the caller; the
caller composes with `if`, `&&`, `||`, `while`, etc. (§13.2 covers
how `set -e` interacts with these contexts). Restrict the mechanism
to predicates that answer yes-or-no — cramming a small integer into
exit status as a data channel breaks the moment the function gains a
third possible answer.

### Choosing between stdout and nameref

The default is stdout. Switch to nameref when one of the following
holds:

- The function is on a measurable hot path and benchmarking shows
  the fork dominates.
- The output is binary or contains trailing newlines that command
  substitution would strip.
- The function returns multiple distinct values and a structured
  return is unavoidable.

Avoid the nameref form for general-purpose library code: composability
matters more than ~1 ms per call, and a stdout-returning function is
trivial to test (`assert "$(func x)" == 'X'`) whereas a nameref
function requires a wrapper.

**See also**: §9.2 (argument passing), §9.3 (`local` and scope —
nameref name collision), §9.4 (`return N`), §13.2 (`set -e` and
function exit status), BCS0411 (subshell return-value patterns),
BCS0202 (variable scoping), BCS-bash `09_06_Shell-Function-Definitions.md`.

#fin
