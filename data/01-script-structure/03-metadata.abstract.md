## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt` using `declare -r` for immutability.**

**Rationale:** Reliable path resolution (realpath resolves symlinks/fails early), VERSION for tracking, SCRIPT_DIR for resource location, SCRIPT_NAME for logging, readonly prevents modification.

**Pattern:**

```bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:**
- **VERSION**: Semantic version (Major.Minor.Patch)
- **SCRIPT_PATH**: Absolute path via `realpath -- "$0"` (fails if missing)
- **SCRIPT_DIR**: Directory via `${SCRIPT_PATH%/*}` (parameter expansion)
- **SCRIPT_NAME**: Filename via `${SCRIPT_PATH##*/}`

**Use realpath not readlink:** Simpler, builtin available, POSIX-compliant, fails early.

**SC2155 acceptable:** realpath failure should terminate; concise pattern preferred.

**Anti-patterns:**
- `$0` directly without realpath → relative/symlink issues
- `dirname`/`basename` → slower external commands
- `$PWD` for SCRIPT_DIR → wrong (current directory not script location)
- `readonly` individually → `readonly SCRIPT_DIR=${SCRIPT_PATH%/*}` fails
- Late declaration → must follow shopt immediately

**Ref:** BCS0103
