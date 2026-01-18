## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on output destination and purpose. Messaging functions for operational status (stderr, respects verbosity); plain `echo` for data output (stdout, always displays).**

**Rationale:**
- **Stream Separation**: Messaging→stderr (user-facing), `echo`→stdout (data/parseable)
- **Verbosity Control**: Messaging respects `VERBOSE`; `echo` always displays
- **Script Composition**: Proper streams allow pipelines without mixing data and status
- **Parseability**: `echo` output is predictable; messaging includes formatting/prefixes

**When to use messaging functions (`info`, `success`, `warn`, `error`):**

```bash
# Operational status updates (to stderr)
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'

# Diagnostic output
debug "Variable state: count=$count, total=$total"
info "Using configuration file ${config_file@Q}"

# Messages respecting verbosity
info 'Checking prerequisites...'   # Only if VERBOSE=1
error 'Configuration file not found'  # Always shown
```

**When to use plain `echo`:**

```bash
# 1. Data output (stdout) - must be capturable
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

# 3. Structured/parseable output
list_users() {
  local -- user
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}
list_users | grep '^admin' | wc -l

# 4. Output that must always display
show_version() { echo "$SCRIPT_NAME $VERSION"; }
echo "Processed $success_count files successfully"
```

**Decision matrix:**

```bash
# Is this operational status or data?     Status→messaging  Data→echo
# Should this respect verbosity?          Yes→messaging     No→echo
# Will this be parsed or piped?           Yes→echo          No→messaging
# Is this multi-line formatted output?    Yes→echo/heredoc  No→messaging
# Does this need color/formatting?        Yes→messaging     No→echo
```

**Anti-patterns:**

```bash
# ✗ Wrong - using info() for data output (goes to stderr, can't capture)
get_user_email() {
  local -- email=$1
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email alice)  # $email is empty!

# ✓ Correct - use echo for data output
get_user_email() {
  local -- email=$1
  echo "$email"  # Goes to stdout, can be captured
}

# ✗ Wrong - using echo for operational status (mixes with data)
process_file() {
  local -- file=$1
  echo "Processing ${file@Q}..."  # Goes to stdout - mixes with data!
  cat "$file"
}

# ✓ Correct - use messaging function for status
process_file() {
  local -- file=$1
  info "Processing ${file@Q}..."  # Goes to stderr - separated from data
  cat "$file"                     # Data to stdout
}

# ✗ Wrong - help text using info() (won't display if VERBOSE=0)
show_help() {
  info 'Usage: script.sh [OPTIONS]'
  info '  -v  Verbose mode'
}

# ✓ Correct - help text using echo/cat
show_help() {
  cat <<HELP
Usage: script.sh [OPTIONS]
  -v  Verbose mode
HELP
}

# ✗ Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found ${1@Q}"  # To stdout - wrong stream!
    return 1
  fi
}

# ✓ Correct - error messages to stderr
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found ${1@Q}"  # To stderr - correct stream
    return 1
  fi
}
```

**Edge cases:**

**1. Progress during data generation:**

```bash
generate_data() {
  local -i i
  info 'Generating data...'           # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"                    # Data to stdout
  done
  success 'Data generation complete'  # Completion to stderr
}
data=$(generate_data)  # Captures only data, sees progress
```

**2. Error context in functions:**

```bash
validate_config() {
  local -- config_file=$1
  if [[ ! -f "$config_file" ]]; then
    error "Config file not found ${config_file@Q}"
    return 2
  fi
  if [[ ! -r "$config_file" ]]; then
    error "Config file not readable ${config_file@Q}"
    return 5
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
  # Log entry (data to stdout, redirected to file)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"
  # User message (status to stderr)
  info "Processing $item..."
}
process_item "$item" >> "$log_file"
```

**Testing stream separation:**

```bash
test_message_separation() {
  local -- output
  output=$(
    info 'Starting process...'  # To stderr - not captured
    echo 'data'                  # To stdout - captured
    success 'Process complete'   # To stderr - not captured
  )
  [[ "$output" == 'data' ]] || die 1 "Expected 'data', got ${output@Q}"
}
```

**Summary:**
- **Messaging functions**: Operational status, diagnostics, user-facing messages → stderr
- **Plain `echo`**: Data output, help text, structured reports, parseable output → stdout
- **Verbosity**: Messaging respects `VERBOSE`; echo always displays
- **Help/version**: Always display (echo), never verbose-dependent
- **Errors**: Always to stderr (use `error()` or `>&2 echo`)

**Key principle:** Stream separation enables script composition. Operational messages (how script works) → stderr via messaging. Data output (what script produces) → stdout via echo.
