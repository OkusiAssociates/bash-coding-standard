#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0210 BCS1004
# bcs-fixture-description: Assigns through a variable name with eval instead of a `local -n` nameref (BCS0210; also BCS1004 eval-avoidance).

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
