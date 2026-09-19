#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS0110
# bcs-fixture-description: Creates a temp directory with `mktemp -d` but installs no `trap` for cleanup per BCS0110.

declare -- TEMP_DIR

main() {
  TEMP_DIR=$(mktemp -d) || { >&2 echo 'Cannot create temp dir'; exit 1; }
  cp -- /etc/hosts "$TEMP_DIR"/ || { >&2 echo 'Cannot copy hosts file'; exit 1; }
  ls -la -- "$TEMP_DIR"
}

main "$@"
#fin
