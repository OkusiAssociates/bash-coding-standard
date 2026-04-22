#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0901
# bcs-fixture-description: Uses `test -f` / `test -r` instead of `[[ -f ... ]]` / `[[ -r ... ]]` per BCS0901.

main() {
  local -- file=${1:-/etc/hosts}
  if test -f "$file" && test -r "$file"; then
    head -1 "$file"
  fi
}

main "$@"
#fin
