### Complete Working Example

Production installation script demonstrating all 13 BCS0101 layout steps.

---

```bash
#!/bin/bash
#shellcheck disable=SC2034
# Configurable installation script with dry-run mode and validation
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION=2.1.420
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- PREFIX=/usr/local APP_NAME=myapp SYSTEM_USER=myapp
declare -- BIN_DIR="$PREFIX"/bin LIB_DIR="$PREFIX"/lib SHARE_DIR="$PREFIX"/share
declare -- CONFIG_DIR=/etc/"$APP_NAME" LOG_DIR=/var/log/"$APP_NAME"
declare -i DRY_RUN=0 FORCE=0 INSTALL_SYSTEMD=0 VERBOSE=1
declare -a WARNINGS=() INSTALLED_FILES=()

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

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

update_derived_paths() {
  BIN_DIR="$PREFIX"/bin LIB_DIR="$PREFIX"/lib SHARE_DIR="$PREFIX"/share
  CONFIG_DIR=/etc/"$APP_NAME" LOG_DIR=/var/log/"$APP_NAME"
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
    command -v "$cmd" >/dev/null 2>&1 || { error "Required command not found ${cmd@Q}"; missing=1; }
  done
  ((INSTALL_SYSTEMD)) && ! command -v systemctl >/dev/null 2>&1 && { error 'systemctl not found'; missing=1; }
  ((missing==0)) || die 1 'Missing required commands'
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ "$PREFIX" =~ [[:space:]] ]] && die 22 'PREFIX cannot contain spaces'
  [[ -n "$APP_NAME" ]] || die 22 'APP_NAME cannot be empty'
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_-]*$ ]] || die 22 'Invalid APP_NAME'
  [[ -n "$SYSTEM_USER" ]] || die 22 'SYSTEM_USER cannot be empty'
  if [[ ! -d "$PREFIX" ]]; then
    ((FORCE)) || yn "Create PREFIX directory '$PREFIX'?" || die 1 'Installation cancelled'
    vecho "Will create ${PREFIX@Q}"
  fi
  success 'Configuration validated'
}

create_directories() {
  local -- dir
  for dir in "$BIN_DIR" "$LIB_DIR" "$SHARE_DIR" "$CONFIG_DIR" "$LOG_DIR"; do
    if ((DRY_RUN)); then info "[DRY-RUN] Would create ${dir@Q}"; continue; fi
    [[ -d "$dir" ]] && { vecho "Exists ${dir@Q}"; continue; }
    mkdir -p "$dir" || die 1 "Failed to create ${dir@Q}"
    success "Created ${dir@Q}"
  done
}

install_binaries() {
  local -- source="$SCRIPT_DIR/bin" target="$BIN_DIR"
  [[ -d "$source" ]] || die 2 "Source not found ${source@Q}"
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install from ${source@Q}"; return 0; }
  local -- file basename target_file
  local -i count=0
  for file in "$source"/*; do
    [[ -f "$file" ]] || continue
    basename=${file##*/} target_file="$target/$basename"
    [[ -f "$target_file" ]] && ! ((FORCE)) && { warn "Exists ${target_file@Q}"; continue; }
    install -m 755 "$file" "$target_file" || die 1 "Failed ${basename@Q}"
    INSTALLED_FILES+=("$target_file"); count+=1
  done
  success "Installed $count binaries"
}

install_libraries() {
  local -- source="$SCRIPT_DIR"/lib target="$LIB_DIR"/"$APP_NAME"
  [[ -d "$source" ]] || { vecho 'No libraries'; return 0; }
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would install libraries"; return 0; }
  mkdir -p "$target" && cp -r "$source"/* "$target"/ && chmod -R a+rX "$target" || die 1 'Library install failed'
  success "Installed libraries to ${target@Q}"
}

generate_config() {
  local -- config_file="$CONFIG_DIR"/"$APP_NAME".conf
  ((DRY_RUN==0)) || { info "[DRY-RUN] Would generate ${config_file@Q}"; return 0; }
  [[ -f "$config_file" ]] && ! ((FORCE)) && { warn "Config exists ${config_file@Q}"; return 0; }
  cat > "$config_file" <<EOT
# $APP_NAME configuration - Generated by $SCRIPT_NAME $VERSION
[installation]
prefix = $PREFIX
version = $VERSION
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
  success "Generated config"
}

install_systemd_unit() {
  ((INSTALL_SYSTEMD)) || return 0
  local -- unit_file="/etc/systemd/system/${APP_NAME}.service"
  ((DRY_RUN)) && { info "[DRY-RUN] Would install ${unit_file@Q}"; return 0; }
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
  systemctl daemon-reload || warn 'Failed to reload systemd'
  success "Installed systemd unit"
}

set_permissions() {
  ((DRY_RUN)) && { info '[DRY-RUN] Would set permissions'; return 0; }
  if id "$SYSTEM_USER" >/dev/null 2>&1; then
    chown -R "$SYSTEM_USER:$SYSTEM_USER" "$LOG_DIR" 2>/dev/null || warn "Failed ownership ${LOG_DIR@Q}"
  else
    warn "User ${SYSTEM_USER@Q} does not exist"
  fi
  success 'Permissions configured'
}

main() {
  while (($#)); do
    case $1 in
      -p|--prefix)  noarg "$@"; shift; PREFIX=$1; update_derived_paths ;;
      -u|--user)    noarg "$@"; shift; SYSTEM_USER=$1 ;;
      -n|--dry-run) DRY_RUN=1 ;;
      -f|--force)   FORCE=1 ;;
      -s|--systemd) INSTALL_SYSTEMD=1 ;;
      -v|--verbose) VERBOSE=1 ;;
      -h|--help)    usage; return 0 ;;
      -V|--version) echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -*)           die 22 "Invalid option ${1@Q}" ;;
      *)            die 2  "Unexpected argument ${1@Q}" ;;
    esac
    shift
  done
  readonly -- PREFIX APP_NAME SYSTEM_USER BIN_DIR LIB_DIR SHARE_DIR CONFIG_DIR LOG_DIR
  readonly -i VERBOSE DRY_RUN FORCE INSTALL_SYSTEMD
  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled'
  info "Installing $APP_NAME $VERSION to ${PREFIX@Q}"
  check_prerequisites; validate_config; create_directories
  install_binaries; install_libraries; generate_config
  install_systemd_unit; set_permissions
  ((DRY_RUN)) && info 'Run without --dry-run to install' || success "Installation complete!"
}

main "$@"
#fin
```

---

## Key Patterns

**Structure:** 13-step layout, metadata readonly, typed globals (`declare -i/-a/--`), conditional colors, `_msg()` system, bottom-up function order.

**Patterns:** Dry-run checks, `update_derived_paths()` (BCS0209), `${var@Q}` logging (BCS0306), progressive readonly after parsing.
