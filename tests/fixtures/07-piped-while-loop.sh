#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0503 BCS0903
# bcs-fixture-description: Pipes into `while read`, creating a subshell that loses variable mutations per BCS0503/BCS0903.

main() {
  local -i count=0
  # shellcheck disable=SC2030,SC2031
  grep -v '^$' /etc/hosts | while IFS= read -r line; do
    count+=1
    echo "line $count: $line"
  done
  echo "final count (always zero): $count"
}

main "$@"
#fin
