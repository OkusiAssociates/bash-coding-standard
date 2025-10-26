## Production Script Optimization

**Remove unused utilities/variables once script is production-ready** - reduces size, improves clarity, eliminates maintenance burden.

### Core Principle
Strip functions/variables not called in your script. Simple script needing only `error()` and `die()` shouldn't carry full messaging suite (`vecho()`, `yn()`, `decp()`, `trim()`, `s()`, etc.).

### Example
```bash
# ✗ Development - carries unused functions
vecho() { ... }; yn() { ... }; decp() { ... }
error() { ... }; die() { ... }  # Only these used

# ✓ Production - stripped to essentials
error() { >&2 _msg ERROR "$@"; }
die() { error "$@"; exit "${2:-1}"; }
```

### Anti-Pattern
**Keeping dead code** → Bloated scripts, confusing maintenance, false dependencies.

**Ref:** BCS0605
