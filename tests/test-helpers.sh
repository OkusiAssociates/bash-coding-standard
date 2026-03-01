#!/usr/bin/env bash
# test-helpers.sh - Shared test assertion functions
# Source this file in test scripts: source "$(dirname "$0")"/test-helpers.sh
set -euo pipefail
shopt -s inherit_errexit

# Test framework state
declare -i TESTS_RUN=0 TESTS_PASSED=0 TESTS_FAILED=0
declare -- CURRENT_TEST=''
declare -r TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
declare -r PROJECT_DIR=${TEST_DIR%/*}
declare -r BCS_CMD="$PROJECT_DIR"/bcs
declare -r DATA_DIR="$PROJECT_DIR"/data

# Colors
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Begin a test
begin_test() {
  CURRENT_TEST=$1
  TESTS_RUN+=1
}

# Assert two values are equal
assert_equal() {
  local -- expected=$1 actual=$2 msg=${3:-$CURRENT_TEST}
  if [[ "$expected" == "$actual" ]]; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s\n' "$RED" "$NC" "$msg"
    printf '    expected: %s\n' "${expected@Q}"
    printf '    actual:   %s\n' "${actual@Q}"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert value is not empty
assert_not_empty() {
  local -- actual=$1 msg=${2:-$CURRENT_TEST}
  if [[ -n "$actual" ]]; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s (was empty)\n' "$RED" "$NC" "$msg"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert command succeeds (exit 0)
assert_success() {
  local -- msg=${1:-$CURRENT_TEST}
  shift
  if "$@" >/dev/null 2>&1; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s (exit code: %d)\n' "$RED" "$NC" "$msg" "$?"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert command fails (non-zero exit)
assert_fails() {
  local -- msg=${1:-$CURRENT_TEST}
  shift
  if "$@" >/dev/null 2>&1; then
    printf '  %s✗%s %s (expected failure, got success)\n' "$RED" "$NC" "$msg"
    TESTS_FAILED+=1
    return 1
  else
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  fi
}

# Assert output contains string
assert_contains() {
  local -- haystack=$1 needle=$2 msg=${3:-$CURRENT_TEST}
  if [[ "$haystack" == *"$needle"* ]]; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s\n' "$RED" "$NC" "$msg"
    printf '    expected to contain: %s\n' "${needle@Q}"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert output matches regex
assert_matches() {
  local -- actual=$1 pattern=$2 msg=${3:-$CURRENT_TEST}
  if [[ "$actual" =~ $pattern ]]; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s\n' "$RED" "$NC" "$msg"
    printf '    did not match: %s\n' "${pattern@Q}"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert file exists
assert_file_exists() {
  local -- file=$1 msg=${2:-"file exists: $1"}
  if [[ -f "$file" ]]; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s\n' "$RED" "$NC" "$msg"
    TESTS_FAILED+=1
    return 1
  fi
}

# Assert numeric comparison
assert_gt() {
  local -i actual=$1 threshold=$2
  local -- msg=${3:-"$actual > $threshold"}
  if ((actual > threshold)); then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
    return 0
  else
    printf '  %s✗%s %s (got %d)\n' "$RED" "$NC" "$msg" "$actual"
    TESTS_FAILED+=1
    return 1
  fi
}

# Print test summary
print_summary() {
  local -- test_name=${1:-Tests}
  echo
  printf '%s%s Summary:%s %d run, %s%d passed%s, ' \
    "$BOLD" "$test_name" "$NC" "$TESTS_RUN" \
    "$GREEN" "$TESTS_PASSED" "$NC"
  if ((TESTS_FAILED)); then
    printf '%s%d failed%s\n' "$RED" "$TESTS_FAILED" "$NC"
  else
    printf '0 failed\n'
  fi
  ((TESTS_FAILED == 0))
}
#fin
