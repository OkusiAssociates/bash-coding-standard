#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- src=${1:-/etc/hosts} dst=${2:-hosts.staged}
  cp -- "$src" "$dst"
  mv -- "$dst" "$dst".bak
  >&2 echo "staged at $dst.bak"
}

main "$@"
#fin
