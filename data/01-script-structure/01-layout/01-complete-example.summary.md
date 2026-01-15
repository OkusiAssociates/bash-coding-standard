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
    vecho) : ;; info) prefix+=" ${CYAN}â—‰${NC}" ;; warn) prefix+=" ${YELLOW}â–²${NC}" ;;
    success) prefix+=" ${GREEN}âœ“${NC}" ;; error) prefix+=" ${RED}âœ—${NC}" ;; *) ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() { local -- REPLY; read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}â–²${NC} ${1:-'Continue?'} y/n "; echo; [[ ${REPLY,,} == y ]]; }
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

**13-Step Structure:** Shebangâ†'shellcheckâ†'descriptionâ†'strict modeâ†'shoptâ†'metadataâ†'globalsâ†'colorsâ†'utilitiesâ†'business logicâ†'mainâ†'invocationâ†'#fin

**Functional:** Dry-run throughout â€¢ Force mode overwrites â€¢ Derived paths via `update_derived_paths()` â€¢ Validation before filesystem ops â€¢ Error arrays â€¢ Interactive prompts â€¢ Conditional systemd â€¢ Progressive readonly â€¢ Short option expansion
