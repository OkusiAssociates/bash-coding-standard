<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.11 Exclusive lock

Use this whenever at most one instance of a script may run at a time —
backup jobs, cache rebuilders, anything that would corrupt state if two
copies ran in parallel. The idiom opens a dedicated lockfile on a
permanent file descriptor and holds an `flock(2)` exclusive lock on it
for the lifetime of the shell. The kernel releases the lock when the
last reference to the file descriptor closes, which happens
automatically on shell exit, crash, or kill — no `trap`-based cleanup
is required for the lock itself.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='locked-job'
declare -r LOCKFILE="${TMPDIR:-/tmp}/$SCRIPT_NAME.lock"   # production: /run/lock

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

acquire_lock() {
  local -- lockfile=$1

  # Open FD 9 for write, creating the lockfile if missing.
  # FD numbers >= 9 are conventional for long-lived script-internal handles.
  exec 9>"$lockfile" || die 5 "Cannot open lockfile ${lockfile@Q}"

  # -n: non-blocking (fail immediately if held by another process).
  # -x: exclusive (default for write FDs, made explicit here).
  flock -n -x 9 || die 1 "$SCRIPT_NAME is already running (lock: $lockfile)"

  # Record our PID so operators inspecting the lockfile can find us.
  printf '%d\n' "$$" >&9
}

main() {
  acquire_lock "$LOCKFILE"

  # ... long-running work; lock is held throughout ...
  printf 'doing the thing\n'    # ⇒ doing the thing
  sleep 0.05                    # placeholder for real work

  # No explicit unlock needed. When this shell exits (normal, signal, or
  # crash) the kernel closes FD 9 and the lock is released automatically.
}

main "$@"
#fin
```

A few details deserve attention. The lockfile is opened for *write*
(`9>"$lockfile"`) rather than read; this guarantees the file exists
before `flock` runs, even on the very first invocation. The path lives
in `/run/lock` (a tmpfs mounted with the right semantics on every
modern Linux system) so the lockfile vanishes at boot — there is never
a stale lockfile after a crash, because the file descriptor itself is
the lock, not the file's mere existence. Using a regular path like
`/var/run/foo.pid` for both the PID and the lock is a classic mistake:
PID files require manual cleanup and stale-pid detection, while
fd-backed `flock` does neither.

`flock -n` returns non-zero immediately if the lock is held; without
`-n`, the call would block until the other instance exited, which is
sometimes what you want (e.g. cron-job serialisation) but rarely what
you want for an interactive command. Keep one or the other consistent
with the script's purpose.

**Common bug: opening the FD inside a subshell.**

```bash
# wrong — the subshell exits as soon as `flock` returns; the lock dies
# with it, so the next process happily acquires it.
(
  exec 9>"$LOCKFILE"
  flock -n 9 || exit 1
) && do_work    # lock already gone by the time do_work runs

# correct — open in the parent shell so the FD outlives the test.
exec 9>"$LOCKFILE"
flock -n 9 || die 1 'already running'
do_work        # lock held for the rest of this script
```

**See also**: §12.14 for the full discussion of advisory locking
semantics, NFS caveats, `flock` vs `fcntl` vs `lockf`, and why
`mkdir`-based locks are not a substitute. BCS0110 covers the cleanup-
trap pattern for resources that *do* need explicit teardown; the
fd-backed lock is the rare resource that does not.

#fin
