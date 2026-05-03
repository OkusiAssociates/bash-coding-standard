<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.12 Targeting multiple Bash versions

Most BCS-aligned scripts simply require bash 5.2 or later and refuse to
run otherwise. That is the cleanest stance: declare the requirement,
fail fast, document in the header. Only when a script is intended for
distribution across mixed estates (RHEL 8 with bash 4.4, CentOS 7 with
bash 4.2, the macOS bash 3.2 problem in §23.6) does
multi-version-targeting become a real concern — and even then, the
right answer is usually "raise the floor."

### Detect with `BASH_VERSINFO`

`BASH_VERSINFO` is an array exposing major/minor/patch/build/release/
machine. Index 0 is the major version; index 1 is the minor.

```bash
# scenario: refuse to run on bash older than 4.4 (early-die pattern)
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4) )); then
  printf '%s: requires bash 4.4 or later (have %s)\n' \
    "$0" "${BASH_VERSION:-unknown}" >&2
  exit 18
fi
```

Exit code 18 is BCS-canonical for "missing dependency" (Appendix L).
Place this check at the very top of the script, immediately after the
shebang and `set -euo pipefail`, so that the failure happens before the
script touches anything bash-4.4-specific.

### Conditional feature use

Where a script would benefit from a newer feature but can degrade to an
older one, gate the use:

```bash
# scenario: use namerefs (declare -n, bash 4.3+) when available, fall
# back to eval-by-name on older bash
copy_array() {
  local -- src_name=$1 dst_name=$2
  if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3) )); then
    local -n src=$src_name dst=$dst_name
    dst=("${src[@]}")
  else
    eval "$dst_name=(\"\${${src_name}[@]}\")"
  fi
}
```

The fallback branch is more dangerous than the primary, so the version
gate also serves as a security boundary: shipping a script that always
took the `eval` branch would be worse hygiene than refusing to run on
old bash at all. This is one reason "raise the floor" is usually the
better strategy.

### Document the floor

Every BCS script should say *somewhere near the top* what version it
needs. The `# Requires bash 4.4+` line is part of the script's contract
with its operators; the runtime check is the enforcement mechanism that
backs it up.

```bash
#!/usr/bin/env bash
# myscript — Brief description.
#
# Requires bash 5.2+ (uses globskipdots, varredir_close, BASH_REMATCH
# semantics changed in 5.0, and `wait -p` from 5.0).
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Hard floor — fail before touching anything version-specific.
if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 2) )); then
  printf '%s: requires bash 5.2+ (have %s)\n' "${0##*/}" "$BASH_VERSION" >&2
  exit 18
fi
```

### Polyfilling — usually not worth it

Writing a function that simulates a missing feature (e.g. an `mapfile`
emulator for bash 3.2 on macOS) is technically possible and almost
always a mistake. The polyfill is slower, less robust, and one more
piece of code to maintain. If the script must run on macOS's stock
shell, switch the shebang to `#!/usr/bin/env bash` and document that
users install bash 5 via Homebrew (`brew install bash`); do not pretend
bash 3.2 is bash 5.

**See also**: §23.6 (Bash 3.2 on macOS) for the most common
multi-version scenario; §23.4 (Bash vs ksh) for the older-bash adjacent
target; Appendix M (Bash version history) for the per-version feature
matrix; Appendix L (exit codes) for code 18; BCS0409 (Bash version
detection) for the canonical version-gate pattern.

#fin
