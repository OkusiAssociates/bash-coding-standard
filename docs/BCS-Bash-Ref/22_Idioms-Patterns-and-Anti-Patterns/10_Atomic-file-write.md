<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.10 Atomic file write

Use this whenever a reader could observe the target file at any moment —
a config file consumed by another daemon, a state file the next run of
the same script will read, anything served by a webserver. The naive
`echo … > "$target"` truncates the target before the new content has
been written, leaving a window in which a concurrent reader sees an
empty or half-written file. Writing to a sibling tempfile and renaming
closes that window: `mv` (which calls `rename(2)`) is atomic on the same
filesystem, so the target is either the old content or the new — never
in-between.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='atomic-write-demo'

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

# atomic_write TARGET <<<"$content"
# Reads stdin, writes it to TARGET atomically.
atomic_write() {
  local -- target=$1 tmp
  local -- dir=${target%/*}
  [[ $dir == "$target" ]] && dir=.

  tmp=$(mktemp -- "$dir"/."${target##*/}".XXXXXX) \
    || die 1 "atomic_write: mktemp failed for ${target@Q}"

  # Cleanup if anything between here and `mv` fails.
  trap 'rm -f -- "$tmp"' RETURN

  cat >"$tmp" || die 5 "atomic_write: write failed to ${tmp@Q}"

  # Optional but recommended: durably persist before rename so a crash
  # between rename and fsync cannot resurrect a stale-content target.
  command -v sync >/dev/null && sync -- "$tmp" 2>/dev/null ||:

  # Inherit the target's mode if it already exists; otherwise mktemp's
  # 0600 default applies — adjust before mv if the target needs 0644.
  if [[ -e $target ]]; then
    chmod --reference="$target" -- "$tmp" 2>/dev/null ||:
  fi

  mv -f -- "$tmp" "$target" || die 5 "atomic_write: rename failed"
  trap - RETURN
}

# Usage:
printf 'count=%d\nmode=%s\n' 42 production | atomic_write /etc/myapp.conf
#fin
```

The mechanics turn on three details. First, the tempfile must live in
the same directory as the target; `rename(2)` is atomic only within a
single filesystem, and `/tmp` is frequently a separate mount (tmpfs). A
hidden-prefix template like `."${target##*/}".XXXXXX` keeps the partial
file out of `ls` listings while it is being written. Second, the
`trap … RETURN` removes the tempfile if any subsequent command fails
under `set -e`; without that the directory accumulates orphan
`.target.A1b2C3` files. Third, the `chmod --reference` step preserves
the target's existing permissions — without it, an atomic rewrite of a
0644 config silently downgrades to 0600 because that is `mktemp`'s
default.

**Common bug: writing to `/tmp` then `mv` across filesystems.**

```bash
# wrong — /tmp is often a different filesystem; mv falls back to copy+
# unlink, which is NOT atomic and races with concurrent readers.
tmp=$(mktemp)
echo "$payload" >"$tmp"
mv "$tmp" /etc/myapp.conf

# correct — tempfile sibling to target, single filesystem, atomic rename.
tmp=$(mktemp -- /etc/.myapp.conf.XXXXXX)
echo "$payload" >"$tmp"
mv -- "$tmp" /etc/myapp.conf
```

**See also**: §12.15 for the full discussion of atomic-write pitfalls
(cross-filesystem rename, fsync ordering, directory fsync for crash
safety); BCS1006 in `BASH-CODING-STANDARD.md` for the temporary-file
mandate.

#fin
