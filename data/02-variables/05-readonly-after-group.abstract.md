## Readonly After Group

**Declare variables first, then make readonly in single statement.**

**Rationale:** Prevents assignment errors; visual grouping; clear immutability contract.

**Three-step progressive workflow:**

```bash
# Step 1 - Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- PREFIX='/usr/local'

# Step 2 - Parse/modify in main()
main() {
  while (($#)); do case $1 in
    -v) VERBOSE=1 ;;
    --prefix) shift; PREFIX="$1" ;;
  esac; shift; done

  # Step 3 - Readonly after parsing
  readonly -- VERBOSE DRY_RUN PREFIX
}
```

Variables mutable during parsing → readonly after.

**Exception:** Script metadata prefers `declare -r` (see BCS0103). Readonly-after-group valid but `declare -r` now recommended.

**Standard groups:**

```bash
# Metadata (exception: uses declare -r)
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")

# Colors (conditional)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' NC=$'\033[0m'
else
  RED='' NC=''
fi
readonly -- RED NC

# Paths
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR
```

**Anti-patterns:**

```bash
# ✗ Wrong - readonly before all values set
PREFIX='/usr'
readonly -- PREFIX
BIN_DIR="$PREFIX/bin"  # Not protected

# ✓ Correct
PREFIX='/usr'
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR

# ✗ Wrong - missing --
readonly PREFIX  # Risky

# ✓ Correct
readonly -- PREFIX
```

**Ref:** BCS0205
