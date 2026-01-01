### Edge Cases and Variations

Special scenarios where the standard 13-step BCS0101 layout may be modified.

---

## When to Skip `main()` Function

**Small scripts under 200 lines** can skip `main()` and run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail

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
# Just function definitions for other scripts to use
#fin
```

## Scripts With External Configuration

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
: ...

# Default configuration
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}"/myapp/config.sh
declare -- DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"/myapp

# Source config file if it exists and can be read
if [[ -r "$CONFIG_FILE" ]]; then
  #shellcheck source=/dev/null
  source "$CONFIG_FILE" || die 1 "Failed to source config ${CONFIG_FILE@Q}"
fi

# Now make readonly after sourcing config
readonly -- CONFIG_FILE DATA_DIR

# ... rest of script
```

## Platform-Specific Sections

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
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

: ... rest of script
```

## Scripts With Cleanup Requirements

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
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

# ... rest of script uses TEMP_FILES
```

**Trap placement:** After cleanup function defined, before code creating temp files.

---

## Legitimate Deviations

### Simplifications
- **Tiny scripts (<200 lines)** - Skip `main()`, run directly
- **Library files** - Skip `set -e`, `main()`, script invocation
- **One-off utilities** - May skip colors, verbose messaging

### Extensions
- **External configuration** - Config sourcing between metadata and business logic
- **Platform detection** - Platform-specific globals after standard globals
- **Cleanup traps** - Trap setup after utility functions, before business logic
- **Lock files** - Lock acquisition/release around main execution

---

## Anti-Patterns

```bash
# ✗ Wrong - arbitrary reordering without reason
#!/usr/bin/env bash

# Functions before set -e
validate_input() { : ... }

set -euo pipefail  # Too late!

# Globals scattered
VERSION=1.0.0
check_system() { : ... }
declare -- PREFIX=/usr
```

```bash
# ✓ Correct - standard order maintained
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
declare -- PREFIX=/usr

validate_input() { : ... }
check_system() { : ... }
```

---

## Core Principles (Even When Deviating)

1. **Safety first** - `set -euo pipefail` comes first (unless library)
2. **Dependencies before usage** - Bottom-up organization applies
3. **Clear structure** - Readers easily understand the flow
4. **Minimal deviation** - Only when clear benefit exists
5. **Document reasons** - Comment why deviating from standard
