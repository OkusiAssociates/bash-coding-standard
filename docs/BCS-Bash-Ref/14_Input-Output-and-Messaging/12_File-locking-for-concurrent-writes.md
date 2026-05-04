<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.12 File locking for concurrent writes

Multiple processes writing to the same file: lock or rely on the
kernel's small-write atomicity. The choice depends on the size of each
write, not on the file's overall size.

### `O_APPEND` and `PIPE_BUF`

When a file is opened in append mode (`O_APPEND` — bash sets this
automatically for `>>`), each `write(2)` is atomic *with respect to
other appenders* if the byte count does not exceed `PIPE_BUF`. On
Linux, `PIPE_BUF` is 4096 bytes; on POSIX it is at least 512.

Querying the local value:

```bash
# scenario: discover the local PIPE_BUF before designing a log format
declare -i pipe_buf
pipe_buf=$(getconf PIPE_BUF /)
printf 'PIPE_BUF on this filesystem: %d bytes\n' "$pipe_buf"
# ⇒ PIPE_BUF on this filesystem:
# (Linux normally reports 4096; POSIX guarantees at least 512)
```

The header constant lives in `<limits.h>`; `getconf` reports the value
the running kernel honours for the given path. Network filesystems
(NFS) frequently report 4096 but the underlying server may not honour
the guarantee — locking is mandatory there.

### When `>>` is enough

Bash's `cmd >> file` opens with `O_APPEND`. Writes ≤ `PIPE_BUF` bytes
are guaranteed not to interleave between concurrent appenders on
local filesystems:

```bash
# scenario: 8 workers logging short lines safely
log() { printf '%s [%s] %s\n' "$(date -Iseconds)" "$$" "$*" >> shared.log; }

for i in {1..8}; do
  ( log "worker $i started"; ) &
done
wait
printf 'shared.log line count: %d\n' "$(wc -l < shared.log)"
# ⇒ shared.log line count: 8
```

Each `printf` produces well under 4096 bytes, so each `write(2)` is
indivisible. No `flock` required.

### When `flock` is mandatory

Once any single write may exceed `PIPE_BUF`, or once the application
needs to read-modify-write, lock around the critical section:

```bash
# scenario: append a JSON record that may exceed PIPE_BUF
{
  flock -x 200
  printf '%s\n' "$LARGE_JSON_BLOB" >> shared.log
} 200>>shared.log
```

The subshell pattern (`{ ... } 200>>file`) opens fd 200 once and holds
the lock for the duration of the block — `flock -x 200` acquires an
exclusive lock on that fd; the kernel releases it when the fd closes.
See §16.10 for the full locking primitives discussion.

### Log-rotation interaction

Atomic small-writes survive `logrotate` if the rotator uses
`copytruncate` (data race tolerated) or `create` with a HUP-handler
in the writer (writer reopens on signal — §12.16). A plain `mv` of an
open log file silently sends future writes to the moved inode; the
`>>` semantics mean the writer never notices.

### See also

- §16.10 — `flock` and other locking primitives
- §12.14 — lockfile pattern (PID-write variant)
- §12.16 — reload-on-SIGHUP for log rotation
- BCS1006 (temporary file handling), BCS1101 (background job management)

#fin
