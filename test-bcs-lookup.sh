#!/usr/bin/env bash
# Test BCS code lookup with new numeric-only directory structure

set -euo pipefail

# BCS code to path converter
bcs_to_path() {
  local code=$1
  local tier=${2:-complete}  # Default to complete tier

  # Strip BCS prefix
  code=${code#BCS}

  # Validate code is all digits
  [[ "$code" =~ ^[0-9]+$ ]] || {
    echo "Error: Invalid BCS code format" >&2
    return 1
  }

  local path="BCS"
  local len=${#code}

  # Section only (2 digits): BCS01 -> BCS/01/00.tier.md
  if ((len == 2)); then
    path="$path/${code}/00.$tier.md"

  # Rule (4 digits): BCS0102 -> BCS/01/02.tier.md
  elif ((len == 4)); then
    local section=${code:0:2}
    local rule=${code:2:2}
    path="$path/$section/$rule.$tier.md"

  # Subrule (6 digits): BCS010201 -> BCS/01/02/01.tier.md
  elif ((len == 6)); then
    local section=${code:0:2}
    local rule=${code:2:2}
    local subrule=${code:4:2}
    path="$path/$section/$rule/$subrule.$tier.md"

  # Sub-subrule (8 digits): BCS01020103 -> BCS/01/02/01/03.tier.md
  elif ((len == 8)); then
    local section=${code:0:2}
    local rule=${code:2:2}
    local subrule=${code:4:2}
    local subsubrule=${code:6:2}
    path="$path/$section/$rule/$subrule/$subsubrule.$tier.md"

  else
    echo "Error: Unsupported BCS code length: $len" >&2
    return 1
  fi

  echo "$path"
}

# Test cases
echo "Testing BCS code to path conversion:"
echo ""

test_codes=(
  "BCS01"
  "BCS0102"
  "BCS010201"
  "BCS0205"
  "BCS0701"
  "BCS140210"
)

for code in "${test_codes[@]}"; do
  echo "Code: $code"
  for tier in complete summary abstract; do
    path=$(bcs_to_path "$code" "$tier")
    if [[ -e "$path" ]]; then
      echo "  [$tier] ✓ $path"
    else
      echo "  [$tier] ✗ $path (not found)"
    fi
  done
  echo ""
done

# Demonstrate reading content
echo "Reading BCS0102 (Shebang rule):"
echo "================================"
head -5 "$(bcs_to_path BCS0102 complete)"
echo ""
echo "Reading BCS010201 (Dual-purpose scripts):"
echo "=========================================="
head -5 "$(bcs_to_path BCS010201 complete)"

#fin
