## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt`, using `declare -r` for immutability.**

**Rationale:** Reliable path resolution via `realpath`; consistent resource location; prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:** VERSION (semver) â†' SCRIPT_PATH (`realpath -- "$0"`) â†' SCRIPT_DIR (`${SCRIPT_PATH%/*}`) â†' SCRIPT_NAME (`${SCRIPT_PATH##*/}`)

**Anti-patterns:**
- `SCRIPT_PATH="$0"` â†' use `realpath -- "$0"` (resolves symlinks/relative paths)
- `dirname`/`basename` â†' use parameter expansion (faster, no external command)
- `SCRIPT_DIR=$PWD` â†' derive from SCRIPT_PATH (PWD is current dir, not script location)

**Edge cases:** Root directory (`SCRIPT_DIR` empty) â†' handle with `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`; Sourced scripts â†' use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103
