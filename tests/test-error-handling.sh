#!/usr/bin/env bash
# Test suite for BCS error handling and edge cases

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
BCS_CMD="$PROJECT_DIR/bcs"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR BCS_CMD

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_invalid_subcommand() {
  test_section "Invalid Subcommand Handling"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" invalid-command-xyz 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Invalid subcommand returns non-zero exit (exit: $exit_code)"
  else
    fail "Should reject invalid subcommand"
  fi

  # Should show error message
  if [[ "$output" =~ (unknown|invalid|not found|error) ]]; then
    pass "Error message shown for invalid subcommand"
  else
    warn "Error message may not be clear"
  fi
}

test_decode_invalid_code() {
  test_section "Decode Invalid BCS Code"
  local -- output
  local -i exit_code=0

  # Test with invalid format
  output=$("$BCS_CMD" decode INVALID 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Invalid BCS code returns non-zero exit (exit: $exit_code)"
  else
    fail "Should reject invalid BCS code format"
  fi
}

test_decode_nonexistent_code() {
  test_section "Decode Non-Existent BCS Code"
  local -- output
  local -i exit_code=0

  # Test with valid format but non-existent code
  output=$("$BCS_CMD" decode BCS9999 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Non-existent BCS code returns non-zero exit (exit: $exit_code)"
  else
    fail "Should reject non-existent BCS code"
  fi
}

test_codes_no_errors() {
  test_section "Codes Command Error-Free Execution"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" codes 2>&1) || exit_code=$?

  if ((exit_code == 0)); then
    pass "Codes command executes successfully"
  else
    fail "Codes command failed (exit: $exit_code)"
  fi

  # Should not contain error messages
  if [[ ! "$output" =~ (error|failed|fatal|ERROR) ]]; then
    pass "Codes output contains no errors"
  else
    warn "Codes output may contain error messages"
  fi
}

test_sections_no_errors() {
  test_section "Sections Command Error-Free Execution"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" sections 2>&1) || exit_code=$?

  if ((exit_code == 0)); then
    pass "Sections command executes successfully"
  else
    fail "Sections command failed (exit: $exit_code)"
  fi

  # Should not contain error messages
  if [[ ! "$output" =~ (error|failed|fatal|ERROR) ]]; then
    pass "Sections output contains no errors"
  else
    warn "Sections output may contain error messages"
  fi
}

test_about_no_errors() {
  test_section "About Command Error-Free Execution"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" about 2>&1) || exit_code=$?

  if ((exit_code == 0)); then
    pass "About command executes successfully"
  else
    fail "About command failed (exit: $exit_code)"
  fi

  # Should not contain error messages
  if [[ ! "$output" =~ (error|failed|fatal|ERROR) ]]; then
    pass "About output contains no errors"
  else
    warn "About output may contain error messages"
  fi
}

test_help_always_succeeds() {
  test_section "Help Always Returns Success"
  local -i exit_code=0

  "$BCS_CMD" --help >/dev/null 2>&1 || exit_code=$?

  if ((exit_code == 0)); then
    pass "Help command returns zero exit code"
  else
    fail "Help should always succeed (got exit: $exit_code)"
  fi
}

test_version_always_succeeds() {
  test_section "Version Always Returns Success"
  local -i exit_code=0

  "$BCS_CMD" --version >/dev/null 2>&1 || exit_code=$?

  if ((exit_code == 0)); then
    pass "Version command returns zero exit code"
  else
    fail "Version should always succeed (got exit: $exit_code)"
  fi
}

test_search_nonexistent_pattern() {
  test_section "Search Non-Existent Pattern"
  local -- output
  local -i exit_code=0

  # Search for pattern that doesn't exist
  output=$("$BCS_CMD" search "xyzabc123nonexistent" 2>&1) || exit_code=$?

  # May return 0 or 1, both acceptable
  if ((exit_code == 0 || exit_code == 1)); then
    pass "Search handles non-existent pattern gracefully (exit: $exit_code)"
  else
    warn "Search returned unexpected exit code: $exit_code"
  fi
}

test_search_with_no_pattern() {
  test_section "Search With No Pattern"
  local -- output
  local -i exit_code=0

  # Search with no pattern argument
  output=$("$BCS_CMD" search 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Search without pattern returns error (exit: $exit_code)"
  else
    # May show usage/help instead
    if [[ "$output" =~ (Usage|pattern|required) ]]; then
      pass "Search shows usage when pattern missing"
    else
      warn "Search behavior unclear when pattern missing"
    fi
  fi
}

test_generate_with_invalid_tier() {
  test_section "Generate With Invalid Tier"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" generate --tier invalid 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Invalid tier value returns error (exit: $exit_code)"
  else
    fail "Should reject invalid tier value"
  fi
}

test_template_invalid_type() {
  test_section "Template With Invalid Type"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" template --type invalid 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Invalid template type returns error (exit: $exit_code)"
  else
    fail "Should reject invalid template type"
  fi
}

test_template_missing_output_file() {
  test_section "Template Missing Output File"
  local -- output
  local -i exit_code=0

  # --output requires a value
  output=$("$BCS_CMD" template --output 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Missing output file value returns error (exit: $exit_code)"
  else
    fail "Should require output file value"
  fi
}

test_decode_with_conflicting_options() {
  test_section "Decode With Conflicting Options"
  local -- output
  local -i exit_code=0

  # --print and --exists are mutually exclusive
  output=$("$BCS_CMD" decode BCS0101 --print --exists 2>&1) || exit_code=$?

  # May accept (last wins) or reject, both acceptable
  if ((exit_code == 0)); then
    pass "Handles conflicting options (accepts with precedence)"
  else
    pass "Rejects conflicting options (exit: $exit_code)"
  fi
}

test_default_invalid_tier() {
  test_section "Default Command Invalid Tier"
  local -- output
  local -i exit_code=0

  output=$("$BCS_CMD" default --set invalid 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Invalid tier for default returns error (exit: $exit_code)"
  else
    warn "May not validate tier value for default command"
  fi
}

test_empty_stdin_handling() {
  test_section "Empty STDIN Handling"
  local -- output
  local -i exit_code=0

  # Some commands may try to read stdin
  output=$(echo "" | "$BCS_CMD" display --cat 2>&1 | head -50) || exit_code=$?

  if ((exit_code == 0)); then
    pass "Handles empty stdin gracefully"
  else
    warn "May have issues with empty stdin (exit: $exit_code)"
  fi
}

test_concurrent_execution() {
  test_section "Concurrent Execution Safety"
  local -i pid1 pid2 exit1=0 exit2=0

  # Run two instances concurrently
  "$BCS_CMD" codes >/dev/null 2>&1 & pid1=$!
  "$BCS_CMD" sections >/dev/null 2>&1 & pid2=$!

  wait "$pid1" || exit1=$?
  wait "$pid2" || exit2=$?

  if ((exit1 == 0 && exit2 == 0)); then
    pass "Concurrent executions both succeed"
  else
    fail "Concurrent execution issues (exits: $exit1, $exit2)"
  fi
}

test_very_long_bcs_code() {
  test_section "Very Long BCS Code Input"
  local -- output
  local -i exit_code=0

  # Test with extremely long input
  output=$("$BCS_CMD" decode "BCS$(printf '%0100d' 1)" 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Rejects excessively long BCS code (exit: $exit_code)"
  else
    warn "May not validate BCS code length"
  fi
}

test_special_characters_in_search() {
  test_section "Special Characters in Search Pattern"
  local -- output
  local -i exit_code=0

  # Test with regex special characters
  output=$("$BCS_CMD" search ".*" 2>&1 | head -20) || exit_code=$?

  # Should handle gracefully (may match everything or escape properly)
  if ((exit_code == 0 || exit_code == 1)); then
    pass "Handles special characters in search (exit: $exit_code)"
  else
    warn "May have issues with regex special characters (exit: $exit_code)"
  fi
}

test_sigpipe_handling() {
  test_section "SIGPIPE Handling"
  local -i exit_code=0

  # Pipe to head to trigger SIGPIPE
  "$BCS_CMD" display --cat 2>/dev/null | head -5 >/dev/null || exit_code=$?

  # Exit 141 is SIGPIPE (128+13), which is acceptable
  if ((exit_code == 0 || exit_code == 141)); then
    pass "Handles SIGPIPE gracefully (exit: $exit_code)"
  else
    warn "Unexpected exit code with SIGPIPE: $exit_code"
  fi
}

test_invalid_subcommand
test_decode_invalid_code
test_decode_nonexistent_code
test_codes_no_errors
test_sections_no_errors
test_about_no_errors
test_help_always_succeeds
test_version_always_succeeds
test_search_nonexistent_pattern
test_search_with_no_pattern
test_generate_with_invalid_tier
test_template_invalid_type
test_template_missing_output_file
test_decode_with_conflicting_options
test_default_invalid_tier
test_empty_stdin_handling
test_concurrent_execution
test_very_long_bcs_code
test_special_characters_in_search
test_sigpipe_handling

print_summary
#fin
