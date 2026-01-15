## Core Message Functions

**Implement standard messaging functions using a private `_msg()` core that detects the calling function via `FUNCNAME` to automatically format messages.**

**Rationale:** Consistent format across scripts; `FUNCNAME` inspection auto-adds prefix/color; DRY via single `_msg()` reused by all wrappers; conditional functions respect `VERBOSE`/`DEBUG`; errors/warnings to stderr, data to stdout; colors/symbols make output scannable.

### FUNCNAME Inspection

The `FUNCNAME` array contains the call stack: `${FUNCNAME[0]}` = current function, `${FUNCNAME[1]}` = caller. Instead of passing a parameter, inspect `FUNCNAME[1]` to auto-detect formatting.

```bash
process_file() {
  info "Processing ${1@Q}"
  # When info() calls _msg():
  #   FUNCNAME[1] = "info"     (determines formatting)
  #   FUNCNAME[2] = "process_file"
}
```

### Core Implementation

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

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

# Conditional output (respects VERBOSE)
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Debug (respects DEBUG)
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# Unconditional error
error()   { >&2 _msg "$@"; }

# Error and exit
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Color Definitions

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

### Flag Variables

```bash
declare -i VERBOSE=0  # Set to 1 for info/warn/success
declare -i DEBUG=0    # Set to 1 for debug
declare -i PROMPT=1   # Set to 0 for automation
```

### Why stdout vs stderr

```bash
data=$(./script.sh)           # Gets only data, not info messages
./script.sh 2>errors.log      # Errors to file, data to stdout
./script.sh | process_data    # Messages visible, data piped
```

### Yes/No Prompt

```bash
yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

### File Logging

Use `printf '%()T'` builtin (Bash 4.2+) instead of `$(date ...)` - 10-50x faster.

**Minimal (single-process):**
```bash
log_msg() {
  printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"
}
```

**Concurrent-safe (multi-process):**
```bash
log_msg() {
  {
    flock -n 9 || return 0
    printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"
  } 9>>"$LOG_FILE"
}
```

### Function Variants

**Minimal (no colors/flags):**
```bash
info()  { >&2 echo "$SCRIPT_NAME: $*"; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Medium (VERBOSE, no colors):**
```bash
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; return 0; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ Wrong - using echo directly (no stderr, no prefix, no color, no VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignoring VERBOSE
info() { >&2 _msg "$@"; }  # Always prints!
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - die without configurable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Wrong - spawns subshell (slow)
log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }
# ✓ Correct - builtin timestamp
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }

# ✗ Wrong - yn() can't disable for automation
yn() { read -r -n 1 -p "$1 y/n " reply; [[ ${reply,,} == y ]]; }
# ✓ Correct - respects PROMPT
yn() { ((PROMPT)) || return 0; local -- REPLY; >&2 read -r -n 1 -p "$SCRIPT_NAME: $1 y/n " REPLY; >&2 echo; [[ ${REPLY,,} == y ]]; }
```

### Edge Cases

1. **Non-terminal output**: Check `[[ -t 1 && -t 2 ]]` before enabling colors
2. **Concurrent logging**: Use `flock` for multi-process scripts to prevent corruption
3. **Automation mode**: `PROMPT=0` makes `yn()` return 0 without prompting

### Summary

- Use `_msg()` with `FUNCNAME` inspection for DRY implementation
- Conditional functions respect `VERBOSE`; `error()` always displays
- Errors to stderr (`>&2`); colors conditional on terminal
- `die()` takes exit code first: `die 1 'Error'`
- `yn()` respects `PROMPT` for non-interactive mode
- Use `printf '%()T'` for logging, not `$(date ...)`
