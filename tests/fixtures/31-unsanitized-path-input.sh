#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS1005
# bcs-fixture-description: Builds a path from a raw argument with no validation and no `--`, so `../../etc` or `-rf` reaches rm; user input must be validated per BCS1005.

declare -r CACHE_DIR=/var/cache/myapp

main() {
  local -- name=${1:-}
  [[ -n $name ]] || { >&2 echo 'usage: purge NAME'; return 2; }
  # shellcheck disable=SC2115
  rm -rf "$CACHE_DIR"/"$name" || { >&2 echo "Cannot remove ${name@Q}"; return 1; }
  echo "Purged $name"
}

main "$@"
#fin
