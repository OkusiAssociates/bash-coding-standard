#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'

sum_ints() {
  local -i total=0
  local -- arg
  for arg in "$@"; do
    [[ $arg =~ ^[0-9]+$ ]] || continue
    total+=$arg
  done
  printf '%d\n' "$total"
}

main() {
  if [[ ${1:-} == --version ]]; then
    printf '%s %s\n' "${0##*/}" "$VERSION"
    return 0
  fi
  sum_ints "$@"
}

main "$@"
#fin
