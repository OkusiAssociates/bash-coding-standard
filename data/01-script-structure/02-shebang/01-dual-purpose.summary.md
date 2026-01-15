### Dual-Purpose Scripts (Executable and Sourceable)

Scripts designed to work both as standalone executables and source libraries. `set -euo pipefail` and `shopt` settings must **ONLY** be applied when executed directly, **NOT** when sourced.

**Rationale:** When sourced, applying `set -e` or modifying `shopt` would alter the calling shell's environment, breaking the caller's error handling or glob behavior.

**Recommended pattern (early return):**
```bash
#!/bin/bash
# Description of dual-purpose script
: ...

# Function definitions (available in both modes)
my_function() {
  local -- arg="$1"
  [[ -n "$arg" ]] || return 1
  echo "Processing: $arg"
}
declare -fx my_function

# Early return for sourced mode - stops here when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# -----------------------------------------------------------------------------
# Executable code starts here (only runs when executed directly)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata initialization with guard (allows re-sourcing safety)
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION=1.0.0
  #shellcheck disable=SC2155
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
1. **Function definitions first** - Define library functions at top, export with `declare -fx` if needed
2. **Early return** - `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` - when sourced: functions loaded, clean exit
3. **Visual separator** - Clear comment marks executable section boundary
4. **Set and shopt** - Only applied when executed, placed immediately after separator
5. **Metadata with guard** - `[[ ! -v SCRIPT_VERSION ]]` prevents re-initialization, safe for multiple sourcing

**Alternative pattern (if/else)** for different initialization per mode:
```bash
#!/bin/bash

process_data() { ... }
declare -fx process_data

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # EXECUTED MODE
  set -euo pipefail
  declare -r DATA_DIR=/var/lib/myapp
  process_data "$DATA_DIR"
else
  # SOURCED MODE - different initialization
  declare -r DATA_DIR=${DATA_DIR:-/tmp/test_data}
fi
```

**Key principles:**
- Prefer early return pattern for simplicity
- Place function definitions **before** sourced/executed detection
- Only apply `set -euo pipefail` and `shopt` in executable section
- Use `return` (not `exit`) for errors when sourced
- Guard metadata with `[[ ! -v VARIABLE ]]` for idempotence
- Test both modes: `./script.sh` and `source script.sh`

**Common use cases:** Utility libraries with CLI demos, reusable functions + CLI interface, test frameworks.
