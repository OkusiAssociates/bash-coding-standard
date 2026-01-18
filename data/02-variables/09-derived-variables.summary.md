## Derived Variables

**Variables computed from other variables for paths, configurations, or composite values. Group with section comments explaining dependencies. When base variables change (especially during argument parsing), update all derived variables.**

**Rationale:**
- DRY Principle: Single source of truth for base values, derived everywhere else
- Consistency: When PREFIX changes, all paths update automatically
- Maintainability: One place to change base value, derivations update automatically
- Correctness: Updating derived variables when base changes prevents subtle bugs

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
declare -- SHARE_DIR="$PREFIX"/share
declare -- DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"

# Application-specific derived paths
declare -- CONFIG_DIR="$HOME"/."$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf
declare -- CACHE_DIR="$HOME"/.cache/"$APP_NAME"
declare -- DATA_DIR="$HOME"/.local/share/"$APP_NAME"
```

**Derived paths with XDG environment fallbacks:**

```bash
declare -- APP_NAME=myapp

# XDG Base Directory Specification with fallbacks
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-"$HOME"/.config}
declare -- CONFIG_DIR="$CONFIG_BASE"/"$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf

declare -- DATA_BASE=${XDG_DATA_HOME:-"$HOME"/.local/share}
declare -- DATA_DIR="$DATA_BASE"/"$APP_NAME"

declare -- STATE_BASE=${XDG_STATE_HOME:-"$HOME"/.local/state}
declare -- LOG_DIR="$STATE_BASE"/"$APP_NAME"

declare -- CACHE_BASE=${XDG_CACHE_HOME:-"$HOME"/.cache}
declare -- CACHE_DIR="$CACHE_BASE"/"$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX=/usr/local
declare -- APP_NAME=myapp

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
        noarg "$@"; shift
        PREFIX=$1
        update_derived_paths  # IMPORTANT: Update when base changes
        ;;
      --app-name)
        noarg "$@"; shift
        APP_NAME=$1
        DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"  # Update dependent
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
declare -- NAMESPACE=default

# Composite identifiers derived from base values
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- RESOURCE_PREFIX="$NAMESPACE-$APP_NAME"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# Paths that depend on environment
declare -- CONFIG_DIR=/etc/"$APP_NAME"/"$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR"/config-"$REGION".conf
declare -- PID_FILE=/var/run/"$DEPLOYMENT_ID".pid

# Derived URLs
declare -- API_HOST=api-"$ENVIRONMENT".example.com
declare -- API_URL="https://$API_HOST/v1"
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - duplicating values instead of deriving
PREFIX=/usr/local
BIN_DIR=/usr/local/bin        # Duplicates PREFIX!

# ✓ Correct - derive from base value
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin           # Derived from PREFIX

# ✗ Wrong - not updating derived variables when base changes
case $1 in --prefix) PREFIX=$1 ;; esac  # BIN_DIR now wrong!

# ✓ Correct - update derived variables
case $1 in --prefix) PREFIX=$1; BIN_DIR="$PREFIX"/bin ;; esac

# ✗ Wrong - making derived readonly before base is finalized
BIN_DIR="$PREFIX"/bin
readonly -- BIN_DIR             # Can't update if PREFIX changes!
PREFIX=/usr/local

# ✓ Correct - make readonly after all values set
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR      # After parsing complete

# ✗ Wrong - inconsistent derivation
CONFIG_DIR=/etc/myapp                  # Hardcoded
LOG_DIR=/var/log/"$APP_NAME"           # Derived - inconsistent!

# ✓ Correct - consistent derivation
CONFIG_DIR=/etc/"$APP_NAME"            # Both derived
LOG_DIR=/var/log/"$APP_NAME"

# ✗ Wrong - complex derivation without comments
DEPLOYMENT="$ENV"-"$REGION"-"$APP"-"$VERSION"-"$COMMIT"

# ✓ Correct - explain complex derivation
# Deployment ID format: environment-region-app-version-commit
DEPLOYMENT="$ENV"-"$REGION"-"$APP"-"$VERSION"-"$COMMIT"
```

**Edge cases:**

**1. Conditional derivation (dev vs prod):**

```bash
if [[ "$ENVIRONMENT" == development ]]; then
  CONFIG_DIR="$SCRIPT_DIR"/config
  LOG_DIR="$SCRIPT_DIR"/logs
else
  CONFIG_DIR=/etc/"$APP_NAME"
  LOG_DIR=/var/log/"$APP_NAME"
fi
CONFIG_FILE="$CONFIG_DIR"/config.conf  # Derived from conditional
```

**2. Platform-specific derivations:**

```bash
case "$(uname -s)" in
  Darwin) LIB_EXT=dylib; CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME" ;;
  Linux)  LIB_EXT=so;    CONFIG_DIR="$HOME"/.config/"$APP_NAME" ;;
esac
LIBRARY_NAME=lib"$APP_NAME"."$LIB_EXT"
CONFIG_FILE="$CONFIG_DIR"/config.conf
```

**3. Hardcoded exceptions with documentation:**

```bash
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
LIB_DIR="$PREFIX"/lib

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR=/etc/profile.d           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR"/"$APP_NAME".sh
```

**Summary:**
- Group derived variables with section comments explaining dependencies
- Derive from base values - never duplicate, always compute
- Update when base changes - especially during argument parsing
- Document special cases - explain hardcoded values that don't derive
- Use `${XDG_VAR:-$HOME/default}` pattern for environment fallbacks
- Make readonly last - after all parsing and derivation complete
- Clear dependency chain: base → derived1 → derived2
- Centralize derivation logic in update functions when many variables
