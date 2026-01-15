## Readonly After Group

**Declare variables with values first, then make them all readonly in a single statement.**

**Rationale:**
- Prevents assignment errors (cannot assign to already-readonly variable)
- Visual grouping of related constants as logical unit
- Clear immutability contract; explicit error if uninitialized variable made readonly
- Separates initialization phase from protection phase

**Three-Step Progressive Readonly Workflow:**

For variables finalized after argument parsing:

```bash
# Step 1 - Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX=${PREFIX:-/usr/local}

# Step 2 - Parse and modify in main()
main() {
  while (($#)); do case $1 in
    -v)       VERBOSE+=1 ;;
    -n)       DRY_RUN=1 ;;
    --output) noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    --prefix) noarg "$@"; shift; PREFIX=$1 ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing complete
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Exception - Script Metadata:**

As of BCS v1.0.1, `declare -r` is preferred for script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME). Other groups continue using readonly-after-group.

```bash
# Script metadata (uses declare -r, see BCS0103)
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variable Groups:**

**1. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**2. Path constants:**
```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**3. Configuration defaults:**
```bash
declare -i DEFAULT_TIMEOUT=30
declare -i DEFAULT_RETRIES=3
declare -- DEFAULT_LOG_LEVEL=info
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES DEFAULT_LOG_LEVEL
```

**Anti-patterns:**

```bash
# ✗ Wrong - making readonly before all values set
PREFIX=/usr/local
readonly -- PREFIX  # Premature!
BIN_DIR="$PREFIX"/bin  # If this fails, inconsistent protection

# ✓ Correct - all values set, then all readonly
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR

# ✗ Wrong - forgetting -- separator
readonly PREFIX BIN_DIR  # Risky if variable name starts with -

# ✓ Correct - always use -- separator
readonly -- PREFIX BIN_DIR

# ✗ Wrong - mixing unrelated variables
CONFIG_FILE=config.conf
VERBOSE=1
PREFIX=/usr/local
readonly -- CONFIG_FILE VERBOSE PREFIX  # No logical grouping!

# ✗ Wrong - readonly inside conditional
if [[ -f config.conf ]]; then
  CONFIG_FILE=config.conf
  readonly -- CONFIG_FILE
fi
# CONFIG_FILE might not be readonly if condition false!

# ✓ Correct - initialize with default, then readonly
CONFIG_FILE=${CONFIG_FILE:-config.conf}
readonly -- CONFIG_FILE
```

**Edge Cases:**

**Derived variables** - initialize in dependency order:
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Conditional initialization:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; NC=$'\033[0m'
else
  RED=''; NC=''
fi
readonly -- RED NC  # Safe after conditional
```

**Arrays:**
```bash
declare -a REQUIRED_COMMANDS=(git make tar)
readonly -a REQUIRED_COMMANDS
```

**Delayed readonly (after argument parsing):**
```bash
declare -i VERBOSE=0
declare -- CONFIG_FILE=''

main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;;
    -c) noarg "$@"; shift; CONFIG_FILE=$1 ;;
  esac; shift; done

  readonly -- VERBOSE
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
}
```

**When NOT to use readonly:**
```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Only make readonly when value is final
[[ -z "$config_file" ]] || readonly -- config_file
```

**Key Principles:**
- Initialize first, readonly second
- Group logically related variables
- Always use `--` separator
- Make readonly as soon as values are final
- Use `readonly -p` to verify status
