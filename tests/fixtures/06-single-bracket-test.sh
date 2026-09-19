#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- mode=${1:-staging}
  local -i argc=$#
  if [ "$mode" = production ] && [ "$argc" -gt 5 ]; then
    echo 'production, many arguments'
  else
    echo 'default settings'
  fi
}

main "$@"
#fin
