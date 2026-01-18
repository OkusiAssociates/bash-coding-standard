## Constants and Environment Variables

**Use `readonly`/`declare -r` for immutable values; `export`/`declare -x` for subprocess visibility.**

| Attribute | `readonly` | `export` |
|-----------|------------|----------|
| Prevents modification | ✓ | ✗ |
| Subprocess access | ✗ | ✓ |

**Rationale:**
- `readonly` prevents accidental modification of constants (VERSION, paths)
- `export` required only when child processes need the value
- Combine with `declare -rx` for immutable exported values

**Pattern:**
```bash
declare -r VERSION=2.1.0              # Script constant
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Env for children
declare -rx BUILD_ENV=production      # Both: readonly + exported

# Allow override then lock
OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/output}
readonly -- OUTPUT_DIR
```

**Anti-patterns:**
- `export MAX_RETRIES=3` → Use `readonly` if children don't need it
- `CONFIG=/etc/app.conf` (unprotected) → Use `readonly -- CONFIG=...`
- `readonly -- VAR=default` before allowing override → Set default first, then `readonly`

**Ref:** BCS0204
