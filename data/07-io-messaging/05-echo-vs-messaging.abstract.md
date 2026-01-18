## Echo vs Messaging Functions

**Use messaging functions (`info`, `success`, `warn`, `error`) for operational status to stderr; use `echo` for data output to stdout.**

**Rationale:**
- Stream separation enables pipelines (data=stdout, status=stderr)
- Messaging respects `VERBOSE`; `echo` always displays (critical for captures)
- Data output must be parseable without formatting interference

**Decision:** Status/progress → messaging. Data/help/reports → echo.

**Core Pattern:**
```bash
get_data() {
  info "Processing..."     # stderr, verbose-controlled
  echo "$result"           # stdout, always outputs (capturable)
}
show_help() { cat <<EOT
Usage: $SCRIPT_NAME [OPTIONS]
EOT
}
```

**Anti-patterns:**
```bash
# ✗ info() for data - goes to stderr, can't capture
get_email() { info "$email"; }
email=$(get_email)  # Empty!

# ✗ echo for status - mixes with data in pipeline
process() { echo "Processing..."; cat "$file"; }
```

**Rules:** Help/version → always echo. Errors → always stderr (`error()`). Data functions → echo only. Progress → messaging functions.

**Ref:** BCS0705
