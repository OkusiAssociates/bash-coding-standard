#!/usr/bin/env bash
# test-subcommand-template.sh - Tests for bcs template subcommand
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: template subcommand'

# Test: minimal template
begin_test 'minimal template generates output'
output=$("$BCS_CMD" template -t minimal 2>/dev/null)
assert_matches "$output" '#!/(usr/)?bin/(env )?bash' 'has shebang' || true

begin_test 'minimal template has #fin'
assert_contains "$output" '#fin' 'has end marker' || true

# Test: basic template
begin_test 'basic template generates output'
output=$("$BCS_CMD" template -t basic 2>/dev/null)
assert_contains "$output" 'set -euo pipefail' 'has strict mode' || true

# Test: complete template
begin_test 'complete template generates output'
output=$("$BCS_CMD" template -t complete 2>/dev/null)
assert_contains "$output" '_msg()' 'has messaging function' || true
assert_contains "$output" 'main "$@"' 'has main invocation' || true

# Test: library template
begin_test 'library template generates output'
output=$("$BCS_CMD" template -t library 2>/dev/null)
assert_contains "$output" 'declare -fx' 'has function export' || true

# Test: name substitution
begin_test 'name substitution works'
output=$("$BCS_CMD" template -t minimal -n myapp 2>/dev/null)
assert_contains "$output" 'myapp' 'name substituted' || true

# Test: description substitution
begin_test 'description substitution works'
output=$("$BCS_CMD" template -t basic -d 'My cool app' 2>/dev/null)
assert_contains "$output" 'My cool app' 'description substituted' || true

# Test: version substitution
begin_test 'version substitution works'
output=$("$BCS_CMD" template -t basic -V '2.5.0' 2>/dev/null)
assert_contains "$output" '2.5.0' 'version substituted' || true

# Test: output to file
begin_test 'output to file works'
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT
"$BCS_CMD" template -t minimal -o "$temp_file" -f 2>/dev/null
output=$(< "$temp_file")
assert_matches "$output" '#!/(usr/)?bin/(env )?bash' 'file has shebang' || true

# Test: executable flag
begin_test 'executable flag works'
temp_file2=$(mktemp)
trap 'rm -f "$temp_file" "$temp_file2"' EXIT
"$BCS_CMD" template -t minimal -o "$temp_file2" -xf 2>/dev/null
if [[ -x "$temp_file2" ]]; then
  printf '  %s✓%s file is executable\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s file is not executable\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

# Test: invalid template type
begin_test 'rejects invalid template type'
assert_fails 'rejects bogus type' "$BCS_CMD" template -t bogus || true

# Test: help
begin_test 'template -h shows help'
output=$("$BCS_CMD" template -h 2>/dev/null)
assert_contains "$output" 'bcs template' 'help has command name' || true

print_summary 'template'
#fin
