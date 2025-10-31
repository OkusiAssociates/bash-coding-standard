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
