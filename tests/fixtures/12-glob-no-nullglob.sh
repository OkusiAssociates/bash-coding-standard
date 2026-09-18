#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS0902
# bcs-fixture-description: Globs without `./` path prefix; a file named `-rf` could hijack commands as flags per BCS0902.

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
