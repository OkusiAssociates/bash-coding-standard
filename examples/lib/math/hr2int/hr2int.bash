#!/usr/bin/env bash
# Convert human-readable numbers with size suffixes to plain integers, and reverse

# ----------------------------------------------------------------------
# Function: hr2int
# Desc    : Convert human-readable numbers with size suffixes to plain integers
#         : Lowercase suffixes (b,k,m,g,t,p) = IEC binary format (powers of 1024)
#         : Uppercase suffixes (B,K,M,G,T,P) = SI decimal format (powers of 1000)
#         : No suffix = treated as SI format (base 1000)
# Synopsis: hr2int number[suffix] [number[suffix]]...
# Examples: hr2int 1k     # Returns: 1024 (IEC binary)
#         : hr2int 1K     # Returns: 1000 (SI decimal)
#         : hr2int 34m    # Returns: 35651584 (34 × 1024²)
#         : hr2int 34M    # Returns: 34000000 (34 × 1000²)
hr2int() {
  local -- num h fmt=si
  local -- LC_ALL=C  # Set once, outside the loop
  while (($#)); do
    num=${1:-0}

    # Auto-strip trailing B/b from common patterns like KB, MB, GB
    # This handles the most common user mistake
    if [[ $num =~ ^[-+]?[0-9.]+[KkMmGgTtPp][Bb]$ ]]; then
      num=${num%[Bb]}
    fi

    h=${num: -1}
    if [[ ${h:-} =~ ^[-+]?[0-9.]+$ ]]; then
      fmt=si
    else
      #bcscheck disable=BCS1202  # ASCII comparison: lowercase > 'a', uppercase < 'a'
      if [[ $h > 'a' ]]; then
        fmt=iec
      else
        fmt=si
      fi
    fi
    numfmt --from="$fmt" -- "${num^^}" || { >&2 echo "${FUNCNAME[0]}: Invalid input ${1@Q}"; return 10; }  # ERR_TYPE
    shift
  done
  return 0
}

# ----------------------------------------------------------------------
# Function: int2hr
# Desc    : Convert integers to human-readable format with size suffixes
#         : SI format (base 1000) outputs uppercase suffixes (K,M,G,T,P)
#         : IEC format (base 1024) outputs lowercase suffixes (k,m,g,t,p)
# Synopsis: int2hr number [si|iec] [number [si|iec]]...
#         :   number   Any integer value
#         :   si|iec   Optional format (default: 'si')
#         :            si  = SI decimal format (base 1000)
#         :            iec = IEC binary format (base 1024)
# Examples: int2hr 1000         # Returns: 1.0K (default SI)
#         : int2hr 1024 iec     # Returns: 1.0k (IEC format)
#         : int2hr 35651584 iec # Returns: 34m (IEC format)
int2hr() {
  local -i num
  local -- fmt hr
  while (($#)); do
    # Validate input is an integer
    if ! [[ ${1:-0} =~ ^-?[0-9]+$ ]]; then
      >&2 echo "${FUNCNAME[0]}: Invalid integer ${1@Q}"
      return 10  # ERR_TYPE
    fi

    num=${1:-0}
    fmt=${2:-si}
    fmt=${fmt,,}

    # Pre-validate format
    if [[ ! $fmt =~ ^(si|iec)$ ]]; then
      >&2 echo "${FUNCNAME[0]}: Invalid format ${fmt@Q} (use 'si' or 'iec')"
      return 22  # ERR_INVAL
    fi

    # Use -- to handle negative numbers properly
    hr=$(numfmt --to="$fmt" -- "$num") || { >&2 echo "${FUNCNAME[0]}: Conversion failed for ${num@Q}"; return 9; }  # ERR_RANGE
    [[ $fmt == iec ]] && hr=${hr,,}
    echo "$hr"
    shift
    ((!$#)) || shift
  done
  return 0
}

# --- dual-purpose guard ---
# When sourced: export functions and return. When executed: fall through to script mode.
[[ ${BASH_SOURCE[0]} == "$0" ]] || {
  declare -fx hr2int
  declare -fx int2hr
  return 0
}

# --- script mode ---
set -euo pipefail
shopt -s inherit_errexit

declare -r VERSION=1.0.0
declare -r SCRIPT_NAME=${0##*/}

if [[ $SCRIPT_NAME == hr2int ]]; then
  show_help() {
    cat <<HELP
$SCRIPT_NAME $VERSION - convert human-readable numbers to integers

Usage: $SCRIPT_NAME NUMBER[SUFFIX] [NUMBER[SUFFIX]]...

Converts each NUMBER to a plain integer. The SUFFIX, if present,
determines the conversion base:

  Lowercase (b,k,m,g,t,p)   IEC binary  (powers of 1024)
  Uppercase (B,K,M,G,T,P)   SI decimal  (powers of 1000)
  (no suffix)               SI decimal  (base 1000)

A trailing 'B' or 'b' is auto-stripped (e.g. 'MB' is treated as 'M').

Options:
  -V, --version           Show version
  -h, --help              Show this help

Examples:
  $SCRIPT_NAME 1k         # 1024     (IEC binary)
  $SCRIPT_NAME 1K         # 1000     (SI decimal)
  $SCRIPT_NAME 34m        # 35651584 (34 × 1024²)
  $SCRIPT_NAME 34M        # 34000000 (34 × 1000²)
  $SCRIPT_NAME 2MB 3GB    # 2000000 then 3000000000
HELP
  }

  case ${1:---help} in
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift ;;
    --*|-[a-zA-Z]*) >&2 echo "$SCRIPT_NAME: Invalid option ${1@Q}"; exit 22 ;;
  esac

  hr2int "$@"

elif [[ $SCRIPT_NAME == int2hr ]]; then
  show_help() {
    cat <<HELP
$SCRIPT_NAME $VERSION - convert integers to human-readable numbers

Usage: $SCRIPT_NAME NUMBER [FORMAT] [NUMBER [FORMAT]]...

Converts each NUMBER to a human-readable form. FORMAT is optional
and controls the base and suffix case:

  si    SI decimal  (base 1000), uppercase suffix  [default]
  iec   IEC binary  (base 1024), lowercase suffix

Arguments:
  NUMBER                  Any integer value (negative values allowed)
  FORMAT                  Either 'si' or 'iec' (default: si)

Options:
  -V, --version           Show version
  -h, --help              Show this help

Examples:
  $SCRIPT_NAME 1000              # 1.0K  (default SI)
  $SCRIPT_NAME 1024 iec          # 1.0k  (IEC format)
  $SCRIPT_NAME 35651584 iec      # 34m
  $SCRIPT_NAME 1000 si 1024 iec  # 1.0K then 1.0k
HELP
  }

  case ${1:---help} in
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift ;;
    --*|-[a-zA-Z]*) >&2 echo "$SCRIPT_NAME: Invalid option ${1@Q}"; exit 22 ;;
  esac

  int2hr "$@"

else
  >&2 echo "Invalid basename ${SCRIPT_NAME@Q}"
  exit 21  # ERR_STATE
fi 

#fin
