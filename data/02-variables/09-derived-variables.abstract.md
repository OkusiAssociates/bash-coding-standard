## Derived Variables

**Derive variables from base values rather than duplicating. Group with section comments. Update all derived variables when base values change (especially during argument parsing).**

**Rationale:**
- DRY principle - single source of truth, automatic updates when base changes
- Prevents inconsistency bugs when base values change but derived don't update
- Section comments make dependencies explicit for maintainability

**Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Base values
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

# Derived paths
declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- CONFIG_DIR="/etc/$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"

# Update function for argument parsing
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  CONFIG_DIR="/etc/$APP_NAME"
  CONFIG_FILE="$CONFIG_DIR/config.conf"
}

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX="$1"; update_derived_paths ;;
      *) break ;;
    esac
    shift
  done
  readonly -- PREFIX BIN_DIR LIB_DIR CONFIG_DIR CONFIG_FILE
}
main "$@"
#fin
```

**Anti-patterns:**
- `BIN_DIR='/usr/local/bin'` ’ Duplicates `PREFIX`, won't update if `PREFIX` changes
- Changing `PREFIX` without updating `BIN_DIR="$PREFIX/bin"` ’ Inconsistent state
- Making derived variables `readonly` before base values finalized ’ Can't update

**Ref:** BCS0209
