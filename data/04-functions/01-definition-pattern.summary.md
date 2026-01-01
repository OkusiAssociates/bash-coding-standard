## Function Definition Pattern

```bash
# Single-line functions for simple operations
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line functions with local variables
main() {
  local -i exitcode=0
  local -- variable
  # Function body
  return "$exitcode"
}
```

**Key Points:**
- Single-line format for simple one-expression functions
- Multi-line with proper indentation for complex functions
- Declare locals at function start with `local -i` (integers) or `local --` (strings)
- Use `return "$exitcode"` for explicit exit status
