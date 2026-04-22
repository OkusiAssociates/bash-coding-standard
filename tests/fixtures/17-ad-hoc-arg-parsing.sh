#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0801
# bcs-fixture-description: Ad-hoc `[[ $# -gt 0 ]]` with `if/elif` argument parsing instead of the BCS0801 `while (($#)); do case` pattern.

main() {
  local -i verbose=0
  local -- file=''
  while [[ $# -gt 0 ]]; do
    if [[ $1 == -v ]]; then
      verbose=1
    elif [[ $1 == -f ]]; then
      shift
      file=$1
    fi
    shift
  done
  echo "verbose=$verbose file=$file"
}

main "$@"
#fin
