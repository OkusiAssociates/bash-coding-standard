<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.13 Tempfile and tempdir lifecycle

The canonical pattern: allocate a tempdir with `mktemp -d`, install an
EXIT trap that removes it, work inside it. The trap fires on any normal
exit — completion, `exit N`, or any caught signal that bash terminates
on after running its handler.

```bash
# scenario: single-tempdir lifecycle
tmpdir=$(mktemp -d -t myscript-XXXXXX) || die 1 "mktemp failed"
trap 'rm -rf -- "$tmpdir"' EXIT
```

- `mktemp -d` for directories; `mktemp` (no `-d`) for a single file.
- Use `-t TEMPLATE` with at least 6 `X`s. The Xs are replaced with
  random characters; `-t` honours `TMPDIR` (defaulting to `/tmp`).
- `mktemp -p DIR` chooses a specific parent if `TMPDIR` is unsuitable
  (e.g. small tmpfs vs working filesystem).
- The trap removes the directory recursively; combine with
  `set -euo pipefail` so a failure in setup short-circuits before the
  trap is installed.

### Multiple tempdirs — array cleanup

A script that allocates several tempdirs (one per worker, one per
phase, etc.) keeps them in an array and iterates in the cleanup
handler. The `nullglob` shopt (BCS0101) makes the unset-array case
safe to expand.

```bash
# scenario: multi-tempdir array cleanup
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a tmpdirs=()

mk_tmp() {
  local d
  d=$(mktemp -d -t "myscript-${1:-x}-XXXXXX") || die 1 "mktemp failed"
  tmpdirs+=("$d")
  printf '%s\n' "$d"
}

cleanup() {
  local d
  for d in "${tmpdirs[@]}"; do
    [[ -d $d ]] && rm -rf -- "$d"
  done
}
trap cleanup EXIT

a=$(mk_tmp build)                          # /tmp/myscript-build-XXXXXX
b=$(mk_tmp cache)                          # /tmp/myscript-cache-XXXXXX
c=$(mk_tmp work)                           # /tmp/myscript-work-XXXXXX

# … use $a $b $c …
# trap removes all three on exit, regardless of which one we were using
# when the script ended.
```

The pattern composes with the idempotent-cleanup guards of §12.12:
add a sentinel if the handler is also wired to INT/TERM, and put the
per-directory `[[ -d $d ]]` check inside the loop so a partial cleanup
does not abort under `set -e`.

### TMPDIR and security

`mktemp` honours `$TMPDIR` if set. Override with `TMPDIR=/var/tmp
mktemp -d -t …` when `/tmp` is unsuitable. **Never** construct paths
manually (`/tmp/myscript.$$`) — the PID is predictable and an attacker
can pre-place a symlink. For state that must survive the script, use
`${XDG_CACHE_HOME:-$HOME/.cache}/myscript/`, not `mktemp`.

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.14 (lockfile pattern), §12.15 (atomic file write), §13.10 (exit
code conventions), BCS0110 (cleanup and traps), BCS1006 (temporary
file handling).

#fin
