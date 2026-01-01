## Production Script Optimization

**Remove unused functions/variables from mature scripts to reduce size and maintenance.**

### Requirements
- Delete unused utilities (`yn()`, `trim()`, `s()`, etc.)
- Delete unused globals (`SCRIPT_DIR`, `DEBUG`, `PROMPT` if unreferenced)
- Keep only what script actually calls

### Example
```bash
# Full template has: _msg, vecho, success, warn, info, debug, error, die, yn
# Production script using only error handling:
error() { >&2 printf '%s\n' "Error: $*"; }
die()   { error "$@"; exit 1; }
```

### Anti-Pattern
```bash
# ✗ Keeping full messaging suite when only die() is used
```

**Ref:** BCS0405
