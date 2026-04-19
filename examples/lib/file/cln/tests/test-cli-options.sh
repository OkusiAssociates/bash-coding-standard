#!/usr/bin/env bash
# Test CLI option parsing for cln
set -euo pipefail
shopt -s inherit_errexit

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

declare -r CLN="$SCRIPT_DIR/../cln"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test_help_option() {
  test_section "Help Option (-h, --help)"

  local output exit_code=0

  output=$("$CLN" -h 2>&1) || exit_code=$?
  assert_success $exit_code "-h exits with 0"
  assert_contains "$output" "Usage:" "-h shows usage"
  assert_contains "$output" "Options:" "-h shows options"

  exit_code=0
  output=$("$CLN" --help 2>&1) || exit_code=$?
  assert_success $exit_code "--help exits with 0"
  assert_contains "$output" "Usage:" "--help shows usage"
}

test_version_option() {
  test_section "Version Option (-V, --version)"

  local output exit_code=0

  output=$("$CLN" -V 2>&1) || exit_code=$?
  assert_success $exit_code "-V exits with 0"
  assert_regex_match "$output" "cln [0-9]+\.[0-9]+\.[0-9]+" "-V shows version"

  exit_code=0
  output=$("$CLN" --version 2>&1) || exit_code=$?
  assert_success $exit_code "--version exits with 0"
}

test_invalid_option() {
  test_section "Invalid Option Handling"

  local output exit_code=0

  output=$("$CLN" -x 2>&1) || exit_code=$?
  assert_exit_code 22 $exit_code "Invalid option exits with 22"
  assert_contains "$output" "Invalid option" "Shows error message"

  exit_code=0
  output=$("$CLN" --invalid-option 2>&1) || exit_code=$?
  assert_exit_code 22 $exit_code "Invalid long option exits with 22"
}

test_missing_argument() {
  test_section "Missing Argument Handling"

  local output exit_code=0

  output=$("$CLN" -m 2>&1) || exit_code=$?
  assert_exit_code 22 $exit_code "-m without arg exits with 22"
  assert_contains "$output" "requires an argument" "Shows missing arg error"

  exit_code=0
  output=$("$CLN" -a 2>&1) || exit_code=$?
  assert_exit_code 22 $exit_code "-a without arg exits with 22"
}

test_quiet_option() {
  test_section "Quiet Option (-q, --quiet)"

  local temp_dir output exit_code=0
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Without -q, should have output
  output=$("$CLN" -P "$temp_dir" 2>&1) || exit_code=$?
  assert_not_empty "$output" "Default mode has output"

  # With -q, should be silent
  output=$("$CLN" -Pq "$temp_dir" 2>&1) || exit_code=$?
  if [[ -z "$output" ]]; then
    pass "-q suppresses output"
  else
    fail "-q should suppress output, got: $output"
  fi
}

test_depth_option() {
  test_section "Depth Option (-m, --depth)"

  local output exit_code=0

  # Help text documents default depth
  output=$("$CLN" -h 2>&1) || exit_code=$?
  assert_contains "$output" "Default: 3" "Help shows default depth 3"

  # -m -1 should work (unlimited)
  exit_code=0
  output=$("$CLN" -m -1 -h 2>&1) || exit_code=$?
  assert_success $exit_code "-m -1 is valid"

  # Non-numeric arg should fail
  exit_code=0
  output=$("$CLN" -m abc 2>&1) || exit_code=$?
  assert_exit_code 22 $exit_code "-m abc exits with 22"
}

test_combined_options() {
  test_section "Combined Short Options"

  local temp_dir output exit_code=0
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # -Pqm should work
  output=$("$CLN" -Pqm 5 "$temp_dir" 2>&1) || exit_code=$?
  assert_success $exit_code "-Pqm 5 works"

  # -vv should work (verbose level 2)
  exit_code=0
  output=$("$CLN" -Pvv "$temp_dir" 2>&1) || exit_code=$?
  assert_success $exit_code "-Pvv works"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Run tests
test_help_option
test_version_option
test_invalid_option
test_missing_argument
test_quiet_option
test_depth_option
test_combined_options

# Print summary
print_summary
#fin
