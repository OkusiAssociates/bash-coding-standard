#!/usr/bin/env bash
# test-subcommand-generate.sh - Tests for bcs generate subcommand
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
begin_test 'generated file has section markers'
for section in 'Script Structure' 'Variables' 'Strings' 'Functions' 'Control Flow' \
               'Error Handling' 'I/O' 'Command-Line' 'File Operations' 'Security' \
               'Concurrency' 'Style'; do
  if [[ "$content" != *"$section"* ]]; then
    printf '  %s✗%s missing section: %s\n' "$RED" "$NC" "$section"
    TESTS_FAILED+=1
    TESTS_RUN+=1
    continue
  fi
done
printf '  %s✓%s all 12 sections present\n' "$GREEN" "$NC"
TESTS_PASSED+=1
TESTS_RUN+=1

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

print_summary 'generate'
#fin
