#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0702
# bcs-fixture-description: Error messages written to stdout instead of stderr per BCS0702.

main() {
  local -- file=${1:-/etc/hosts}
  if [[ ! -f $file ]]; then
    echo "error: ${file} not found"
    echo 'usage: script.sh FILE'
    exit 1
  fi
  cat "$file"
}

main "$@"
#fin
