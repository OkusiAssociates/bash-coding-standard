#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- url=${1:-https://example.com}
  local -- body
  command -v curl >/dev/null || { >&2 echo 'curl required'; return 18; }
  body=$(curl -fsSL "$url") || { >&2 echo "Fetch failed ${url@Q}"; return 1; }
  printf '%s\n' "$body"
}

main "$@"
#fin
