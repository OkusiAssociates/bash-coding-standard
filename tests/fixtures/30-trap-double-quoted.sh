#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0603
# bcs-fixture-description: Trap command in double quotes expands `$TEMP_FILE` when the trap is installed (still empty), so the temp file is never removed; trap commands must be single-quoted per BCS0603.

declare -- TEMP_FILE=''
# shellcheck disable=SC2064
trap "rm -f -- $TEMP_FILE" EXIT

main() {
  TEMP_FILE=$(mktemp) || { >&2 echo 'mktemp failed'; return 1; }
  printf '%s\n' 'scratch data' > "$TEMP_FILE"
  wc -c < "$TEMP_FILE"
}

main "$@"
#fin
