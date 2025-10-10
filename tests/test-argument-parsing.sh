#!/usr/bin/env bash
# Tests for command-line argument parsing

set -euo pipefail

# Load test helpers
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

SCRIPT="$SCRIPT_DIR"/../bash-coding-standard

test_help_options() {
  test_section "Help Option Tests"

  # Test --help
  local -- output
  output=$("$SCRIPT" --help 2>&1)
  assert_contains "$output" "Usage:" "bash-coding-standard --help shows usage"
  assert_contains "$output" "Options:" "bash-coding-standard --help shows options"
  assert_contains "$output" "Examples:" "bash-coding-standard --help shows examples"

  # Test -h
  output=$("$SCRIPT" -h 2>&1)
  assert_contains "$output" "Usage:" "bash-coding-standard -h shows usage"

  # Test exit code
  "$SCRIPT" --help >/dev/null 2>&1
  assert_exit_code 0 $? "bash-coding-standard --help exits with 0"
}

test_cat_options() {
  test_section "Cat Option Tests"

  # Test --cat
  local -- output
  output=$("$SCRIPT" --cat 2>&1 | head -5)
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard --cat shows content"
  assert_not_contains "$output" "\033" "bash-coding-standard --cat has no ANSI codes"

  # Test -c
  output=$("$SCRIPT" -c 2>&1 | head -5)
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard -c shows content"

  # Test -  (dash)
  output=$("$SCRIPT" - 2>&1 | head -5)
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard - shows content"

  # Test exit code
  "$SCRIPT" --cat >/dev/null 2>&1
  assert_exit_code 0 $? "bash-coding-standard --cat exits with 0"
}

test_bash_option() {
  test_section "Bash Declare Option Tests"

  # Test --bash
  local -- output
  output=$("$SCRIPT" --bash 2>&1)
  assert_contains "$output" "declare" "bash-coding-standard --bash outputs declare"
  assert_contains "$output" "BCS_MD" "bash-coding-standard --bash declares BCS_MD"

  # Test -b
  output=$("$SCRIPT" -b 2>&1)
  assert_contains "$output" "declare" "bash-coding-standard -b outputs declare"

  # Test exit code
  "$SCRIPT" --bash >/dev/null 2>&1
  assert_exit_code 0 $? "bash-coding-standard --bash exits with 0"
}

test_md2ansi_option() {
  test_section "md2ansi Option Tests"

  # Test --md2ansi (only if md2ansi is available)
  if command -v md2ansi &>/dev/null; then
    local -- output
    local -i exit_code=0

    # SIGPIPE (141) is expected when piping to head
    output=$("$SCRIPT" --md2ansi 2>&1 | head -20) || exit_code=$?
    [[ "$exit_code" -eq 0 || "$exit_code" -eq 141 ]] && exit_code=0
    assert_success "$exit_code" "bash-coding-standard --md2ansi succeeds when md2ansi available"

    # Test -a
    exit_code=0
    output=$("$SCRIPT" -a 2>&1 | head -20) || exit_code=$?
    [[ "$exit_code" -eq 0 || "$exit_code" -eq 141 ]] && exit_code=0
    assert_success "$exit_code" "bash-coding-standard -a succeeds when md2ansi available"
  else
    echo "Skipping --md2ansi tests (md2ansi not available)"
  fi
}

test_json_option() {
  test_section "JSON Option Tests"

  local -- output

  # Test --json produces valid JSON
  output=$("$SCRIPT" --json 2>&1)

  # Validate JSON format
  if command -v jq &>/dev/null; then
    echo "$output" | jq -e '.["bash-coding-standard"]' >/dev/null 2>&1
    assert_success $? "bash-coding-standard --json produces valid JSON"
  elif command -v python3 &>/dev/null; then
    echo "$output" | python3 -m json.tool >/dev/null 2>&1
    assert_success $? "bash-coding-standard --json produces valid JSON"
  fi

  # Test JSON contains expected content
  assert_contains "$output" '"bash-coding-standard"' "JSON output contains bash-coding-standard key"
  assert_contains "$output" "Bash Coding Standard" "JSON output contains document content"

  # Test -j short option
  output=$("$SCRIPT" -j 2>&1)
  assert_contains "$output" '"bash-coding-standard"' "bash-coding-standard -j produces JSON"

  # Test exit code
  "$SCRIPT" --json >/dev/null 2>&1
  assert_exit_code 0 $? "bash-coding-standard --json exits with 0"
}

