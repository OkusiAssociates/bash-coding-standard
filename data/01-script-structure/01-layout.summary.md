## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency and correctness. Bottom-up organization places low-level utilities before high-level orchestration, allowing each component to safely call previously defined functions.**

See: **BCS010101** (complete example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Developers know exactly where to find components: metadata (step 6), utilities (step 9), business logic (step 10)
2. **Safe Initialization** - Error handling established before any commands run; globals declared before code references them
3. **Bottom-Up Dependency** - Each function can safely call functions defined above it
4. **Testing** - Source script to test individual functions; consistent structure simplifies debugging
5. **Error Prevention** - Strict ordering prevents undefined functions, uninitialized variables, premature business logic
6. **Production Readiness** - Includes version tracking, error handling, terminal detection, argument validation

---

## The 13 Mandatory Steps

### Step 1: Shebang

```bash
#!/bin/bash
```

**Alternatives:** `#!/usr/bin/bash` or `#!/usr/bin/env bash`

### Step 2: ShellCheck Directives (if needed)

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
```

**Always include explanatory comments** for disabled checks.

### Step 3: Brief Description Comment

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`

```bash
set -euo pipefail
```

- `set -e` - Exit on any command failure
- `set -u` - Exit on undefined variable reference
- `set -o pipefail` - Pipelines fail if any command fails

**This MUST come before any commands** (except shebang/comments/shellcheck).

**Optional Bash >= 5 test** (if really necessary):
```bash
set -euo pipefail
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- `inherit_errexit` - Subshells inherit set -e
- `shift_verbose` - Catches argument parsing bugs
- `extglob` - Extended pattern matching: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing (critical for `for file in *.txt`)

### Step 6: Script Metadata

```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

SC2155 warnings can be safely ignored when using `realpath` or `readlink`.

### Step 7: Global Variable Declarations

```bash
declare -- PREFIX=/usr/local
declare -- CONFIG_FILE=''
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -a INPUT_FILES=()
declare -A CONFIG=()
```

- `declare -i` for integers (enables arithmetic context)
- `declare --` for strings
- `declare -a` for indexed arrays
- `declare -A` for associative arrays

### Step 8: Color Definitions (if terminal output)

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

### Step 9: Utility Functions

```bash
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
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**Simplified version** for scripts without color/verbosity:
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
error() { >&2 echo "${FUNCNAME[0]}: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Production optimization:** Remove unused functions after script is mature.

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
    info "[DRY-RUN] Would install files from ${source_dir@Q} to ${target_dir@Q}"
    return 0
  fi
  mkdir -p "$target_dir" || die 1 "Failed to create target directory"
  cp -r "$source_dir"/* "$target_dir"/
}
```

**Organize bottom-up:** Lower-level functions first, higher-level later.

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

**Exception:** Scripts under 100 lines can skip `main()`.

### Step 12: Script Invocation

```bash
main "$@"
```

**ALWAYS quote `"$@"`** to preserve argument array.

### Step 13: End Marker

```bash
#fin
```

OR `#end`. Visual confirmation script is complete (not truncated).

---

## Structure Summary Tables

### Executable Scripts (Man=Mandatory, Opt=Optional, Rec=Recommended)

| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck directives |
| 2 | Opt | Description comment |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 version test |
| 5 | Rec | `shopt` settings |
| 6 | Rec | Script Metadata |
| 7 | Rec | Global Variable Declarations |
| 8 | Rec | Color Definitions |
| 9 | Rec | Utility Functions |
| 10 | Rec | Business Logic Functions |
| 11 | Rec | `main()` function |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` marker |

### Module/Library Scripts

Skip steps 3, 5, 11, 12. Business logic (step 10) is mandatory.

### Combined Module/Executable Scripts

Include dual-purpose guard: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`
After guard, repeat steps 3-13 for executable section.

---

## Anti-Patterns (See BCS010102)

1. Missing `set -euo pipefail`
2. Variables used before declaration
3. Business logic before utilities
4. No `main()` in large scripts
5. Missing end marker
6. Premature `readonly`
7. Scattered declarations
8. Unprotected sourcing

## Edge Cases (See BCS010103)

1. **Tiny scripts (<100 lines)** - May skip `main()`
2. **Sourced libraries** - Skip `set -e`, `main()`, invocation
3. **External configuration** - Add config sourcing after step 7
