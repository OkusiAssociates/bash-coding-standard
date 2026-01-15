## FHS Preference

**Follow Filesystem Hierarchy Standard for predictable file locations, multi-environment support, and package manager compatibility.**

**Key locations:** `/usr/local/{bin,share,lib,etc}` (local install) â†' `/usr/{bin,share}` (system) â†' `$HOME/.local/{bin,share}` (user) â†' `${XDG_CONFIG_HOME:-$HOME/.config}` (user config)

**Rationale:** Predictable paths for users/package managers; no hardcoded paths; portable across distros.

**FHS search pattern:**
```bash
find_data_file() {
  local -a search_paths=(
    "$SCRIPT_DIR"/"$1"                    # Development
    /usr/local/share/myapp/"$1"           # Local install
    /usr/share/myapp/"$1"                 # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$1"
  )
  local -- path; for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done; return 1
}
```

**Anti-patterns:**
- `data=/home/user/myapp/data.txt` â†' use FHS search
- `source /usr/local/lib/myapp/common.sh` â†' search multiple locations
- `BIN_DIR=/usr/local/bin` â†' use `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

**When NOT FHS:** Single-user scripts, project-specific tools, containers, embedded systems.

**Ref:** BCS0104
