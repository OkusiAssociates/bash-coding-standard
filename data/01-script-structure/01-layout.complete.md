### Standard Script General Layout

**All Bash scripts must follow a specific 13-step structural layout that ensures consistency, maintainability, and correctness. This bottom-up organizational pattern places low-level utilities before high-level orchestration, allowing each component to safely call previously defined functions. The structure is mandatory for all scripts and ensures that error handling, metadata, dependencies, and execution flow are properly established before any business logic runs.**

---

## Rationale

**Why enforce a strict 13-step layout?**

1. **Predictability** - Developers (and AI assistants) know exactly where to find specific components in any script. Metadata is always in step 6, utilities in step 9, business logic in step 10, orchestration in step 11.

2. **Safe Initialization** - The ordering ensures that critical infrastructure is established before it's needed: error handling (`set -euo pipefail`) is configured before any commands run, metadata is available before any function executes, and global variables are declared before any code references them.

3. **Bottom-Up Dependency Resolution** - Lower-level components are defined before higher-level ones that depend on them. Messaging functions come before business logic that calls them, business logic comes before `main()` that orchestrates it. Each function can safely call any function defined above it.

4. **Testing and Maintenance** - Consistent structure makes scripts easier to test, debug, and maintain. You can source a script to test individual functions, extract utilities for reuse, or understand unfamiliar code quickly because the structure is standardized.

5. **Error Prevention** - The strict ordering prevents entire classes of errors: using undefined functions, referencing uninitialized variables, or running business logic before error handling is configured. Many subtle bugs are prevented by structure alone.

6. **Documentation Through Structure** - The layout itself documents the script's organization. The progression from infrastructure (steps 1-8) through implementation (steps 9-10) to orchestration (steps 11-12) tells the story of how the script works.

7. **Production Readiness** - The structure includes all elements needed for production scripts: version tracking, proper error handling, terminal detection for output, argument validation, and clear execution flow. Nothing is left to chance.

---

## The 13 Mandatory Steps

### Step 1: Shebang

**First line of every script - specifies the interpreter.**

```bash
#!/usr/bin/env bash
```

**Alternatives:**
```bash
#!/bin/bash
#!/usr/bin/bash
```

**Rationale for `env` approach:**
- Portable across systems where bash may be in different locations
- Respects user's PATH settings
- Standard on modern systems

### Step 2: ShellCheck Directives (if needed)

**Global directives that apply to the entire script.**

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
```

**Always include explanatory comments** for disabled checks.

Only use when necessary - don't disable checks without good reason.

### Step 3: Brief Description Comment

**One-line purpose statement immediately after shebang/directives.**

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

**Not a full header block** - just a concise description.

### Step 4: `set -euo pipefail`

**Mandatory strict error handling configuration.**

```bash
set -euo pipefail
```

**What this enables:**
- `set -e` - Exit on any command failure
- `set -u` - Exit on undefined variable reference
- `set -o pipefail` - Pipelines fail if any command fails (not just the last)

**This MUST come before any commands** (except shebang/comments/shellcheck).

### Step 5: `shopt` Settings

**Strongly recommended shell option settings.**

```bash
shopt -s inherit_errexit  # Subshells inherit set -e
shopt -s shift_verbose    # Warn on shift with no arguments
shopt -s extglob          # Enable extended pattern matching
shopt -s nullglob         # Empty globs expand to nothing (not literal string)
```

**Why these specific options:**
- `inherit_errexit` - Prevents subshells from silently continuing after errors
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Enables powerful pattern matching: `@(pattern)`, `!(pattern)`, etc.
- `nullglob` - Makes empty globs safe (critical for `for file in *.txt` patterns)

### Step 6: Script Metadata

**Standard metadata variables - make readonly together after declaration.**

```bash
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**Why these specific variables:**
- `VERSION` - For `--version` flag, logging, compatibility checks
- `SCRIPT_PATH` - Absolute canonical path to script (resolves symlinks)
- `SCRIPT_DIR` - Directory containing script (for relative file access)
- `SCRIPT_NAME` - Script basename (for messages, logging, temp files)

