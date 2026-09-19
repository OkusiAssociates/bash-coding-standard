#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'

main() {
  if [[ ${1:-} == --version ]]; then
    printf '%s %s\n' "${0##*/}" "$VERSION"
    return 0
  fi
  local -- name=${1:-world}
  printf 'Hello, %s\n' "$name"
}

main "$@"
#fin
