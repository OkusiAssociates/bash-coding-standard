#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE)) && echo 'starting'
  ((DRY_RUN)) && echo 'dry-run mode'
  echo 'done'
}

main "$@"
#fin
