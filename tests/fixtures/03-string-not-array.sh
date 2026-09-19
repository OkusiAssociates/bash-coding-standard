#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- raw='alpha beta gamma' item
  # shellcheck disable=SC2206  # raw is space-delimited by contract
  local -a items=($raw)
  for item in "${items[@]}"; do
    echo "$item"
  done
}

main "$@"
#fin
