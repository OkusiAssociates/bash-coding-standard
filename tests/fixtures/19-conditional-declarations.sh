#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0606
# bcs-fixture-description: `((flag)) && action` chains without trailing `||:`; under `set -e`, script exits when the flag is zero per BCS0606.

declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE)) && echo 'starting'
  ((DRY_RUN)) && echo 'dry-run mode'
  echo 'done'
}

main "$@"
#fin
