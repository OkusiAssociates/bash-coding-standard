## Readonly After Group

**When declaring multiple readonly variables, always declare them first with their values, then make them all readonly in a single statement. This pattern improves readability, prevents assignment errors, and makes the immutability contract explicit and visible.**

**Rationale:**

- **Prevents Assignment Errors**: Cannot assign value to an already-readonly variable (Can use #shellcheck disable for simple assignments)
- **Visual Grouping**: Related constants are visually grouped together as a logical unit
- **Clear Intent**: Single readonly statement makes immutability contract obvious
- **Maintainability**: Easy to add/remove variables from the readonly group
- **Readability**: Separates initialization phase (values) from protection phase (readonly)
- **Error Detection**: If any variable hasn't been initialized before readonly, script fails explicitly

**Three-Step Progressive Readonly Workflow:**

This is the standard pattern for variables that can only be finalized after argument parsing or runtime configuration:

**Step 1 - Declare with defaults:**
```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX=${PREFIX:-/usr/local}
```

**Step 2 - Parse and modify in main():**
```bash
main() {
  while (($#)); do case $1 in
    -v)       VERBOSE+=1 ;;
    -n)       DRY_RUN=1 ;;
    --output) noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    --prefix) noarg "$@"; shift; PREFIX=$1 ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing complete
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  # Now safe to use - all readonly
  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Rationale for three-step pattern:**
- Variables must be **mutable during parsing** (Step 2)
- Making readonly **too early** prevents modification
- Making readonly **after parsing** locks in final values (Step 3)
- Prevents accidental modification throughout rest of script

**Exception - Script Metadata:**

**Note:** As of BCS v1.0.1, the **preferred pattern** for script metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) is `declare -r` for immediate readonly declaration. While readonly-after-group remains valid for metadata, `declare -r` is now recommended (see BCS0103). All other variable groups (colors, paths, configuration) continue to use the readonly-after-group pattern described below.

The important principle is that script metadata variables must be readonly. The specific mechanism (readonly-after-group vs declare -r) is less critical than ensuring immutability is achieved.

**Standard pattern (for non-metadata variables):**

```bash
# Script metadata (exception - uses declare -r, see BCS0103)
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Why readonly-after-group pattern works:**

```bash
# For non-metadata variable groups (paths, colors, config):

# Phase 1: Initialize all variables
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
LIB_DIR="$PREFIX"/lib

# Phase 2: Protect entire group
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR

# Now all four variables are immutable
```

**What groups belong together:**

**1. Script metadata group (exception - uses declare -r, see BCS0103):**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**2. Color definitions group:**
```bash
# Terminal colors (conditional)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi
```

**3. Path constants group:**
```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
declare -- LIB_DIR="$PREFIX"/lib/myapp
declare -- ETC_DIR="$PREFIX"/etc/myapp
: ...
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR
```

**4. Configuration defaults group:**
```bash
declare -i DEFAULT_TIMEOUT=30
declare -i DEFAULT_RETRIES=3
declare -- DEFAULT_LOG_LEVEL=info
declare -i DEFAULT_PORT=8080
: ...
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES DEFAULT_LOG_LEVEL DEFAULT_PORT
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# ============================================================================
# Script Metadata (Group 1 - exception: uses declare -r, see BCS0103)
# ============================================================================

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# ============================================================================
# Color Definitions (Group 2)
# ============================================================================

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

# ============================================================================
# Installation Paths (Group 3)
# ============================================================================

declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/"$SCRIPT_NAME"
readonly -- PREFIX BIN_DIR SHARE_DIR

# ============================================================================
# Configuration (Group 4)
# ============================================================================

declare -i DEFAULT_TIMEOUT=30
declare -i DEFAULT_RETRIES=3
declare -i MAX_FILE_SIZE=104857600  # 100MB
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES MAX_FILE_SIZE

# ============================================================================
# Mutable Global Variables
# ============================================================================

declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i ERROR_COUNT=0

# These will be made readonly after argument parsing
declare -- LOG_FILE=''
declare -- CONFIG_FILE=''

# Main logic
main() {
  # Parse arguments...
  # After parsing, make parsed values readonly
  [[ -z "$LOG_FILE" ]] || readonly -- LOG_FILE
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE

  info "Starting $SCRIPT_NAME $VERSION"
}

main "$@"

#fin
```

**Anti-patterns to avoid:**

```bash
# For script metadata (see BCS0103):
# ▲ Valid but not preferred - readonly-after-group for metadata
VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ Preferred - declare -r for script metadata (BCS0103)
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Note: Both patterns above are valid. The declare -r pattern is preferred
# as of BCS v1.0.1 for its conciseness and immediate immutability.

# For non-metadata variable groups:
# ✗ Wrong - making readonly before all values are set
PREFIX=/usr/local
readonly -- PREFIX  # Premature!
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share

# If BIN_DIR assignment fails, PREFIX is readonly but
# SHARE_DIR is not, creating inconsistent protection

# ✓ Correct - all values set, then all readonly
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
: ...
readonly -- PREFIX BIN_DIR SHARE_DIR

# ✗ Wrong - forgetting -- separator
readonly PREFIX BIN_DIR  # Risky if variable name starts with -

# ✓ Correct - always use -- separator
readonly -- PREFIX BIN_DIR

# ✗ Wrong - mixing related and unrelated variables
CONFIG_FILE=config.conf
VERBOSE=1
PREFIX=/usr/local
readonly -- CONFIG_FILE VERBOSE PREFIX
# These don't form a logical group!

# ✓ Correct - group logically related variables
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR

CONFIG_FILE=config.conf
LOG_FILE=app.log
readonly -- CONFIG_FILE LOG_FILE

# ✗ Wrong - readonly inside conditional (hard to verify)
if [[ -f config.conf ]]; then
  CONFIG_FILE=config.conf
  readonly -- CONFIG_FILE
fi
# CONFIG_FILE might not be readonly if condition is false!

# ✓ Correct - initialize with default, then readonly
CONFIG_FILE=${CONFIG_FILE:-config.conf}
readonly -- CONFIG_FILE
# Always readonly, value might vary
```

**Edge case: Derived variables:**

When variables depend on each other, initialize in dependency order:

```bash
# Base configuration
PREFIX=${PREFIX:-/usr/local}

# Derived paths (depend on PREFIX)
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
LIB_DIR="$PREFIX"/lib

# Make all readonly together
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR

# If you need to recalculate derived values:
# Don't make them readonly until after all calculations
```

**Edge case: Conditional initialization:**

```bash
# Color constants depend on terminal detection
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  NC=$'\033[0m'
else
  RED=''
  GREEN=''
  NC=''
fi

# Either way, same variables are defined
# Safe to make readonly after conditional
readonly -- RED GREEN NC
```

**Edge case: Arrays in readonly groups:**

```bash
# Can make arrays readonly too
declare -a REQUIRED_COMMANDS=(git make tar)
declare -a OPTIONAL_COMMANDS=(md2ansi pandoc)

: ...

# Make both arrays readonly
readonly -a REQUIRED_COMMANDS OPTIONAL_COMMANDS

# Or use -- if not specifying type
readonly -- REQUIRED_COMMANDS OPTIONAL_COMMANDS
```

**Edge case: Delayed readonly (after argument parsing):**

Some variables can only be made readonly after argument parsing:

```bash
#!/bin/bash
set -euo pipefail

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Mutable flags (will be readonly after parsing)
declare -i VERBOSE=0
declare -i DRY_RUN=0

# Mutable configuration (will be readonly after parsing)
declare -- CONFIG_FILE=''
declare -- LOG_FILE=''

main() {
  # Parse arguments (modifies VERBOSE, DRY_RUN, etc.)
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -c|--config)  noarg "$@"; shift; CONFIG_FILE=$1 ;;
    -l|--log)     noarg "$@"; shift; LOG_FILE=$1 ;;
    *)            die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  # Now make parsed values readonly
  readonly -- VERBOSE DRY_RUN

  # Optional values: only readonly if set
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
  [[ -z "$LOG_FILE" ]] || readonly -- LOG_FILE

  # Rest of script with readonly variables
  ((VERBOSE)) && info 'Verbose mode enabled' ||:
  ((DRY_RUN)) && info 'Dry-run mode enabled' ||:
}

main "$@"
#fin
```

**Testing readonly status:**

```bash
# Check if variable is readonly
if readonly -p 2>/dev/null | grep -q "VERSION"; then
  echo 'VERSION is readonly'
else
  echo 'VERSION is not readonly'
fi

# List all readonly variables
readonly -p

# Attempt to modify readonly variable (for testing)
VERSION=2.0.0  # Will fail: bash: VERSION: readonly variable
```

**When NOT to use readonly:**

```bash
# Don't make readonly if value will change during script execution
declare -i count=0
# count is modified in loops - don't make readonly

# Don't make readonly if conditional assignment
config_file=''
if [[ -f custom.conf ]]; then
  config_file=custom.conf
elif [[ -f default.conf ]]; then
  config_file=default.conf
fi
# config_file might be modified - don't make readonly yet

# Only make readonly when value is final
[[ -z "$config_file" ]] || readonly -- config_file
```

**Summary:**

- **Initialize first, readonly second**: Separate value assignment from protection
- **Group related variables**: Make logically related variables readonly together
- **Use visual separation**: Add blank lines or comments between variable groups
- **Always use `--`**: Prevents option injection bugs
- **Make readonly early**: As soon as values are final and won't change
- **Delayed readonly for args**: Make readonly after argument parsing for flags/options
- **Test readonly status**: Use `readonly -p` to verify

**Key principle:** The "readonly after group" pattern makes immutability contracts explicit and visible. By clearly separating initialization from protection, readers immediately understand which variables are constants and which are mutable.
