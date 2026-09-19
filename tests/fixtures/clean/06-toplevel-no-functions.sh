#!/usr/bin/env bash
#shellcheck disable=SC2015  # `a && b ||:` guards errexit; the `||:` is not an else-branch
set -euo pipefail
shopt -s inherit_errexit

declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -r CSV_LINE=${1:-'alpha,beta,gamma'}
declare -a FIELDS=()
declare -i INDEX=0
declare -- FIELD='' TODAY=''

IFS=',' read -ra FIELDS <<< "$CSV_LINE"
((${#FIELDS[@]})) || { >&2 echo 'No fields given'; exit 2; }

printf -v TODAY '%(%F)T' -1

cat <<'HEADER'
# index  field   (a literal $HOME stays literal here)
HEADER

for FIELD in "${FIELDS[@]}"; do
  INDEX+=1
  printf '%d\t%s\n' "$INDEX" "$FIELD"
done

((INDEX > 2)) && >&2 echo "Note: $INDEX fields on $TODAY" ||:
#fin
