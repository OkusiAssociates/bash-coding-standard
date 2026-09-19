#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- file=${1:-/etc/hosts}
  if test -f "$file" && test -r "$file"; then
    head -1 "$file"
  fi
}

main "$@"
#fin
