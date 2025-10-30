#!/bin/bash
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
  local LC_ALL=C  # Set once, outside the loop
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
      if [[ "$h" > 'a' ]]; then
        fmt=iec
      else
        fmt=si
      fi
    fi
    numfmt --from="$fmt" "${num^^}" || { >&2 echo "${FUNCNAME[0]}: Invalid input ${1@Q}"; return 1; }
    shift 1
  done
  return 0
}
declare -fx hr2int

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
      return 1
    fi

    num=$(( ${1:-0} ))
    fmt=${2:-si}
    fmt=${fmt,,}

    # Pre-validate format
    if [[ ! $fmt =~ ^(si|iec)$ ]]; then
      >&2 echo "${FUNCNAME[0]}: Invalid format ${fmt@Q} (use 'si' or 'iec')"
      return 1
    fi

    # Use -- to handle negative numbers properly
    hr=$(numfmt --to="$fmt" -- "$num") || { >&2 echo "${FUNCNAME[0]}: Conversion failed for ${num@Q}'"; return 1; }
    [[ $fmt == 'iec' ]] && hr="${hr,,}"
    echo "$hr"
    shift 1
    (($#==0)) || shift 1
  done
  return 0
}
declare -fx int2hr

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

#/bin/bash #semantic ----------------------------------------------------------
set -euo pipefail

# Quick help
if [[ $* == *'-h'* ]]; then
  grep '^# ' "$(realpath -e -- "$0")" | sed 's/^# //'
  exit 0
fi


if [[ $(basename -- "$0") == hr2int ]]; then
  hr2int "$@"
elif [[ $(basename -- "$0") == int2hr ]]; then
  int2hr "$@"
else
  >&2 echo "Invalid basename $(basename -- "$0")"
  exit 1
fi 

#fin
