## Production Script Optimization

**Remove unused functions/variables from mature production scripts.**

### Why
- Reduces size, improves clarity, eliminates maintenance burden

### Pattern
```bash
# Development: full toolkit
source lib/messaging.sh  # All utilities

# Production: keep only what's used
error() { >&2 printf '%s\n' "ERROR: $*"; }
die() { error "$@"; exit 1; }
# Removed: info, warn, debug, yn, trim...
```

### Anti-Pattern
```bash
# ✗ Shipping unused utilities
declare -- PROMPT='> '    # Never used
debug() { :; }            # Never called
```

**Ref:** BCS0405
