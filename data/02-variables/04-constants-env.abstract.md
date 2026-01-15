## Constants and Environment Variables

**Use `declare -r` for immutable constants; `declare -x` for child process visibility.**

| Attribute | `readonly` | `export` |
|-----------|-----------|----------|
| Prevents change | âœ“ | âœ— |
| Subprocess access | âœ— | âœ“ |

**Rationale:**
- `readonly` prevents accidental modification, signals intent
- `export` required only when child processes need the value
- Combine with `declare -rx` when both immutability and export needed

**Example:**
```bash
declare -r VERSION=2.1.0              # Constant (script only)
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Exported, user-overridable
declare -rx BUILD_ENV=production      # Immutable + exported
readonly -- SCRIPT_DIR               # Lock after calculation
```

**Anti-patterns:**
- `export MAX_RETRIES=3` â†' Use `readonly` if children don't need it
- `CONFIG=/etc/app.conf` without `readonly` â†' Allows accidental modification
- `readonly OUTPUT_DIR=$HOME/out` â†' Blocks user override; use `${VAR:-default}` first

**Ref:** BCS0204
