# Input/Output & Messaging

Standardized messaging patterns with color support and proper stream handling. Core functions: `_msg()` (FUNCNAME-based), `vecho()`, `success()`, `warn()`, `info()`, `debug()`, `error()`, `die()`, `yn()`.

## STDOUT vs STDERR

- Error/status messages �' STDERR; data output �' STDOUT
- Place `>&2` at command beginning for clarity

```bash
somefunc() { >&2 echo "[$(date -Ins)]: $*"; }
```

## Standardized Messaging and Color Support

```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

## Core Message Functions

Use private `_msg()` with `FUNCNAME[1]` inspection for DRY implementation.

**FUNCNAME array:** `${FUNCNAME[0]}`=current, `${FUNCNAME[1]}`=caller. Auto-detects caller for formatting without parameters.

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**File logging (use printf builtin, not date subshell):**

```bash
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }

# Concurrent-safe:
log_msg() {
  { flock -n 9 || return 0; printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"; } 9>>"$LOG_FILE"
}
```

## Usage Documentation

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}
```

## Echo vs Messaging Functions

| Context | Use |
|---------|-----|
| Operational status | Messaging functions (stderr) |
| Data output | `echo` (stdout) |
| Help/version text | `echo`/`cat` (always display) |
| Pipeable/parseable | `echo` (stdout) |
| Respects VERBOSE | Messaging functions |

```bash
# Data output - use echo
get_user_email() { echo "$email"; }

# Status - use messaging functions
info "Processing ${file@Q}..."
cat "$file"
```

**Anti-patterns:**

```bash
# ✗ Wrong - info() for data (goes to stderr, can't capture)
get_value() { info "$value"; }

# ✗ Wrong - echo for status (mixes with data in pipes)
echo "Processing..."

# ✗ Wrong - help with info() (won't show if VERBOSE=0)
show_help() { info 'Usage:...'; }
```

## Color Management Library

Two-tier system for namespace control. Source `color-set` library for sophisticated needs.

**Basic tier (5 vars):** `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN`
**Complete tier (+7):** `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE`

```bash
source color-set complete flags  # One-line init for colors + _msg globals
```

Options: `basic`|`complete`, `auto`|`always`|`never`, `verbose`, `flags`

## TUI Basics (BCS0907)

```bash
# Spinner
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while ((1)); do
    printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"
    i+=1; sleep 0.1
  done
}
spinner 'Processing...' &
spinner_pid=$!
# ... work ...
kill "$spinner_pid" 2>/dev/null; printf '\r\033[K'

# Progress bar
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local -- bar
  bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' "$((width - filled))" '' | tr ' ' '░')
  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}

# Cursor control
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
trap 'show_cursor' EXIT
```

## Terminal Capabilities (BCS0908)

```bash
# Detect terminal
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with resize trap
get_terminal_size() {
  if [[ -t 1 ]]; then
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
  else
    TERM_COLS=80; TERM_ROWS=24
  fi
}
trap 'get_terminal_size' WINCH

# Unicode check
has_unicode() { [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]; }
```

**Anti-patterns:**

```bash
# ✗ Wrong - TUI without terminal check
progress_bar 50 100  # Garbage if not terminal

# ✓ Correct
[[ -t 1 ]] && progress_bar 50 100 || echo '50% complete'

# ✗ Wrong - hardcoded width
printf '%-80s\n' "$text"

# ✓ Correct
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

## Key Anti-Patterns Summary

```bash
# ✗ echo directly for errors
echo "Error: file not found"
# ✓ Use messaging function
error 'File not found'

# ✗ Duplicate message logic
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Use _msg core function

# ✗ Errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Errors to stderr
error() { >&2 _msg "$@"; }

# ✗ die without customizable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Subshell for timestamp (slow)
log_msg() { echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"; }
# ✓ Builtin (10-50x faster)
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }
```

**Key principles:**
- Stream separation: status�'stderr, data�'stdout
- FUNCNAME inspection eliminates duplication
- Conditional functions respect VERBOSE/DEBUG flags
- Colors conditional on `[[ -t 1 && -t 2 ]]`
- Use printf `%()T` for timestamps, not date subshell
