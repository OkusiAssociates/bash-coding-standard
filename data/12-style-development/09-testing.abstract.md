## Testing Support Patterns

**Use dependency injection and test mode flags to make scripts testable without modifying production code.**

**Rationale:** Testability requires isolating external dependencies (commands, file systems) while maintaining production behavior.

**Example:**
```bash
# Dependency injection - override for tests
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"

if ((TEST_MODE)); then
  DATA_DIR='./test_data'
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR='/var/lib/app'
  RM_CMD() { rm "$@"; }
fi

# Assert helper
assert() {
  local -- expected="$1" actual="$2" message="${3:-Assertion failed}"
  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
}

# Test runner
run_tests() {
  local -i passed=0 failed=0
  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1; echo " $test_func"
    else
      failed+=1; echo " $test_func"
    fi
  done
  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```

**Anti-pattern:** Modifying production code for tests or using global mocks that affect all functions.

**Ref:** BCS1409
