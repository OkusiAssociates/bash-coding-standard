## Script Metadata

**Every script must declare standard metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) immediately after `shopt` settings. Declare as readonly using `declare -r`.**

**Rationale:**

- **Reliable Path Resolution**: `realpath` provides canonical absolute paths and fails early if script doesn't exist
- **Self-Documentation**: VERSION provides clear versioning for deployment and debugging
- **Resource Location**: SCRIPT_DIR enables reliable loading of companion files and configuration
- **Logging**: SCRIPT_NAME provides consistent script identification in logs/errors
- **Defensive Programming**: Readonly metadata prevents accidental modification
- **Consistency**: Standard variables work identically across all scripts

**Standard metadata pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata - immediately after shopt
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Metadata variables:**

**1. VERSION**
- Semantic version (Major.Minor.Patch: '1.0.0', '2.3.1')
- Used for `--version` output, logging, deployment tracking

```bash
VERSION='1.0.0'
show_version() { echo "$SCRIPT_NAME $VERSION"; }
```

**2. SCRIPT_PATH**
- Absolute canonical path to script file
- Command: `realpath -- "$0"`
  - `--`: Prevents option injection if filename starts with `-`
  - Resolves symlinks, relative paths, `.` and `..` components
  - Fails if file doesn't exist (intentional - catches errors early)
  - Loadable builtin available for maximum performance

```bash
SCRIPT_PATH=$(realpath -- "$0")
# Examples: /usr/local/bin/myapp, /home/user/projects/app/deploy.sh
```

**3. SCRIPT_DIR**
- Directory containing the script
- Derivation: `${SCRIPT_PATH%/*}` (removes last `/` and everything after)

```bash
SCRIPT_DIR=${SCRIPT_PATH%/*}
# Load library from same directory
source "$SCRIPT_DIR/lib/common.sh"
# Read config from relative path
config_file="$SCRIPT_DIR/../conf/app.conf"
```

**4. SCRIPT_NAME**
- Base name of script (filename only, no path)
- Derivation: `${SCRIPT_PATH##*/}` (removes everything up to last `/`)

```bash
SCRIPT_NAME=${SCRIPT_PATH##*/}
# Use in error messages and help text
die() {
  local -i exit_code=$1
  shift
  >&2 echo "$SCRIPT_NAME: error: $*"
  exit "$exit_code"
}
```

**Why declare -r for metadata:**

```bash
# ✓ Correct - declare as readonly immediately
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Benefits:
# 1. Makes each variable immediately immutable at declaration
# 2. Concise single-line declarations
# 3. SCRIPT_DIR and SCRIPT_NAME combined (both derived from SCRIPT_PATH)
# 4. SC2155 disable documents intentional command substitution in declare -r
```

**Resource location pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Load libraries relative to script location
source "$SCRIPT_DIR/lib/logging.sh"

# Load configuration
declare -- config_file="$SCRIPT_DIR/../etc/app.conf"
[[ -f "$config_file" ]] && source "$config_file"

# Access data files
declare -- data_dir="$SCRIPT_DIR/../share/data"
[[ -d "$data_dir" ]] || die 2 "Data directory not found: $data_dir"

# Use metadata in logging
info "Starting $SCRIPT_NAME $VERSION"
```

**Why realpath over readlink:**

```bash
# realpath is canonical BCS approach because:
# 1. Simpler syntax - no flags needed (default behavior is correct)
# 2. Builtin available - loadable builtin provides maximum performance
# 3. Widely available - standard on modern Linux systems
# 4. POSIX compliant - realpath is POSIX, readlink is GNU-specific
# 5. Consistent behavior - fails if file doesn't exist (catches errors early)

# ✓ Correct
SCRIPT_PATH=$(realpath -- "$0")

# ✗ Avoid - requires -en flags, GNU-specific
SCRIPT_PATH=$(readlink -en -- "$0")
```

**About shellcheck SC2155:**

```bash
# SC2155 warns about command substitution in declare -r
# It masks the return value of the command

declare -r SCRIPT_PATH=$(realpath -- "$0")
#shellcheck disable=SC2155

# Why we disable SC2155 for SCRIPT_PATH:
# 1. realpath failure is acceptable - we WANT script to fail early if file missing
# 2. Metadata variables set exactly once at script startup
# 3. Command substitution is simple and well-understood
# 4. Pattern is concise and immediately makes variable readonly

# Alternative (avoiding SC2155) is more verbose:
SCRIPT_PATH=$(realpath -- "$0") || die 1 "Failed to resolve script path"
declare -r SCRIPT_PATH
```

**Anti-patterns:**

```bash
# ✗ Wrong - using $0 directly without realpath
SCRIPT_PATH="$0"  # Could be relative path or symlink

# ✓ Correct
SCRIPT_PATH=$(realpath -- "$0")

# ✗ Wrong - using dirname/basename (requires external commands)
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

# ✓ Correct - parameter expansion (faster, more reliable)
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

# ✗ Wrong - using PWD for script directory
SCRIPT_DIR="$PWD"  # Wrong! This is current working directory

# ✓ Correct
SCRIPT_DIR=${SCRIPT_PATH%/*}

# ✗ Wrong - making readonly individually
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly variable!

# ✓ Correct - declare as readonly immediately
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}

# ✗ Wrong - inconsistent variable names
SCRIPT_VERSION='1.0.0'  # Should be VERSION
SCRIPT_DIRECTORY="$SCRIPT_DIR"  # Redundant
MY_SCRIPT_PATH="$SCRIPT_PATH"  # Non-standard

# ✓ Correct - standard names
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Edge cases:**

```bash
# Script in root directory
# If script is /myscript
SCRIPT_DIR=${SCRIPT_PATH%/*}  # Results in empty string!

# Solution:
SCRIPT_DIR=${SCRIPT_PATH%/*}
[[ -z "$SCRIPT_DIR" ]] && SCRIPT_DIR='/'
readonly -- SCRIPT_DIR

# Sourced vs executed
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  # Script is being sourced
  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
else
  # Script is being executed
  SCRIPT_PATH=$(realpath -- "$0")
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- LOG_FILE="$SCRIPT_DIR/../logs/$SCRIPT_NAME.log"
declare -- CONFIG_FILE="$SCRIPT_DIR/../etc/$SCRIPT_NAME.conf"

info() { echo "[$SCRIPT_NAME] $*" | tee -a "$LOG_FILE"; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*" | tee -a "$LOG_FILE"; }
die() {
  local -i exit_code=$1
  shift
  error "$*"
  exit "$exit_code"
}

show_version() { echo "$SCRIPT_NAME $VERSION"; }

show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help     Show this help
  -V, --version  Show version

Version: $VERSION
Location: $SCRIPT_PATH
EOF
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    info "Loading config from $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    die 2 "Config not found: $CONFIG_FILE"
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

- Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt`
- Use `realpath` to resolve SCRIPT_PATH (canonical BCS approach)
- Derive SCRIPT_DIR and SCRIPT_NAME from SCRIPT_PATH using parameter expansion
- Declare as readonly with `declare -r` immediately
- Use for resource location, logging, error messages, version display
- Handle edge cases: root directory, sourced scripts
