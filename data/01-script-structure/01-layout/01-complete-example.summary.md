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

# ============================================================================
# Script Metadata
# ============================================================================

declare -r VERSION=2.2.420
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# ============================================================================
# Global Variable Declarations
# ============================================================================

# Configuration (can be modified by arguments)
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- APP_NAME=my_app_420
declare -- SYSTEM_USER=my_app_user_420

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
  read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-'Continue?'} y/n "
  echo
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

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - Installation script

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -p, --prefix DIR       Installation prefix (default: /usr/local)
  -u, --user USER        System user for service (default: myapp)
  -n, --dry-run          Show what would be done without doing it
  -f, --force            Overwrite existing files
  -s, --systemd          Install systemd service unit
  -v, --verbose          Enable verbose output
  -q, --quiet            Disable verbose output
  -h, --help             Display this help message
  -V, --version          Display version information
HELP
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
  ((missing==0)) || die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 1 'PREFIX cannot be empty'
  ! [[ "$PREFIX" =~ [[:space:]] ]] || die 22 "PREFIX cannot contain spaces ${PREFIX@Q}"
  [[ -n "$APP_NAME" ]] || die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || die 22 'Invalid APP_NAME format'
  [[ -n "$SYSTEM_USER" ]] || die 22 'SYSTEM_USER cannot be empty'
  success 'Configuration validated'
}

create_directories() {
  local -- dir
  for dir in "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then
      info "[DRY-RUN] Would create directory ${dir@Q}"
    elif [[ ! -d "$dir" ]]; then
      mkdir -p "$dir" || die 1 "Failed to create directory ${dir@Q}"
      success "Created directory ${dir@Q}"
    fi
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR"/bin target=$BIN_DIR
  [[ -d "$source" ]] || die 2 "Source directory not found ${source@Q}"
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install binaries"; return 0; }
  local -- file basename target_file
  local -i count=0
  for file in "$source"/*; do
    [[ -f "$file" ]] || continue
    basename=${file##*/}
    target_file="$target"/"$basename"
    if [[ -f "$target_file" ]] && ! ((FORCE)); then
      warn "File exists (use --force) ${target_file@Q}"
      continue
    fi
    install -m 755 "$file" "$target_file" || die 1 "Failed to install ${basename@Q}"
    INSTALLED_FILES+=("$target_file")
    count+=1
  done
  success "Installed $count binaries"
}

# ============================================================================
# Step 11: main() Function
# ============================================================================

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
      -[punfsvqVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             die 2  "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done

  readonly -- PREFIX APP_NAME SYSTEM_USER
  readonly -- BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -- VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD

  check_prerequisites
  validate_config
  create_directories
  install_binaries
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

## Key Patterns Demonstrated

| Pattern | Implementation |
|---------|----------------|
| **Dry-run mode** | Every operation checks `DRY_RUN` flag before execution |
| **Force mode** | Existing files trigger warnings unless `--force` |
| **Derived paths** | `update_derived_paths()` called when `PREFIX` changes |
| **Validation first** | Prerequisites/config validated before filesystem ops |
| **Progressive readonly** | Variables become immutable after argument parsing |
| **Bundled options** | `-vf` splits to `-v -f` via recursive `set --` |

## Structural Checklist

1. ✓ Shebang + shellcheck + description + strict mode + shopt
2. ✓ Metadata: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME (all readonly)
3. ✓ Globals organized: configuration, runtime flags, arrays
4. ✓ TTY-aware color definitions
5. ✓ Standard `_msg()` system with info/warn/error/success helpers
6. ✓ Business functions: validation → action → summary
7. ✓ Complete argument parsing with short option bundling
8. ✓ `main "$@"` invocation
9. ✓ `#fin` end marker

This template demonstrates all BCS principles working together in production code.