**Why readonly together:** More efficient than individual readonly statements, documents that these are immutable constants.

### Step 7: Global Variable Declarations

**All global variables declared up front with types.**

```bash
# Configuration variables
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''
declare -- LOG_FILE=''

# Runtime state
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i FORCE=0

# Arrays for accumulation
declare -a INPUT_FILES=()
declare -a WARNINGS=()
```

**Type declarations:**
- `declare -i` for integers (enables arithmetic context)
- `declare --` for strings (explicit string type)
- `declare -a` for indexed arrays
- `declare -A` for associative arrays

**Why up front:** Makes all globals visible in one place, prevents accidental creation of globals in functions, documents script's state.

### Step 8: Color Definitions (if terminal output)

**Terminal detection and color code definitions.**

```bash
# Detect terminal capabilities
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  readonly -- RED GREEN YELLOW BLUE BOLD RESET
else
  # Not a terminal or tput unavailable - no colors
  declare -r RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi
```

**Why conditional:** Colors only work on terminals - don't use them when output is piped or redirected.

**Skip this step** if your script doesn't use colored output.

### Step 9: Utility Functions

**Messaging and helper functions - lowest level, used by everything else.**

```bash
# Core messaging function using FUNCNAME
_msg() {
  local -r level=$1
  shift
  >&2 echo "${FUNCNAME[1]}: $level: $*"
}

# Verbose output (respects VERBOSE flag)
vecho() {
  ((VERBOSE)) && echo "$@"
}

# Success messages
success() {
  >&2 echo "${GREEN}✓ $*${RESET}"
}

# Warnings (non-fatal)
warn() {
  _msg 'WARNING' "$@"
}

# Info messages
info() {
  >&2 echo "${BLUE}ℹ $*${RESET}"
}

# Debug output (respects DEBUG flag)
debug() {
  ((DEBUG)) && _msg 'DEBUG' "$@"
}

# Error output (unconditional)
error() {
  _msg 'ERROR' "$@"
}

# Exit with error
die() {
  local -i exit_code=$1
  shift
  error "$@"
  exit "$exit_code"
}

# Yes/no prompt
yn() {
  local -- prompt=$1
  local -- response
  read -r -p "$prompt [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}

# Argument validation helper
noarg() {
  (($# < 2)) && die 22 "Option '$1' requires an argument"
}
```

**Why these come first:** Business logic needs messaging, validation, and error handling. These utilities must exist before anything calls them.

**Production optimization:** Remove unused functions after script is mature (see Section 6 of main standard).

### Step 10: Business Logic Functions

**Core functionality - the actual work of the script.**

```bash
# Check if all required commands are available
check_prerequisites() {
  local -i missing=0
  local -- cmd

  for cmd in git make gcc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found: $cmd"
      missing=1
    fi
  done

  ((missing)) && die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

# Validate configuration
validate_config() {
  [[ -z "$PREFIX" ]] && die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist: $PREFIX"

  success 'Configuration validated'
}

# Install files to target directory
install_files() {
  local -- source_dir=$1
  local -- target_dir=$2

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install files from '$source_dir' to '$target_dir'"
    return 0
  fi

  [[ -d "$source_dir" ]] || die 2 "Source directory not found: $source_dir"
  mkdir -p "$target_dir" || die 1 "Failed to create target directory: $target_dir"

  cp -r "$source_dir"/* "$target_dir"/ || die 1 'Installation failed'
  success "Installed files to '$target_dir'"
}

# Generate configuration file
generate_config() {
  local -- config_file=$1

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would generate config: $config_file"
    return 0
  fi

  cat > "$config_file" <<EOF
# Generated configuration
PREFIX=$PREFIX
VERSION=$VERSION
INSTALL_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

  success "Generated config: $config_file"
}
```

**Organize bottom-up within business logic:**
- Lower-level functions first (validation, file operations)
- Higher-level functions later (orchestration)
- Each function can call functions defined above it

### Step 11: `main()` Function

**Required for scripts over 40 lines - orchestrates everything.**

