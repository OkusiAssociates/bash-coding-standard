## Script Metadata

**Every script must declare standard metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) immediately after `shopt` settings and before any other code. Declare them as readonly using `declare -r`.**

**Rationale:**
- `realpath` provides canonical absolute paths and fails early if script doesn't exist
- VERSION enables deployment tracking and `--version` output
- SCRIPT_DIR enables reliable loading of companion files and resources
- SCRIPT_NAME provides consistent identification in logs and errors
- Readonly prevents accidental modification; standard names reduce cognitive load

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
| SCRIPT_PATH | Absolute canonical path | `realpath -- "$0"` |
| SCRIPT_DIR | Directory containing script | `${SCRIPT_PATH%/*}` |
| SCRIPT_NAME | Filename only, no path | `${SCRIPT_PATH##*/}` |

**Using metadata for resource location:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Load libraries relative to script location
source "$SCRIPT_DIR"/lib/logging.sh

# Load configuration
declare -- config_file="$SCRIPT_DIR"/../etc/app.conf
[[ ! -f "$config_file" ]] || source "$config_file"

# Use metadata in logging
info "Starting $SCRIPT_NAME $VERSION"
debug "Script location: ${SCRIPT_PATH@Q}"
```

**Why realpath over readlink:**
- Simpler syntax: No `-e` and `-n` flags needed (defaults are correct)
- Loadable builtin available for maximum performance
- POSIX compliant (readlink is GNU-specific)
- Fails if file doesn't exist (catches errors early - intentional)

```bash
# ✓ Correct - use realpath
SCRIPT_PATH=$(realpath -- "$0")

# ✓ Acceptable - readlink requires -en flags (more complex, GNU-specific)
SCRIPT_PATH=$(readlink -en -- "$0")

# For maximum performance, load realpath as builtin:
# enable -f /usr/local/lib/bash-builtins/realpath.so realpath
```

**About shellcheck SC2155:**

SC2155 warns about command substitution in `declare -r` masking return values. We disable it because:
1. realpath failure is acceptable - script should fail early if file doesn't exist
2. Metadata is set exactly once at startup
3. Concise pattern immediately makes variable readonly

**Anti-patterns:**

```bash
# ✗ Wrong - using $0 directly without realpath
SCRIPT_PATH="$0"  # Could be relative path or symlink!

# ✗ Wrong - using dirname/basename (external commands)
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

# ✓ Correct - parameter expansion (faster, more reliable)
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

# ✗ Wrong - using PWD for script directory
SCRIPT_DIR=$PWD  # This is current working directory, not script location!

# ✗ Wrong - making readonly individually causes assignment errors
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly variable!

# ✓ Correct - declare as readonly immediately
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}

# ✗ Wrong - inconsistent variable names
SCRIPT_VERSION=1.0.0  # Should be VERSION
SCRIPT_DIRECTORY=$SCRIPT_DIR  # Redundant

# ✗ Wrong - declaring metadata late in script
# ... 50 lines of code ...
VERSION=1.0.0  # Too late! Should be near top
```

**Edge case: Script in root directory**

```bash
# If script is /myscript (in root directory)
SCRIPT_PATH=/myscript
SCRIPT_DIR=${SCRIPT_PATH%/*}  # Results in empty string!

# Solution: Handle this edge case if script might be in /
SCRIPT_DIR=${SCRIPT_PATH%/*}
[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'
readonly -- SCRIPT_DIR
```

**Edge case: Sourced vs executed**

```bash
# When script is sourced, $0 is the calling shell, not the script
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  # Script is being sourced
  declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
else
  # Script is being executed
  declare -r SCRIPT_PATH=$(realpath -- "$0")
fi

declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
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
  cat <<HELP
$SCRIPT_NAME $VERSION - Process data

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help     Show this help message
  -V, --version  Show version information
HELP
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

**Key principles:**
- Declare metadata immediately after `shopt` settings
- Use standard names: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- Use `realpath` for canonical path resolution
- Derive SCRIPT_DIR/SCRIPT_NAME via parameter expansion
- Make readonly with `declare -r` at declaration time
- Handle edge cases: root directory, sourced scripts
