#!/usr/bin/env bash
# test-subcommand-check.sh - Tests for bcs check subcommand
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
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

# Test: check help includes --effort
begin_test 'check help includes --effort'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--effort' 'help mentions --effort' || true

# Test: check --model requires argument
begin_test 'check --model requires argument'
assert_fails 'model needs arg' "$BCS_CMD" check --model || true

# Test: check --effort requires argument
begin_test 'check --effort requires argument'
assert_fails 'effort needs arg' "$BCS_CMD" check --effort || true

# Test: check rejects invalid effort level
begin_test 'check rejects invalid effort level'
temp=$(mktemp --suffix=.sh)
echo '#!/bin/bash' > "$temp"
assert_fails 'invalid effort rejected' "$BCS_CMD" check --effort bogus "$temp" || true
rm -f "$temp"

# Test: check accepts arbitrary --model pass-through
# Use -h to short-circuit before any backend call; we only exercise the parser.
# A direct model name must NOT error at the argparse stage.
begin_test 'accepts arbitrary --model pass-through'
assert_success 'direct model name accepted' \
  "$BCS_CMD" check -m claude-opus-4-6 -h || true

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

# Test: option bundling -se
begin_test 'option bundling -se parsed'
# -se should not error on option parsing (will fail on missing effort arg, not option)
err=$("$BCS_CMD" check -se 2>&1 || true)
assert_not_contains "$err" 'Invalid option' '-se bundling parsed correctly' || true

# Test: -- separator works
begin_test '-- separator works'
assert_fails '-- then nonexistent' "$BCS_CMD" check -- /nonexistent/file.sh || true

# Test: check help includes --backend
begin_test 'check help includes --backend'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" '--backend' 'help mentions --backend' || true

# Test: check --backend requires argument
begin_test 'check --backend requires argument'
assert_fails 'backend needs arg' "$BCS_CMD" check --backend || true

# Test: check rejects invalid backend
begin_test 'check rejects invalid backend'
temp=$(mktemp --suffix=.sh)
echo '#!/bin/bash' > "$temp"
assert_fails 'invalid backend rejected' "$BCS_CMD" check --backend bogus "$temp" || true
rm -f "$temp"

# Test: option bundling -bs parsed
begin_test 'option bundling -bs parsed'
err=$("$BCS_CMD" check -bs 2>&1 || true)
assert_not_contains "$err" 'Invalid option' '-bs bundling parsed correctly' || true

# Test: check help shows ollama backend
begin_test 'check help mentions ollama'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'ollama' 'help mentions ollama' || true

# Test: check help shows anthropic backend
begin_test 'check help mentions anthropic'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'anthropic' 'help mentions anthropic' || true

# Test: check help shows openai backend
begin_test 'check help mentions openai'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'openai' 'help mentions openai' || true

# Test: check help shows BCS_BACKEND env var
begin_test 'check help mentions BCS_BACKEND'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'BCS_BACKEND' 'help mentions BCS_BACKEND' || true

# Test: check help shows ANTHROPIC_API_KEY env var
begin_test 'check help mentions ANTHROPIC_API_KEY'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'ANTHROPIC_API_KEY' 'help mentions ANTHROPIC_API_KEY' || true

# Test: check help shows BCS_ANTHROPIC_MODEL env var
begin_test 'check help mentions BCS_ANTHROPIC_MODEL'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'BCS_ANTHROPIC_MODEL' 'help mentions BCS_ANTHROPIC_MODEL' || true

# Test: check help shows BCS_GOOGLE_MODEL env var
begin_test 'check help mentions BCS_GOOGLE_MODEL'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'BCS_GOOGLE_MODEL' 'help mentions BCS_GOOGLE_MODEL' || true

# Test: check help shows BCS_OPENAI_MODEL env var
begin_test 'check help mentions BCS_OPENAI_MODEL'
output=$("$BCS_CMD" check -h 2>/dev/null)
assert_contains "$output" 'BCS_OPENAI_MODEL' 'help mentions BCS_OPENAI_MODEL' || true

# Skip actual LLM invocation tests (requires running backend)
echo '  (skipping live LLM tests - requires running backend)'

print_summary 'check'
#fin
