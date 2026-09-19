#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

if ! ((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)); then
  printf 'Bash 5.2+ required\n' >&2
  exit 1
fi

printf 'ok\n'
#fin
