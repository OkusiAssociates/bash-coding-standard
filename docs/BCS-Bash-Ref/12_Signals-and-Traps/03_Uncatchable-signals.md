<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.3 Uncatchable signals

Two signals cannot be caught, blocked, or ignored:

- **SIGKILL (9)** — terminates the process unconditionally.
- **SIGSTOP (19 on Linux)** — stops the process unconditionally.

A third — **SIGCONT** — *can* be caught but cannot be blocked: it always
resumes a stopped process before the handler runs.

Any cleanup logic placed in a `trap` (§12.5) is bypassed when the
process is terminated by SIGKILL. EXIT trap, ERR trap, lockfile release,
tempdir removal — none of it runs. This is a kernel guarantee with no
user-space override.

### Critical-cleanup discipline

Never rely on a trap to release resources whose absence would corrupt
state. `kill -9`, the OOM killer, and panicked operators all bypass
EXIT traps. For correctness-critical cleanup, use kernel-managed
mechanisms:

1. **Filesystem janitor** — `mktemp -d` + EXIT trap *plus* a periodic
   cron/systemd-timer sweep of orphaned `myscript-*` whose owners are
   gone.
2. **Locks held by file descriptor** — `flock` on an open fd releases
   automatically when the kernel reaps the process, however it died
   (§12.14).

```bash
# scenario: cleanup that survives SIGKILL
exec 9>"$tmpdir/.lock"
flock -n 9 || die 1 'another instance is running'
trap 'rm -rf -- "$tmpdir"' EXIT     # tidy path
# If kill -9 hits here: EXIT trap does NOT run; $tmpdir survives
# until the janitor reaps it; fd 9 is released by the kernel so the
# next invocation can take the lock immediately.
```

The dual: a parent that *wants* its children to clean up sends
SIGTERM (catchable) first, waits briefly, then escalates to SIGKILL
only on timeout. This is the systemd `TimeoutStopSec=` protocol; a
shell supervisor should imitate it.

**See also**: §12.4 (signal disposition), §12.5 (the `trap` builtin),
§12.12 (idempotent cleanup), §12.13 (tempfile lifecycle), §12.14
(lockfile pattern), Appendix K (signal numbers), BCS0603 (trap
handling), BCS1006 (temporary file handling).

#fin
