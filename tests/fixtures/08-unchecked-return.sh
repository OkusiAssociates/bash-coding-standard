#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0604
# bcs-fixture-description: Critical `mv` and `cp` invocations have no `|| die` guard or context message per BCS0604.

main() {
  local -- src=${1:-/etc/hosts} dst=/tmp/bcs_fixture_hosts
  cp "$src" "$dst"
  mv "$dst" "$dst".bak
  echo "staged at $dst.bak"
}

main "$@"
#fin
