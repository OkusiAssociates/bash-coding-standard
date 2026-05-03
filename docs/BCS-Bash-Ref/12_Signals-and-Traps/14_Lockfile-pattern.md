<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.14 Lockfile pattern

Mutual exclusion across script invocations. The canonical bash recipe
uses `flock(1)` from `util-linux` — an external command, not a bash
builtin — applied to a file descriptor held open for the script's
lifetime. The kernel releases the lock automatically when the
descriptor is closed (including when the process dies), so this pattern
survives `kill -9`.

```bash
# scenario: minimal exclusion lock
exec 9>"$lockfile"
flock -n 9 || die 1 "another instance is running"
```

| Flag | Meaning |
|------|---------|
| `-n`        | non-blocking (return non-zero immediately if locked) |
| `-w SEC`    | wait up to SEC seconds, then fail |
| (default)   | block forever |
| `-x`        | exclusive (default) |
| `-s`        | shared (read-style) lock |
| `-u`        | explicit unlock (rarely needed — closing the fd is enough) |

Two forms of `flock` are easy to confuse. The `exec 9>file; flock -n 9`
form holds the lock for the whole script; the `flock -n file cmd` form
runs `cmd` under the lock and releases when `cmd` exits. The first is
correct for "I am a running instance"; the second for "this one
operation must be atomic".

### Stale-lock and PID-write variant

`flock` *itself* never goes stale — the kernel reaps the lock when the
holder dies. But many shell scripts also write a PID file alongside the
lockfile so operators can identify the holder. The PID file *can* go
stale (e.g. if the script is `kill -9`'d and the PID is recycled). The
pattern below uses `flock` for correctness and a PID file as a
human-facing diagnostic, and tolerates a stale PID file from a previous
crash:

```bash
# scenario: lock + PID file with stale-PID handling
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- lockfile=/run/lock/myscript.lock pidfile=/run/myscript.pid

acquire_lock() {
  exec 9>"$lockfile"
  if ! flock -n 9; then
    # Another instance holds the kernel lock — try to identify it.
    if [[ -r $pidfile ]] && other=$(<"$pidfile") && kill -0 "$other" 2>/dev/null; then
      die 1 "already running as PID $other"
    fi
    # PID file is stale or unreadable, but the kernel lock is held —
    # so the running instance just hasn't written its PID yet.
    die 1 "another instance is starting up"
  fi

  # Lock acquired — write our PID. The PID file inherits the lock's
  # protection because we hold fd 9.
  printf '%s\n' "$$" >"$pidfile"
  trap 'rm -f -- "$pidfile"' EXIT          # PID file is best-effort
}

acquire_lock
# … work …
```

Notes on this variant:

1. The kernel-side `flock` is the source of truth; the PID file is
   advisory. Never make correctness depend on it.
2. `kill -0 $other` checks process existence without sending a signal
   (§11.10). It returns non-zero if the PID is gone or owned by another
   user.
3. Cleaning up the PID file on EXIT is best-effort: `kill -9` will
   leave it behind. The next run handles that case via the staleness
   probe.
4. Holding fd 9 across the whole script means the lock travels with
   the process; do not close fd 9 anywhere except in cleanup.

### Lock contention versus busy-wait

`flock -w 30` blocks up to 30 seconds and returns non-zero on timeout
— preferable to a shell-level retry loop because the kernel's wakeup
is immediate when the holder releases. The retry-loop form `until
flock -n 9; do sleep 1; done` is wasteful and occasionally races on
systems with overloaded kernel locks. Use `-w` whenever possible.

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.13 (tempfile lifecycle), §11.10 (`kill` and `-0` probe), BCS0110
(cleanup and traps), BCS1006 (temporary file handling).

#fin
