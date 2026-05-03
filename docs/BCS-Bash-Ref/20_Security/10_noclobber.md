<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.10 `noclobber`

`set -o noclobber` (or `set -C`) prevents `>` from overwriting existing files.

- `cmd > existing.txt` errors with noclobber.
- `cmd >| existing.txt` forces overwrite.
- Default off; turn on for safer scripts.
- Use for "exclusive create" semantics.

```bash
# scenario: canonical exclusive-create lockfile with PID writeback
acquire_lock() {
  local -- lockfile="$1"
  set -o noclobber
  if ! { printf '%d\n' "$$" >"$lockfile"; } 2>/dev/null; then
    set +o noclobber
    local -i existing_pid
    existing_pid=$(<"$lockfile")
    if kill -0 "$existing_pid" 2>/dev/null; then
      printf >&2 'lock held by pid %d\n' "$existing_pid"
      return 1
    fi
    printf >&2 'stale lock (pid %d gone) — recovering\n' "$existing_pid"
    rm -f -- "$lockfile"
    acquire_lock "$lockfile"
    return
  fi
  set +o noclobber
  trap 'rm -f -- "$lockfile"' EXIT
}

acquire_lock /run/myservice.lock || exit 1
```

The `>` under noclobber is atomic at the kernel level (open with
`O_CREAT|O_EXCL`); two simultaneous starters cannot both succeed. PID
writeback lets the second instance distinguish a live lock from a stale
one. The `EXIT` trap (BCS0603) ensures the lock is released on every exit
path including `set -e` aborts under `inherit_errexit`.

**See also**: §20.13 (symlink races), §16 (concurrency), BCS0603 (traps), BCS1006 (temporary files).

#fin
