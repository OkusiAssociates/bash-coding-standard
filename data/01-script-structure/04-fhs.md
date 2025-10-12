### Filesystem Hierarchy Standard (FHS) Preference

When designing scripts that install files, search for data files, or integrate with the system, prefer following the Filesystem Hierarchy Standard (FHS) where practical. This is a guideline, not a mandatory requirement.

**Common FHS locations:**
- `/usr/local/bin/` - User-installed executables (system-wide, not managed by package manager)
- `/usr/local/share/` - Architecture-independent data files
- `/usr/local/lib/` - Libraries and loadable modules
- `/usr/local/etc/` - Configuration files
- `/usr/bin/` - System executables (managed by package manager)
- `/usr/share/` - System-wide architecture-independent data
- `$HOME/.local/bin/` - User-specific executables (in user's PATH)
- `$HOME/.local/share/` - User-specific data files
- `${XDG_CONFIG_HOME:-$HOME/.config}/` - User-specific configuration

**When FHS is useful:**
- Installation scripts that need to place files in standard locations
- Scripts that search for data files in multiple standard locations
- Scripts that support both system-wide and user-specific installation
- Projects distributed to multiple systems expecting standard paths

**Example pattern - searching for data files:**
```bash
find_data_file() {
  local -- script_dir="$1"
  local -- filename="$2"
  local -a search_paths=(
    "$script_dir"/"$filename"  # Same directory (development)
    /usr/local/share/myapp/"$filename" # Local install
    /usr/share/myapp/"$filename" # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$filename"  # User install
  )

  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done

  return 1
}
```

**Real-world example:**
The `bash-coding-standard` script in this repository follows FHS by searching for `BASH-CODING-STANDARD.md` in:
1. Development location (same directory as script)
2. `/usr/local/share/yatti/bash-coding-standard/` (local FHS-compliant install)
3. `/usr/share/yatti/bash-coding-standard/` (system FHS-compliant install)

This approach allows the script to work in development mode, after `make install`, or when installed by a package manager, without modification.
