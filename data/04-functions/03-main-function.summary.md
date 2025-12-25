## Main Function

**Always include a `main()` function for scripts longer than approximately 200 lines. Place `main "$@"` at the bottom of the script, just before the `#fin` marker.**

**Rationale:**

- **Single Entry Point**: Clear execution flow from one well-defined function
- **Testability**: Scripts can be sourced without executing; functions tested individually
- **Organization**: Separates initialization, parsing, and logic into clear sections
- **Debugging**: Central location for debugging output or dry-run logic
- **Scope Control**: Local variables prevent global namespace pollution
- **Exit Code Management**: Centralized return/exit handling

**When to use main():** Scripts >200 lines, multiple functions, argument parsing, testability required, complex logic flow

**Basic structure:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Functions
# ... helper functions ...

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  # Main logic
  info 'Starting processing...'

  return 0
}

main "$@"
#fin
```

**With argument parsing:**

```bash
main() {
  local -i verbose=0 dry_run=0
  local -- output_file=''
  local -a input_files=()

  # Parse arguments
  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output) noarg "$@"; shift; output_file="$1" ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option: $1" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  input_files+=("$@")
  readonly -- verbose dry_run output_file
  readonly -a input_files

  # Validate
  [[ ${#input_files[@]} -eq 0 ]] && { error 'No input files'; usage; return 22; }

  # Main logic
  ((verbose)) && info "Processing ${#input_files[@]} files"

  for file in "${input_files[@]}"; do
    process_file "$file"
  done

  return 0
}
```

**With setup/cleanup:**

```bash
cleanup() {
  local -i exit_code=$?
  [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
  return "$exit_code"
}

main() {
  trap cleanup EXIT
  TEMP_DIR=$(mktemp -d)
  readonly -- TEMP_DIR

  info "Using temp directory: $TEMP_DIR"
  # ... processing ...

  return 0
}

main "$@"
#fin
```

**With error handling:**

```bash
main() {
  local -i errors=0

  for item in "${items[@]}"; do
    if ! process_item "$item"; then
      error "Failed to process: $item"
      ((errors+=1))
    fi
  done

  if ((errors > 0)); then
    error "Completed with $errors errors"
    return 1
  else
    success 'All items processed successfully'
    return 0
  fi
}
```

**Enabling sourcing for tests:**

```bash
main() {
  # ... script logic ...
  return 0
}

# Only execute if run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#fin
```

**Anti-patterns:**

```bash
#  Wrong - no main function in complex script (>200 lines)
#!/bin/bash
set -euo pipefail
# ... 200 lines of code directly in script ...

#  Correct
main() {
  # Script logic
}
main "$@"
#fin

#  Wrong - main() called before all functions defined
main() { }
main "$@"
helper_function() { }  # Defined AFTER main executes!

#  Correct
helper_function() { }
main() { }
main "$@"
#fin

#  Wrong - parsing arguments outside main
verbose=0
while (($#)); do
  # ... parse args ...
done
main() { }
main "$@"  # Arguments already consumed!

#  Correct
main() {
  local -i verbose=0
  while (($#)); do
    # ... parse args ...
  done
  readonly -- verbose
}
main "$@"

#  Wrong - not passing arguments
main() { }
main  # Missing "$@"!

#  Correct
main "$@"
```

**Edge cases:**

**1. Global configuration:**

```bash
declare -i VERBOSE=0 DRY_RUN=0

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN
}

main "$@"
```

**2. Library and executable:**

```bash
utility_function() { }

main() { }

# Only run main if executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
#fin
```

**3. Multiple modes:**

```bash
main_install() { }
main_uninstall() { }

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

**Testing pattern:**

```bash
# Script: myapp.sh
main() {
  local -i value="$1"
  ((value * 2))
  echo "$value"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

# Test file: test_myapp.sh
#!/bin/bash
source ./myapp.sh  # Source without executing
result=$(main 5)
[[ "$result" == "10" ]] && echo "PASS" || echo "FAIL"
```

**Summary:**

- Use main() for scripts >200 lines
- Single entry point for all execution
- Place main() at end, after all helper functions
- Always call with `main "$@"`
- Parse arguments in main, make locals readonly after parsing
- Return 0 for success, non-zero for errors
- Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- Organize: messaging ’ documentation ’ helpers ’ business logic ’ main
- Main orchestrates, helpers do the work
