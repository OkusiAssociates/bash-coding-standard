#!/usr/bin/env bash
# Tests for bcs generate-rulets subcommand

set -euo pipefail
shopt -s inherit_errexit shift_verbose

# Load test helpers
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

SCRIPT="$SCRIPT_DIR"/../bash-coding-standard

test_generate_rulets_help() {
  test_section "Generate-Rulets Help Tests"

  local -- output
  output=$("$SCRIPT" generate-rulets --help 2>&1)

  assert_contains "$output" "Usage:" "generate-rulets --help shows usage"
  assert_contains "$output" "bcs generate-rulets" "Help mentions generate-rulets command"
  assert_contains "$output" "-a, --all" "Help shows --all option"
  assert_contains "$output" "-f, --force" "Help shows --force option"
  assert_contains "$output" "CATEGORY" "Help mentions CATEGORY argument"
  assert_contains "$output" "bcs-rulet-extractor" "Help mentions agent requirement"
  assert_contains "$output" "\[BCSXXXX\]" "Help mentions BCS code format"
}

test_generate_rulets_requires_agent() {
  test_section "Generate-Rulets Agent Requirement Tests"

  # Test with non-existent agent path
  local -- output exit_code
  exit_code=0
  output=$("$SCRIPT" generate-rulets --agent-cmd /nonexistent/agent 02 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Command fails when agent not found (exit code: $exit_code)"
  else
    fail "Command should fail when agent not found"
  fi

  assert_contains "$output" "not found" "Error message mentions agent not found"
}

test_generate_rulets_requires_category() {
  test_section "Generate-Rulets Category Requirement Tests"

  # Test without category and without --all
  local -- output exit_code
  exit_code=0
  output=$("$SCRIPT" generate-rulets 2>&1) || exit_code=$?

  if ((exit_code != 0)); then
    pass "Command fails when no category specified (exit code: $exit_code)"
  else
    fail "Command should fail when no category specified"
  fi

  assert_contains "$output" "No category specified" "Error message mentions missing category"
}

test_resolve_category_dir() {
  test_section "Category Resolution Tests"

  # Create a mock agent for testing category resolution
  local -- mock_agent
  mock_agent=$(mktemp)
  cat > "$mock_agent" <<'MOCK'
#!/bin/bash
echo "mock agent"
MOCK
  chmod +x "$mock_agent"
  trap 'rm -f "$mock_agent"' RETURN

  # Test category resolution (dry run by checking error messages)
  local -- output exit_code

  # Valid category numbers - should fail for other reasons (no complete.md files, etc), not category resolution
  for cat in 01 02 1 2; do
    exit_code=0
    output=$("$SCRIPT" generate-rulets --agent-cmd "$mock_agent" "$cat" 2>&1) || exit_code=$?

    # Should NOT complain about "Category not found"
    if [[ ! "$output" =~ "Category not found" ]]; then
      pass "Category '$cat' resolved successfully"
    else
      fail "Category '$cat' not resolved: $output"
    fi
  done

  # Test invalid category
  exit_code=0
  output=$("$SCRIPT" generate-rulets --agent-cmd "$mock_agent" 99 2>&1) || exit_code=$?

  if [[ "$output" =~ "Category not found" ]]; then
    pass "Invalid category 99 properly rejected"
  else
    fail "Should reject invalid category 99"
  fi
}

test_rulet_file_exists_check() {
  test_section "Rulet File Existence Check Tests"

  # Create a mock agent that always succeeds
  local -- mock_agent
  mock_agent=$(mktemp)
  cat > "$mock_agent" <<'MOCK'
#!/bin/bash
# Mock agent - just echo some rulet content
cat <<'EOF'
# Test Category - Rulets

## Test Section

- [BCS0201] Test rulet number one
- [BCS0202] Test rulet number two
EOF
MOCK
  chmod +x "$mock_agent"
  trap 'rm -f "$mock_agent"' RETURN

  # Find an existing rulet file
  local -- existing_rulet
  existing_rulet=$(find "$SCRIPT_DIR"/../data -name "00-*.rulet.md" | head -1)

  if [[ -n "$existing_rulet" ]]; then
    local -- category_dir
    category_dir=$(dirname "$existing_rulet")
    local -- category_num
    category_num=$(basename "$category_dir" | grep -o '^[0-9][0-9]')

    # Try to regenerate without --force
    local -- output
    output=$("$SCRIPT" generate-rulets --agent-cmd "$mock_agent" "$category_num" 2>&1)

    if [[ "$output" =~ "already exists" || "$output" =~ "use --force" ]]; then
      pass "Detects existing rulet file without --force"
    else
      warn "May not be checking for existing rulet files"
    fi
  else
    skip "No existing rulet files found for testing"
  fi
}

test_generate_rulets_help_from_main() {
  test_section "Generate-Rulets in Main Help Tests"

  local -- output
  output=$("$SCRIPT" help 2>&1)

  assert_contains "$output" "generate-rulets" "Main help lists generate-rulets command"

  # Test help delegation
  output=$("$SCRIPT" help generate-rulets 2>&1)
  assert_contains "$output" "Generate rulet files" "Help delegation works for generate-rulets"
}

# Run tests
test_generate_rulets_help
test_generate_rulets_requires_agent
test_generate_rulets_requires_category
test_resolve_category_dir
test_rulet_file_exists_check
test_generate_rulets_help_from_main

# Summary
test_summary
