#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  chmod -- u+s "$0"
  >&2 printf 'installed\n'
}

main "$@"
#fin
