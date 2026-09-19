#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE)) && >&2 echo 'starting'
  ((DRY_RUN)) && >&2 echo 'dry-run mode'
  >&2 echo 'done'
}

main "$@"
#fin
