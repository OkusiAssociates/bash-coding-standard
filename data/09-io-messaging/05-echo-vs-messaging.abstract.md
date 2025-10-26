## Echo vs Messaging Functions

**Use messaging functions for operational status (stderr); use `echo` for data output (stdout).**

**Rationale:**
- **Stream separation** - Status (stderr) vs data (stdout) enables clean piping
- **Verbosity control** - Messaging respects `VERBOSE`, echo always displays
- **Parseability** - Only stdout data is pipeable/capturable

**Messaging functions (`info`, `success`, `warn`, `error`):**
- Operational status: `info 'Processing...'`
- Diagnostics: `debug "count=$count"`
- Messages respecting verbosity

**Plain `echo`:**
- Function return values: `echo "$result"` (capturable via `var=$(func)`)
- Help/version text (must always display)
- Reports, structured output
- Pipeable data

**Example:**
```bash
get_home() {
  echo "$(getent passwd "$1" | cut -d: -f6)"  # Data
}

main() {
  info "Looking up: $user"     # Status → stderr
  home=$(get_home "$user")     # Capture stdout
  echo "Home: $home"           # Data → stdout
}
```

**Anti-patterns:**
```bash
# ✗ info() for data → stderr, can't capture
get_email() { info "$email"; }
# ✓ echo for data → stdout
get_email() { echo "$email"; }

# ✗ echo for status → mixes with data
process() { echo 'Processing...'; cat "$file"; }
# ✓ messaging for status → separates streams
process() { info 'Processing...'; cat "$file"; }
```

**Decision: Data → `echo` (stdout), Status → messaging (stderr)**

**Ref:** BCS0905
