## Readonly After Group

**Declare multiple readonly variables first with their values, then make them all readonly in a single statement.**

**Rationale:**
- Prevents assignment errors (cannot assign to already-readonly variable)
- Visual grouping of related constants as logical unit
- Clear immutability contract; explicit protection phase
- Easy maintenance; if uninitialized variable in readonly list, script fails explicitly

**Three-Step Progressive Readonly Workflow:**

For variables finalized after argument parsing:

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

  # Now safe to use - all readonly
  ((VERBOSE)) && info "Using prefix: $PREFIX" ||:
}
```

**Exception - Script Metadata:** Use `declare -r` for VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME (see BCS0103). Other groups (colors, paths, config) use readonly-after-group.

**Variable Groups:**

**1. Script metadata (uses declare -r):**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**2. Color definitions:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**3. Path constants:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/myapp
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**4. Configuration defaults:**
```bash
DEFAULT_TIMEOUT=30
DEFAULT_RETRIES=3
MAX_FILE_SIZE=104857600  # 100MB
readonly -- DEFAULT_TIMEOUT DEFAULT_RETRIES MAX_FILE_SIZE
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
readonly -- CONFIG_FILE VERBOSE PREFIX  # Not a logical group!

# ✗ Wrong - readonly inside conditional
if [[ -f config.conf ]]; then
  CONFIG_FILE=config.conf
  readonly -- CONFIG_FILE
fi
# CONFIG_FILE might not be readonly if condition is false!

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
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
  [[ -z "$CONFIG_FILE" ]] || readonly -- CONFIG_FILE
}
```

**Testing readonly status:**
```bash
readonly -p 2>/dev/null | grep -q "VERSION" && echo 'readonly'
readonly -p  # List all readonly variables
```

**When NOT to use readonly:**
```bash
# Don't make readonly if value changes during execution
declare -i count=0  # Modified in loops

# Only make readonly when value is final
[[ -n "$config_file" ]] && readonly -- config_file
```

**Key principle:** Separate initialization from protection. Group related variables together. Always use `--` separator. Make readonly as soon as values are final.
