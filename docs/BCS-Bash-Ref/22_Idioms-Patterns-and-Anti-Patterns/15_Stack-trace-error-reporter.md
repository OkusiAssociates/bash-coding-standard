<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.15 Stack-trace error reporter

Use this when an unexpected error in a long script needs to be diagnosed
without instrumenting every function call by hand. Bash exposes three
parallel arrays — `FUNCNAME`, `BASH_SOURCE`, and `BASH_LINENO` — that
together describe the live call stack. A small `ERR`-trap handler walks
them and prints a Python-style backtrace, turning "the script died on
line 217" into "the script died at `do_thing` (`lib/work.bash:42`)
called from `main` (`bin/runner:217`)".

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME="${0##*/}"

# stack_trace — print a backtrace of the current call stack to stderr.
#
# Array alignment (the only tricky part):
#   FUNCNAME[i]     — name of frame i; FUNCNAME[0] is this function.
#   BASH_LINENO[i]  — line in BASH_SOURCE[i+1] where FUNCNAME[i] was called.
#   BASH_SOURCE[i]  — file containing FUNCNAME[i].
#
# Frame 0 is always `stack_trace` itself, so start the walk at i=1.
stack_trace() {
  local -i i frames=${#FUNCNAME[@]}
  local -- fn src line

  printf '%s: stack trace (most recent call last):\n' "$SCRIPT_NAME" >&2
  for ((i = frames - 1; i >= 1; i--)); do
    fn=${FUNCNAME[i]}
    src=${BASH_SOURCE[i]:-<unknown>}
    line=${BASH_LINENO[i-1]:-0}
    printf '  at %s (%s:%d)\n' "$fn" "$src" "$line" >&2
  done
}

# err_handler — wired to ERR; prints the failing command, its exit code,
# and a stack trace. Single-quoted on installation so $? and BASH_COMMAND
# are evaluated when the trap fires, not when it is registered.
err_handler() {
  local -i exitcode=$1
  local -- cmd=$2
  local -- src=${BASH_SOURCE[1]:-<unknown>}
  local -i line=${BASH_LINENO[0]:-0}

  printf '%s: error: command %s failed (exit %d) at %s:%d\n' \
    "$SCRIPT_NAME" "${cmd@Q}" "$exitcode" "$src" "$line" >&2
  stack_trace
  exit "$exitcode"
}

trap 'err_handler "$?" "$BASH_COMMAND"' ERR
set -o errtrace            # propagate ERR into functions, subshells, command subs

# --- demo --------------------------------------------------------------
inner() {
  local -- file=$1
  cat -- "$file"           # will fail if $file does not exist
}

outer() {
  inner /no/such/file
}

main() {
  outer
}

main "$@"
#fin
```

Sample output when `inner` is called with a missing file:

```
demo: error: command 'cat -- "$file"' failed (exit 1) at lib/work.bash:53
demo: stack trace (most recent call last):
  at main (bin/demo:65)
  at outer (bin/demo:60)
  at inner (lib/work.bash:53)
```

The walking direction matters. The arrays are indexed from
*innermost-first* (frame 0 is the currently executing function), so
walking `i = frames-1 down to 1` prints `main` first and the failing
function last — the same order Python uses, the order operators
expect. The `i-1` offset on `BASH_LINENO` is required because
`BASH_LINENO[i]` records the line of the *caller* of `FUNCNAME[i+1]`,
not of `FUNCNAME[i]` itself; this off-by-one is the single most common
source of broken bash backtraces.

`set -o errtrace` (equivalently `set -E`) is essential. Without it, the
`ERR` trap is *not* inherited by shell functions, command substitutions,
or subshells — so a failure inside `outer` would silently exit without
firing the trap. Adding it costs nothing and ensures every error path
is reported.

**Common bug: trap registered with double quotes.**

```bash
# wrong — $? and $BASH_COMMAND are expanded NOW, when the trap is set,
# capturing 0 and the empty string forever.
trap "err_handler $? $BASH_COMMAND" ERR

# correct — single quotes defer expansion until the trap fires, so the
# real exit code and failing command reach the handler.
trap 'err_handler "$?" "$BASH_COMMAND"' ERR
```

**See also**: §13.12 for the full discussion of error reporting,
trap-DEBUG vs trap-ERR, and integrating backtraces with logging
frameworks. BCS0603 (trap handling) and BCS0601 (exit on error) for
the rule-level statements; BCS1207 covers the related `PS4` debugging
pattern that uses the same `FUNCNAME`/`BASH_SOURCE` arrays.

#fin
