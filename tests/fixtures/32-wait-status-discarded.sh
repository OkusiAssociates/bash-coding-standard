#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS1103
# bcs-fixture-description: Waits on tracked background jobs with `wait "$pid" ||:`, discarding every exit code so failed jobs go unnoticed; failures must be accumulated per BCS1103.

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
  echo 'All jobs finished'
}

main "$@"
#fin
