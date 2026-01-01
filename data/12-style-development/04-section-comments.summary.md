## Section Comments

Use lightweight `# Description` comments to organize code into logical groups.

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1
declare -i DRY_RUN=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc

# Core message function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  # ...
}

# Conditional messaging functions
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Unconditional messaging functions
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Guidelines:**
- Keep section comments short (2-4 words), no dashes or box drawing
- Place immediately before the group; blank line after the group
- Reserve 80-dash separators for major script divisions only

**Common patterns:** `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`, `# Validation functions`
