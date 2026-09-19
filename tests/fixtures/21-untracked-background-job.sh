#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit nullglob
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

process_one() {
  sleep 1
  printf 'done: %s\n' "$1"
}

main() {
  local -- f
  for f in /tmp/job-*.in; do
    process_one "$f" &
  done
  >&2 printf 'all launched\n'
}

main "$@"
#fin
