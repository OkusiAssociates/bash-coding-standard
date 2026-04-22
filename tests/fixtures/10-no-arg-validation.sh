#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0803
# bcs-fixture-description: Option `-o` captures `$1` after `shift` without a `noarg` check; missing argument silently corrupts state per BCS0803.

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
