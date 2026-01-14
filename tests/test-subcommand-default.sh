#!/usr/bin/env bash
# Tests for bcs default subcommand

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Load test helpers
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

SCRIPT="$SCRIPT_DIR"/../bash-coding-standard

test_default_help() {
  test_section "Default Help Tests"

  local -- output
  output=$("$SCRIPT" default --help 2>&1)

  assert_contains "$output" "Usage:" "default --help shows usage"
  assert_contains "$output" "bcs default" "Help mentions default command"
  assert_contains "$output" "complete" "Help mentions complete tier"
  assert_contains "$output" "summary" "Help mentions summary tier"
  assert_contains "$output" "abstract" "Help mentions abstract tier"
  assert_contains "$output" "rulet" "Help mentions rulet tier"
}

test_default_show_current() {
  test_section "Show Current Default Tests"

  local -- output
  output=$("$SCRIPT" default 2>&1)

  # Should have content
  assert_not_empty "$output" "bcs default produces output"

  # Should contain one of the tier names (and nothing else)
  case "$output" in
    complete|summary|abstract|rulet)
      pass "Output contains a valid tier name: $output"
      ;;
    *)
      fail "Output should be a tier name, got: $output"
      ;;
  esac
}

test_default_list() {
  test_section "List Tiers Tests"

  local -- output
  output=$("$SCRIPT" default --list 2>&1)

  # Should have content
  assert_not_empty "$output" "bcs default --list produces output"

  # Should list all four tiers
  assert_contains "$output" "complete" "List contains complete tier"
  assert_contains "$output" "summary" "List contains summary tier"
  assert_contains "$output" "abstract" "List contains abstract tier"
  assert_contains "$output" "rulet" "List contains rulet tier"

  # Should indicate current default with asterisk
  assert_contains "$output" "\*" "List indicates current default with asterisk"
}

test_default_list_short_option() {
  test_section "List Tiers Short Option Tests"

  local -- output
  output=$("$SCRIPT" default -l 2>&1)

  # Should produce same output as --list
  assert_not_empty "$output" "bcs default -l produces output"
  assert_contains "$output" "complete" "Short option lists complete tier"
  assert_contains "$output" "\*" "Short option indicates current with asterisk"
}

test_default_file_option() {
  test_section "File Option Tests"

  local -- output
  output=$("$SCRIPT" default --file 2>&1)

  # Should have content
  assert_not_empty "$output" "bcs default --file produces output"

  # Should contain BASH-CODING-STANDARD.md
  assert_contains "$output" "BASH-CODING-STANDARD.md" "Output contains BASH-CODING-STANDARD.md"

  # Should be an actual file path
  if [[ -f "$output" ]]; then
    pass "Output is a valid file path"
  else
    fail "Output should be a valid file path: $output"
  fi
}

test_default_file_short_option() {
  test_section "File Short Option Tests"

  local -- output
  output=$("$SCRIPT" default -f 2>&1)

  # Should produce same output as --file
  assert_not_empty "$output" "bcs default -f produces output"
  assert_contains "$output" "BASH-CODING-STANDARD.md" "Short option shows file path"

  # Should be an actual file path
  if [[ -f "$output" ]]; then
    pass "Short option returns valid file path"
  else
    fail "Short option should return valid file path: $output"
  fi
}

test_default_invalid_tier() {
  test_section "Invalid Tier Tests"

  local -- output
  local -i exit_code
  output=$("$SCRIPT" default invalid_tier 2>&1) && exit_code=$? || exit_code=$?

  # Should fail
  if ((exit_code != 0)); then
    pass "Invalid tier returns non-zero exit code: $exit_code"
  else
    fail "Invalid tier should return non-zero exit code"
  fi

  # Should mention error
  assert_contains "$output" "Invalid" "Error message mentions invalid"
  assert_contains "$output" "tier" "Error message mentions tier"
}

