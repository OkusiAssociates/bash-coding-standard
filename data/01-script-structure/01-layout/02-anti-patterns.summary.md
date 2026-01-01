### Common Layout Anti-Patterns

**Common violations of BCS0101 13-step layout with incorrect approach and correct solution.**

---

## Anti-Patterns

### ✗ Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash

# Script starts without error handling
VERSION=1.0.0

# Commands can fail silently
rm -rf /important/data
cp config.txt /etc/
```

**Problem:** Errors not caught, script continues after failures.

### ✓ Correct: Error Handling First

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION=1.0.0
```

---

### ✗ Variables Declared After Use

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  ((VERBOSE)) && echo 'Starting...' ||:  # VERBOSE not declared!
  process_files
}

declare -i VERBOSE=0  # Too late

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
  ((VERBOSE)) && echo 'Starting...' ||:
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
    [[ -f "$file" ]] || die 2 "Not a file ${file@Q}"  # die() not defined!
  done
}

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() { process_files; }

main "$@"
#fin
```

**Problem:** Violates bottom-up organization, harder to understand.

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

main() { process_files; }

main "$@"
#fin
```

---

### ✗ No `main()` in Large Script

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
# ... 200 lines of functions ...

if [[ "$1" == '--help' ]]; then
  echo 'Usage: ...'
  exit 0
fi

check_prerequisites
validate_config
install_files
echo 'Done'
#fin
```

**Problem:** No clear entry point, scattered argument parsing, can't source to test functions.

### ✓ Correct: Use `main()` for Scripts Over 40 Lines

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0

main() {
  while (($#)); do
    case $1 in
      -h|--help) usage; exit 0 ;;
      *) die 22 "Invalid argument ${1@Q}" ;;
    esac
    shift
  done

  check_prerequisites
  validate_config
  install_files
  success 'Installation complete'
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

**Problem:** No visual confirmation file is complete, harder to detect truncation.

### ✓ Correct: Always End With `#fin`

```bash
#!/usr/bin/env bash
set -euo pipefail

main() { echo 'Hello, World!'; }

main "$@"
#fin
```

---

### ✗ Readonly Before Parsing Arguments

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
PREFIX=/usr/local
readonly -- VERSION PREFIX  # Too early!

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX="$1" ;;  # Fails - readonly!
    esac
    shift
  done
}

main "$@"
#fin
```

### ✓ Correct: Readonly After Argument Parsing

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME  # Never change

declare -- PREFIX=/usr/local  # Modified during parsing

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;
    esac
    shift
  done
  readonly -- PREFIX  # Now lock it
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

main() { check_something; }
main "$@"
#fin
```

### ✓ Correct: All Globals Together

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=1.0.0
declare -i VERBOSE=0
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''

check_something() { echo 'Checking...'; }

main() { check_something; }
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

### ✓ Correct: Dual-Purpose Script

```bash
#!/usr/bin/env bash

error() { >&2 echo "ERROR: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Exit if sourced

set -euo pipefail

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_NAME

main() { echo 'Running main'; }

main "$@"
#fin
```

---

## Summary

Eight anti-patterns violating BCS0101:

| Anti-Pattern | Consequence |
|-------------|-------------|
| Missing strict mode | Scripts fail silently |
| Late declaration | Unbound variable errors |
| Wrong function order | Violates bottom-up organization |
| Missing main() | No testable entry point |
| Missing end marker | Can't detect truncation |
| Premature readonly | Breaks argument parsing |
| Scattered declarations | Hard to see all state |
| Unprotected sourcing | Modifies caller's shell |
