## Readonly After Group

**Declare variables first, then make all readonly in single statement. Exception: script metadata uses `declare -r` (BCS0103).**

### Why
- Prevents assignment to already-readonly variable
- Groups related constants visually
- Separates initialization from protection phase

### Three-Step Pattern (for arg-parsed values)
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0

# 2. Parse in main()
while (($#)); do case $1 in -v) VERBOSE+=1 ;; esac; shift; done

# 3. Make readonly AFTER parsing
readonly -- VERBOSE DRY_RUN
```

### Standard Groups
```bash
# Colors (conditional init, then readonly)
if [[ -t 1 ]]; then RED=$'\033[31m'; else RED=''; fi
readonly -- RED

# Paths (derive all, then readonly together)
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR
```

### Anti-Patterns
```bash
# ✗ Premature readonly
PREFIX=/usr/local
readonly -- PREFIX  # Too early!
BIN_DIR="$PREFIX"/bin  # PREFIX locked before group complete

# ✓ Correct
PREFIX=/usr/local
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR

# ✗ Missing -- separator
readonly PREFIX  # Risky if var starts with -

# ✗ Readonly inside conditional
if [[ -f x ]]; then readonly -- VAR; fi  # May not be readonly!
```

**Key:** Always use `--` separator. Group logically related variables. Make readonly only when values are final.

**Ref:** BCS0205
