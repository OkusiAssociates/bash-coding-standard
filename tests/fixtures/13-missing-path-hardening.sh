#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

main() {
  grep -c '^' /etc/hosts
  awk 'NR==1' /etc/hosts
}

main "$@"
#fin
