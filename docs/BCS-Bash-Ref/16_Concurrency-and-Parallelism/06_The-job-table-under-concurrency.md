<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.6 The job table under concurrency

When job control is on, every backgrounded process becomes a *job*
with a small-integer ID. Job control is on by default for interactive
shells and *off* by default for scripts (BCS1101).

### Default state

- Non-interactive bash (the script case): job control off, `jobs`
  prints nothing useful.
- Interactive bash: job control on, `jobs` lists running and stopped
  jobs.
- Override in a script: `set -m` enables job control inside a
  non-interactive shell (rarely needed).

### `jobs` output

When job control is on, the builtin shows the live job table:

```bash
# scenario: interactive shell, three backgrounded jobs
$ sleep 30 &
[1] 12345
$ sleep 60 &
[2] 12346
$ sleep 90 &
[3] 12347
$ jobs
[1]   Running                 sleep 30 &
[2]-  Running                 sleep 60 &
[3]+  Running                 sleep 90 &
```

| Column | Meaning |
|--------|---------|
| `[N]` | job ID, used in `%N` shorthand for `kill`, `fg`, `wait` |
| `+`/`-` | `+` is "current job" (foreground if `fg` is run), `-` is "previous" |
| state | `Running`, `Stopped`, `Done`, `Exit N` |
| command | the original command line |

### `disown` semantics

`disown` removes a job from the table without killing it. After
disown, the script no longer SIGHUPs the child on exit and `jobs`
no longer reports it:

```bash
# scenario: spawn a daemon, hand it off to init
nohup my_daemon >/var/log/daemon.log 2>&1 &
disown -h $!     # immune to SIGHUP from this shell
disown $!        # remove from job table entirely
```

`disown -h JOB` keeps the entry in the table but marks it
SIGHUP-immune. `disown JOB` removes it altogether. `disown -a`
disowns every job; `disown -r` only the running ones.

### Pipelines as units

Each pipeline is a single job, regardless of how many processes it
contains:

```bash
$ producer | filter | consumer &
[1] 12345     # one job, three processes
$ jobs
[1]+  Running                 producer | filter | consumer &
```

`kill %1` signals the *foreground* process of the pipeline; `kill -- -%1`
(note the `--` and the negative job id) signals the whole process
group, killing all three.

### Strict-mode caveat

A backgrounded command that fails does *not* trip `set -e` in the
parent — the parent only sees the failure when it `wait`s for that
PID. `wait` itself is the failure-checkpoint; a script that spawns
without waiting will silently lose error visibility (BCS0601).

### See also

- §16.1 — sequential vs background
- §16.11 — signal handling under concurrency (kill 0, pgid)
- BCS1101 (background job management)

#fin
