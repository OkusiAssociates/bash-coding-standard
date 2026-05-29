#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit nullglob
# bcs-fixture-expect: BCS0410
# bcs-fixture-description: Recursive walk uses loop variable `entry` without `local`; recursion corrupts the caller's value (BCS0410).

walk() {
  local -- dir=$1
  for entry in "$dir"/*; do
    if [[ -d $entry ]]; then
      walk "$entry"
    else
      printf '%s\n' "$entry"
    fi
  done
}

walk "${1:-.}"
#fin
