## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context, formatting, and output destination. Use messaging functions for operational status (respects verbosity), plain `echo` for data output (must always display).**

**Rationale:**
- **Stream Separation**: Messagingâ†'stderr (user-facing), `echo`â†'stdout (parseable data)
- **Verbosity Control**: Messaging respects `VERBOSE`; `echo` always displays
- **Script Composition**: Proper streams allow pipeline use without mixing data/status
- **Parseability**: Plain `echo` is predictable; messaging includes formatting

**When to use messaging functions (`info`, `success`, `warn`, `error`):**

```bash
# Operational status updates (stderr, verbosity-controlled)
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'

# Diagnostic/debug output
debug "Variable state: count=$count, total=$total"
info "Using configuration file ${config_file@Q}"
```

**When to use plain `echo`:**

```bash
# 1. Data output (stdout) - functions returning values
get_user_email() {
  local -- username=$1
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')

# 2. Help text and documentation
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}

# 3. Structured reports and parseable output
generate_report() {
  echo 'System Report'
  echo '============='
  df -h
}

# 4. Output that must always display (version, results)
echo "$SCRIPT_NAME $VERSION"
echo "Processed $success_count files successfully"
```

**Decision matrix:**
- Status vs Data? Statusâ†'messaging, Dataâ†'echo
- Respect verbosity? Yesâ†'messaging, Noâ†'echo
- Parsed/piped? Yesâ†'echo to stdout
- Multi-line formatted? Yesâ†'echo/here-doc
- Needs color/formatting? Yesâ†'messaging

**Complete messaging functions implementation:**

```bash
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
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Anti-patterns:**

```bash
# âœ— Wrong - using info() for data output (goes to stderr, can't capture)
get_user_email() {
  info "$email"  # Goes to stderr! $email is empty when captured!
}

# âœ“ Correct - use echo for data
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# âœ— Wrong - echo for operational status (mixes with data stream)
process_file() {
  echo "Processing ${file@Q}..."  # Goes to stdout - mixes with data!
  cat "$file"
}

# âœ“ Correct - messaging for status, data to stdout
process_file() {
  info "Processing ${file@Q}..."  # To stderr
  cat "$file"                     # Data to stdout
}

# âœ— Wrong - help text using info() (won't display if VERBOSE=0)
show_help() {
  info 'Usage: script.sh [OPTIONS]'
}

# âœ“ Correct - help with echo/cat (always displays)
show_help() {
  cat <<HELP
Usage: script.sh [OPTIONS]
HELP
}

# âœ— Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found ${1@Q}"  # Wrong stream!
    return 1
  fi
}

# âœ“ Correct - errors to stderr
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found ${1@Q}"  # Correct stream
    return 1
  fi
}
```

**Edge cases:**

**1. Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'      # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"               # Data to stdout
  done
  success 'Data generation complete'  # Status to stderr
}
data=$(generate_data)  # Captures data, sees progress
```

**2. Error context with return codes:**
```bash
validate_config() {
  local -- config_file=$1
  if [[ ! -f "$config_file" ]]; then
    error "Config file not found ${config_file@Q}"
    return 2
  fi
  return 0
}

if ! validate_config "$config"; then
  die $? 'Configuration validation failed'
fi
```

**3. Logging vs user messages:**
```bash
process_item() {
  local -- item=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log (stdoutâ†'file)
  info "Processing $item..."                                # User (stderr)
}
process_item "$item" >> "$log_file"
```

**Key principle:** Stream separation enables script composition. Operational messages (how script works)â†'stderr via messaging. Data output (what script produces)â†'stdout via echo.
