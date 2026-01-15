## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after `shopt`, before any other code.**

### Rationale
- `realpath` provides canonical paths, fails early if script missing
- SCRIPT_DIR enables reliable companion file/library loading
- Readonly prevents accidental modification breaking resource loading

### Pattern
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

### Variables
| Variable | Derivation | Purpose |
|----------|------------|---------|
| VERSION | Manual | Semantic version (Major.Minor.Patch) |
| SCRIPT_PATH | `realpath -- "$0"` | Absolute canonical path |
| SCRIPT_DIR | `${SCRIPT_PATH%/*}` | Script directory for resources |
| SCRIPT_NAME | `${SCRIPT_PATH##*/}` | Basename for logs/errors |

### Anti-patterns
- `SCRIPT_PATH="$0"` â†' Use `realpath -- "$0"` (resolves symlinks/relative)
- `SCRIPT_DIR=$(dirname "$0")` â†' Use `${SCRIPT_PATH%/*}` (faster, no subprocess)
- `SCRIPT_DIR=$PWD` â†' Wrong! PWD is CWD, not script location
- `readonly VAR=$(cmd)` â†' Use `declare -r` (readonly can't assign from expansion)

### Edge Cases
- **Root dir**: `${SCRIPT_PATH%/*}` yields empty; add `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`
- **Sourced**: Use `${BASH_SOURCE[0]}` instead of `$0`

**Ref:** BCS0103
