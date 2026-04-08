# Section 04: Functions & Libraries

## BCS0400 Section Overview

Organize functions bottom-up: messaging first, then helpers, then business logic, with `main()` last. Each function can safely call previously defined functions.

## BCS0401 Function Definition

Use single-line format for simple operations, multi-line for complex functions.

```bash
# correct — single-line
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# correct — multi-line
process_file() {
  local -- filename=$1
  local -i line_count=0

  [[ -f $filename ]] || return 1

  while IFS= read -r line; do
    line_count+=1
  done < "$filename"

  return 0
}
```

Declare local variables before use, grouped near the function top when practical. Declarations may appear mid-body (e.g., after early-return guards, inside conditionals, or between logical sections), but must not appear inside loops. Always use proper types and `return` explicitly from complex functions.

## BCS0402 Function Names

```bash
# correct
process_log_file() { :; }           # lowercase with underscores
_validate_input() { :; }            # underscore prefix for private

# wrong
ProcessLogFile() { :; }             # camelCase
PROCESS_FILE() { :; }               # UPPER_CASE
my-function() { :; }                # dashes (invalid in some contexts)
cd() { :; }                         # overriding built-in
```

Never use dashes in function names. Never override built-in commands without good reason.

## BCS0403 Main Function

Include `main()` for scripts longer than ~200 lines. Place `main "$@"` at the bottom just before `#fin`.

```bash
# correct
main() {
  # Parse arguments
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)    show_help; exit 0 ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac; shift; done

  # Make parsed variables readonly
  readonly VERBOSE DRY_RUN

  # Business logic
  process_files
}

main "$@"
#fin
```

Always call main with all arguments: `main "$@"`, never just `main`.

## BCS0404 Function Export

Export functions needed by subshells with `declare -fx`.

```bash
# correct — define first, then export
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

## BCS0405 Production Optimization

Remove unused utility functions from production scripts.

```bash
# wrong — keeping unused functions
yn() { :; }          # never called in this script
trim() { :; }        # never called in this script
debug() { :; }       # DEBUG never set in this script
```

Keep only functions and variables the script actually needs. Remove unused globals too.

## BCS0406 Dual-Purpose Scripts

For scripts that can be sourced or executed, define functions before the source fence and strict mode after it. Either fence pattern is acceptable:

```bash
# correct — BASH_SOURCE fence with conditional export
my_function() {
  local -- name=$1
  echo "Hello, $name"
}

# --- source fence ---
[[ ${BASH_SOURCE[0]} == "$0" ]] || { declare -fx my_function; return 0; }

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

```bash
# correct — return 0 fence (export unconditionally before fence)
my_function() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx my_function

return 0 2>/dev/null ||:

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

Use idempotent initialization with version guard:

```bash
[[ -v MY_LIB_VERSION ]] || {
  declare -rx MY_LIB_VERSION=1.0.0
  # other initialization
}
```

## BCS0407 Library Patterns

Pure libraries must reject direct execution.

```bash
# correct — library pattern
[[ ${BASH_SOURCE[0]} != "$0" ]] || {
  >&2 echo "Error: ${0@Q} must be sourced"
  exit 1
}

declare -rx LIB_VALIDATION_VERSION=1.0.0

# Namespace all functions
myapp_init() { :; }
myapp_cleanup() { :; }
myapp_process() { :; }
declare -fx myapp_init myapp_cleanup myapp_process
```

Libraries should only define functions, not have side effects on source. Allow configuration override before sourcing: `: "${CONFIG_DIR:=/etc/myapp}"`.

Source libraries with existence check:

```bash
[[ -f $lib_path ]] && source "$lib_path" || die 1 "Missing library ${lib_path}"
```

## BCS0408 Dependency Management

Use `command -v` for dependency checks, never `which`. POSIX/coreutils commands guaranteed on any Bash 5.2+ system (e.g., `sed`, `awk`, `grep`, `cat`, `date`, `tput`, `wc`, `stty`, `mkdir`, `rm`, `cp`, `mv`) do not require checks — only verify non-standard or separately packaged tools.

```bash
# correct — check non-standard tools
command -v curl >/dev/null || die 18 'curl required: apt install curl'

# correct — check multiple non-standard tools
for cmd in curl jq pandoc; do
  command -v "$cmd" >/dev/null || die 18 "Required: ${cmd@Q}"
done

# correct — optional dependency
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:

# correct — check bash version
((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)) || die 1 'Requires Bash 5.2+'

# wrong — using which
which curl &>/dev/null

# wrong — checking coreutils commands
command -v sed >/dev/null || die 18 'sed required'
```

Use lazy loading for expensive resources: initialize only when first needed.
