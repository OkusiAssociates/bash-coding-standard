<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN

Bash extends `trap` with four *pseudo-signals* — events that are not
delivered by the kernel but synthesised by the shell at well-defined
moments in script lifecycle. Each is trapped with the usual `trap
HANDLER NAME` syntax and inspected with `trap -p NAME`. They are the
primary mechanism for cleanup, diagnostics, tracing, and call-graph
instrumentation. None can be caught with a numeric signal number;
they exist only by name.

### EXIT

Fires once, when the shell process is about to exit, by any path
short of `SIGKILL`. This includes normal end-of-script, explicit
`exit N`, errexit triggering (§13.2), receipt of any catchable
terminating signal (SIGINT, SIGTERM, …) and even uncaught `set -e`
exits. EXIT is the canonical place for cleanup that must run no matter
how the script ends — temp files, lockfiles, terminal-state restoration.

`$?` inside the EXIT trap holds the script's outgoing exit status
(captured before the handler runs). Capturing it as the *first*
statement of the handler is mandatory; any subsequent command will
overwrite it.

```bash
# scenario: EXIT trap captures rc; cleans up temp dir; preserves status
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- TMPDIR
TMPDIR=$(mktemp -d)
cleanup() {
  local -i rc=$?                       # FIRST line: capture before clobber
  [[ -n ${TMPDIR:-} && -d $TMPDIR ]] && rm -rf -- "$TMPDIR"
  exit "$rc"                            # preserve outgoing status
}
trap cleanup EXIT

work_in "$TMPDIR"
# whether work_in succeeds, fails, or the script is SIGTERM'd,
# cleanup runs exactly once.
```

EXIT fires *exactly once* per shell instance. Subshells get their own
EXIT trap; the parent's EXIT trap fires only when the parent exits.
Reinstalling EXIT inside the handler is a no-op — the shell is
already exiting.

### ERR

Fires whenever a command exits non-zero under conditions that *would*
cause `set -e` to exit. ERR is therefore subject to the exemption
matrix (§13.3): a `false` on the left of `&&`, in an `if` test, or
prefixed by `!` does not fire ERR, just as it does not exit. ERR
fires *before* the shell exits, so a handler can log diagnostics and
still let errexit run its course; alternatively, the handler may
`exit N` itself with a chosen code.

ERR is *not* inherited by functions, command substitutions, or
subshells unless `set -E` (`errtrace`, §13.9) is also set. Without it,
an ERR trap installed at the top level only fires for top-level
commands.

Useful variables inside the handler:

- `$?` — the failing command's exit status.
- `$BASH_COMMAND` — the literal command text that failed.
- `$LINENO` — line number of the failing command (in the current source).
- `BASH_SOURCE[]`, `BASH_LINENO[]`, `FUNCNAME[]` — full call stack.

```bash
# scenario: ERR trap with full diagnostic stack
#!/usr/bin/env bash
set -eEuo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

on_err() {
  local -i rc=$?                       # FIRST line: capture
  local -- cmd="$BASH_COMMAND"
  local -i ln=$1                       # passed by the trap installer
  printf >&2 'ERR rc=%d cmd=[%s] at %s:%d in %s\n' \
    "$rc" "$cmd" "${BASH_SOURCE[1]##*/}" "$ln" "${FUNCNAME[1]:-MAIN}"
  exit "$rc"
}
trap 'on_err $LINENO' ERR

probe() { false; }                     # ⇒ ERR fires inside probe (set -E)
probe
```

The `'on_err $LINENO'` (single-quoted) form is essential: the
expansion of `$LINENO` is deferred to the moment the trap fires,
giving the failing line number, not the line where the trap was
installed. This is the canonical trap-quoting rule (§12.5).

### DEBUG

Fires *before* every simple command. The handler runs with the
about-to-execute command in `$BASH_COMMAND`; if the handler returns a
non-zero status and `extdebug` is on, the command is *skipped*. This
is the mechanism behind `set -x` (xtrace) and tools like
`bashdb`. Stepping, breakpointing, and pre-command instrumentation
all hang off DEBUG.

