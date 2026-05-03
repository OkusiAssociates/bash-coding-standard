<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.5 The `trap` builtin

`trap` registers handler commands for signals and pseudo-signals. The
handler is a *string* that bash re-parses and evaluates in the shell's
own context every time the trap fires; understanding when that string is
expanded is the difference between a working cleanup and a silent footgun.

### Forms

| Form | Effect |
|------|--------|
| `trap 'CMDS' SIG [SIG …]` | install handler for one or more signals |
| `trap '' SIG` | ignore the signal (cannot be reset by the trap-setter's parent) |
| `trap - SIG` | reset to the default disposition (§12.4) |
| `trap` *or* `trap -p` | print every installed trap in re-loadable form |
| `trap -p SIG` | print just one trap |
| `trap -l` | list signal names and numbers |

A single `trap` call may name several signals; the same handler is
attached to each. Pseudo-signals (`EXIT`, `ERR`, `DEBUG`, `RETURN`) are
mixed freely with real signals on the same call, though the semantics
differ (§12.6).

```bash
# scenario: install one cleanup for three terminating events
trap cleanup EXIT INT TERM
```

### Single quotes vs double quotes — the canonical pitfall

The handler string is expanded **twice**: once by the parser at the time
`trap` is called, and again by the shell each time the trap fires. The
quoting style of the handler decides which expansion wins.

```bash
# wrong — $var captured at trap-set time, frozen for the script's life
var=initial
trap "echo $var" EXIT      # ⇒ becomes: trap 'echo initial' EXIT
var=final
exit                       # prints: initial
```

```bash
# right — $var deferred to trap-fire time
var=initial
trap 'echo $var' EXIT      # the literal string $var is stored
var=final
exit                       # prints: final
```

The double-quoted form interpolates immediately, so the trap captures a
*snapshot* of the variable. The single-quoted form stores the literal
text `$var`, leaving expansion until the handler runs. For state that
changes during the script (which is most state — line numbers, exit
codes, working directories), single quotes are mandatory (BCS0301,
BCS0603).

The same rule governs `$LINENO`, `$BASH_COMMAND`, `$?`, `$BASH_SOURCE`,
and any function call that should resolve at fire time:

```bash
# wrong — $LINENO is the line where trap was installed (always the same)
trap "echo failed at $LINENO" ERR

# right — $LINENO is the line where the failing command lives
trap 'echo failed at $LINENO' ERR
```

### Functions as handlers

Wrap non-trivial logic in a function and trap the function name. Bash
re-evaluates the *string* on each fire, so `trap cleanup EXIT` becomes a
single-token call to whatever `cleanup` resolves to at fire time —
including overrides installed later in the script.

```bash
# scenario: function-handler form; pass the failing line number explicitly
#!/usr/bin/env bash
set -eEuo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

on_err() {
  local -i rc=$?
  local -i ln=$1
  printf >&2 'ERR rc=%d at line %d: %s\n' "$rc" "$ln" "$BASH_COMMAND"
  exit "$rc"
}

# Single quotes around the whole handler so $LINENO defers; the
# function call itself takes the deferred value as a positional arg.
trap 'on_err $LINENO' ERR

work() { false; }                 # ⇒ on_err prints rc=1 at line 13: false
work
```

### Inspecting and clearing

`trap -p` prints every trap in a form that can be `eval`'d to restore
state. This is the supported way for one function to save and later
restore the calling context's traps:

```bash
# scenario: save and restore the EXIT trap around a critical section
saved=$(trap -p EXIT)             # eval-restorable string
trap 'rollback' EXIT
do_risky_thing
eval "${saved:-trap - EXIT}"      # restore exactly; default if none was set
```

`trap - SIG` resets a single signal to its default disposition;
`trap '' SIG` ignores it entirely (and any child `exec`'d from this
shell inherits the *ignored* state — see §12.9).

### Multiple-signal install — three equivalent forms

```bash
# scenario: one handler, three signals — three styles
trap cleanup EXIT INT TERM        # space-separated names
trap cleanup EXIT INT TERM HUP    # add SIGHUP for daemons (§12.16)
trap cleanup 0 2 15               # numeric form (0 = EXIT)
```

Mixing names and numbers is allowed but unidiomatic. Names survive
across kernels and platforms; numbers do not (signal 10 is SIGUSR1 on
Linux but SIGBUS on some BSDs — see §12.2).

### Strict-mode interaction

Under `set -e`, a trap handler that exits non-zero will *itself*
trigger errexit on the way out — but EXIT is already firing, so the
effect is to override the script's exit status. Always end EXIT and ERR
handlers with an explicit `exit "$rc"` (or `return "$rc"` from a
function) to preserve the caller's outcome (BCS0110).

The handler runs in the *parent* shell, not a subshell — assignments
inside the handler persist (or, in the case of EXIT, persist for the
remaining lifetime of the dying shell). `inherit_errexit` does *not*
affect trap inheritance; that is governed by `set -E` and `set -T`
(§12.8).

**See also**: §12.4 (signal disposition), §12.6 (pseudo-signals
EXIT/ERR/DEBUG/RETURN), §12.7 (`trap -p` and inspection), §12.8 (trap
inheritance), §12.10 (synchronous vs asynchronous delivery), §12.11
(signal-safe code), §12.12 (idempotent cleanup), BCS0110, BCS0301,
BCS0603, BCS-bash `30_48_trap.md`.

#fin
