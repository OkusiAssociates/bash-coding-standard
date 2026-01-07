# Error Handling - Rulets
## Exit on Error
- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` to ensure command substitutions inherit `set -e` behavior.
- [BCS0601] Allow expected failures with `command_that_might_fail || true` or by wrapping in conditional: `if command_that_might_fail; then ...`.
- [BCS0601] Handle undefined optional variables with default syntax: `"${OPTIONAL_VAR:-}"`.
- [BCS0601] Never use `set +e` broadly; only disable errexit for specific commands when absolutely necessary, then immediately re-enable.
- [BCS0601] Capture failing command output safely: `if result=$(failing_command); then ...` or `output=$(cmd) || die 1 'cmd failed'`.
## Exit Codes
- [BCS0602] Use `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }` as the standard exit function.
- [BCS0602] Exit 0 for success, 1 for general error, 2 for usage error, 3 for file not found, 5 for I/O error, 22 for invalid argument.
- [BCS0602] Use exit codes 8 (required argument missing), 9 (value out of range), 10 (wrong type/format) for validation errors.
- [BCS0602] Use exit codes 11 (operation not permitted), 12 (read-only), 13 (permission denied) for permission errors.
- [BCS0602] Use exit codes 18 (missing dependency), 19 (configuration error), 20 (environment error), 21 (invalid state) for environment issues.
- [BCS0602] Use exit codes 23 (network error), 24 (timeout), 25 (host unreachable) for network operations.
- [BCS0602] Never use exit codes 64-78 (sysexits), 126 (cannot execute), 127 (not found), or 128+n (signals) - these are reserved.
- [BCS0602] Include context in error messages: `die 3 "Config not found ${config@Q}"` not just `die 3 'File not found'`.
## Trap Handling
- [BCS0603] Install cleanup traps early with `trap 'cleanup $?' SIGINT SIGTERM EXIT` before creating any resources.
- [BCS0603] Always disable traps inside cleanup function first: `trap - SIGINT SIGTERM EXIT` to prevent recursion.
- [BCS0603] Preserve exit code by capturing `$?` immediately: `cleanup() { local -i exitcode=${1:-0}; ... exit "$exitcode"; }`.
- [BCS0603] Use single quotes for trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` not double quotes.
- [BCS0603] Use `||:` or `|| true` for cleanup operations that might fail: `rm -rf "$temp_dir" ||:`.
- [BCS0603] Kill background processes in cleanup: `((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:`.
- [BCS0603] Never combine multiple traps for same signal (replaces previous); use single trap with function or compound commands.
## Checking Return Values
- [BCS0604] Always check return values of critical operations even with `set -e`: `mv "$file" "$dest" || die 1 "Failed to move ${file@Q}"`.
- [BCS0604] Check command substitution results explicitly: `output=$(command) || die 1 'Command failed'` since `set -e` doesn't catch these.
- [BCS0604] Use `set -o pipefail` and verify with PIPESTATUS array for critical pipelines: `((PIPESTATUS[0] != 0))` checks first command.
- [BCS0604] Check `$?` immediately after command, not after other operations: `cmd1; result=$?; cmd2; # result is from cmd1`.
- [BCS0604] Use command group with cleanup on failure: `cp "$src" "$dst" || { rm -f "$dst"; die 1 "Copy failed"; }`.
- [BCS0604] Handle different exit codes with case statement: `case $? in 0) success;; 2) die 2 'Not found';; *) die 1 'Unknown error';; esac`.
- [BCS0604] Prefer process substitution over pipes to while loops to avoid subshell issues: `while read -r line; do ...; done < <(command)`.
## Error Suppression
- [BCS0605] Only suppress errors when failure is expected, non-critical, and explicitly safe to ignore; always document why.
- [BCS0605] Use `command 2>/dev/null` to suppress error messages while still checking return value.
- [BCS0605] Use `command || true` or `command ||:` to ignore return code while keeping stderr visible.
- [BCS0605] Use `command 2>/dev/null || true` only when both messages and return code are irrelevant.
- [BCS0605] Safe to suppress: `command -v optional_tool >/dev/null 2>&1`, `rm -f /tmp/optional_*`, `rmdir maybe_empty 2>/dev/null ||:`.
- [BCS0605] Never suppress: file copies, data processing, security operations, system configuration, or required dependency checks.
- [BCS0605] Never use `set +e` to suppress errors; use `|| true` for specific commands only.
- [BCS0605] Verify system state after suppressed operations when possible: `install -d "$dir" 2>/dev/null ||:; [[ -d "$dir" ]] || die 1 'Failed'`.
## Conditional Declarations with Exit Code Handling
- [BCS0606] Append `||:` to `((condition)) && action` patterns under `set -e`: `((complete)) && declare -g VAR=value ||:`.
- [BCS0606] Use colon `:` over `true` for the no-op (traditional shell idiom, built-in, single character).
- [BCS0606] False arithmetic conditions return exit code 1 which triggers `set -e`; `||:` makes overall expression return 0.
- [BCS0606] Use for optional declarations: `((DEBUG)) && declare -g DEBUG_LOG=/tmp/debug.log ||:`.
- [BCS0606] Use for conditional output: `((VERBOSE)) && echo "Processing $file" ||:`.
- [BCS0606] Use for tier-based features: `((complete)) && declare -g BLUE=$'\033[0;34m' ||:`.
- [BCS0606] Never use `||:` for critical operations that must succeed; use explicit if statement with error handling instead.
- [BCS0606] For nested conditionals, apply `||:` to each level: `((outer)) && { action; ((inner)) && nested ||:; } ||:`.
