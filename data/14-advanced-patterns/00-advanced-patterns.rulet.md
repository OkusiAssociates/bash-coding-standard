# Advanced Patterns - Rulets
## Debugging & Development
- [BCS1401] Enable debug mode with `declare -i DEBUG="${DEBUG:-0}"` and activate trace output using `((DEBUG)) && set -x` for troubleshooting.
- [BCS1401] Customize trace output with `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '` to show filename, line number, and function name in debug traces.
- [BCS1401] Implement conditional debug output with a `debug()` function that checks `((DEBUG))` before calling `_msg()` to stderr.
## Dry-Run Pattern
- [BCS1402] Implement dry-run mode by declaring `declare -i DRY_RUN=0` and checking `((DRY_RUN))` at the start of functions that modify state, displaying preview messages with `[DRY-RUN]` prefix and returning early without performing actual operations.
- [BCS1402] Parse dry-run flags with `-n|--dry-run) DRY_RUN=1` and `-N|--not-dry-run) DRY_RUN=0` for toggling preview mode.
- [BCS1402] Structure dry-run functions to maintain identical control flow whether in preview or execution mode, ensuring logic verification without side effects.
## Temporary File Handling
- [BCS1403] Always use `mktemp` to create temporary files and directories with secure permissions (0600 for files, 0700 for directories), never hard-code temp file paths like `/tmp/myapp.txt`.
- [BCS1403] Set up cleanup traps immediately after creating temp resources: `temp_file=$(mktemp) || die 1 'Failed to create temp file'` followed by `trap 'rm -f "$temp_file"' EXIT`.
- [BCS1403] Store temp file paths in variables and make them readonly when possible: `readonly -- temp_file` to prevent accidental modification.
- [BCS1403] For multiple temp resources, use an array with a cleanup function: `declare -a TEMP_RESOURCES=()` and `cleanup() { for resource in "${TEMP_RESOURCES[@]}"; do rm -rf "$resource"; done }` with `trap cleanup EXIT`.
- [BCS1403] Never use hard-coded paths, PIDs in filenames, or manual temp file creation - these create security vulnerabilities and race conditions.
- [BCS1403] Use custom templates when helpful: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (minimum 3 X's required for uniqueness).
- [BCS1403] Verify temp file security by checking permissions (0600), ownership (current user), and file type (regular file) when handling sensitive data.
- [BCS1403] Implement `--keep-temp` option for debugging by checking the flag in cleanup function before removing temp resources.
## Environment Variables
- [BCS1404] Validate required environment variables with `: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"` to exit immediately if not set.
- [BCS1404] Provide defaults for optional environment variables using `: "${OPTIONAL_VAR:=default_value}"` or `export VAR="${VAR:-default}"`.
- [BCS1404] Check multiple required variables by iterating through an array and testing `[[ -n "${!var:-}" ]]` to ensure all are set before proceeding.
## Regular Expressions
- [BCS1405] Use POSIX character classes for portability: `[[:alnum:]]`, `[[:digit:]]`, `[[:space:]]`, `[[:xdigit:]]` instead of literal ranges.
- [BCS1405] Store complex regex patterns in readonly variables: `readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'` then use `[[ "$email" =~ $EMAIL_REGEX ]]`.
- [BCS1405] Access regex capture groups through `BASH_REMATCH` array after successful match: `major="${BASH_REMATCH[1]}"`.
## Background Job Management
- [BCS1406] Track background process PIDs with `command &` followed by `PID=$!` to enable monitoring and control.
- [BCS1406] Check if background process is still running using `kill -0 "$PID" 2>/dev/null` which returns 0 if process exists.
- [BCS1406] Use `timeout` command with `wait` for timed background operations: `timeout 10 wait "$PID"` returns 124 on timeout.
- [BCS1406] Manage multiple background jobs by storing PIDs in an array `PIDS+=($!)` and iterating with `for pid in "${PIDS[@]}"; do wait "$pid"; done`.
## Logging
- [BCS1407] Implement structured logging with ISO8601 timestamps, script name, log level, and message: `printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"`.
- [BCS1407] Define log file location with defaults and create log directory if needed: `readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"` followed by `mkdir -p "${LOG_FILE%/*}"`.
- [BCS1407] Provide convenience logging functions (`log_debug`, `log_info`, `log_warn`, `log_error`) that wrap the main `log()` function.
## Performance Profiling
- [BCS1408] Use the `SECONDS` builtin for simple timing by resetting `SECONDS=0` before operation and reading elapsed time after completion.
- [BCS1408] Use `EPOCHREALTIME` for high-precision timing: capture `start=$EPOCHREALTIME` before operation, `end=$EPOCHREALTIME` after, calculate with `awk "BEGIN {print $end - $start}"`.
## Testing Support
- [BCS1409] Implement dependency injection by declaring command wrappers as functions: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` allows test mocking.
- [BCS1409] Use `declare -i TEST_MODE="${TEST_MODE:-0}"` flag to enable test-specific behavior like using test data directories or disabling destructive operations.
- [BCS1409] Implement assert function for test validation: check expected vs actual values, output detailed failure message to stderr, return 1 on failure.
- [BCS1409] Create test runner that discovers functions matching `test_*` pattern, executes each, tracks passed/failed counts, and returns 0 only if all pass.
## Progressive State Management
- [BCS1410] Declare boolean flags with initial values at script start: `declare -i INSTALL_BUILTIN=0`, `declare -i BUILTIN_REQUESTED=0`, `declare -i SKIP_BUILTIN=0`.
- [BCS1410] Parse command-line arguments to set flags based on user input, tracking both user intent (e.g., `BUILTIN_REQUESTED`) and current state (e.g., `INSTALL_BUILTIN`).
- [BCS1410] Progressively adjust flags based on runtime conditions in logical order: parse arguments → validate dependencies → check build success → execute actions.
- [BCS1410] Separate decision logic from execution by modifying flags during validation phase, then executing actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin`.
- [BCS1410] Disable features when prerequisites fail by resetting flags: `check_builtin_support || INSTALL_BUILTIN=0` ensures fail-safe behavior.
- [BCS1410] Never modify flags during execution phase - only in setup and validation phases to maintain clear separation between decision-making and action.
