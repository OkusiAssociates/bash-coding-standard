## Core Message Functions

**Every script should implement standard messaging functions using a private `_msg()` core function that inspects `FUNCNAME[1]` to automatically format messages based on the calling function.**

**Rationale:**

- **Consistency**: Same message format across all scripts
- **DRY**: Single `_msg()` implementation reused by all messaging functions
- **Proper Streams**: Errors/warnings to stderr, data to stdout
- **Context**: `FUNCNAME` inspection auto-adds prefix/color
- **Verbosity Control**: Conditional functions respect `VERBOSE` flag
- **User Experience**: Colors and symbols make output scannable

### FUNCNAME Inspection

**The FUNCNAME array** contains the function call stack:
- `${FUNCNAME[0]}` = Current function (`_msg`)
- `${FUNCNAME[1]}` = Calling function (`info`, `warn`, `error`, etc.)

**Why powerful:** Inspecting `FUNCNAME[1]` automatically detects caller, enabling single `_msg()` to format differently per caller without passing parameters.

**Call stack example:**
```bash
main() { process_file "test.txt"; }

process_file() {
  info "Processing $1"
  # When info() calls _msg():
  #   FUNCNAME[0] = "_msg"     (current)
  #   FUNCNAME[1] = "info"     (caller - determines formatting!)
  #   FUNCNAME[2] = "process_file"
}
```

**Implementation:**

```bash
# Private core messaging function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  case "${FUNCNAME[1]}" in
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
```

**Public wrappers:**

```bash
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
die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}
```

**Usage:**

```bash
info 'Starting processing...'
success 'Build completed'
warn 'Config not found, using defaults'
error 'Failed to connect'
debug "Variable state: count=$count"
die 1 'Critical error'
die 22 "File not found: $file"
```

**Stdout vs stderr:**

```bash
# info/warn/error → stderr (>&2)
data=$(./script.sh)              # Gets only data
./script.sh 2>errors.log         # Errors to file
./script.sh | process_data       # Messages visible, data piped
```

**Color definitions:**

```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'
  NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**Flags:**

```bash
declare -i VERBOSE=0  # 1 for info/warn/success
declare -i DEBUG=0    # 1 for debug
declare -i PROMPT=1   # 0 for non-interactive
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DEBUG=0 PROMPT=1

if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC

# Messaging Functions
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
die()     { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }

yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -d|--debug)   DEBUG=1 ;;
    -y|--yes)     PROMPT=0 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done
  readonly -- VERBOSE DEBUG PROMPT

  info "Starting $SCRIPT_NAME $VERSION"
  info 'Processing files...'
  success 'Files processed'
  if yn 'Continue?'; then
    info 'Deploying...'
    success 'Complete'
  else
    warn 'Skipped'
  fi
}

main "$@"
#fin
```

**Simplified version (no colors):**

```bash
_msg() {
  local -- level="${FUNCNAME[1]}"
  printf '[%s] %s: %s\n' "$SCRIPT_NAME" "${level^^}" "$*"
}
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { local -i code=$1; shift; (($#)) && error "$@"; exit "$code"; }
```

**Log to file variant:**

```bash
LOG_FILE="/var/log/$SCRIPT_NAME.log"

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg timestamp
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf '[%s] %s: %s\n' "$timestamp" "${FUNCNAME[1]^^}" "$msg" >> "$LOG_FILE"
  done
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - echo directly (not stderr, no prefix, no color, ignores VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - duplicating logic
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Correct - use _msg with FUNCNAME
_msg() {
  local -- prefix="$SCRIPT_NAME:"
  case "${FUNCNAME[1]}" in
    info)  prefix+=" INFO:" ;;
    warn)  prefix+=" WARN:" ;;
  esac
  echo "$prefix $*"
}
info() { _msg "$@"; }
warn() { _msg "$@"; }

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct - errors to stderr
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignores VERBOSE
info() { >&2 _msg "$@"; }
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - no exit code parameter
die() { error "$@"; exit 1; }
# ✓ Correct
die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }

# ✗ Wrong - yn() ignores PROMPT
yn() {
  local reply
  read -r -n 1 -p "$1 y/n " reply
  [[ ${reply,,} == y ]]
}
# ✓ Correct - respects PROMPT
yn() {
  ((PROMPT)) || return 0
  local reply
  >&2 read -r -n 1 -p "$SCRIPT_NAME: $1 y/n " reply
  >&2 echo
  [[ ${reply,,} == y ]]
}
```

**Function variants:**

**Minimal (no colors/flags):**
```bash
info()  { >&2 echo "[$SCRIPT_NAME] $*"; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { error "$*"; exit "${1:-1}"; }
```

**Medium (VERBOSE, no colors):**
```bash
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "[$SCRIPT_NAME] $*"; return 0; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { local -i code=$1; shift; (($#)) && error "$@"; exit "$code"; }
```

**Summary:** Use `_msg()` with FUNCNAME inspection for DRY. Conditional functions respect `VERBOSE`, unconditional always display. Errors to stderr (`>&2`). Colors conditional on terminal. `die()` takes exit code first. `yn()` respects PROMPT. Remove unused functions per Section 6.
