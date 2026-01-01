## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status to stderr; use `echo` for data output to stdout.**

**Key Distinction:**
- **Messaging** �' stderr, respects `VERBOSE`, has formatting/colors
- **echo** �' stdout, always displays, parseable/pipeable

**Use messaging for:** status updates, diagnostics, progress, color-coded feedback
**Use echo for:** data returns, help/version, reports, parseable output

```bash
# Messaging: operational status (stderr)
info 'Processing...'
error "File not found ${file@Q}"

# Echo: data output (stdout, capturable)
get_value() { echo "$result"; }
val=$(get_value)

# Help text always uses echo/cat (not messaging)
show_help() { cat <<'EOT'
Usage: script.sh [OPTIONS]
EOT
}
```

**Anti-patterns:**

```bash
# ✗ info() for data - goes to stderr, cannot capture
get_email() { info "$email"; }

# ✗ echo for status - mixes with data in stdout
echo "Processing..."  # Use info instead

# ✗ Help via info() - hidden if VERBOSE=0
show_help() { info 'Usage: ...'; }

# ✗ Error to stdout
echo "Error: failed"  # Use: error "failed"
```

**Stream separation enables pipeline composition:** data piped/captured, status visible to user.

**Ref:** BCS0705
