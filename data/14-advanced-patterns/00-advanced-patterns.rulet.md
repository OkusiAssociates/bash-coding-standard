# Advanced Patterns - Rulets

## Debugging and Development

- [BCS1401] Enable trace mode with `set -x` when `DEBUG=1` and enhance trace output with `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '` for readable debugging.
- [BCS1401] Implement conditional debug output with `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }` to show messages only when debugging is enabled.

## Dry-Run Pattern

- [BCS1402] Check dry-run flag at the start of state-modifying functions with `if ((DRY_RUN)); then info '[DRY-RUN] Would perform action'; return 0; fi` to preview operations safely.
- [BCS1402] Display preview messages with `[DRY-RUN]` prefix using `info` and return early (exit code 0) without performing actual operations.
- [BCS1402] Parse dry-run from command-line with `-n|--dry-run) DRY_RUN=1` and `-N|--not-dry-run) DRY_RUN=0` flags.
- [BCS1402] Maintain identical control flow in dry-run mode (same function calls, same logic paths) to verify logic without side effects.

## Temporary File Handling

- [BCS1403] Always use `mktemp` to create temporary files (`temp_file=$(mktemp)`) or directories (`temp_dir=$(mktemp -d)`), never hard-code temp file paths.
- [BCS1403] Set up cleanup trap immediately after creating temp resources: `trap 'rm -f "$temp_file"' EXIT` for files, `trap 'rm -rf "$temp_dir"' EXIT` for directories.
- [BCS1403] Check mktemp success with `|| die 1 'Failed to create temporary file'` and make temp file variables readonly after creation.
- [BCS1403] Use custom templates for recognizable temp files: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (at least 3 X's required).
- [BCS1403] Register multiple temp resources in array with cleanup function: `TEMP_FILES+=("$temp_file")` and `trap cleanup_temp_files EXIT`.
- [BCS1403] Validate temp file security by checking permissions (0600 for files, 0700 for directories) and ownership when handling sensitive data.
- [BCS1403] Never overwrite EXIT trap when creating multiple temp files; use single trap with cleanup function or list all files: `trap 'rm -f "$temp1" "$temp2"' EXIT`.
- [BCS1403] Preserve exit code in cleanup function with `local -i exit_code=$?` and `return "$exit_code"` to maintain original script exit status.

## Environment Variable Best Practices

- [BCS1404] Validate required environment variables with `: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"` to exit script if not set.
- [BCS1404] Provide defaults for optional environment variables with `: "${OPTIONAL_VAR:=default_value}"` or `export VAR="${VAR:-default}"`.
- [BCS1404] Check multiple required variables in loop: `for var in "${REQUIRED[@]}"; do [[ -n "${!var:-}" ]] || error "Required variable '$var' not set"; done`.

## Regular Expression Guidelines

- [BCS1405] Use POSIX character classes for portability: `[[:alnum:]]` for alphanumeric, `[[:digit:]]` for digits, `[[:space:]]` for whitespace, `[[:xdigit:]]` for hexadecimal.
- [BCS1405] Store complex regex patterns in readonly variables: `readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'`.
- [BCS1405] Extract capture groups from `BASH_REMATCH` after successful regex match: `if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then major="${BASH_REMATCH[1]}"; fi`.

## Background Job Management

- [BCS1406] Start background jobs with `command &` and track PID with `PID=$!` for later process management.
- [BCS1406] Check if background process is still running with `kill -0 "$PID" 2>/dev/null` before attempting to wait or kill.
- [BCS1406] Wait for background jobs with timeout: `timeout 10 wait "$PID"` and kill on timeout with `kill "$PID" 2>/dev/null || true`.
- [BCS1406] Track multiple background jobs in array: `PIDS+=($!)` and wait for all with `for pid in "${PIDS[@]}"; do wait "$pid"; done`.

## Logging Best Practices

- [BCS1407] Create structured log entries with ISO8601 timestamp, script name, level, and message: `printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"`.
- [BCS1407] Ensure log directory exists before logging: `[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"`.
- [BCS1407] Provide convenience logging functions: `log_debug()`, `log_info()`, `log_warn()`, `log_error()` that call main `log()` function.

## Performance Profiling

- [BCS1408] Use `SECONDS` builtin for simple timing: `SECONDS=0; operation; info "Completed in ${SECONDS}s"`.
- [BCS1408] Use `EPOCHREALTIME` for high-precision timing: `start=$EPOCHREALTIME; "$@"; end=$EPOCHREALTIME; runtime=$(awk "BEGIN {print $end - $start}")`.

## Testing Support Patterns

- [BCS1409] Implement dependency injection by declaring command wrappers: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` for mockable external commands.
- [BCS1409] Use `TEST_MODE` flag to conditionally enable test behavior: `declare -i TEST_MODE="${TEST_MODE:-0}"` and override destructive operations in test mode.
- [BCS1409] Create assertion function for tests: `assert() { [[ "$expected" != "$actual" ]] && { >&2 echo "ASSERT FAIL: $message"; return 1; }; return 0; }`.
- [BCS1409] Implement test runner that finds and executes all `test_*` functions: `for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do "$test_func"; done`.

## Progressive State Management

- [BCS1410] Declare all boolean flags at the top with initial values: `declare -i INSTALL_BUILTIN=0`.
- [BCS1410] Progressively adjust flags based on runtime conditions: parse command-line arguments first, then validate dependencies, then check for failures.
- [BCS1410] Separate user intent from runtime state using distinct flags: `BUILTIN_REQUESTED=1` (what user asked for) vs `INSTALL_BUILTIN=0` (what will actually happen).
- [BCS1410] Disable features when prerequisites fail: `check_builtin_support || INSTALL_BUILTIN=0` to fail gracefully rather than error out.
- [BCS1410] Execute actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin` runs only if flag is still enabled after all checks.
- [BCS1410] Never modify flags during execution phase; only change them in setup/validation phases to maintain clear separation between decision logic and action.
- [BCS1410] Document state transitions with comments showing how flags change throughout script lifecycle.
