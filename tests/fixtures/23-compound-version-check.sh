#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0409
# bcs-fixture-description: Bash version gate uses one compound `&&` over major/minor; wrongly rejects Bash 6.0 (BCS0409).

if ! ((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)); then
  printf 'Bash 5.2+ required\n' >&2
  exit 1
fi

printf 'ok\n'
#fin
