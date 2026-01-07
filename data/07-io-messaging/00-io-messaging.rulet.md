# Input/Output & Messaging - Rulets
## Color Support and Terminal Detection
- [BCS0701] Declare message control flags as integers at script start: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0701] Conditionally set color variables based on terminal detection: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ... else declare -r RED='' ... fi`.
- [BCS0701,BCS0708] Always check BOTH stdout AND stderr for terminal detection: `[[ -t 1 && -t 2 ]]`, not just `[[ -t 1 ]]`.
## STDOUT vs STDERR Separation
- [BCS0702] All error, warning, and informational messages must go to STDERR; only data output goes to STDOUT.
- [BCS0702] Place `>&2` at the BEGINNING of commands for clarity: `>&2 echo "message"` is preferred over `echo "message" >&2`.
- [BCS0702,BCS0705] Stream separation enables script composition: `data=$(./script.sh)` captures only data, `./script.sh 2>errors.log` separates errors, `./script.sh | process` pipes data while showing messages.
## Core Message Functions
- [BCS0703] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine the calling function and apply appropriate formatting automatically.
- [BCS0703] Standard messaging wrapper functions: `vecho()` (verbose), `success()` (green ✓), `warn()` (yellow ▲), `info()` (cyan ◉), `error()` (red ✗), `debug()` (DEBUG-controlled).
- [BCS0703] Conditional functions must check their flag before output: `info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }`.
- [BCS0703] The `error()` function must be unconditional and always output to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0703] Implement `die()` with exit code as first parameter: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0703] The `yn()` prompt function must respect the PROMPT flag for automation: `yn() { ((PROMPT)) || return 0; ... }`.
- [BCS0703] Never duplicate message logic across functions; use a single `_msg()` implementation with FUNCNAME inspection for DRY compliance.
## Usage Documentation
- [BCS0704] Structure help text with sections: script name/version, brief description, detailed description, Usage line, Options block, Examples.
- [BCS0704] Use heredoc with `cat <<EOT` for help text; never use messaging functions for help output.
- [BCS0704] Include version in help header and provide both `-V|--version` and `-h|--help` options.
## Echo vs Messaging Functions
- [BCS0705] Use messaging functions (`info`, `warn`, `error`) for operational status updates that should respect verbosity settings.
- [BCS0705] Use plain `echo` for data output, help text, structured reports, version output, and any parseable output.
- [BCS0705] Help text and version output must ALWAYS display regardless of VERBOSE setting; use `echo` or `cat`, never `info()`.
- [BCS0705] Functions returning data must use `echo` to stdout, never messaging functions: `get_value() { echo "$result"; }`.
- [BCS0705] Never mix data and status on the same stream; status to stderr via messaging functions, data to stdout via echo.
## Color Management Library
- [BCS0706] Use a two-tier color system: basic (5 variables: NC, RED, GREEN, YELLOW, CYAN) for minimal scripts, complete (12 variables adding BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE) when needed.
- [BCS0706] Provide three color modes: `auto` (detect terminal), `always` (force on), `never` (force off).
- [BCS0706] The `flags` option in color_set integrates with BCS _msg system by setting VERBOSE, DEBUG, DRY_RUN, PROMPT globals.
- [BCS0706] Implement dual-purpose pattern for color libraries: sourceable as library or executable for demonstration.
- [BCS0706] Never scatter inline color declarations across scripts; centralize in a color management library or single declaration block.
## TUI Basics
- [BCS0707] Always check for terminal before using TUI elements: `if [[ -t 1 ]]; then progress_bar 50 100; else echo '50% complete'; fi`.
- [BCS0707] Hide cursor during TUI operations and restore on exit: `hide_cursor() { printf '\033[?25l'; }; trap 'show_cursor' EXIT`.
- [BCS0707] Use ANSI escape sequences for cursor control: `\033[?25l` (hide), `\033[?25h` (show), `\033[2K\r` (clear line), `\033[%dA` (move up).
## Terminal Capabilities
- [BCS0708] Get terminal dimensions dynamically and update on resize: `trap 'get_terminal_size' WINCH`.
- [BCS0708] Use `tput` for capability checking with fallbacks: `tput cols 2>/dev/null || echo 80`.
- [BCS0708] Check for Unicode support via locale: `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`.
- [BCS0708] Never hardcode terminal width; use `${TERM_COLS:-80}` with dynamic detection.
- [BCS0708] Provide graceful fallbacks for limited terminals; never assume color or cursor control support.
