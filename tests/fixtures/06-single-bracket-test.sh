#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0501
# bcs-fixture-description: Uses single-bracket `[ ... ]` conditionals; BCS0501 mandates `[[ ... ]]` for strings and files.

main() {
  local -- file=${1:-/etc/hosts}
  if [ -f "$file" ] && [ -r "$file" ]; then
    echo 'readable'
  else
    echo 'not readable'
  fi
}

main "$@"
#fin
