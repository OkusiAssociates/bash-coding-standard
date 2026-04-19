#!/usr/bin/env bash
# Normalizes whitespace by removing leading/trailing whitespace and collapsing multiple spaces to single spaces
# shellcheck disable=SC2048,SC2086  # Intentional: unquoted expansion for word-splitting normalization

trimall() {
  local -i process_escape=0

  # Check for -e flag to process escape sequences
  if [[ ${1:-} == '-e' ]]; then
    process_escape=1
    shift
  fi

  # Process arguments if provided
  if (($#)); then
    local -- v

    # Process escape sequences if -e flag was used
    if ((process_escape)); then
      v=$(printf '%b' "$*")
    else
      v="$*"
    fi

    # Intentional unquoted expansion: IFS word splitting collapses all
    # whitespace (spaces, tabs, newlines) between arguments, then $*
    # joins them with the first character of IFS (space by default).
    set -f  # Disable globbing to prevent * and ? expansion
    set -- $v
    printf '%s\n' "$*"
    set +f  # Restore globbing
    return 0
  fi

  # Process stdin if no arguments provided
  if [[ ! -t 0 ]]; then
    # Read all input into a variable
    local -- content=''
    local -- line

    # Process each line from stdin
    while IFS= read -r line || [[ -n $line ]]; do
      # Add each line to content with a space
      [[ -z $content ]] || content+=' '
      content+=$line
    done

    # If we have content, normalize it
    if [[ -n $content ]]; then
      set -f
      set -- $content
      printf '%s\n' "$*"
      set +f
    fi
  fi
}

# Check if the script is being sourced or executed directly
[[ ${BASH_SOURCE[0]} == "$0" ]] || { declare -fx trimall; return 0; }

# --- script mode ---
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -r VERSION='1.0.0' SCRIPT_NAME=${0##*/}

die() { (($# < 2)) || >&2 echo "$SCRIPT_NAME: ✗ ${*:2}"; exit "${1:-0}"; }

if (($#)); then
  case $1 in
    -h|--help)
        cat <<HELP
$SCRIPT_NAME $VERSION - Normalize whitespace in string

Strips leading and trailing whitespace and collapses consecutive blanks
(spaces, tabs, newlines) to single spaces.

Usage: trimall [-e] string    # Normalize whitespace in string
       trimall < file         # Process stdin stream

Options:
  -e             Process escape sequences in the input string
  -V, --version  Display "$SCRIPT_NAME $VERSION"
  -h, --help     Display this help message

Source mode:
  Sourcing is the primary intended usage for this utility.

  source trimall                               # Single utility
  source /usr/local/share/yatti/trim/trim.inc.sh     # All utilities

  result=\$(trimall "  hello    world  ")

Examples:
  str="  multiple    spaces   here  "
  str=\$(trimall "\$str")     # Result: "multiple spaces here"
  echo "  line1\n  line2  " | trimall  # Output: "line1 line2"

See also: trim, ltrim, rtrim, trimv, squeeze
HELP
        exit 0
        ;;
    -V|--version)
        printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
        exit 0
        ;;
    -e) ;;
    --) shift ;;
    -*) die 22 "Unknown option ${1@Q}" ;;
    *)  ;;
  esac
fi

trimall "$@"
#fin
