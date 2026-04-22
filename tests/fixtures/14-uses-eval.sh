#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS1004
# bcs-fixture-description: Uses `eval` for dynamic function dispatch where a `case` statement would be safer per BCS1004.

start_service() { echo 'starting'; }
stop_service() { echo 'stopping'; }

main() {
  local -- action=${1:-start}
  # shellcheck disable=SC2294
  eval "${action}_service"
}

main "$@"
#fin
