#!/usr/bin/env bash
# Remove comment lines (starting with #) and blank lines from input
# Dual-purpose: can be sourced for function or executed as filter

# ============================================================================
# LIBRARY FUNCTIONS (available when sourced)
# ============================================================================

# Remove lines starting with # (after optional whitespace) and blank lines
# Usage: remblanks [arguments...]
#   With arguments: processes arguments as single string
#   Without arguments: reads from stdin (pipe mode)
# Returns: 0 on success, grep exit code on failure
remblanks() {
  local -- pattern='^[[:blank:]]*#\|^[[:blank:]]*$'

  if (($#)); then
    # Arguments provided - process as string
    # Using $* (not $@) intentionally to join with spaces
    echo "$*" | grep -v "$pattern"
  else
    # No arguments - read from stdin (pipe mode)
    grep -v "$pattern"
  fi
}
declare -fx remblanks

# Early return for sourced mode - stops here when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# ============================================================================
# EXECUTABLE MODE (only runs when executed directly)
# ============================================================================
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata with re-sourcing guard
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -r SCRIPT_VERSION='1.0.0'
  #shellcheck disable=SC2155
  declare -r SCRIPT_PATH=$(realpath -- "$0")
  declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
fi

# Main execution - simple passthrough to library function
remblanks "$@"

#fin
