## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt`, using `declare -r` for immutability.**

**Rationale:** Enables reliable resource loading from any invocation directory; `realpath` fails early if script missing; readonly prevents accidental modification.

**Pattern:**

```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Load resources relative to script
source "$SCRIPT_DIR"/lib/common.sh
```

**Variables:** VERSION (semver) â†' SCRIPT_PATH (`realpath -- "$0"`) â†' SCRIPT_DIR (`${SCRIPT_PATH%/*}`) â†' SCRIPT_NAME (`${SCRIPT_PATH##*/}`)

**Anti-patterns:**

- `SCRIPT_PATH="$0"` â†' use `realpath -- "$0"` (resolves symlinks/relative paths)
- `SCRIPT_DIR=$(dirname "$0")` â†' use `${SCRIPT_PATH%/*}` (faster, no external command)
- `SCRIPT_DIR=$PWD` â†' wrong! PWD is current directory, not script location

**Edge cases:** Root directory (`SCRIPT_DIR` empty) â†' add `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`; Sourced scripts â†' use `${BASH_SOURCE[0]}` instead of `$0`

**Ref:** BCS0103
