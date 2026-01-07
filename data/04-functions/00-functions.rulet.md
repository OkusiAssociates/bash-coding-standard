# Functions - Rulets
## Section Overview
- [BCS0400] Organize functions bottom-up: messaging functions first, then helpers, then business logic, with `main()` last—each function can safely call previously defined functions.
## Function Definition Pattern
- [BCS0401] Use single-line format for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0401] Use multi-line format with local variables for complex functions; always `return "$exitcode"` explicitly.
- [BCS0401] Declare local variables at function start with `local -i` for integers and `local --` for strings.
## Function Names
- [BCS0402] Use lowercase with underscores for function names: `process_log_file()` not `ProcessLogFile()` or `PROCESS_FILE()`.
- [BCS0402] Prefix private/internal functions with underscore: `_validate_input()`, `_my_private_function()`.
- [BCS0402] Never override built-in commands without good reason; if wrapping built-ins, use a different name: `change_dir()` not `cd()`.
- [BCS0402] Never use dashes in function names: `my_function()` not `my-function()`.
## Main Function
- [BCS0403] Always include a `main()` function for scripts longer than ~200 lines; place `main "$@"` at the bottom just before `#fin`.
- [BCS0403] Parse arguments inside `main()`, not at script level; make parsed option variables readonly after parsing.
- [BCS0403] Always call main with all arguments: `main "$@"` never just `main`.
- [BCS0403] Define all helper functions before `main()` so they exist when main executes.
- [BCS0403] For testable scripts, use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `set -euo pipefail` to allow sourcing.
- [BCS0403] Use `trap cleanup EXIT` in main for setup/cleanup patterns with temporary resources.
- [BCS0403] Return appropriate exit codes from main: `((error_count == 0))` for boolean success/failure.
## Function Export
- [BCS0404] Export functions needed by subshells using `declare -fx`: `declare -fx grep find my_function`.
- [BCS0404] Define function first, then export: `my_func() { :; }; declare -fx my_func`.
## Production Optimization
- [BCS0405] Remove unused utility functions from production scripts: if `yn()`, `trim()`, `debug()` are not called, delete them.
- [BCS0405] Remove unused global variables: if `SCRIPT_DIR`, `DEBUG`, `PROMPT` are not referenced, delete them.
- [BCS0405] Keep only functions and variables the script actually needs to reduce size and maintenance burden.
## Dual-Purpose Scripts
- [BCS0406] For dual-purpose scripts, define functions before any `set -e`, then check `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before enabling strict mode.
- [BCS0406] Place `set -euo pipefail` AFTER the sourced check, not before—library code should not impose error handling on caller.
- [BCS0406] Use idempotent initialization with version guard: `[[ -v MY_LIB_VERSION ]] || { declare -rx MY_LIB_VERSION=1.0.0; ... }`.
- [BCS0406] Export all functions intended for use when sourced: `my_function() { :; }; declare -fx my_function`.
## Library Patterns
- [BCS0407] Pure libraries must reject execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || { >&2 echo 'Error: must be sourced'; exit 1; }`.
- [BCS0407] Define library version as readonly export: `declare -rx LIB_VALIDATION_VERSION=1.0.0`.
- [BCS0407] Use namespace prefixes for all library functions to avoid conflicts: `myapp_init()`, `myapp_cleanup()`, `myapp_process()`.
- [BCS0407] Allow configuration override before sourcing: `: "${CONFIG_DIR:=/etc/myapp}"`.
- [BCS0407] Libraries should only define functions, not have side effects on source; use explicit initialization calls.
- [BCS0407] Source libraries with existence check: `[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library"`.
## Dependency Management
- [BCS0408] Use `command -v` for dependency checks, never `which`: `command -v curl >/dev/null || die 1 'curl required'`.
- [BCS0408] Check multiple dependencies in a loop: `for cmd in curl jq awk; do command -v "$cmd" >/dev/null || die 1 "Required ${cmd@Q}"; done`.
- [BCS0408] For optional dependencies, set availability flag: `declare -i HAS_JQ=0; command -v jq >/dev/null && HAS_JQ=1 ||:`.
- [BCS0408] Check Bash version at script start: `((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)) || die 1 'Requires Bash 5.2+'`.
- [BCS0408] Provide helpful error messages for missing dependencies: `die 1 'curl required: apt install curl'`.
- [BCS0408] Use lazy loading for expensive resources: initialize only when first needed, not at script start.
