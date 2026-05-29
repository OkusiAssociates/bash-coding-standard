#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS1001
# bcs-fixture-description: Script sets the SUID bit on itself; SUID on Bash scripts is forbidden (BCS1001).

main() {
  chmod u+s "$0"
  printf 'installed\n'
}

main "$@"
#fin
