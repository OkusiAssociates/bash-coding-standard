#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'

count_nonblank() {
  local -- file=$1
  local -i lines=0
  local -- line
  while IFS= read -r line; do
    if [[ -n $line ]]; then
      lines+=1
    fi
  done < "$file"
  printf '%d\n' "$lines"
}

main() {
  if [[ ${1:-} == --version ]]; then
    printf '%s %s\n' "${0##*/}" "$VERSION"
    return 0
  fi
  local -- file=${1:-}
  if [[ ! -f $file ]]; then
    printf 'not a file: %s\n' "${file@Q}" >&2
    return 3
  fi
  count_nonblank "$file"
}

main "$@"
#fin
