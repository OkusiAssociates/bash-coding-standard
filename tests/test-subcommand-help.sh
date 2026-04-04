#!/usr/bin/env bash
# test-subcommand-help.sh - Tests for bcs help subcommand
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: help subcommand'

# Test: main help
output=$("$BCS_CMD" help 2>/dev/null)

begin_test 'main help mentions bcs'
assert_contains "$output" 'bcs' 'main help mentions bcs' || true

begin_test 'main help mentions display'
assert_contains "$output" 'display' 'main help mentions display' || true

begin_test 'main help mentions template'
assert_contains "$output" 'template' 'main help mentions template' || true

begin_test 'main help mentions check'
assert_contains "$output" 'check' 'main help mentions check' || true

begin_test 'main help mentions codes'
assert_contains "$output" 'codes' 'main help mentions codes' || true

begin_test 'main help mentions generate'
assert_contains "$output" 'generate' 'main help mentions generate' || true

# Test: help for each subcommand
for cmd in display template check codes generate; do
  begin_test "help $cmd shows usage"
  output=$("$BCS_CMD" help "$cmd" 2>/dev/null)
  assert_contains "$output" "$cmd" "help $cmd mentions command" || true
done

# Test: --help flag
begin_test '--help shows main help'
output=$("$BCS_CMD" --help 2>/dev/null)
assert_contains "$output" 'Commands:' '--help shows commands' || true

# Test: -h flag
begin_test '-h shows main help'
output=$("$BCS_CMD" -h 2>/dev/null)
assert_contains "$output" 'Commands:' '-h shows commands' || true

# Test: version output
begin_test '--version shows version'
output=$("$BCS_CMD" --version 2>/dev/null)
assert_matches "$output" '^bcs [0-9]+\.[0-9]+\.[0-9]+$' 'version format' || true

begin_test '-V shows version'
output=$("$BCS_CMD" -V 2>/dev/null)
assert_matches "$output" '^bcs [0-9]+\.[0-9]+\.[0-9]+$' '-V version format' || true

# Test: version matches source VERSION
begin_test 'version matches source'
output=$("$BCS_CMD" --version 2>/dev/null)
source_version=$(grep -m1 'VERSION=' "$BCS_CMD" | head -1 | sed "s/.*VERSION=//; s/'//g")
assert_contains "$output" "$source_version" "version $source_version in output" || true

# Test: help mentions all 6 subcommands
begin_test 'help lists all 6 subcommands'
output=$("$BCS_CMD" help 2>/dev/null)
declare -i missing_cmds=0
for cmd in display template check codes generate help; do
  [[ "$output" == *"$cmd"* ]] || missing_cmds+=1
done
assert_equal 0 "$missing_cmds" 'all 6 subcommands in help' || true

# Test: unknown command
begin_test 'unknown command fails'
assert_fails 'unknown command' "$BCS_CMD" foobar || true

# Test: help for unknown command
begin_test 'help unknown command fails'
assert_fails 'help unknown' "$BCS_CMD" help foobar || true

print_summary 'help'
#fin
