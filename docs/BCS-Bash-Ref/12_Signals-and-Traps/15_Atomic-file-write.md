<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.15 Atomic file write

Write to a sibling tempfile in the *same* directory, then rename. The
`rename(2)` syscall is atomic on a single filesystem, so concurrent
readers see either the old version or the new version of the target —
never a half-written file.

```bash
# scenario: atomic-replace single file
tmp=$(mktemp -- "${target}.XXXXXX") || die 5 "mktemp failed"
write_data > "$tmp"
mv -- "$tmp" "$target"
```

- `mktemp -- "${target}.XXXXXX"` creates the tempfile *next to* the
  target, guaranteeing same-filesystem rename. **Do not** use
  `mktemp -t` here — that places the file in `/tmp`, which is usually
  a different filesystem.
- `mv` within one filesystem invokes `rename(2)` and is atomic.
- The reader either opens the inode that was the old file or the inode
  that becomes the new file. There is no observable mid-state.
- `sync` between the write and the `mv` is required only when crash
  durability matters (`man 2 fsync` for the rationale).

### The cross-filesystem trap

If `$tmp` and `$target` are on **different** filesystems, `mv` is not
a rename — it is a copy plus unlink. Concurrent readers can observe a
half-written file; the `rename(2)` syscall returns `EXDEV` and `mv`
silently falls back to copy mode.

```bash
# scenario: cross-fs mv is NOT atomic — stage in the target's dir
tmp=$(mktemp -t write-XXXXXX)              # WRONG — /tmp is a separate fs
mv -- "$tmp" "$target"                     # ⇒ copy + unlink (not atomic)

tmp=$(mktemp -- "${target}.XXXXXX")        # CORRECT — same dir, same fs
mv -- "$tmp" "$target"                     # ⇒ atomic rename(2)
```

To verify same-filesystem staging, compare device numbers — equality
means same fs:

```bash
[[ "$(stat -c '%d' -- "$tmp")" == "$(stat -c '%d' -- "$(dirname -- "$target")")" ]] \
  || die 5 'tmp and target are on different filesystems'
```

### Cleanup on failure and permissions

Combine with an EXIT trap so a failure between `mktemp` and `mv`
removes the tempfile; cancel the trap on success:

```bash
tmp=$(mktemp -- "${target}.XXXXXX") || die 5 "mktemp failed"
trap 'rm -f -- "$tmp"' EXIT
write_data > "$tmp"
mv -- "$tmp" "$target"
trap - EXIT
```

`mktemp` creates files mode 0600, so the new `$target` will have
mode 0600 and the tempfile's owner. To preserve the previous file's
permissions, copy them before the rename:

```bash
[[ -e $target ]] && chmod --reference="$target" -- "$tmp"
mv -- "$tmp" "$target"
```

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.13 (tempfile lifecycle), §12.14 (lockfile pattern), BCS0110
(cleanup and traps), BCS1006 (temporary file handling), BCS0901 (safe
file testing).

#fin
