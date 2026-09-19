#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -- TEMP_DIR

main() {
  TEMP_DIR=$(mktemp -d) || { >&2 echo 'Cannot create temp dir'; exit 1; }
  cp -- /etc/hosts "$TEMP_DIR"/ || { >&2 echo 'Cannot copy hosts file'; exit 1; }
  ls -la -- "$TEMP_DIR"
}

main "$@"
#fin
