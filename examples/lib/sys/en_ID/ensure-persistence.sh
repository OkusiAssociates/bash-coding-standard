#!/usr/bin/env bash
# Ensure en_ID locale persists through system updates
# Works on Debian/Ubuntu, Fedora/RHEL, and Arch Linux systems
set -euo pipefail
shopt -s inherit_errexit

# Script metadata
# shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
# shellcheck disable=SC2034 # SCRIPT_DIR reserved per BCS0103
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Secure PATH for privileged execution
declare -rx PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Colors for output (CYAN included per BCS0706 minimal set)
if [[ -t 1 && -t 2 ]]; then
  # shellcheck disable=SC2034 # CYAN reserved per BCS0706
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  # shellcheck disable=SC2034
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

# Global variables
declare -- DISTRO=''
declare -i CHANGES_MADE=0
declare -i VERBOSE=1

# --- Messaging functions ---

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    warn)  prefix+=" $YELLOW▲$NC" ;;
    info)  prefix+=" $CYAN◉$NC" ;;
    error) prefix+=" $RED✗$NC" ;;
    *)     ;;
  esac
  (($#)) || { >&2 echo; return 0; }
  for msg in "$@"; do >&2 printf '%s %s\n' "$prefix" "$msg"; done
}
info()  { ((VERBOSE)) || return 0; _msg "$@"; }
# shellcheck disable=SC2317 # BCS0706 standard set; may be unused in this script
warn()  { _msg "$@"; }
error() { _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# --- Cleanup ---

# shellcheck disable=SC2317 # invoked via trap
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# --- Execution ---

# Check if running as root
if ((EUID)); then
  die 1 'This script must be run as root or with sudo'
fi

# Detect distribution
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  if [[ $ID == ubuntu ]] || [[ $ID == debian ]] || [[ ${ID_LIKE:-} == *debian* ]]; then
    DISTRO=debian
  elif [[ $ID == fedora ]] || [[ $ID == rhel ]] || [[ $ID == centos ]] || [[ "${ID_LIKE:-}" == *rhel* ]] || [[ ${ID_LIKE:-} == *fedora* ]]; then
    DISTRO=fedora
  elif [[ $ID == arch ]] || [[ ${ID_LIKE:-} == *arch* ]]; then
    DISTRO=arch
  fi
fi

if [[ -z $DISTRO ]]; then
  die 1 'Unable to detect distribution'
fi

info "Ensuring en_ID locale persistence on ${DISTRO}..."

# Check if en_ID locale definition exists
if [[ ! -f /usr/share/i18n/locales/en_ID ]]; then
  die 1 'en_ID locale definition not found at /usr/share/i18n/locales/en_ID' \
        'Please install the en_ID locale first using the appropriate install script.'
fi

# Debian/Ubuntu specific persistence
if [[ $DISTRO == debian ]]; then
  info 'Setting up Debian/Ubuntu persistence mechanisms...'

  # Add to locale.gen
  if [[ -f /etc/locale.gen ]]; then
    if ! grep -q '^en_ID.UTF-8' /etc/locale.gen; then
      echo 'en_ID.UTF-8 UTF-8' >> /etc/locale.gen \
        || die 5 'Failed to write /etc/locale.gen'
      info 'Added en_ID to /etc/locale.gen'
      CHANGES_MADE=1
    else
      info 'en_ID already in /etc/locale.gen'
    fi
  fi

  # Create APT hook
  declare -r APT_HOOK_FILE=/etc/apt/apt.conf.d/99en-id-locale-gen
  if [[ ! -f $APT_HOOK_FILE ]]; then
    cat > "$APT_HOOK_FILE" << 'EOF' || die 5 "Failed to create APT hook ${APT_HOOK_FILE@Q}"
// Automatically regenerate en_ID locale after package updates
DPkg::Post-Invoke { "if [ -f /etc/locale.gen ] && grep -q '^en_ID.UTF-8' /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"; };
EOF
    info 'Created APT hook for automatic locale regeneration'
    CHANGES_MADE=1
  else
    info 'APT hook already exists'
  fi

  # Regenerate locale now
  if ((CHANGES_MADE)); then
    info 'Regenerating locale...'
    locale-gen en_ID.UTF-8 || die 1 'locale-gen failed'
  fi

# Fedora/RHEL specific persistence
elif [[ $DISTRO == fedora ]]; then
  info 'Setting up Fedora/RHEL persistence mechanisms...'

  # Create DNF post-transaction hook
  declare -r DNF_HOOK_DIR=/etc/dnf/plugins/post-transaction-actions.d
  declare -r DNF_HOOK_FILE="$DNF_HOOK_DIR"/en_id_locale.action

  if [[ ! -d $DNF_HOOK_DIR ]]; then
    mkdir -p "$DNF_HOOK_DIR" \
      || die 5 "Failed to create hook directory ${DNF_HOOK_DIR@Q}"
  fi

  if [[ ! -f $DNF_HOOK_FILE ]]; then
    cat > "$DNF_HOOK_FILE" << 'EOF' || die 5 "Failed to create DNF hook ${DNF_HOOK_FILE@Q}"
# Regenerate en_ID locale after glibc updates
glibc*:update:/usr/bin/localedef -i en_ID -f UTF-8 en_ID.UTF-8 2>/dev/null || true
glibc*:install:/usr/bin/localedef -i en_ID -f UTF-8 en_ID.UTF-8 2>/dev/null || true
glibc*:reinstall:/usr/bin/localedef -i en_ID -f UTF-8 en_ID.UTF-8 2>/dev/null || true
EOF
    info 'Created DNF hook for automatic locale regeneration'
    CHANGES_MADE=1
  else
    info 'DNF hook already exists'
  fi

  # Regenerate locale now
  info 'Regenerating locale...'
  localedef -i en_ID -f UTF-8 en_ID.UTF-8 || die 1 'localedef failed'

# Arch Linux specific persistence
elif [[ $DISTRO == arch ]]; then
  info 'Setting up Arch Linux persistence mechanisms...'

  # Add to locale.gen
  if [[ -f /etc/locale.gen ]]; then
    if ! grep -q '^en_ID.UTF-8' /etc/locale.gen; then
      echo 'en_ID.UTF-8 UTF-8' >> /etc/locale.gen \
        || die 5 'Failed to write /etc/locale.gen'
      info 'Added en_ID to /etc/locale.gen'
      CHANGES_MADE=1
    else
      info 'en_ID already in /etc/locale.gen'
    fi
  fi

  # Create pacman hook
  declare -r PACMAN_HOOK_DIR=/etc/pacman.d/hooks
  declare -r PACMAN_HOOK_FILE="$PACMAN_HOOK_DIR"/en_id_locale.hook

  if [[ ! -d $PACMAN_HOOK_DIR ]]; then
    mkdir -p "$PACMAN_HOOK_DIR" \
      || die 5 "Failed to create hook directory ${PACMAN_HOOK_DIR@Q}"
  fi

  if [[ ! -f $PACMAN_HOOK_FILE ]]; then
    cat > "$PACMAN_HOOK_FILE" << 'EOF' || die 5 "Failed to create Pacman hook ${PACMAN_HOOK_FILE@Q}"
[Trigger]
Operation = Upgrade
Operation = Install
Type = Package
Target = glibc

[Action]
Description = Regenerate en_ID locale
When = PostTransaction
Exec = /usr/bin/bash -c "if grep -q '^en_ID.UTF-8' /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"
EOF
    info 'Created Pacman hook for automatic locale regeneration'
    CHANGES_MADE=1
  else
    info 'Pacman hook already exists'
  fi

  # Regenerate locale now
  if ((CHANGES_MADE)); then
    info 'Regenerating locale...'
    locale-gen en_ID.UTF-8 || die 1 'locale-gen failed'
  fi
fi

# Verify locale is available
info
info 'Verifying locale availability...'
if locale -a 2>/dev/null | grep -q 'en_ID'; then
  info "${GREEN}✓ en_ID locale is available$NC"
else
  die 1 'en_ID locale is not available after persistence setup'
fi

# Test the locale
info 'Testing locale...'
if LC_ALL=en_ID.UTF-8 date +"%x" >/dev/null 2>&1; then
  info "${GREEN}✓ Locale test successful$NC"
  >&2 LC_ALL=en_ID.UTF-8 date +'%x = %A, %d %B %Y'
else
  die 1 'Locale test failed'
fi

info
info "${GREEN}Persistence mechanisms successfully configured!$NC"
info 'The en_ID locale will now be automatically regenerated after system updates.'

exit 0
#fin
