#!/usr/bin/env bash
# Generates trim.inc.sh by extracting function definitions from *.bash files
set -euo pipefail

declare -- dest=${1:?Usage: generate-inc.sh DEST}
declare -- dir f
dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

{ cat <<TRIMUTILS
#!/usr/bin/env bash
# Bash String Trim Utilities - Combined Module File
# Source this file to load all trim family functions:
#   source $dest
# Available functions: trim, ltrim, rtrim, trimv, trimall, squeeze
TRIMUTILS

  for f in *.bash; do
    #shellcheck disable=SC1090
    source "$dir"/"$f"
    declare -pf "${f/.bash}"
    echo
  done

  echo '#fin'
} > "$dest"

chmod 644 "$dest"
echo "Generated $dest"
#fin
