#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0704
# bcs-fixture-description: Help is printed through info(), which VERBOSE gates, so `-q -h` prints nothing (BCS0704).

declare -i VERBOSE=1
declare -a WORDS=()

_msg() { >&2 printf '%s: %s %s\n' "${0##*/}" "$1" "${*:2}"; }
info() { ((VERBOSE)) || return 0; _msg '◉' "$@"; }
error() { _msg '✗' "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do case $1 in
    -q|--quiet) VERBOSE=0 ;;
    -h|--help)  info "Usage: ${0##*/} [-q] WORD..."; exit 0 ;;
    -[qh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
    -*)         die 22 "Invalid option ${1@Q}" ;;
    *)          WORDS+=("$1") ;;
  esac; shift; done
  readonly VERBOSE WORDS
  ((${#WORDS[@]})) || die 2 'No word given'
  info "${#WORDS[@]} word(s)"
  printf '%s\n' "${WORDS[@]^^}"
}

main "$@"
#fin
