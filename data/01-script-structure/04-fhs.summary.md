## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS when designing scripts that install files or search for resources. FHS compliance enables predictable file locations, supports multi-environment installations, and integrates with package managers.**

**Rationale:**
- Predictability: Users/package managers expect files in standard locations
- Multi-environment support: Works in development, local, system, and user installs
- No hardcoded paths: FHS search patterns eliminate brittle absolute paths
- Portability: Works across distributions without modification

**Common FHS locations:**
- `/usr/local/bin/`, `/usr/bin/` - Executables (user-installed vs package-managed)
- `/usr/local/share/`, `/usr/share/` - Architecture-independent data
- `/usr/local/lib/`, `/usr/lib/` - Libraries and loadable modules
- `/usr/local/etc/`, `/etc/` - Configuration files
- `$HOME/.local/bin/`, `$HOME/.local/share/` - User-specific executables/data
- `${XDG_CONFIG_HOME:-$HOME/.config}/` - User-specific configuration

**Core FHS search pattern:**
```bash
find_data_file() {
  local -- filename=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/"$filename"                                    # Development
    /usr/local/share/myapp/"$filename"                           # Local install
    /usr/share/myapp/"$filename"                                 # System install
    "${XDG_DATA_HOME:-"$HOME"/.local/share}"/myapp/"$filename"   # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done
  return 1
}
```

**Config file search (XDG priority):**
```bash
find_config_file() {
  local -- filename=$1
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-"$HOME"/.config}"/myapp/"$filename"  # User config (highest)
    /usr/local/etc/myapp/"$filename"                          # System-local
    /etc/myapp/"$filename"                                    # System-wide
    "$SCRIPT_DIR"/"$filename"                                 # Development/fallback
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ ! -f "$path" ]] || { echo "$path"; return 0; }
  done
  return 1  # Config is optional
}
```

**Library loading pattern:**
```bash
load_library() {
  local -- lib_name=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/lib/"$lib_name"      # Development
    /usr/local/lib/myapp/"$lib_name"   # Local install
    /usr/lib/myapp/"$lib_name"         # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { source "$path"; return 0; } ||:
  done
  die 2 "Library not found ${lib_name@Q}"
}
```

**FHS-compliant installation script:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Installation paths (customizable via PREFIX)
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
declare -- LIB_DIR="$PREFIX"/lib/myapp
declare -- ETC_DIR="$PREFIX"/etc/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
  install -m 755 "$SCRIPT_DIR"/myapp "$BIN_DIR"/myapp
  install -m 644 "$SCRIPT_DIR"/data/template.txt "$SHARE_DIR"/template.txt
  install -m 644 "$SCRIPT_DIR"/lib/common.sh "$LIB_DIR"/common.sh
  # Preserve existing config
  [[ -f "$ETC_DIR"/myapp.conf ]] || \
    install -m 644 "$SCRIPT_DIR"/myapp.conf.example "$ETC_DIR"/myapp.conf
}

uninstall_files() {
  rm -f "$BIN_DIR"/myapp "$SHARE_DIR"/template.txt "$LIB_DIR"/common.sh
  rmdir --ignore-fail-on-non-empty "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
}

main() {
  case "${1:-install}" in
    install)   install_files ;;
    uninstall) uninstall_files ;;
    *)         die 2 "Usage: $SCRIPT_NAME {install|uninstall}" ;;
  esac
}
main "$@"
#fin
```

**Generic resource finder (file or directory):**
```bash
find_resource() {
  local -- type=$1 name=$2
  local -- install_base="${SCRIPT_DIR%/bin}"/share/myorg/myproject
  local -a search_paths=(
    "$SCRIPT_DIR"                     # Development
    "$install_base"                   # Custom PREFIX
    /usr/local/share/myorg/myproject  # Local install
    /usr/share/myorg/myproject        # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ||: ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ||: ;;
    esac
  done
  return 1
}

# Usage:
CONFIG=$(find_resource file config.yml) || die 'Config not found'
DATA_DIR=$(find_resource dir data) || die 'Data directory not found'
```

**XDG Base Directory variables:**
```bash
declare -- XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
declare -- XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
declare -- XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
declare -- XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}
```

**Anti-patterns:**
```bash
# ✗ Hardcoded absolute path
data_file=/home/user/projects/myapp/data/template.txt
# ✓ FHS search pattern
data_file=$(find_data_file template.txt)

# ✗ Assuming specific install location
source /usr/local/lib/myapp/common.sh
# ✓ Search multiple FHS locations
load_library common.sh

# ✗ Relative paths from CWD (breaks when run elsewhere)
source ../lib/common.sh
# ✓ Paths relative to script location
source "$SCRIPT_DIR"/../lib/common.sh

# ✗ Not supporting PREFIX customization
BIN_DIR=/usr/local/bin
# ✓ Respect PREFIX environment variable
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin

# ✗ Overwriting user config on upgrade
install myapp.conf "$PREFIX"/etc/myapp/myapp.conf
# ✓ Preserve existing config
[[ -f "$PREFIX"/etc/myapp/myapp.conf ]] || \
  install myapp.conf.example "$PREFIX"/etc/myapp/myapp.conf
```

**Edge cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX=${PREFIX:-/usr/local}
PREFIX=${PREFIX%/}  # Remove trailing slash if present
```

**2. User install without sudo:**
```bash
if [[ ! -w "$PREFIX" ]]; then
  warn "No write permission to ${PREFIX@Q}"
  info "Try: PREFIX=\$HOME/.local make install"
  die 5 'Permission denied'
fi
```

**3. Symlink resolution:**
```bash
# realpath resolves symlinks to actual installation directory
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
# SCRIPT_DIR points to actual location, not symlink (/usr/local/bin)
```

**When NOT to use FHS:**
- Single-user scripts only used by one person
- Project-specific tools (build scripts, test runners) staying in project directory
- Container applications using `/app` or similar
- Embedded systems with custom layouts

**Key principle:** FHS compliance makes scripts portable, predictable, and package-manager compatible. Design scripts to work in development mode and multiple install scenarios without modification.
