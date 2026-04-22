#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
# bcs-fixture-expect: BCS0202
# bcs-fixture-description: Function variables not declared `local`; pollutes global scope per BCS0202.

process_file() {
  filename=$1
  line_count=$(wc -l < "$filename")
  echo "$filename: $line_count lines"
}

main() {
  process_file /etc/hosts
}

main "$@"
#fin
