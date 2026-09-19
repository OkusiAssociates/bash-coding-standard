#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

greet() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx greet

# --- source fence ---
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# --- Script mode only below ---
greet "${1:-world}"
#fin
