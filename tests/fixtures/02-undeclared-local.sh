#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

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