test_default_set_complete() {
  test_section "Set to Complete Tier Tests"

  # Save current default
  local -- original_tier
  original_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Set to complete
  local -- output
  local -i exit_code
  output=$("$SCRIPT" default complete 2>&1) && exit_code=$? || exit_code=$?

  if ((exit_code == 0)); then
    pass "Set to complete tier succeeded"

    # Verify it was set
    local -- new_tier
    new_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

    if [[ "$new_tier" == "complete" ]]; then
      pass "Default tier is now complete"
    else
      fail "Default tier should be complete but is $new_tier"
    fi

    # Restore original
    if [[ "$original_tier" != "complete" && "$original_tier" != "unknown" ]]; then
      "$SCRIPT" default "$original_tier" >/dev/null 2>&1 || true
    fi
  else
    warn "Set to complete failed (exit code $exit_code) - may lack permissions"
  fi
}

test_default_set_summary() {
  test_section "Set to Summary Tier Tests"

  # Save current default
  local -- original_tier
  original_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Set to summary
  local -- output
  local -i exit_code
  output=$("$SCRIPT" default summary 2>&1) && exit_code=$? || exit_code=$?

  if ((exit_code == 0)); then
    pass "Set to summary tier succeeded"

    # Verify it was set
    local -- new_tier
    new_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

    if [[ "$new_tier" == "summary" ]]; then
      pass "Default tier is now summary"
    else
      fail "Default tier should be summary but is $new_tier"
    fi

    # Restore original
    if [[ "$original_tier" != "summary" && "$original_tier" != "unknown" ]]; then
      "$SCRIPT" default "$original_tier" >/dev/null 2>&1 || true
    fi
  else
    warn "Set to summary failed (exit code $exit_code) - may lack permissions"
  fi
}

test_default_set_abstract() {
  test_section "Set to Abstract Tier Tests"

  # Save current default
  local -- original_tier
  original_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Set to abstract
  local -- output
  local -i exit_code
  output=$("$SCRIPT" default abstract 2>&1) && exit_code=$? || exit_code=$?

  if ((exit_code == 0)); then
    pass "Set to abstract tier succeeded"

    # Verify it was set
    local -- new_tier
    new_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

    if [[ "$new_tier" == "abstract" ]]; then
      pass "Default tier is now abstract"
    else
      fail "Default tier should be abstract but is $new_tier"
    fi

    # Restore original
    if [[ "$original_tier" != "abstract" && "$original_tier" != "unknown" ]]; then
      "$SCRIPT" default "$original_tier" >/dev/null 2>&1 || true
    fi
  else
    warn "Set to abstract failed (exit code $exit_code) - may lack permissions"
  fi
}

test_default_set_rulet() {
  test_section "Set to Rulet Tier Tests"

  # Save current default
  local -- original_tier
  original_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Set to rulet
  local -- output
  local -i exit_code
  output=$("$SCRIPT" default rulet 2>&1) && exit_code=$? || exit_code=$?

  if ((exit_code == 0)); then
    pass "Set to rulet tier succeeded"

    # Verify it was set
    local -- new_tier
    new_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

    if [[ "$new_tier" == "rulet" ]]; then
      pass "Default tier is now rulet"
    else
      fail "Default tier should be rulet but is $new_tier"
    fi

    # Restore original
    if [[ "$original_tier" != "rulet" && "$original_tier" != "unknown" ]]; then
      "$SCRIPT" default "$original_tier" >/dev/null 2>&1 || true
    fi
  else
    warn "Set to rulet failed (exit code $exit_code) - may lack permissions"
  fi
}

test_default_set_already_set() {
  test_section "Set Already Set Tier Tests"

  # Get current default
  local -- current_tier
  current_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  if [[ "$current_tier" == "unknown" ]]; then
    warn "Cannot determine current tier - skipping test"
    return 0
  fi

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Try to set to current tier
  local -- output
  output=$("$SCRIPT" default "$current_tier" 2>&1)

  # Should mention already set
  assert_contains "$output" "already" "Output mentions already set"
}

