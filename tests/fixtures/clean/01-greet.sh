#!/usr/bin/env bash
# bcs-fixture-expect:
# bcs-fixture-description: Fully BCS-compliant minimal script; any finding is a false positive.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'

main() {
  if [[ ${1:-} == --version ]]; then
    printf '%s\n' "$VERSION"
    return 0
  fi
  local -- name=${1:-world}
  printf 'Hello, %s\n' "$name"
}

main "$@"
#fin
