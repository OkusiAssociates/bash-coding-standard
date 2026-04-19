#!/usr/bin/env bash
# Unit tests for SIGPIPE handling
# Verifies trim utilities don't hang when downstream closes the pipe early.

set -uo pipefail
trap '' PIPE  # Ignore SIGPIPE in the test harness itself

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

TRIM="$ROOT_DIR/trim.bash"
LTRIM="$ROOT_DIR/ltrim.bash"
SQUEEZE="$ROOT_DIR/squeeze.bash"

echo "Testing SIGPIPE handling..."

declare -i passed=0 failed=0

# Test that trim doesn't hang when downstream closes the pipe
test_sigpipe_trim() {
  local -i exit_code=0
  local -- result
  result=$(timeout 5 bash -c "seq 1 10000 | sed 's/.*/ & /' | '$TRIM' | head -1" 2>/dev/null) || exit_code=$?

  if ((exit_code != 124)) && [[ "$result" == "1" ]]; then
    echo -e "${GREEN}Test passed${NC}: trim handles SIGPIPE (head -1)"
    ((++passed))
  elif ((exit_code == 124)); then
    echo -e "${RED}Test failed${NC}: trim hung on SIGPIPE (timeout)"
    ((++failed))
  else
    # Exit 141 (SIGPIPE) is acceptable — means process was killed cleanly
    echo -e "${GREEN}Test passed${NC}: trim exits on SIGPIPE (exit: $exit_code)"
    ((++passed))
  fi
}

# Test ltrim with SIGPIPE
test_sigpipe_ltrim() {
  local -i exit_code=0
  local -- result
  result=$(timeout 5 bash -c "seq 1 10000 | sed 's/.*/ & /' | '$LTRIM' | head -1" 2>/dev/null) || exit_code=$?

  if ((exit_code == 124)); then
    echo -e "${RED}Test failed${NC}: ltrim hung on SIGPIPE (timeout)"
    ((++failed))
  else
    echo -e "${GREEN}Test passed${NC}: ltrim handles SIGPIPE (exit: $exit_code)"
    ((++passed))
  fi
}

# Test squeeze with SIGPIPE
test_sigpipe_squeeze() {
  local -i exit_code=0
  local -- result
  result=$(timeout 5 bash -c "seq 1 10000 | sed 's/.*/ &  & /' | '$SQUEEZE' | head -1" 2>/dev/null) || exit_code=$?

  if ((exit_code == 124)); then
    echo -e "${RED}Test failed${NC}: squeeze hung on SIGPIPE (timeout)"
    ((++failed))
  else
    echo -e "${GREEN}Test passed${NC}: squeeze handles SIGPIPE (exit: $exit_code)"
    ((++passed))
  fi
}

# Test with larger input to ensure no hang
test_sigpipe_large_no_hang() {
  local -i exit_code=0
  timeout 5 bash -c "seq 1 50000 | sed 's/.*/ & /' | '$TRIM' | head -1" >/dev/null 2>&1 || exit_code=$?

  if ((exit_code == 124)); then
    echo -e "${RED}Test failed${NC}: trim hung on large SIGPIPE input (timeout)"
    ((++failed))
  else
    # 0 = clean exit, 141 = SIGPIPE (128 + 13) — both acceptable
    echo -e "${GREEN}Test passed${NC}: trim does not hang on SIGPIPE (exit: $exit_code)"
    ((++passed))
  fi
}

# Run all tests
test_sigpipe_trim
test_sigpipe_ltrim
test_sigpipe_squeeze
test_sigpipe_large_no_hang

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All SIGPIPE tests passed!" && exit 0
echo "SIGPIPE tests FAILED" && exit 1

#fin
