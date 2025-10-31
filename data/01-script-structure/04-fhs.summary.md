## Filesystem Hierarchy Standard (FHS) Preference

**Follow FHS for scripts that install files or search for resources. FHS enables predictable locations, supports multiple installation types, and integrates with package managers.**

**Rationale:** Predictable locations users expect, works in development/local/system/user scenarios, eliminates hardcoded paths, portable across distributions with PREFIX customization.

**Common locations:**
- `/usr/local/{bin,share,lib,etc}` - User-installed (system-wide)
- `/usr/{bin,share}` - System (package manager)
- `$HOME/.local/{bin,share}` - User-specific
- `${XDG_CONFIG_HOME:-$HOME/.config}` - User config

**Search pattern:**
```bash
find_data_file() {
  local -- script_dir="$1" filename="$2"
  local -a search_paths=(
    "$script_dir/$filename"
    /usr/local/share/myapp/"$filename"
    /usr/share/myapp/"$filename"
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**Installation script:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- PREFIX="${PREFIX:-/usr/local}"
declare -- BIN_DIR="$PREFIX/bin"
declare -- SHARE_DIR="$PREFIX/share/myapp"
declare -- LIB_DIR="$PREFIX/lib/myapp"
declare -- ETC_DIR="$PREFIX/etc/myapp"
declare -- MAN_DIR="$PREFIX/share/man/man1"
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR ETC_DIR MAN_DIR

install_files() {
  install -d "$BIN_DIR" "$SHARE_DIR" "$LIB_DIR" "$ETC_DIR" "$MAN_DIR"
  install -m 755 "$SCRIPT_DIR/myapp" "$BIN_DIR/myapp"
  install -m 644 "$SCRIPT_DIR/data/template.txt" "$SHARE_DIR/template.txt"
  install -m 644 "$SCRIPT_DIR/lib/common.sh" "$LIB_DIR/common.sh"
  [[ -f "$ETC_DIR/myapp.conf" ]] || \
    install -m 644 "$SCRIPT_DIR/myapp.conf.example" "$ETC_DIR/myapp.conf"
  install -m 644 "$SCRIPT_DIR/docs/myapp.1" "$MAN_DIR/myapp.1"
}

uninstall_files() {
  rm -f "$BIN_DIR/myapp" "$SHARE_DIR/template.txt" "$LIB_DIR/common.sh" "$MAN_DIR/myapp.1"
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

**Resource loading:**

```bash
find_data_file() {
  local -- filename="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/$filename"
    "/usr/local/share/myapp/$filename"
    "/usr/share/myapp/$filename"
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  die 2 "Data file not found: $filename"
}

find_config_file() {
  local -- filename="$1"
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/myapp/$filename"
    "/usr/local/etc/myapp/$filename"
    "/etc/myapp/$filename"
    "$SCRIPT_DIR/$filename"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}

load_library() {
  local -- lib_name="$1"
  local -a search_paths=(
    "$SCRIPT_DIR/lib/$lib_name"
    "/usr/local/lib/myapp/$lib_name"
    "/usr/lib/myapp/$lib_name"
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { source "$path"; return 0; }
  done
  die 2 "Library not found: $lib_name"
}
```

**Makefile:**

```bash
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/myapp
MANDIR = $(PREFIX)/share/man/man1

install:
	install -d $(BINDIR) $(SHAREDIR) $(MANDIR)
	install -m 755 myapp $(BINDIR)/myapp
	install -m 644 data/template.txt $(SHAREDIR)/template.txt
	install -m 644 docs/myapp.1 $(MANDIR)/myapp.1

uninstall:
	rm -f $(BINDIR)/myapp $(SHAREDIR)/template.txt $(MANDIR)/myapp.1
```

**XDG support:**

```bash
declare -- XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

declare -- USER_DATA_DIR="$XDG_DATA_HOME/myapp"
declare -- USER_CONFIG_DIR="$XDG_CONFIG_HOME/myapp"

install -d "$USER_DATA_DIR" "$USER_CONFIG_DIR"
```

**Production template (from bcs):**

```bash
find_bcs_file() {
  local -- script_dir=$1
  local -- install_share="${script_dir%/bin}/share/yatti/bash-coding-standard"
  local -a search_paths=(
    "$script_dir"
    "$install_share"
    /usr/local/share/yatti/bash-coding-standard
    /usr/share/yatti/bash-coding-standard
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path"/BASH-CODING-STANDARD.md ]] && \
      { echo "$path"/BASH-CODING-STANDARD.md; return 0; }
  done
  return 1
}
declare -fx find_bcs_file
```

**Key features:** `install_share` calculation `${script_dir%/bin}/share/...`, four search locations, early return, works in dev/PREFIX/local/system.

**Find directory:**

```bash
find_data_dir() {
  local -- install_share="${BCS_DIR%/bin}/share/yatti/bash-coding-standard/data"
  local -a search_paths=(
    "$BCS_DIR/data"
    "$install_share"
    /usr/local/share/yatti/bash-coding-standard/data
    /usr/share/yatti/bash-coding-standard/data
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -d "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**Generic finder:**

```bash
find_resource() {
  local -- type=$1 name=$2
  local -- install_base="${SCRIPT_DIR%/bin}/share/myorg/myproject"
  local -a search_paths=(
    "$SCRIPT_DIR"
    "$install_base"
    /usr/local/share/myorg/myproject
    /usr/share/myorg/myproject
  )

  local -- path
  for path in "${search_paths[@]}"; do
    local -- resource="$path/$name"
    case "$type" in
      file) [[ -f "$resource" ]] && { echo "$resource"; return 0; } ;;
      dir)  [[ -d "$resource" ]] && { echo "$resource"; return 0; } ;;
      *)    die 2 "Invalid type ${type@Q}" ;;
    esac
  done
  return 1
}

# Usage: CONFIG=$(find_resource file config.yml) || die 'Not found'
```

**Anti-patterns:**

```bash
# ✗ Hardcoded path
data_file='/home/user/projects/myapp/data/template.txt'
# ✓ FHS search
data_file=$(find_data_file 'template.txt')

# ✗ Assuming location
source /usr/local/lib/myapp/common.sh
# ✓ Search
load_library 'common.sh'

# ✗ Relative from CWD
source ../lib/common.sh
# ✓ Relative to script
source "$SCRIPT_DIR/../lib/common.sh"

# ✗ No PREFIX support
BIN_DIR=/usr/local/bin
# ✓ PREFIX
PREFIX="${PREFIX:-/usr/local}"; BIN_DIR="$PREFIX/bin"

# ✗ Overwrite config
install myapp.conf "$PREFIX/etc/myapp/myapp.conf"
# ✓ Preserve
[[ -f "$PREFIX/etc/myapp/myapp.conf" ]] || \
  install myapp.conf.example "$PREFIX/etc/myapp/myapp.conf"
```

**Edge cases:**

```bash
# PREFIX trailing slash
PREFIX="${PREFIX:-/usr/local}"
PREFIX="${PREFIX%/}"

# Permission check
[[ -w "$PREFIX" ]] || die 5 "No write permission. Try: PREFIX=\$HOME/.local make install"
```

**When NOT to use:** Single-user scripts, project-specific tools staying in project directory, containers using `/app`, embedded systems with custom layouts.

**Summary:** Use FHS for system-wide/distributed scripts. PREFIX for custom locations. Search multiple locations. Separate by type (bin/share/etc/lib). Support XDG. Preserve user config. Make PREFIX customizable.
