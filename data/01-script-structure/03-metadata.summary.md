## Script Metadata

**Every script must declare standard metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) immediately after `shopt` settings and before any other code. Declare them as readonly using `declare -r`.**

**Rationale:**
- **Reliable Path Resolution**: `realpath` provides canonical absolute paths and fails early if script doesn't exist
- **Self-Documentation**: VERSION provides versioning for deployment and debugging
- **Resource Location**: SCRIPT_DIR enables reliable loading of companion files and configuration
- **Logging**: SCRIPT_NAME provides consistent script identification in logs and errors
- **Defensive Programming**: Readonly prevents accidental modification that could break resource loading

**Standard metadata pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata - immediately after shopt
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Rest of script follows
```

**Metadata variables:**

| Variable | Purpose | Derivation |
|----------|---------|------------|
| VERSION | Semantic version (Major.Minor.Patch) | Manual assignment |
| SCRIPT_PATH | Absolute canonical path | `$(realpath -- "$0")` |
| SCRIPT_DIR | Directory containing script | `${SCRIPT_PATH%/*}` |
| SCRIPT_NAME | Base filename only | `${SCRIPT_PATH##*/}` |

**Usage examples:**

```bash
# Version display
show_version() { echo "$SCRIPT_NAME $VERSION"; }

# Load libraries relative to script
source "$SCRIPT_DIR"/lib/common.sh

# Error messages
die() { (($# < 2)) || >&2 echo "$SCRIPT_NAME: error: ${*:2}"; exit "${1:-0}"; }

# Help text
show_help() { cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE
EOF
}
```

**Why realpath over readlink:**
- Simpler syntax: No `-e` and `-n` flags needed
- Loadable builtin available for maximum performance
- POSIX compliant (readlink is GNU-specific)
- Fails if file doesn't exist (catches errors early)

```bash
# ✓ Correct - use realpath
SCRIPT_PATH=$(realpath -- "$0")

# ✗ Avoid - readlink requires -en flags
SCRIPT_PATH=$(readlink -en -- "$0")
```

**About SC2155:**

```bash
# shellcheck SC2155 warns about command substitution in declare -r masking return value
# We disable it because:
# 1. realpath failure is acceptable - we WANT early failure if script doesn't exist
# 2. Pattern is concise and immediately makes variable readonly
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

**Anti-patterns:**

```bash
# ✗ Wrong - using $0 directly without realpath
SCRIPT_PATH="$0"  # Could be relative path or symlink!

# ✓ Correct
SCRIPT_PATH=$(realpath -- "$0")

# ✗ Wrong - using dirname/basename (external commands)
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

# ✓ Correct - parameter expansion (faster)
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

# ✗ Wrong - using PWD for script directory
SCRIPT_DIR=$PWD  # This is CWD, not script location!

# ✗ Wrong - readonly assignment fails
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly!

# ✓ Correct - declare -r
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
```

**Edge case: Script in root directory:**

```bash
# If script is /myscript, SCRIPT_DIR becomes empty string
SCRIPT_DIR=${SCRIPT_PATH%/*}
[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'
readonly -- SCRIPT_DIR
```

**Edge case: Sourced vs executed:**

```bash
# When sourced, $0 is the calling shell
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
else
  SCRIPT_PATH=$(realpath -- "$0")
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- LOG_FILE="$SCRIPT_DIR"/../logs/"$SCRIPT_NAME".log
declare -- CONFIG_FILE="$SCRIPT_DIR"/../etc/"$SCRIPT_NAME".conf

info() { echo "[$SCRIPT_NAME] $*" | tee -a "$LOG_FILE"; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*" | tee -a "$LOG_FILE"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

show_version() { echo "$SCRIPT_NAME $VERSION"; }

show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help     Show this help message
  -V, --version  Show version information

Version: $VERSION
Location: $SCRIPT_PATH
EOF
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    info "Loading configuration from ${CONFIG_FILE@Q}"
    source "$CONFIG_FILE"
  else
    die 2 "Configuration file not found ${CONFIG_FILE@Q}"
  fi
}

main() {
  info "Starting $SCRIPT_NAME $VERSION"
  load_config
  info 'Processing complete'
}

main "$@"

#fin
```

**Summary:**
- Declare metadata immediately after `shopt` settings
- Use standard names: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- Use `realpath` to resolve SCRIPT_PATH (canonical BCS approach)
- Derive SCRIPT_DIR/SCRIPT_NAME from SCRIPT_PATH using parameter expansion
- Use `declare -r` for immediate readonly
- Use metadata for resource location, logging, error messages, version display
