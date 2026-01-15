## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency and correctness. This bottom-up pattern places utilities before orchestration, allowing each component to call previously defined functions.**

See: **BCS010101** (working example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Developers know where to find components: metadata step 6, utilities step 9, business logic step 10
2. **Safe Initialization** - Error handling before commands, metadata before functions, globals before references
3. **Bottom-Up Dependencies** - Lower-level components defined before higher-level ones that depend on them
4. **Testing** - Source script to test individual functions; consistent structure aids debugging
5. **Error Prevention** - Strict ordering prevents undefined functions, uninitialized variables, premature execution
6. **Production Readiness** - Includes version tracking, error handling, terminal detection, argument validation

---

## The 13 Mandatory Steps

### Step 1: Shebang
```bash
#!/bin/bash
```
Alternatives: `#!/usr/bin/bash` or `#!/usr/bin/env bash` (portable, respects PATH)

### Step 2: ShellCheck Directives (if needed)
```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
```
Always include explanatory comments for disabled checks.

### Step 3: Brief Description Comment
```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`
```bash
set -euo pipefail
```
- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

**MUST come before any commands.** Optional Bash 5 check:
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```
- `inherit_errexit` - Subshells inherit set -e
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Extended patterns: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
SC2155 can be safely ignored with `realpath`. On some systems `realpath` is a builtin (10x faster).

### Step 7: Global Variable Declarations
```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- CONFIG_FILE='' LOG_FILE=''
declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -a INPUT_FILES=() WARNINGS=()
```
Type declarations: `declare -i` integers, `declare --` strings, `declare -a` indexed arrays, `declare -A` associative arrays.

### Step 8: Color Definitions (if terminal output)
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```
Skip if no colored output needed.

### Step 9: Utility Functions
```bash
declare -i VERBOSE=1

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho)   : ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-'Continue?'} y/n "
  echo
  [[ ${REPLY,,} == y ]]
}
```

Simple alternative for scripts without color:
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
error() { >&2 echo "${FUNCNAME[0]}: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Step 10: Business Logic Functions
```bash
check_prerequisites() {
  local -i missing=0
  local -- cmd
  for cmd in git make gcc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found ${cmd@Q}"
      missing+=1
    fi
  done
  ((missing==0)) || die 1 "Missing $missing required commands"
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist ${PREFIX@Q}"
}
```
Organize bottom-up: lower-level functions first, higher-level later.

### Step 11: `main()` Function
```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX=$1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     show_help; return 0 ;;
      -[pvqnfVh]*) #shellcheck disable=SC2046
                     set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done
  readonly -- PREFIX CONFIG_FILE LOG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  check_prerequisites
  validate_config
}
```
Required for scripts >200 lines. Exception: scripts <100 lines can skip `main()`.

### Step 12: Script Invocation
```bash
main "$@"
```
**ALWAYS quote `"$@"`** to preserve argument array.

### Step 13: End Marker
```bash
#fin
```
OR `#end`. Confirms script is complete (not truncated).

---

## Structure Summary Tables

### Executable Scripts
| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description comment |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 version test |
| 5 | Rec | `shopt` settings |
| 6 | Rec | Script Metadata |
| 7 | Rec | Global Variables |
| 8 | Rec | Color Definitions |
| 9 | Rec | Utility Functions |
| 10 | Rec | Business Logic |
| 11 | Rec | `main()` |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` Marker |

### Module/Library Scripts
Skip steps 3 (`set -e`), 11-12 (`main`). Step 10 (Business Logic) is Rec.

### Combined Module+Executable
Add step 14: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` then repeat steps 0-13 for executable portion.

---

## Anti-Patterns

1. **Missing `set -euo pipefail`** - Must be first command
2. **Variables before declaration** - All globals declared upfront in step 7
3. **Business logic before utilities** - Messaging functions must exist before code calls them
4. **No `main()` in large scripts** - Required for >200 lines
5. **Missing end marker** - `#fin` or `#end` mandatory

---

## Edge Cases

1. **Tiny scripts (<100 lines)** - May skip `main()`, steps 11-12
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation; keep shebang and end marker
3. **Combined module+executable** - Use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` guard
