# Error Handling - Rulets

## Exit on Error Configuration

- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` to make command substitutions inherit `set -e` behavior.
- [BCS0601] Allow specific commands to fail using `command || true` pattern; never disable `set -e` globally.
- [BCS0601] When capturing output from commands that may fail, use `if result=$(command); then` or `result=$(command) || die 1 "Failed"`.
- [BCS0601] With `set -e`, checking `$?` after assignment like `result=$(failing_command)` is unreachable—the script already exited.

## Exit Codes

- [BCS0602] Use standard exit codes: `0` (success), `1` (general error), `2` (misuse/usage error), `22` (invalid argument/EINVAL), `5` (permission denied).
- [BCS0602] Implement `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error exits.
- [BCS0602] Define exit codes as readonly constants for readability: `readonly -i ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3`.
- [BCS0602] Avoid exit codes 126-255 for custom errors; these conflict with shell-reserved codes and signal numbers (128+n).

## Trap Handling

- [BCS0603] Install traps early, before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS0603] Always disable traps inside cleanup function to prevent recursion: `trap - SIGINT SIGTERM EXIT`.
- [BCS0603] Preserve exit code by capturing `$?` in trap command: `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`.
- [BCS0603] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT`.
- [BCS0603] Create cleanup function for non-trivial cleanup; avoid complex inline trap commands.
- [BCS0603] Handle cleanup failures gracefully: `rm -rf "$temp_dir" || warn "Failed to remove temp directory"`.

## Return Value Checking

- [BCS0604] Always check return values of critical operations; `set -e` doesn't catch all failures (pipelines, conditionals, command substitution).
- [BCS0604] Provide context in error messages: `mv "$file" "$dest" || die 1 "Failed to move $file to $dest"` not just `"Move failed"`.
- [BCS0604] Check command substitution results explicitly: `output=$(command) || die 1 "Command failed"`.
- [BCS0604] Use `PIPESTATUS` array to check individual pipeline command results: `((PIPESTATUS[0] != 0)) && die 1 "First command failed"`.
- [BCS0604] Capture exit code immediately after command if needed: `command; exit_code=$?` before any other operations.
- [BCS0604] Clean up on failure using command groups: `cp "$src" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }`.

## Error Suppression

- [BCS0605] Only suppress errors when failure is expected, non-critical, and safe to ignore; always document WHY with a comment.
- [BCS0605] Use `|| true` to ignore return code while keeping stderr visible; use `2>/dev/null` to suppress messages while checking return code.
- [BCS0605] Use `2>/dev/null || true` only when both error messages and return code are irrelevant.
- [BCS0605] Safe to suppress: optional tool checks (`command -v optional_tool >/dev/null 2>&1`), cleanup operations (`rm -f /tmp/myapp_* 2>/dev/null || true`), idempotent operations (`install -d "$dir" 2>/dev/null || true`).
- [BCS0605] Never suppress: critical file operations, data processing, security operations, required dependency checks.
- [BCS0605] Verify system state after suppressed operations when possible: `install -d "$dir" 2>/dev/null || true; [[ -d "$dir" ]] || die 1 "Failed"`.

## Conditional Declarations with Exit Code Handling

- [BCS0606] Append `|| :` to `((condition)) && action` patterns under `set -e` to prevent false conditions from exiting: `((verbose)) && echo "Debug" || :`.
- [BCS0606] Prefer colon `:` over `true` for no-op fallback (traditional shell idiom, single character, no PATH lookup).
- [BCS0606] Use for optional variable declarations: `((complete)) && declare -g EXTRA_VAR=value || :`.
- [BCS0606] Use for feature-gated actions: `((DRY_RUN)) && echo "Would execute: $cmd" || :`.
- [BCS0606] Never use `|| :` for critical operations that must succeed—use explicit `if` statement with error handling instead.
- [BCS0606] For complex conditional logic, prefer explicit `if ((condition)); then action; fi` over `((condition)) && action || :`.
