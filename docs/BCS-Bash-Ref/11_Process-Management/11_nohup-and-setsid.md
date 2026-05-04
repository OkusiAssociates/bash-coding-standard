<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.11 `nohup` and `setsid`

Three tools — `nohup`, `setsid`, and `disown` — overlap enough to
confuse and differ enough that picking the wrong one leaves a child
killable by the next `SIGHUP`. This chapter pins down what each does,
and what each does *not* do.

### The three tools at a glance

| Tool | Survives shell exit? | New session? | Redirects fds? | Removes from job table? |
|------|:--------------------:|:------------:|:--------------:|:------------------------:|
| `nohup cmd &` | yes (ignores `SIGHUP`) | no | yes — `nohup.out` if tty | no |
| `setsid cmd` | yes (new session, no ctty) | yes | no | n/a (already detached) |
| `cmd & disown` | yes (Bash's `huponexit` off) | no | no | yes |

Each addresses one slice of "decouple from this shell"; combine them
when you want all three effects.

#### `nohup` — install `SIG_IGN` on `SIGHUP`

`nohup` calls `signal(SIGHUP, SIG_IGN)` and `execve(2)`s the target.
If stdout is a terminal it redirects stdout (and stderr if also a tty)
to `./nohup.out` or `$HOME/nohup.out`. The child *inherits* the
ignored disposition; the new program may reset it but rarely does.

```bash
# scenario: a long sleep that survives this shell's logout.
nohup sleep 600 >/tmp/sleep.log 2>&1 &
declare -ri child=$!
disown "$child"
printf 'detached pid=%d\n' "$child"
```

Without the explicit redirection, `nohup` writes to `nohup.out` in the
cwd — a frequent surprise in shared directories.

#### `setsid` — fork into a new session

`setsid(1)` calls `setsid(2)` so the child becomes its own session
leader with no controlling terminal. It cannot receive terminal-
generated signals (`SIGHUP` from logout, `SIGINT` from Ctrl-C) because
it has no terminal to receive them from.

```bash
# scenario: launch a daemonish worker fully detached from this tty.
setsid --fork bash -c 'exec /usr/local/bin/myworker' \
       </dev/null >/var/log/myworker.log 2>&1
```

`--fork` is essential: without it, `setsid` only does `setsid(2)` if
the caller is not already a process group leader. With `--fork`, it
forks first (so the child cannot be a leader) and then calls
`setsid(2)` unconditionally.

#### `disown` — remove from Bash's job table

`disown` is a Bash builtin; it does not touch the OS. By default it
forgets the job, so subsequent `wait`/`fg`/`bg`/`jobs` cannot reach it.
With `-h`, the job stays in the table but is marked "do not send
`SIGHUP` on shell exit". With `-a` it acts on every job. See §11.9.

```bash
# scenario: keep the job listed but immune to shell-exit SIGHUP.
sleep 600 &
disown -h "$!"   # listed by `jobs`, but huponexit cannot reach it
```

### Side-by-side comparison

```bash
# wrong — naive backgrounding leaves the child exposed
sleep 600 &
# exit          # → on shell exit the child receives SIGHUP if huponexit is on
kill %1 2>/dev/null; wait %1 2>/dev/null || true   # tear-down for the demo

# right (option A) — nohup ignores SIGHUP at the OS level
nohup sleep 600 >/tmp/x.log 2>&1 & disown
# exit          # → child would run to completion across shell exit
kill %1 2>/dev/null; wait %1 2>/dev/null || true

# right (option B) — setsid puts the child in a new session
setsid --fork bash -c 'sleep 600' </dev/null >/tmp/x.log 2>&1
# exit          # → child has no ctty, no SIGHUP source

echo "side-by-side patterns illustrated"
# ⇒ side-by-side patterns illustrated
```

The two right-hand forms are not equivalent: only `setsid` actually
changes the kernel's view of the child's session. For a one-shot
backgrounded job, `nohup … & disown` is enough. For a long-running
service, `setsid` is closer to a true daemon — and `systemd` is closer
still (§11.12).

### Strict-mode interaction

Under `set -euo pipefail`, the parent script's exit status is the exit
status of the last executed command, not the detached child. `wait`
will not see a `disown`ed PID; rely on the child's own logging or
status file.

**See also**: §11.5 (foreground vs background), §11.6 (process groups
and sessions), §11.9 (job-control builtins, including `disown`),
§11.12 (detaching from the terminal), BCS1101.

#fin
