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

# Test: check help includes --model
begin_test 'check help includes --model'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--model' 'help mentions --model' || true

# Test: check help includes --fast
begin_test 'check help includes --fast'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--fast' 'help mentions --fast' || true

# Test: check --model requires argument
begin_test 'check --model requires argument'
assert_fails 'model needs arg' "$BCS_CMD" check --model || true

# Test: check help includes --strict
begin_test 'check help includes --strict'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--strict' 'help mentions --strict' || true

# Test: check help includes --quiet
begin_test 'check help includes --quiet'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--quiet' 'help mentions --quiet' || true

# Test: check rejects unreadable file
begin_test 'check rejects unreadable file'
unreadable=$(mktemp --suffix=.sh)
echo '#!/bin/bash' > "$unreadable"
chmod 000 "$unreadable"
assert_fails 'unreadable file' "$BCS_CMD" check "$unreadable" || true
rm -f "$unreadable"

# Test: option bundling -sf
begin_test 'option bundling -sf parsed'
# -sf should not error on option parsing (will fail on missing file, not option)
err=$("$BCS_CMD" check -sf 2>&1 || true)
assert_not_contains "$err" 'Invalid option' '-sf bundling parsed correctly' || true

# Test: -- separator works
begin_test '-- separator works'
assert_fails '-- then nonexistent' "$BCS_CMD" check -- /nonexistent/file.sh || true

# Skip actual claude invocation test (requires claude CLI)
echo '  (skipping live claude tests - requires claude CLI)'

print_summary 'check'
#fin
