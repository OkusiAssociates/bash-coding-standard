## Derived Variables

**Compute variables from base values; group with section comments; update derived when base changes (especially during argument parsing).**

**Rationale:** DRY principle (single source of truth) â†' consistency when PREFIX changes â†' prevents subtle bugs from stale derived values.

**Core pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived from PREFIX and APP_NAME
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf

# XDG fallback pattern
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-"$HOME"/.config}
```

**Update function when base changes:**

```bash
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}

# In argument parsing:
--prefix) shift; PREFIX=$1; update_derived_paths ;;
```

**Anti-patterns:**

```bash
# âœ— Duplicating values instead of deriving
BIN_DIR=/usr/local/bin   # â†' BIN_DIR="$PREFIX"/bin

# âœ— Not updating derived when base changes
PREFIX=$1  # BIN_DIR now wrong! â†' call update_derived_paths

# âœ— Making readonly before parsing complete
readonly BIN_DIR  # â†' readonly after all parsing done
```

**Key rules:**
- Group derived vars with `# Derived from PREFIX` comments
- Update ALL derived vars when any base changes
- Make readonly AFTER argument parsing complete
- Document hardcoded exceptions (e.g., `/etc/profile.d` fixed path)

**Ref:** BCS0209
