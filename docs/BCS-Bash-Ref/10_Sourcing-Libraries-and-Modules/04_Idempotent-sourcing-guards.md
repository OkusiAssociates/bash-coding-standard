<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.4 Idempotent sourcing guards

A guard at the top of a library that prevents double-loading when
two callers each source it. Critical for any library that defines
state-bearing structures (associative arrays, file-handle slots),
runs trap installations, or has costly initialisation.

```bash
[[ -n ${_MYLIB_LOADED:-} ]] && return
_MYLIB_LOADED=1
```

- Use a unique sentinel name per library (typically the library's
  namespace prefix, uppercased, with `_LOADED` suffix).
- Place at the top of the library, *before* any work.
- Avoids duplicate function definitions, redundant variable
  initialisation, and double-installed traps.
- Combined with `set -e` exemption: `[[ ]] && return` is in `&&`
  context, so the guard itself is exempt from errexit.

### Demonstrating the no-op behaviour

The simplest way to see the guard work is to add a side-effecting
print to the library and source it twice. Without the guard, the
print runs both times; with it, only the first.

```bash
# scenario: the guard makes a second `source` a clean no-op.
# ── /tmp/mylib.sh ─────────────────────────────────────────────
[[ -n ${_MYLIB_LOADED:-} ]] && return          # guard (BCS0407)
declare -gri _MYLIB_LOADED=1                   # sentinel (-g for in-function safety, §10.8)

>&2 echo 'mylib: initialising'                 # side effect — should run only once
declare -gA _MYLIB_CONFIG=()
_MYLIB_CONFIG[host]='localhost'
_MYLIB_CONFIG[port]=8080

mylib::greet() { printf 'hello, %s\n' "${1:-world}"; }
#fin

# ── /tmp/main.sh ──────────────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/mylib.sh                           # ⇒ stderr: mylib: initialising
source /tmp/mylib.sh                           # ⇒ silent — guard short-circuits
source /tmp/mylib.sh                           # ⇒ silent — guard short-circuits
mylib::greet 'gd'                              # ⇒ hello, gd
echo "host=${_MYLIB_CONFIG[host]}"             # ⇒ host=localhost
#fin
```

Output: `mylib: initialising` then `hello, gd` then
`host=localhost`. The library prints its initialisation message
exactly *once*; the sentinel prevents subsequent sources from
re-running the body. Without the guard, any associative-array
initialisation would also clobber values the first source had
populated (a common "I set it and now it's gone" bug).

`declare -gri`: `-g` makes the sentinel a *global* declaration even
if the source happens inside a function (§10.8); `-r` makes it
readonly; `-i` declares integer. For non-integer sentinels,
`declare -gr` suffices.

**See also**: §10.1 `source` semantics (how `return` from a sourced
file behaves), §10.5 namespace prefixes (where `_MYLIB_` comes from),
§10.7 version negotiation (often paired with the guard so the
sentinel encodes the version), §10.8 lazy loading (`declare -g`
inside a function), BCS0407 (library patterns).

#fin
