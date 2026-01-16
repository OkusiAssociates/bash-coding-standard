## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status â†' stderr; use `echo` for data output â†' stdout.**

**Rationale:**
- Stream separation: messagingâ†'stderr (user-facing), echoâ†'stdout (parseable data)
- Verbosity: messaging respects `VERBOSE`, echo always displays
- Pipeability: only stdout should contain data for capture/piping

**Decision matrix:**
- Status/progress â†' messaging function
- Data/return values â†' echo
- Help/version â†' echo (always display)
- Errors â†' `error()` to stderr

**Example:**
```bash
get_data() {
  info "Processing..."    # Status â†' stderr
  echo "$result"          # Data â†' stdout
}
output=$(get_data)        # Captures only data
```

**Anti-patterns:**
```bash
# âœ— Using info() for data - can't capture
get_email() { info "$email"; }     # Goes to stderr!

# âœ“ Use echo for data output
get_email() { echo "$email"; }     # Capturable

# âœ— Echo for status - mixes with data
echo "Processing..."               # Pollutes stdout

# âœ“ Messaging for status
info "Processing..."               # Clean separation
```

**Ref:** BCS0705
