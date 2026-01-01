## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS for scripts that install files or search for resources. FHS enables predictable file locations, multi-environment support, and package manager compatibility.**

**Rationale:**
- Predictability: Standard locations (`/usr/local/bin/`, `/usr/share/`)
- Multi-environment: Development, local install, system install, user install
- Package manager compatibility (apt, yum, pacman)
- No hardcoded paths; portability across distributions
- Logical separation: executables, data, configuration, documentation

**Common FHS Locations:**
| Path | Purpose |
|------|---------|
| `/usr/local/bin/` | User-installed executables |
| `/usr/local/share/` | Architecture-independent data |
| `/usr/local/lib/` | Libraries and loadable modules |
| `/usr/local/etc/` | Configuration files |
| `/usr/bin/`, `/usr/share/` | Package manager-managed |
| `$HOME/.local/bin/` | User-specific executables |
| `${XDG_CONFIG_HOME:-$HOME/.config}/` | User configuration |

**FHS Search Pattern:**
```bash
find_data_file() {
  local -- script_dir=$1
  local -- filename=$2
  local -a search_paths=(
    "$script_dir"/"$filename"  # Development
    /usr/local/share/myapp/"$filename" # Local install
    /usr/share/myapp/"$filename" # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$filename"  # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done
  return 1
}
```

**FHS-Compliant Installation Script:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"
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

**Generic FHS Resource Finder:**
```bash
find_resource() {
  local -- type=$1 name=$2
  local -- install_base="${SCRIPT_DIR%/bin}"/share/myorg/myproject
  local -a search_paths=(
    "$SCRIPT_DIR"                        # Development
    "$install_base"                      # Custom PREFIX
    /usr/local/share/myorg/myproject     # Local install
    /usr/share/myorg/myproject           # System install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ;;
    esac
  done
  return 1
}

# Usage:
CONFIG=$(find_resource file config.yml) || die 'Config not found'
DATA_DIR=$(find_resource dir data) || die 'Data directory not found'
```

**XDG Base Directory Variables:**
```bash
declare -- XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
declare -- XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
declare -- XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
declare -- XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
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

# ✗ Hardcoded BIN_DIR
BIN_DIR=/usr/local/bin
# ✓ Respect PREFIX
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin

# ✗ Overwriting user config on upgrade
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"
# ✓ Preserve existing config
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge Cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX=${PREFIX:-/usr/local}
PREFIX=${PREFIX%/}  # Remove trailing slash
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
# realpath resolves symlinks - SCRIPT_DIR points to actual location
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
```

**When NOT to use FHS:**
- Single-user scripts
- Project-specific tools (build scripts, test runners)
- Container applications (`/app` paths)
- Embedded systems with custom layouts

**Key Principle:** FHS compliance makes scripts portable, predictable, and package manager compatible. Design scripts to work in development and multiple install scenarios without modification.
