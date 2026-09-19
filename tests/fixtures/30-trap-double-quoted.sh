#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -- TEMP_FILE=''
# shellcheck disable=SC2064  # the path is fixed once set
trap "rm -f -- $TEMP_FILE" EXIT

main() {
  TEMP_FILE=$(mktemp) || { >&2 echo 'mktemp failed'; return 1; }
  printf '%s\n' 'scratch data' > "$TEMP_FILE"
  wc -c < "$TEMP_FILE"
}

main "$@"
#fin
