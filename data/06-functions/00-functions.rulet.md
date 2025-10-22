# Functions - Rulets

## Function Definition Pattern

- [BCS0601] Use single-line format for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`.
- [BCS0601] Use multi-line format with local variables for complex functions: declare locals first, then function body, then explicit return.

## Function Naming

- [BCS0602] Always use lowercase with underscores for function names to match shell conventions: `my_function()`, `process_log_file()`.
- [BCS0602] Use leading underscore for private/internal functions: `_my_private_function()`, `_validate_input()`.
- [BCS0602] Never use CamelCase or UPPER_CASE for function names; this can be confused with variables or commands.
- [BCS0602] Never override built-in commands without good reason; if you must wrap built-ins, use a different name like `change_dir()` instead of `cd()`.
- [BCS0602] Never use special characters like dashes in function names: `my-function()` creates issues in some contexts.

## Main Function

- [BCS0603] Always include a `main()` function for scripts longer than approximately 200 lines to improve organization, testability, and maintainability.
- [BCS0603] Place `main "$@"` at the bottom of the script, just before the `#fin` marker, to ensure all helper functions are defined first.
- [BCS0603] Parse command-line arguments inside `main()` using local variables, not outside it with globals: `local -i verbose=0; while (($#)); do case $1 in -v) verbose=1 ;; esac; shift; done`.
- [BCS0603] Make parsed option variables readonly after parsing to prevent accidental modification: `readonly -- verbose dry_run output_dir`.
- [BCS0603] Use `main()` as the orchestrator that coordinates work by calling helper functions in the right order, not by doing the heavy lifting itself.
- [BCS0603] Return appropriate exit codes from `main()`: 0 for success, non-zero for errors.
- [BCS0603] Use `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` pattern to make scripts sourceable for testing without automatic execution.
- [BCS0603] Always pass all arguments to main with `main "$@"`, never call it without arguments.

## Function Export

- [BCS0604] Export functions with `declare -fx` when they need to be available in subshells or when creating sourceable libraries.
- [BCS0604] Group function exports together for readability: `declare -fx grep find` for multiple related functions.

## Production Optimization

- [BCS0605] Remove unused utility functions once a script is mature and ready for production: if `yn()`, `decp()`, `trim()`, `s()` are not used, delete them.
- [BCS0605] Remove unused global variables that are not referenced: `PROMPT`, `DEBUG`, color variables if terminal output is not used.
- [BCS0605] Remove unused messaging functions that your script doesn't call; a simple script may only need `error()` and `die()`, not the full messaging suite.
- [BCS0605] Keep only the functions and variables your script actually needs to reduce script size, improve clarity, and eliminate maintenance burden.

## Function Organization

- [BCS0600,BCS0603] Organize functions bottom-up: messaging functions first (lowest level), then helpers, then business logic, with `main()` last (highest level).
- [BCS0600,BCS0603] This bottom-up organization ensures each function can safely call previously defined functions and readers understand primitives before composition.
