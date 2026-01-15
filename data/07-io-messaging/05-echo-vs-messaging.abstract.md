## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for statusâ†'stderr; plain `echo` for dataâ†'stdout.**

**Key distinction:** Messaging respects `VERBOSE` and goes to stderr. Echo always outputs to stdout for piping/capture.

### When to Use Which

| Output Type | Tool | Stream | Verbosity |
|-------------|------|--------|-----------|
| Status/progress | `info`, `warn` | stderr | Respects VERBOSE |
| Errors | `error` | stderr | Always shows |
| Data/results | `echo` | stdout | Always shows |
| Help/version | `echo`/`cat` | stdout | Always shows |

### Core Pattern

```bash
get_data() {
  info "Processing..."     # Statusâ†'stderr (verbose-controlled)
  echo "$result"           # Dataâ†'stdout (capturable)
}

# Correct separation:
output=$(get_data)         # Captures only data, sees status
```

### Anti-Patterns

```bash
# âœ— Data via messaging - can't capture!
get_value() { info "$val"; }
x=$(get_value)  # Empty!

# âœ— Status via echo - pollutes data stream
process() { echo "Working..."; cat "$f"; }

# âœ— Help via info() - hidden when VERBOSE=0
show_help() { info "Usage: ..."; }
```

**Rule:** Data=`echo`â†'stdout. Status=messagingâ†'stderr. Errors always stderr. Help/version always display.

**Ref:** BCS0705
