<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.7 Function tracing

Bash provides three trap-inheritance hooks for observing function
entry, exit, ERR, and individual command execution. None of them
are inherited by functions *by default* — each must be enabled
explicitly.

- `set -T` (alias `set -o functrace`) — DEBUG and RETURN traps are
  inherited by functions, command substitutions, and subshells.
- `set -E` (alias `set -o errtrace`) — ERR trap is inherited by
  functions, command substitutions, and subshells.
- `RETURN` trap — fires when a function returns or sourcing
  completes.
- `DEBUG` trap — fires before each *simple* command.
- `declare -t funcname` — turn on function tracing (DEBUG/RETURN
  inheritance) for a specific function only.
- `declare -ft funcname` — make a function exportable with
  tracing.
- Use cases: instrumentation, profiling, structured debugging
  output, ERR-trap stack-walking.

### DEBUG / RETURN / ERR inheritance

Without `-T` and `-E` the traps below would only fire at the
top level — inside the function body the inheritance is opted out.
Enabling both is the typical "deep tracing" preamble for a
debugging session.

```bash
# scenario: trace function entry, every command, and any ERR fall.
#!/usr/bin/env bash
set -Eeuo pipefail                             # -E: ERR trap inherited
set -T                                         # -T: DEBUG/RETURN inherited (BCS0603)

trap 'printf "[DEBUG] %s\n"  "$BASH_COMMAND" >&2' DEBUG
trap 'printf "[RETURN] %s\n" "${FUNCNAME[0]:-MAIN}" >&2' RETURN
trap 'printf "[ERR] line %s status %s\n" "$LINENO" "$?" >&2' ERR

inner() {
  local -- name="$1"
  printf 'inner: %s\n' "$name"
  false                                        # ⇒ fires ERR trap, then RETURN trap
}

outer() {
  inner 'hello'
}

outer

#fin
```

Run output (abridged):

```
[DEBUG] outer
[DEBUG] inner 'hello'
[DEBUG] local -- name="$1"
[DEBUG] printf 'inner: %s\n' "$name"
inner: hello
[DEBUG] false
[ERR] line 21 status 1
[RETURN] inner
```

Without `set -T` the DEBUG and RETURN traps would only fire for
top-level commands; `inner` and `outer` bodies would be invisible.
Without `set -E` the ERR trap would only catch top-level failures;
the `false` inside `inner` would silently take down the script via
`set -e` with no diagnostic.

The pair `-Eeuo pipefail -T` is the BCS-recommended preamble for
any script that installs ERR/RETURN/DEBUG traps and expects them to
work uniformly across function and subshell boundaries (BCS0603).

**See also**: §9.3 `local` and scope, §12.6 EXIT/ERR/DEBUG/RETURN
pseudo-signals, §13.7 `&&`/`||` and `true` idioms, §13.8 the ERR
trap, BCS0603 (trap handling).

#fin
