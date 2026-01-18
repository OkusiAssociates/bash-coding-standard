## Derived Variables

**Compute variables from base values; group with section comments; update derived vars when base changes.**

**Rationale:**
- DRY: Single source of truth—change PREFIX once, all paths update
- Correctness: Forgetting to update derived vars after base changes causes subtle bugs

**Pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived paths (update these when base changes)
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf

# Update function for argument parsing
update_derived() {
  BIN_DIR="$PREFIX"/bin
  CONFIG_DIR=/etc/"$APP_NAME"
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}
```

**Anti-patterns:**

```bash
# ✗ Duplicating instead of deriving
BIN_DIR=/usr/local/bin  # Hardcoded, won't update with PREFIX

# ✗ Not updating derived vars when base changes
--prefix) PREFIX=$1 ;;  # BIN_DIR now wrong!

# ✓ Always update derived vars
--prefix) PREFIX=$1; update_derived ;;
```

**Key rules:**
- Group derived vars with `# Derived from PREFIX` comments
- Use `update_derived()` function when multiple vars need updating
- Make readonly AFTER all parsing complete
- XDG fallbacks: `${XDG_CONFIG_HOME:-"$HOME"/.config}`

**Ref:** BCS0209
