#!/usr/bin/env bash
# bcs-fixture-expect: BCS0101
# bcs-fixture-description: Missing `set -euo pipefail` and `shopt -s inherit_errexit` strict mode per BCS0101.

main() {
  local -- name=${1:-world}
  echo "hello, $name"
}

main "$@"
#fin
