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
| **13-step structure** | Shebang â†' shellcheck â†' description â†' strict mode â†' shopt â†' metadata â†' globals â†' colors â†' utilities â†' business logic â†' main() â†' invocation â†' #fin |
| **Progressive readonly** | Variables mutable during parsing, immutable after |
| **Derived paths** | `update_derived_paths()` recalculates when PREFIX changes |
| **Dry-run mode** | Every operation checks `DRY_RUN` flag before executing |
| **Force mode** | Existing files warn unless `--force` specified |
| **TTY-aware colors** | Conditional based on `[[ -t 1 && -t 2 ]]` |
| **Validation first** | Prerequisites and config validated before filesystem ops |
| **Error accumulation** | Warnings collected in array for summary reporting |
