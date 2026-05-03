<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.6 Process groups and sessions

Linux organises processes into a two-level hierarchy above the bare PID:
**process groups** for collective signal delivery, and **sessions** for
controlling-terminal ownership. Job control (§11.5) and detachment
(§11.11, §11.12) both rely on this model. Understanding it is the
difference between killing one stage of a pipeline and killing the
whole pipeline cleanly.

### The model

| Level | Identifier | Purpose |
|-------|-----------|---------|
| Process | PID | Schedulable entity |
| Process group | PGID = PID of group leader | Signal fan-out target |
| Session | SID = PID of session leader | Owns at most one controlling terminal |

A process group is a set of processes that share a PGID; sending a
signal to `-PGID` (negative PID) delivers it to **every** member. A
session is a set of process groups that share a SID and, optionally, a
controlling terminal (`/dev/tty`). The session leader is the only
process that may acquire one.

Relevant syscalls (consult `man 2 setpgid`, `man 2 setsid`,
`man 3 tcsetpgrp` for full semantics):

- `setpgid(2)` — move a process into a process group.
- `setsid(2)` — start a new session; caller becomes session leader and
  loses its controlling terminal.
- `getpgrp(2)`, `getsid(2)` — query.
- `tcsetpgrp(3)` — set the foreground process group of a terminal.

### How Bash builds them

When job control is enabled (`set -o monitor`, default in interactive
shells, off in scripts), Bash places **each pipeline** into its own
process group whose PGID equals the PID of the pipeline's first
command. The shell uses `tcsetpgrp` to hand the terminal to the
foreground job and reclaim it on suspension or exit.

In scripts (`set +m`), Bash does *not* create per-pipeline groups — all
descendants share the script's PGID — so `kill -TERM 0` reaches every
descendant in one call. Test this before relying on it.

### Worked example: inspect pgid and sid

```bash
#!/usr/bin/env bash
# scenario: show pgid/sid for a script, its subshell, and a pipeline.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

ps -o pid,ppid,pgid,sid,comm -p "$$"
( ps -o pid,ppid,pgid,sid,comm -p "$BASHPID" )
sleep 5 | sleep 5 &
ps -o pid,ppid,pgid,sid,comm --ppid "$$"
wait
# ⇒   PID  PPID  PGID   SID COMMAND
# ⇒  4711  4123  4711  4123 bash
# ⇒  4712  4711  4711  4123 bash       (subshell — same PGID/SID)
# ⇒  4713  4711  4711  4123 sleep      (pipeline left)
# ⇒  4714  4711  4711  4123 sleep      (pipeline right)
```

Every descendant shares the script's PGID and SID. Re-run with
`set -m` enabled and the pipeline acquires its own PGID — this is the
behaviour interactive shells exhibit.

### Signal fan-out: kill the group, not the leader

```bash
# scenario: kill a backgrounded pipeline cleanly.
sleep 5 | sleep 5 &
declare -ri pgid=$!         # in scripts the pipeline shares the script's PGID
kill -TERM "-$pgid"         # negative PID → fan out to every group member
wait "$pgid" 2>/dev/null || true
```

A negative `PID` argument to `kill(1)` (and to the Bash `kill` builtin)
delivers the signal to every process in the group. This is the
canonical way to terminate a whole pipeline or a subprocess that has
itself spawned children.

### Footgun: orphaned process groups

A process group whose leader has exited becomes an *orphaned process
group*. The kernel sends `SIGHUP` followed by `SIGCONT` to every
stopped member of an orphaned group when the last live ancestor exits
the session. This is why `nohup` (§11.11) and `setsid` (§11.11) matter
for survivable background work.

### Controlling terminal in a nutshell

The controlling terminal — `/dev/tty` for any process that has one —
is owned by the session leader. Only one process group at a time can
read from it (the *foreground* group); others are stopped with
`SIGTTIN` if they try. `tcsetpgrp(3)` moves the foreground privilege
between groups; the kernel notifies displaced groups with `SIGTTOU`
when they attempt to write. Bash hides this behind `fg`/`bg`/`%n`
job-control commands (§11.9). A daemon's first job is to **drop** the
controlling terminal — that is exactly what `setsid(2)` achieves
(§11.11).

### Common pitfalls

- Sending a `SIGTERM` to the pipeline leader and expecting downstream
  stages to die: in scripts (no job control), every stage shares the
  script's PGID, so the signal must go to `-PGID` to fan out.
- Using `kill 0` thinking it is harmless: `0` is a *PGID specifier*
  meaning "my own group" — the parent script will receive the signal
  too, often killing itself before the children.
- Assuming `setsid cmd` is enough: `setsid(1)` does its work only if
  the caller is not already a process group leader. Use
  `setsid --fork` to guarantee the call (§11.11).

### Strict-mode interaction

`set -e` does not propagate across a `kill -TERM "-$pgid"`; the
backgrounded children's exit status is recovered by `wait`. Combine
with BCS1103 (`wait` patterns) and BCS0603 (trap handling) to drain
process groups cleanly on `EXIT`/`INT`/`TERM`. A typical drain trap:

```bash
# scenario: ensure all background workers die when the script exits.
trap 'kill -TERM "-$$" 2>/dev/null || true; wait' EXIT
```

The negative `$$` argument fans the signal across the script's whole
process group (in script mode, that is every descendant); `wait`
reaps survivors so `EXIT` does not return before they have reported.

**See also**: §11.5 (foreground vs background), §11.7 (job table),
§11.10 (kill), §11.11 (nohup, setsid), §11.12 (detachment),
BCS-bash `25_JOB-CONTROL.md`, BCS0603, BCS1101, BCS1103.

#fin
