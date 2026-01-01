## Constants and Environment Variables

**Constants (readonly):**
```bash
# Use readonly for values that never change
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -r CONFIG_DIR=/etc/myapp

# Group readonly declarations
VERSION=1.0.0
AUTHOR='John Doe'
LICENSE=GPL-3
readonly -- VERSION AUTHOR LICENSE
```

**Environment variables (export):**
```bash
# Use declare -x (or export) for variables passed to child processes
declare -x ORACLE_SID=PROD
declare -x DATABASE_URL='postgresql://localhost/mydb'

# Alternative syntax
export LOG_LEVEL=DEBUG
export TEMP_DIR=/tmp/myapp
```

**Rationale:**

- `readonly`: Script metadata (VERSION, AUTHOR), configuration paths, derived constants. Prevents modification, signals intent.
- `declare -x`/`export`: Values for child processes, environment config (DATABASE_URL, API_KEY), settings for subshells.

| Feature | `readonly` | `declare -x` / `export` |
|---------|-----------|------------------------|
| Prevents modification | ✓ Yes | ✗ No |
| Available in subprocesses | ✗ No | ✓ Yes |
| Can be changed later | ✗ Never | ✓ Yes |
| Use case | Constants | Environment config |

**Combining both (readonly + export):**
```bash
# Make a constant that is also exported to child processes
declare -rx BUILD_ENV=production
declare -rix MAX_CONNECTIONS=100

# Or in two steps
declare -x DATABASE_URL='postgresql://prod-db/app'
readonly -- DATABASE_URL
```

**Anti-patterns:**

```bash
# ✗ Wrong - exporting constants unnecessarily
export MAX_RETRIES=3  # Child processes don't need this

# ✓ Correct - only make it readonly
readonly -- MAX_RETRIES=3

# ✗ Wrong - not making true constants readonly
CONFIG_FILE=/etc/app.conf  # Could be accidentally modified later

# ✓ Correct - protect against modification
readonly -- CONFIG_FILE=/etc/app.conf

# ✗ Wrong - making user-configurable variables readonly too early
readonly -- OUTPUT_DIR="$HOME"/output  # Can't be overridden by user!

# ✓ Correct - allow override, then make readonly
OUTPUT_DIR=${OUTPUT_DIR:-$HOME/output}
readonly -- OUTPUT_DIR
```

**Complete example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script constants (not exported)
readonly -- SCRIPT_VERSION=2.1.0
readonly -- MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100MB

# Environment variables for child processes (exported)
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}
declare -x TEMP_DIR=${TMPDIR:-/tmp}

# Combined: readonly + exported
declare -rx BUILD_ENV=production

# Derived constants (readonly)
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly -- SCRIPT_PATH SCRIPT_DIR
```
