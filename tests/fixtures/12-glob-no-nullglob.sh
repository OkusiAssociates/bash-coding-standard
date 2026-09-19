#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- f
  for f in *.log; do
    [[ -f $f ]] || continue
    echo "$f"
  done
  # shellcheck disable=SC2035  # deleting by pattern is intended
  rm -f *.tmp 2>/dev/null ||:
}

main "$@"
#fin
