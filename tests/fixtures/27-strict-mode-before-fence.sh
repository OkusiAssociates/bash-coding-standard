#!/usr/bin/env bash
# bcs-fixture-expect: BCS0406
# bcs-fixture-description: Dual-purpose script applies `set -euo pipefail` above the source fence, so sourcing it alters the caller's shell; strict mode belongs below the fence per BCS0406.
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
