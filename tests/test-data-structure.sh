#!/usr/bin/env bash
# test-data-structure.sh - Validate data directory structure and BCS codes
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: data structure validation'

# Test: all 12 section files exist
begin_test 'all 12 section files exist'
declare -i found=0
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
  for f in "$DATA_DIR"/"$i"-*.md; do
    [[ -f "$f" ]] && found+=1 && break
  done
done
assert_equal 12 "$found" 'all 12 section files present' || true

# Test: BASH-CODING-STANDARD.md exists
begin_test 'BASH-CODING-STANDARD.md exists'
assert_file_exists "$DATA_DIR"/BASH-CODING-STANDARD.md || true

# Test: templates directory exists
begin_test 'templates directory exists'
if [[ -d "$DATA_DIR"/templates ]]; then
  printf '  %s✓%s templates directory exists\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
else
  printf '  %s✗%s templates directory missing\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi
TESTS_RUN+=1

# Test: all 4 template types exist
for type in minimal basic complete library; do
  begin_test "template $type exists"
  assert_file_exists "$DATA_DIR"/templates/"$type".sh.template "$type template exists" || true
done

# Test: each section file starts with # Section N:
begin_test 'section files have proper headers'
declare -i good_headers=0
for f in "$DATA_DIR"/[0-9]*.md; do
  [[ "$(basename -- "$f")" == BASH-CODING-STANDARD.md ]] && continue
  declare -- first_line
  IFS= read -r first_line < "$f"
  if [[ "$first_line" =~ ^#\ Section\ [0-9]+: ]]; then
    good_headers+=1
  else
    printf '    bad header in %s: %s\n' "$(basename "$f")" "$first_line"
  fi
done
assert_equal 12 "$good_headers" 'all 12 section files have proper headers' || true

# Test: every section has at least one BCS code
begin_test 'every section has BCS codes'
declare -i sections_with_codes=0
for f in "$DATA_DIR"/[0-9]*.md; do
  [[ "$(basename -- "$f")" == BASH-CODING-STANDARD.md ]] && continue
  if grep -q '^## BCS[0-9]' "$f"; then
    sections_with_codes+=1
  else
    printf '    no BCS codes in %s\n' "$(basename "$f")"
  fi
done
assert_equal 12 "$sections_with_codes" 'all sections have BCS codes' || true

# Test: BCS codes are well-formed (BCS followed by 4 digits)
begin_test 'BCS codes are well-formed'
declare -i malformed=0
while IFS= read -r line; do
  if [[ "$line" =~ ^##\ BCS ]] && ! [[ "$line" =~ ^##\ BCS[0-9]{4}\ .+ ]]; then
    printf '    malformed code: %s\n' "$line"
    malformed+=1
  fi
done < <(grep '^## BCS' "$DATA_DIR"/[0-9]*.md)
assert_equal 0 "$malformed" 'no malformed BCS codes' || true

# Test: no duplicate BCS codes
begin_test 'no duplicate BCS codes'
declare -i duplicates
duplicates=$(grep -h '^## BCS[0-9]' "$DATA_DIR"/[0-9]*.md | sort | uniq -d | wc -l)
assert_equal 0 "$duplicates" 'no duplicate BCS codes' || true

# Test: BCS codes are sequential within sections
begin_test 'BCS codes follow section numbering'
declare -i mismatched=0
for f in "$DATA_DIR"/[0-9]*.md; do
  [[ "$(basename -- "$f")" == BASH-CODING-STANDARD.md ]] && continue
  declare -- basename_f
  basename_f=$(basename -- "$f")
  declare -- section_num=${basename_f:0:2}
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ (BCS[0-9]{4}) ]]; then
      declare -- code=${BASH_REMATCH[1]}
      declare -- code_section=${code:3:2}
      if [[ "$code_section" != "$section_num" ]]; then
        printf '    %s in %s (expected section %s)\n' "$code" "$(basename "$f")" "$section_num"
        mismatched+=1
      fi
    fi
  done < "$f"
done
assert_equal 0 "$mismatched" 'all BCS codes match their section file' || true

# Test: standard document line count is in range
begin_test 'standard document line count in range'
declare -i std_lines
std_lines=$(wc -l < "$DATA_DIR"/BASH-CODING-STANDARD.md)
if ((std_lines >= 1500 && std_lines <= 3000)); then
  printf '  %s✓%s line count %d in range [1500-3000]\n' "$GREEN" "$NC" "$std_lines"
  TESTS_PASSED+=1
else
  printf '  %s✗%s line count %d outside range [1500-3000]\n' "$RED" "$NC" "$std_lines"
  TESTS_FAILED+=1
fi
TESTS_RUN+=1

print_summary 'data-structure'
#fin
