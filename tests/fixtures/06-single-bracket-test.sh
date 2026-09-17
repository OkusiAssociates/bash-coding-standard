#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0501
# bcs-fixture-description: Uses single-bracket `[ ... ]` conditionals on strings and numbers; BCS0501 mandates `[[ ... ]]` and `(( ... ))`. (File tests in `[ ]` belong to BCS0901.)

main() {
  local -- mode=${1:-staging}
  local -i retries=${2:-3}
  if [ "$mode" = production ] && [ "$retries" -gt 5 ]; then
    echo 'production, many retries'
  else
    echo 'default settings'
  fi
}

main "$@"
#fin
