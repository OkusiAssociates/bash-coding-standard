### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work as both standalone executables and sourceable libraries must apply `set -euo pipefail` and `shopt` settings **ONLY when executed directly, NOT when sourced**.

**Rationale:** Sourcing a script that applies `set -e` or modifies `shopt` settings would alter the calling shell's environment, potentially breaking the caller's error handling or glob behavior. The sourced script should provide functions/variables without modifying shell state.

**Recommended pattern (early return):**
```bash
#!/bin/bash
# Description of dual-purpose script

# Function definitions (available in both modes)
my_function() {
  local -- arg="$1"
  [[ -n "$arg" ]] || return 1
  echo "Processing: $arg"
}
declare -fx my_function

# Early return for sourced mode - stops here when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# -----------------------------------------------------------------------------
# Executable code starts here (only runs when executed directly)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata initialization with guard (allows re-sourcing safety)
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION='1.0.0'
  declare -x SCRIPT_PATH=$(realpath -- "$0")
  declare -x SCRIPT_DIR=${SCRIPT_PATH%/*}
  declare -x SCRIPT_NAME=${SCRIPT_PATH##*/}
  readonly -- SCRIPT_VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
fi

# Helper functions (only needed for executable mode)
show_help() {
  cat <<EOT
$SCRIPT_NAME $SCRIPT_VERSION - Description

Usage: $SCRIPT_NAME [options] [arguments]
EOT
}

# Main execution logic
my_function "$@"

#fin
```

**Pattern breakdown:**

1. **Function definitions first** - Define all library functions at top, export with `declare -fx` if needed by subshells
2. **Early return** - `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` - when sourced: functions loaded then immediate exit; when executed: test fails, continues
3. **Visual separator** - Comment line marks executable section boundary
4. **Set and shopt** - Only applied when executed (after separator)
5. **Metadata with guard** - `if [[ ! -v SCRIPT_VERSION ]]` prevents re-initialization, safe to source multiple times

**Alternative pattern (if/else block for different initialization per mode):**
```bash
#!/bin/bash

# Functions first
process_data() { ... }
declare -fx process_data

# Dual-mode initialization
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # EXECUTED MODE
  set -euo pipefail
  DATA_DIR=/var/lib/myapp
  process_data "$DATA_DIR"
else
  # SOURCED MODE - different initialization
  DATA_DIR=${DATA_DIR:-/tmp/test_data}
  # Export functions, return to caller
fi
```

**Key principles:**
- Prefer early return pattern for clarity
- Place all function definitions before sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata initialization with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` (execute) and `source script.sh` (source)

**Use cases:**
- Utility libraries that demonstrate usage when executed
- Scripts providing reusable functions plus CLI interface
- Test frameworks sourceable for functions or runnable for tests
