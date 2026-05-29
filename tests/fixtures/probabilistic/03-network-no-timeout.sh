#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS1104
# bcs-fixture-description: Network fetch via curl with no timeout; a hung server stalls the script indefinitely (BCS1104).

main() {
  local -- url=${1:-https://example.com}
  local -- body
  body=$(curl -fsSL "$url")
  printf '%s\n' "$body"
}

main "$@"
#fin
