# Input/Output & Messaging - Rulets
## Color Support
- [BCS0901] Declare global flags for messaging control: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0901] Only initialize color variables when both stdout and stderr are terminals: `if [[ -t 1 && -t 2 ]]; then` set colors, `else` set empty strings.
- [BCS0901] Use ANSI escape sequences in `$'...'` format for colors: `RED=$'\033[0;31m'`, `GREEN=$'\033[0;32m'`, `YELLOW=$'\033[0;33m'`, `CYAN=$'\033[0;36m'`, `NC=$'\033[0m'`.
- [BCS0901] Always make color variables readonly after initialization: `readonly -- RED GREEN YELLOW CYAN NC`.
## Stream Handling
- [BCS0902] All error messages must go to stderr, not stdout.
- [BCS0902] Place `>&2` at the beginning of commands for clarity: `>&2 echo "error message"` not `echo "error message" >&2`.
## Core Messaging Functions
- [BCS0903] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine formatting and prefix based on the calling function name.
- [BCS0903] Use `_msg()` as the single source of message formatting logic; all public messaging functions (`info`, `warn`, `error`, `success`, `debug`) should call `_msg()` to avoid duplication.
- [BCS0903] Conditional messaging functions (`vecho`, `info`, `warn`, `success`) must check the VERBOSE flag and return early if not enabled: `((VERBOSE)) || return 0`.
- [BCS0903] Debug output function must check DEBUG flag: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS0903] Error messages must always display regardless of verbosity: `error() { >&2 _msg "$@"; }`.
- [BCS0903] The `die()` function must accept exit code as first parameter, then optional message arguments: `die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }`.
- [BCS0903] Use symbol prefixes in messages for visual scanning: `✓` (success), `▲` (warning), `◉` (info), `✗` (error), `DEBUG:` (debug).
- [BCS0903] Send all operational messages to stderr using `>&2`: `success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }`.
- [BCS0903] The `yn()` prompt function must respect the PROMPT flag for non-interactive mode: `((PROMPT)) || return 0`.
- [BCS0903] Format `_msg()` case statement to detect calling function: `case "${FUNCNAME[1]}" in success) prefix+=" ${GREEN}✓${NC}" ;; ... esac`.
## Usage Documentation
- [BCS0904] Use here-documents for help text with `cat <<EOT` containing usage, options, and examples.
- [BCS0904] Include script name and version in help output: `$SCRIPT_NAME $VERSION - Brief description`.
- [BCS0904] Document all options with both short and long forms: `-v|--verbose`, `-h|--help`.
- [BCS0904] Provide concrete examples section showing common use cases.
## Echo vs Messaging Functions
- [BCS0905] Use messaging functions (`info`, `warn`, `error`, `success`) for operational status updates that should go to stderr and respect verbosity settings.
- [BCS0905] Use plain `echo` for data output to stdout, help text, structured reports, and output that must always display regardless of verbosity.
- [BCS0905] Never use messaging functions for data output that will be captured or piped: use `echo` to stdout instead.
- [BCS0905] Use `echo` with here-documents for multi-line formatted output like help text or reports, not multiple messaging function calls.
- [BCS0905] Functions that return data must use `echo` to stdout: `get_value() { echo "$result"; }` not `info "$result"`.
- [BCS0905] Separate operational messages (stderr via messaging functions) from data output (stdout via echo) to enable proper script composition and piping.
- [BCS0905] Version and help output should use `echo` (always display), never messaging functions that respect VERBOSE.
## Color Management Library
- [BCS0906] For scripts requiring sophisticated color management beyond inline declarations, use a dedicated color management library with basic (5 variables) and complete (12 variables) tiers.
- [BCS0906] Implement `color_set()` function supporting options: `basic` (default 5 colors), `complete` (12 colors), `auto` (terminal detection), `always` (force on), `never` (force off), `verbose` (show declarations), `flags` (set BCS globals).
- [BCS0906] Basic tier provides: `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN`; complete tier adds: `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE`.
- [BCS0906] Auto-detection must test both stdout AND stderr are terminals: `[[ -t 1 && -t 2 ]] && color=1 || color=0`.
- [BCS0906] The `flags` option should initialize BCS messaging control variables: `VERBOSE=${VERBOSE:-1}`, and with complete tier: `DEBUG=0 DRY_RUN=1 PROMPT=1`.
- [BCS0906] Implement dual-purpose pattern so library can be sourced (`source color-set.sh && color_set complete`) or executed for demonstration (`./color-set.sh complete verbose`).
- [BCS0906] Export the `color_set` function for library usage: `declare -fx color_set`.
