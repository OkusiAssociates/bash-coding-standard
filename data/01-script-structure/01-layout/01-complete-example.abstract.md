### Complete Working Example

**Production-quality script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## Minimal Example (Core Pattern)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CONFIG_VAR=${CONFIG_VAR:-default}
declare -i DRY_RUN=0

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      -*)           echo "Invalid: $1" >&2; exit 22 ;;
    esac
    shift
  done
  readonly CONFIG_VAR DRY_RUN
  # Business logic here
}

main "$@"
#fin
```

## Key Patterns

- **Dry-run:** Every operation checks flag before executing
- **Derived paths:** Update dependents when base changes (`update_derived_paths()`)
- **Progressive readonly:** Variables immutable after argument parsing
- **Validation first:** Check prerequisites before filesystem operations

## Anti-Patterns

- `set -e` alone → Must use full `set -euo pipefail` + `inherit_errexit`
- Modifying readonly vars → Make mutable during parsing, readonly after

**Ref:** BCS010101
