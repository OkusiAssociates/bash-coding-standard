#!/usr/bin/env bash
# Test suite for workflows/modify-rule.sh

set -euo pipefail
shopt -s inherit_errexit shift_verbose

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
MODIFY_RULE_SCRIPT="$PROJECT_DIR/workflows/02-modify-rule.sh"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR MODIFY_RULE_SCRIPT

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_script_exists() {
  test_section "Script Existence"
  assert_file_exists "$MODIFY_RULE_SCRIPT"
  assert_file_executable "$MODIFY_RULE_SCRIPT"
}

test_help_option() {
  test_section "Help Option"
  local -- output
  output=$("$MODIFY_RULE_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "CODE_OR_FILE" "Required argument documented"
}

test_help_contains_all_options() {
  test_section "Help Documentation Completeness"
  local -- output
  output=$("$MODIFY_RULE_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "--editor" "Editor option documented"
  assert_contains "$output" "--no-backup" "Backup option documented"
  assert_contains "$output" "--no-compress" "Compress option documented"
  assert_contains "$output" "--validate" "Validate option documented"
  assert_contains "$output" "--quiet" "Quiet option documented"
  assert_contains "$output" "CODE_OR_FILE" "Required argument documented"
}

test_missing_required_argument() {
  test_section "Missing Required Argument"
  local -- output

  # Test with no argument - script shows error message but may not exit with error code
  output=$(timeout 2 "$MODIFY_RULE_SCRIPT" 2>&1 < /dev/null) || true
  assert_contains "$output" "No BCS code or file specified" "Shows error for missing argument"
}

test_invalid_bcs_code_format() {
  test_section "Invalid BCS Code Format"
  local -- output
  local -i exit_code

  # Test invalid format (missing digits)
  exit_code=0
  output=$("$MODIFY_RULE_SCRIPT" BCS01 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects incomplete BCS code BCS01 (exit: $exit_code)"
  else
    fail "Should reject incomplete BCS code BCS01"
  fi

  # Test invalid format (lowercase)
  exit_code=0
  output=$("$MODIFY_RULE_SCRIPT" bcs0101 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects lowercase BCS code bcs0101 (exit: $exit_code)"
  else
    fail "Should reject lowercase BCS code bcs0101"
  fi

  # Test invalid format (letters in number)
  exit_code=0
  output=$("$MODIFY_RULE_SCRIPT" BCS01AB 2>&1 < /dev/null) || exit_code=$?
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

  # Test valid format but non-existent code
  output=$("$MODIFY_RULE_SCRIPT" BCS9999 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects non-existent BCS code BCS9999 (exit: $exit_code)"
  else
    fail "Should reject non-existent BCS code BCS9999"
  fi
}

test_nonexistent_file_path() {
  test_section "Non-Existent File Path"
  local -- output
  local -i exit_code=0

  # Test with non-existent file path
  output=$("$MODIFY_RULE_SCRIPT" /tmp/nonexistent-file.complete.md 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects non-existent file path (exit: $exit_code)"
  else
    fail "Should reject non-existent file path"
  fi
}

test_invalid_file_extension() {
  test_section "Invalid File Extension"
  local -- output tmpfile
  local -i exit_code=0

  # Create temp file with wrong extension
  tmpfile=$(mktemp --suffix=.txt)
  trap 'rm -f "$tmpfile"' RETURN

  output=$("$MODIFY_RULE_SCRIPT" "$tmpfile" 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects file without .complete.md extension (exit: $exit_code)"
  else
    fail "Should reject file without .complete.md extension"
  fi
}

test_script_exists
test_help_option
test_help_contains_all_options
test_missing_required_argument
test_invalid_bcs_code_format
test_nonexistent_bcs_code
test_nonexistent_file_path
test_invalid_file_extension

print_summary
#fin
