#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- pattern=${1:-root} file=${2:-/etc/passwd}
  local -i rc
  set +e
  grep -q -- "$pattern" "$file"
  rc=$?
  set -e
  if ((rc)); then
    >&2 echo "No match for ${pattern@Q}"
    return 1
  fi
  echo "Found $pattern"
}

main "$@"
#fin
