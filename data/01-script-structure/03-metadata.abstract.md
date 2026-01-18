## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after shopt, before any other code.**

**Rationale:** Reliable path resolution via `realpath` fails early if script missing; SCRIPT_DIR enables resource loading; readonly prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

source "$SCRIPT_DIR"/lib/common.sh
```

**Anti-patterns:**
- `SCRIPT_PATH="$0"` → use `realpath -- "$0"` (resolves symlinks/relative paths)
- `SCRIPT_DIR=$(dirname "$0")` → use `${SCRIPT_PATH%/*}` (parameter expansion faster)
- `SCRIPT_DIR=$PWD` → PWD is working dir, not script location

**Edge cases:** Root dir (`SCRIPT_DIR` empty) → add `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`; Sourced scripts → use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103
