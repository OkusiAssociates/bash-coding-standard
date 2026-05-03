<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.10 Locking primitives

When two scripts must not run a critical section at the same time, the
shell needs a real mutex — not a "is there a lockfile?" check, which is
itself racy (§16.9). Three idioms cover almost every case: `flock` on a
file descriptor, `mkdir` as an atomic mutex, and `O_EXCL` create via
`noclobber`. Each has a different recovery story for stale locks left
behind by a crash.

### `flock` on a long-lived fd

`flock(1)` takes an advisory `fcntl` lock on an open file descriptor.
The kernel releases the lock automatically when the fd closes —
including when the process dies — so stale-lock cleanup is free. The
canonical idiom wraps the critical section in a subshell that holds
the fd for its entire lifetime:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r LOCK=/var/lock/myjob.lock

# scenario: only one instance of the critical section may run at a time
(
  flock -x -w 30 200 || { echo 'lock timeout' >&2; exit 1; }
  # critical section — fd 200 holds the exclusive lock here
  do_work
) 200>"$LOCK"
# ⇒ subshell exits → fd 200 closes → kernel releases lock
```

For non-blocking attempts, use `flock -n`. For self-locking (a script
re-execing itself under the lock):

```bash
# scenario: re-exec under a lock with no subshell
[[ ${FLOCKER:-} != "$0" ]] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@"
# critical section follows in the re-exec'd process
```

### `mkdir` as an atomic mutex

`mkdir(2)` is atomic: either the directory is created or `EEXIST` is
returned. This works on every Unix, including filesystems where
`flock` semantics differ (NFS, CIFS). Cleanup is the caller's problem,
so a trap is mandatory (BCS0110, BCS0603):

```bash
declare -r LOCKDIR=/var/lock/myjob.d

acquire_lock() {
  local -i tries=0
  until mkdir -- "$LOCKDIR" 2>/dev/null; do
    ((tries+=1 < 30)) || return 1
    sleep 1
  done
  trap 'rmdir -- "$LOCKDIR"' EXIT INT TERM
}

acquire_lock || die 1 'could not acquire lock'
do_work
# ⇒ EXIT trap removes the directory; INT/TERM trigger it on signal
```

A crash *before* the trap is installed leaves a stale lockdir. Mitigate
by writing `$BASHPID` into a file inside the lockdir and validating
with `kill -0` — but only *after* `mkdir` succeeded, never before.

### `noclobber` (`O_EXCL`) create

The shell's redirection layer can do an `O_EXCL` create directly via
`set -C`. The result is a file whose existence is the lock; whose
content can be the holder's PID for diagnostics:

```bash
declare -r LOCKFILE=/var/lock/myjob.pid

acquire_lock() {
  set -C
  if ! printf '%d\n' "$$" > "$LOCKFILE" 2>/dev/null; then
    set +C
    # check for stale lock: holder dead?
    local -i pid; pid=$(<"$LOCKFILE") || return 1
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f -- "$LOCKFILE"
      acquire_lock; return $?
    fi
    return 1
  fi
  set +C
  trap 'rm -f -- "$LOCKFILE"' EXIT
}
```

This idiom has a real-world wrinkle: a holder that dies between
`set -C; printf ... > "$LOCKFILE"` and `trap '...' EXIT` leaks the
lockfile. The `kill -0` recovery path handles it, at the cost of one
window where two scripts could both decide the lock is stale. For
single-host single-user scripts this is acceptable; for fleet-wide
locking, prefer `flock`.

### Choosing

| Primitive | Best for | Crash recovery | Cross-host |
|-----------|----------|----------------|------------|
| `flock` fd | local single-host critical sections | automatic (kernel) | no (advisory only) |
| `mkdir` | NFS / portable scripts | manual via trap | yes (atomic on most NFS) |
| `noclobber` | minimal dependencies | manual + PID check | partial |

Lock the *resource itself* where possible (`flock` on the data file's
fd), not a separate lockfile — this prevents the case where the lock
disappears while the data still exists.

### Common pitfalls

- **Locking on `/tmp`** — `/tmp` is often `tmpfs` and clears on reboot,
  which is fine, but it is also world-writable. Use a directory only
  the script's user can write (`/var/lock/`, `${XDG_RUNTIME_DIR}/`)
  to avoid hostile pre-creation of the lock path.
- **`flock` and pipes** — `flock` only locks the *file descriptor it
  was given*. A pipeline like `flock -x lockfile | grep ...` runs
  `flock` in a subshell whose fd vanishes immediately. Use the
  subshell-redirect form `( flock -x 200; ... ) 200>"$LOCK"` shown
  above, or `flock -c 'cmd'`.
- **Forgetting `-x` / `-s`** — `flock` defaults to exclusive (`-x`),
  but explicit is better. Use `-s` for a shared (reader) lock when
  multiple readers can run concurrently.
- **NFS surprises** — older NFS clients do not honour `flock` (they
  silently no-op). On NFSv4 it works; on NFSv3 prefer `mkdir`. Test
  on the target filesystem before shipping.
- **Holding the lock too long** — a critical section that takes
  minutes blocks every contender for the same time. Where possible,
  do the slow work *outside* the lock and only swap the result in
  under the lock (read-copy-update style):

  ```bash
  result=$(slow_compute "$@")        # outside the lock
  ( flock -x 200
    install -m 0644 /dev/stdin "$STATE" <<<"$result"
  ) 200>"$LOCK"
  # ⇒ lock is held only for the install, not the compute
  ```

**See also**: §16.9 (race conditions), §16.11 (signals during locks),
§20.10 (`mktemp` and tempfile security), §12 (traps), `flock(1)`.

#fin
