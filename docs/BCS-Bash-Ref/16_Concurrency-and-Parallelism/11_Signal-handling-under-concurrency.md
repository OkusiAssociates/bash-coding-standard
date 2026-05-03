<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.11 Signal handling under concurrency

A script with background children is a small process group. When the
user presses Ctrl-C, the terminal sends `SIGINT` to the *foreground
process group* — but only the parent is in that group; backgrounded
workers are not, and they keep running, orphaned, until they finish or
the kernel reaps them via the parent's death. To clean up properly the
parent must catch the signal and forward it to its children
explicitly. This is the trap-and-forward pattern, and every fan-out
script needs it (BCS0110, BCS0603).

### Trap-and-forward template

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -a pids=()

cleanup() {
  local -i rc=$?
  # forward TERM to every child still alive; ignore "no such process"
  if (( ${#pids[@]} )); then
    kill -TERM "${pids[@]}" 2>/dev/null || true
    wait "${pids[@]}" 2>/dev/null || true
  fi
  exit "$rc"
}
trap cleanup EXIT
trap 'cleanup' INT TERM HUP

# scenario: dispatch workers, register PIDs before any await
for host in host1 host2 host3; do
  worker "$host" &
  pids+=("$!")
done

# wait for all; if a signal arrives during wait, cleanup runs
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
# ⇒ Ctrl-C kills children before parent exits; no orphans
```

Three points are load-bearing:

1. **Register the PID immediately after `&`.** A signal that arrives
   between `worker &` and `pids+=("$!")` will not see the new child.
   Keep the two lines adjacent and never compute anything between them.
2. **`wait` is interruptible.** When `INT` arrives, `wait` returns 128+N
   and the trap runs; `set -e` would otherwise abort. The `|| true`
   suppresses the non-zero status from a killed child.
3. **EXIT is the canonical cleanup hook.** It fires on normal exit,
   `set -e` exit, and trap-driven exit alike, so the same `cleanup`
   function covers every path. Adding traps for `INT TERM HUP` simply
   converts those signals into an `exit`.

### Whole-process-group kill (`kill 0`)

If the parent and all its children share a process group, `kill 0`
signals the entire group in one call:

```bash
# scenario: process-group fan-out under set -m (job control)
set -m                    # each backgrounded pipeline gets its own pgid
                          # in interactive shells; non-interactive needs
                          # explicit setsid
trap 'kill -- -$$ 2>/dev/null; exit 130' INT TERM
# kill -- -PID  →  kill the process group whose pgid == PID
# at the parent, $$ is its own pgid only if it leads the group
```

`kill 0` (no PID) sends to the *caller's* process group, which
includes the script and all children that have not detached. This is
the simplest variant and is preferred where job control is not in
play:

```bash
trap 'trap - INT; kill 0' INT
# ⇒ on Ctrl-C: clear the trap (avoid recursion), signal the whole group
# the parent then takes the same signal and exits
```

### Pitfalls

- **Children must trap independently.** A trap installed in the parent
  is *not* inherited by `exec`'d processes (only by subshells). If a
  worker is `exec foo`, the parent's `trap` is gone. Wrap the worker:
  `( trap '...' TERM; exec foo )`.
- **`SIGKILL` cannot be trapped.** If the parent dies on `KILL`, no
  cleanup runs; orphan children become init's responsibility. For
  systemd services use `KillMode=mixed` so the unit kills the whole
  cgroup.
- **Re-entry is queued, not parallel.** A second `INT` while the trap
  is running is held until the handler returns; do the destructive
  work first and the user-facing output last so a second Ctrl-C still
  produces a clean exit.
- **`wait` returns 128+N on signal.** When a child dies on a signal,
  `wait` returns `128 + signum` (e.g. 130 for `SIGINT`). Treat this
  as a normal child status (§16.4); do not special-case it unless the
  caller cares about the difference between "child failed" and "child
  was killed".

### Process-group ownership

In a non-interactive script, all children of the parent share the
parent's process group by default. Job control (`set -m`) is *off* in
non-interactive shells unless explicitly enabled. To start a child in
its own process group — useful when the child must survive the
parent's signal — use `setsid`:

```bash
# scenario: detach a long-running worker into its own process group
setsid -f --wait worker "$@" &
detached_pid=$!
# ⇒ worker runs with a fresh pgid; kill 0 in the parent does not reach it
```

Conversely, `kill -TERM -- -"$detached_pgid"` signals the *whole* group
of the detached child, including any grandchildren it spawned — useful
for hierarchies the parent must clean up but does not directly own.

**See also**: §16.10 (locking — signals during a lock), §11 (process
management, pgid mechanics), §12 (traps in detail), BCS0110, BCS0603.

#fin
