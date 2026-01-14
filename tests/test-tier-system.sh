#!/usr/bin/env bash
# Test suite for BCS tier system (complete, summary, abstract, rulet)

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
PROJECT_DIR=$(realpath -- "$SCRIPT_DIR/..")
BCS_CMD="$PROJECT_DIR/bcs"
DATA_DIR="$PROJECT_DIR/data"
readonly -- SCRIPT_PATH SCRIPT_DIR PROJECT_DIR BCS_CMD DATA_DIR

# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

test_tier_files_exist() {
  test_section "Tier Files Existence"

  # Check canonical tier files exist
  assert_file_exists "$DATA_DIR/BASH-CODING-STANDARD.complete.md"
  assert_file_exists "$DATA_DIR/BASH-CODING-STANDARD.summary.md"
  assert_file_exists "$DATA_DIR/BASH-CODING-STANDARD.abstract.md"
  assert_file_exists "$DATA_DIR/BASH-CODING-STANDARD.rulet.md"
}

test_tier_symlink_exists() {
  test_section "Default Tier Symlink"

  assert_file_exists "$DATA_DIR/BASH-CODING-STANDARD.md"

  # Should be a symlink
  if [[ -L "$DATA_DIR/BASH-CODING-STANDARD.md" ]]; then
    pass "BASH-CODING-STANDARD.md is a symlink"
  else
    fail "BASH-CODING-STANDARD.md should be a symlink"
  fi
}

test_tier_symlink_points_to_valid_tier() {
  test_section "Symlink Points to Valid Tier"

  local -- target
  target=$(readlink "$DATA_DIR/BASH-CODING-STANDARD.md")

  # Should point to one of the tier files
  if [[ "$target" =~ ^BASH-CODING-STANDARD\.(complete|summary|abstract|rulet)\.md$ ]]; then
    pass "Symlink points to valid tier: $target"
  else
    fail "Symlink points to unexpected target: $target"
  fi
}

test_default_tier_detection() {
  test_section "Default Tier Detection"

  # bcs default command should show current default
  local -- output
  output=$("$BCS_CMD" default 2>&1) || true

  if [[ "$output" =~ (complete|summary|abstract|rulet) ]]; then
    pass "Default tier detected"
  else
    warn "Could not detect default tier from output"
  fi
}

test_tier_size_hierarchy() {
  test_section "Tier Size Hierarchy"

  local -i complete_size summary_size abstract_size rulet_size

  complete_size=$(wc -l < "$DATA_DIR/BASH-CODING-STANDARD.complete.md")
  summary_size=$(wc -l < "$DATA_DIR/BASH-CODING-STANDARD.summary.md")
  abstract_size=$(wc -l < "$DATA_DIR/BASH-CODING-STANDARD.abstract.md")
  rulet_size=$(wc -l < "$DATA_DIR/BASH-CODING-STANDARD.rulet.md")

  # complete > summary > abstract > rulet
  if ((complete_size > summary_size)); then
    pass "Complete tier larger than summary ($complete_size > $summary_size lines)"
  else
    fail "Complete should be larger than summary"
  fi

  if ((summary_size > abstract_size)); then
    pass "Summary tier larger than abstract ($summary_size > $abstract_size lines)"
  else
    fail "Summary should be larger than abstract"
  fi

  if ((abstract_size > rulet_size)); then
    pass "Abstract tier larger than rulet ($abstract_size > $rulet_size lines)"
  else
    warn "Abstract should be larger than rulet (may vary)"
  fi
}

test_all_tiers_contain_bcs_codes() {
  test_section "All Tiers Contain BCS Codes"

  local -- tier file
  for tier in complete summary abstract; do
    file="$DATA_DIR/BASH-CODING-STANDARD.$tier.md"

    if grep -qE 'BCS[0-9]{2,}' "$file"; then
      pass "Tier '$tier' contains BCS codes"
    else
      fail "Tier '$tier' missing BCS codes"
    fi
  done
}

