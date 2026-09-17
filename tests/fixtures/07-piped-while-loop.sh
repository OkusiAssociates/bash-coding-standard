#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0504
# bcs-fixture-description: Pipes into `while read`, creating a subshell that loses variable mutations; BCS0504 is the canonical code for pipe-to-while (BCS0503 and BCS0903 defer to it).

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
