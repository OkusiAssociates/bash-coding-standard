## BCS0101: Script Layout

**13-step bottom-up structure: infrastructure â†' utilities â†' logic â†' orchestration.**

### Rationale
1. **Safe init** - `set -euo pipefail` before commands; dependencies before use
2. **Predictability** - Metadataâ†'utilitiesâ†'logicâ†'main() in fixed order
3. **Bottom-up** - Functions call only previously defined functions

### 13 Steps

| # | Element |
|---|---------|
| 1 | `#!/bin/bash` |
| 2 | ShellCheck directives (opt) |
| 3 | Brief description |
| 4 | `set -euo pipefail` **MANDATORY** |
| 5 | `shopt -s inherit_errexit shift_verbose extglob nullglob` |
| 6 | Metadata: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` |
| 7 | Globals with types (`declare -i/-a/-A/--`) |
| 8 | Colors (terminal-conditional) |
| 9 | Utilities (`info`, `warn`, `error`, `die`) |
| 10 | Business logic |
| 11 | `main()` with arg parsing |
| 12 | `main "$@"` |
| 13 | `#fin` **MANDATORY** |

### Example
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
declare -r VERSION=1.0.0 SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
main() { echo "$SCRIPT_NAME $VERSION"; }
main "$@"
#fin
```

### Anti-Patterns
- Missing `set -euo pipefail` â†' undefined error behavior
- Business logic before utilities â†' undefined function calls

**Ref:** BCS0101
