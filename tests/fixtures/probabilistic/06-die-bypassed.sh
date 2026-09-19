#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0602
# bcs-fixture-description: die() is defined, yet one failing exit below it hand-rolls `echo ...; exit 22` instead of calling it (BCS0602).

error() { >&2 printf '%s: error: %s\n' "${0##*/}" "$*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() {
  (($#)) || die 2 'No word given'
  local -- word=$1
  [[ $word =~ ^[a-z]+$ ]] || { >&2 echo "Invalid word ${word@Q}"; exit 22; }
  printf '%s\n' "${word^^}"
}

main "$@"
#fin
