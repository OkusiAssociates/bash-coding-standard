#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS1006
# bcs-fixture-description: Hardcoded `/tmp/<name>_$$` temp path is predictable per BCS1006; should use `mktemp`.

declare -r TEMP_FILE=/tmp/bcs_fixture_$$.tmp
trap 'rm -f -- "$TEMP_FILE"' EXIT

main() {
  echo 'payload' > "$TEMP_FILE"
  cat -- "$TEMP_FILE"
}

main "$@"
#fin
