<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.7 Logging discipline

Every non-trivial script needs a small set of diagnostic helpers:
`info`, `success`, `warn`, `error`, `die`. The BCS canonical
implementation (BCS0703) is a single `_msg` core that dispatches by
icon argument, with per-level wrappers. All output goes to stderr
(§14.1) so the script remains pipe-composable.

### Canonical implementation

The pattern below is lifted verbatim from the BCS reference scripts.
The whole messaging suite is roughly 15 lines:

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/}
declare -i VERBOSE=1 DEBUG=0

# Colour init — see §14.9 (BCS0706)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' \
             CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg()    { >&2 printf "$SCRIPT_NAME: $1 %s\n" "${@:2}"; }
error()   { _msg "$RED✗$NC"     "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
warn()    { _msg "$YELLOW▲$NC"  "$@"; }
info()    { ((VERBOSE)) || return 0; _msg "$CYAN◉$NC"   "$@"; }
success() { ((VERBOSE)) || return 0; _msg "$GREEN✓$NC"  "$@"; }
debug()   { ((DEBUG))   || return 0; _msg "${RED}DEBUG$NC" "$@"; }
```

### How `_msg` dispatch works

`_msg` is the only function that touches stdio. Every wrapper passes
its severity icon as `$1` and forwards the user's message arguments
as `${@:2}`. Inside `_msg`:

- `>&2` — redirect the entire command to stderr (§14.1).
- `printf "$SCRIPT_NAME: $1 %s\n"` — format string carries the script
  name and the icon literally; the message words go through `%s`.
- `"${@:2}"` — every argument from position 2 onward becomes its own
  `%s`; `printf` recycles the format until inputs are exhausted, so
  one-liners and multi-arg calls both behave correctly.

### Behaviour by severity

```bash
# scenario: typical use throughout a script
info 'Loading configuration'        # only when VERBOSE=1 (default)
success 'Imported 42 records'       # only when VERBOSE=1
warn 'Cache stale; rebuilding'      # always shown
error 'Connection refused'          # always shown
die 22 'Invalid argument:' "$1"     # always shown, then exits 22
debug "PATH=$PATH"                  # only when DEBUG=1
```

| Helper    | Visible when    | Goes to | Exits? |
|-----------|-----------------|---------|--------|
| `info`    | `VERBOSE=1`     | stderr  | no     |
| `success` | `VERBOSE=1`     | stderr  | no     |
| `warn`    | always          | stderr  | no     |
| `error`   | always          | stderr  | no     |
| `die`     | always          | stderr  | yes    |
| `debug`   | `DEBUG=1`       | stderr  | no     |

`die N msg ...` is the canonical exit helper: first argument is the
exit code, remaining arguments form the error message. Exit codes
follow the BCS table (1 general, 2 usage, 22 invalid argument, …).
`die N` with no message exits silently — useful for terminating
without further output.

### Invocation patterns

```bash
# scenario: pass the script name through automatically
$ myscript --bogus
myscript: ✗ Invalid argument '--bogus'
$ echo $?
22

# scenario: VERBOSE off, only warnings/errors visible
$ VERBOSE=0 myscript
myscript: ▲ Cache stale; rebuilding
```

Note that `$SCRIPT_NAME` (BCS0102) is referenced at every call but
expanded once in the format string — efficient and consistent. Multi-
argument calls produce one line per argument because the format is
`%s\n`; pre-format with `printf -v` if you need a single line:

```bash
printf -v line 'records=%d errors=%d' "$n" "$err"
info "$line"
```

### Why FUNCNAME dispatch is *not* used here

A common alternative is a single `msg` function that inspects
`${FUNCNAME[1]}` to pick its icon. The BCS pattern is simpler: each
wrapper passes the icon explicitly. This avoids one stack-frame
lookup per message and keeps `_msg` callable from anywhere
(including subshells where `FUNCNAME[1]` may be empty).

### Timestamps and structured logging

For longer-running scripts, prepend a timestamp via `printf`'s
`%(fmt)T` specifier (built-in, no `date(1)` fork):

```bash
# scenario: extend _msg with an ISO-8601 timestamp
_msg() {
  >&2 printf '[%(%FT%T%z)T] %s: %s %s\n' \
    -1 "$SCRIPT_NAME" "$1" "${*:2}"
}
```

The `-1` argument tells `printf` to use *now* as the time. For
machine-readable output (pipe to `jq`, store in a journal), build a
structured logger that emits a single JSON line per call — but keep
it on stderr so pipelines see only data on stdout (§14.1).

### Anti-patterns to avoid

```bash
# wrong — diagnostic on stdout, breaks pipelines
echo "Loading config"
echo "$result"

# wrong — colour codes hard-coded; breaks log files
echo -e '\033[31mERROR\033[0m: failed'

# wrong — multiple bare echoes; no script-name context
echo "WARN: cache stale"
echo "INFO: rebuilding"

# right — single helper, stderr, conditional colour
warn 'cache stale'
info 'rebuilding'
```

A script that uses the BCS messaging suite from line one rarely
acquires logging bugs — every diagnostic flows through one place.

### See also

- §14.1 — stdout/stderr discipline (why diagnostics go to stderr)
- §14.9 — colour init for `RED`/`GREEN`/etc.
- §14.8 — log levels and `VERBOSE`/`DEBUG` gating
- BCS0703 (messaging system), BCS0102 (`SCRIPT_NAME`),
  BCS0706 (colour definitions)

#fin
