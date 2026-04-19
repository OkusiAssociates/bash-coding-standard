#!/usr/bin/env bash
# Run all cln test suites
set -euo pipefail
shopt -s inherit_errexit

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CLN_CMD="$SCRIPT_DIR/../cln"

# Colors
if [[ -t 1 ]]; then
  declare -r GREEN=$'\033[0;32m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m' NC=$'\033[0m'
else
  declare -r GREEN='' RED='' YELLOW='' NC=''
fi

# Counters
declare -i total_passed=0 total_failed=0 total_skipped=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  cln Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Run each test file
for test_file in "$SCRIPT_DIR"/test-*.sh; do
  [[ -f "$test_file" ]] || continue

  test_name=$(basename "$test_file")
  [[ "$test_name" == "test-helpers.sh" ]] && continue
  echo "${YELLOW}▶${NC} Running $test_name..."
  echo

  # Run test and capture exit code
  set +e
  bash "$test_file"
  exit_code=$?
  set -e

  case $exit_code in
    0)   ((total_passed+=1)) ;;
    77)  ((total_skipped+=1)) ;;
    *)   ((total_failed+=1)) ;;
  esac

  echo
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Overall Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ${GREEN}Passed:${NC}  $total_passed test files"
echo "  ${RED}Failed:${NC}  $total_failed test files"
echo "  ${YELLOW}Skipped:${NC} $total_skipped test files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

((total_failed == 0)) || exit 1
#fin
