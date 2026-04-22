#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-subcommand-codes.sh - Tests for bcs codes subcommand
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: codes subcommand'

# Test: codes produces output
begin_test 'codes produces output'
output=$("$BCS_CMD" codes 2>/dev/null)
assert_not_empty "$output" 'codes produces output' || true

# Test: codes output format
begin_test 'codes output format is BCS#### Title'
first_line=$(echo "$output" | head -1)
assert_matches "$first_line" '^BCS[0-9]+ .+' 'first line matches format' || true

# Test: codes count is reasonable (should be ~100)
begin_test 'codes count is reasonable'
code_count=$(echo "$output" | wc -l)
assert_gt "$code_count" 80 'at least 80 codes' || true

# Test: key codes present
begin_test 'BCS0101 present'
assert_contains "$output" 'BCS0101' 'BCS0101 found' || true

begin_test 'BCS0505 present'
assert_contains "$output" 'BCS0505' 'BCS0505 found' || true

begin_test 'BCS1206 present'
assert_contains "$output" 'BCS1206' 'BCS1206 found' || true

# Test: all 12 sections represented
begin_test 'all 12 sections represented'
declare -i sections_found=0
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
  if [[ "$output" == *"BCS${i}"* ]]; then
    sections_found+=1
  fi
done
assert_equal 12 "$sections_found" 'all 12 sections have codes' || true

# Test: exact code count is 110 (12 section overviews + 98 substantive rules)
begin_test 'exactly 110 BCS codes'
assert_equal 110 "$code_count" "exactly 110 codes (got $code_count)" || true

# Test: codes are in ascending order
begin_test 'codes are in ascending order'
sorted_output=$(echo "$output" | sort -t' ' -k1,1)
if [[ "$output" == "$sorted_output" ]]; then
  printf '  %s✓%s codes are sorted ascending\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s codes are not sorted\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

# Test: codes help
begin_test 'codes -h shows help'
help_output=$("$BCS_CMD" codes -h 2>/dev/null)
assert_contains "$help_output" 'bcs codes' 'help has command name' || true

# Test: codes rejects invalid options
begin_test 'codes rejects invalid options'
assert_fails 'rejects --bogus' "$BCS_CMD" codes --bogus || true

print_summary 'codes'
#fin
