#!/usr/bin/env bash
# Test file deletion behavior for cln
set -euo pipefail
shopt -s inherit_errexit

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

declare -r CLN="$SCRIPT_DIR/../cln"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test_actual_deletion() {
  test_section "Actual File Deletion"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create matching file
  touch "$temp_dir/test~"
  [[ -f "$temp_dir/test~" ]] || { fail "Setup failed"; return 1; }

  # Run cln
  "$CLN" -Pq "$temp_dir" 2>/dev/null || true

  # Verify deletion
  if [[ ! -f "$temp_dir/test~" ]]; then
    pass "File actually deleted from filesystem"
  else
    fail "File should be deleted"
  fi
}

test_preserves_non_matching() {
  test_section "Preserves Non-Matching Files"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create various files
  touch "$temp_dir/delete~"
  touch "$temp_dir/keep.txt"
  touch "$temp_dir/keep.sh"
  mkdir "$temp_dir/subdir"
  touch "$temp_dir/subdir/keep.md"

  # Run cln
  "$CLN" -Pq "$temp_dir" 2>/dev/null || true

  # Verify preserved
  [[ -f "$temp_dir/keep.txt" ]] && pass "keep.txt preserved" || fail "keep.txt should be preserved"
  [[ -f "$temp_dir/keep.sh" ]] && pass "keep.sh preserved" || fail "keep.sh should be preserved"
  [[ -d "$temp_dir/subdir" ]] && pass "subdir preserved" || fail "subdir should be preserved"
  [[ -f "$temp_dir/subdir/keep.md" ]] && pass "subdir/keep.md preserved" || fail "subdir/keep.md should be preserved"
}

test_multiple_directories() {
  test_section "Multiple Directory Processing"

  local temp_dir1 temp_dir2
  temp_dir1=$(mktemp -d)
  temp_dir2=$(mktemp -d)
  trap "rm -rf '$temp_dir1' '$temp_dir2'" RETURN

  # Create files in both directories
  touch "$temp_dir1/file~"
  touch "$temp_dir2/file~"

  # Run cln on both
  "$CLN" -Pq "$temp_dir1" "$temp_dir2" 2>/dev/null || true

  # Verify both cleaned
  [[ ! -f "$temp_dir1/file~" ]] && pass "First directory cleaned" || fail "First dir should be cleaned"
  [[ ! -f "$temp_dir2/file~" ]] && pass "Second directory cleaned" || fail "Second dir should be cleaned"
}

test_verbose_output() {
  test_section "Verbose Output (-v)"

  local temp_dir output exit_code=0
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  touch "$temp_dir/file~"

  output=$("$CLN" -Pv "$temp_dir" 2>&1) || exit_code=$?

  assert_success $exit_code "Verbose mode exits 0"
  assert_contains "$output" "Searching" "Shows searching message"
  assert_contains "$output" "Removing" "Shows removing message"
}

test_quiet_deletion() {
  test_section "Quiet Deletion (-q)"

  local temp_dir output exit_code=0
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  touch "$temp_dir/file~"

  output=$("$CLN" -Pq "$temp_dir" 2>&1) || exit_code=$?

  assert_success $exit_code "Quiet mode exits 0"
  if [[ -z "$output" ]]; then
    pass "Quiet mode produces no output"
  else
    fail "Quiet mode should produce no output, got: $output"
  fi

  # But file should still be deleted
  [[ ! -f "$temp_dir/file~" ]] && pass "File still deleted in quiet mode" || fail "File should be deleted"
}

test_multiple_files() {
  test_section "Multiple Files Deletion"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create multiple matching files
  for i in {1..5}; do
    touch "$temp_dir/file${i}~"
  done

  # Run cln
  "$CLN" -Pq "$temp_dir" 2>/dev/null || true

  # Verify all deleted
  local -i remaining=0
  for i in {1..5}; do
    [[ -f "$temp_dir/file${i}~" ]] && remaining+=1
  done

  if ((remaining == 0)); then
    pass "All 5 matching files deleted"
  else
    fail "$remaining files remain, expected 0"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Run tests
test_actual_deletion
test_preserves_non_matching
test_multiple_directories
test_verbose_output
test_quiet_deletion
test_multiple_files

# Print summary
print_summary
#fin
