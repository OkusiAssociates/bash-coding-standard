#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

set_var() {
  eval "$1=\$2"
}

main() {
  local -- result=''
  set_var result 'done'
  printf '%s\n' "$result"
}

main "$@"
#fin
