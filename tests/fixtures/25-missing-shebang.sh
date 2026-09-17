# shellcheck shell=bash
# bcs-fixture-expect: BCS0102
# bcs-fixture-description: No shebang at all; the first line of a script must be one of the three accepted bash shebangs per BCS0102. The shellcheck shell= directive only keeps the linter usable.
set -euo pipefail
shopt -s inherit_errexit

main() {
  local -- name=${1:-world}
  printf 'Hello, %s\n' "$name"
}

main "$@"
#fin
