## Derived Variables

**Compute variables from base values; update all derivations when base changes.**

**Rationale:** DRY principle—single source of truth; automatic consistency when PREFIX changes; prevents subtle bugs from stale derived values.

**Pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived from PREFIX
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib/"$APP_NAME"

# Update function for arg parsing
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib/"$APP_NAME"
}

# After --prefix changes: update_derived_paths
# Make readonly AFTER all parsing complete
readonly -- PREFIX BIN_DIR LIB_DIR
```

**XDG fallbacks:** `CONFIG_BASE=${XDG_CONFIG_HOME:-$HOME/.config}`

**Anti-patterns:**

```bash
# ✗ Duplicating base value
BIN_DIR=/usr/local/bin  # Hardcoded, not derived!

# ✗ Not updating after base changes
PREFIX=$1  # BIN_DIR now stale!

# ✗ Readonly before parsing complete
readonly -- BIN_DIR  # Can't update later!
```

**Key rules:**
- Group derived vars with section comments
- Update ALL derivations when base changes
- `readonly` only after parsing complete
- Document hardcoded exceptions

**Ref:** BCS0209
