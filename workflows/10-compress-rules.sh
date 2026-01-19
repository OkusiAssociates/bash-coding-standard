#!/usr/bin/env bash
# Compress BCS rule files using Claude AI
# Enhanced wrapper around 'bcs compress' with pre-flight checks and progress reporting

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Project paths
#shellcheck disable=SC2155
declare -r PROJECT_DIR=$(realpath -- "$SCRIPT_DIR"/..)
declare -r DATA_DIR="$PROJECT_DIR"/data
#shellcheck disable=SC2034 # Reserved for future use
declare -r BCS_CMD="$PROJECT_DIR"/bcs

# Global variables
declare -i VERBOSE=1 DRY_RUN=0 REPORT_ONLY=1
declare -- TIER=both CONTEXT_LEVEL=none CLAUDE_CMD=claude
declare -i SUMMARY_LIMIT=10000 ABSTRACT_LIMIT=1500

# Colors
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Messaging functions
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho)   ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

#shellcheck disable=SC2317
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Usage
show_help() {
  cat <<HELP
Usage: $SCRIPT_NAME [OPTIONS]

Compress BCS rule files using Claude AI with pre-flight checks and progress reporting.
Enhanced wrapper around 'bcs compress'.

MODES:
  --report-only        Report oversized files only (default)
  --regenerate         Delete and regenerate all compressed files

OPTIONS:
  -h, --help              Show this help message
  -q, --quiet             Quiet mode (errors only)
  -v, --verbose           Verbose mode (default)
  -n, --dry-run           Show what would be done without doing it
  --tier TIER             Process specific tier: summary or abstract (default: both)
  --context-level LEVEL   Context awareness level (default: none)
                          Options: none, toc, abstract, summary, complete
  --claude-cmd CMD        Claude CLI command path (default: claude)
  --summary-limit N       Summary file size limit in bytes (default: 10000)
  --abstract-limit N      Abstract file size limit in bytes (default: 1500)

CONTEXT LEVELS:
  none      - Each rule compressed in isolation (fastest)
  toc       - Includes table of contents (~5-10KB context)
  abstract  - Full abstract standard (~83KB) - RECOMMENDED
  summary   - Full summary standard (~310KB context)
  complete  - Full complete standard (~520KB context)

EXAMPLES:
  $SCRIPT_NAME                                    # Report oversized files
  $SCRIPT_NAME --regenerate                       # Regenerate with no context
  $SCRIPT_NAME --regenerate --context-level abstract  # RECOMMENDED
  $SCRIPT_NAME --regenerate --tier summary        # Only summary tier
  $SCRIPT_NAME --dry-run --regenerate             # Preview regeneration

PRE-FLIGHT CHECKS:
  1. Claude CLI availability
  2. Data directory validation
  3. BCS command accessibility
  4. Existing file permissions

EXIT CODES:
  0 - Success
  1 - Compression failed or oversized files found
  2 - Invalid arguments or setup failure

SEE ALSO:
  bcs compress            - Direct compression command
  bcs compress --help     - Detailed compression options
HELP
}

# Parse arguments
parse_arguments() {
  while (($#)); do
    case $1 in
      -h|--help) show_help; exit 0 ;;
      -q|--quiet) VERBOSE=0 ;;
      -v|--verbose) VERBOSE=1 ;;
      -n|--dry-run) DRY_RUN=1 ;;
      --report-only) REPORT_ONLY=1 ;;
      --regenerate) REPORT_ONLY=0 ;;
      --tier)
        noarg "$@"; shift
        TIER=$1
        [[ "$TIER" =~ ^(summary|abstract|both)$ ]] || \
          die 2 "Invalid tier ${TIER@Q} (must be summary, abstract, or both)"
        ;;
      --context-level)
        noarg "$@"; shift
        CONTEXT_LEVEL=$1
        [[ "$CONTEXT_LEVEL" =~ ^(none|toc|abstract|summary|complete)$ ]] || \
          die 2 "Invalid context level ${CONTEXT_LEVEL@Q}"
        ;;
      --claude-cmd)
        noarg "$@"; shift
        CLAUDE_CMD=$1
        ;;
      --summary-limit)
        noarg "$@"; shift
        SUMMARY_LIMIT=$1
        ;;
      --abstract-limit)
        noarg "$@"; shift
        ABSTRACT_LIMIT=$1
        ;;
      -*) die 22 "Unknown option ${1@Q}" ;;
      *) die 2 "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done
}

