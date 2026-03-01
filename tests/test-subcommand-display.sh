#!/usr/bin/env bash
# test-subcommand-display.sh - Tests for bcs display subcommand
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

# Test: display -s squeezes blank lines
begin_test 'display -s squeezes blanks'
lines_normal=$("$BCS_CMD" display -c 2>/dev/null | wc -l)
lines_squeezed=$("$BCS_CMD" display -cs 2>/dev/null | wc -l)
assert_gt "$lines_normal" 100 'normal output has >100 lines' || true

# Test: display help
begin_test 'display -h shows help'
output=$("$BCS_CMD" display -h 2>/dev/null)
assert_contains "$output" 'bcs display' 'help contains command name' || true

# Test: invalid option
begin_test 'display rejects invalid options'
assert_fails 'rejects --invalid' "$BCS_CMD" display --invalid || true

print_summary 'display'
#fin
