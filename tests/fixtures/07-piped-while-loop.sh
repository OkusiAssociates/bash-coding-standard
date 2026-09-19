#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -i count=0
  local -- line
  # shellcheck disable=SC2030,SC2031  # the count is only reported inside the loop
  grep -v '^$' /etc/hosts | while IFS= read -r line; do
    count+=1
    echo "line $count: $line"
  done
  echo "final count (always zero): $count"
}

main "$@"
#fin