test_rulet_tier_format() {
  test_section "Rulet Tier Format"

  local -- rulet_file="$DATA_DIR/BASH-CODING-STANDARD.rulet.md"
  local -- output
  output=$(head -100 "$rulet_file")

  # Rulet should have [BCS####] format
  if [[ "$output" =~ \\[BCS[0-9]+ ]]; then
    pass "Rulet contains [BCS####] format codes"
  else
    warn "Rulet may not use expected bracket format"
  fi
}

test_section_tiers_exist() {
  test_section "Section Tier Files"

  # Check a few section directories have tier files
  local -- section_dir section_file found=0
  for section_dir in "$DATA_DIR"/0[1-3]-*/; do
    [[ -d "$section_dir" ]] || continue

    # Check for at least one .complete.md file
    for section_file in "$section_dir"/*.complete.md; do
      if [[ -f "$section_file" ]]; then
        ((found+=1))
        break
      fi
    done
  done

  if ((found >= 3)); then
    pass "Section directories contain .complete.md files ($found found)"
  else
    fail "Too few section .complete.md files found ($found)"
  fi
}

test_rule_file_tier_triplets() {
  test_section "Rule File Tier Triplets"

  # Each rule should have all three tiers: .complete.md, .summary.md, .abstract.md
  local -- section_dir rule_base rule_files missing=0

  for section_dir in "$DATA_DIR"/0[1-2]-*/; do
    [[ -d "$section_dir" ]] || continue

    # Find all unique rule bases (e.g., "01-layout" from "01-layout.complete.md")
    for rule_base in "$section_dir"/[0-9][0-9]-*.complete.md; do
      [[ -f "$rule_base" ]] || continue

      # Strip .complete.md to get base
      rule_base="${rule_base%.complete.md}"

      # Check all three tiers exist
      if [[ ! -f "$rule_base.complete.md" ]] || \
         [[ ! -f "$rule_base.summary.md" ]] || \
         [[ ! -f "$rule_base.abstract.md" ]]; then
        ((missing+=1))
      fi
    done
  done

  if ((missing == 0)); then
    pass "All rules have complete triplets (complete/summary/abstract)"
  else
    warn "Found $missing rules with missing tier files"
  fi
}

test_decode_command_tier_support() {
  test_section "Decode Command Tier Support"

  # Test decode with different tiers
  local -- output_complete output_summary output_abstract

  output_complete=$("$BCS_CMD" decode BCS0101 --complete --print 2>&1 | head -20) || true
  output_summary=$("$BCS_CMD" decode BCS0101 --summary --print 2>&1 | head -20) || true
  output_abstract=$("$BCS_CMD" decode BCS0101 --abstract --print 2>&1 | head -20) || true

  if [[ -n "$output_complete" ]]; then
    pass "Decode supports --complete tier"
  else
    fail "Decode --complete produced no output"
  fi

  if [[ -n "$output_summary" ]]; then
    pass "Decode supports --summary tier"
  else
    fail "Decode --summary produced no output"
  fi

  if [[ -n "$output_abstract" ]]; then
    pass "Decode supports --abstract tier"
  else
    fail "Decode --abstract produced no output"
  fi
}

test_generate_command_tier_support() {
  test_section "Generate Command Tier Support"

  local -- help_output
  help_output=$("$BCS_CMD" generate --help 2>&1) || true

  # Should document tier options
  assert_contains "$help_output" "--tier" "Generate supports --tier option"
  assert_contains "$help_output" "complete" "Generate documents complete tier"
  assert_contains "$help_output" "summary" "Generate documents summary tier"
  assert_contains "$help_output" "abstract" "Generate documents abstract tier"
}

test_tier_content_differences() {
  test_section "Tier Content Differences"

  # Check that tiers have different content (not just copies)
  local -i complete_size summary_size abstract_size

  complete_size=$(stat -c%s "$DATA_DIR/BASH-CODING-STANDARD.complete.md")
  summary_size=$(stat -c%s "$DATA_DIR/BASH-CODING-STANDARD.summary.md")
  abstract_size=$(stat -c%s "$DATA_DIR/BASH-CODING-STANDARD.abstract.md")

  # Sizes should differ significantly
  if ((complete_size - summary_size > 10000)); then
    pass "Complete and summary differ significantly ($((complete_size - summary_size)) bytes)"
  else
    warn "Complete and summary may be too similar"
  fi

  if ((summary_size - abstract_size > 10000)); then
    pass "Summary and abstract differ significantly ($((summary_size - abstract_size)) bytes)"
  else
    warn "Summary and abstract may be too similar"
  fi
}

test_tier_files_exist
test_tier_symlink_exists
test_tier_symlink_points_to_valid_tier
test_default_tier_detection
test_tier_size_hierarchy
test_all_tiers_contain_bcs_codes
test_rulet_tier_format
test_section_tiers_exist
test_rule_file_tier_triplets
test_decode_command_tier_support
test_generate_command_tier_support
test_tier_content_differences

print_summary
#fin
