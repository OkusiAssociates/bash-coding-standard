## Section Comments

**Use lightweight `# Description` comments to group related code blocks (variables, functions, logical groups).**

**Format**: Simple `# Description` (no dashes/decorations), 2-4 words, placed immediately before group.

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

# Core message function
_msg() { local -- prefix="$SCRIPT_NAME:" msg; }

# Conditional messaging
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Unconditional messaging
error() { >&2 _msg "$@"; }
```

**Common patterns**: `# Default values`, `# Derived paths`, `# Helper functions`, `# Business logic`, `# Validation functions`

Reserve 80-dash separators for major script divisions only.

**Ref:** BCS1304
