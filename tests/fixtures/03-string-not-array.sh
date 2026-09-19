#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- raw='alpha beta gamma'
  # shellcheck disable=SC2206  # raw is space-delimited by contract
  local -a items=($raw)
  # shellcheck disable=SC2068  # items never contain blanks
  for item in ${items[@]}; do
    echo "$item"
  done
}

main "$@"
#fin
