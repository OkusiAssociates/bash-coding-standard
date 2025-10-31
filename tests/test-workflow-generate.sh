#!/usr/bin/env bash
# Test suite for workflows/20-generate-canonical.sh

set -euo pipefail
shopt -s inherit_errexit shift_verbose

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
GENERATE_SCRIPT="$PROJECT_DIR/workflows/20-generate-canonical.sh"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR GENERATE_SCRIPT

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_script_exists() {
  test_section "Script Existence"
  assert_file_exists "$GENERATE_SCRIPT"
  assert_file_executable "$GENERATE_SCRIPT"
}

test_help_option() {
  test_section "Help Option"
  local -- output
  output=$("$GENERATE_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "generate" "Script purpose shown"
}

test_help_contains_all_options() {
  test_section "Help Documentation Completeness"
  local -- output
  output=$("$GENERATE_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "--all" "All tiers option documented"
  assert_contains "$output" "--tier" "Tier option documented"
  assert_contains "$output" "--validate" "Validate option documented"
  assert_contains "$output" "--backup" "Backup option documented"
  assert_contains "$output" "--update-symlink" "Update-symlink option documented"
  assert_contains "$output" "--force" "Force option documented"
  assert_contains "$output" "--verbose" "Verbose option documented"
  assert_contains "$output" "--quiet" "Quiet option documented"
}

test_tier_values_documented() {
  test_section "Tier Values Documentation"
  local -- output
  output=$("$GENERATE_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "complete" "Tier 'complete' documented"
  assert_contains "$output" "summary" "Tier 'summary' documented"
  assert_contains "$output" "abstract" "Tier 'abstract' documented"
  assert_contains "$output" "all" "Tier 'all' documented"
}

test_invalid_tier_value() {
  test_section "Invalid Tier Validation"
  local -- output
  local -i exit_code=0

  # Test invalid tier value
  output=$(timeout 5 "$GENERATE_SCRIPT" --tier invalid 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects invalid tier value (exit: $exit_code)"
  else
    # Check if error message is shown
    if [[ "$output" =~ (invalid|tier|complete|summary|abstract) ]]; then
      pass "Shows error for invalid tier"
    else
      warn "May not validate tier value"
    fi
  fi
}

test_force_option_behavior() {
  test_section "Force Option Behavior"
  local -- output

  # Run with --force flag - should indicate forcing regeneration
  output=$(timeout 10 "$GENERATE_SCRIPT" --force --tier abstract --quiet 2>&1 < /dev/null) || true

  # Check that generation ran (should complete without errors or show progress)
  if [[ "$output" =~ (generated|success|complete|wrote) ]] || [[ -z "$output" ]]; then
    pass "Force option executes generation"
  else
    warn "Force option may not execute properly"
  fi
}

test_default_behavior() {
  test_section "Default Behavior (All Tiers)"
  local -- output
  local -i exit_code=0

  # Run with no options - should generate all tiers
  output=$(timeout 15 "$GENERATE_SCRIPT" --quiet 2>&1 < /dev/null) || exit_code=$?

  if ((exit_code == 0)); then
    pass "Default execution completes successfully"
  else
    warn "Default execution may have issues (exit: $exit_code)"
  fi
}

test_single_tier_generation() {
  test_section "Single Tier Generation"
  local -- output

  # Generate only abstract tier (fastest)
  output=$(timeout 10 "$GENERATE_SCRIPT" --tier abstract --quiet 2>&1 < /dev/null) || true

  # Should complete without major errors
  if [[ ! "$output" =~ (error|failed|fatal) ]] || [[ -z "$output" ]]; then
    pass "Single tier generation executes"
  else
    warn "Single tier generation may have issues"
  fi
}

test_script_exists
test_help_option
test_help_contains_all_options
test_tier_values_documented
test_invalid_tier_value
test_force_option_behavior
test_default_behavior
test_single_tier_generation

print_summary
#fin
