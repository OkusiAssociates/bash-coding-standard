#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin
# bcs-fixture-expect: BCS1206
# bcs-fixture-description: `#shellcheck disable=SC2086` is used without a documented justification comment, violating BCS1206's documented-exceptions requirement.

count_words() {
  local -- text=$1
  # shellcheck disable=SC2086
  echo $text | wc -w
}

main() {
  count_words 'hello world foo bar'
}

main "$@"
#fin
