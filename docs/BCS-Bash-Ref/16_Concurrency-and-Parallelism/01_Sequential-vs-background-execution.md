<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.1 Sequential vs background execution

A command run unadorned blocks the script until it finishes; the same
command suffixed with `&` runs in the background and returns
immediately. The two forms are the foundation of every concurrency
pattern in bash (BCS1101).

### Form register

- `cmd` — foreground; blocks; exit status in `$?`.
- `cmd &` — background; returns immediately; PID in `$!`.
- `cmd & wait $!` — semantically equivalent to plain `cmd` (foreground)
  but routes through the job table.
- Multiple `cmd1 & cmd2 & cmd3 & wait` — parallel fan-out.
- `cmd & disown` — background, then detach from the job table so the
  shell does not deliver SIGHUP on exit.

### `wait $!` vs `disown`

These two are easily confused. `wait $!` blocks until the most recent
background job finishes and reports *its* exit status — the script
treats the spawned process as part of itself. `disown` releases the
job from the shell's responsibility — the script treats the spawned
process as an independent runaway:

```bash
# scenario: rejoin the child to get its exit status
expensive_task &
wait $!
rc=$?
(( rc == 0 )) || die 1 "task failed (rc=$rc)"

# scenario: spawn a daemon that should outlive the script
nohup long_lived_daemon >/var/log/daemon.log 2>&1 &
disown
# script exits, daemon keeps running
```

`disown` without args drops the most recent job; `disown -h $!` keeps
the job in the table but marks it as immune to SIGHUP; `disown -a`
drops all jobs.

### Redirecting background output

Background processes inherit the script's stdout and stderr. If the
script is being piped, that means *every* backgrounded child writes to
the same downstream — output interleaves. Redirect explicitly:

```bash
# scenario: each worker writes to a per-PID log; main stdout stays clean
worker() {
  local -- task=$1
  exec >"/tmp/worker.$$.log" 2>&1
  do_work "$task"
}

for task in t1 t2 t3; do
  worker "$task" &
done
wait
```

`exec >/tmp/...` rewires the worker's stdout/stderr *before* the
business logic runs; the parent's redirection state is untouched.

### See also

- §16.2 — `wait` and `wait -n`
- §16.5 — bounded fan-out
- BCS1101 (background job management), BCS1103 (wait patterns)

#fin
