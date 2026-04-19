#!/usr/bin/env bash
# Test file pattern matching for cln
set -euo pipefail
shopt -s inherit_errexit

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

declare -r CLN="$SCRIPT_DIR/../cln"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test_default_patterns() {
  test_section "Default File Patterns"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create files matching default patterns
  touch "$temp_dir/file~"
  touch "$temp_dir/~file"
  touch "$temp_dir/.~file"
  touch "$temp_dir/.file~"
  touch "$temp_dir/DEADJOE"
  touch "$temp_dir/dead.letter"
  touch "$temp_dir/wget-log"
  touch "$temp_dir/wget-log.1"
  touch "$temp_dir/keepme.txt"

  # Run cln without prompting
  "$CLN" -Pq "$temp_dir" 2>/dev/null || true

  # Verify matching files are deleted
  [[ ! -f "$temp_dir/file~" ]] && pass "file~ deleted" || fail "file~ should be deleted"
  [[ ! -f "$temp_dir/~file" ]] && pass "~file deleted" || fail "~file should be deleted"
  [[ ! -f "$temp_dir/.~file" ]] && pass ".~file deleted" || fail ".~file should be deleted"
  [[ ! -f "$temp_dir/.file~" ]] && pass ".file~ deleted" || fail ".file~ should be deleted"
  [[ ! -f "$temp_dir/DEADJOE" ]] && pass "DEADJOE deleted" || fail "DEADJOE should be deleted"
  [[ ! -f "$temp_dir/dead.letter" ]] && pass "dead.letter deleted" || fail "dead.letter should be deleted"
  [[ ! -f "$temp_dir/wget-log" ]] && pass "wget-log deleted" || fail "wget-log should be deleted"
  [[ ! -f "$temp_dir/wget-log.1" ]] && pass "wget-log.1 deleted" || fail "wget-log.1 should be deleted"

  # Verify non-matching files are kept
  [[ -f "$temp_dir/keepme.txt" ]] && pass "keepme.txt preserved" || fail "keepme.txt should be preserved"
}

test_custom_patterns() {
  test_section "Custom File Patterns (-a)"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create test files
  touch "$temp_dir/file.bak"
  touch "$temp_dir/file.tmp"
  touch "$temp_dir/file.txt"

  # Run cln with custom pattern
  "$CLN" -Pq -a '*.bak' "$temp_dir" 2>/dev/null || true

  [[ ! -f "$temp_dir/file.bak" ]] && pass "*.bak pattern works" || fail "*.bak should be deleted"
  [[ -f "$temp_dir/file.tmp" ]] && pass ".tmp preserved (not in pattern)" || fail ".tmp should be preserved"
  [[ -f "$temp_dir/file.txt" ]] && pass ".txt preserved" || fail ".txt should be preserved"
}

test_comma_delimited_patterns() {
  test_section "Comma-Delimited Patterns"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create test files
  touch "$temp_dir/file.bak"
  touch "$temp_dir/file.tmp"
  touch "$temp_dir/file.old"
  touch "$temp_dir/file.txt"

  # Run cln with comma-delimited patterns
  "$CLN" -Pq -a '*.bak,*.tmp,*.old' "$temp_dir" 2>/dev/null || true

  [[ ! -f "$temp_dir/file.bak" ]] && pass "*.bak deleted" || fail "*.bak should be deleted"
  [[ ! -f "$temp_dir/file.tmp" ]] && pass "*.tmp deleted" || fail "*.tmp should be deleted"
  [[ ! -f "$temp_dir/file.old" ]] && pass "*.old deleted" || fail "*.old should be deleted"
  [[ -f "$temp_dir/file.txt" ]] && pass ".txt preserved" || fail ".txt should be preserved"
}

test_depth_limit() {
  test_section "Depth Limit (-m)"

  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create nested structure
  mkdir -p "$temp_dir/level1/level2/level3"
  touch "$temp_dir/file~"
  touch "$temp_dir/level1/file~"
  touch "$temp_dir/level1/level2/file~"
  touch "$temp_dir/level1/level2/level3/file~"

  # Run with depth 2
  "$CLN" -Pq -m 2 "$temp_dir" 2>/dev/null || true

  [[ ! -f "$temp_dir/file~" ]] && pass "depth 0 deleted" || fail "depth 0 should be deleted"
  [[ ! -f "$temp_dir/level1/file~" ]] && pass "depth 1 deleted" || fail "depth 1 should be deleted"
  [[ -f "$temp_dir/level1/level2/file~" ]] && pass "depth 2 preserved (beyond limit)" || fail "depth 2 should be preserved"
  [[ -f "$temp_dir/level1/level2/level3/file~" ]] && pass "depth 3 preserved" || fail "depth 3 should be preserved"
}

test_no_matches() {
  test_section "No Matching Files"

  local temp_dir output exit_code=0
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" RETURN

  # Create files that don't match patterns
  touch "$temp_dir/file.txt"
  touch "$temp_dir/file.doc"

  output=$("$CLN" -P "$temp_dir" 2>&1) || exit_code=$?
  assert_success $exit_code "Exits 0 when no matches"
  assert_contains "$output" "No matching files" "Shows no matches message"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Run tests
test_default_patterns
test_custom_patterns
test_comma_delimited_patterns
test_depth_limit
test_no_matches

# Print summary
print_summary
#fin
