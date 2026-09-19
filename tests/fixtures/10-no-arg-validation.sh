#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- output=''
  while (($#)); do case $1 in
    -o|--output) shift; output=${1:-} ;;
    *) break ;;
  esac; shift; done
  echo "output=${output:-none}"
}

main "$@"
#fin
