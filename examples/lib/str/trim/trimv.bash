#!/usr/bin/env bash
# Removes leading and trailing whitespace and assigns result to a variable

trimv() {
  local -i _trimv__escape=0
  local -- _trimv__varname=''

  # Process command line options
  if (($#)); then
    # Check for -e flag to process escape sequences
    if [[ $1 == '-e' ]]; then
      _trimv__escape=1
      shift
    fi

    # Check for -n flag to specify a variable name
    if [[ ${1:-} == '-n' ]]; then
      # Get variable name, default to TRIM
      _trimv__varname=${2:-TRIM}

      # Validate variable name
      [[ $_trimv__varname =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || {
        >&2 echo "trimv: invalid variable name ${_trimv__varname@Q}"
        return 1
      }

      # Remove processed arguments
      shift 2
    fi
  fi

  # Process command-line arguments if present
  if (($#)); then
    local -- _trimv__val

    # Process escape sequences if -e flag was used
    if ((_trimv__escape)); then
      _trimv__val=$(printf '%b' "$*")
    else
      _trimv__val="$*"
    fi

    # Remove leading whitespace using parameter expansion
    _trimv__val=${_trimv__val#"${_trimv__val%%[![:blank:]]*}"}
    # Remove trailing whitespace
    _trimv__val=${_trimv__val%"${_trimv__val##*[![:blank:]]}"}

    if [[ -n $_trimv__varname ]]; then
      # Assign to the target variable via nameref
      local -n _trimv__ref=$_trimv__varname
      _trimv__ref=$_trimv__val
    else
      # Otherwise print to stdout
      printf '%s\n' "$_trimv__val"
    fi
    return 0
  fi

  # Process stdin if no arguments
  if [[ ! -t 0 ]]; then
    if [[ -n $_trimv__varname ]]; then
      # Accumulate trimmed lines into a string
      local -- _trimv__content='' _trimv__line
      while IFS= read -r _trimv__line || [[ -n $_trimv__line ]]; do
        # Remove leading and trailing whitespace
        _trimv__line=${_trimv__line#"${_trimv__line%%[![:blank:]]*}"}
        _trimv__line=${_trimv__line%"${_trimv__line##*[![:blank:]]}"}
        _trimv__content+="$_trimv__line"$'\n'
      done
      # Remove trailing newline added by the loop
      _trimv__content=${_trimv__content%$'\n'}

      # Assign via nameref
      local -n _trimv__ref=$_trimv__varname
      _trimv__ref=$_trimv__content
    else
      # Process line by line for stdout
      local -- REPLY
      while IFS= read -r REPLY || [[ -n $REPLY ]]; do
        # Remove leading and trailing whitespace
        REPLY=${REPLY#"${REPLY%%[![:blank:]]*}"}
        REPLY=${REPLY%"${REPLY##*[![:blank:]]}"}
        echo "$REPLY"
      done
    fi
  fi
}

# Check if the script is being sourced or executed directly
[[ ${BASH_SOURCE[0]} == "$0" ]] || { declare -fx trimv; return 0; }

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
$SCRIPT_NAME $VERSION - Remove leading and trailing whitespace and assign to a variable

Usage:
  source trimv
  trimv [-e] [-n varname] string

Options:
  -e            Process escape sequences in the input string
  -n varname    Variable to store result (defaults to TRIM)
  -V, --version Display "$SCRIPT_NAME $VERSION"
  -h, --help    Display this help message

Examples:
  source trimv
  trimv -n RESULT "  hello world  "
  echo "\$RESULT"                        # Outputs: hello world

  trimv -e -n CONTENT "\\t hello \\n"     # Process escape sequences
  cat file.txt | trimv -n DATA          # Read from stdin

Source mode:
  This utility MUST be sourced to use -n variable assignment.
  Running as a script, assignments only affect the subprocess.

  source trimv                              # Single utility
  source /usr/local/share/yatti/trim/trim.inc.sh # All utilities

Inline alternatives:
  For tight loops, avoid function call overhead with direct
  parameter expansion:

  v="\${v#"\${v%%[![:blank:]]*}"}"             # Leading
  v="\${v%"\${v##*[![:blank:]]}"}"             # Trailing
  v="\${v#"\${v%%[![:blank:]]*}"}"; v="\${v%"\${v##*[![:blank:]]}"}"  # Both

See also: trim, ltrim, rtrim, trimall, squeeze
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

trimv "$@"
#fin
