<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.13 Symlink races

A symlink race exploits the window between the script's *check* of a path
(`[[ -f $f ]]`) and its *use* (`> $f`). An attacker who can `rename(2)`
or `symlink(2)` in any directory component substitutes a different
target; the privileged operation lands on the attacker's choice.

The single best mitigation is to *not name the path*. Create a fresh
private directory with `mktemp -d`, work inside it, and clean up via
trap. Predictable paths in `/tmp` (`/tmp/foo.$$`, `/tmp/$USER.lock`) are
exploitable on multi-user hosts (BCS1006).

### Canonical `mktemp -d` wrapper

The pattern is three lines and belongs at the top of every script that
writes temporary state:

```bash
# scenario: private workdir, deterministic cleanup, no race
declare -- WORKDIR
WORKDIR=$(mktemp -d -t "${SCRIPT_NAME}.XXXXXXXX")
trap 'rm -rf -- "$WORKDIR"' EXIT
cd -- "$WORKDIR"                    # ⇒ from here on, relative paths are safe

# … create files inside WORKDIR …
printf '%s\n' "$payload" > result.txt
process -- result.txt
```

What this buys: `mktemp -d` creates the directory atomically with mode
0700, owned by the invoking user, with a name an attacker cannot guess.
The trap fires on every exit path, including `set -e` aborts and signals
that the script has not blocked. `cd -- "$WORKDIR"` ensures subsequent
relative paths cannot be tricked by a writable cwd.

Three subtleties matter:

1. **Quote `$WORKDIR`** in the trap. The trap argument is re-evaluated at
   trap time; an unquoted `$WORKDIR` breaks if `mktemp -d` returned a
   path containing whitespace (rare on Linux, common on macOS).
2. **`rm -rf --`** terminates options so a pathological `WORKDIR` value
   cannot become a flag. The chance is low after `mktemp -d`, but the
   `--` is free.
3. **Trap once.** Re-installing the EXIT trap deeper in the script
   *replaces* the cleanup; concatenate via a wrapper trap function if
   multiple cleanups are needed (BCS0603).

### Operating on a path the script does *not* own

The wrapper above is sufficient for tempfiles. When the script must
operate on a path supplied by the caller — `[[ -f $f ]] && rm $f` style
— bash itself offers no race-free primitive. `O_NOFOLLOW` and the
`*at()` family (`openat`, `unlinkat`) are not exposed from the shell.

Two practical escape hatches:

```bash
# scenario: race-resistant write via a python3 helper opening with O_NOFOLLOW
python3 - "$f" "$payload" <<'PY'
import os, sys
fd = os.open(sys.argv[1], os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
os.write(fd, sys.argv[2].encode())
os.close(fd)
PY
```

`O_NOFOLLOW` causes the open to fail with `ELOOP` if the final component
is a symlink; combined with `O_EXCL`, this refuses both pre-existing
files and substituted symlinks atomically. The same shape works in any
language with `os.open`/`open(2)` access — Perl, Python, a 20-line C
helper. Treat the helper as part of the script; ship it alongside.

The deletion-of-a-tree case has a similar caveat: `rm -rf -- "$dir"`
follows directory symlinks introduced mid-walk. Where symlinks are
plausible inside the target tree, prefer:

```bash
# scenario: symlink-aware tree deletion
find "$dir" -depth -xdev \( -type f -o -type l \) -delete
find "$dir" -depth -xdev -type d -empty -delete
```

`-xdev` refuses to cross filesystem boundaries (defends against a
substituted bind-mount); `-depth` ensures contents are removed before
the directory itself.

For the "predictable lockfile" pattern, `mktemp` plus a symlink-as-lock
gives atomicity (§20.10 covers `set -C` lockfiles).

**See also**: §20.10 noclobber, §20.12 sanitising filenames, BCS1006
temporary file handling, BCS0603 trap handling.

#fin
