## Testing Support Patterns

**Make scripts testable via dependency injection and test mode flags.**

### Why
- Enables mocking external commands without modifying production code
- Isolates destructive operations during testing
- Provides consistent test infrastructure across scripts

### Pattern

```bash
# Dependency injection - define if not exists
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
```

### Anti-Patterns

- `find "$@"` directly â†' cannot mock; use `FIND_CMD "$@"`
- Hardcoded paths â†' use conditional `DATA_DIR` based on `TEST_MODE`

### Test Infrastructure

```bash
assert() {
  local -- expected=$1 actual=$2 message=${3:-Assertion failed}
  [[ "$expected" = "$actual" ]] && return 0
  >&2 echo "FAIL: $message - expected '$expected', got '$actual'"
  return 1
}

run_tests() {
  local -i passed=0 failed=0
  for f in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    "$f" && passed+=1 || failed+=1
  done
  ((failed == 0))
}
```

**Ref:** BCS1209
