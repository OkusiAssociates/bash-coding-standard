#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit nullglob

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
