## Core Message Functions

**Implement a private `_msg()` core function using `FUNCNAME[1]` inspection to automatically format messages based on caller.**

**Rationale:**
- **DRY/Consistent**: Single `_msg()` reused by all wrappers; impossible to pass wrong level
- **Context-aware**: `FUNCNAME[1]` detects caller automatically (info, warn, error, etc.)
- **Stream separation**: Errors/warnings to stderr, data to stdout (enables `data=$(./script)`)
- **Flag control**: `VERBOSE` controls info/warn/success; `DEBUG` controls debug; `PROMPT` controls yn()

### FUNCNAME Array

```bash
# FUNCNAME[0] = current function (_msg)
# FUNCNAME[1] = calling function (determines formatting!)
# FUNCNAME[2+] = higher call stack

process_file() {
  info "Processing ${1@Q}"
  # When info() calls _msg():
  #   FUNCNAME[1] = "info" �' cyan ◉ prefix
}
```

### Core Implementation

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  case ${FUNCNAME[1]} in
    vecho)   ;;
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

# Conditional (respect VERBOSE)
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Debug (respects DEBUG)
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# Unconditional
error()   { >&2 _msg "$@"; }

# Error and exit
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Yes/no prompt (respects PROMPT)
yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
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
declare -i VERBOSE=0  # 1 = show info/warn/success
declare -i DEBUG=0    # 1 = show debug messages
declare -i PROMPT=1   # 0 = disable prompts (automation)
```

### Usage

```bash
info 'Starting processing...'          # Only if VERBOSE=1
success "Installed to $PREFIX"         # Only if VERBOSE=1
warn "Deprecated: $old_option"         # Only if VERBOSE=1
error "Invalid file: $filename"        # Always shown
debug "count=$count, file=$file"       # Only if DEBUG=1
die 1 'Critical error'                 # Exit with code and message
die 22 "File not found ${file@Q}"      # Exit code 22
die 1                                  # Exit without message
```

### Variant: Log to File

```bash
LOG_FILE=/var/log/"$SCRIPT_NAME".log

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg timestamp

  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf '[%s] %s: %s\n' "$timestamp" "${FUNCNAME[1]^^}" "$msg" >> "$LOG_FILE"
  done
}
```

### Minimal Variants

```bash
# No colors, no flags
info()  { >&2 echo "$SCRIPT_NAME: $*"; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# With VERBOSE, no colors
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; return 0; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ Wrong - echo directly (no stderr, prefix, colors, VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - duplicating logic in each function
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Correct - use _msg core with FUNCNAME

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignoring VERBOSE (always prints)
info() { >&2 _msg "$@"; }
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - die without customizable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Wrong - yn() can't disable prompts
yn() { read -r -n 1 -p "$1 y/n " reply; [[ ${reply,,} == y ]]; }
# ✓ Correct - respects PROMPT flag
yn() { ((PROMPT)) || return 0; ...; }
```

### Edge Cases

1. **Non-terminal output**: Colors disabled via `[[ -t 1 && -t 2 ]]` check
2. **Piping data**: `data=$(./script)` captures only stdout; messages go to stderr
3. **Automation**: Set `PROMPT=0` to skip yn() prompts
