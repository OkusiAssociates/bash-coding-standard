## Derived Variables

**Derived variables are computed from base variables for paths, configurations, or composite values. Group them with section comments explaining dependencies, document hardcoded exceptions, and update all derived variables when base values change (especially during argument parsing).**

**Rationale:**

- **DRY Principle**: Single source of truth - change base value once, all derivations update automatically
- **Consistency**: When PREFIX changes, all dependent paths update together
- **Clarity**: Section comments make variable relationships explicit
- **Correctness**: Updating derived variables when base changes prevents subtle bugs where variables become desynchronized

**Simple derived variables:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# ============================================================================
# Configuration - Base Values
# ============================================================================

declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

# All paths derived from PREFIX
declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- SHARE_DIR="$PREFIX/share"
declare -- DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Application-specific derived paths
declare -- CONFIG_DIR="$HOME/.$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"
declare -- CACHE_DIR="$HOME/.cache/$APP_NAME"
declare -- DATA_DIR="$HOME/.local/share/$APP_NAME"

main() {
  echo "Installation prefix: $PREFIX"
  echo "Binaries: $BIN_DIR"
  echo "Libraries: $LIB_DIR"
  echo "Documentation: $DOC_DIR"
}

main "$@"

#fin
```

**XDG Base Directory support with environment fallbacks:**

```bash
declare -- APP_NAME='myapp'

# XDG_CONFIG_HOME with fallback to $HOME/.config
declare -- CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
declare -- CONFIG_DIR="$CONFIG_BASE/$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"

# XDG_DATA_HOME with fallback to $HOME/.local/share
declare -- DATA_BASE="${XDG_DATA_HOME:-$HOME/.local/share}"
declare -- DATA_DIR="$DATA_BASE/$APP_NAME"

# XDG_STATE_HOME with fallback to $HOME/.local/state (for logs)
declare -- STATE_BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
declare -- LOG_DIR="$STATE_BASE/$APP_NAME"
declare -- LOG_FILE="$LOG_DIR/app.log"

# XDG_CACHE_HOME with fallback to $HOME/.cache
declare -- CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
declare -- CACHE_DIR="$CACHE_BASE/$APP_NAME"
```

**Updating derived variables when base changes:**

```bash
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- SHARE_DIR="$PREFIX/share"
declare -- MAN_DIR="$PREFIX/share/man"
declare -- DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Update all derived paths when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"
  MAN_DIR="$PREFIX/share/man"
  DOC_DIR="$PREFIX/share/doc/$APP_NAME"

  info "Updated paths for PREFIX=$PREFIX"
}

main() {
  while (($#)); do
    case $1 in
      --prefix)
        noarg "$@"
        shift
        PREFIX="$1"
        # IMPORTANT: Update all derived paths when PREFIX changes
        update_derived_paths
        ;;

      --app-name)
        noarg "$@"
        shift
        APP_NAME="$1"
        # DOC_DIR depends on APP_NAME, update it
        DOC_DIR="$PREFIX/share/doc/$APP_NAME"
        ;;

      *) die 22 "Invalid argument: $1" ;;
    esac
    shift
  done

  # Make variables readonly after parsing
  readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR SHARE_DIR MAN_DIR DOC_DIR
}
```

**Complex derivations with multiple dependencies:**

```bash
declare -- ENVIRONMENT='production'
declare -- REGION='us-east'
declare -- APP_NAME='myapp'
declare -- NAMESPACE='default'

# ============================================================================
# Configuration - Derived Identifiers
# ============================================================================

# Composite identifiers derived from base values
declare -- DEPLOYMENT_ID="$APP_NAME-$ENVIRONMENT-$REGION"
declare -- RESOURCE_PREFIX="$NAMESPACE-$APP_NAME"
declare -- LOG_PREFIX="$ENVIRONMENT/$REGION/$APP_NAME"

# ============================================================================
# Configuration - Derived Paths
# ============================================================================

declare -- CONFIG_DIR="/etc/$APP_NAME/$ENVIRONMENT"
declare -- LOG_DIR="/var/log/$APP_NAME/$ENVIRONMENT"
declare -- DATA_DIR="/var/lib/$APP_NAME/$ENVIRONMENT"

# Files derived from directories and identifiers
declare -- CONFIG_FILE="$CONFIG_DIR/config-$REGION.conf"
declare -- LOG_FILE="$LOG_DIR/$APP_NAME-$REGION.log"
declare -- PID_FILE="/var/run/$DEPLOYMENT_ID.pid"

