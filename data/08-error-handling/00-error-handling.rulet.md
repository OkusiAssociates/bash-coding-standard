# Error Handling - Rulets

## Exit on Error Configuration

- [BCS0801] Always use `set -euo pipefail` immediately after the shebang to enable strict error handling: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` exits if any command in a pipeline fails.
- [BCS0801] Strongly recommend `shopt -s inherit_errexit` to make command substitution inherit errexit behavior: `output=$(failing_command)` will exit with set -e.
- [BCS0801] Handle expected failures explicitly using `command || true`, conditional checks `if command; then`, or temporarily disable errexit with `set +e; risky_command; set -e`.
- [BCS0801] Check if optional variables exist before using them: `[[ -n "${OPTIONAL_VAR:-}" ]]` prevents exit on undefined variable.

## Standard Exit Codes

- [BCS0802] Use standard exit codes consistently: `0` for success, `1` for general error, `2` for misuse/missing argument, `22` for invalid argument (EINVAL), `5` for I/O error.
- [BCS0802] Implement a standard `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error exits with optional messages.
- [BCS0802] Define exit codes as readonly constants for readability: `readonly -i ERR_CONFIG=3 ERR_NETWORK=4` then use `die "$ERR_CONFIG" 'Failed to load config'`.
- [BCS0802] Never use exit codes above 125 for custom codes to avoid conflicts with signal codes (128+n) and shell reserved codes.

## Trap Handling for Cleanup

- [BCS0803] Always implement a `cleanup()` function with trap for resource cleanup: `trap 'cleanup $?' SIGINT SIGTERM EXIT` ensures cleanup runs on all exit paths.
- [BCS0803] Disable trap at the start of cleanup function to prevent recursion: `trap - SIGINT SIGTERM EXIT` must be first line in `cleanup()`.
- [BCS0803] Preserve the original exit code in cleanup: `cleanup() { local -i exitcode=${1:-0}; trap - SIGINT SIGTERM EXIT; # cleanup; exit "$exitcode"; }`.
- [BCS0803] Install traps early before creating resources to prevent leaks: set `trap 'cleanup $?' EXIT` before `temp_file=$(mktemp)`.
- [BCS0803] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` not `trap "rm -f $temp_file" EXIT`.

## Return Value Checking

- [BCS0804] Always check return values of critical operations with explicit error messages: `mv "$source" "$dest" || die 1 "Failed to move $source to $dest"`.
- [BCS0804] Use `set -o pipefail` to catch pipeline failures: without it, `cat missing_file | grep pattern` continues even if cat fails.
- [BCS0804] Check command substitution results explicitly: `output=$(command) || die 1 "Command failed"` because `set -e` doesn't catch substitution failures.
- [BCS0804] Use different patterns for different needs: `if ! command; then error; exit 1; fi` for informative errors, `command || die 1 "msg"` for concise checks, `command || { cleanup; exit 1; }` for cleanup on failure.
- [BCS0804] Handle partial failures in loops by tracking counts: increment `success_count` and `fail_count`, return non-zero if any failures occurred.

## Error Suppression

- [BCS0805] Only suppress errors when failure is expected, non-critical, and safe to ignore; always document WHY with a comment above the suppression.
- [BCS0805] Never suppress critical operations like file operations, data processing, system configuration, or security operations: `cp "$important" "$backup" 2>/dev/null || true` is dangerous.
- [BCS0805] Use `|| true` to ignore return codes while keeping stderr visible; use `2>/dev/null` to suppress error messages while checking return code; use both only when both are irrelevant.
- [BCS0805] Appropriate suppression cases: checking if commands exist `command -v optional_tool >/dev/null 2>&1`, cleanup operations `rm -f /tmp/myapp_* 2>/dev/null || true`, idempotent operations `install -d "$dir" 2>/dev/null || true`.
- [BCS0805] Verify after suppressed operations when possible: after `install -d "$dir" 2>/dev/null || true`, check `[[ -d "$dir" ]] || die 1 "Failed to create $dir"`.

## Conditional Declarations with Exit Code Handling

- [BCS0806] Append `|| :` after arithmetic conditionals to prevent false conditions from triggering `set -e` exit: `((complete)) && declare -g BLUE=$'\033[0;34m' || :`.
- [BCS0806] Prefer colon `:` over `true` for no-op fallback as it's the traditional Unix idiom and more concise: `((condition)) && action || :`.
- [BCS0806] Use `|| :` only for optional operations like conditional variable declarations, feature-gated actions, or optional logging; never for critical operations that must succeed.
- [BCS0806] For critical operations, use explicit error handling instead: `if ((flag)); then critical_operation || die 1 "Operation failed"; fi` not `((flag)) && critical_operation || :`.
- [BCS0806] Use if statements for complex conditional logic with multiple statements; use `((condition)) && action || :` only for simple one-line conditional declarations.

## Configuration and Best Practices

- [BCS0800] Configure error handling with `set -euo pipefail` before any other commands run to catch failures early.
- [BCS0801,BCS0804] Remember that `set -e` has limitations: doesn't catch pipeline failures (except last command without pipefail), commands in conditionals, commands with `||`, or command substitution without `inherit_errexit`.
- [BCS0803,BCS0805] Document all error suppression and cleanup decisions with comments explaining the rationale and why it's safe.
- [BCS0804] Provide context in error messages including what failed and with what inputs: `die 1 "Failed to move $file to $dest"` not `die 1 "Move failed"`.
- [BCS0801,BCS0804] Test error paths to ensure failures are caught correctly and cleanup runs as expected; verify both success and failure scenarios.
