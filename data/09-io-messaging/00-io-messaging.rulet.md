# Input/Output & Messaging - Rulets

## Color Support

- [BCS0901] Detect terminal output before enabling colors: test both stdout AND stderr with `[[ -t 1 && -t 2 ]]`, then declare color variables or set them to empty strings.
- [BCS0901] Always make color variables readonly after initialization: `readonly -- RED GREEN YELLOW CYAN NC`.
- [BCS0901] Use ANSI escape codes with `$'\033[0;31m'` syntax for color definitions, not `\e` or `\x1b`.

## Stream Separation

- [BCS0902] Always send error messages to stderr by placing `>&2` at the beginning of the command for clarity: `>&2 echo "error message"`.
- [BCS0902] Separate data output (stdout) from diagnostic messages (stderr) so scripts can be piped without mixing streams.

## Core Message Functions

- [BCS0903] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine the calling function and format messages with appropriate prefixes and colors automatically.
- [BCS0903] Create conditional messaging functions that respect verbosity flags: `vecho()`, `info()`, `warn()`, `success()`, and `debug()` should check `((VERBOSE))` or `((DEBUG))` before outputting.
- [BCS0903] Always make `error()` unconditional (always displays) and send to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0903] Implement `die()` with exit code as first parameter: `die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }`.
- [BCS0903] Send all conditional messaging functions (info, warn, success, debug) to stderr with `>&2` prefix so they don't interfere with data output.
- [BCS0903] Use consistent prefixes in all messages: include `$SCRIPT_NAME` and appropriate symbols (, ², É, ).
- [BCS0903] Implement `yn()` prompt function that respects `PROMPT` flag: `((PROMPT)) || return 0` for non-interactive mode.
- [BCS0903] Declare global control flags with integer type: `declare -i VERBOSE=0 DEBUG=0 PROMPT=1`.

## _msg Function Pattern

- [BCS0903] Use `case "${FUNCNAME[1]}" in` within `_msg()` to detect calling function and set appropriate prefix/color without duplicating logic across functions.
- [BCS0903] Loop through all arguments in `_msg()` to print each on a separate line: `for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done`.

## Usage Documentation

- [BCS0904] Create help text using heredocs with `cat <<EOT` for multi-line formatted output that always displays.
- [BCS0904] Include script name, version, description, usage pattern, options with short/long forms, and examples in help text.
- [BCS0904] Reference `$SCRIPT_NAME` and `$VERSION` variables in help text for consistency.

## Echo vs Messaging Functions

- [BCS0905] Use messaging functions (`info`, `success`, `warn`, `error`) for operational status updates that should respect verbosity settings and go to stderr.
- [BCS0905] Use plain `echo` for data output (stdout) that will be captured, piped, or parsed: `result=$(get_data)`.
- [BCS0905] Use plain `echo` or `cat` for help text and documentation that must always display regardless of verbosity settings.
- [BCS0905] Use plain `echo` for structured multi-line output like reports, tables, or formatted data.
- [BCS0905] Never use messaging functions (`info`, `warn`) for data that needs to be captured or piped; they go to stderr and won't be captured by command substitution.
- [BCS0905] Use `echo` for version output and final summary results that users explicitly requested.
- [BCS0905] Use messaging functions for progress indicators during data generation (go to stderr), while actual data goes to stdout via `echo`.

## Decision Matrix

- [BCS0905] If output is operational status or diagnostics ’ use messaging functions to stderr.
- [BCS0905] If output is data intended for capture/piping ’ use `echo` to stdout.
- [BCS0905] If output should respect verbosity flags ’ use messaging functions.
- [BCS0905] If output must always display ’ use `echo` (or `error()` for critical messages).
- [BCS0905] If output needs color/formatting/symbols ’ use messaging functions.

## Color Management Library

- [BCS0906] For sophisticated color management, use a dedicated library with two-tier system (basic 5 variables, complete 12 variables) instead of inline declarations.
- [BCS0906] Implement basic tier with: `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN` (default to minimize namespace pollution).
- [BCS0906] Implement complete tier with basic plus: `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE` (opt-in).
- [BCS0906] Provide `color_set` function with options: `basic`, `complete`, `auto`, `always`, `never`, `verbose`, `flags`.
- [BCS0906] Use `flags` option to initialize BCS control variables: `VERBOSE`, `DEBUG`, `DRY_RUN`, `PROMPT` for _msg system integration.
- [BCS0906] Implement dual-purpose pattern (BCS010201) in color library: sourceable as library or executable for demonstration.
- [BCS0906] Auto-detect terminal by testing both stdout AND stderr: `[[ -t 1 && -t 2 ]]` before enabling colors.
- [BCS0906] Export `color_set` function with `declare -fx color_set` for use in sourced mode.

## Production Optimization

- [BCS0903,BCS0905] Remove unused messaging functions before production deployment: if script never uses `yn()`, `debug()`, or `success()`, delete them to reduce script size.
- [BCS0903] Remove unused global control flags (PROMPT, DEBUG) if the script doesn't reference them.
