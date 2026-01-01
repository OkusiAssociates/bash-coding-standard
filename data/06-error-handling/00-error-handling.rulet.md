# Error Handling - Rulets
## Exit on Error (set -euo pipefail)
- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` so command substitutions inherit `set -e` behavior.
- [BCS0601] Allow expected failures with `command || true` or `if command; then ...; fi` patterns.
- [BCS0601] Capture exit code when needed: `set +e; result=$(failing_command); set -e` or use `if result=$(cmd); then`.
- [BCS0601] Never use `result=$(failing_command)` without error handling—command substitution failures don't exit with `set -e` alone.
## Exit Codes
- [BCS0602] Use standard exit codes: 0=success, 1=general error, 2=misuse/missing argument, 22=invalid argument (EINVAL), 5=permission denied.
- [BCS0602] Implement `die()` for consistent exits: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0602] Use `die 22 "Invalid option ${1@Q}"` for argument errors, matching errno EINVAL convention.
- [BCS0602] Avoid exit codes 126-255 for custom errors; these conflict with signal handling (128+n = fatal signal n).
- [BCS0602] Define exit code constants for readability: `readonly -i ERR_USAGE=2 ERR_CONFIG=3 ERR_NETWORK=4`.
## Trap Handling
- [BCS0603] Install traps early, before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS0603] Always preserve exit code in traps: use `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`.
- [BCS0603] Disable trap inside cleanup to prevent recursion: `cleanup() { trap - SIGINT SIGTERM EXIT; ... }`.
- [BCS0603] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT`.
- [BCS0603] Handle multiple signals by combining in cleanup function; avoid multiple separate traps for same signal.
- [BCS0603] For temp files: `temp_file=$(mktemp) || die 1 'Failed to create temp'; trap 'rm -f "$temp_file"' EXIT`.
## Return Value Checking
- [BCS0604] Always check return values of critical operations with informative error messages: `mv "$src" "$dst" || die 1 "Failed to move ${src@Q}"`.
- [BCS0604] Use `|| { cleanup; exit 1; }` pattern when failure requires cleanup before exit.
- [BCS0604] Check PIPESTATUS array for pipeline failures: `((PIPESTATUS[0] != 0))` checks first command.
- [BCS0604] Command substitution needs explicit check: `output=$(cmd) || die 1 'cmd failed'`.
- [BCS0604] Capture exit code immediately: `command; exit_code=$?` before any other commands that would overwrite `$?`.
- [BCS0604] Use `if ! operation; then die 1 'msg'; fi` for operations needing contextual error messages.
- [BCS0604] Functions should use meaningful return codes: `return 2` for not found, `return 5` for permission denied, `return 22` for invalid input.
## Error Suppression
- [BCS0605] Only suppress errors when failure is expected, non-critical, and safe—always document WHY with a comment.
- [BCS0605] Use `2>/dev/null` to suppress error messages while still checking return value.
- [BCS0605] Use `|| true` or `|| :` to ignore return code while keeping stderr visible.
- [BCS0605] Use `2>/dev/null || true` only when both error messages and return code are irrelevant.
- [BCS0605] Safe to suppress: existence checks (`command -v`), cleanup of optional files (`rm -f /tmp/opt_* 2>/dev/null || true`), idempotent operations (`install -d`).
- [BCS0605] Never suppress: file operations, data processing, system configuration, security operations, required dependency checks.
- [BCS0605] Verify after suppressed operations when possible: `install -d "$dir" 2>/dev/null || true; [[ -d "$dir" ]] || die 1 'Failed'`.
## Conditional Declarations with Exit Code Handling
- [BCS0606] Append `|| :` to `((condition)) && action` patterns under `set -e`: `((verbose)) && echo 'msg' || :`.
- [BCS0606] Arithmetic conditionals return exit code 1 when false, which triggers `set -e`—`|| :` prevents this.
- [BCS0606] Prefer `:` over `true` for the null command—it's the traditional Unix idiom and slightly faster.
- [BCS0606] Use for optional variable declarations: `((complete)) && declare -g EXTRA=$'\033[0;34m' || :`.
- [BCS0606] Use for feature-gated actions: `((DRY_RUN)) && echo "Would execute: $cmd" || :`.
- [BCS0606] Never use `|| :` for critical operations that must succeed—use explicit error handling instead.
- [BCS0606] For complex logic, prefer explicit `if ((condition)); then action; fi` over `((condition)) && action || :`.
