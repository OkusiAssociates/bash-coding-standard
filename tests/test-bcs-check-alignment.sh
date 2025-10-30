#!/usr/bin/env bash
# Test BCS check alignment - Validate that bcs check correctly validates BCS-compliant scripts
# Tests all lib/ scripts plus main bcs script to ensure AI checker is properly aligned

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Load test helpers
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

# Repository root (normalized to avoid find issues with ..)
REPO_ROOT=$(realpath -- "$SCRIPT_DIR"/..)

# Color variables for reports (test-helpers.sh already defines RED, GREEN, YELLOW, NC)
if [[ ! -v CYAN ]]; then
  if [[ -t 1 ]]; then
    declare -r CYAN=$'\033[0;36m' BOLD=$'\033[1m'
  else
    declare -r CYAN='' BOLD=''
  fi
fi

# Test configuration
declare -i VERBOSE=0
declare -i STRICT_MODE=0
declare -i SHOW_DETAILS=0
declare -- OUTPUT_FILE=''

# Test tracking
declare -i TOTAL_SCRIPTS=0 SCRIPTS_PASSED=0 SCRIPTS_FAILED=0
declare -a FAILED_SCRIPTS=()
declare -a SCRIPT_RESULTS=()

# Messaging functions
info() { >&2 echo "${CYAN}◉${NC} $*"; }
warn() { >&2 echo "${YELLOW}▲${NC} $*"; }
error() { >&2 echo "${RED}✗${NC} $*"; }
success() { >&2 echo "${GREEN}✓${NC} $*"; }

# Help message
show_help() {
  cat <<'EOF'
test-bcs-check-alignment.sh - Validate bcs check against BCS-compliant scripts

Usage: test-bcs-check-alignment.sh [OPTIONS]

Options:
  -h, --help           Show this help message
  -v, --verbose        Verbose output (show bcs check output)
  -s, --strict         Run bcs check in strict mode
  -d, --details        Show detailed output for all tests
  -o, --output FILE    Save results to file

Description:
  Tests all 22 lib/ scripts plus the main bcs script against 'bcs check'
  to verify the AI compliance checker correctly validates canonically
  BCS-compliant code.

  All scripts tested are known to be BCS-compliant, so failures indicate
  potential issues with the AI checker's validation logic.

Examples:
  ./test-bcs-check-alignment.sh
  ./test-bcs-check-alignment.sh --verbose --details
  ./test-bcs-check-alignment.sh -o results.txt
EOF
}

# Parse arguments
while (($#)); do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -s|--strict)
      STRICT_MODE=1
      shift
      ;;
    -d|--details)
      SHOW_DETAILS=1
      shift
      ;;
    -o|--output)
      [[ -n ${2:-} ]] || { error "Option $1 requires an argument"; exit 1; }
      OUTPUT_FILE=$2
      shift 2
      ;;
    -*)
      error "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)
      error "Unexpected argument: $1"
      show_help
      exit 1
      ;;
  esac
done

# Discover all scripts to test
discover_scripts() {
  local -a scripts=()
  local -- file

  # Find all files in lib/ and filter for scripts
  while IFS= read -r file; do
    # Include if executable OR has .sh/.bash extension
    if [[ -x $file || $file =~ \.(sh|bash)$ ]]; then
      scripts+=("$file")
    fi
  done < <(find "$REPO_ROOT"/lib -type f ! -path '*/.*' 2>/dev/null | sort)

  # Add main bcs script
  scripts+=("$REPO_ROOT/bcs")

  # Return via stdout
  printf '%s\n' "${scripts[@]}"
}

