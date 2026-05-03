<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.11 Signal-safe code

A signal handler runs in the same shell as the script that installed
it. Anything the handler does competes with whatever the main script
was doing, in the shell's own state. The C concept of *async-signal
safety* — the short list of syscalls a handler may invoke without
deadlock or reentrancy — translates into bash as a similar short list
of operations a `trap` handler may perform without surprising itself or
the main flow.

### What is unsafe

| Operation | Why it is unsafe |
|-----------|------------------|
| `read` | Race against pending stdin or readline state; partial reads on EINTR |
| `wait` (with no PID) | Can deadlock if the trapped signal arrives during the wait |
| Subshell pipelines (`a \| b`) | Each component is a fork; signal may arrive mid-fork |
| Long external commands | Defer further trap handling until they return |
| Recursive trap invocation | Same signal during handler may be coalesced or dropped |
| Modifying global state without a lock | Main flow may be mid-update of the same variable |

Bash itself protects most of its critical sections — variable
assignments, pipeline setup, internal command execution — by deferring
asynchronous signal delivery to the next safe point (§12.10). What it
does *not* protect is your handler's interaction with the main script's
shared state. A handler that runs `pkg=$(some_lookup)` while the main
flow is also doing `pkg=…` is a data race even if neither line is
itself dangerous.

### What is safe

- Simple variable assignment: `STOP=1`, `caught_sig=$1`.
- `printf` / `echo` to stderr (file descriptors are reentrant enough).
- `kill` of a known PID (the kernel serialises).
- Calling functions whose own bodies obey the same rules.
- `exit "$rc"` — the canonical handler-terminator.
- Re-installing the trap (a no-op in bash; included for portability).

The unifying principle: **set a flag; let the main loop act on it.**
The handler is a notification, not a worker.

### The flag-and-defer pattern

The textbook approach to a slow handler is to defer the work to the
main loop. The handler does the minimum necessary — capture the signal,
mark intent — and returns. The main loop polls the flag at safe points
and does the actual work in the script's normal control flow.

```bash
# scenario: graceful shutdown of a long-running worker loop
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i STOP=0
declare -i RELOAD=0

on_term() { STOP=1; }              # tiny handler: flag-set only
on_hup()  { RELOAD=1; }            # tiny handler: flag-set only

trap on_term INT TERM
trap on_hup  HUP

reload_config() {
  RELOAD=0                          # clear flag *first* (race: another HUP wins next loop)
  source -- /etc/myapp/config.conf  # heavy work, but in main flow
}

reload_config
while (( ! STOP )); do
  (( RELOAD )) && reload_config
  process_one_unit_of_work          # short; checks flag often
done

cleanup_and_exit                    # in main flow, not a handler
```

The signal arrives, sets the flag, returns. The main loop notices
within one iteration and runs the (potentially slow) reload from a
context that is allowed to do anything.

Two subtle disciplines worth calling out:

- **Clear the flag before acting on it.** If a second SIGHUP arrives
  during `reload_config`, you want the *next* loop iteration to reload
  again, not for the in-progress reload to swallow it.
- **Make the inner work-unit short.** The flag is checked once per
  iteration; long inner work delays shutdown.

### Coalescing and queue depth

POSIX guarantees that *at least one* delivery happens for an
unblocked signal that was raised, but not that every raise produces a
separate delivery. Bash inherits this: a flurry of fifty SIGUSR1s in
a millisecond may produce a single trap fire. Handlers must therefore
be **idempotent** — a flag-set handler is naturally idempotent
(`STOP=1` is the same after one fire or fifty), which is a second
reason the pattern wins.

### Re-installing inside the handler

Some POSIX C signal APIs reset a handler to default after firing,
requiring re-installation inside the handler itself. Bash does **not**
do this — `trap` installs a *persistent* disposition. Re-installing
inside the handler is harmless but unnecessary; remove it from any
script ported from sh or C.

### Handler-from-handler

If a second signal of a *different* kind arrives while a handler is
running, bash queues it and runs it after the current handler returns.
The handlers do not nest. This is normally what you want, but it means
a handler that itself calls `sleep` or any blocking operation is
delaying *all* other trap handling for the duration.

### Strict-mode interaction

Under `set -e`, a non-zero exit inside a handler propagates: a `kill`
returning non-zero (because the target already exited) will errexit
the handler. Guard with `|| true`:

```bash
# scenario: signal-safe child reaping in cleanup
cleanup() {
  local -i rc=$?
  (( CHILD )) && kill -TERM "$CHILD" 2>/dev/null || true
  wait "$CHILD" 2>/dev/null || true
  exit "$rc"
}
```

`set -u` is equally relevant: a handler that references an unset
variable will errexit and skip the rest of the cleanup. Use the
`${var:-}` default-expansion form when reading globals that may not
yet be set when the handler fires (BCS0110).

**See also**: §12.5 (trap builtin), §12.6 (pseudo-signals), §12.10
(synchronous vs asynchronous delivery), §12.12 (idempotent cleanup),
§12.16 (SIGHUP reload), BCS0110, BCS0603, BCS1101, BCS-bash
`24_SIGNALS.md`, `30_48_trap.md`.

#fin