test_default_before_after_output() {
  test_section "Before/After Output Tests"

  # Save current default
  local -- original_tier
  original_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")

  if [[ "$original_tier" == "unknown" ]]; then
    warn "Cannot determine current tier - skipping test"
    return 0
  fi

  # Skip if no write permission
  if [[ ! -w "$SCRIPT_DIR/.." ]]; then
    warn "Skipping set tests - no write permission"
    return 0
  fi

  # Choose a different tier
  local -- target_tier
  case "$original_tier" in
    complete) target_tier="summary" ;;
    summary) target_tier="abstract" ;;
    abstract) target_tier="rulet" ;;
    rulet) target_tier="complete" ;;
    *) warn "Unknown tier - skipping test"; return 0 ;;
  esac

  # Change tier and capture output
  local -- output
  output=$("$SCRIPT" default "$target_tier" 2>&1)

  # Should mention both tiers
  assert_contains "$output" "$original_tier" "Output mentions old tier"
  assert_contains "$output" "$target_tier" "Output mentions new tier"

  # Restore original
  "$SCRIPT" default "$original_tier" >/dev/null 2>&1 || true
}

test_default_exit_codes() {
  test_section "Exit Code Tests"

  local -- exit_code

  # Help should return 0
  "$SCRIPT" default --help >/dev/null 2>&1 && exit_code=$? || exit_code=$?
  if ((exit_code == 0)); then
    pass "Help returns exit code 0"
  else
    fail "Help should return 0, got $exit_code"
  fi

  # Show current should return 0
  "$SCRIPT" default >/dev/null 2>&1 && exit_code=$? || exit_code=$?
  if ((exit_code == 0)); then
    pass "Show current returns exit code 0"
  else
    fail "Show current should return 0, got $exit_code"
  fi

  # Invalid tier should return non-zero
  "$SCRIPT" default invalid_tier >/dev/null 2>&1 && exit_code=$? || exit_code=$?
  if ((exit_code != 0)); then
    pass "Invalid tier returns non-zero exit code: $exit_code"
  else
    fail "Invalid tier should return non-zero"
  fi
}

test_default_symlink_verification() {
  test_section "Symlink Verification Tests"

  local -- symlink_path="$SCRIPT_DIR/../BASH-CODING-STANDARD.md"

  # Verify symlink exists
  if [[ -L "$symlink_path" ]]; then
    pass "BASH-CODING-STANDARD.md is a symlink"
  else
    fail "BASH-CODING-STANDARD.md should be a symlink"
  fi

  # Verify symlink target exists
  if [[ -f "$symlink_path" ]]; then
    pass "Symlink target file exists"
  else
    fail "Symlink target should exist"
  fi

  # Verify target matches current default
  local -- current_tier target
  current_tier=$("$SCRIPT" default 2>&1 | grep -oE "(complete|summary|abstract|rulet)" || echo "unknown")
  target=$(readlink "$symlink_path" || echo "")

  if [[ "$target" == *"${current_tier}.md" ]]; then
    pass "Symlink target matches current default tier"
  else
    warn "Symlink target ($target) may not match current tier ($current_tier)"
  fi
}

test_default_tier_validation() {
  test_section "Tier Validation Tests"

  local -- invalid_tiers=("comp" "summ" "abs" "rule" "COMPLETE" "Summary" "test" "")

  for invalid in "${invalid_tiers[@]}"; do
    local -- output
    local -i exit_code
    output=$("$SCRIPT" default "$invalid" 2>&1) && exit_code=$? || exit_code=$?

    if ((exit_code != 0)); then
      pass "Rejected invalid tier: '$invalid'"
    else
      warn "Should reject invalid tier: '$invalid'"
    fi
  done
}

# Run all tests
test_default_help
test_default_show_current
test_default_list
test_default_list_short_option
test_default_file_option
test_default_file_short_option
test_default_invalid_tier
test_default_set_complete
test_default_set_summary
test_default_set_abstract
test_default_set_rulet
test_default_set_already_set
test_default_before_after_output
test_default_exit_codes
test_default_symlink_verification
test_default_tier_validation

print_summary

#fin
