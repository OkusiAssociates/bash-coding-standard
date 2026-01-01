## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS for scripts that install files or search for resources. FHS enables predictable locations, multi-environment support, and package manager compatibility.**

**Rationale:**
- Predictability: Standard locations (`/usr/local/bin/`, `/usr/share/`)
- Multi-environment: Works in development, local, system, and user installs
- Package manager compatible (apt, yum, pacman)
- Eliminates hardcoded paths; portable across distributions
- Separates executables, data, configuration, and documentation

**FHS Locations:**
| Path | Purpose |
|------|---------|
| `/usr/local/bin/` | User-installed executables (not package-managed) |
| `/usr/local/share/` | Architecture-independent data |
| `/usr/local/lib/` | Libraries and loadable modules |
| `/usr/local/etc/` | Configuration files |
| `/usr/bin/`, `/usr/share/` | Package-managed system files |
| `$HOME/.local/bin/` | User-specific executables |
| `${XDG_DATA_HOME:-$HOME/.local/share}/` | User-specific data |
| `${XDG_CONFIG_HOME:-$HOME/.config}/` | User-specific config |

**FHS Search Pattern (Canonical):**
```bash
find_data_file() {
  local -- script_dir=$1
  local -- filename=$2
  local -a search_paths=(
    "$script_dir"/"$filename"  # Same directory (development)
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

# Installation paths (customizable via PREFIX)
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
declare -- LIB_DIR="$PREFIX"/lib/myapp
declare -- ETC_DIR="$PREFIX"/etc/myapp
declare -- MAN_DIR="$PREFIX"/share/man/man1
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR MAN_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR" "$MAN_DIR"
  install -m 755 "$SCRIPT_DIR"/myapp "$BIN_DIR"/myapp
  install -m 644 "$SCRIPT_DIR"/data/template.txt "$SHARE_DIR"/template.txt
  install -m 644 "$SCRIPT_DIR"/lib/common.sh "$LIB_DIR"/common.sh
  # Preserve existing config
  if [[ ! -f "$ETC_DIR"/myapp.conf ]]; then
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"
  fi
  install -m 644 "$SCRIPT_DIR"/docs/myapp.1 "$MAN_DIR"/myapp.1
  info "Installation complete to $PREFIX"
}

uninstall_files() {
  rm -f "$BIN_DIR"/myapp "$SHARE_DIR"/template.txt "$LIB_DIR"/common.sh "$MAN_DIR"/myapp.1
  rmdir --ignore-fail-on-non-empty "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR"
  info 'Uninstallation complete'
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
  local -- type=$1     # 'file' or 'dir'
  local -- name=$2     # Resource name
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
      *)    die 2 "Invalid resource type ${type@Q}" ;;
    esac
  done

  return 1
}
declare -fx find_resource

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

declare -- USER_DATA_DIR="$XDG_DATA_HOME"/myapp
declare -- USER_CONFIG_DIR="$XDG_CONFIG_HOME"/myapp
install -d "$USER_DATA_DIR" "$USER_CONFIG_DIR"
```

**Makefile Pattern:**
```makefile
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/myapp

install:
	install -d $(BINDIR) $(SHAREDIR)
	install -m 755 myapp $(BINDIR)/myapp
	install -m 644 data/template.txt $(SHAREDIR)/template.txt

# Usage: make install | make PREFIX=/usr install | make PREFIX=$HOME/.local install
```

**Anti-patterns:**
```bash
# ✗ Wrong - hardcoded absolute path
data_file=/home/user/projects/myapp/data/template.txt
# ✓ Correct - FHS search pattern
data_file=$(find_data_file template.txt)

# ✗ Wrong - assuming specific install location
source /usr/local/lib/myapp/common.sh
# ✓ Correct - search multiple FHS locations
load_library common.sh

# ✗ Wrong - using relative paths from CWD
source ../lib/common.sh  # Breaks when run from different directory
# ✓ Correct - paths relative to script location
source "$SCRIPT_DIR"/../lib/common.sh

# ✗ Wrong - not supporting PREFIX customization
BIN_DIR=/usr/local/bin  # Hardcoded
# ✓ Correct - respect PREFIX environment variable
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin"

# ✗ Wrong - overwriting user configuration on upgrade
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"
# ✓ Correct - preserve existing config
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge Cases:**

**1. PREFIX with trailing slash:**
```bash
PREFIX=${PREFIX:-/usr/local}
PREFIX=${PREFIX%/}  # Remove trailing slash if present
BIN_DIR="$PREFIX"/bin
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
# realpath resolves symlinks - SCRIPT_DIR points to actual install location
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
```

**When NOT to use FHS:**
- Single-user scripts
- Project-specific tools (build scripts, test runners)
- Container applications (Docker often uses `/app`)
- Embedded systems with custom layouts

**Summary:** FHS makes scripts portable, predictable, and package-manager compatible. Use PREFIX for custom installs, search multiple locations, separate file types by hierarchy, support XDG for user files, preserve user config on upgrades.
