#!/usr/bin/env bash
# Generates trim.inc.sh by extracting function definitions from *.bash files
set -euo pipefail

declare -- dest=${1:?Usage: generate-inc.sh DEST}
declare -- dir
dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

{
  echo '#!/usr/bin/env bash'
  echo '# Bash String Trim Utilities - Combined Module File'
  echo '# Source this file to load all trim functions:'
  echo "#   source $dest"
  echo '# Available functions: trim, ltrim, rtrim, trimv, trimall, squeeze'
  echo

  for f in trim ltrim rtrim trimv trimall squeeze; do
    #shellcheck disable=SC1090
    source "$dir"/"$f".bash
    declare -pf "$f"
    echo
  done

  echo '#fin'
} > "$dest"

chmod 644 "$dest"
echo "Generated $dest"
#fin
