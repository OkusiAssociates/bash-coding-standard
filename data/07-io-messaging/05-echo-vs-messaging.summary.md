## Echo vs Messaging Functions

**Choose plain `echo` for data output (stdout) and messaging functions for operational status (stderr). Stream separation enables script composition.**

**Rationale:**
- **Stream Separation**: Messagingâ†'stderr (user-facing), echoâ†'stdout (parseable data)
- **Verbosity Control**: Messaging respects `VERBOSE`; echo always displays
- **Script Composition**: Proper streams allow pipeline combining without mixing data/status

### When to Use Messaging Functions

**Operational status and diagnostics:**
```bash
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'
debug "Variable state: count=$count"
```

### When to Use Plain Echo

**1. Data output (return values):**
```bash
get_user_email() {
  local -- username=$1
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')
```

**2. Help text and documentation:**
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

**3. Structured reports and parseable output:**
```bash
generate_report() {
  echo 'System Report'
  echo '============='
  df -h
}

list_users() {
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}
list_users | grep '^admin'  # Pipeable
```

**4. Output that must always display:**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo, not info()
}
```

### Decision Matrix

| Question | Answer | Use |
|----------|--------|-----|
| Status or data? | Status | messaging function |
| Status or data? | Data | echo |
| Respect verbosity? | Yes | messaging function |
| Parsed/piped? | Yes | echo to stdout |
| Multi-line formatted? | Yes | echo/here-doc |
| Needs color/formatting? | Yes | messaging function |

### Anti-Patterns

```bash
# âœ— Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email alice)  # $email is empty!

# âœ“ Correct
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# âœ— Wrong - using echo for operational status
process_file() {
  echo "Processing ${file@Q}..."  # Mixes with data output!
  cat "$file"
}

# âœ“ Correct
process_file() {
  info "Processing ${file@Q}..."  # Status to stderr
  cat "$file"                     # Data to stdout
}

# âœ— Wrong - help text using info()
show_help() {
  info 'Usage: script.sh [OPTIONS]'  # Won't display if VERBOSE=0!
}

# âœ“ Correct - help text using cat
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
EOF
}

# âœ— Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found ${1@Q}"  # Wrong stream!
    return 1
  fi
}

# âœ“ Correct
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found ${1@Q}"  # To stderr
    return 1
  fi
}
```

### Edge Cases

**Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'  # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"           # Data to stdout
  done
  success 'Complete'         # Status to stderr
}
data=$(generate_data)        # Captures only data
```

**Logging vs user messages:**
```bash
process_item() {
  local -- item=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log (stdoutâ†'file)
  info "Processing $item..."                                # User (stderr)
}
process_item "$item" >> "$log_file"
```

**Key principle:** Operational messages (how script works)â†'stderr via messaging. Data output (what script produces)â†'stdout via echo. This enables proper piping, capturing, and redirection.
