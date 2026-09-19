#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- file=${1:-/etc/hosts}
  if [[ ! -f $file ]]; then
    echo "error: $file not found"
    echo 'usage: script.sh FILE'
    exit 3
  fi
  cat -- "$file"
}

main "$@"
#fin
