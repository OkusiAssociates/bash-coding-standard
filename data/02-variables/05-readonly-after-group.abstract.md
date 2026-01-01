## Readonly After Group

**Initialize all related variables first, then protect entire group with single `readonly --` statement.**

### Rationale
- Prevents assignment-to-readonly errors
- Groups related constants visibly
- Explicit immutability contract

### Three-Step Pattern (for parsed variables)
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
# 2. Modify during parsing (in main)
# 3. Make readonly AFTER parsing
readonly -- VERBOSE DRY_RUN
```

### Standard Groups

**Colors** (conditional):
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' NC=$'\033[0m'
else
  RED='' NC=''
fi
readonly -- RED NC
```

**Paths** (derived):
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR
```

### Exception
Script metadata uses `declare -r` instead (see BCS0103).

### Anti-Patterns

```bash
# ✗ Premature readonly
PREFIX=/usr/local
readonly -- PREFIX  # Too early!
BIN_DIR="$PREFIX"/bin  # PREFIX locked before group complete

# ✗ Missing -- separator
readonly PREFIX BIN_DIR  # Risky if var starts with -

# ✗ Readonly inside conditional
if [[ -f conf ]]; then
  CONFIG=conf
  readonly -- CONFIG  # May not execute!
fi

# ✓ Correct
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR
```

### Delayed Readonly
Variables modified by argument parsing �' make readonly after parsing completes:
```bash
[[ -z "$CONFIG" ]] || readonly -- CONFIG
```

**Ref:** BCS0205