DEBUG is *not* inherited by functions or subshells unless `set -T`
(`functrace`) is also set. Inside loops, DEBUG fires once per
iteration's body command, *not* once per loop. Pipeline components
each fire DEBUG in their own subshells (with `-T`).

```bash
# scenario: DEBUG trap as a tracer
#!/usr/bin/env bash
set -uo pipefail; set -T               # functrace; not -e for the demo
shopt -s inherit_errexit shift_verbose extglob nullglob

trace() { printf >&2 '+ %s:%d %s\n' "${BASH_SOURCE[1]##*/}" "$1" "$BASH_COMMAND"; }
trap 'trace $LINENO' DEBUG

greet() {
  local -- name="$1"
  echo "Hello, $name"
}
greet world
# ⇒ trace fires before each command:
# + script.bash:13 greet world
# + script.bash:9  local -- name="$1"
# + script.bash:10 echo "Hello, $name"
```

In production scripts, DEBUG is rarely installed permanently — it is a
heavy hook (one handler invocation per command). For end-user
tracing, prefer `set -x` (or `BASH_XTRACEFD=`) which is implemented
on top of the same machinery but with built-in formatting.

### RETURN

Fires when a shell function returns or a sourced script (`.` /
`source`) finishes loading. Useful for "leave-function" instrumentation
and for sourced-library teardown. Like DEBUG, RETURN is not inherited
into functions unless `set -T`.

`$?` inside RETURN holds the function's (or sourced script's) exit
status; `FUNCNAME[0]` (in the trap, indexes shift) identifies the
returning function.

```bash
# scenario: RETURN trap as a function-leave tracer
#!/usr/bin/env bash
set -uo pipefail; set -T
shopt -s inherit_errexit shift_verbose extglob nullglob

leave() {
  local -i rc=$?                       # FIRST line: capture
  printf >&2 '<- %s rc=%d\n' "${FUNCNAME[1]:-?}" "$rc"
  return "$rc"                          # do not mask original status
}
trap leave RETURN

work() { sleep 0.01; return 0; }
fail() { return 7; }
work; fail
# ⇒ <- work rc=0
# ⇒ <- fail rc=7
```

The `return "$rc"` discipline mirrors the EXIT-trap `exit "$rc"`
pattern: a trap handler must not silently overwrite the status it was
called to observe.

### Combining pseudo-signals

All four pseudo-signals can be installed simultaneously. The order of
firing for a failing command at top level is:

1. DEBUG fires (with the about-to-run command in `$BASH_COMMAND`).
2. The command runs, returns non-zero.
3. ERR fires (if not in an exempt context, §13.3).
4. errexit triggers; the shell proceeds toward exit.
5. RETURN fires for any in-progress function being unwound (with `-T`).
6. EXIT fires.

Each handler is independent; one handler's exit status does not
suppress the next. Handlers should be *defensive*: capture `$?` first,
do their job, restore the captured status with `return` / `exit`.

### Trap inspection

`trap -p` lists all installed traps with their handlers, including
pseudo-signals. `trap -p ERR` shows just the ERR trap. `trap -- '' NAME`
ignores a (real) signal — but pseudo-signals cannot be ignored; they
can only be re-set with a no-op handler (`trap : ERR` makes ERR a
silent observer).

### Practical guidance

Use EXIT for cleanup, ERR for error diagnostics, DEBUG for tracing
during development, RETURN for tearing down sourced libraries or
profiling function calls. EXIT and ERR belong in production scripts;
DEBUG and RETURN are diagnostic tools used selectively.

Pair ERR with `set -E` (§13.9) and EXIT with the captured-rc preamble
(`local -i rc=$?`). The BCS template (BCS0110) ships an EXIT-trap
skeleton that integrates with the strict-mode contract.

**See also**: §12.5 (trap builtin and quoting), §12.7 (`trap -p`),
§12.8 (trap inheritance), §12.12 (idempotent cleanup), §13.2
(errexit), §13.8 (ERR trap deep-dive), §13.9 (errtrace contract),
BCS0110 (cleanup and traps), BCS-bash `30_48_trap.md`.

#fin
