#!/usr/bin/env bash
# test-helpers.sh - Test assertion functions for cln test suite
set -euo pipefail
shopt -s inherit_errexit

# Test framework state
declare -i TESTS_PASSED=0 TESTS_FAILED=0

# Colors
if [[ -t 1 && -t 2 ]]; then
  declare -r GREEN=$'\033[0;32m' RED=$'\033[0;31m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r GREEN='' RED='' CYAN='' NC=''
fi

# Print a section header
test_section() {
  printf '\n  %s── %s ──%s\n' "$CYAN" "$1" "$NC"
}

# Record a pass
pass() {
  printf '  %s✓%s %s\n' "$GREEN" "$NC" "$1"
  TESTS_PASSED+=1
}

# Record a failure
fail() {
  printf '  %s✗%s %s\n' "$RED" "$NC" "$1"
  TESTS_FAILED+=1
}

# Assert exit code is 0
assert_success() {
  local -i code=$1
  local -- msg=${2:-"exits with 0"}
  if ((code == 0)); then
    pass "$msg"
  else
    fail "$msg (got exit code $code)"
  fi
}

# Assert exit code matches expected
assert_exit_code() {
  local -i expected=$1 actual=$2
  local -- msg=${3:-"exits with $expected"}
  if ((expected == actual)); then
    pass "$msg"
  else
    fail "$msg (expected $expected, got $actual)"
  fi
}

# Assert string contains substring
assert_contains() {
  local -- haystack=$1 needle=$2 msg=${3:-"contains expected string"}
  if [[ "$haystack" == *"$needle"* ]]; then
    pass "$msg"
  else
    fail "$msg (expected to contain ${needle@Q})"
  fi
}

# Assert string is not empty
assert_not_empty() {
  local -- actual=$1 msg=${2:-"is not empty"}
  if [[ -n "$actual" ]]; then
    pass "$msg"
  else
    fail "$msg (was empty)"
  fi
}

# Assert string matches regex
assert_regex_match() {
  local -- actual=$1 pattern=$2 msg=${3:-"matches pattern"}
  if [[ "$actual" =~ $pattern ]]; then
    pass "$msg"
  else
    fail "$msg (did not match ${pattern@Q})"
  fi
}

# Print test summary and exit with appropriate code
print_summary() {
  local -i total=$((TESTS_PASSED + TESTS_FAILED))
  echo
  printf '  %d run, %s%d passed%s, ' "$total" "$GREEN" "$TESTS_PASSED" "$NC"
  if ((TESTS_FAILED)); then
    printf '%s%d failed%s\n' "$RED" "$TESTS_FAILED" "$NC"
  else
    printf '0 failed\n'
  fi
  ((TESTS_FAILED == 0))
}
#fin
