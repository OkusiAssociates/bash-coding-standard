#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0303
# bcs-fixture-description: RHS of `=~` is quoted, which disables regex matching per BCS0303.

main() {
  local -- input=${1:-abc123}
  # shellcheck disable=SC2076
  if [[ $input =~ "^[a-z]+[0-9]+$" ]]; then
    echo 'matched'
  else
    echo 'no match'
  fi
}

main "$@"
#fin
