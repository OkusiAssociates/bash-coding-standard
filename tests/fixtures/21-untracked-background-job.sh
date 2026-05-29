#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit nullglob
# bcs-fixture-expect: BCS1101
# bcs-fixture-description: Background jobs launched with `&` but their PIDs are never captured or waited on (BCS1101).

process_one() {
  sleep 1
  printf 'done: %s\n' "$1"
}

main() {
  local -- f
  for f in /tmp/job-*.in; do
    process_one "$f" &
  done
  printf 'all launched\n'
}

main "$@"
#fin
