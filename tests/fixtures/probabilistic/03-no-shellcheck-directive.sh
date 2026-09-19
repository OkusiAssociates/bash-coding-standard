#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
}

main "$@"
#fin
