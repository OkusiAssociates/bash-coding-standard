<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.9 Race conditions in shell

A race condition arises when correctness depends on the *order* of
operations that are not atomic from the shell's point of view. Shell
scripts are unusually prone to these bugs because most filesystem
checks (`-f`, `-e`, `-d`) and most "if absent then create" idioms split
into a *test* and an *act* with a window between them where another
process — friendly or hostile — can change the answer. This is the
TOCTOU (time-of-check / time-of-use) class.

The classic illustration:

```text
   process A                process B
   ----------------          ----------------
   [[ -f $f ]]              # A: test passes
                             rm -f -- "$f"  # B: removes file
   rm -- "$f"               # A: now fails or removes wrong file
                             > "$f"         # B: re-created (different inode)
```

Between A's check and A's act, B has changed the world. No amount of
defensive testing closes this gap — only an *atomic* operation does.

### TOCTOU on a regular file

```bash
# wrong — test then act, racy
if [[ -f $TARGET ]]; then
  rm -- "$TARGET"
fi

# right — let the kernel atomically test-and-act
rm -f -- "$TARGET"        # ENOENT is silently ignored
# ⇒ no window: rm(2) checks existence under the inode lock
```

For the create-only case (must not clobber an existing file), the
atomic primitive is `O_EXCL` via `set -C` (noclobber):

```bash
# right — atomic exclusive create
set -C
: > "$LOCK" 2>/dev/null || die 'already locked'
set +C
# ⇒ open(2) with O_CREAT|O_EXCL fails atomically if the file exists
```

### Symlink races (TOCTOU on the path)

A path traversal that follows a symlink at use-time can be retargeted
between check and use, letting an attacker substitute the file the
victim writes. `chmod`, `chown`, and `cat >` are all vulnerable when
the path lies in an attacker-writable directory.

```bash
# wrong — symlink can be swapped between -d test and write
[[ -d $userdir ]] && cp secret "$userdir"/copy

# right — operate on a fd opened with no-follow semantics
exec {fd}<"$userdir" || die 'cannot open'
[[ -d /proc/self/fd/$fd ]] || die 'not a directory'
cp secret "/proc/self/fd/$fd"/copy
exec {fd}<&-
# ⇒ the fd binds the inode; cannot be retargeted by a later symlink swap
```

Where `/proc/self/fd` is unavailable, place the work inside a directory
the script *creates* with `mktemp -d` (mode 0700, owned by the running
user) — see §20.13.

### Tempfile races

```bash
# wrong — predictable name, racy create
tmp="/tmp/work.$$"; > "$tmp"

# right — mktemp(1) creates atomically with mode 0600
tmp=$(mktemp) || { echo 'mktemp failed' >&2; exit 5; }
trap 'rm -f -- "$tmp"' EXIT
echo "tmp prefix:"               # ⇒ tmp prefix:
printf '%s\n' "${tmp%%[A-Za-z0-9]*}"   # → "/tmp/" before the random suffix
# (mktemp uses O_EXCL internally and a 0600 umask)
```

Note: some embedded systems ship a `tempfile(1)` helper that does *not*
use `O_EXCL`. Treat `mktemp(1)` as the only portable safe primitive.

### Lock-then-do races

A "test for lockfile then create" pair is itself a TOCTOU. Use either
`flock` on a long-lived fd (§16.10) or atomic `O_EXCL` create. The
PID-bearing lockfile must check `kill -0 "$old_pid"` *after* taking the
lock, never before, otherwise a stale-PID detection becomes its own
race.

### Signal-during-handler

Signals delivered while a trap is running are queued, not lost, but the
handler is not re-entered. State a trap touches must be reset to a
consistent value *before* the trap can fire again — typically by doing
the cleanup last, or guarding with a single-shot flag (§12, §16.11).

### Fixes that always work

| Pattern | Atomic primitive |
|---------|------------------|
| Create-or-fail | `set -C; : > "$f"` (uses `O_EXCL`) |
| Lock-or-fail | `flock -n` on an fd (§16.10) |
| Tempfile | `mktemp` / `mktemp -d` |
| Rename-into-place | `mv -- "$tmp" "$final"` (rename(2) is atomic) |
| Append | `>> "$f"` is atomic for writes ≤ `PIPE_BUF` |

The "rename into place" idiom deserves its own example because it
solves a *different* race — the half-written-file race, where a reader
opens the target while a writer is still writing. Always write to a
sibling tempfile and `mv` it on top:

```bash
# scenario: produce a config file readers must never see partial
tmp=$(mktemp -- "$target.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
generate_config > "$tmp"
mv -- "$tmp" "$target"
trap - EXIT
# ⇒ readers see either the old contents or the new — never a mixture
```

`mv` within the same filesystem is `rename(2)`, which is atomic from
the kernel's perspective: the directory entry switches inodes in a
single operation. Across filesystems `mv` falls back to copy + unlink,
which is *not* atomic — keep the tempfile in the same directory as
its target, never in `/tmp`.

**See also**: §16.10 (locking primitives), §16.11 (signal handling),
§20.13 (symlink/path security), §12 (traps).

#fin
