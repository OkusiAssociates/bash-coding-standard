### Dual-Purpose Scripts

**Rule: BCS0606** (Elevated from BCS010201)

Scripts that can be both executed directly and sourced as libraries.

---

#### Rationale

Dual-purpose scripts provide:
- Reusable functions without code duplication
- Direct execution for standalone use
- Library sourcing for integration
- Testing flexibility (source functions, run tests)

---

#### Basic Pattern

```bash
#!/usr/bin/env bash
# my-lib.sh - Dual-purpose library/script

# Define functions first (before any set -e)
my_function() {
  local -- arg=$1
  echo "Processing ${arg@Q}"
}
declare -fx my_function

# Check if sourced or executed
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Everything below runs only when executed directly
set -euo pipefail
shopt -s inherit_errexit shift_verbose

# Script metadata
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  my_function "$@"
}

main "$@"
#fin
```

#### With Idempotent Initialization

```bash
#!/usr/bin/env bash
# Prevent double-initialization when sourced

[[ -v MY_LIB_VERSION ]] || {
  declare -rx MY_LIB_VERSION=1.0.0
  declare -rx MY_LIB_PATH=$(realpath -e -- "${BASH_SOURCE[0]}")
}

# Functions defined here...
my_func() { :; }
declare -fx my_func

# Source-mode exit
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Execution mode
set -euo pipefail
main() { my_func "$@"; }
main "$@"
#fin
```

#### Why set -e Comes After Check

The `set -e` must come AFTER the sourced check because:

1. When sourced, parent script controls error handling
2. `return 0` with `set -e` active could cause issues
3. Library code should not impose error handling on caller

```bash
# ✗ Wrong - set -e before source check
set -euo pipefail
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Risky

# ✓ Correct - set -e after source check
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail
```

---

#### Using Dual-Purpose Scripts

```bash
# As executable
./my-lib.sh arg1 arg2

# As library (source for functions)
source ./my-lib.sh
my_function "value"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - functions not exported
my_func() { :; }
# Cannot be called from subshells after sourcing

# ✓ Correct - export functions
my_func() { :; }
declare -fx my_func
```

---

**See Also:** BCS0607 (Library Patterns), BCS0604 (Function Export)

**Full implementation:** See `examples/exemplar-code/internetip/internetip`

#fin
