<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.8 Lazy and conditional loading

Sourcing a library has a cost — file I/O plus the cost of evaluating
every function definition, every `declare`, and any top-level code.
For a small library the cost is negligible; for a large library
sourced only to obtain one rarely-used function, it is wasted. *Lazy*
loading defers sourcing until the feature is first invoked; *conditional*
loading sources different libraries based on environment.

### Lazy loading by stub

The standard pattern replaces the heavyweight function with a thin
stub that loads the real library on first call, *replaces* itself
with the genuine implementation, and forwards the original
arguments. From the caller's view the function is always defined —
the cost is paid only when it is first used.

```bash
# scenario: lazy-load stub — real library is sourced on first call
# Cheap stub installed at script startup; real myapp_render is in lib/render.sh.
myapp_render() {
  source "${MYAPP_LIB_DIR:-/usr/local/lib/myapp}/render.sh"   # defines myapp_render itself
  myapp_render "$@"                                            # forward original args
}

# First call: source occurs, real function replaces this stub, then runs.
# Second call: real function is already in place, no source.
```

The stub overwrites itself at the moment the library is sourced
(because the library's definition of `myapp_render` clobbers the
stub). Bash's function-table semantics make this a clean replacement
with no second-call penalty. Idempotency (§10.4) is still required
inside the library, but the stub guarantees a single load in the
common case.

### The `declare -g` pitfall

The pitfall worth documenting in detail: when a library is sourced
*inside a function*, every `declare` and every assignment without
`declare` resolves to the *function's* local scope, not the global
namespace. The library's `MY_LIBRARY_VERSION='1.0'`, intended to be
visible script-wide, becomes invisible the instant the calling
function returns. Lazy loading is the canonical context that triggers
this — the lazy stub is itself a function, so the library is sourced
in function scope.

```bash
# scenario: function-scoped global pitfall — without declare -g
# --- lib.sh ---
LIB_VERSION='1.0'                       # bare assignment
declare -- LIB_NAME='strings'           # declare WITHOUT -g

# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail

load_lib() { source ./lib.sh; }         # sourced inside a function

load_lib
echo "version=${LIB_VERSION:-UNSET}"    # ⇒ version=UNSET
echo "name=${LIB_NAME:-UNSET}"          # ⇒ name=UNSET
```

Both assignments became *locals of `load_lib`* and disappeared on
return. The fix has two parts: at the library's top, every `declare`
that should populate the caller's global namespace must use the `-g`
flag; bare assignments without `declare` are subject to the same
rule when `local` is in scope above them on the call stack
(BCS0202's reason for mandating explicit `local`).

```bash
# scenario: correct lazy-loadable library — uses declare -g for globals
# --- lib.sh ---
declare -g  LIB_VERSION='1.0'           # -g forces global scope
declare -gr LIB_NAME='strings'          # -g + readonly: global constant
declare -gi LIB_LOAD_TIME=$EPOCHSECONDS # -g + integer

# Functions are unaffected: function definitions are always global.
my_lib_function() { :; }

# --- caller.bash ---
load_lib() { source ./lib.sh; }
load_lib
echo "version=${LIB_VERSION}"           # ⇒ version=1.0
echo "name=${LIB_NAME}"                 # ⇒ name=strings
```

The `-g` flag is harmless when the library is sourced at script top
level (where `declare` and `declare -g` have the same effect) but
load-bearing when sourced from inside a function. A library that
*may* be lazy-loaded must therefore use `declare -g` *unconditionally*
for every variable it intends to export, regardless of whether the
current call site happens to be at top level.

The same rule applies to `declare -i`, `declare -r`, `declare -a`,
`declare -A`: combine each with `-g` when defining library globals.
`declare -gri` is a common BCS idiom for an immutable global integer
constant.

### Conditional loading

Different libraries for different environments — `bash`-specific
helpers when running under bash, OS-specific helpers based on
`uname`, version-specific helpers based on `BASH_VERSINFO`. The
mechanism is plain `if` plus `source`; the caveat is that the
`declare -g` rule applies if the conditional sits inside a function.

```bash
# scenario: OS-conditional library load
load_platform_lib() {
  case ${OSTYPE} in
    linux-gnu*)  source "${MYAPP_LIB_DIR}/linux.sh"  ;;
    darwin*)     source "${MYAPP_LIB_DIR}/macos.sh"  ;;
    *)           die 1 "unsupported OS: ${OSTYPE}"  ;;
  esac
}
load_platform_lib                       # both libraries must use declare -g
```

Conditional loading composes naturally with the version-detection
predicates of §10.7 (`bash_at_least 5 2`) — load a polyfill library
on older bash, a thin pass-through on new bash.

**See also**: §10.1 (`source` semantics), §10.4 (idempotent
sourcing guards), §10.7 (version negotiation), §9.3 (`local` and
scope — why `declare -g` is required), BCS0202 (variable scoping),
BCS0408 (dependency management — lazy loading guidance), BCS-bash
`30_02_dot-source.md`.

#fin
