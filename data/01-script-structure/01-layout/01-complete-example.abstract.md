### Complete Working Example

**Production-quality script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## 13-Step Pattern (Minimal)

```bash
#!/bin/bash
#shellcheck disable=SC2034
# Description comment
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CONFIG_VAR=default
declare -i DRY_RUN=0

# Colors (TTY-aware)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Messaging functions
error() { >&2 echo "$SCRIPT_NAME: ${RED}âœ—${NC} $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Business logic
do_work() { ((DRY_RUN)) && { echo '[DRY-RUN]'; return 0; }; }

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      *)            die 22 "Invalid: ${1@Q}" ;;
    esac
    shift
  done
  readonly -i DRY_RUN
  do_work
}

main "$@"
#fin
```

## Key Patterns

- **Metadata** â†' VERSION, SCRIPT_PATH/DIR/NAME with grouped `readonly --`
- **TTY colors** â†' `[[ -t 1 && -t 2 ]]` conditional
- **Dry-run** â†' `declare -i DRY_RUN=0`, check via `((DRY_RUN))`
- **Progressive readonly** â†' After arg parsing: `readonly -i DRY_RUN`

**Ref:** BCS010101
