#!/usr/bin/env bash
# fix-permissions.sh - Fix group permissions for BCS repository and installation
# This script ensures proper group ownership and permissions for collaborative development

set -euo pipefail
shopt -s inherit_errexit

declare -r VERSION=1.0.1
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

# Configuration
declare -r GROUP=bcs
declare -r REPO_DIR=$SCRIPT_DIR
declare -r INSTALL_DIR=/usr/local/share/yatti/bash-coding-standard

declare -i VERBOSE=1

# Terminal colors
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BLUE=$'\033[0;34m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' BLUE='' NC=''
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

main() {
  info "BCS Permissions Fix Script ${VERSION}"
  >&2 echo

  # Check if group exists
  getent group "$GROUP" >/dev/null 2>&1 \
      || die "Group ${GROUP@Q} does not exist." \
             "Create it first: sudo groupadd -g 8088 $GROUP"

  # Check if running as root for installed location
  if ((EUID)); then
    warn "Not running as root. Can only fix repository permissions," \
         "not ${INSTALL_DIR@Q}"
    warn 'Run with sudo to fix both locations'
    >&2 echo
  fi

  # Prompt user to proceed if running from terminal
  if [[ -t 0 ]]; then
    info 'This will modify file and directory permissions for:'
    info "  - Repository: ${REPO_DIR}"
    ((EUID)) || info "  - Installed: ${INSTALL_DIR}"
    >&2 echo
    yn 'Proceed with permission changes?' || die 'Operation cancelled by user'
    >&2 echo
  fi

  # Fix repository permissions
  info "Fixing repository permissions in ${REPO_DIR@Q}"

  if ((EUID)); then
    sudo chgrp -R "$GROUP" "$REPO_DIR"
  else
    chgrp -R "$GROUP" "$REPO_DIR"
  fi

  find "$REPO_DIR" -type d -exec chmod 2775 {} +
  find "$REPO_DIR" -type f -exec chmod 664 {} +

  # Set executable scripts
  chmod 775 "$REPO_DIR"/bcs
  [[ -f "$REPO_DIR"/testcode ]] && chmod 775 "$REPO_DIR"/testcode ||:
  find "$REPO_DIR" -name "*.sh" -type f -exec chmod 775 {} +

  success 'Repository permissions fixed'

  # Fix installed location (if running as root)
  if ((EUID == 0)); then
    if [[ -d "$INSTALL_DIR" ]]; then
      info "Fixing installed location permissions in ${INSTALL_DIR@Q}"

      chgrp -R "$GROUP" "$INSTALL_DIR"
      find "$INSTALL_DIR" -type d -exec chmod 2775 {} +
      find "$INSTALL_DIR" -type f -exec chmod 664 {} +

      success 'Installed location permissions fixed'
    else
      warn "Installed location not found ${INSTALL_DIR@Q}"
    fi
  fi

  >&2 echo
  success 'Permission fix complete'
  info "Group ${GROUP@Q} members can now read/write all BCS files"
  info "New files will automatically inherit ${GROUP@Q} group ownership (setgid)"
}

main "$@"
#fin
