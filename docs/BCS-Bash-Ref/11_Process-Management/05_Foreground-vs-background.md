<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.5 Foreground vs background

Bash distinguishes commands the shell waits for (foreground) from
commands launched concurrently (background, suffixed with `&`).
Background jobs are the primitive on which every concurrency idiom in
the reference is built — parallel pools, timeouts, supervisor patterns,
the wait-and-invert idiom (§12.10) — and `$!`, `wait`, `wait -n`, and
`huponexit` are the four builtins that make them tractable.

### The basic forms

```bash
cmd                                # foreground: shell blocks until cmd exits
cmd &                              # background: shell returns immediately
cmd &> log &                       # background with redirection (else inherits stdout/stderr)
```

A backgrounded command keeps the parent's open file descriptors. If you
do not redirect its stdout/stderr, its output interleaves with the
script's. For any non-trivial background job, redirect explicitly.

### `$!` — the just-backgrounded PID

`$!` is set immediately after `cmd &` to the PID of the launched
process. It is *only* set by `&` (and coproc); it is **not** set by
foreground commands or by `(subshell &)`. Capture it on the very next
line, before any other command can clobber it:

```bash
# scenario: capture child PID for later wait/kill
worker &
worker_pid=$!                       # ⇒ snapshot now; $! changes on next &
log_collector &
log_pid=$!

wait "$worker_pid"
worker_rc=$?                        # exit status of the specific child
kill "$log_pid"
```

`$!` is *only* meaningful in the shell that launched the job. A subshell
asking for `$!` after a `cmd &` started in the parent gets the empty
string; capture in the parent and pass through (BCS1101).

### `wait` patterns

`wait` (no args) blocks until *all* known children exit. Its exit
status is 0 if every child exited 0, and the status of the *last* one
that did not, otherwise — a fact that is rarely what callers want.
Prefer one of the targeted forms:

| Form | Semantics |
|------|-----------|
| `wait $pid` | wait for one specific child; status is that child's exit status |
| `wait -n` | wait for any one child to exit; status is that child's |
| `wait -n $pid1 $pid2` | wait for any of a named subset (bash 5.1+) |
| `wait -p var -n` | wait any; place exited PID into `var` (bash 5.1+) |
| `wait` | wait for all; aggregated exit status as above |

`wait -n` is the building block of a **bounded worker pool**: keep N
children running, and as each exits, launch the next.

```bash
# scenario: three-wide worker pool with wait -n
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -ar TASKS=(alpha bravo charlie delta echo foxtrot)
declare -ir N=3
declare -i running=0 i=0

run_one() { sleep $((RANDOM % 3 + 1)); printf 'done %s\n' "$1"; }

while (( i < ${#TASKS[@]} )); do
  if (( running < N )); then
    run_one "${TASKS[i]}" &
    i+=1; running+=1
  else
    wait -n                          # one slot frees up
    running+=-1
  fi
done
wait                                 # drain remaining
```

`wait` and `wait -n` are interruptible by traps (§12.10) — the
interaction that makes the wait-and-invert idiom work at all.

### `huponexit` and SIGHUP at logout

When an interactive shell exits, it sends SIGHUP to its jobs **only if
the `huponexit` shopt is set**. The shopt is *off* by default in modern
bash; an interactive `exit` therefore leaves backgrounded jobs running
on most desktop systems. Turn it on if you want the shell to clean up
its jobs:

```bash
# scenario: aggressive cleanup at logout
shopt -s huponexit                   # backgrounded jobs receive SIGHUP on exit
```

Non-interactive scripts behave differently: when a script ends, its
backgrounded children become orphans of init/systemd. They do *not*
receive SIGHUP from the script's exit. To detach a job from the
script's terminal so it survives the user's logout regardless, use
`disown -h <jobspec>` (which removes the job from the job table and
suppresses SIGHUP) or wrap it in `nohup` / `setsid` (§11.11, §11.12).

### SIGCHLD interaction

When a child exits, the kernel sends SIGCHLD to the parent. Bash's
default behaviour (with job control on) is to reap the child and
update the job table; under job control off, it still reaps but does
not surface a notification. The signal interrupts any in-progress
`wait`, which is precisely how `wait -n` returns as soon as *any* child
exits — the SIGCHLD wakes bash, bash sees the dead child, `wait`
returns its status.

A script that traps SIGCHLD itself is unusual and competes with bash's
reaping; the canonical idiom is to let bash handle SIGCHLD and use
`wait -n` to consume exits one at a time.

### Strict-mode interaction

Background jobs do **not** trigger `set -e` if they exit non-zero —
errexit only inspects foreground commands. To make a failing child
fatal, you must `wait` for it explicitly and let the resulting non-zero
status be observed by errexit:

```bash
# wrong — failure invisible to set -e
worker &                             # exits 1, but errexit ignores backgrounded jobs
echo continuing                      # ⇒ runs anyway

# right — wait surfaces the status; set -e fires
worker &
wait $!                              # exits 1 here; script terminates
```

`pipefail` interacts with backgrounded jobs the same way it interacts
with foreground pipelines: the pipeline's status is its rightmost
non-zero, captured at the synchronous point where the pipeline is
considered to have run. For backgrounded pipelines (`a | b &`), capture
the rightmost component's PID via `$!` and `wait` it explicitly to
observe the failure (BCS1101, BCS1103).

**See also**: §11.6 (process groups and sessions), §11.7 (job table),
§11.9 (job-control builtins, `disown -h`), §11.11 (`nohup`/`setsid`),
§12.10 (synchronous vs asynchronous delivery, wait-and-invert), §12.11
(signal-safe code), BCS1101, BCS1103, BCS1104, BCS-bash
`25_JOB-CONTROL.md`.

#fin
