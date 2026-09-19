#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

main() {
  local -- kernel user
  # shellcheck disable=SC2006  # kept as the original author wrote it
  kernel=`uname -r`
  # shellcheck disable=SC2006  # kept as the original author wrote it
  user=`whoami`
  echo "$user on $kernel"
}

main "$@"
#fin
