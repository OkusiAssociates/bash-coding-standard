## Echo vs Messaging Functions

**Use `echo` for data output (stdout), messaging functions for operational status (stderr).**

**Rationale:** Stream separation enables piping/capturing data while showing status; verbosity control applies only to status messages; parseable output requires predictable format.

### Decision Criteria

| Output Type | Tool | Stream | Verbosity |
|-------------|------|--------|-----------|
| Data/results | `echo` | stdout | Always shows |
| Help/version | `echo`/`cat` | stdout | Always shows |
| Status/progress | `info`/`success` | stderr | Respects VERBOSE |
| Errors | `error`/`die` | stderr | Always shows |

### Core Pattern

```bash
# Data output - capturable
get_value() { echo "$result"; }
val=$(get_value)  # Works

# Status - never captured
process() {
  info 'Processing...'    # stderr
  echo "$data"            # stdout (data)
  success 'Done'          # stderr
}
output=$(process)  # Only captures $data
```

### Anti-Patterns

```bash
# âœ— info() for data - can't capture
get_email() { info "$email"; }
result=$(get_email)  # Empty!

# âœ— echo for status - pollutes data stream
list_files() {
  echo "Listing..."  # Mixes with data!
  ls
}

# âœ— Help via info() - hidden when VERBOSE=0
show_help() { info 'Usage: ...'; }
```

**Key:** Data â†' stdout (echo), Status â†' stderr (messaging functions).

**Ref:** BCS0705
