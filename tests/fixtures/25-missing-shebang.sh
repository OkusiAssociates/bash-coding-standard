# shellcheck shell=bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- name=${1:-world}
  printf 'Hello, %s\n' "$name"
}

main "$@"
#fin
