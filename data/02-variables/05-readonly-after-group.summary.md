## Readonly After Group

**Declare multiple readonly variables first with values, then make them all readonly in a single statement. This improves readability, prevents assignment errors, and makes immutability explicit.**

**Rationale:**
- Prevents assignment errors (can't assign to already-readonly variable)
- Visual grouping of related constants as logical unit
- Clear immutability contract; easy to add/remove variables
- Explicit failure if variable uninitialized before readonly

**Three-Step Progressive Readonly Workflow:**

Standard pattern for variables finalized after argument parsing:

**Step 1 - Declare with defaults:**
```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE='' PREFIX=/usr/local
```

**Step 2 - Parse and modify in main():**
```bash
main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;;
    -n) DRY_RUN=1 ;;
    --output) noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    --prefix) noarg "$@"; shift; PREFIX=$1 ;;
  esac; shift; done

  # Step 3 - Make readonly AFTER parsing complete
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE PREFIX

  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Exception - Script Metadata:** Prefer `declare -r` for immediate readonly (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) per BCS0103. Other variable groups use readonly-after-group.

**Standard pattern (non-metadata):**

```bash
# Script metadata (uses declare -r, see BCS0103)
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Message flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Color definitions (conditional)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Variable groups:**

**1. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN BOLD NC
```

**2. Path constants:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/myapp
LIB_DIR="$PREFIX"/lib/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR LIB_DIR
```

**3. Configuration defaults:**
```bash
DEFAULT_TIMEOUT=30
DEFAULT_RETRIES=3
DEFAULT_LOG_LEVEL=info
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES DEFAULT_LOG_LEVEL
```

**Anti-patterns:**

```bash
# ✗ Wrong - readonly before all values set
PREFIX=/usr/local
readonly -- PREFIX  # Premature!
BIN_DIR="$PREFIX"/bin
# If BIN_DIR fails, inconsistent protection

# ✓ Correct - all values set, then all readonly
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR

# ✗ Wrong - forgetting -- separator
readonly PREFIX BIN_DIR  # Risky if name starts with -

# ✓ Correct - always use -- separator
readonly -- PREFIX BIN_DIR

# ✗ Wrong - mixing unrelated variables
CONFIG_FILE=config.conf
VERBOSE=1
PREFIX=/usr/local
readonly -- CONFIG_FILE VERBOSE PREFIX  # Not a logical group!

# ✓ Correct - group logically related variables
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR

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

**Edge cases:**

**Derived variables** - initialize in dependency order:
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Conditional initialization** - same variables defined either way:
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; NC=''
fi
readonly -- RED GREEN NC
```

**Arrays:**
```bash
declare -a REQUIRED_COMMANDS=(git make tar)
declare -a OPTIONAL_COMMANDS=(md2ansi pandoc)
readonly -a REQUIRED_COMMANDS OPTIONAL_COMMANDS
```

**Delayed readonly (after argument parsing):**
```bash
declare -i VERBOSE=0 DRY_RUN=0
declare -- CONFIG_FILE='' LOG_FILE=''

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -c|--config)  noarg "$@"; shift; CONFIG_FILE=$1 ;;
    -l|--log)     noarg "$@"; shift; LOG_FILE=$1 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
  [[ -z "$LOG_FILE" ]] || readonly -- LOG_FILE

  ((VERBOSE)) && info 'Verbose mode enabled' ||:
}
```

**Testing readonly status:**
```bash
readonly -p 2>/dev/null | grep -q "VERSION" && echo 'VERSION is readonly'
readonly -p  # List all readonly variables
```

**When NOT to use readonly:**
```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops - don't make readonly

# Only make readonly when value is final
[[ -n "$config_file" ]] && readonly -- config_file
```

**Key principles:**
- Initialize first, readonly second
- Group related variables together
- Always use `--` separator
- Make readonly as soon as values are final
- Delayed readonly for parsed arguments
