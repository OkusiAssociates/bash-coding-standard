# Input/Output & Messaging - Rulets
## Stream Separation
- [BCS0702] All error messages must go to STDERR; place `>&2` at the beginning of commands for clarity: `>&2 echo "error message"` rather than `echo "error message" >&2`.
- [BCS0702] Use STDOUT for data output that will be captured or piped; use STDERR for diagnostic/status messages that inform the user.
## Color Support
- [BCS0701] Declare message control flags as integers: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0701] Conditionally define color variables based on terminal detection: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ... NC=$'\033[0m'; else declare -r RED='' ... NC=''; fi`.
- [BCS0701] Always test both stdout AND stderr for terminal (`[[ -t 1 && -t 2 ]]`) before enabling colors.
## Core Message Functions
- [BCS0703] Implement a private `_msg()` core function that inspects `${FUNCNAME[1]}` to automatically determine formatting based on the calling function (info, warn, error, etc.).
- [BCS0703] Conditional output functions (`info`, `warn`, `success`) must check `((VERBOSE)) || return 0` before calling `_msg`.
- [BCS0703] The `error()` function must be unconditional (always displays) and output to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0703] Implement `die()` with exit code as first parameter: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0703] The `debug()` function must respect DEBUG flag: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS0703] Implement `yn()` prompt that respects PROMPT flag for non-interactive mode: `yn() { ((PROMPT)) || return 0; ... }`.
- [BCS0703] Use standard icons in message prefixes: `✓` (success/GREEN), `▲` (warn/YELLOW), `◉` (info/CYAN), `✗` (error/RED).
## Usage Documentation
- [BCS0704] Implement `show_help()` using a here-doc with sections: description, usage line, options (grouped logically), and examples.
- [BCS0704] Include `$SCRIPT_NAME $VERSION` in help header and reference them in usage line and version option description.
- [BCS0704] Group related options visually with blank lines; show both short and long forms: `-v|--verbose`.
## Echo vs Messaging Functions
- [BCS0705] Use messaging functions (`info`, `success`, `warn`, `error`) for operational status updates that should respect verbosity settings and go to stderr.
- [BCS0705] Use plain `echo` for data output to stdout (must be parseable/pipeable), help text, version output, structured reports, and output that must always display.
- [BCS0705] Never use `info()` for data output that needs to be captured—it goes to stderr and respects VERBOSE.
- [BCS0705] Help and version output must use `echo`/`cat`, never messaging functions, so they display regardless of VERBOSE setting.
- [BCS0705] Data-returning functions must use `echo` for output: `get_value() { echo "$result"; }` not `info "$result"`.
## Color Management Library
- [BCS0706] Use a two-tier color system: basic tier (5 variables: NC, RED, GREEN, YELLOW, CYAN) for minimal namespace pollution, complete tier (+7: BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE) when needed.
- [BCS0706] Support three color modes: `auto` (default, checks both stdout AND stderr for TTY), `always` (force on), `never`/`none` (force off).
- [BCS0706] Use the `flags` option to initialize BCS control variables: `color_set complete flags` sets VERBOSE, DEBUG, DRY_RUN, PROMPT.
- [BCS0706] Implement dual-purpose pattern for color libraries: sourceable with optional arguments (`source color-set complete`) and executable for demonstration.
## TUI Basics
- [BCS0707] Always check for terminal before using TUI elements: `if [[ -t 1 ]]; then progress_bar 50 100; else echo '50% complete'; fi`.
- [BCS0707] Hide cursor during TUI operations and restore on exit: `hide_cursor() { printf '\033[?25l'; }; trap 'show_cursor' EXIT`.
- [BCS0707] Use `printf '\r\033[K'` to clear the current line when updating progress indicators.
## Terminal Capabilities
- [BCS0708] Get terminal dimensions dynamically with fallbacks: `TERM_COLS=$(tput cols 2>/dev/null || echo 80)`.
- [BCS0708] Handle terminal resize with WINCH trap: `trap 'get_terminal_size' WINCH`.
- [BCS0708] Check for Unicode support via locale: `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`.
- [BCS0708] Use terminal-aware width for output: `printf '%-*s\n' "${TERM_COLS:-80}" "$text"` not hardcoded widths.
- [BCS0708,BCS0701] Never output raw ANSI escape codes without first checking terminal capability; provide plain text fallback for non-terminals.