test_short_option_bundling() {
  test_section "Short Option Bundling Tests"

  # Test -hc
  local -- output
  output=$("$SCRIPT" -hc 2>&1)
  assert_contains "$output" "Usage:" "bash-coding-standard -hc processes -h first"

  # Test -ch
  output=$("$SCRIPT" -ch 2>&1)
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard -ch processes -c and -h"

  # Test -cb
  output=$("$SCRIPT" -cb 2>&1 | head -5)
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard -cb processes both flags"

  # Test -ba
  output=$("$SCRIPT" -ba 2>&1 | head -5)
  if command -v md2ansi &>/dev/null; then
    assert_success $? "bash-coding-standard -ba processes both flags"
  else
    assert_contains "$output" "declare" "bash-coding-standard -ba processes -b when md2ansi unavailable"
  fi
}

test_viewer_args_passthrough() {
  test_section "Viewer Arguments Passthrough Tests"

  # Test passing -n (line numbers) to cat
  local -- output
  local -i exit_code=0
  output=$("$SCRIPT" -c -n 2>&1 | head -5) || exit_code=$?
  # SIGPIPE is acceptable
  [[ "$exit_code" -eq 0 || "$exit_code" -eq 141 ]] && exit_code=0
  assert_success "$exit_code" "bash-coding-standard -c -n succeeds"
  # -n should be passed to cat, so we should see line numbers
  assert_contains "$output" "^\s*[0-9]" "bash-coding-standard -c -n passes -n to cat"

  # Test multiple viewer args
  exit_code=0
  output=$("$SCRIPT" --cat -n -b 2>&1 | head -5) || exit_code=$?
  [[ "$exit_code" -eq 0 || "$exit_code" -eq 141 ]] && exit_code=0
  assert_success "$exit_code" "bash-coding-standard --cat with multiple viewer args succeeds"
}

test_invalid_options() {
  test_section "Invalid Option Tests"

  # Test invalid option at beginning
  local -- output
  output=$("$SCRIPT" non-option-arg 2>&1) || true
  assert_contains "$output" "error:" "bash-coding-standard rejects non-option arguments"

  # Test invalid option with dash
  # Note: Unknown long options are passed to viewer (cat), which reports the error
  output=$("$SCRIPT" --invalid-option 2>&1) || true
  assert_contains "$output" "option" "bash-coding-standard passes invalid options to viewer"
}

test_no_arguments() {
  test_section "No Arguments Test"

  # Test running with no arguments (should use auto-detection)
  local -- output
  output=$("$SCRIPT" 2>&1 | head -10)
  assert_success $? "bash-coding-standard with no args succeeds"
  assert_contains "$output" "Bash Coding Standard" "bash-coding-standard with no args shows content"
}

test_option_order() {
  test_section "Option Order Tests"

  # Test that last option wins
  local -- output
  output=$("$SCRIPT" --cat --bash 2>&1 | head -2)
  assert_contains "$output" "declare" "bash-coding-standard --cat --bash: last option (--bash) wins"

  # Test help overrides everything
  output=$("$SCRIPT" --help --cat --bash 2>&1)
  assert_contains "$output" "Usage:" "bash-coding-standard --help overrides other options"
}

# Run all tests
test_help_options
test_cat_options
test_bash_option
test_md2ansi_option
test_json_option
test_short_option_bundling
test_viewer_args_passthrough
test_invalid_options
test_no_arguments
test_option_order

print_summary

#fin
