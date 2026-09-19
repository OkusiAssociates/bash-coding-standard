#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- name=${1:-}
  rm -rf -- "/var/cache/myapp/$name" \
    || { printf 'Failed to purge %s\n' "${name@Q}" >&2; return 1; }
}

main "$@"
#fin
