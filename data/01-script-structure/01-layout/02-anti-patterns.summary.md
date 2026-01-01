### Common Layout Anti-Patterns

Common violations of BCS0101 13-step layout with corrections.

---

## Anti-Patterns

### ✗ Missing `set -euo pipefail`

```bash
#!/usr/bin/env bash
VERSION=1.0.0
rm -rf /important/data  # Fails silently
```

**Problem:** Errors not caught, script continues after failures.

### ✓ Correct

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose
VERSION=1.0.0
```

---

### ✗ Variables After Use

```bash
main() {
  ((VERBOSE)) && echo 'Starting...' ||:  # VERBOSE undefined!
}
declare -i VERBOSE=0  # Too late
```

**Problem:** "Unbound variable" errors with `set -u`.

### ✓ Correct

```bash
declare -i VERBOSE=0
declare -i DRY_RUN=0

main() {
  ((VERBOSE)) && echo 'Starting...' ||:
}
```

---

### ✗ Business Logic Before Utilities

```bash
process_files() {
  [[ -f "$file" ]] || die 2 "Not a file"  # die() not defined yet!
}
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Problem:** Violates bottom-up organization; harder to understand.

### ✓ Correct

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

process_files() {
  [[ -f "$file" ]] || die 2 "Not a file"
}
```

---

### ✗ No `main()` in Large Script

```bash
# ... 200 lines of functions ...
if [[ "$1" == '--help' ]]; then echo 'Usage: ...'; exit 0; fi
check_prerequisites
install_files
```

**Problem:** No clear entry point, scattered parsing, can't source for testing.

### ✓ Correct

```bash
main() {
  while (($#)); do
    case $1 in
      -h|--help) usage; exit 0 ;;
      *) die 22 "Invalid argument ${1@Q}" ;;
    esac
    shift
  done
  check_prerequisites
  install_files
}
main "$@"
#fin
```

---

### ✗ Missing End Marker

```bash
main "$@"
# File ends without #fin
```

**Problem:** No confirmation file is complete; truncation harder to detect.

### ✓ Correct

```bash
main "$@"
#fin
```

---

### ✗ Readonly Before Parsing

```bash
PREFIX=/usr/local
readonly -- PREFIX

main() {
  case $1 in
    --prefix) PREFIX="$1" ;;  # Fails - readonly!
  esac
}
```

### ✓ Correct

```bash
declare -- PREFIX=/usr/local

main() {
  case $1 in --prefix) PREFIX=$1 ;; esac
  readonly -- PREFIX  # After parsing
}
```

---

### ✗ Scattered Declarations

```bash
declare -i VERBOSE=0
check_something() { echo 'Checking...'; }
declare -- PREFIX=/usr/local  # More globals after function
```

**Problem:** Hard to see all state variables at once.

### ✓ Correct

```bash
declare -i VERBOSE=0
declare -- PREFIX=/usr/local

check_something() { echo 'Checking...'; }
```

---

### ✗ Unprotected Sourcing

```bash
#!/usr/bin/env bash
set -euo pipefail  # Modifies caller's shell!
main "$@"          # Runs when sourced!
```

### ✓ Dual-Purpose Script

```bash
#!/usr/bin/env bash
error() { >&2 echo "ERROR: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail
VERSION=1.0.0
main() { echo 'Running main'; }
main "$@"
#fin
```

---

## Summary

| Anti-Pattern | Consequence |
|--------------|-------------|
| Missing strict mode | Silent failures |
| Declaration order | Unbound variable errors |
| Function organization | Code harder to understand |
| Missing main() | Can't test or source script |
| Missing #fin | Truncation undetectable |
| Premature readonly | Assignment errors |
| Scattered declarations | State hard to audit |
| Unprotected sourcing | Caller's shell modified |
