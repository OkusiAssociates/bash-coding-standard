## Derived Variables

**Compute variables from base values; update all derivations when base changes during argument parsing.**

**Rationale:** DRY principle—single source of truth; automatic path updates when PREFIX changes; prevents subtle bugs from stale values.

**Core pattern:**

```bash
declare -- PREFIX=/usr/local
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
}

# Call after --prefix changes PREFIX
```

**XDG fallbacks:** `CONFIG_BASE=${XDG_CONFIG_HOME:-$HOME/.config}`

**Anti-patterns:**

```bash
# ✗ Duplicating values
BIN_DIR=/usr/local/bin     # Hardcoded, not derived!

# ✗ Not updating after base changes
PREFIX=$1                  # Changed but BIN_DIR still has old value!

# ✓ Always update derived variables
PREFIX=$1; update_derived_paths
```

**Rules:**
- Group with section comments explaining dependencies
- Make `readonly` only after all parsing complete
- Document hardcoded exceptions (e.g., `/etc/profile.d`)
- Consistent derivation—if one derives from APP_NAME, all should

**Ref:** BCS0209