# Pre-flight check: Claude CLI
check_claude_cli() {
  info "Checking Claude CLI availability..."

  if command -v "$CLAUDE_CMD" >/dev/null 2>&1; then
    success "Claude CLI found: $CLAUDE_CMD"
    return 0
  else
    error "Claude CLI not found: $CLAUDE_CMD"
    error "Install from: https://claude.ai/code"
    return 1
  fi
}

# Pre-flight check: Data directory
check_data_directory() {
  info 'Checking data directory...'

  [[ -d "$DATA_DIR" ]] || {
    error "Data directory not found: $DATA_DIR"
    return 1
  }

  # Count .complete.md files
  local -i complete_count
  complete_count=$(find "$DATA_DIR" -type f -name "*.complete.md" | wc -l)

  if ((complete_count)); then
    success "Found $complete_count .complete.md files"
    return 0
  else
    error "No .complete.md files found in $DATA_DIR"
    return 1
  fi
}

# Pre-flight check: BCS command
check_bcs_command() {
  info "Checking BCS command..."

  [[ -x "$BCS_CMD" ]] || {
    error "BCS command not executable: $BCS_CMD"
    return 1
  }

  # Verify compress subcommand exists
  if "$BCS_CMD" help compress >/dev/null 2>&1; then
    success "BCS compress subcommand available"
    return 0
  else
    error "BCS compress subcommand not available"
    return 1
  fi
}

# Run all pre-flight checks
run_preflight_checks() {
  info "${BOLD}Pre-flight Checks${NC}"
  echo

  local -i failed=0

  check_claude_cli || failed+=1
  check_data_directory || failed+=1
  check_bcs_command || failed+=1

  echo

  if ((failed)); then
    error "Pre-flight checks failed: $failed check(s)"
    return 1
  else
    success 'All pre-flight checks passed'
    return 0
  fi
}

# Report mode: list oversized files
report_oversized_files() {
  info "${BOLD}Checking File Sizes${NC}"
  echo

  local -i oversized_summary=0 oversized_abstract=0
  local -- file
  local -i size

  # Check summary files
  if [[ "$TIER" == "both" || "$TIER" == "summary" ]]; then
    info "Checking summary files (limit: $SUMMARY_LIMIT bytes)..."
    while IFS= read -r -d '' file; do
      size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
      if ((size > SUMMARY_LIMIT)); then
        warn "  Oversized: ${file#"$DATA_DIR"/} ($size bytes)"
        oversized_summary+=1
      fi
    done < <(find "$DATA_DIR" -type f -name "*.summary.md" ! -name "00-header.summary.md" -print0 | sort -z)

    ((oversized_summary)) || success 'All summary files within limit'
    echo
  fi

  # Check abstract files
  if [[ "$TIER" == "both" || "$TIER" == "abstract" ]]; then
    info "Checking abstract files (limit: $ABSTRACT_LIMIT bytes)..."
    while IFS= read -r -d '' file; do
      size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
      if ((size > ABSTRACT_LIMIT)); then
        warn "  Oversized: ${file#"$DATA_DIR"/} ($size bytes)"
        oversized_abstract+=1
      fi
    done < <(find "$DATA_DIR" -type f -name "*.abstract.md" ! -name "00-header.abstract.md" -print0 | sort -z)

    ((oversized_abstract)) || success 'All abstract files within limit'
    echo
  fi

  # Summary
  local -i total_oversized=$((oversized_summary + oversized_abstract))
  if ((total_oversized)); then
    warn "${BOLD}Summary:${NC} $total_oversized oversized file(s) found"
    warn 'Run with --regenerate to compress files'
    return 1
  else
    success "${BOLD}Summary:${NC} All files within size limits"
    return 0
  fi
}

