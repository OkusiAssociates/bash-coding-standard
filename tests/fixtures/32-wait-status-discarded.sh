#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -a pids=()
  local -- file pid
  for file in "$@"; do
    gzip -k -- "$file" &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid" ||:
  done
  >&2 echo 'All jobs finished'
}

main "$@"
#fin
