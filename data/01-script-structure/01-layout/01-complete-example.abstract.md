### Complete Working Example

**Production installation script demonstrating all 13 BCS0101 mandatory steps.**

---

## Core Pattern (Minimal)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- PREFIX=/usr/local
declare -i DRY_RUN=0 VERBOSE=1

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    show_help; return 0 ;;
      -*)           die 22 "Invalid option ${1@Q}" ;;
    esac
    shift
  done
  readonly PREFIX DRY_RUN VERBOSE
  # business logic here
}
main "$@"
#fin
```

## Key Elements

| Step | Purpose |
|------|---------|
| 1-5 | Shebang, shellcheck, description, strict mode, shopt |
| 6-7 | Metadata (VERSION, SCRIPT_*), globals |
| 8-9 | Colors (TTY-aware), utility functions |
| 10-11 | Business logic, main() with arg parsing |
| 12-13 | `main "$@"`, `#fin` marker |

## Critical Patterns

- **Dry-run**: Check `((DRY_RUN))` before every operation
- **Derived paths**: Update dependent vars when base changes
- **Progressive readonly**: Lock vars after argument parsing
- **Validation first**: Check prerequisites before filesystem ops

## Anti-patterns

- ✗ Modifying readonly vars after `readonly` declaration
- ✗ Missing `#fin` end marker

**Ref:** BCS010101
