#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0504
# bcs-fixture-description: Pipes `find` output into a while loop; BCS0504 mandates `< <(command)` process substitution to preserve variables.

main() {
  local -a files=()
  # shellcheck disable=SC2030,SC2031
  find /etc -maxdepth 1 -type f 2>/dev/null | while IFS= read -r f; do
    files+=("$f")
  done
  echo "collected (always empty): ${#files[@]}"
}

main "$@"
#fin
