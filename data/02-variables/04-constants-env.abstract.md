## Constants and Environment Variables

**Use `readonly` for immutable values; `declare -x`/`export` for subprocess-visible variables.**

| Feature | `readonly` | `declare -x` |
|---------|-----------|--------------|
| Prevents modification | ✓ | ✗ |
| Available to children | ✗ | ✓ |

**Key patterns:**
- Group `readonly -- VAR1 VAR2` after assignment block
- Combine: `declare -rx` for immutable + exported
- Allow override first: `VAR=${VAR:-default}; readonly -- VAR`

```bash
# Constants (not exported)
readonly -- SCRIPT_VERSION=2.1.0

# Environment for children
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}

# Combined: readonly + exported
declare -rx BUILD_ENV=production
```

**Anti-patterns:**
- `export MAX_RETRIES=3` �' Children don't need internal constants; use `readonly --`
- `CONFIG_FILE=/path` without `readonly` �' Accidental modification risk
- `readonly -- OUTPUT_DIR="$val"` before allowing user override

**Ref:** BCS0204
