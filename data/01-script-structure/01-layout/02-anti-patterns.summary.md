### Common Layout Anti-Patterns

**Violations of BCS0101 13-step layout pattern with incorrect and correct approaches.**

---

## Anti-Patterns

### ✗ Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash
# Script starts without error handling
VERSION=1.0.0
rm -rf /important/data  # Fails silently
```

**Problem:** Errors not caught, script continues after failures.

### ✓ Correct: Error Handling First

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose
declare -r VERSION=1.0.0
```

---

### ✗ Declaring Variables After Use

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  ((VERBOSE)) && echo 'Starting...' ||:  # VERBOSE not declared yet
  process_files
}

declare -i VERBOSE=0  # Too late!

main "$@"
#fin
```

**Problem:** "unbound variable" errors with `set -u`.

### ✓ Correct: Declare Before Use

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE==0)) || echo 'Starting...'
  process_files
}

main "$@"
#fin
```

---

### ✗ Business Logic Before Utilities

```bash
#!/usr/bin/env bash
set -euo pipefail

process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"  # die() not defined yet!
  done
}

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main "$@"
#fin
```

**Problem:** Violates bottom-up organization; harder to understand.

### ✓ Correct: Utilities Before Business Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

process_files() {
  local -- file
  for file in *.txt; do
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"
  done
}

main "$@"
#fin
```

---

### ✗ No `main()` in Large Script

```bash
#!/usr/bin/env bash
set -euo pipefail

# ... 200 lines of code ...
if [[ "$1" == '--help' ]]; then
  echo 'Usage: ...'; exit 0
fi

check_prerequisites
validate_config
install_files
#fin
```

**Problem:** No clear entry point, argument parsing scattered, can't source to test individual functions.

### ✓ Correct: Use `main()` for Scripts Over 200 Lines

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0

main() {
  while (($#)); do
    case $1 in
      -h|--help) show_help; exit 0 ;;
      -*)        die 22 "Invalid option ${1@Q}" ;;
      *)         die 2 "Invalid argument ${1@Q}" ;;
    esac
    shift
  done

  check_prerequisites
  validate_config
  install_files
}

main "$@"
#fin
```

---

### ✗ Missing End Marker

```bash
#!/usr/bin/env bash
set -euo pipefail

main() { echo 'Hello, World!'; }

main "$@"
# File ends without #fin
```

**Problem:** No visual confirmation file is complete; harder to detect truncation.

### ✓ Correct: Always End With `#fin`

```bash
main "$@"
#fin
```

---

### ✗ Readonly Before Parsing Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r PREFIX=/usr/local
readonly -- PREFIX  # Too early!

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;  # FAILS - readonly!
    esac
    shift
  done
}
#fin
```

**Problem:** Variables modified during argument parsing made readonly too early.

### ✓ Correct: Readonly After Argument Parsing

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -- PREFIX=/usr/local  # Mutable during parsing

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;  # OK - not readonly yet
    esac
    shift
  done

  readonly -- PREFIX  # Now make readonly
}

main "$@"
#fin
```

---

### ✗ Mixing Declaration and Logic

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0

check_something() { echo 'Checking...'; }

declare -- PREFIX=/usr/local  # Globals scattered!
declare -- CONFIG_FILE=''

main "$@"
#fin
```

**Problem:** Globals scattered throughout file; hard to see all state variables.

### ✓ Correct: All Globals Together

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -i VERBOSE=0
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''

check_something() { echo 'Checking...'; }

main "$@"
#fin
```

---

### ✗ Sourcing Without Protecting Execution

```bash
#!/usr/bin/env bash
set -euo pipefail  # Modifies caller's shell!

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main "$@"  # Runs automatically when sourced!
#fin
```

**Problem:** When sourced, modifies caller's shell settings and runs `main` automatically.

### ✓ Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash

error() { >&2 echo "ERROR: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Fast exit if sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Now start main script
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}

main() {
  echo 'Running main'
}

main "$@"
#fin
```

---

## Summary

Eight common BCS0101 violations:

1. **Missing strict mode** - Scripts without `set -euo pipefail` fail silently
2. **Declaration order** - Variables must be declared before use
3. **Function organization** - Utilities before business logic
4. **Missing main()** - Large scripts need structured entry point
5. **Missing end marker** - Scripts must end with `#fin`
6. **Premature readonly** - Variables must be mutable until after parsing
7. **Scattered declarations** - All globals must be grouped together
8. **Unprotected sourcing** - Dual-purpose scripts must protect execution code
