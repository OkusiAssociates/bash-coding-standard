#!/usr/bin/env bash
# Script to install en_ID locale and automatically set it as system default
# For Ubuntu Desktop and Server
# Fully automated installation with persistence
set -euo pipefail
shopt -s inherit_errexit

# Script metadata
# shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
# shellcheck disable=SC2034 # SCRIPT_DIR reserved per BCS0103
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
# shellcheck disable=SC2034 # VERSION reserved per BCS0103
declare -r VERSION=2.1.0

# Secure PATH for privileged execution
declare -rx PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Repository URL (can be overridden by environment variable)
declare -r REPO_URL=${EN_ID_REPO_URL:-https://github.com/Open-Technology-Foundation/en_ID.git}
[[ $REPO_URL =~ ^https?:// ]] || { >&2 echo "Invalid repository URL ${REPO_URL@Q}"; exit 22; }

# Colors for output (CYAN included per BCS0706 minimal set)
if [[ -t 1 && -t 2 ]]; then
  # shellcheck disable=SC2034 # CYAN reserved per BCS0706
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  # shellcheck disable=SC2034
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

# Global variables
declare -- CNF_HOOK=''
declare -- TEMP_DIR=''
declare -r APT_HOOK_FILE=/etc/apt/apt.conf.d/99en-id-locale-gen
declare -i SSH_CONFIG_UPDATED=0
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
warn()  { _msg "$@"; }
error() { _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# --- Cleanup ---

# shellcheck disable=SC2317 # invoked via trap
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  # Restore APT hook if we disabled it
  if [[ -n $CNF_HOOK && -f "$CNF_HOOK".disabled ]]; then
    mv -- "$CNF_HOOK".disabled "$CNF_HOOK" ||:
  fi
  # Remove temp directory
  if [[ -n $TEMP_DIR ]]; then
    rm -rf "$TEMP_DIR" ||:
  fi
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# --- Execution ---

# Check if running as root
if ((EUID)); then
  die 1 'This script must be run as root or with sudo'
fi

info "${GREEN}Installing en_ID locale as system default...$NC"

# Update package lists
info 'Updating package lists...'
# Disable cnf-update-db APT hook temporarily — it can cause apt-get update failures
for conf in /etc/apt/apt.conf.d/*; do
  [[ -f $conf ]] || continue
  if grep -q 'cnf-update-db' "$conf" 2>/dev/null; then
    CNF_HOOK=$conf
    break
  fi
done
if [[ -n $CNF_HOOK ]]; then
  mv -- "$CNF_HOOK" "$CNF_HOOK".disabled || die 1 "Failed to disable APT hook ${CNF_HOOK@Q}"
  apt-get update -qq || die 1 'apt-get update failed'
  mv -- "$CNF_HOOK".disabled "$CNF_HOOK" || die 1 "Failed to restore APT hook ${CNF_HOOK@Q}"
else
  apt-get update -qq || die 1 'apt-get update failed'
fi

# Install required packages
info 'Installing required packages...'
apt-get install -y -qq git make locales || die 18 'Failed to install: git make locales'

# Clone the repository to temp directory
TEMP_DIR=$(mktemp -d)
info 'Downloading en_ID locale...'
if ! git clone --quiet "$REPO_URL" "$TEMP_DIR"/en_ID; then
  die 1 'Failed to download en_ID repository'
fi

# Change to repo directory
cd "$TEMP_DIR"/en_ID || die 1 'Failed to enter repo directory'

# Install the locale
info 'Installing locale files...'
make install || die 1 'make install failed'

# Verify installation
if ! locale -a | grep -q 'en_ID'; then
  die 1 'Failed to install en_ID locale'
fi

info "${GREEN}en_ID locale installed successfully$NC"

# Backup current locale settings
if [[ -f /etc/default/locale ]]; then
  cp /etc/default/locale /etc/default/locale.backup || die 5 'Failed to backup locale settings'
  info 'Backed up current locale settings to /etc/default/locale.backup'
fi

# Set en_ID as default locale
info 'Setting en_ID as default locale...'
update-locale LANG=en_ID.UTF-8 \
              LC_ALL=en_ID.UTF-8 \
              LC_CTYPE=en_ID.UTF-8 \
              LC_NUMERIC=en_ID.UTF-8 \
              LC_TIME=en_ID.UTF-8 \
              LC_COLLATE=en_ID.UTF-8 \
              LC_MONETARY=en_ID.UTF-8 \
              LC_MESSAGES=en_ID.UTF-8 \
              LC_PAPER=en_ID.UTF-8 \
              LC_NAME=en_ID.UTF-8 \
              LC_ADDRESS=en_ID.UTF-8 \
              LC_TELEPHONE=en_ID.UTF-8 \
              LC_MEASUREMENT=en_ID.UTF-8 \
              LC_IDENTIFICATION=en_ID.UTF-8 \
  || die 1 'update-locale failed'

# Also set locale in /etc/environment for apps that don't read /etc/default/locale
grep -q 'LANG=en_ID.UTF-8' /etc/environment \
  || echo 'LANG=en_ID.UTF-8' >> /etc/environment \
  || die 5 'Failed to write /etc/environment'
grep -q 'LC_ALL=en_ID.UTF-8' /etc/environment \
  || echo 'LC_ALL=en_ID.UTF-8' >> /etc/environment \
  || die 5 'Failed to write /etc/environment'

# Add to locale.gen for persistence across system updates
if [[ -f /etc/locale.gen ]]; then
  if ! grep -q '^en_ID.UTF-8' /etc/locale.gen; then
    echo 'en_ID.UTF-8 UTF-8' >> /etc/locale.gen || die 5 'Failed to write /etc/locale.gen'
    info 'Added en_ID to /etc/locale.gen for persistence'
  fi
fi

# Create APT hook to regenerate locale after package updates
if [[ ! -f $APT_HOOK_FILE ]]; then
  cat > "$APT_HOOK_FILE" << 'EOF'
// Automatically regenerate en_ID locale after package updates
DPkg::Post-Invoke { "if [ -f /etc/locale.gen ] && grep -q '^en_ID.UTF-8' /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"; };
EOF
  info 'Created APT hook to maintain en_ID locale after system updates'
fi

# Enable locale forwarding in SSH if not already configured
if [[ -f /etc/ssh/sshd_config ]]; then
  if ! grep -q '^AcceptEnv.*LC_\*' /etc/ssh/sshd_config; then
    echo 'AcceptEnv LANG LC_*' >> /etc/ssh/sshd_config || die 5 'Failed to write /etc/ssh/sshd_config'
    SSH_CONFIG_UPDATED=1
  fi
fi

info "${GREEN}Installation complete!$NC"
info
info 'Current locale settings:'
>&2 locale

info
warn 'IMPORTANT: You need to log out and log back in for the changes to take full effect.'
warn 'For SSH sessions, reconnect to apply the new locale.'

if ((SSH_CONFIG_UPDATED)); then
  info
  warn 'NOTE: SSH configuration was updated to accept locale environment variables.'
  warn '      You should restart the SSH service when convenient:'
  warn '      sudo systemctl restart ssh'
fi

# Test the locale
info
info 'Testing locale (date format):'
>&2 LC_ALL=en_ID.UTF-8 date +'%x = %A, %d %B %Y'

exit 0
#fin
