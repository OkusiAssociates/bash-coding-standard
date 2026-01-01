## Script Metadata

**Every script must declare standard metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) immediately after `shopt` settings. Declare them as readonly using `declare -r`.**

**Rationale:**
- `realpath` provides canonical absolute paths and fails early if script doesn't exist
- VERSION enables versioning for deployment, debugging, and `--version` output
- SCRIPT_DIR enables reliable loading of companion files and resources
- SCRIPT_NAME provides consistent identification in logs and error messages
- Making metadata readonly prevents accidental modification

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
```

**Metadata variables:**

| Variable | Purpose | Derivation |
|----------|---------|------------|
| VERSION | Semantic version (Major.Minor.Patch) | Manual assignment |
| SCRIPT_PATH | Absolute canonical path to script | `realpath -- "$0"` |
| SCRIPT_DIR | Directory containing script | `${SCRIPT_PATH%/*}` |
| SCRIPT_NAME | Base filename only | `${SCRIPT_PATH##*/}` |

**Using metadata for resource location:**

```bash
# Load libraries relative to script location
source "$SCRIPT_DIR"/lib/logging.sh

# Load configuration
declare -- config_file="$SCRIPT_DIR"/../etc/app.conf
[[ -f "$config_file" ]] && source "$config_file" ||:

# Access data files
declare -- data_dir="$SCRIPT_DIR"/../share/data
[[ -d "$data_dir" ]] || die 2 "Data directory not found ${data_dir@Q}"

# Use metadata in logging
info "Starting $SCRIPT_NAME $VERSION"
```

**Why realpath over readlink:**
- Simpler syntax (no -e/-n flags needed)
- Loadable builtin available for maximum performance
- POSIX compliant (readlink is GNU-specific)
- Fails if file doesn't exist (catches errors early)

```bash
# ✓ Correct - use realpath
SCRIPT_PATH=$(realpath -- "$0")

# ✗ Avoid - readlink requires -en flags
SCRIPT_PATH=$(readlink -en -- "$0")
```

**About SC2155:** We disable SC2155 for SCRIPT_PATH because realpath failure should cause immediate script termination anyway. The concise pattern with documented disable is preferred.

**Edge cases:**

```bash
# Script in root directory (SCRIPT_DIR becomes empty)
SCRIPT_DIR=${SCRIPT_PATH%/*}
[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'
readonly -- SCRIPT_DIR

# Sourced vs executed
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
else
  SCRIPT_PATH=$(realpath -- "$0")
fi
```

**Anti-patterns:**

```bash
# ✗ Wrong - using $0 directly without realpath
SCRIPT_PATH="$0"  # Could be relative path or symlink!

# ✗ Wrong - using dirname and basename (external commands)
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

# ✓ Correct - use parameter expansion
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

# ✗ Wrong - using PWD for script directory
SCRIPT_DIR=$PWD  # This is current working directory, not script location

# ✗ Wrong - making readonly individually
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly variable!

# ✓ Correct - declare -r immediately
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}

# ✗ Wrong - using inconsistent variable names
SCRIPT_VERSION=1.0.0  # Should be VERSION
SCRIPT_DIRECTORY="$SCRIPT_DIR"  # Redundant

# ✗ Wrong - declaring metadata late in script
# ... 50 lines of code ...
VERSION=1.0.0  # Too late! Should be near top
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

main() {
  info "Starting $SCRIPT_NAME $VERSION"
  # Main logic here
}

main "$@"

#fin
```

**Key principle:** Metadata provides the foundation for reliable script operation. Declaring it consistently at the top enables predictable behavior regardless of how the script is invoked or where it's located.
