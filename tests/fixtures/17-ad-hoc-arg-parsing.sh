#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -i verbose=0
  local -- file=''
  while [[ $# -gt 0 ]]; do
    if [[ $1 == -v ]]; then
      verbose=1
    elif [[ $1 == -i ]]; then
      (($# > 1)) || { >&2 echo 'Option -i requires an argument'; exit 22; }
      shift
      file=$1
    fi
    shift
  done
  echo "verbose=$verbose file=$file"
}

main "$@"
#fin
