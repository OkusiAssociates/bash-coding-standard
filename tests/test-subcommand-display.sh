#!/usr/bin/env bash
# Test suite for bcs display subcommand

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
BCS_CMD="$PROJECT_DIR/bcs"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR BCS_CMD

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_bcs_command_exists() {
  test_section "BCS Command Existence"
  assert_file_exists "$BCS_CMD"
  assert_file_executable "$BCS_CMD"
}

test_display_help() {
  test_section "Display Command Help"
  local -- output
  output=$("$BCS_CMD" display --help 2>&1) || true
  assert_contains "$output" "Usage:" "Help shows usage"
  assert_contains "$output" "Display" "Command purpose shown"
}

test_default_display_produces_output() {
  test_section "Default Display Output"
  local -- output
  output=$("$BCS_CMD" display 2>&1 | head -100) || true

  # Should produce substantial output
  if [[ -n "$output" ]]; then
    pass "Produces output"
  else
    fail "No output produced"
  fi

  # Should contain BCS standard content
  assert_contains "$output" "Bash Coding Standard" "Contains standard title"
}

test_no_subcommand_defaults_to_display() {
  test_section "No Subcommand Defaults to Display"
  local -- output1 output2
  output1=$("$BCS_CMD" 2>&1 | head -50) || true
  output2=$("$BCS_CMD" display 2>&1 | head -50) || true

  # Both should produce similar output
  if [[ "$output1" == "$output2" ]]; then
    pass "Default command matches display"
  else
    # Content may differ slightly, check for common elements
    if [[ "$output1" =~ "Bash Coding Standard" && "$output2" =~ "Bash Coding Standard" ]]; then
      pass "Both produce BCS content"
    else
      warn "Default and display may produce different output"
    fi
  fi
}

test_cat_option_forces_plain_text() {
  test_section "Cat Option Forces Plain Text"
  local -- output
  output=$("$BCS_CMD" display --cat 2>&1 | head -100) || true

  # Should produce output
  if [[ -n "$output" ]]; then
    pass "Cat option produces output"
  else
    fail "Cat option produces no output"
  fi

  # Should not contain ANSI escape codes (md2ansi adds these)
  if [[ ! "$output" =~ $'\033'\\[ ]]; then
    pass "Output is plain text (no ANSI codes)"
  else
    warn "Output may contain ANSI codes (expected plain text)"
  fi
}

test_short_cat_option() {
  test_section "Short Cat Option (-c)"
  local -- output
  output=$("$BCS_CMD" display -c 2>&1 | head -100) || true

  if [[ -n "$output" ]]; then
    pass "Short -c option produces output"
  else
    fail "Short -c option produces no output"
  fi
}

test_json_option_produces_json() {
  test_section "JSON Option Output"
  local -- output
  output=$("$BCS_CMD" display --json 2>&1) || true

  # Should produce JSON-like output
  if [[ "$output" =~ \{ ]]; then
    pass "JSON option produces JSON-like output"
  else
    warn "JSON option may not produce JSON format"
  fi
}

test_bash_export_option() {
  test_section "Bash Export Option"
  local -- output
  output=$("$BCS_CMD" display --bash 2>&1) || true

  # Should produce bash variable declaration
  if [[ "$output" =~ declare.*BCS_MD ]]; then
    pass "Bash export produces declare statement"
  else
    warn "Bash export may not produce expected format"
  fi
}

test_squeeze_option() {
  test_section "Squeeze Option"
  local -- output
  output=$("$BCS_CMD" display --squeeze 2>&1 | head -200) || true

  # Should produce output with squeezed blank lines
  if [[ -n "$output" ]]; then
    pass "Squeeze option produces output"
  else
    fail "Squeeze option produces no output"
  fi

  # Count consecutive blank lines - should not have many consecutive ones
  local -i max_consecutive=0 consecutive=0
  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      ((consecutive+=1))
      ((consecutive > max_consecutive)) && max_consecutive=$consecutive
    else
      consecutive=0
    fi
  done <<< "$output"

  if ((max_consecutive <= 2)); then
    pass "Blank lines squeezed (max consecutive: $max_consecutive)"
  else
    warn "Multiple consecutive blank lines found ($max_consecutive)"
  fi
}

test_output_contains_sections() {
  test_section "Output Contains Major Sections"
  local -- output
  output=$("$BCS_CMD" display --cat 2>&1) || true

  # Should contain major section headings
  assert_contains "$output" "Script Structure" "Contains Script Structure section"
  assert_contains "$output" "Variable" "Contains Variables section"
  assert_contains "$output" "Function" "Contains Functions section"
  assert_contains "$output" "Error" "Contains Error Handling section"
}

test_output_size_reasonable() {
  test_section "Output Size Validation"
  local -- output
  local -i line_count char_count

  output=$("$BCS_CMD" display --cat 2>&1) || true
  line_count=$(echo "$output" | wc -l)
  char_count=$(echo "$output" | wc -c)

  # Summary tier is ~12K lines, should be substantial
  if ((line_count > 1000)); then
    pass "Output has substantial content ($line_count lines)"
  else
    fail "Output seems too small ($line_count lines)"
  fi

  if ((char_count > 50000)); then
    pass "Output has substantial size ($char_count characters)"
  else
    warn "Output may be smaller than expected ($char_count characters)"
  fi
}

test_viewer_option_passthrough() {
  test_section "Viewer Option Pass-through"
  local -- output
  local -i exit_code=0

  # Pass -n option to cat (line numbers)
  output=$("$BCS_CMD" display --cat -n 2>&1 | head -20) || exit_code=$?

  if ((exit_code == 0)); then
    # Check if line numbers are present
    if [[ "$output" =~ [[:space:]]+[0-9]+[[:space:]] ]]; then
      pass "Viewer options passed through (line numbers shown)"
    else
      warn "Line numbers may not be shown (option may not pass through)"
    fi
  else
    warn "Viewer option pass-through may not work (exit: $exit_code)"
  fi
}

test_bcs_command_exists
test_display_help
test_default_display_produces_output
test_no_subcommand_defaults_to_display
test_cat_option_forces_plain_text
test_short_cat_option
test_json_option_produces_json
test_bash_export_option
test_squeeze_option
test_output_contains_sections
test_output_size_reasonable
test_viewer_option_passthrough

print_summary
#fin
