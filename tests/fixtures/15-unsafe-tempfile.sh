#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -r TEMP_FILE=/tmp/bcs_fixture_$$.tmp
trap 'rm -f -- "$TEMP_FILE"' EXIT

main() {
  echo 'payload' > "$TEMP_FILE"
  cat -- "$TEMP_FILE"
}

main "$@"
#fin
