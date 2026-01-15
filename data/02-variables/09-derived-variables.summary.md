## Derived Variables

**Variables computed from other variables for paths, configurations, or composite values. Group with section comments explaining dependencies. Update all derived variables when base variables change (especially during argument parsing).**

**Rationale:**
- DRY Principle: Single source of truth for base values
- Consistency: When PREFIX changes, all paths update automatically
- Clarity: Section comments make variable relationships obvious
- Correctness: Updating derived variables when base changes prevents subtle bugs

**Simple derived variables:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

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

**XDG Base Directory compliance:**

```bash
# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-"$HOME"/.config}
declare -- CONFIG_DIR="$CONFIG_BASE"/"$APP_NAME"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE=${XDG_DATA_HOME:-"$HOME"/.local/share}
declare -- DATA_DIR="$DATA_BASE"/"$APP_NAME"

# XDG_STATE_HOME with fallback to $HOME/.local/state (for logs)
declare -- STATE_BASE=${XDG_STATE_HOME:-"$HOME"/.local/state}
declare -- LOG_DIR="$STATE_BASE"/"$APP_NAME"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE=${XDG_CACHE_HOME:-"$HOME"/.cache}
declare -- CACHE_DIR="$CACHE_BASE"/"$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib/"$APP_NAME"
  SHARE_DIR="$PREFIX"/share/"$APP_NAME"
  DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
  info "Updated paths for PREFIX=${PREFIX@Q}"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"; shift
        PREFIX=$1
        # IMPORTANT: Update all derived paths when PREFIX changes
        update_derived_paths
        ;;
      --app-name)
        noarg "$@"; shift
        APP_NAME=$1
        # DOC_DIR depends on APP_NAME, update it
        DOC_DIR="$PREFIX"/share/doc/"$APP_NAME"
        ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR SHARE_DIR DOC_DIR
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
declare -- CONFIG_DIR=/etc/"$APP_NAME"/"$ENVIRONMENT"
declare -- CONFIG_FILE="$CONFIG_DIR"/config-"$REGION".conf

# Derived URLs
declare -- API_HOST=api-"$ENVIRONMENT".example.com
declare -- API_URL="https://$API_HOST/v1"
```

**Anti-patterns:**

```bash
# ✗ Wrong - duplicating values instead of deriving
PREFIX=/usr/local
BIN_DIR=/usr/local/bin        # Duplicates PREFIX!

# ✓ Correct - derive from base value
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin           # Derived from PREFIX

# ✗ Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      shift
      PREFIX=$1
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

# ✓ Correct - update derived variables
main() {
  case $1 in
    --prefix)
      noarg "$@"; shift
      PREFIX=$1
      BIN_DIR="$PREFIX"/bin     # Update derived
      LIB_DIR="$PREFIX"/lib     # Update derived
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
LOG_DIR=/var/log/"$APP_NAME"           # Derived from APP_NAME

# ✓ Correct - consistent derivation
CONFIG_DIR=/etc/"$APP_NAME"            # Derived
LOG_DIR=/var/log/"$APP_NAME"           # Derived
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

**3. Platform-specific derivations:**

```bash
case "$(uname -s)" in
  Darwin)
    LIB_EXT=dylib
    CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME"
    ;;
  Linux)
    LIB_EXT=so
    CONFIG_DIR="$HOME"/.config/"$APP_NAME"
    ;;
esac

LIBRARY_NAME=lib"$APP_NAME"."$LIB_EXT"
```

**Summary:**
- Group derived variables with section comments explaining dependencies
- Derive from base values - never duplicate, always compute
- Update when base changes - especially during argument parsing
- Document hardcoded exceptions that don't derive
- Use `${XDG_VAR:-$HOME/default}` pattern for environment fallbacks
- Make readonly after all parsing and derivation complete
- Clear dependency chain: base �' derived1 �' derived2
