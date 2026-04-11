#!/usr/bin/env bash
# test-subcommand-display.sh - Tests for bcs display subcommand
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: display subcommand'

# Test: default display outputs content
begin_test 'display outputs standard content'
output=$("$BCS_CMD" display -c 2>/dev/null)
assert_contains "$output" 'Bash Coding Standard' 'default display contains title' || true

# Test: display -c outputs plain text
begin_test 'display -c outputs plain text'
output=$("$BCS_CMD" display -c 2>/dev/null)
assert_contains "$output" 'BCS0101' 'cat output contains BCS0101' || true

# Test: display -c produces substantial output
begin_test 'display -c has >100 lines'
lines_normal=$("$BCS_CMD" display -c 2>/dev/null | wc -l)
assert_gt "$lines_normal" 100 'normal output has >100 lines' || true

# Test: display help
begin_test 'display -h shows help'
output=$("$BCS_CMD" display -h 2>/dev/null)
assert_contains "$output" 'bcs display' 'help contains command name' || true

# Test: --file returns path to standard
begin_test 'display --file returns path'
file_path=$("$BCS_CMD" display --file 2>/dev/null)
assert_contains "$file_path" 'BASH-CODING-STANDARD.md' '--file returns path to standard' || true

# Test: --file output is a valid file
begin_test 'display --file path exists'
assert_file_exists "$file_path" '--file path is valid' || true

# Test: no-subcommand defaults to display
begin_test 'no subcommand defaults to display'
output=$("$BCS_CMD" -c 2>/dev/null)
assert_contains "$output" 'Bash Coding Standard' 'no subcommand shows standard' || true

# Test: option bundling -cf
begin_test 'option bundling -cf works'
bundled_path=$("$BCS_CMD" display -cf 2>/dev/null)
assert_contains "$bundled_path" 'BASH-CODING-STANDARD.md' '-cf bundling works' || true

# Test: --symlink creates symlink
begin_test 'display --symlink creates symlink'
tmpdir=$(mktemp -d)
(cd "$tmpdir" && "$BCS_CMD" display --symlink &>/dev/null)
if [[ -L "$tmpdir"/BASH-CODING-STANDARD.md ]]; then
  printf '  %s✓%s --symlink creates symlink\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s --symlink did not create symlink\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi
rm -rf "$tmpdir"

# Test: invalid option
begin_test 'display rejects invalid options'
assert_fails 'rejects --invalid' "$BCS_CMD" display --invalid || true

# Test: removed -s/--squeeze option is rejected
begin_test 'display rejects removed -s option'
assert_fails 'rejects -s (removed)' "$BCS_CMD" display -s || true

print_summary 'display'
#fin
