#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0507
# bcs-fixture-description: Parses a version tag with external grep/cut instead of [[ =~ ]] + BASH_REMATCH (BCS0507, recommended).

main() {
  local -- tag=${1:-v1.2}
  local -- major minor
  major=$(printf '%s' "$tag" | grep -oE '[0-9]+' | head -1)
  minor=$(printf '%s' "$tag" | cut -d. -f2)
  printf 'major=%s minor=%s\n' "$major" "$minor"
}

main "$@"
#fin
