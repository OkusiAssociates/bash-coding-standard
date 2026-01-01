## Constants and Environment Variables

**Use `readonly` for immutable constants, `declare -x`/`export` for child process inheritance.**

| Feature | `readonly` | `declare -x` |
|---------|-----------|--------------|
| Prevents modification | âœ“ | âœ— |
| Available to children | âœ— | âœ“ |

**Rationale:**
- `readonly` signals intent and prevents accidental modification
- `export` makes variables available to subprocess environment only when needed

**Pattern:**
```bash
# Constants (not exported)
readonly -- VERSION=1.0.0 CONFIG_DIR=/etc/app

# Environment for children
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}

# Combined: readonly + exported
declare -rx BUILD_ENV=production
```

**Anti-patterns:**
- `export MAX_RETRIES=3` â†' Use `readonly` unless children need it
- Unprotected constants â†' `CONFIG=/etc/app.conf` can be modified; use `readonly --`
- Early readonly on user-configurable â†' `readonly -- DIR="$HOME/out"` prevents override; allow default first: `DIR=${DIR:-default}; readonly -- DIR`

**Ref:** BCS0204
