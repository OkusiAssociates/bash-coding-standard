### Complete Working Example

**Production script demonstrating all 13 mandatory BCS0101 layout steps.**

---

#### Minimal Template

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=1
die() { (($# < 2)) || >&2 echo "$SCRIPT_NAME: âœ— ${@:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do
    case $1 in
      -h|--help) echo "Usage: $SCRIPT_NAME [options]"; return 0 ;;
      -V|--version) echo "$VERSION"; return 0 ;;
      -*) die 22 "Invalid option ${1@Q}" ;;
    esac
    shift
  done
  # Business logic here
}

main "$@"
#fin
```

#### Key Patterns

- **Dry-run**: Check `DRY_RUN` flag before operations â†' `((DRY_RUN==0)) || { info "[DRY-RUN]..."; return 0; }`
- **Progressive readonly**: `readonly -- VAR1 VAR2` after argument parsing
- **Derived paths**: Update dependent vars when base changes
- **TTY-aware colors**: `[[ -t 1 ]] && RED=$'\033[31m' || RED=''`

#### Anti-patterns

- âœ— Missing `#fin` end marker
- âœ— Modifying readonly vars after declaration â†' `readonly: cannot unset`

**Ref:** BCS010101
