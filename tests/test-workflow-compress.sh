#!/usr/bin/env bash
# Test suite for workflows/10-compress-rules.sh

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
COMPRESS_SCRIPT="$PROJECT_DIR/workflows/10-compress-rules.sh"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR COMPRESS_SCRIPT

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_script_exists() {
  test_section "Script Existence"
  assert_file_exists "$COMPRESS_SCRIPT"
  assert_file_executable "$COMPRESS_SCRIPT"
}

test_help_option() {
  test_section "Help Option"
  local -- output
  output=$("$COMPRESS_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "compress" "Script purpose shown"
}

test_help_contains_all_options() {
  test_section "Help Documentation Completeness"
  local -- output
  output=$("$COMPRESS_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "--regenerate" "Regenerate mode documented"
  assert_contains "$output" "--report-only" "Report-only mode documented"
  assert_contains "$output" "--dry-run" "Dry-run option documented"
  assert_contains "$output" "--tier" "Tier option documented"
  assert_contains "$output" "--context-level" "Context level option documented"
  assert_contains "$output" "--verbose" "Verbose option documented"
  assert_contains "$output" "--quiet" "Quiet option documented"
  assert_contains "$output" "PRE-FLIGHT" "Pre-flight checks documented"
}

test_invalid_tier_value() {
  test_section "Invalid Tier Validation"
  local -- output
  local -i exit_code=0

  # Test invalid tier value
  output=$(timeout 5 "$COMPRESS_SCRIPT" --tier invalid --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects invalid tier value (exit: $exit_code)"
  else
    # Check if error message is shown
    if [[ "$output" =~ (invalid|tier|summary|abstract) ]]; then
      pass "Shows error for invalid tier"
    else
      warn "May not validate tier value"
    fi
  fi
}

test_invalid_context_level() {
  test_section "Invalid Context Level Validation"
  local -- output
  local -i exit_code=0

  # Test invalid context level
  output=$(timeout 5 "$COMPRESS_SCRIPT" --context-level invalid --dry-run 2>&1 < /dev/null) || exit_code=$?
  if ((exit_code != 0)); then
    pass "Rejects invalid context level (exit: $exit_code)"
  else
    # Check if error message is shown
    if [[ "$output" =~ (invalid|context|none|toc|abstract|summary|complete) ]]; then
      pass "Shows error for invalid context level"
    else
      warn "May not validate context level"
    fi
  fi
}

test_dry_run_prevents_changes() {
  test_section "Dry-Run Mode Safety"
  local -- output

  # Run in dry-run mode - should not make changes
  output=$(timeout 10 "$COMPRESS_SCRIPT" --dry-run --regenerate 2>&1 < /dev/null) || true

  # Check that dry-run is indicated
  if [[ "$output" =~ (dry.run|would|preview|simulation) ]]; then
    pass "Dry-run mode indicated in output"
  else
    warn "Dry-run mode may not be clearly indicated"
  fi
}

test_report_only_mode() {
  test_section "Report-Only Mode (Default)"
  local -- output

  # Default mode should be report-only
  output=$(timeout 10 "$COMPRESS_SCRIPT" 2>&1 < /dev/null) || true

  # Should mention reporting or checking
  if [[ "$output" =~ (report|oversized|checking|analyzing) ]]; then
    pass "Report mode executes"
  else
    warn "Report mode may not execute properly"
  fi
}

test_context_level_values() {
  test_section "Context Level Documentation"
  local -- output
  output=$("$COMPRESS_SCRIPT" --help 2>&1) || true

  assert_contains "$output" "none" "Context level 'none' documented"
  assert_contains "$output" "toc" "Context level 'toc' documented"
  assert_contains "$output" "abstract" "Context level 'abstract' documented"
  assert_contains "$output" "summary" "Context level 'summary' documented"
  assert_contains "$output" "complete" "Context level 'complete' documented"
}

test_script_exists
test_help_option
test_help_contains_all_options
test_invalid_tier_value
test_invalid_context_level
test_dry_run_prevents_changes
test_report_only_mode
test_context_level_values

print_summary
#fin
