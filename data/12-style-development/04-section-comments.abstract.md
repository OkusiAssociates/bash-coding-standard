## Section Comments

**Use lightweight `# Description` comments (2-4 words) to group related code; reserve 80-dash separators for major divisions only.**

### Key Points
- Simple format: `# Default values` → no dashes/boxes
- Place immediately before group, blank line after
- Group related variables, functions, or logical blocks

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
`# Default values` `# Derived paths` `# Helper functions` `# Business logic` `# Validation`

**Ref:** BCS1204
