## Filesystem Hierarchy Standard (FHS) Preference

**Scripts installing files or searching resources should follow FHS for predictable locations, multi-environment support, and package manager compatibility.**

**Rationale:** Predictable paths users/package managers expect; works across dev/local/system/user installs; eliminates hardcoded paths.

**Locations:**
- `/usr/local/{bin,share}` - User-installed system-wide
- `/usr/{bin,share}` - System (package manager)
- `$HOME/.local/{bin,share}` - User-specific
- `${XDG_CONFIG_HOME:-$HOME/.config}` - User config

**Search pattern:**
```bash
find_data() {
  local -a paths=(
    "$SCRIPT_DIR/$1"                                      # Dev
    /usr/local/share/myapp/"$1"                           # Local
    /usr/share/myapp/"$1"                                 # System
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$1"       # User
  )
  local -- p
  for p in "${paths[@]}"; do
    [[ -f "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}
```

**PREFIX customization:**
```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/myapp"
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Anti-patterns:** Hardcoded paths → FHS search; Fixed install location → `PREFIX="$PREFIX/bin"`; Relative `source ../lib/` → Breaks from different CWD; Overwrite config → Check first `[[ -f "$cfg" ]] || install`

**Skip when:** Single-user scripts, project-specific tools, containers, embedded systems.

**Ref:** BCS0104
