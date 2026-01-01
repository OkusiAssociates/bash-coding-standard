## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency, maintainability, and correctness. Bottom-up organization places low-level utilities before high-level orchestration, allowing each component to safely call previously defined functions.**

For detailed examples: **BCS010101** (462-line example), **BCS010102** (anti-patterns), **BCS010103** (edge cases).

---

## Rationale

1. **Predictability** - Developers know where to find components: metadata (step 6), utilities (step 9), business logic (step 10)
2. **Safe Initialization** - Error handling configured before commands run; metadata available before functions execute
3. **Bottom-Up Dependency Resolution** - Lower-level components defined before higher-level ones
4. **Testing/Maintenance** - Source scripts to test functions; extract utilities for reuse
5. **Error Prevention** - Prevents undefined functions, uninitialized variables, premature business logic
6. **Documentation Through Structure** - Progression from infrastructure (1-8) â†' implementation (9-10) â†' orchestration (11-12)

---

## The 13 Mandatory Steps

### Step 1: Shebang
```bash
#!/bin/bash
```
**Alternatives:** `#!/usr/bin/bash` or `#!/usr/bin/env bash` (portable, respects PATH)

### Step 2: ShellCheck Directives (if needed)
```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
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

**Optional Bash 5 test** (immediately after, if needed):
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```
- `inherit_errexit` - Subshells inherit `set -e`
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Extended pattern matching: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
SC2155 safely ignored with `realpath`. On BCS systems, `realpath` may be a builtin (10x faster).

### Step 7: Global Variable Declarations
```bash
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''
declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -a INPUT_FILES=()
declare -A OPTIONS=()
```
Type declarations: `-i` integers, `--` strings, `-a` indexed arrays, `-A` associative arrays.

### Step 8: Color Definitions (if terminal output)
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```
Skip if script doesn't use colored output.

### Step 9: Utility Functions
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
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
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo; [[ ${REPLY,,} == y ]]
}
```

**Simplified messaging** (no color/verbosity):
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

install_files() {
  local -- source_dir=$1 target_dir=$2
  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install from ${source_dir@Q} to ${target_dir@Q}"
    return 0
  fi
  mkdir -p "$target_dir" || die 1 "Failed to create ${target_dir@Q}"
  cp -r "$source_dir"/* "$target_dir"/
}
```
Organize bottom-up: validation â†' file operations â†' orchestration.

### Step 11: `main()` Function
```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX=$1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     usage; return 0 ;;
      -[pvnVh]*)     #shellcheck disable=SC2046
                     set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done
  readonly -- PREFIX
  readonly -i VERBOSE DRY_RUN

  check_prerequisites
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share
}
```
**Required for scripts >100 lines.** Single entry point for testing/debugging.

### Step 12: Script Invocation
```bash
main "$@"
```

### Step 13: End Marker
```bash
#fin
```
Or `#end`. Confirms script is complete (not truncated).

---

## Structure Summary Tables

### Executable Scripts
| Step | Status | Element |
|------|--------|---------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description comment |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 version test |
| 5 | Rec | `shopt` settings |
| 6 | Rec | Script metadata |
| 7 | Rec | Global declarations |
| 8 | Rec | Color definitions |
| 9 | Rec | Utility functions |
| 10 | Rec | Business logic |
| 11 | Rec | `main()` function |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` marker |

### Module/Library Scripts
Skip steps 3, 5, 11, 12. Add `#end` marker.

### Combined Module-Executable
Add guard: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`
Then repeat steps 3-13 for executable section.

---

## Anti-Patterns

1. **Missing `set -euo pipefail`** - Must be first command
2. **Variables used before declaration** - Declare all globals in step 7
3. **Business logic before utilities** - Utilities must exist before callers
4. **No `main()` in large scripts** - Required for testability
5. **Missing end marker** - `#fin` or `#end` mandatory

See **BCS010102** for corrections.

---

## Edge Cases

1. **Tiny scripts (<100 lines)** - May skip `main()`
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation
3. **External configuration** - Add config sourcing after metadata

See **BCS010103** for details.

---

## Summary

The 13-step layout guarantees safety, consistency, testability, and maintainability. For scripts >100 lines, implement all steps. For smaller scripts, steps 11-12 optional. Deviations should be rare and justified.
