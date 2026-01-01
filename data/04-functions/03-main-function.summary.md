## Main Function

**Always include a `main()` function for scripts longer than ~200 lines. Serves as single entry point for organization, testability, and maintainability. Place `main "$@"` at bottom before `#fin`.**

**Rationale:**
- Single entry point with clear execution flow
- Testable: source without executing, test functions individually
- Scope control: locals in main prevent global namespace pollution
- Centralized exit code handling and debugging

**When to use main():**
```bash
# Use main() when:
# - Script > ~200 lines, multiple functions, argument parsing, complex flow
# Can skip main() when:
# - Trivial script (< 200 lines), simple wrapper, no functions, linear
```

**Basic main() structure:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# ... helper functions ...

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  # Main logic
  info 'Starting processing...'
  return 0
}

main "$@"
#fin
```

**Main function with argument parsing:**
```bash
main() {
  local -i verbose=0
  local -i dry_run=0
  local -- output_file=''
  local -a input_files=()

  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output)
      noarg "$@"
      shift
      output_file=$1
      ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option ${1@Q}" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  input_files+=("$@")
  readonly -- verbose dry_run output_file
  readonly -a input_files

  if ((${#input_files[@]} == 0)); then
    error 'No input files specified'
    usage
    return 22
  fi

  local -- file
  for file in "${input_files[@]}"; do
    process_file "$file"
  done
  return 0
}
```

**Main function with setup/cleanup:**
```bash
cleanup() {
  local -i exit_code=${1:-$?}
  if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
  return "$exit_code"
}

main() {
  trap cleanup EXIT
  TEMP_DIR=$(mktemp -d)
  readonly -- TEMP_DIR
  info "Using temp directory ${TEMP_DIR@Q}"
  # ... processing ...
  return 0
}
```

**Main function with error tracking:**
```bash
main() {
  local -i errors=0
  local -- item
  for item in "${items[@]}"; do
    if ! process_item "$item"; then
      error "Failed to process: $item"
      errors+=1
    fi
  done

  if ((errors)); then
    error "Completed with $errors errors"
    return 1
  else
    success 'All items processed successfully'
    return 0
  fi
}
```

**Main function enabling sourcing for tests:**
```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail

main() {
  # ... script logic ...
  return 0
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - no main function in complex script (hard to test/organize)
#!/bin/bash
set -euo pipefail
# ... 200 lines of code directly in script ...

# ✓ Correct - main function
main() { # Script logic }
main "$@"
#fin

# ✗ Wrong - main() not at end (functions defined after execution)
main() { # ... }
main "$@"
helper_function() { # ... }  # Defined after main executes!

# ✓ Correct - main() at end, called last
helper_function() { # ... }
main() { # Can call helper_function }
main "$@"
#fin

# ✗ Wrong - parsing arguments outside main
verbose=0
while (($#)); do # ... parse args ... ; done
main() { # Uses globals }
main "$@"  # Arguments already consumed!

# ✓ Correct - parsing in main
main() {
  local -i verbose=0
  while (($#)); do # ... ; done
  readonly -- verbose
}
main "$@"

# ✗ Wrong - not passing arguments
main  # Missing "$@"!

# ✓ Correct
main "$@"

# ✗ Wrong - mixing global and local logic
total=0  # Global
main() {
  local -i count=0
  ((total+=count))  # Mixes global/local
}

# ✓ Correct - all logic in main
main() {
  local -i total=0 count=0
  total+=count
}
```

**Edge cases:**

**1. Script needs global configuration:**
```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done
  readonly -- VERBOSE DRY_RUN
}
main "$@"
```

**2. Library and executable (dual-purpose):**
```bash
utility_function() { # ... }

main() { # ... }

[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"
#fin
```

**3. Multiple main scenarios (subcommands):**
```bash
main_install() { # Installation logic }
main_uninstall() { # Uninstallation logic }

main() {
  local -- mode="${1:-}"
  case "$mode" in
    install) shift; main_install "$@" ;;
    uninstall) shift; main_uninstall "$@" ;;
    *) die 22 "Invalid mode: $mode" ;;
  esac
}
main "$@"
```

**Testing with main():**
```bash
# Script: myapp.sh
main() {
  local -i value="$1"
  ((value * 2))
  echo "$value"
}
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"

# Test file: test_myapp.sh
#!/bin/bash
source ./myapp.sh  # Source without executing
result=$(main 5)
[[ "$result" == "10" ]] && echo "PASS" || echo "FAIL: Expected 10, got ${result@Q}"
```

**Key principles:**
- Use main() for scripts >200 lines
- Place main() at end, define helpers first
- Always call with `main "$@"`
- Parse arguments in main, make locals readonly after parsing
- Return 0 for success, non-zero for errors
- Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- main() is the orchestrator - heavy lifting in helper functions
