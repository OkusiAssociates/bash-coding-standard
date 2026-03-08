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

# Test: default type is basic
begin_test 'default template type is basic'
default_output=$("$BCS_CMD" template 2>/dev/null)
assert_contains "$default_output" 'set -euo pipefail' 'default has strict mode (basic)' || true

# Test: file overwrite protection
begin_test 'refuses overwrite without -f'
overwrite_file=$(mktemp)
echo 'existing content' > "$overwrite_file"
assert_fails 'overwrite blocked' "$BCS_CMD" template -t minimal -o "$overwrite_file" || true
rm -f "$overwrite_file"

# Test: name derived from output filename
begin_test 'name from output filename'
name_file=$(mktemp -d)/deploy.sh
output=$("$BCS_CMD" template -t minimal -o "$name_file" 2>/dev/null)
name_content=$(< "$name_file")
assert_contains "$name_content" 'deploy' 'name derived from filename' || true
rm -rf "$(dirname "$name_file")"

# Test: no leftover placeholders in output
for ttype in minimal basic complete library; do
  begin_test "no placeholders in $ttype template"
  tpl_output=$("$BCS_CMD" template -t "$ttype" -n test -d 'desc' 2>/dev/null)
  assert_not_contains "$tpl_output" '{{' "no {{ in $ttype output" || true
done

# Test: all template types produce shellcheck-clean output
# SC2034 (unused vars) and SC2155 (declare+assign) are excluded because
# templates define scaffold variables that user code will reference.
for ttype in minimal basic complete library; do
  begin_test "$ttype template passes shellcheck"
  sc_file=$(mktemp --suffix=.sh)
  "$BCS_CMD" template -t "$ttype" -n testscript -o "$sc_file" -f 2>/dev/null
  if shellcheck -e SC2034 -e SC2155 "$sc_file" 2>/dev/null; then
    printf '  %s✓%s %s shellcheck clean\n' "$GREEN" "$NC" "$ttype"
    TESTS_PASSED+=1
  else
    printf '  %s✗%s %s shellcheck has findings\n' "$RED" "$NC" "$ttype"
    shellcheck -e SC2034 -e SC2155 "$sc_file" 2>&1 | head -20
    TESTS_FAILED+=1
  fi
  rm -f "$sc_file"
done

# Test: help line counts match actual templates
begin_test 'help line counts match actual templates'
declare -i line_mismatches=0
declare -A expected_lines=([minimal]=15 [basic]=25 [complete]=112 [library]=39)
for ttype in minimal basic complete library; do
  actual_lines=$("$BCS_CMD" template -t "$ttype" 2>/dev/null | wc -l)
  expected=${expected_lines[$ttype]}
  # Allow ±15% tolerance for ~ prefix
  low=$((expected * 85 / 100))
  high=$((expected * 115 / 100))
  if ((actual_lines < low || actual_lines > high)); then
    printf '    %s: expected ~%d, got %d\n' "$ttype" "$expected" "$actual_lines"
    line_mismatches+=1
  fi
done
assert_equal 0 "$line_mismatches" 'help line counts match actual templates' || true

# Test: invalid template type
begin_test 'rejects invalid template type'
assert_fails 'rejects bogus type' "$BCS_CMD" template -t bogus || true

# Test: help
begin_test 'template -h shows help'
output=$("$BCS_CMD" template -h 2>/dev/null)
assert_contains "$output" 'bcs template' 'help has command name' || true

print_summary 'template'
#fin