# Run bcs check on a single script
check_script() {
  local -- script_path=$1
  local -- script_name=${script_path##*/}
  local -- relative_path=${script_path#"$REPO_ROOT"/}
  local -i exit_code=0
  local -- output=''

  # Build bcs check command
  local -a cmd=("$REPO_ROOT/bcs" check)
  ((STRICT_MODE)) && cmd+=(--strict)
  cmd+=("$script_path")

  # Run bcs check and capture output
  if ((VERBOSE)); then
    info "Testing: $relative_path"
    output=$("${cmd[@]}" 2>&1) && exit_code=0 || exit_code=$?
    echo "$output"
  else
    output=$("${cmd[@]}" 2>&1) && exit_code=0 || exit_code=$?
  fi

  # Track results
  TOTAL_SCRIPTS+=1

  if ((exit_code == 0)); then
    SCRIPTS_PASSED+=1
    ((SHOW_DETAILS || VERBOSE)) && success "$relative_path - PASSED"
    SCRIPT_RESULTS+=("PASS|$relative_path")
    return 0
  else
    SCRIPTS_FAILED+=1
    FAILED_SCRIPTS+=("$relative_path")
    error "$relative_path - FAILED (exit code: $exit_code)"
    if ((SHOW_DETAILS)); then
      echo "${BOLD}Output:${NC}"
      echo "$output"
      echo ""
    fi
    SCRIPT_RESULTS+=("FAIL|$relative_path|$exit_code")
    return 1
  fi
}

# Generate summary report
generate_report() {
  local -- report=''
  local -i pass_rate=0

  # Calculate pass rate
  if ((TOTAL_SCRIPTS > 0)); then
    pass_rate=$((SCRIPTS_PASSED * 100 / TOTAL_SCRIPTS))
  fi

  # Build report
  report="${BOLD}=== BCS Check Alignment Test Results ===${NC}

${CYAN}Summary:${NC}
  Total Scripts Tested: $TOTAL_SCRIPTS
  Passed: ${GREEN}$SCRIPTS_PASSED${NC}
  Failed: ${RED}$SCRIPTS_FAILED${NC}
  Pass Rate: ${pass_rate}%

${CYAN}Configuration:${NC}
  Strict Mode: $( ((STRICT_MODE)) && echo 'Enabled' || echo 'Disabled' )
  Verbose: $( ((VERBOSE)) && echo 'Enabled' || echo 'Disabled' )
"

  # Add failed scripts details
  if ((SCRIPTS_FAILED > 0)); then
    report+="
${YELLOW}Failed Scripts:${NC}"
    for script in "${FAILED_SCRIPTS[@]}"; do
      report+="
  ${RED}✗${NC} $script"
    done
    report+="

${YELLOW}⚠ Note:${NC} All tested scripts are canonically BCS-compliant.
Failures indicate potential false positives in the AI checker.
"
  else
    report+="
${GREEN}✓ All scripts passed validation!${NC}

The bcs check AI validator is properly aligned with BCS-compliant code.
"
  fi

  # Add results table if details requested
  if ((SHOW_DETAILS)); then
    report+="
${CYAN}Detailed Results:${NC}
${BOLD}Status | Script Path${NC}
-------|-------------"
    for result in "${SCRIPT_RESULTS[@]}"; do
      IFS='|' read -r status path exit_code <<< "$result"
      if [[ $status == 'PASS' ]]; then
        report+="
${GREEN}PASS${NC}   | $path"
      else
        report+="
${RED}FAIL${NC}   | $path (exit: $exit_code)"
      fi
    done
  fi

  echo "$report"

  # Save to file if requested
  if [[ -n $OUTPUT_FILE ]]; then
    # Strip ANSI codes for file output
    echo "$report" | sed 's/\x1B\[[0-9;]*[mK]//g' > "$OUTPUT_FILE"
    info "Results saved to: $OUTPUT_FILE"
  fi
}

# Main test execution
main() {
  local -a scripts=()

  echo "${BOLD}=== BCS Check Alignment Test ===${NC}"
  echo ""

  # Check if bcs script exists
  if [[ ! -x $REPO_ROOT/bcs ]]; then
    error "bcs script not found or not executable: $REPO_ROOT/bcs"
    exit 1
  fi

  # Check if Claude CLI is available
  if ! command -v claude &>/dev/null; then
    warn "Claude CLI not found - bcs check requires 'claude' command"
    warn "Install from: https://claude.com/claude-code"
    exit 77  # Exit code 77 = test skipped
  fi

  info "Discovering BCS-compliant scripts..."
  mapfile -t scripts < <(discover_scripts)

  info "Found ${#scripts[@]} scripts to test"
  echo ""

  # Test each script
  for script in "${scripts[@]}"; do
    check_script "$script" || true  # Continue on failure
  done

  echo ""

  # Generate and display report
  generate_report

  # Return exit code based on results
  ((SCRIPTS_FAILED == 0))
}

# Execute main function
main "$@"

#fin
