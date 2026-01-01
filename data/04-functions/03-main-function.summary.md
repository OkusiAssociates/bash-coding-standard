## Main Function

**Always include a `main()` function for scripts longer than ~200 lines. Place `main "$@"` at bottom, just before `#fin`.**

**Rationale:**
- Single entry point with clear execution flow
- Testability: source scripts without executing; test functions individually
- Scope control: locals in main prevent global pollution
- Centralized argument parsing, debugging, and exit code management

**When to use:**
```bash
# Use main() when: >200 lines, multiple functions, argument parsing, testable, complex logic
# Skip main() when: <200 lines, simple wrapper, no functions, linear flow
```

**Basic structure:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Functions...

main() {
  while (($#)); do case $1 in
    -h|--help) usage; return 0 ;;
    *) die 22 "Invalid option ${1@Q}" ;;
  esac; shift; done

  info 'Starting processing...'
  return 0
}

main "$@"
#fin
```

**Main with argument parsing and cleanup:**
```bash
cleanup() {
  local -i exit_code=${1:-$?}
  [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
  return "$exit_code"
}

main() {
  trap cleanup EXIT

  local -i verbose=0 dry_run=0
  local -- output_file=''
  local -a input_files=()

  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -n|--dry-run) dry_run=1 ;;
    -o|--output) noarg "$@"; shift; output_file=$1 ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid option ${1@Q}" ;;
    *) input_files+=("$1") ;;
  esac; shift; done

  input_files+=("$@")
  readonly -- verbose dry_run output_file
  readonly -a input_files

  if ((${#input_files[@]} == 0)); then
    error 'No input files specified'; usage; return 22
  fi

  ((verbose)) && info "Processing ${#input_files[@]} files"
  ((dry_run)) && info '[DRY-RUN] Mode enabled'

  local -- file
  for file in "${input_files[@]}"; do
    process_file "$file"
  done

  return 0
}

main "$@"
#fin
```

**Main with error tracking:**
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
    error "Completed with $errors errors"; return 1
  fi
  success 'All items processed successfully'
}
```

**Sourceable for testing:**
```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail

main() { : ...; return 0; }
main "$@"
#fin
```

**Anti-patterns:**
```bash
# ✗ Wrong - no main in complex script
#!/bin/bash
# ... 200 lines directly in script (untestable)

# ✓ Correct
main() { : ... }
main "$@"
#fin

# ✗ Wrong - main() not at end
main() { : ... }
main "$@"
helper_function() { : ... }  # Defined after main executes!

# ✓ Correct - define helpers first
helper_function() { : ... }
main() { : ... }
main "$@"
#fin

# ✗ Wrong - parsing outside main
verbose=0
while (($#)); do : ...; done  # Args consumed!
main() { : ... }
main "$@"  # No args left!

# ✓ Correct - parse in main
main() {
  local -i verbose=0
  while (($#)); do : ...; done
  readonly -- verbose
}
main "$@"

# ✗ Wrong - not passing arguments
main  # Missing "$@"!

# ✓ Correct
main "$@"

# ✗ Wrong - mixing global and local
total=0  # Global
main() {
  local -i count=0
  ((total+=count))  # Mixed state
}

# ✓ Correct - all local
main() {
  local -i total=0 count=0
  total+=count
}
```

**Edge cases:**

**1. Global configuration:**
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

**2. Library and executable:**
```bash
utility_function() { : ...; }

main() { : ...; }

[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return
main "$@"
#fin
```

**3. Multiple modes:**
```bash
main_install() { : ...; }
main_uninstall() { : ...; }

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

**Summary:**
- Use main() for scripts >200 lines
- Place main() at end, call with `main "$@"`
- Parse arguments in main, make locals readonly after
- Return 0 for success, non-zero for errors
- Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` for testability
- main() orchestrates—delegates work to helper functions
