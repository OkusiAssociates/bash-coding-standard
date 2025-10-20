#!/usr/bin/env bash
# fix-permissions.sh - Fix group permissions for BCS repository and installation
# This script ensures proper group ownership and permissions for collaborative development

set -euo pipefail
shopt -s inherit_errexit

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Configuration
readonly -- GROUP='bcs'
readonly -- REPO_DIR="$SCRIPT_DIR"
readonly -- INSTALL_DIR='/usr/local/share/yatti/bash-coding-standard'

# Terminal colors
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[1;33m' BLUE=$'\033[0;34m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

info() { >&2 echo "${BLUE}◉${NC} $*"; }
success() { >&2 echo "${GREEN}✓${NC} $*"; }
warn() { >&2 echo "${YELLOW}▲${NC} $*"; }
error() { >&2 echo "${RED}✗${NC} $*"; }
die() { error "$@"; exit 1; }

main() {
  info "BCS Permissions Fix Script v${VERSION}"
  echo

  # Check if group exists
  if ! getent group "$GROUP" >/dev/null 2>&1; then
    die "Group '${GROUP}' does not exist. Create it first: sudo groupadd -g 8088 ${GROUP}"
  fi

  # Check if running as root for installed location
  if [[ $EUID -ne 0 ]]; then
    warn "Not running as root. Can only fix repository permissions, not ${INSTALL_DIR}"
    warn "Run with sudo to fix both locations"
    echo
  fi

  # Fix repository permissions
  info "Fixing repository permissions: ${REPO_DIR}"

  if [[ $EUID -eq 0 ]]; then
    chgrp -R "$GROUP" "$REPO_DIR"
  else
    sudo chgrp -R "$GROUP" "$REPO_DIR"
  fi

  find "$REPO_DIR" -type d -exec chmod 2775 {} +
  find "$REPO_DIR" -type f -exec chmod 664 {} +

  # Set executable scripts
  chmod 775 "$REPO_DIR"/bcs
  chmod 775 "$REPO_DIR"/rebuild-bcs-symlinks.sh
  [[ -f "$REPO_DIR/testcode" ]] && chmod 775 "$REPO_DIR/testcode"
  find "$REPO_DIR" -name "*.sh" -type f -exec chmod 775 {} +

  success "Repository permissions fixed"

  # Fix installed location (if running as root)
  if [[ $EUID -eq 0 ]]; then
    if [[ -d "$INSTALL_DIR" ]]; then
      info "Fixing installed location permissions: ${INSTALL_DIR}"

      chgrp -R "$GROUP" "$INSTALL_DIR"
      find "$INSTALL_DIR" -type d -exec chmod 2775 {} +
      find "$INSTALL_DIR" -type f -exec chmod 664 {} +

      success "Installed location permissions fixed"
    else
      warn "Installed location not found: ${INSTALL_DIR}"
    fi
  fi

  echo
  success "Permission fix complete"
  info "Group '${GROUP}' members can now read/write all BCS files"
  info "New files will automatically inherit '${GROUP}' group ownership (setgid)"
}

main "$@"
#fin
