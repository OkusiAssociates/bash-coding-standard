## Main Function

**Always include a `main()` function for scripts longer than ~200 lines. Place `main "$@"` at the bottom of the script, just before `#fin`.**

**Rationale:**
- Single entry point with clear execution flow
- Testability: source scripts without executing; test functions individually
- Scope control: local variables prevent global namespace pollution
- Centralized argument parsing, exit code handling, and debugging

**When to use main():**
```bash
# Use main() when: >200 lines, multiple functions, argument parsing, complex logic, testability needed
# Skip main() when: trivial (<200 lines), simple wrapper, no functions, linear flow
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
  while (($#)); do case $1 in
    -h|--help) show_help; return 0 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  info 'Starting processing...'
  return 0
}

main "$@"
#fin
```

**Main function with argument parsing:**
```bash
main() {
  local -i verbose=0 dry_run=0
  local -- output_file=''
  local -a input_files=()

  while (($#)); do case $1 in
    -n|--dry-run) dry_run=1 ;;
    -o|--output)
      noarg "$@"
      shift
      output_file=$1
      ;;
    -v|--verbose) verbose=1 ;;
    -q|--quiet)   verbose=0 ;;
    -h|--help)    usage; return 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            input_files+=("$1") ;;
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
  return 0
}

main "$@"
#fin
```

**Main function enabling sourcing for tests:**
```bash
# Only execute main if script is run directly (not sourced)
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail

main() {
  return 0
}

main "$@"
#fin
```

**Anti-patterns to avoid:**
```bash
# ✗ Wrong - no main function in complex script (200+ lines)
#!/bin/bash
# ... 200 lines of code directly in script - hard to test/organize

# ✓ Correct - main function
main() { ... }
main "$@"
#fin

# ✗ Wrong - main() not at end (functions defined after main executes)
main() { ... }
main "$@"
helper_function() { ... }  # Defined AFTER main is called!

# ✓ Correct - main() at end, called last
helper_function() { ... }
main() { ... }
main "$@"
#fin

# ✗ Wrong - parsing arguments outside main
verbose=0
while (($#)); do ... done  # Arguments consumed!
main() { ... }
main "$@"  # No arguments left!

# ✓ Correct - parsing in main
main() {
  local -i verbose=0
  while (($#)); do ... done
  readonly -- verbose
}
main "$@"

# ✗ Wrong - not passing arguments
main  # Missing "$@"!

# ✓ Correct
main "$@"
```

**Edge cases:**

**1. Script needs global configuration:**
```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done
  readonly -- VERBOSE DRY_RUN
}
main "$@"
```

**2. Script is library and executable:**
```bash
utility_function() { ... }
main() { ... }

# Only run main if executed (not sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"
#fin
```

**3. Multiple main scenarios (subcommands):**
```bash
main_install() { ... }
main_uninstall() { ... }

main() {
  local -- mode=${1:-}
  case "$mode" in
    install)   shift; main_install "$@" ;;
    uninstall) shift; main_uninstall "$@" ;;
    *) die 22 "Invalid mode ${mode@Q}" ;;
  esac
}
main "$@"
```

**Summary:**
- **Use main() for scripts >200 lines** - organization and testability
- **Place main() at end** - define helpers first, main last
- **Always call with `main "$@"`** - pass all arguments
- **Parse arguments in main** - keep argument handling centralized
- **Make locals readonly after parsing** - immutable option state
- **Consider sourcing** - use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- **main() is the orchestrator** - coordinates helpers, doesn't do heavy lifting
