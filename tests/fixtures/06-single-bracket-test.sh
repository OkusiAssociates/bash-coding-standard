#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- mode=${1:-staging}
  local -i retries=${2:-3}
  if [ "$mode" = production ] && [ "$retries" -gt 5 ]; then
    echo 'production, many retries'
  else
    echo 'default settings'
  fi
}

main "$@"
#fin
