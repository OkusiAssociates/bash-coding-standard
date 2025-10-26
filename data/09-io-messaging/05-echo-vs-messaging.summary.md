## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context and output destination. Use messaging functions for operational status (stderr, respects verbosity), `echo` for data output (stdout, always displays).**

**Rationale:**

- **Stream separation** enables script compositionmessaging to stderr (user-facing), `echo` to stdout (parseable data)
- **Verbosity control** with messaging functions; `echo` always displays (critical for pipeable output)
- **Consistent formatting** via messaging functions (prefixes, colors, script identification)

**Use messaging functions (`info`, `success`, `warn`, `error`) for:**

**1. Operational status:**

```bash
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
info "Processing file $count of $total"
```

**2. User-facing diagnostics:**

```bash
debug "Variable state: count=$count, total=$total"
info "Using configuration file: $config_file"
```

**3. Messages respecting verbosity and needing color/formatting:**

```bash
((VERBOSE)) && info 'Checking prerequisites...'
success 'Build completed'        # Green checkmark
warn 'Using default settings'    # Yellow warning
error 'Compilation failed'       # Red X
```

**Use plain `echo` for:**

**1. Data output (stdout):**

```bash
get_user_email() {
  local -- username="$1" email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}

user_email=$(get_user_email 'alice')  # Capture output
```

**2. Help text and documentation:**

```bash
usage() {
  cat <<'EOF'
Usage: script.sh [OPTIONS] FILE...

Process files with various options.

Options:
  -v, --verbose     Enable verbose output
  -h, --help        Show this help message
  -o, --output DIR  Output directory
EOF
}
```

**3. Output for parsing/piping:**

```bash
list_users() {
  local -- user
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}

list_users | grep '^admin' | wc -l
```

**4. Output that always displays regardless of verbosity:**

```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"
}

echo "Processed $success_count files successfully"
```

**Decision matrix:**

```bash
# Status/operational ’ messaging function
# Data output ’ echo

# Respect verbosity? Yes ’ messaging function; No ’ echo (or error)
# Parsed/piped? Yes ’ echo to stdout; No ’ messaging function to stderr
# Multi-line formatted? Yes ’ echo/here-doc; No ’ messaging function
# Color/formatting? Yes ’ messaging function; No ’ echo
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

declare -i VERBOSE=0

if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC

# Messaging Functions (stderr, verbosity control)
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}${NC}" ;;
    warn)    prefix+=" ${YELLOW}²${NC}" ;;
    info)    prefix+=" ${CYAN}É${NC}" ;;
    error)   prefix+=" ${RED}${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }

die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

# Data Functions (stdout, always output)
get_user_home() {
  local -- username="$1" home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -z "$home_dir" ]] && return 1
  echo "$home_dir"  # Data to stdout
}

show_report() {
  echo "User Report"
  echo "==========="
  echo ""
  echo "Username: $USER"
  echo "Home: $HOME"
}

usage() {
  cat <<'EOF'
Usage: script.sh [OPTIONS] USERNAME

Get information about a user.

Options:
  -v, --verbose    Show detailed progress
  -h, --help       Show this help
EOF
}

main() {
  local -- username user_home

  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)    usage; return 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            break ;;
  esac; shift; done

  readonly -- VERBOSE

  (($# != 1)) && { error 'Expected exactly one argument'; usage; return 22; }

  username="$1"
  info "Looking up user: $username"  # Operational status to stderr

  if ! user_home=$(get_user_home "$username"); then
    error "User not found: $username"
    return 1
  fi

  success "Found user: $username"  # Status to stderr
  show_report                       # Data to stdout
  info 'Report generation complete'
}

main "$@"

#fin
```

**Output behavior:**

```bash
# Without verbose - only data and errors
$ ./script.sh alice
User Report
===========
Username: alice
Home: /home/alice

# With verbose - status messages visible (stderr)
$ ./script.sh -v alice
script.sh: É Looking up user: alice
script.sh:  Found user: alice
User Report
===========
...
script.sh: É Report generation complete

# Pipe output - only stdout data piped, stderr visible
$ ./script.sh -v alice | grep Home
script.sh: É Looking up user: alice
script.sh:  Found user: alice
Home: /home/alice
script.sh: É Report generation complete
```

**Anti-patterns:**

```bash
#  Wrong - info() for data output (goes to stderr, can't capture)
get_user_email() { info "$email"; }
email=$(get_user_email 'alice')  # $email is empty!

#  Correct
get_user_email() { echo "$email"; }

#  Wrong - echo for status (mixes with data on stdout)
process_file() {
  echo "Processing $file..."  # Mixes with data!
  cat "$file"
}

#  Correct - status to stderr, data to stdout
process_file() {
  info "Processing $file..."  # To stderr
  cat "$file"                  # To stdout
}

#  Wrong - help won't display if VERBOSE=0
show_help() {
  info 'Usage: script.sh [OPTIONS]'
  info '  -v  Verbose mode'
}

#  Correct - help always displays
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
  -v  Verbose mode
EOF
}

#  Wrong - error to stdout
validate_input() {
  [[ ! -f "$1" ]] && echo "File not found: $1" && return 1
}

#  Correct - error to stderr
validate_input() {
  [[ ! -f "$1" ]] && error "File not found: $1" && return 1
}

#  Wrong - data output respects VERBOSE
get_count() { ((VERBOSE)) && echo "$count"; }  # Data hidden if VERBOSE=0!

#  Correct - data always outputs
get_count() { echo "$count"; }
```

**Edge cases:**

**1. Version output (data, always display):**

```bash
show_version() { echo "$SCRIPT_NAME $VERSION"; }  # Use echo
```

**2. Progress during data generation:**

```bash
generate_data() {
  info 'Generating data...'  # Progress to stderr
  for ((i=1; i<=100; i++)); do echo "line $i"; done  # Data to stdout
  success 'Complete'  # Status to stderr
}

data=$(generate_data)  # Capture data, see progress
```

**3. Error context in functions:**

```bash
validate_config() {
  [[ ! -f "$1" ]] && { error "Config file not found: $1"; return 2; }
  [[ ! -r "$1" ]] && { error "Config file not readable: $1"; return 5; }
  return 0
}

validate_config "$config" || die $? 'Configuration validation failed'
```

**Summary:**

- **Messaging functions** for operational status, diagnostics respecting verbosity (stderr)
- **Plain `echo`** for data output, help text, parseable output (stdout)
- **Stream separation** enables script composition: status to stderr, data to stdout
- **Pipeability**: Only stdout contains data for capturing/piping
- **Help/version**: Always display (echo), never verbose-dependent
- **Multi-line**: Use echo/here-docs, not multiple messaging calls

**Key principle:** Choose based on stream separation. Operational messages (how script works) ’ stderr via messaging functions. Data output (what script produces) ’ stdout via echo. This enables proper composition, piping, redirection while informing users of progress.
