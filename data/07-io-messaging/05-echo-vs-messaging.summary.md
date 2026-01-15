## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context and output destination. Messaging functions for operational status (stderr, respects verbosity); plain `echo` for data output (stdout, always displays).**

**Rationale:**
- **Stream Separation**: Messaging â†' stderr (user-facing); `echo` â†' stdout (parseable data)
- **Verbosity Control**: Messaging respects `VERBOSE`; `echo` always displays
- **Parseability**: Plain `echo` is predictable; messaging includes formatting/colors
- **Script Composition**: Proper streams enable pipelines without mixing data and status

**Use messaging functions (`info`, `success`, `warn`, `error`):**

```bash
# Operational status updates
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'

# Diagnostic/debug output
debug "Variable state: count=$count, total=$total"
info "Using configuration file ${config_file@Q}"
```

**Use plain `echo`:**

```bash
# Data output from functions
get_user_email() {
  local -- username=$1
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')

# Help text (always displays, never verbose-dependent)
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}

# Structured reports and parseable output
generate_report() {
  echo 'System Report'
  echo '============='
  df -h
}
```

**Decision matrix:**
- Operational status or data? Status â†' messaging; Data â†' echo
- Respect verbosity? Yes â†' messaging; No â†' echo
- Parsed/piped? Yes â†' echo to stdout; No â†' messaging to stderr
- Multi-line formatted? Yes â†' echo/here-doc; No â†' messaging (single-line)
- Need color/formatting? Yes â†' messaging; No â†' echo

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=1 DEBUG=0

# Colors (conditional on terminal)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Data function (stdout, always output)
get_user_home() {
  local -- username=$1
  local -- home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -n "$home_dir" ]] || return 1
  echo "$home_dir"  # Data to stdout
}

main() {
  local -- username=$1
  local -- user_home

  info "Looking up user ${username@Q}"  # Status to stderr

  if ! user_home=$(get_user_home "$username"); then
    error "User not found ${username@Q}"
    return 1
  fi

  success "Found user ${username@Q}"
  echo "Home: $user_home"  # Data to stdout
}

main "$@"
```

**Anti-patterns:**

```bash
# âœ— Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email alice)  # $email is empty!

# âœ“ Correct - use echo for data
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# âœ— Wrong - using echo for operational status
process_file() {
  echo "Processing ${file@Q}..."  # Mixes with data on stdout!
  cat "$file"
}

# âœ“ Correct - messaging for status
process_file() {
  info "Processing ${file@Q}..."  # To stderr
  cat "$file"                     # Data to stdout
}

# âœ— Wrong - help text using info() (won't display if VERBOSE=0)
show_help() {
  info 'Usage: script.sh [OPTIONS]'
}

# âœ“ Correct - help text using cat
show_help() {
  cat <<HELP
Usage: script.sh [OPTIONS]
  -v  Verbose mode
HELP
}

# âœ— Wrong - error messages to stdout
if [[ ! -f "$1" ]]; then
  echo "File not found ${1@Q}"  # Wrong stream!
fi

# âœ“ Correct - errors to stderr
if [[ ! -f "$1" ]]; then
  error "File not found ${1@Q}"
fi
```

**Edge cases:**

**1. Version output (always display):**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo, not info()
}
```

**2. Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'     # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"              # Data to stdout
  done
  success 'Complete'            # Status to stderr
}
data=$(generate_data)  # Captures only data
```

**3. Logging vs user messages:**
```bash
process_item() {
  local -- item=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log to stdoutâ†'file
  info "Processing $item..."                                # User message to stderr
}
process_item "$item" >> "$log_file"
```

**Key principle:** Stream separation determines the choice. Operational messages (how script works) â†' stderr via messaging. Data output (what script produces) â†' stdout via echo. This enables proper piping, capturing, and redirection while keeping users informed.
