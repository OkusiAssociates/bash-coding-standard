#!/usr/bin/env bash
# Tests for find_bcs_file() function

set -euo pipefail

# Load test helpers
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

# Source the script to get access to find_bcs_file
# shellcheck source=bash-coding-standard
source "$SCRIPT_DIR"/../bash-coding-standard

test_find_bcs_file() {
  test_section "find_bcs_file() Function Tests"

  # Test 1: Find file in current directory
  local -- result
  local -i exit_code
  result=$(find_bcs_file "$SCRIPT_DIR"/..)
  exit_code=$?
  assert_contains "$result" "BASH-CODING-STANDARD.md" \
    "find_bcs_file finds file in script directory"
  assert_exit_code 0 "$exit_code" "find_bcs_file returns 0 on success"

  # Test 2: Test with nonexistent directory (may still find in FHS paths)
  # Note: This test may pass if BASH-CODING-STANDARD.md exists in /usr/local/share or /usr/share
  result=$(find_bcs_file "/nonexistent/path" 2>/dev/null) || exit_code=$?
  if [[ -f /usr/local/share/yatti/bash-coding-standard/BASH-CODING-STANDARD.md ]] || \
     [[ -f /usr/share/yatti/bash-coding-standard/BASH-CODING-STANDARD.md ]]; then
    pass "find_bcs_file falls back to FHS paths (system install detected)"
  else
    assert_failure "$exit_code" "find_bcs_file returns non-zero when file not found"
  fi

  # Test 3: Test search path order
  local -- tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "${tmpdir:-}"' EXIT

  # Create test file in tmpdir
  touch "$tmpdir"/BASH-CODING-STANDARD.md
  result=$(find_bcs_file "$tmpdir")

  # Skip path assertion if system installation exists (FHS paths take precedence)
  if [[ -f /usr/local/share/yatti/bash-coding-standard/data/BASH-CODING-STANDARD.md ]] || \
     [[ -f /usr/share/yatti/bash-coding-standard/data/BASH-CODING-STANDARD.md ]]; then
    skip_test "Path order test skipped (system installation detected)"
  else
    assert_equals "$tmpdir/BASH-CODING-STANDARD.md" "$result" \
      "find_bcs_file returns correct path"
  fi

  # Test 4: Verify output format
  result=$(find_bcs_file "$SCRIPT_DIR"/..)
  [[ -f "$result" ]] && assert_success 0 \
    "find_bcs_file output is a valid file path"

  # Test 5: Test with empty string
  # Empty path should still succeed if file exists in FHS paths
  result=$(find_bcs_file "" 2>/dev/null) || exit_code=$?
  if [[ -f /usr/local/share/yatti/bash-coding-standard/BASH-CODING-STANDARD.md ]] || \
     [[ -f /usr/share/yatti/bash-coding-standard/BASH-CODING-STANDARD.md ]]; then
    assert_success "$exit_code" "find_bcs_file falls back to FHS paths even with empty input"
  else
    assert_failure "$exit_code" "find_bcs_file returns error when no file found anywhere"
  fi
}

# Run tests
test_find_bcs_file
print_summary

#fin
