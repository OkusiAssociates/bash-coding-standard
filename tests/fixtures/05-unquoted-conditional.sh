#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- input=${1:-abc123}
  # shellcheck disable=SC2076  # a literal match is what is wanted
  if [[ $input =~ "^[a-z]+[0-9]+$" ]]; then
    echo 'matched'
  else
    echo 'no match'
  fi
}

main "$@"
#fin
