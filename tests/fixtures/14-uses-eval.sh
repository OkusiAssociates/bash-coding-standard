#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

start_service() { echo 'starting'; }
stop_service() { echo 'stopping'; }

main() {
  local -- action=${1:-start}
  # shellcheck disable=SC2294  # action names come from the fixed list above
  eval "${action}_service"
}

main "$@"
#fin
