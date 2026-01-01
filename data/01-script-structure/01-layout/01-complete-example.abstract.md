### Complete Working Example

**Production-quality installation script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## Key Elements

- **Initialization:** Shebang â†' shellcheck â†' description â†' `set -euo pipefail` â†' shopt
- **Metadata block:** `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` â†' `readonly --`
- **Globals:** Configuration vars â†' derived paths â†' runtime flags (`declare -i`) â†' arrays
- **Colors:** TTY-conditional: `if [[ -t 1 && -t 2 ]]; then ... fi`
- **Messaging:** `_msg()` + `vecho/info/warn/success/error/die/yn/noarg`
- **Business logic:** Validation â†' operations â†' summary (bottom-up organization)
- **Argument parsing:** `while (($#)); case $1 in` with `noarg` validation
- **Progressive readonly:** Config immutable after parsing

## Core Pattern

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH

declare -i DRY_RUN=0
# ... business functions ...
main() { while (($#)); do case $1 in ...; esac; shift; done; }
main "$@"
#fin
```

## Critical Patterns

- **Dry-run:** `((DRY_RUN)) && { info '[DRY-RUN] Would...'; return 0; }`
- **Derived paths:** Update via function when PREFIX changes
- **Validation:** Check prerequisites before filesystem operations
- **Force mode:** `[[ -f "$file" ]] && ! ((FORCE)) && warn ...`

**Ref:** BCS010101
