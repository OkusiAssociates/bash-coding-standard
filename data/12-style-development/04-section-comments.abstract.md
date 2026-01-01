## Section Comments

**Use simple `# Description` comments to organize code into logical groups.**

### Format
- `# Short description` (2-4 words, no dashes/boxes)
- Place immediately before group; blank line after group
- Reserve 80-dash separators for major divisions only

### Example
```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin

# Conditional messaging
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
```

### Common Patterns
`# Default values` | `# Derived paths` | `# Helper functions` | `# Business logic` | `# Validation`

**Anti-pattern:** Heavy box-drawing or 80-dash separators for minor groupings â†' use simple `# Label` instead.

**Ref:** BCS1204
