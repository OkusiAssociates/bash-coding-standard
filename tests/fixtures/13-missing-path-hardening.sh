#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS1002
# bcs-fixture-description: Script calls external commands without hardening PATH at start per BCS1002.

main() {
  grep -c '^' /etc/hosts
  awk 'NR==1' /etc/hosts
}

main "$@"
#fin
