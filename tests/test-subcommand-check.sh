#!/usr/bin/env bash
# test-subcommand-check.sh - Tests for bcs check subcommand
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: check subcommand'

# Test: check requires a file argument
begin_test 'check requires file argument'
assert_fails 'no file argument' "$BCS_CMD" check || true

# Test: check rejects nonexistent file
begin_test 'check rejects nonexistent file'
assert_fails 'nonexistent file' "$BCS_CMD" check /nonexistent/file.sh || true

# Test: check help
begin_test 'check -h shows help'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'bcs check' 'help has command name' || true

# Test: check rejects multiple files
begin_test 'check rejects multiple files'
temp1=$(mktemp --suffix=.sh)
temp2=$(mktemp --suffix=.sh)
echo '#!/bin/bash' > "$temp1"
echo '#!/bin/bash' > "$temp2"
assert_fails 'multiple files rejected' "$BCS_CMD" check "$temp1" "$temp2" || true
rm -f "$temp1" "$temp2"

# Skip actual claude invocation test (requires claude CLI)
echo '  (skipping live claude tests - requires claude CLI)'

print_summary 'check'
#fin
