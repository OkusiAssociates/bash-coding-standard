#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS1005
# bcs-fixture-description: A caller-supplied name is joined to a base directory and removed with no validation, so `../..` escapes the base (BCS1005).

main() {
  local -- name=${1:?usage: purge NAME}
  rm -rf -- "/var/cache/myapp/$name" || return 1
  printf 'Purged %s\n' "$name"
}

main "$@"
#fin
