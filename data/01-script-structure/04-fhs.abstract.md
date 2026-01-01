## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search for resourcesâ€”enables predictable locations, multi-environment support, and package manager compatibility.**

**Key rationale:** Eliminates hardcoded paths; works in dev/local/system install modes; XDG support for user files.

**FHS locations:** `/usr/local/{bin,share,lib,etc}/` (local install) â†' `/usr/{bin,share}/` (system) â†' `$HOME/.local/{bin,share}/` (user) â†' `${XDG_CONFIG_HOME:-$HOME/.config}/` (user config)

**Core patternâ€”FHS search:**
```bash
find_data_file() {
  local -- filename=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/"$filename"                              # Development
    /usr/local/share/myapp/"$filename"                     # Local install
    /usr/share/myapp/"$filename"                           # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$filename"  # User
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**PREFIX pattern:** `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin` â†' supports `make PREFIX=/usr install`

**Anti-patterns:**
- `source /usr/local/lib/myapp/common.sh` â†' hardcoded path breaks portability
- `install myapp /opt/random/` â†' non-FHS location, breaks package managers

**When NOT to use:** Single-user scripts, project-specific tools, containers with `/app`

**Ref:** BCS0104
