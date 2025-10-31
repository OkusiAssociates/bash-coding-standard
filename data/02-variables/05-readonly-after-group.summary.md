## Readonly After Group

**Declare variables with values first, then make them readonly together in a single statement. This prevents assignment errors, groups related constants visually, and makes immutability explicit.**

**Rationale:**
- Cannot assign to already-readonly variables
- Related constants visually grouped as logical unit
- Single readonly statement makes intent obvious
- Easy to maintain, separates initialization from protection

**Three-Step Progressive Readonly (runtime configuration/arguments):**

```bash
# Step 1 - Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX='/usr/local'

# Step 2 - Parse and modify in main()
main() {
  while (($#)); do case $1 in
    -v) VERBOSE=1 ;;
    --prefix) noarg "$@"; shift; PREFIX="$1" ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  ((VERBOSE)) && info "Using prefix: $PREFIX"
}
```

Variables must be mutable during parsing; making readonly too early prevents modification. Lock values after parsing completes.

**Script Metadata Exception:**

As of BCS v1.0.1, script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) prefers `declare -r` for immediate readonly declaration. Readonly-after-group remains valid but `declare -r` is recommended (see BCS0103). All other groups (colors, paths, config) use readonly-after-group.

```bash
# Metadata - uses declare -r (see BCS0103)
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Colors - readonly-after-group
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' NC=''
fi
readonly -- RED GREEN YELLOW NC
```

**Standard Groups:**

```bash
# Group 1: Script metadata (exception - uses declare -r)
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Group 2: Colors (conditional)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  RED='' GREEN='' CYAN='' NC=''
fi
readonly -- RED GREEN CYAN NC

# Group 3: Path constants
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/myapp"
readonly -- PREFIX BIN_DIR SHARE_DIR

# Group 4: Configuration defaults
DEFAULT_TIMEOUT=30
DEFAULT_RETRIES=3
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES
```

**Complete Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script Metadata
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Colors
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' NC=$'\033[0m'
else
  RED='' GREEN='' NC=''
fi
readonly -- RED GREEN NC

# Paths
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR

# Configuration
DEFAULT_TIMEOUT=30
readonly -- DEFAULT_TIMEOUT

# Mutable globals
declare -i VERBOSE=0 DRY_RUN=0
declare -- LOG_FILE=''

main() {
  # Parse arguments...
  [[ -n "$LOG_FILE" ]] && readonly -- LOG_FILE
  info "Starting $SCRIPT_NAME $VERSION"
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
#   Valid but not preferred for metadata (use declare -r instead)
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH

#  Preferred for metadata
declare -r VERSION='1.0.0'

#  Wrong - readonly before all values set
PREFIX='/usr/local'
readonly -- PREFIX  # Premature!
BIN_DIR="$PREFIX/bin"  # BIN_DIR not readonly

#  Correct - all values first, then readonly
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR

#  Wrong - missing -- separator
readonly PREFIX  # Risky if name starts with -

#  Correct - always use --
readonly -- PREFIX

#  Wrong - unrelated variables grouped
CONFIG_FILE='config.conf'
VERBOSE=1
readonly -- CONFIG_FILE VERBOSE  # Not logical group

#  Correct - group related variables
CONFIG_FILE='config.conf'
LOG_FILE='app.log'
readonly -- CONFIG_FILE LOG_FILE

#  Wrong - readonly inside conditional
if [[ -f config.conf ]]; then
  CONFIG_FILE='config.conf'
  readonly -- CONFIG_FILE  # Might not execute
fi

#  Correct - initialize with default, then readonly
CONFIG_FILE="${CONFIG_FILE:-config.conf}"
readonly -- CONFIG_FILE
```

**Derived Variables:**

Initialize in dependency order:

```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share"
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Arrays:**

```bash
declare -a REQUIRED_COMMANDS=('git' 'make' 'tar')
declare -a OPTIONAL_COMMANDS=('md2ansi' 'pandoc')
readonly -a REQUIRED_COMMANDS OPTIONAL_COMMANDS
# Or: readonly -- REQUIRED_COMMANDS OPTIONAL_COMMANDS
```

**Delayed Readonly (after argument parsing):**

```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- CONFIG_FILE='' LOG_FILE=''

main() {
  while (($#)); do case $1 in
    -v) VERBOSE=1 ;;
    -c) noarg "$@"; shift; CONFIG_FILE="$1" ;;
  esac; shift; done

  # Make readonly after parsing
  readonly -- VERBOSE DRY_RUN
  [[ -n "$CONFIG_FILE" ]] && readonly -- CONFIG_FILE
  [[ -n "$LOG_FILE" ]] && readonly -- LOG_FILE
}
```

**Testing Readonly Status:**

```bash
readonly -p | grep -q "VERSION" && echo "VERSION is readonly"
readonly -p  # List all readonly variables
VERSION='2.0.0'  # Fails: bash: VERSION: readonly variable
```

**When NOT to Use Readonly:**

```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Only make readonly when value is final
config_file=''
# ...assignment logic...
[[ -n "$config_file" ]] && readonly -- config_file
```

**Summary:**
- Initialize first, readonly second
- Group related variables together
- Always use `--` separator
- Make readonly as soon as values are final
- Delayed readonly for arguments (after parsing)
- Makes immutability explicit and prevents accidental modification
