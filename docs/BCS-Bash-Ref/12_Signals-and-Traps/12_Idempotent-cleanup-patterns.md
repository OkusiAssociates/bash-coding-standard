<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.12 Idempotent cleanup patterns

A cleanup handler attached to multiple signals (`trap cleanup EXIT INT
TERM HUP`) can fire more than once: SIGINT may arrive *during* an
ongoing cleanup, the EXIT trap then runs again, and so on. Idempotent
handlers tolerate this by guarding against re-entry and by checking
each resource's existence before acting.

There are two canonical guards. Use either; do not mix.

### Pattern 1 — sentinel variable

A flag distinguishes the first invocation from subsequent ones. The
`${_CLEANED:-}` form uses parameter expansion's default (empty) so the
guard works under `set -u` (BCS0101) where reading an unset variable
would otherwise abort.

```bash
# scenario: re-entrant trap protected by a sentinel
cleanup() {
  [[ -n ${_CLEANED:-} ]] && return        # second + later calls: no-op
  _CLEANED=1                              # first call claims the work
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir" # exists-check before remove
  exec 9>&-                               # release lock fd
}
trap cleanup EXIT INT TERM HUP            # any of these triggers it
```

Per-resource existence checks (`[[ -d $tmpdir ]]`) matter as much as
the sentinel: another pass may have already removed the resource, and
`rm -rf` against a missing path under `set -e` aborts the rest of
cleanup.

### Pattern 2 — disable the trap on entry

Reset every signal back to default before doing the work. Subsequent
deliveries of those signals then take their default action (terminate)
without re-entering the handler. This is simpler than a sentinel but
forfeits the chance to catch a re-entrant signal at all.

```bash
# scenario: handler disables itself before doing work
cleanup() {
  trap - EXIT INT TERM HUP                 # disable further invocations
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir"
  exec 9>&-
}
trap cleanup EXIT INT TERM HUP
```

Use this form when the cleanup is short and re-entry would be a bug;
use the sentinel form when the handler itself may take noticeable time
and you want second SIGINTs to be politely ignored rather than to kill
the script mid-cleanup.

### Capturing `$?` in the handler

The EXIT trap fires after the failing command sets `$?`, so a single
handler can log the failing exit status without losing it:

```bash
cleanup() {
  local rc=$?                              # capture before doing anything
  [[ -n ${_CLEANED:-} ]] && return
  _CLEANED=1
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir"
  (( rc )) && error "exiting with rc=$rc"
  return "$rc"                             # preserve script's exit status
}
trap cleanup EXIT
```

The `return "$rc"` is critical: without it, the handler's last command
becomes the script's exit status. A bare `[[ -d $tmpdir ]]` returning
non-zero would change a successful script's exit code from 0 to 1.

For multi-resource cleanup, push each step onto an array and iterate
in reverse-acquisition order in the handler, with `|| true` per step
so one failure does not abort the rest of the cleanup.

**See also**: §12.5 (`trap` builtin), §12.6 (pseudo-signals — EXIT
mechanics), §12.13 (tempfile lifecycle), §12.14 (lockfile pattern),
§12.15 (atomic file write), BCS0110 (cleanup and traps), BCS0603 (trap
handling).

#fin
