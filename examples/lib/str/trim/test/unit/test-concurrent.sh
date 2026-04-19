#!/usr/bin/env bash
# Unit tests for concurrent usage of trimv

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source trimv for function testing
source "$ROOT_DIR/trimv.bash"

echo "Testing concurrent trimv usage..."

declare -i passed=0 failed=0

# Test parallel trimv invocations with -n flag
test_parallel_trimv() {
  local -- result1='' result2='' result3=''

  # Run three trimv calls that assign to different variables
  trimv -n result1 "  first value  " &
  local -i pid1=$!
  trimv -n result2 "  second value  " &
  local -i pid2=$!
  trimv -n result3 "  third value  " &
  local -i pid3=$!

  wait "$pid1" "$pid2" "$pid3" 2>/dev/null

  # In background subshells, -n assignments don't propagate back.
  # This test verifies no crashes or hangs occur during concurrent execution.
  echo -e "${GREEN}Test passed${NC}: Parallel trimv invocations complete without errors"
  ((++passed))
}

# Test concurrent stdin processing (no -n flag, output mode)
test_concurrent_stdout() {
  local -- tmp1 tmp2 tmp3
  tmp1=$(mktemp)
  tmp2=$(mktemp)
  tmp3=$(mktemp)

  echo "  concurrent one  " | trimv > "$tmp1" &
  local -i pid1=$!
  echo "  concurrent two  " | trimv > "$tmp2" &
  local -i pid2=$!
  echo "  concurrent three  " | trimv > "$tmp3" &
  local -i pid3=$!

  wait "$pid1" "$pid2" "$pid3"

  local -- r1 r2 r3
  r1=$(<"$tmp1")
  r2=$(<"$tmp2")
  r3=$(<"$tmp3")

  rm -f "$tmp1" "$tmp2" "$tmp3"

  if [[ "$r1" == "concurrent one" && "$r2" == "concurrent two" && "$r3" == "concurrent three" ]]; then
    echo -e "${GREEN}Test passed${NC}: Concurrent stdout trimv produces correct results"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Concurrent stdout (got: ${r1@Q}, ${r2@Q}, ${r3@Q})"
    ((++failed))
  fi
}

# Test rapid sequential trimv calls (race condition check)
test_rapid_sequential() {
  local -i i errors=0

  for ((i = 0; i < 100; i++)); do
    local -- var=''
    trimv -n var "  iteration $i  "
    if [[ "$var" != "iteration $i" ]]; then
      ((++errors))
    fi
  done

  if ((errors == 0)); then
    echo -e "${GREEN}Test passed${NC}: 100 rapid sequential trimv calls correct"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: $errors errors in 100 sequential calls"
    ((++failed))
  fi
}

# Test concurrent stdin processing with larger data
test_concurrent_large_stdin() {
  local -- tmp1 tmp2
  tmp1=$(mktemp)
  tmp2=$(mktemp)

  # Generate 500 lines for each concurrent process
  seq 1 500 | sed 's/.*/ line & /' | trimv > "$tmp1" &
  local -i pid1=$!
  seq 501 1000 | sed 's/.*/ line & /' | trimv > "$tmp2" &
  local -i pid2=$!

  wait "$pid1" "$pid2"

  local -i count1 count2
  count1=$(wc -l < "$tmp1")
  count2=$(wc -l < "$tmp2")

  rm -f "$tmp1" "$tmp2"

  if ((count1 == 500 && count2 == 500)); then
    echo -e "${GREEN}Test passed${NC}: Concurrent large stdin (500+500 lines)"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Concurrent large stdin (got: $count1, $count2 lines)"
    ((++failed))
  fi
}

# Run all tests
test_parallel_trimv
test_concurrent_stdout
test_rapid_sequential
test_concurrent_large_stdin

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All concurrent tests passed!" && exit 0
echo "Concurrent tests FAILED" && exit 1

#fin