```bash
main() {
  # Parse arguments
  while (($#)); do
    case $1 in
      -v|--verbose)    VERBOSE=1 ;;
      -n|--dry-run)    DRY_RUN=1 ;;
      -f|--force)      FORCE=1 ;;

      -p|--prefix)     noarg "$@"
                       shift
                       PREFIX="$1"
                       ;;

      -h|--help)       usage
                       exit 0
                       ;;

      -V|--version)    echo "$SCRIPT_NAME $VERSION"
                       exit 0
                       ;;

      -*)              die 22 "Invalid option: $1" ;;
      *)               INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  # Make configuration readonly after parsing
  readonly -- PREFIX CONFIG_FILE LOG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  # Execute workflow
  ((DRY_RUN)) && info 'DRY-RUN mode enabled'

  check_prerequisites
  validate_config
  install_files "$SCRIPT_DIR/data" "$PREFIX/share"
  generate_config "$PREFIX/etc/myapp.conf"

  success 'Installation complete'
}
```

**Why main() is required:**
- **Testing** - Can source script and test `main()` with specific arguments
- **Organization** - Single entry point makes execution flow clear
- **Scoping** - Argument parsing can use local variables in main()
- **Debugging** - Easy to add debug hooks before/after main()

**Exception:** Scripts under 40 lines can skip `main()` and run directly.

### Step 12: Script Invocation

**Execute main with all arguments.**

```bash
main "$@"
```

**ALWAYS quote `"$@"`** to preserve argument array properly.

**For small scripts without main():** Just write business logic directly here.

### Step 13: End Marker

**Mandatory final line.**

```bash
#fin
```

**Why mandatory:**
- Visual confirmation script is complete (not truncated)
- Some editors/tools look for end-of-file marker
- Consistency across all scripts

**Alternative:** `#end` is acceptable but `#fin` is preferred.

---

## Complete Example: All 13 Steps

This example demonstrates every step of the mandatory structure in a realistic installation script:

