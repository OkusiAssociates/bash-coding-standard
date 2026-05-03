<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.10 `kill` and signal delivery

The `kill` builtin sends a signal to a process or process group via the
`kill(2)` syscall. Despite the name, it is the general-purpose signal
delivery primitive — not just for termination.

| Form | Effect |
|------|--------|
| `kill PID`             | send SIGTERM to the process |
| `kill -SIGNAL PID`     | send SIGNAL by name (`TERM`, `SIGTERM`) or number (`15`) |
| `kill -SIGNAL %n`      | send SIGNAL to the *process group* of job `%n` |
| `kill -0 PID`          | send no signal; test process existence (`$?` = 0 if alive) |
| `kill -l`              | list signal names/numbers |
| `kill -L`              | list as a `name=number` table |
| `kill -SIGNAL -PID`    | **negative PID** — send to the process group with that pgid |

Signal names accept both the bare form (`TERM`) and the `SIG`-prefixed
form (`SIGTERM`); the standard table lives in Appendix K.

### Process-group delivery: the negative-PID form

The killer feature of `kill(2)` — and the source of most surprises — is
that a *negative* PID denotes a process group. `kill -TERM -1234` does
not kill PID 1234; it sends SIGTERM to **every process whose pgid is
1234**. The pgid is normally the PID of the process-group leader (see
§11.6).

```bash
# scenario: signal a child and all its descendants
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
set -m                                    # job control on (§11.7)

# Launch a child that itself spawns grandchildren
bash -c 'sleep 100 & sleep 200 & sleep 300 & wait' &
leader=$!                                  # pgid of the new group

sleep 0.1                                  # let grandchildren be born
ps -o pid,pgid,comm --ppid "$leader"       # show the family tree

kill -TERM -"$leader"                      # negative PID → whole group
wait "$leader" 2>/dev/null || true

# ⇒ Without the leading minus, only the leader dies; the three sleeps
#   become orphans of init/systemd and continue running.
```

The two semantics are easy to confuse because the PID and pgid are the
same number for the group leader. The minus sign is what matters.

### Targeting a job's process group

`%n` is shorthand for "the process group of job `n`":

```bash
sleep 100 &              # %1
sleep 200 | cat &        # %2 (a 2-process pgid)
kill -TERM %2            # kills both sleep and cat — they share a pgid
```

This is how `Ctrl-C` works at the terminal: the kernel sends SIGINT to
the foreground process group, not to a single PID. A pipeline
foregrounded with `fg` becomes one pgid; one keystroke ends them all.

### Existence probe with `-0`

`kill -0 PID` performs all permission checks of a real `kill(2)` but
delivers no signal. It is the canonical "is this process still running"
test:

```bash
# scenario: probe a recorded PID before signalling
if kill -0 "$daemon_pid" 2>/dev/null; then
  kill -TERM "$daemon_pid"
else
  warn "daemon $daemon_pid no longer exists"
fi
```

### External cousins: `pkill`, `killall`, `pgrep`

`pkill -SIGNAL pattern` matches by command name (regex). `killall name`
matches by exact name. Both are external (`procps-ng`), not builtins.
Prefer the builtin `kill` against captured PIDs — name-based matching is
brittle in scripts and can hit the wrong process on shared hosts.

**See also**: §11.5 (foreground/background), §11.6 (process groups and
sessions), §11.7 (job table), §11.9 (job-control builtins), §12 (signals
and traps), §12.1 (signal taxonomy), Appendix K (signal numbers),
BCS-bash `30_31_kill.md`, BCS0603 (trap handling).

#fin
