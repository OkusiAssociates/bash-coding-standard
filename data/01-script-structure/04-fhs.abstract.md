## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search for resources—enables predictable locations, multi-environment support, and package manager compatibility.**

### Rationale
- Predictable file locations (`/usr/local/bin/`, `/usr/share/`)
- Eliminates hardcoded paths; supports PREFIX customization
- Works across dev, local, system, and user installs

### Key Locations
- `/usr/local/{bin,share,lib,etc}/` — local installs
- `/usr/{bin,share}/` — system (package manager)
- `$HOME/.local/{bin,share}/` — user installs
- `${XDG_CONFIG_HOME:-$HOME/.config}/` — user config

### FHS Search Pattern
```bash
find_data_file() {
  local -a paths=("$SCRIPT_DIR"/"$1" /usr/local/share/app/"$1" /usr/share/app/"$1")
  local p; for p in "${paths[@]}"; do [[ -f "$p" ]] && { echo "$p"; return 0; }; done
  return 1
}
```

### Anti-Patterns
- `source /usr/local/lib/app/x.sh` → Use FHS search function
- `BIN_DIR=/usr/local/bin` hardcoded → `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

### When NOT to Use
Single-user scripts, project-specific tools, containers with custom paths.

**Ref:** BCS0104