```bash
#!/usr/bin/env bash
#shellcheck disable=SC2034  # Some variables used by sourcing scripts

# Configurable installation script with dry-run mode and validation

set -euo pipefail

shopt -s inherit_errexit shift_verbose extglob nullglob

# ============================================================================
# Step 6: Script Metadata
# ============================================================================

VERSION='2.1.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ============================================================================
# Step 7: Global Variable Declarations
# ============================================================================

# Configuration (can be modified by arguments)
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'
declare -- SYSTEM_USER='myapp'

# Derived paths (updated when PREFIX changes)
declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- SHARE_DIR="$PREFIX/share"
declare -- CONFIG_DIR="/etc/$APP_NAME"
declare -- LOG_DIR="/var/log/$APP_NAME"

# Runtime flags
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i FORCE=0
declare -i INSTALL_SYSTEMD=0

# Accumulation arrays
declare -a WARNINGS=()
declare -a INSTALLED_FILES=()

# ============================================================================
# Step 8: Color Definitions
# ============================================================================

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  readonly -- RED GREEN YELLOW BLUE BOLD RESET
else
  declare -r RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# ============================================================================
# Step 9: Utility Functions
# ============================================================================

_msg() {
  local -r level=$1
  shift
  >&2 echo "${FUNCNAME[1]}: $level: $*"
}

vecho() {
  ((VERBOSE)) && echo "$@"
}

success() {
  >&2 echo "${GREEN}✓ $*${RESET}"
}

warn() {
  _msg 'WARNING' "$@"
  WARNINGS+=("$*")
}

info() {
  >&2 echo "${BLUE}ℹ $*${RESET}"
}

error() {
  _msg 'ERROR' "$@"
}

die() {
  local -i exit_code=$1
  shift
  error "$@"
  exit "$exit_code"
}

yn() {
  local -- prompt=$1
  local -- response
  read -r -p "$prompt [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}

noarg() {
  (($# < 2)) && die 22 "Option '$1' requires an argument"
}

# ============================================================================
# Step 10: Business Logic Functions
# ============================================================================

# Update derived paths when PREFIX or APP_NAME changes
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"

  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
}

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Configurable installation script with dry-run mode.

OPTIONS:
  -p, --prefix DIR       Installation prefix (default: /usr/local)
  -u, --user USER        System user for service (default: myapp)
  -n, --dry-run          Show what would be done without doing it
  -f, --force            Overwrite existing files
  -s, --systemd          Install systemd service unit
  -v, --verbose          Enable verbose output
  -h, --help             Display this help message
  -V, --version          Display version information

EXAMPLES:
  # Dry-run installation to /opt
  $SCRIPT_NAME --prefix /opt --dry-run

  # Install with systemd service
  $SCRIPT_NAME --systemd --user webapp

  # Force reinstall to default location
  $SCRIPT_NAME --force

EOF
}

check_prerequisites() {
  local -i missing=0
  local -- cmd

  for cmd in install mkdir chmod chown; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found: $cmd"
      missing=1
    fi
  done

  if ((INSTALL_SYSTEMD)) && ! command -v systemctl >/dev/null 2>&1; then
    error 'systemd installation requested but systemctl not found'
    missing=1
  fi

  ((missing)) && die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  # Validate PREFIX
  [[ -z "$PREFIX" ]] && die 22 'PREFIX cannot be empty'
  [[ "$PREFIX" =~ [[:space:]] ]] && die 22 'PREFIX cannot contain spaces'

  # Validate APP_NAME
  [[ -z "$APP_NAME" ]] && die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || \
    die 22 "Invalid APP_NAME: must start with letter, contain only lowercase, digits, dash, underscore"

  # Validate SYSTEM_USER
  [[ -z "$SYSTEM_USER" ]] && die 22 'SYSTEM_USER cannot be empty'

  # Check write permissions
  if [[ ! -d "$PREFIX" ]]; then
    if ((FORCE)) || yn "Create PREFIX directory: $PREFIX?"; then
      vecho "Will create: $PREFIX"
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
      info "[DRY-RUN] Would create directory: $dir"
      continue
    fi

    if [[ -d "$dir" ]]; then
      vecho "Directory exists: $dir"
    else
      mkdir -p "$dir" || die 1 "Failed to create directory: $dir"
      success "Created directory: $dir"
    fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR/bin"
  local -- target="$BIN_DIR"

  [[ -d "$source" ]] || die 2 "Source directory not found: $source"

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install binaries from '$source' to '$target'"
    return 0
  fi

  local -- file
  local -i count=0

  for file in "$source"/*; do
    [[ -f "$file" ]] || continue

    local -- basename=${file##*/}
    local -- target_file="$target/$basename"

    if [[ -f "$target_file" ]] && ! ((FORCE)); then
      warn "File exists (use --force to overwrite): $target_file"
      continue
    fi

    install -m 755 "$file" "$target_file" || die 1 "Failed to install: $basename"
    INSTALLED_FILES+=("$target_file")
    count+=1
    vecho "Installed: $target_file"
  done

  success "Installed $count binaries to '$target'"
}

install_libraries() {
  local -- source="$SCRIPT_DIR/lib"
  local -- target="$LIB_DIR/$APP_NAME"

  [[ -d "$source" ]] || {
    vecho 'No libraries to install'
    return 0
  }

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install libraries from '$source' to '$target'"
    return 0
  fi

  mkdir -p "$target" || die 1 "Failed to create library directory: $target"

  cp -r "$source"/* "$target"/ || die 1 'Library installation failed'
  chmod -R a+rX "$target"

  success "Installed libraries to '$target'"
}

generate_config() {
  local -- config_file="$CONFIG_DIR/$APP_NAME.conf"

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would generate config: $config_file"
    return 0
  fi

  if [[ -f "$config_file" ]] && ! ((FORCE)); then
    warn "Config file exists (use --force to overwrite): $config_file"
    return 0
  fi

  cat > "$config_file" <<EOF
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
EOF

  chmod 644 "$config_file"
  success "Generated config: $config_file"
}

install_systemd_unit() {
  ((INSTALL_SYSTEMD)) || return 0

  local -- unit_file="/etc/systemd/system/${APP_NAME}.service"

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install systemd unit: $unit_file"
    return 0
  fi

  cat > "$unit_file" <<EOF
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
EOF

  chmod 644 "$unit_file"
  systemctl daemon-reload || warn 'Failed to reload systemd daemon'

  success "Installed systemd unit: $unit_file"
}

set_permissions() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would set directory permissions'
    return 0
  fi

  # Log directory should be writable by system user
  if id "$SYSTEM_USER" >/dev/null 2>&1; then
    chown -R "$SYSTEM_USER:$SYSTEM_USER" "$LOG_DIR" 2>/dev/null || \
      warn "Failed to set ownership on '$LOG_DIR' (may need sudo)"
  else
    warn "System user '$SYSTEM_USER' does not exist - skipping ownership changes"
  fi

  success 'Permissions configured'
}

show_summary() {
  cat <<EOF

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

EOF

  if ((${#WARNINGS[@]})); then
    echo "${YELLOW}Warnings:${RESET}"
    local -- warning
    for warning in "${WARNINGS[@]}"; do
      echo "  • $warning"
    done
    echo
  fi

  if ((DRY_RUN)); then
    echo "${BLUE}This was a DRY-RUN - no changes were made${RESET}"
  fi
}

# ============================================================================
# Step 11: main() Function
# ============================================================================

main() {
  # Parse command-line arguments
  while (($#)); do
    case $1 in
      -p|--prefix)       noarg "$@"
                         shift
                         PREFIX="$1"
                         update_derived_paths
                         ;;

      -u|--user)         noarg "$@"
                         shift
                         SYSTEM_USER="$1"
                         ;;

      -n|--dry-run)      DRY_RUN=1 ;;
      -f|--force)        FORCE=1 ;;
      -s|--systemd)      INSTALL_SYSTEMD=1 ;;
      -v|--verbose)      VERBOSE=1 ;;

      -h|--help)         usage
                         exit 0
                         ;;

      -V|--version)      echo "$SCRIPT_NAME $VERSION"
                         exit 0
                         ;;

      -*)                die 22 "Invalid option: $1 (use --help for usage)" ;;
      *)                 die 22 "Unexpected argument: $1" ;;
    esac
    shift
  done

  # Make configuration readonly after argument parsing
  readonly -- PREFIX APP_NAME SYSTEM_USER
  readonly -- BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -i VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD

  # Show mode information
  ((DRY_RUN)) && info 'DRY-RUN mode enabled - no changes will be made'
  ((VERBOSE)) && info 'Verbose mode enabled'
  ((FORCE)) && info 'Force mode enabled - will overwrite existing files'

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
    info 'Dry-run complete - review output and run without --dry-run to install'
  else
    success "Installation of $APP_NAME v$VERSION complete!"
  fi
}

# ============================================================================
# Step 12: Script Invocation
# ============================================================================

main "$@"

# ============================================================================
# Step 13: End Marker
# ============================================================================

#fin
```

