#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0302
# bcs-fixture-description: Uses legacy backtick command substitution instead of `$(...)` per BCS0302.

main() {
  local -- now user
  # shellcheck disable=SC2006
  now=`date +%s`
  # shellcheck disable=SC2006
  user=`whoami`
  echo "$user at $now"
}

main "$@"
#fin
