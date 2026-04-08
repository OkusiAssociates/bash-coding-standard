# Section 06: Error Handling

## BCS0600 Section Overview

Error handling covers strict mode, exit codes, traps, return value checking, and error suppression patterns. Every script must fail safely and provide clear error context.

## BCS0601 Exit on Error

`set -euo pipefail` provides three protections: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.

```bash
# correct — allow expected failures
command_that_might_fail || true
if command_that_might_fail; then
  process_result
fi

# correct — handle undefined optional variables
"${OPTIONAL_VAR:-}"

# correct — capture failing command safely
if result=$(failing_command); then
  echo "$result"
fi
output=$(cmd) || die 1 'cmd failed'

# wrong
set +e                               # never disable broadly
command
set -e
```

## BCS0602 Exit Codes

Use `die()` as the standard exit function.

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

Standard exit codes:

| Code | Use Case |
|------|----------|
| 0 | Success |
| 1 | General error |
| 2 | Usage / argument error |
| 3 | File/directory not found |
| 5 | I/O error |
| 8 | Required argument missing |
| 13 | Permission denied |
| 18 | Missing dependency |
| 19 | Configuration error |
| 22 | Invalid argument |
| 24 | Timeout |

```bash
# correct — include context
die 3 "Config not found ${config@Q}"
die 22 "Invalid option ${1@Q}"

# wrong — no context
die 3 'File not found'
```

Reserved: 64-78 (sysexits), 126 (cannot execute), 127 (not found), 128+n (signals).

## BCS0603 Trap Handling

Install cleanup traps early, before creating any resources.

```bash
# correct
declare -- TEMP_FILE
#...
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT         # prevent recursion
  [[ -z ${TEMP_FILE:-} ]] || rm -f "$TEMP_FILE"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
#...
TEMP_FILE=$(mktemp)
readonly TEMP_FILE
```

Use single quotes for trap commands to delay variable expansion. Use `||:` for cleanup operations that might fail.

```bash
# correct — single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# correct — kill background processes in cleanup
((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:

# wrong — double quotes expand immediately
trap "rm -f $temp_file" EXIT
```

Never combine multiple traps for the same signal (replaces previous). Use a single trap with a cleanup function.

## BCS0604 Checking Return Values

Always check return values of critical operations.

```bash
# correct
mv "$file" "$dest" || die 1 "Failed to move ${file@Q}"
output=$(command) || die 1 'Command failed'

# correct — command group with cleanup on failure
cp "$src" "$dst" || {
  rm -f "$dst"
  die 1 'Copy failed'
}

# correct — check PIPESTATUS for pipelines
sort "$file" | uniq > "$output"
((PIPESTATUS[0] == 0)) || die 1 'Sort failed'

# correct — check $? immediately
cmd1
local -i result=$?
```

## BCS0605 Error Suppression

Only suppress errors when failure is expected, non-critical, and explicitly safe to ignore.

```bash
# correct — safe to suppress
command -v optional_tool &>/dev/null
rm -f /tmp/optional_*
rmdir "$maybe_empty" 2>/dev/null ||:

# correct — suppress message but check return
if result=$(command 2>/dev/null); then
  process "$result"
fi

# wrong — suppressing critical operations
cp "$src" "$dst" 2>/dev/null || true
set +e                               # never disable broadly
```

Verify system state after suppressed operations when possible.

## BCS0606 Conditional Declarations

Prefer inverting the condition with `||` over `((condition)) && action ||:`.

```bash
# preferred — inverted condition avoids ||: entirely
((width >= 20)) || width=20
((padding >= 0)) || padding=0
((color_count < 256)) || HAS_COLOR=1

# acceptable — when && reads more naturally
((DRY_RUN)) && info 'Dry-run mode' ||:
((VERBOSE)) && echo "Processing $file" ||:
((DEBUG)) && set -x ||:

# wrong — exits script when condition is false under set -e
((DRY_RUN)) && info 'Dry-run mode'
```

A false arithmetic condition returns exit code 1, which triggers `set -e`. The inverted `||` form avoids this because the right-hand side (an assignment or command) returns 0. When `&&` reads more naturally (e.g., flag-guarded actions), append `||:` to make the expression safe. Use `:` over `true` (traditional shell idiom, built-in).

Never use `||:` for critical operations that must succeed.