---

## Anti-Patterns

### ✗ Wrong: Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash

# Script starts without error handling
VERSION='1.0.0'

# Commands can fail silently
rm -rf /important/data
cp config.txt /etc/
```

**Problem:** Errors are not caught, script continues executing after failures, leading to silent corruption or incomplete operations.

### ✓ Correct: Error Handling First

```bash
#!/usr/bin/env bash

# Installation script with proper safeguards

set -euo pipefail

shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
# ... rest of script
```

---

### ✗ Wrong: Declaring Variables After Use

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

**Problem:** Variables are referenced before they're declared, leading to "unbound variable" errors with `set -u`.

### ✓ Correct: Declare Before Use

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

### ✗ Wrong: Business Logic Before Utilities

```bash
#!/usr/bin/env bash
set -euo pipefail

# Business logic defined first
process_files() {
  local -- file
  for file in *.txt; do
    # Calling die() which isn't defined yet!
    [[ -f "$file" ]] || die 2 "Not a file: $file"
    echo "Processing: $file"
  done
}

# Utilities defined after business logic
die() {
  local -i exit_code=$1
  shift
  >&2 echo "ERROR: $*"
  exit "$exit_code"
}

main() {
  process_files
}

main "$@"
#fin
```

**Problem:** `process_files()` calls `die()` which isn't defined yet. This works in bash (functions are resolved at runtime) but violates the principle of bottom-up organization and makes code harder to understand.

### ✓ Correct: Utilities Before Business Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

# Utilities first
die() {
  local -i exit_code=$1
  shift
  >&2 echo "ERROR: $*"
  exit "$exit_code"
}

# Business logic can safely call utilities
process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file: $file"
    echo "Processing: $file"
  done
}

main() {
  process_files
}

main "$@"
#fin
```

