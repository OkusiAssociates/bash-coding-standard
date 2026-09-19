#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- now user
  # shellcheck disable=SC2006  # kept as the original author wrote it
  now=`date +%s`
  # shellcheck disable=SC2006  # kept as the original author wrote it
  user=`whoami`
  echo "$user at $now"
}

main "$@"
#fin
