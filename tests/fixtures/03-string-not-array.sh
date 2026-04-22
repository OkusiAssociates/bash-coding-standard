#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0206
# bcs-fixture-description: Word-splits a string into an array and iterates with unquoted `${arr[@]}` per BCS0206 anti-pattern.

main() {
  local -- raw='alpha beta gamma'
  # shellcheck disable=SC2206
  local -a items=($raw)
  # shellcheck disable=SC2068
  for item in ${items[@]}; do
    echo "$item"
  done
}

main "$@"
#fin
