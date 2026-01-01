## FHS Compliance

**Follow Filesystem Hierarchy Standard for scripts that install files or search for resourcesâ€”enables predictable locations, multi-environment support, and package manager compatibility.**

**Key rationale:** Eliminates hardcoded paths; scripts work across dev/local/system installs without modification.

**Standard locations:** `/usr/local/bin/` (executables), `/usr/local/share/` (data), `/usr/local/lib/` (libraries), `/usr/local/etc/` (config), `${XDG_DATA_HOME:-$HOME/.local/share}/` (user data)

**FHS search pattern:**
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

**PREFIX pattern:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
```

**Anti-patterns:**
- `source /usr/local/lib/myapp/common.sh` â†' hardcoded path breaks portability
- `BIN_DIR=/usr/local/bin` â†' use `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

**Skip FHS:** Single-user scripts, project-specific tools, containers

**Ref:** BCS0104
