### Edge Cases and Variations

**Special scenarios where the standard 13-step BCS0101 layout may be modified or simplified.**

---

## When to Skip `main()` Function

**Small scripts under 200 lines** can skip `main()` and run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Simple file counter - only 20 lines total
declare -i count=0

for file in "$@"; do
  [[ ! -f "$file" ]] || count+=1
done

echo "Found $count files"
#fin
```

## Sourced Library Files

**Files meant only to be sourced** skip execution parts and `set -e`:

```bash
#!/usr/bin/env bash
# Library of utility functions - meant to be sourced, not executed

# Don't use set -e when sourced (would affect caller)
# Don't make variables readonly (caller might need to modify)

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }

is_valid_email() { [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; }

# No main(), no execution
#fin
```

## Scripts With External Configuration

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
: ...

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-"$HOME"/.config}"/myapp/config.sh
declare -- DATA_DIR="${XDG_DATA_HOME:-"$HOME"/.local/share}"/myapp

# Source config file if it exists and can be read
if [[ -r "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config ${CONFIG_FILE@Q}"
fi

# Now make readonly after sourcing config
readonly -- CONFIG_FILE DATA_DIR
```

## Platform-Specific Sections

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
: ...

# Detect platform
declare -- PLATFORM
case $(uname -s) in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      PLATFORM=unknown ;;
esac
readonly -- PLATFORM

# Platform-specific global variables
case $PLATFORM in
  macos)
    declare -- PACKAGE_MANAGER=brew
    declare -- INSTALL_CMD='brew install'
    ;;
  linux)
    declare -- PACKAGE_MANAGER=apt
    declare -- INSTALL_CMD='apt-get install'
    ;;
  *)
    die 1 "Unsupported platform ${PLATFORM@Q}"
    ;;
esac

readonly -- PACKAGE_MANAGER INSTALL_CMD
```

## Scripts With Cleanup Requirements

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
: ...

# Temporary files array for cleanup
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=${1:-$?}
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    [[ ! -f "$file" ]] || rm -f "$file"
  done

  return "$exit_code"
}

# Set trap early, after functions are defined
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Trap should be set** after cleanup function is defined but before any code that creates temp files.

---

## Legitimate Deviations

### Simplifications
- **Tiny scripts (<200 lines)** - Skip `main()`, run code directly
- **Library files** - Skip `set -e`, `main()`, script invocation
- **One-off utilities** - May skip color definitions, verbose messaging

### Extensions
- **External configuration** - Add config sourcing between metadata and business logic
- **Platform detection** - Add platform-specific globals after standard globals
- **Cleanup traps** - Add trap setup after utility functions but before business logic
- **Lock files** - Add lock acquisition/release around main execution

---

## Key Principles

Even when deviating:

1. **Safety first** - `set -euo pipefail` still comes first (unless library file)
2. **Dependencies before usage** - Bottom-up organization still applies
3. **Clear structure** - Readers should easily understand the flow
4. **Minimal deviation** - Only deviate when there's clear benefit
5. **Document reasons** - Comment why you're deviating from standard

---

## Anti-Pattern: Arbitrary Reordering

**Wrong:**
```bash
# ✗ Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!
shopt -s inherit_errexit shift_verbose extglob nullglob

# Globals scattered
declare -r VERSION=1.0.0
check_system() { : ... }
declare -- PREFIX=/usr
```

**Correct:**
```bash
# ✓ Correct - standard order maintained
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -- PREFIX=/usr

validate_input() { : ... }
check_system() { : ... }
```

---

## Summary

Edge cases exist for:
- **Simplification** for tiny scripts
- **Libraries** that shouldn't modify sourcing environment
- **External config** that must override defaults
- **Platform detection** for cross-platform compatibility
- **Cleanup traps** for resource management

Core principles remain: error handling first, dependencies before usage, clear structure. Deviate only when necessary.
