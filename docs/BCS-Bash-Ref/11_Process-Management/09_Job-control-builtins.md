<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.9 Job-control builtins

The builtins that read and mutate the job table. All accept job specs
(`%n`, `%+`, `%-`, `%?str` — see §11.8) wherever a job is named.

| Builtin | Purpose |
|---------|---------|
| `jobs`    | list jobs (`-l` PID, `-p` PIDs only, `-r` running, `-s` stopped, `-n` changed) |
| `fg %n`   | bring job to foreground, give it the controlling tty |
| `bg %n`   | resume a stopped job in the background |
| `disown [-h\|-a\|-r] [%n]` | remove from job table or mark SIGHUP-immune |
| `wait [%n\|pid]` | block until job finishes; collect its exit status |
| `suspend` | stop the shell itself (login shell needs `-f`) |
| `kill -SIGNAL %n` | signal a job by spec (§11.10) |

### `disown` — three distinct modes

`disown` is the most-confused of the lot because its three forms have
different effects on both the job table and the SIGHUP behaviour.

| Form | Removes from table? | Receives SIGHUP on shell exit? |
|------|---------------------|--------------------------------|
| `disown %n` (default) | yes | no |
| `disown -h %n`         | no  | no (kept in table, marked immune) |
| `disown -a`            | yes (all jobs) | no |
| `disown -r`            | yes (running jobs only) | no |
| `disown` (no args)     | yes (current job `%+`) | no |

The point of `-h` is to keep monitoring the job (`jobs` still lists it,
`wait` still works) while still surviving the parent shell's exit:

```bash
# scenario: -h vs default disown
sleep 100 &           # job %1
sleep 200 &           # job %2

disown -h %1          # %1 stays in table, will not receive SIGHUP
disown    %2          # %2 removed from table immediately

jobs -l
# ⇒ [1]+
# (only %1 is listed; %2 has been removed from the job table.
#  The literal PID after `[1]+` varies per run.)

# On shell exit:
#   - %1 (and %2) survive because both are protected, but only %1
#     is still wait-able from this shell.
```

The bare `disown` form (no args, no flag) acts on the *current* job
(`%+`) — useful in one-liners but error-prone in scripts because the
"current" job changes as new jobs start. Always pass an explicit spec in
scripts.

### `wait` and exit-code propagation

`wait %n` (or `wait $pid`) blocks until the named job completes and
returns that job's exit status. `wait` with no argument waits for *all*
children. `wait -n` (since 4.3) waits for the **next** child to finish
and returns its status; `wait -n -p var` (since 5.1) also stores the
PID of that child in `var`. See §11.5 and §16 for worker-pool patterns.

```bash
# scenario: harvesting parallel results with -n
slow_op &  jobs+=("$!")
slow_op &  jobs+=("$!")
slow_op &  jobs+=("$!")

while (( ${#jobs[@]} )); do
  wait -n -p done_pid
  rc=$?
  printf 'pid %s exited rc=%d\n' "$done_pid" "$rc"
  jobs=("${jobs[@]/$done_pid}")
done
```

**See also**: §11.5 (foreground/background), §11.7 (job table), §11.8
(job specs), §11.10 (kill), §11.11 (`nohup`/`setsid`), §16
(concurrency), BCS-bash `25_JOB-CONTROL.md`, BCS1101 (background jobs),
BCS1103 (wait patterns).

#fin
