<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.10 Synchronous vs asynchronous delivery

Bash does not interrupt itself in mid-command. Asynchronous signals
(SIGINT, SIGTERM, SIGHUP, SIGUSR1, …) are queued by the shell and
delivered only at command boundaries. Synchronous signals (SIGSEGV,
SIGFPE) — which the process raises against itself by faulting — are
delivered the instant they occur, but bash scripts almost never
encounter them.

The practical consequence is the **sleep-trap classic**: a trap
installed for SIGINT will not fire while bash is blocked inside an
external command, because bash itself is parked in a `wait()` syscall.
Only when the child returns does control come back to bash, at which
point the queued trap fires.

### The classic walkthrough

```bash
# scenario: SIGINT during a long external command
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "caught INT"; exit 130' INT

echo "press Ctrl-C now…"
sleep 1000                         # bash is parked in wait()
echo "after sleep"                 # ⇒ never reached if INT was sent
```

What actually happens when the user presses Ctrl-C:

1. The kernel sends SIGINT to the **foreground process group** —
   *both* the shell and the `sleep` child receive it.
2. `sleep` has the default disposition (terminate); it dies with status
   130 (128 + signal 2).
3. Bash's `wait()` returns. Bash *now* notices its own queued SIGINT.
4. The INT trap fires, prints `caught INT`, and the script exits 130.

The user sees a near-instant response, but the response was driven by
the kernel killing the child, not by the trap interrupting bash. The
trap's role was post-mortem.

If the foreground command *catches* SIGINT itself and ignores it, the
shell still has its own queued SIGINT and the trap fires only when the
child eventually exits for some other reason. This is a frequent source
of "Ctrl-C does nothing" bugs in scripts that run interactive children
(editors, pagers, ssh) — the child is consuming the signal.

### Wait-and-invert idiom

To make a long external command *itself* respond to SIGINT while still
running a trap in the parent, run the command in the background and
have bash `wait` for it explicitly. `wait` is the one foreground builtin
that *is* interruptible by traps: an asynchronous signal causes `wait`
to return immediately (with status 128 + signum) and the trap then
fires inside the parent. The child can be left to die naturally or
killed by the trap.

```bash
# scenario: wait-and-invert — Ctrl-C reaches us promptly, child cleaned up
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i CHILD=0

cleanup() {
  local -i rc=$?
  (( CHILD )) && kill -TERM "$CHILD" 2>/dev/null
  wait "$CHILD" 2>/dev/null || true
  exit "$rc"
}
trap cleanup INT TERM EXIT

long_running &                     # background — bash returns immediately
CHILD=$!                            # capture PID for the trap (§11.5)

wait "$CHILD"                       # interruptible: traps fire here
echo "child finished cleanly"
```

The pattern's three load-bearing pieces:

- **`cmd &` then `wait $!`** — bash is no longer in `wait()` on the
  child *directly*; it is in the `wait` *builtin*, which is built to be
  interrupted.
- **PID captured in a global** — `$!` is per-job and would be lost if
  the trap ran in a different context; assigning it to `CHILD` makes
  it available to the cleanup handler.
- **`kill` then `wait` in cleanup** — TERM the child, then wait for it
  to finish so no zombies are left behind. The `2>/dev/null || true`
  guards handle the race where the child has already exited.

This is the single most useful pattern for any script that wraps a
long-running external command and must respond to SIGINT/SIGTERM in
real time. It is also the foundation of the timeout-without-`timeout(1)`
pattern (§12.16, BCS1104).

### When SIGCHLD matters

Bash sets a default SIGCHLD handler when job control is on. Scripts
running with `set -m` (or interactively) receive SIGCHLD when any child
exits, which interrupts `wait` precisely as above. Non-interactive
scripts with job control off still see the same `wait`-interruption
behaviour for the signals they trap; they just don't get the SIGCHLD
notification *for untrapped* child exits.

A script that installs its own SIGCHLD handler is rare and usually
wrong — it competes with bash's reaper. Prefer `wait -n` (§11.5,
BCS1103) to consume child exits one at a time without trapping CHLD.

### Strict-mode interaction

Under `set -e`, a trap-driven `exit "$rc"` from inside `wait` preserves
the failing status. Without the explicit `exit`, the trap returns
normally and the script proceeds — usually not what is wanted. Always
end signal-handling cleanup paths with `exit "$rc"` (BCS0110, BCS0603).

**See also**: §12.5 (trap builtin), §12.11 (signal-safe code), §12.16
(SIGHUP reload), §11.5 (foreground vs background, `wait -n`),
BCS0110, BCS0603, BCS1101, BCS1103, BCS1104, BCS-bash `24_SIGNALS.md`.

#fin
