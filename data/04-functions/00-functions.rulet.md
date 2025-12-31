# Functions & Libraries - Rulets

## Function Definition Pattern

- [BCS0401] Use single-line format for simple functions: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0401] Multi-line functions must declare local variables with type at function start: `local -i exitcode=0` for integers, `local -- variable` for strings.
- [BCS0401] Always return explicit exit codes: `return "$exitcode"` or `return 0`.

## Function Naming

- [BCS0402] Use lowercase with underscores for function names: `process_log_file()` not `ProcessLogFile()`.
- [BCS0402] Prefix private/internal functions with underscore: `_validate_input()`.
- [BCS0402] Never override built-in commands; use alternative names: `change_dir()` not `cd()`.
- [BCS0402] Avoid dashes in function names: `my_function()` not `my-function()`.

## Main Function

- [BCS0403] Always include `main()` function for scripts exceeding ~200 lines.
- [BCS0403] Place `main "$@"` at script bottom, just before `#fin` marker.
- [BCS0403] Parse all arguments inside `main()`, not at global scope.
- [BCS0403] Declare option variables as local in main: `local -i verbose=0; local -- output_file=''`
- [BCS0403] Make parsed options readonly after parsing: `readonly -- verbose dry_run output_file`
- [BCS0403] Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"` pattern for testable scripts.
- [BCS0403] Main orchestrates; heavy lifting belongs in helper functions called by main.
- [BCS0403] Track errors using counters: `local -i errors=0` then `((errors+=1))` on failures.
- [BCS0403] Use `trap cleanup EXIT` at main start for guaranteed cleanup.
- [BCS0403] Never define functions after `main "$@"` call; never parse arguments in global scope.
- [BCS0403] Never call main without `"$@"`: use `main "$@"` not `main`.

## Function Export

- [BCS0404] Export functions for subshell access with `declare -fx`: `grep() { /usr/bin/grep "$@"; }; declare -fx grep`
- [BCS0404] Group related function exports: `declare -fx func1 func2 func3`

## Production Optimization

- [BCS0405] Remove unused utility functions from mature production scripts.
- [BCS0405] Remove unused global variables and messaging functions not called by script.
- [BCS0405] Keep only functions and variables the script actually needs; a simple script may only need `error()` and `die()`.

## Dual-Purpose Scripts

- [BCS0406] Define all functions BEFORE `set -euo pipefail` in dual-purpose scripts.
- [BCS0406] Use source-mode exit after function definitions: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`
- [BCS0406] Place `set -euo pipefail` AFTER the source check, never before.
- [BCS0406] Export all library functions: `my_func() { :; }; declare -fx my_func`
- [BCS0406] Use idempotent initialization to prevent double-loading: `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION='1.0.0'`

## Library Patterns

- [BCS0407] Pure libraries should reject execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || { echo "Must be sourced" >&2; exit 1; }`
- [BCS0407] Declare library version: `declare -rx LIB_VALIDATION_VERSION='1.0.0'`
- [BCS0407] Use namespace prefixes for all functions: `myapp_init()`, `myapp_cleanup()`, `myapp_process()`
- [BCS0407] Libraries should only define functions on source; explicit init call for side effects: `source lib.sh; lib_init`
- [BCS0407] Source libraries with existence check: `[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing: $lib_path"`

## Dependency Management

- [BCS0408] Check dependencies with `command -v`, never `which`: `command -v curl >/dev/null || die 1 'curl required'`
- [BCS0408] Collect missing dependencies for helpful error messages: `local -a missing=(); for cmd in curl jq; do command -v "$cmd" >/dev/null || missing+=("$cmd"); done`
- [BCS0408] Check Bash version when using modern features: `((BASH_VERSINFO[0] >= 5)) || die 1 "Requires Bash 5+"`
- [BCS0408] Use availability flags for optional features: `declare -i HAS_JQ=0; command -v jq >/dev/null && HAS_JQ=1`
- [BCS0408] Lazy-load expensive resources only when needed.

## Function Organization

- [BCS0400] Organize functions bottom-up: messaging first, then helpers, then business logic, with `main()` last.
- [BCS0400] Each function should safely call only previously-defined functions above it.
