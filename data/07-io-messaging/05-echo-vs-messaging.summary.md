## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context and output destination. Use messaging functions for operational status (stderr), and plain `echo` for data output (stdout).**

**Rationale:**
- **Stream Separation**: Messaging â†' stderr (user-facing); `echo` â†' stdout (data/parseable)
- **Verbosity Control**: Messaging functions respect `VERBOSE`; `echo` always displays
- **Script Composition**: Proper streams allow pipelines without mixing data and status
- **Parseability**: Plain `echo` output is predictable; messaging includes formatting

**Use messaging functions (`info`, `success`, `warn`, `error`) for:**

1. **Operational status updates:**
```bash
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'
```

2. **User-facing diagnostics:**
```bash
debug "Variable state: count=$count, total=$total"
info "Using configuration file: $config_file"
```

3. **Messages respecting verbosity:**
```bash
info 'Checking prerequisites...'   # Only shown if VERBOSE=1
error 'Configuration file not found'  # Always shown
```

**Use plain `echo` for:**

1. **Data output (stdout):**
```bash
get_user_email() {
  local -- username="$1"
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')  # Can capture output
```

2. **Help text and documentation:**
```bash
usage() {
  cat <<'EOF'
Usage: script.sh [OPTIONS] FILE...

Options:
  -v, --verbose     Enable verbose output
  -h, --help        Show this help message
EOF
}
```

3. **Output for parsing or piping:**
```bash
list_users() {
  local -- user
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}
list_users | grep '^admin' | wc -l
```

4. **Output that must always display:**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"
}
echo "Processed $success_count files successfully"
```

**Decision matrix:**
```bash
# Is this operational status or data?
#   Status â†' messaging function    |   Data â†' echo
# Should this respect verbosity?
#   Yes â†' messaging function       |   No â†' echo
# Will this be parsed or piped?
#   Yes â†' echo to stdout           |   No â†' messaging to stderr
# Does this need color/formatting?
#   Yes â†' messaging function       |   No â†' echo
```

**Core implementation pattern:**

```bash
# Messaging Functions (stderr, with verbosity control)
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }

# Data Functions (stdout, always output)
get_user_home() {
  local -- username="$1"
  local -- home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -z "$home_dir" ]] && return 1
  echo "$home_dir"  # Data to stdout
}
```

**Running behavior:**
```bash
# Without verbose - only data output and errors
$ ./script.sh alice
User Report
===========
Username: alice
...

# With verbose - operational messages visible (to stderr)
$ ./script.sh -v alice
script.sh: â—‰ Looking up user: alice
script.sh: âœ“ Found user: alice
User Report
===========
...

# Pipe output (only stdout piped, stderr messages visible)
$ ./script.sh -v alice | grep Shell
script.sh: â—‰ Looking up user: alice
Shell: /bin/bash
script.sh: â—‰ Report generation complete
```

**Anti-patterns:**

```bash
# âœ— Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email 'alice')  # $email is empty!

# âœ“ Correct - use echo for data output
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# âœ— Wrong - using echo for operational status
process_file() {
  echo "Processing $file..."  # Goes to stdout - mixes with data!
  cat "$file"
}

# âœ“ Correct - use messaging function for status
process_file() {
  info "Processing $file..."  # Goes to stderr - separated from data
  cat "$file"                  # Data to stdout
}

# âœ— Wrong - help text using info()
show_help() {
  info 'Usage: script.sh [OPTIONS]'  # Won't display if VERBOSE=0!
}

# âœ“ Correct - help text using echo/cat
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
EOF
}

# âœ— Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"  # To stdout - wrong stream!
    return 1
  fi
}

# âœ“ Correct - error messages to stderr
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found: $1"  # To stderr - correct stream
    return 1
  fi
}
```

**Edge cases:**

**1. Version output (always echo):**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo - version won't show if VERBOSE=0 with info()
}
```

**2. Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'              # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"                        # Data to stdout
  done
  success 'Data generation complete'     # Completion to stderr
}
data=$(generate_data)  # Captures data, sees progress
```

**3. Conditional output formatting:**
```bash
show_result() {
  if [[ -t 1 ]]; then
    success 'Operation completed'  # Interactive terminal
  else
    echo "$result"                 # Non-interactive/piped
  fi
}
```

**4. Logging vs user messages:**
```bash
process_item() {
  local -- item="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log (stdoutâ†'file)
  info "Processing $item..."                                # User message (stderr)
}
process_item "$item" >> "$log_file"
```

**Key principle:** The choice between echo and messaging functions is fundamentally about stream separation. Operational messages (how the script is working) belong on stderr via messaging functions. Data output (what the script produces) belongs on stdout via echo. This enables proper script composition, piping, and redirection.
