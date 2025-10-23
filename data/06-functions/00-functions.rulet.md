# Functions - Rulets
## Function Definition Pattern
- [BCS0601] Use single-line functions for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0601] Use multi-line functions with local variables for complex operations, always declaring locals at the top of the function body.
- [BCS0601] Always return explicit exit codes from functions: `return "$exitcode"` not implicit returns.
## Function Naming
- [BCS0602] Always use lowercase_with_underscores for function names to match shell conventions and avoid conflicts with built-in commands.
- [BCS0602] Prefix private/internal functions with underscore: `_my_private_function()`, `_validate_input()`.
- [BCS0602] Never use CamelCase or UPPER_CASE for function names; avoid special characters like dashes.
- [BCS0602] Never override built-in commands unless absolutely necessary; if you must wrap built-ins, use a different name: `change_dir()` not `cd()`.
## Main Function
- [BCS0603] Always include a `main()` function for scripts longer than approximately 200 lines; place `main "$@"` at the bottom just before `#fin`.
- [BCS0603] Use `main()` as the single entry point to orchestrate script logic: parsing arguments, validating input, calling helper functions in the right order, and returning appropriate exit codes.
- [BCS0603] Parse command-line arguments inside `main()`, not in global scope; make parsed option variables readonly after validation.
- [BCS0603] Place `main()` function definition at the end of the script after all helper functions are defined; this ensures bottom-up function organization.
- [BCS0603] For testable scripts, use conditional invocation: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` to prevent execution when sourced.
- [BCS0603] Skip `main()` function only for trivial scripts (<200 lines) with no functions, linear flow, or simple wrappers.
## Function Organization
- [BCS0603,BCS0107] Organize functions bottom-up: messaging functions first (lowest level), then documentation/helpers, then validation, then business logic, then orchestration, with `main()` last (highest level).
- [BCS0603] Separate script into clear sections with comment dividers: messaging functions, documentation functions, helper functions, business logic functions, main function.
## Function Export
- [BCS0604] Export functions with `declare -fx` when they need to be available in subshells or when creating sourceable libraries.
- [BCS0604] Batch export related functions together: `declare -fx grep find` after defining wrapper functions.
## Production Optimization
- [BCS0605] Remove unused utility functions from mature production scripts: if `yn()`, `decp()`, `trim()`, `s()` are not called, delete them.
- [BCS0605] Remove unused global variables from production scripts: if `PROMPT`, `DEBUG` are not referenced, delete them.
- [BCS0605] Remove unused messaging functions your script doesn't call; keep only what your script actually needs to reduce size and improve clarity.
- [BCS0605] Simple scripts may only need `error()` and `die()`, not the full messaging suite; optimize accordingly.
## Error Handling in Main
- [BCS0603] Track errors in `main()` using counters: `local -i errors=0` then `((errors+=1))` on failures; return non-zero if `((errors > 0))`.
- [BCS0603] Use trap for cleanup in `main()`: `trap cleanup EXIT` at the start ensures cleanup happens on any exit path.
- [BCS0603] Make `main()` return 0 for success and non-zero for errors to enable `main "$@"` invocation at script level with `set -e`.
## Main Function Anti-Patterns
- [BCS0603] Never define functions after calling `main "$@"`; all functions must be defined before the main invocation.
- [BCS0603] Never parse arguments outside `main()` in global scope; this consumes `"$@"` before main receives it.
- [BCS0603] Never call main without passing arguments: use `main "$@"` not `main` to preserve all command-line arguments.
- [BCS0603] Never mix global and local state unnecessarily; prefer all logic and variables local to `main()` for clean scope.
