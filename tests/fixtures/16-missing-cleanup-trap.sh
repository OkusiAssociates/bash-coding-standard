#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0110
# bcs-fixture-description: Creates a temp directory with `mktemp -d` but installs no `trap` for cleanup per BCS0110.

declare -- TEMP_DIR

main() {
  TEMP_DIR=$(mktemp -d) || exit 1
  cp /etc/hosts "$TEMP_DIR"/
  ls -la "$TEMP_DIR"
  # No trap handler for SIGINT/SIGTERM/EXIT — stale directory on failure.
}

main "$@"
#fin
