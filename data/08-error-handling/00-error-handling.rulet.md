# Error Handling - Rulets
## Exit on Error
- [BCS0801] Always use `set -euo pipefail` at line 5 (after script description) to enable strict error detection: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` exits if any command in a pipeline fails.
- [BCS0801] Add `shopt -s inherit_errexit` to make command substitution inherit `set -e` behavior, ensuring `output=$(failing_command)` exits on failure.
- [BCS0801] Allow specific commands to fail using `command_that_might_fail || true` or wrap in conditional: `if command_that_might_fail; then ... else ... fi`.
- [BCS0801] Check if optional variables exist before using with: `[[ -n "${OPTIONAL_VAR:-}" ]]` to prevent exit on undefined variable with `set -u`.
- [BCS0801] Never capture command substitution in assignment without checking: `result=$(failing_command)` doesn't exit with `set -e`; use `result=$(cmd) || die 1` or enable `shopt -s inherit_errexit`.
## Exit Codes
- [BCS0802] Implement standard `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error handling with exit codes and messages.
- [BCS0802] Use standard exit codes: `0` for success, `1` for general error, `2` for misuse/missing argument, `22` for invalid argument (EINVAL), `5` for I/O error.
- [BCS0802] Never use exit codes above 125 for custom errors; codes 126-127 are reserved for shell errors, 128+n for fatal signals, and 255 is out of range.
- [BCS0802] Define exit code constants as readonly integers for readability: `readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3`.
- [BCS0802] Check exit codes in case statements to handle different failure modes: `case $? in 1) ... ;; 2) ... ;; *) ... ;; esac`.
## Trap Handling
- [BCS0803] Implement standard cleanup function pattern: capture exit code with `cleanup() { local -i exitcode=${1:-0}; trap - SIGINT SIGTERM EXIT; ... ; exit "$exitcode"; }`.
- [BCS0803] Install trap early before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT` ensures cleanup runs on normal exit, errors, Ctrl+C, and kill signals.
- [BCS0803] Always disable trap at start of cleanup function with `trap - SIGINT SIGTERM EXIT` to prevent recursion if cleanup itself fails.
- [BCS0803] Preserve exit code by capturing immediately: `trap 'cleanup $?' EXIT` passes original exit status; never use `trap 'cleanup' EXIT` as `$?` may change.
- [BCS0803] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` evaluates variables when trap fires, not when set.
- [BCS0803] Create temp files and directories before trap installation risks resource leaks; always use: `temp_file=$(mktemp) || die 1 'Failed'; trap 'rm -f "$temp_file"' EXIT`.
## Checking Return Values
- [BCS0804] Always check return values of critical operations with explicit conditionals: `if ! mv "$source" "$dest"; then die 1 "Failed to move $source to $dest"; fi`.
- [BCS0804] Provide informative error messages including context: `die 1 "Failed to move $source to $dest"` not just `die 1 "Move failed"`.
- [BCS0804] Check command substitution results explicitly: `output=$(command) || die 1 "command failed"` or enable `shopt -s inherit_errexit` to inherit `set -e` in subshells.
- [BCS0804] Use `set -o pipefail` to catch pipeline failures: without it, `cat missing_file | grep pattern` continues even if cat fails; with it, entire pipeline fails.
- [BCS0804] Check `PIPESTATUS` array for individual pipeline command exit codes: `if ((PIPESTATUS[0] != 0)); then die 1 "First command failed"; fi`.
- [BCS0804] Use cleanup on failure pattern: `operation || { error "Failed"; cleanup_resources; die 1; }` ensures partial state is cleaned up.
- [BCS0804,BCS0802] Capture and check exit codes when different codes require different actions: `cmd; exit_code=$?; case $exit_code in 0) ... ;; 1) ... ;; esac`.
## Error Suppression
- [BCS0805] Only suppress errors when failure is expected, non-critical, and explicitly documented: add comment explaining WHY suppression is safe before every `2>/dev/null` or `|| true`.
- [BCS0805] Never suppress critical operations like file copies, data processing, system configuration, security operations, or dependency checks; these must fail explicitly.
- [BCS0805] Use `2>/dev/null` to suppress only error messages while still checking return code: `if ! command 2>/dev/null; then error "command failed"; fi`.
- [BCS0805] Use `|| true` to ignore return code while keeping error messages visible for debugging.
- [BCS0805] Use combined suppression `2>/dev/null || true` only when both error messages and return code are completely irrelevant: `rmdir /tmp/maybe_exists 2>/dev/null || true`.
- [BCS0805] Appropriate suppression cases: checking if optional commands exist (`command -v tool >/dev/null 2>&1`), cleanup operations (`rm -f /tmp/files 2>/dev/null || true`), idempotent operations (`install -d "$dir" 2>/dev/null || true`).
- [BCS0805] Verify system state after suppressed operations when possible: after `install -d "$dir" 2>/dev/null || true`, check `[[ -d "$dir" ]] || die 1 "Failed to create $dir"`.
## Conditional Declarations
- [BCS0806] Append `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit: `((complete)) && declare -g BLUE=$'\033[0;34m' || :`.
- [BCS0806] Use colon `:` instead of `true` as no-op fallback; it's the traditional Unix idiom, built-in, and more concise.
- [BCS0806] Arithmetic conditionals `(())` return 0 (success) when true, 1 (failure) when false; under `set -e`, false conditions without `|| :` will exit the script.
- [BCS0806] Use `|| :` pattern only for optional operations like feature-gated variable declarations; never suppress critical operations that must succeed.
- [BCS0806] Prefer explicit `if` statements over `((condition)) && action || :` for complex logic with multiple statements or when clarity is more important than conciseness.
- [BCS0806,BCS0805] Never use `|| :` to suppress critical operation failures; use explicit error handling: `if ((flag)); then critical_op || die 1 "Failed"; fi`.
