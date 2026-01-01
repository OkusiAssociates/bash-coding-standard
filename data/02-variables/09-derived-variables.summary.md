## Derived Variables

**Derived variables are computed from base variables for paths, configurations, or composite values. Group them with section comments explaining dependencies. When base variables change (especially during argument parsing), update all derived variables.**

**Rationale:**
- **DRY Principle**: Single source of truth for base values
- **Consistency**: When PREFIX changes, all paths update automatically
- **Maintainability**: One place to change, derivations update automatically
- **Correctness**: Updating derived variables when base changes prevents subtle bugs

**Simple derived variables:**

```bash
# ============================================================================
# Configuration - Base Values
# ============================================================================

declare -- PREFIX=/usr/local
declare -- APP_NAME=myapp

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

# All paths derived from PREFIX
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"

# Application-specific derived paths
declare -- CONFIG_DIR="$HOME"/."$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf
declare -- CACHE_DIR="$HOME"/.cache/"$APP_NAME"
```

**XDG Base Directory with fallbacks:**

```bash
# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-$HOME/.config}
declare -- CONFIG_DIR="$CONFIG_BASE"/"$APP_NAME"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE=${XDG_DATA_HOME:-$HOME/.local/share}
declare -- DATA_DIR="$DATA_BASE"/"$APP_NAME"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE=${XDG_CACHE_HOME:-$HOME/.cache}
declare -- CACHE_DIR="$CACHE_BASE"/"$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX=/usr/local
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
declare -- DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"

# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
  info "Updated paths for PREFIX=${PREFIX@Q}"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"
        shift
        PREFIX=$1
        # IMPORTANT: Update all derived paths when PREFIX changes
        update_derived_paths
        ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR DOC_DIR
}
```

**Complex derivations with multiple dependencies:**

```bash
declare -- ENVIRONMENT=production
declare -- REGION=us-east
declare -- APP_NAME=myapp

# Composite identifiers derived from base values
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# Paths that depend on environment
declare -- CONFIG_DIR="/etc/$APP_NAME/$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR/config-$REGION.conf"

# Derived URLs
declare -- API_HOST="api-$ENVIRONMENT.example.com"
declare -- API_URL="https://$API_HOST/v1"
```

**Anti-patterns:**

```bash
# ✗ Wrong - duplicating values instead of deriving
PREFIX=/usr/local
BIN_DIR=/usr/local/bin        # Duplicates PREFIX!

# ✓ Correct - derive from base value
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin

# ✗ Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      PREFIX=$1
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

# ✓ Correct - update derived variables
main() {
  case $1 in
    --prefix)
      PREFIX=$1
      BIN_DIR="$PREFIX"/bin     # Update derived
      ;;
  esac
}

# ✗ Wrong - making derived variables readonly before base
BIN_DIR="$PREFIX"/bin
readonly -- BIN_DIR             # Can't update if PREFIX changes!
PREFIX=/usr/local

# ✓ Correct - make readonly after all values set
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
# Parse arguments that might change PREFIX...
readonly -- PREFIX BIN_DIR      # Now make readonly

# ✗ Wrong - inconsistent derivation
CONFIG_DIR=/etc/myapp                  # Hardcoded
LOG_DIR=/var/log/"$APP_NAME"           # Derived
# Inconsistent - either both derived or both hardcoded!

# ✓ Correct - consistent derivation
CONFIG_DIR=/etc/"$APP_NAME"
LOG_DIR=/var/log/"$APP_NAME"

# ✗ Wrong - circular dependency
VAR1="$VAR2"
VAR2="$VAR1"                           # Circular!

# ✓ Correct - clear dependency chain
BASE='value'
DERIVED1="$BASE"/path1
DERIVED2="$BASE"/path2
```

**Edge cases:**

**1. Conditional derivation:**

```bash
# Different paths for development vs production
if [[ "$ENVIRONMENT" == development ]]; then
  CONFIG_DIR="$SCRIPT_DIR"/config
  LOG_DIR="$SCRIPT_DIR"/logs
else
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
fi

# Derived from environment-specific directories
CONFIG_FILE="$CONFIG_DIR"/config.conf
```

**2. Hardcoded exceptions:**

```bash
# Most paths derived from PREFIX
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR=/etc/profile.d           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR"/"$APP_NAME".sh
```

**3. Multiple update functions:**

```bash
update_prefix_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
}

update_app_paths() {
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
}

update_all_derived() {
  update_prefix_paths
  update_app_paths
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}
```

**Summary:**
- **Group derived variables** with section comments explaining dependencies
- **Derive from base values** - never duplicate, always compute
- **Update when base changes** - especially during argument parsing
- **Document hardcoded exceptions** - explain why they don't derive
- **Consistent derivation** - if one path derives from APP_NAME, all should
- **Environment fallbacks** - use `${XDG_VAR:-$HOME/default}` pattern
- **Make readonly last** - after all parsing and derivation complete
- **Clear dependency chain** - base �' derived1 �' derived2
