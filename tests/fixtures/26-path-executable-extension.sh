#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0106
# bcs-fixture-description: Installs a PATH-wide executable under a `.sh` name; globally available executables must have no extension per BCS0106.

main() {
  local -- src=${1:-./report}
  [[ -f $src ]] || { >&2 echo "Not found ${src@Q}"; return 3; }
  install -m 755 -- "$src" /usr/local/bin/report.sh || return 1
  >&2 echo 'Installed: run report.sh from anywhere on PATH'
}

main "$@"
#fin
