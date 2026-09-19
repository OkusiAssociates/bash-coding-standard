#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- src=${1:-./report}
  [[ -f $src ]] || { >&2 echo "Not found ${src@Q}"; return 3; }
  install -m 755 -- "$src" /usr/local/bin/report.sh \
    || { >&2 echo "Install failed ${src@Q}"; return 1; }
  >&2 echo 'Installed: run report.sh from anywhere on PATH'
}

main "$@"
#fin
