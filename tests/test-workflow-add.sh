#!/usr/bin/env bash
# Test suite for workflows/add-rule.sh

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
ADD_RULE_SCRIPT="$PROJECT_DIR/workflows/01-add-rule.sh"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR ADD_RULE_SCRIPT

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_script_exists() {
  test_section "Script Existence"
  assert_file_exists "$ADD_RULE_SCRIPT"
  assert_file_executable "$ADD_RULE_SCRIPT"
}

test_help_option() {
  test_section "Help Option"
  local -- output
  output=$("$ADD_RULE_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "add-rule" "Script name shown"
}

test_help_contains_all_options() {
  test_section "Help Documentation Completeness"
  local -- output
  output=$("$ADD_RULE_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "section" "Section option documented"
  assert_contains "$output" "number" "Number option documented"
  assert_contains "$output" "name" "Name option documented"
  assert_contains "$output" "template" "Template option documented"
  assert_contains "$output" "no-interactive" "Non-interactive mode documented"
  assert_contains "$output" "no-compress" "No-compress option documented"
  assert_contains "$output" "no-validate" "No-validate option documented"
}

test_missing_required_arguments() {
  test_section "Missing Required Arguments"
  local -- output
  local -i exit_code

  # Test missing --section value
  output=$("$ADD_RULE_SCRIPT" --section 2>&1) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Exits with error when --section value missing (exit: $exit_code)"
  else
    fail "Should exit with error when --section value missing"
  fi

  # Test missing --number value
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --number 2>&1) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Exits with error when --number value missing (exit: $exit_code)"
  else
    fail "Should exit with error when --number value missing"
  fi

  # Test missing --name value
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --name 2>&1) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Exits with error when --name value missing (exit: $exit_code)"
  else
    fail "Should exit with error when --name value missing"
  fi
}

test_invalid_section_numbers() {
  test_section "Invalid Section Validation"
  local -- output
  local -i exit_code

  # Test section 00 (invalid)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 00 --number 01 --name test --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects section 00 (exit: $exit_code)"
  else
    fail "Should reject section 00"
  fi

  # Test section 15 (invalid - max is 14)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 15 --number 01 --name test --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects section 15 (exit: $exit_code)"
  else
    fail "Should reject section 15"
  fi

  # Test section "ab" (invalid format)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section ab --number 01 --name test --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects non-numeric section (exit: $exit_code)"
  else
    fail "Should reject non-numeric section"
  fi
}

test_invalid_rule_numbers() {
  test_section "Invalid Rule Number Validation"
  local -- output
  local -i exit_code

  # Test single digit (invalid - must be 2 digits)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 01 --number 1 --name test --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects single-digit rule number (exit: $exit_code)"
  else
    fail "Should reject single-digit rule number"
  fi

  # Test non-numeric
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 01 --number ab --name test --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects non-numeric rule number (exit: $exit_code)"
  else
    fail "Should reject non-numeric rule number"
  fi
}

test_invalid_rule_names() {
  test_section "Invalid Rule Name Validation"
  local -- output
  local -i exit_code

  # Test uppercase (invalid - must be lowercase)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 01 --number 01 --name Test-Name --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects uppercase in rule name (exit: $exit_code)"
  else
    fail "Should reject uppercase in rule name"
  fi

  # Test spaces (invalid - must use hyphens)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 01 --number 01 --name "test name" --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects spaces in rule name (exit: $exit_code)"
  else
    fail "Should reject spaces in rule name"
  fi

  # Test underscores (invalid - must use hyphens)
  exit_code=0
  output=$("$ADD_RULE_SCRIPT" --section 01 --number 01 --name test_name --no-interactive 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects underscores in rule name (exit: $exit_code)"
  else
    fail "Should reject underscores in rule name"
  fi
}

test_script_exists
test_help_option
test_help_contains_all_options
test_missing_required_arguments
test_invalid_section_numbers
test_invalid_rule_numbers
test_invalid_rule_names

print_summary
#fin
