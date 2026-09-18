#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS1206
# bcs-fixture-description: A `#shellcheck disable=SC2155` directive with no reason given, on the line or above it, violating BCS1206's documented-exceptions requirement.

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
}

main "$@"
#fin
