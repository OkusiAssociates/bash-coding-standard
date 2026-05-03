<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.1 Processes — fork, exec, wait

The kernel-level process model on which every Bash construct ultimately rests. Bash decomposes "what a command is" into builtins (executed in-process), functions (executed in the current shell or a subshell depending on context), and external commands (executed via `fork(2)` followed by `execve(2)`).

### Syscall lifecycle

| Syscall | Effect | What carries over |
|---------|--------|--------------------|
| `fork(2)` | Duplicates the calling process. Child gets a fresh PID; parent receives the child's PID, child receives 0. | File descriptors (with their offsets), signal dispositions, environment, working directory, umask, controlling terminal. |
| `execve(2)` | Replaces the process image with a new programme. PID and PPID are preserved. | Open fds without `O_CLOEXEC`, environment (as supplied), PID. **Reset:** signal handlers (custom handlers revert to default), pending alarms. |
| `wait(2)` / `waitpid(2)` | Reaps a child and unblocks the parent. Returns the child's PID and status. | Status word encodes normal exit vs signalled termination (see §1.7). |

Bash's `fork → exec → wait` cycle is what runs every external command. Builtins skip `fork` (they execute in the current shell unless inside a pipeline subshell); shell functions also skip `fork` unless backgrounded or piped.

### `$$` versus `$BASHPID`

`$$` is the PID of the **script process**, fixed at startup and inherited unchanged by every subshell. `$BASHPID` is the PID of the **current shell**, refreshed in subshells. Use `$BASHPID` for any check that must distinguish a subshell from its parent.

```bash
# scenario: prove $$ is frozen, $BASHPID tracks subshell identity
echo "main: $$=$$ BASHPID=$BASHPID"
( echo "subshell: $$=$$ BASHPID=$BASHPID" )   # ⇒ $$ identical, BASHPID differs
```

### Concrete fork+exec

The shell forks for every external command. The child then `execve`s the target binary, inheriting the parent's fds and environment.

```bash
# scenario: fork+exec a child and reap it explicitly
date &                  # fork; child execs /usr/bin/date
declare -i child=$!     # PID returned by Bash's fork
wait "$child"           # waitpid(child) — reaps the zombie
echo "exit=$?"          # ⇒ 0 on success
```

### Zombies and orphans

A **zombie** (state `Z` in `ps`) is a terminated child whose status has not yet been reaped. Bash's `wait` builtin issues `waitpid(2)` and clears it. An **orphan** is a child whose parent died first; it is re-parented to PID 1 (or to the nearest sub-reaper marked by `prctl(PR_SET_CHILD_SUBREAPER)`), which inherits the duty to reap.

```bash
# scenario: deliberately produce a transient zombie
sleep 0.1 &
declare -i pid=$!
sleep 0.2
ps -o pid,stat,comm -p "$pid" 2>/dev/null   # ⇒ may show "Z" before wait
wait "$pid" || true                         # reap; status now collected
```

### Bash `wait` versus `waitpid(2)`

Bash's `wait` is a thin wrapper. `wait` (no arg) blocks until **all** background children are reaped; `wait PID` blocks for one; `wait -n` blocks until any single child finishes; `wait -f PID` waits for the process to terminate even if status was already reported (Bash 5.1+). See also §11.3 (wait patterns) and BCS1103.

### Process groups and sessions

Each pipeline runs in its own process group, allowing `Ctrl-C` to signal the whole group at once. Sessions group process groups under one controlling terminal. The deeper treatment — `setpgid(2)`, `setsid(2)`, foreground/background scheduling — is in §11.6.

**See also**: §1.2 (file descriptor inheritance across fork/exec), §1.7 (encoding of `wait` status), §11.6 (process groups), §17.1 (`coproc` lifecycle), BCS0101 (strict mode), BCS0408 (dependency management).

#fin
