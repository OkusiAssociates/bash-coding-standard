## Constants and Environment Variables

**Constants (readonly):**
```bash
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -r CONFIG_DIR=/etc/myapp

# Group readonly declarations
VERSION=1.0.0
AUTHOR='John Doe'
readonly -- VERSION AUTHOR LICENSE
```

**Environment variables (export):**
```bash
declare -x ORACLE_SID=PROD
declare -x DATABASE_URL='postgresql://localhost/mydb'
export LOG_LEVEL=DEBUG
```

**When to use:**
- `readonly`: Script metadata, config paths, derived constants - prevents accidental modification
- `declare -x`/`export`: Values for child processes, environment config, subshell inheritance

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification | ✓ Yes | ✗ No |
| Available in subprocesses | ✗ No | ✓ Yes |
| Can be changed later | ✗ Never | ✓ Yes |

**Combining both (readonly + export):**
```bash
declare -rx BUILD_ENV=production
declare -rix MAX_CONNECTIONS=100
```

**Anti-patterns:**
```bash
# ✗ Exporting internal constants - child processes don't need this
export MAX_RETRIES=3
# ✓ Correct
readonly -- MAX_RETRIES=3

# ✗ Not protecting true constants
CONFIG_FILE=/etc/app.conf
# ✓ Correct
readonly -- CONFIG_FILE=/etc/app.conf

# ✗ Making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME"/output  # Can't be overridden!
# ✓ Allow override first
OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/output}
readonly -- OUTPUT_DIR
```

**Complete example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script constants (not exported)
declare -r VERSION=2.1.0
declare -ri MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100MB

# Environment variables for child processes
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}
declare -x TEMP_DIR=${TMPDIR:-/tmp}

# Combined: readonly + exported
declare -rx BUILD_ENV=production

# Derived constants
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```
