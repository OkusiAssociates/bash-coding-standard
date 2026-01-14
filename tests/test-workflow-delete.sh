#!/usr/bin/env bash
# Test suite for workflows/delete-rule.sh

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
DELETE_RULE_SCRIPT="$PROJECT_DIR/workflows/03-delete-rule.sh"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR DELETE_RULE_SCRIPT

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_script_exists() {
  test_section "Script Existence"
  assert_file_exists "$DELETE_RULE_SCRIPT"
  assert_file_executable "$DELETE_RULE_SCRIPT"
}

test_help_option() {
  test_section "Help Option"
  local -- output
  output=$("$DELETE_RULE_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "CODE" "Required argument documented"
}

test_help_contains_all_options() {
  test_section "Help Documentation Completeness"
  local -- output
  output=$("$DELETE_RULE_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "--dry-run" "Dry-run option documented"
  assert_contains "$output" "--force" "Force option documented"
  assert_contains "$output" "--no-backup" "No-backup option documented"
  assert_contains "$output" "--no-check-refs" "No-check-refs option documented"
  assert_contains "$output" "--quiet" "Quiet option documented"
  assert_contains "$output" "CODE" "Required argument documented"
}

test_missing_required_argument() {
  test_section "Missing Required Argument"
  local -- output

  # Test with no argument - script shows error message
  output=$(timeout 2 "$DELETE_RULE_SCRIPT" 2>&1 < /dev/null) || true
  assert_contains "$output" "No BCS code specified" "Shows error for missing argument"
}

test_invalid_bcs_code_format() {
  test_section "Invalid BCS Code Format"
  local -- output
  local -i exit_code

  # Test invalid format (missing digits)
  exit_code=0
  output=$("$DELETE_RULE_SCRIPT" BCS01 --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects incomplete BCS code BCS01 (exit: $exit_code)"
  else
    fail "Should reject incomplete BCS code BCS01"
  fi

  # Test invalid format (lowercase)
  exit_code=0
  output=$("$DELETE_RULE_SCRIPT" bcs0101 --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects lowercase BCS code bcs0101 (exit: $exit_code)"
  else
    fail "Should reject lowercase BCS code bcs0101"
  fi

  # Test invalid format (letters in number)
  exit_code=0
  output=$("$DELETE_RULE_SCRIPT" BCS01AB --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects invalid BCS code BCS01AB (exit: $exit_code)"
  else
    fail "Should reject invalid BCS code BCS01AB"
  fi
}

test_nonexistent_bcs_code() {
  test_section "Non-Existent BCS Code"
  local -- output
  local -i exit_code=0

  # Test valid format but non-existent code with --dry-run to prevent accidents
  output=$("$DELETE_RULE_SCRIPT" BCS9999 --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects non-existent BCS code BCS9999 (exit: $exit_code)"
  else
    fail "Should reject non-existent BCS code BCS9999"
  fi
}

test_dry_run_mode_prevents_deletion() {
  test_section "Dry-Run Mode Safety"
  local -- output

  # Use existing BCS0101 with --dry-run - should show what would be deleted but not delete
  output=$("$DELETE_RULE_SCRIPT" BCS0101 --dry-run --force 2>&1 < /dev/null) || true

  # Check that dry-run mode is mentioned in output
  if [[ "$output" =~ (dry.run|would.delete|preview|simulation) ]]; then
    pass "Dry-run mode indicated in output"
  else
    warn "Dry-run mode may not be clearly indicated (or code doesn't exist)"
  fi

  # Verify files still exist after dry-run
  if [[ -f "$PROJECT_DIR/data/01-script-structure/01-layout.complete.md" ]]; then
    pass "Files not deleted in dry-run mode"
  else
    warn "Cannot verify dry-run safety (files may not exist)"
  fi
}

test_script_exists
test_help_option
test_help_contains_all_options
test_missing_required_argument
test_invalid_bcs_code_format
test_nonexistent_bcs_code
test_dry_run_mode_prevents_deletion

print_summary
#fin