---

### ✗ Wrong: No `main()` Function in Large Script

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

**Problem:** No clear entry point, argument parsing is scattered, can't easily test the script, can't source it to test individual functions.

### ✓ Correct: Use `main()` for Scripts Over 40 Lines

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
      *) die 22 "Invalid argument: $1" ;;
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

### ✗ Wrong: Missing End Marker

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

main() {
  echo 'Hello, World!'
}

main "$@"
# File ends without #fin
```

**Problem:** No visual confirmation that file is complete, harder to detect truncated files.

### ✓ Correct: Always End With `#fin`

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

### ✗ Wrong: Readonly Before Parsing Arguments

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

**Problem:** Variables that need to be modified during argument parsing are made readonly too early.

### ✓ Correct: Readonly After Argument Parsing

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

### ✗ Wrong: Mixing Declaration and Logic

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

**Problem:** Globals are scattered throughout the file, making it hard to see all state variables at once.

### ✓ Correct: All Globals Together

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

### ✗ Wrong: Sourcing Without Protecting Execution

```bash
#!/usr/bin/env bash
# This file is meant to be sourced, but...

set -euo pipefail  # Modifies caller's shell!

die() {
  >&2 echo "ERROR: $*"
  exit 1
}

# Runs automatically when sourced!
main "$@"
#fin
```

**Problem:** When sourced, this modifies the caller's shell settings and runs `main` automatically.

### ✓ Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash

# Only set strict mode when executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
fi

die() {
  >&2 echo "ERROR: $*"
  exit 1
}

main() {
  echo 'Running main'
}

# Only run main when executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

#fin
```

---

## Edge Cases and Variations

### When to Skip `main()` Function

**Small scripts under 40 lines** can skip `main()` and run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Simple file counter - only 20 lines total
declare -i count=0

for file in "$@"; do
  [[ -f "$file" ]] && count+=1
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

# No main(), no execution
# Just function definitions for other scripts to use
#fin
```

### Scripts With External Configuration

**When sourcing config files**, structure might include:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/myapp/config.sh"
declare -- DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/myapp"

# Source config file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config: $CONFIG_FILE"
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
    die 1 "Unsupported platform: $PLATFORM"
    ;;
esac

readonly -- PACKAGE_MANAGER INSTALL_CMD

# ... rest of script
```

### Scripts With Cleanup Requirements

**When trap handlers are needed:**

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'

# Temporary files array for cleanup
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=$?
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
  done

  return "$exit_code"
}

# Set trap early, after functions are defined
trap cleanup EXIT

# ... rest of script uses TEMP_FILES
```

**Trap should be set** after cleanup function is defined but before any code that creates temp files.

---

## Summary

**The 13-step layout is not optional** - it's the foundation of all scripts in this coding standard. This structure:

1. **Guarantees safety** - Error handling comes first, nothing runs without it
2. **Ensures consistency** - Every script follows the same pattern
3. **Enables testing** - `main()` function allows sourcing for tests
4. **Prevents errors** - Bottom-up organization means dependencies are always defined before use
5. **Documents intent** - Structure itself tells you what the script does and how it works
6. **Simplifies maintenance** - Know where everything goes, no guessing

**For scripts over 40 lines**, all 13 steps are mandatory. **For smaller scripts**, steps 11-12 (main function) can be skipped, but all other steps remain required.

**When in doubt**, follow the complete 13-step structure - the benefits far outweigh the minor overhead. Every production script should follow this pattern exactly.

This layout is the result of years of experience and represents best practices for Bash scripting. Deviations from this structure should be rare and well-justified.
