<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Section 06: Error Handling

## BCS0600 Section Overview

Error handling covers strict mode, exit codes, traps, return value checking, and error suppression patterns. Every script must fail safely and provide clear error context.

## BCS0601 Exit on Error

**Tier:** core

`set -euo pipefail` provides three protections: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.

```bash
# correct — allow expected failures
command_that_might_fail ||:
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

**Tier:** recommended

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

**Tier:** core

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

**Tier:** core

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

**`PIPESTATUS` pitfalls:**

- `PIPESTATUS` is overwritten by the **very next command** -- including `echo`. Snapshot it immediately if you need it across statements: `local -a ps=("${PIPESTATUS[@]}")`.
- Under `set -o pipefail` (part of BCS0101 strict mode), `$?` already reflects the rightmost non-zero exit. Inspect `PIPESTATUS` only when you need to distinguish *which* stage failed.
- `((PIPESTATUS[0]))` only tells you about the first command. For a multi-stage pipeline, iterate over a snapshot:

```bash
# correct — snapshot, then inspect each stage
sort "$file" | uniq | wc -l > "$output"
local -a ps=("${PIPESTATUS[@]}")
for i in "${!ps[@]}"; do
  ((ps[i] == 0)) || die 1 "Stage $i failed (exit ${ps[i]})"
done

# wrong — echo clobbers PIPESTATUS before we read it
sort "$file" | uniq | wc -l > "$output"
echo 'Pipeline done'
((PIPESTATUS[0] == 0)) || die 1 'Sort failed'   # PIPESTATUS is now echo's
```

## BCS0605 Error Suppression

**Tier:** recommended

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

**Tier:** core

Under `set -e`, a false arithmetic condition (e.g., `((DRY_RUN))` when `DRY_RUN=0`) returns exit code 1 and terminates the script. Any `&&` chain built on an arithmetic condition MUST end with `||:` to suppress this, unless the chain is expressed in inverted form with `||`.

**Mandatory (correctness):** the `&&`-chain form requires `||:`:

```bash
# correct — flag-guarded action, safely wrapped
((DRY_RUN)) && info 'Dry-run mode' ||:
((VERBOSE)) && echo "Processing $file" ||:
((DEBUG)) && set -x ||:
((VERBOSE < 3)) && VERBOSE+=1 ||:

# wrong — missing ||:, script exits when flag is 0
((DRY_RUN)) && info 'Dry-run mode'
```

The inverted form avoids the issue because the RHS returns 0:

```bash
# correct — no ||: needed (RHS is an assignment or command returning 0)
((width >= 20)) || width=20
((padding >= 0)) || padding=0
((color_count < 256)) || HAS_COLOR=1
command -v curl >/dev/null || die 18 'curl required'
```

The `||:` catches failure from **the entire chain**, including the arithmetic condition -- not just the final command. Use `:` over `true` (shorter, built-in, traditional shell idiom).

**Style (preference only):** when `||:` is present, both the `&&...||:` form and the inverted `||` form are correct. Pick whichever reads more naturally -- short guard clauses favour inversion; flag-guarded actions often favour `&&...||:`. **Neither form alone is a violation.** LLM-based checkers MUST NOT report a rule violation for form choice when `||:` is properly present.

**Never:** never use `||:` for critical operations that must succeed -- it masks real failures.
