#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-subcommand-generate.sh - Tests for bcs generate subcommand
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: generate subcommand'

# Test: generate creates output file
begin_test 'generate creates output'
temp_file=$(mktemp --suffix=.md)
trap 'rm -f "$temp_file"' EXIT
"$BCS_CMD" generate -o "$temp_file" 2>/dev/null
assert_file_exists "$temp_file" 'output file created' || true

# Test: generated file has content
begin_test 'generated file has content'
line_count=$(wc -l < "$temp_file")
assert_gt "$line_count" 1500 'generated file has >1500 lines' || true

# Test: generated file has header
begin_test 'generated file has header'
content=$(< "$temp_file")
assert_contains "$content" 'Bash Coding Standard' 'has title' || true

# Test: generated file has table of contents
begin_test 'generated file has table of contents'
assert_contains "$content" '## Contents' 'has contents section' || true

# Test: generated file has all 12 sections
begin_test 'generated file has all 12 sections'
declare -i missing_sections=0
for section in 'Script Structure' 'Variables' 'Strings' 'Functions' 'Control Flow' \
               'Error Handling' 'I/O' 'Command-Line' 'File Operations' 'Security' \
               'Concurrency' 'Style'; do
  if [[ "$content" != *"$section"* ]]; then
    printf '    missing: %s\n' "$section"
    missing_sections+=1
  fi
done
assert_equal 0 "$missing_sections" 'all 12 sections present' || true

# Test: generated file has BCS codes
begin_test 'generated file has BCS codes'
bcs_count=$(grep -c '^## BCS[0-9]' "$temp_file" || true)
assert_gt "$bcs_count" 80 'at least 80 BCS codes in generated file' || true

# Test: generate help
begin_test 'generate -h shows help'
help_output=$("$BCS_CMD" generate -h 2>/dev/null)
assert_contains "$help_output" 'bcs generate' 'help has command name' || true

# Test: default output location
begin_test 'default generates to data/BASH-CODING-STANDARD.md'
"$BCS_CMD" generate 2>/dev/null
assert_file_exists "$DATA_DIR"/BASH-CODING-STANDARD.md 'default output exists' || true

# Test: idempotency (generate twice, same output)
begin_test 'generate is idempotent'
temp_a=$(mktemp --suffix=.md)
temp_b=$(mktemp --suffix=.md)
"$BCS_CMD" generate -o "$temp_a" 2>/dev/null
"$BCS_CMD" generate -o "$temp_b" 2>/dev/null
if diff -q "$temp_a" "$temp_b" >/dev/null 2>&1; then
  printf '  %s✓%s generate produces identical output twice\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s generate output differs between runs\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi
rm -f "$temp_a" "$temp_b"

# Test: generated output matches current BASH-CODING-STANDARD.md
begin_test 'generated matches current standard'
temp_regen=$(mktemp --suffix=.md)
"$BCS_CMD" generate -o "$temp_regen" 2>/dev/null
if diff -q "$temp_regen" "$DATA_DIR"/BASH-CODING-STANDARD.md >/dev/null 2>&1; then
  printf '  %s✓%s regenerated matches current standard\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s regenerated differs from current standard\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi
rm -f "$temp_regen"

print_summary 'generate'
#fin
