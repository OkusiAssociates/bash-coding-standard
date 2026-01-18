## Testing Support Patterns

**Make scripts testable via dependency injection, test mode flags, and assertion helpers.**

### Core Techniques

1. **Dependency Injection**: Wrap external commands in overridable functions
2. **TEST_MODE Flag**: Toggle test vs production behavior
3. **Assert Helper**: Standardized comparison with failure output

### Pattern

```bash
# Dependency injection - override in tests
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"
if ((TEST_MODE)); then
  DATA_DIR=./test_data
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR=/var/lib/app
  RM_CMD() { rm "$@"; }
fi

# Assert helper
assert() {
  [[ "$1" == "$2" ]] && return 0
  >&2 echo "FAIL: ${3:-Assertion failed}: '$1' != '$2'"
  return 1
}
```

### Anti-Patterns

- `rm -rf` directly → Use `RM_CMD` wrapper for testability
- Hardcoded paths → Use configurable `DATA_DIR` variables

**Ref:** BCS1209