# Regenerate mode: compress all files
regenerate_compressed_files() {
  info "${BOLD}Regenerating Compressed Files${NC}"
  echo

  ((DRY_RUN)) && warn 'DRY-RUN mode: No files will be modified'

  # Build bcs compress command
  local -a cmd=("$BCS_CMD" "compress" "--regenerate")
  [[ "$TIER" != "both" ]] && cmd+=(--tier "$TIER")
  cmd+=(--context-level "$CONTEXT_LEVEL")
  cmd+=(--claude-cmd "$CLAUDE_CMD")
  cmd+=(--summary-limit "$SUMMARY_LIMIT")
  cmd+=(--abstract-limit "$ABSTRACT_LIMIT")
  ((VERBOSE)) && cmd+=(--verbose)

  info "Command: ${cmd[*]}"
  >&2 echo

  if ((DRY_RUN)); then
    info 'DRY-RUN: Would execute compression'
    return 0
  fi

  # Execute compression
  if "${cmd[@]}"; then
    success 'Compression completed successfully'
    return 0
  else
    local -i exit_code=$?
    error "Compression failed with exit code $exit_code"
    return "$exit_code"
  fi
}

# Display compression statistics
show_compression_stats() {
  info "${BOLD}Compression Statistics${NC}"

  # Count files by tier
  local -i complete_count summary_count abstract_count
  complete_count=$(find "$DATA_DIR" -type f -name "*.complete.md" ! -name "00-header.complete.md" | wc -l)
  summary_count=$(find "$DATA_DIR" -type f -name "*.summary.md" ! -name "00-header.summary.md" | wc -l)
  abstract_count=$(find "$DATA_DIR" -type f -name "*.abstract.md" ! -name "00-header.abstract.md" | wc -l)

  echo "  Complete tier: $complete_count files"
  echo "  Summary tier:  $summary_count files"
  echo "  Abstract tier: $abstract_count files"
  echo

  # Average sizes
  local -i total_size avg_size
  if ((summary_count)); then
    total_size=$(find "$DATA_DIR" -type f -name "*.summary.md" ! -name "00-header.summary.md" -exec stat -c%s {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
    avg_size=$((total_size / summary_count))
    echo "  Average summary size: $avg_size bytes (limit: $SUMMARY_LIMIT)"
  fi

  if ((abstract_count)); then
    total_size=$(find "$DATA_DIR" -type f -name "*.abstract.md" ! -name "00-header.abstract.md" -exec stat -c%s {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
    avg_size=$((total_size / abstract_count))
    echo "  Average abstract size: $avg_size bytes (limit: $ABSTRACT_LIMIT)"
  fi
}

# Main function
main() {
  parse_arguments "$@"

  info "${BOLD}BCS Rule Compression Workflow${NC}"
  info "Data directory: $DATA_DIR"
  info "Mode: $( ((REPORT_ONLY)) && echo 'Report only' || echo 'Regenerate')"
  [[ "$TIER" != "both" ]] && info "Tier: $TIER"
  info "Context level: $CONTEXT_LEVEL"
  echo

  # Pre-flight checks (only for regenerate mode)
  if ((!REPORT_ONLY)); then
    run_preflight_checks || die 2 'Pre-flight checks failed'
    echo
  fi

  # Execute mode
  if ((REPORT_ONLY)); then
    # Report mode
    if report_oversized_files; then
      exit 0
    else
      exit 1
    fi
  else
    # Regenerate mode
    if regenerate_compressed_files; then
      echo
      show_compression_stats
      echo
      success "${BOLD}Regeneration completed successfully${NC}"
      exit 0
    else
      error "${BOLD}Regeneration failed${NC}"
      exit 1
    fi
  fi
}

main "$@"
#fin