# ============================================================================
# Configuration - Derived URLs
# ============================================================================

declare -- API_HOST="api-$ENVIRONMENT.example.com"
declare -- API_URL="https://$API_HOST/v1"
declare -- METRICS_URL="https://metrics-$REGION.example.com/$APP_NAME"
```

**Anti-patterns to avoid:**

```bash
#  Wrong - duplicating values instead of deriving
PREFIX='/usr/local'
BIN_DIR='/usr/local/bin'        # Duplicates PREFIX!
LIB_DIR='/usr/local/lib'

#  Correct - derive from base value
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"

#  Wrong - not updating derived variables when base changes
main() {
  case $1 in
    --prefix)
      shift
      PREFIX="$1"
      # BIN_DIR and LIB_DIR are now wrong!
      ;;
  esac
}

#  Correct - update derived variables
main() {
  case $1 in
    --prefix)
      shift
      PREFIX="$1"
      BIN_DIR="$PREFIX/bin"     # Update derived
      LIB_DIR="$PREFIX/lib"
      ;;
  esac
}

#  Wrong - making derived variables readonly before base
BIN_DIR="$PREFIX/bin"
readonly -- BIN_DIR             # Can't update if PREFIX changes!
PREFIX='/usr/local'

#  Correct - make readonly after all values set
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
# Parse arguments that might change PREFIX...
readonly -- PREFIX BIN_DIR

#  Wrong - inconsistent derivation
CONFIG_DIR='/etc/myapp'                  # Hardcoded
LOG_DIR="/var/log/$APP_NAME"             # Derived from APP_NAME

#  Correct - consistent derivation
CONFIG_DIR="/etc/$APP_NAME"
LOG_DIR="/var/log/$APP_NAME"

#  Wrong - circular dependency
VAR1="$VAR2"
VAR2="$VAR1"                             # Circular!

#  Correct - clear dependency chain
BASE='value'
DERIVED1="$BASE/path1"
DERIVED2="$BASE/path2"
```

**Edge cases:**

**1. Conditional derivation:**

```bash
# Different paths for development vs production
if [[ "$ENVIRONMENT" == 'development' ]]; then
  CONFIG_DIR="$SCRIPT_DIR/config"
  LOG_DIR="$SCRIPT_DIR/logs"
else
  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
fi

# Derived from environment-specific directories
CONFIG_FILE="$CONFIG_DIR/config.conf"
LOG_FILE="$LOG_DIR/app.log"
```

**2. Platform-specific derivations:**

```bash
# Detect platform
case "$(uname -s)" in
  Darwin)
    LIB_EXT='dylib'
    CONFIG_DIR="$HOME/Library/Application Support/$APP_NAME"
    ;;
  Linux)
    LIB_EXT='so'
    CONFIG_DIR="$HOME/.config/$APP_NAME"
    ;;
  *)
    die 1 'Unsupported platform'
    ;;
esac

# Derived from platform-specific values
LIBRARY_NAME="lib$APP_NAME.$LIB_EXT"
CONFIG_FILE="$CONFIG_DIR/config.conf"
```

**3. Hardcoded exceptions:**

```bash
# Most paths derived from PREFIX
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"

# Exception: System-wide profile must be in /etc regardless of PREFIX
# Reason: Shell initialization requires fixed path for all users
PROFILE_DIR='/etc/profile.d'           # Hardcoded by design
PROFILE_FILE="$PROFILE_DIR/$APP_NAME.sh"
```

**4. Multiple update functions:**

```bash
# Update subset of derived variables
update_prefix_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  SHARE_DIR="$PREFIX/share"
}

update_app_paths() {
  CONFIG_DIR="/etc/$APP_NAME"
  LOG_DIR="/var/log/$APP_NAME"
  DATA_DIR="/var/lib/$APP_NAME"
}

update_all_derived() {
  update_prefix_paths
  update_app_paths

  # Files derived from directories
  CONFIG_FILE="$CONFIG_DIR/config.conf"
  LOG_FILE="$LOG_DIR/app.log"
}
```

**Summary:**

- **Group derived variables** with section comments explaining dependencies
- **Derive from base values** - never duplicate, always compute
- **Update when base changes** - call update functions during argument parsing
- **Document hardcoded exceptions** - explain why specific values don't derive
- **Environment fallbacks** - use `${XDG_VAR:-$HOME/default}` pattern
- **Make readonly last** - after all parsing and derivation complete
- **Clear dependency chain** - base ’ derived1 ’ derived2
- **Update functions** - centralize derivation logic when many variables depend on same base
