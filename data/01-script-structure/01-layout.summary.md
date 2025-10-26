## General Layouts for Standard Script

**All Bash scripts must follow a 13-step structural layout ensuring consistency, maintainability, and correctness. Bottom-up organization places low-level utilities before high-level orchestration.**

References: **BCS010101** (complete example), **BCS010102** (anti-patterns), **BCS010103** (edge cases)

---

## Rationale

1. **Predictability** - Components in expected locations (metadata step 6, utilities step 9, business logic step 10, main step 11)
2. **Safe Initialization** - Infrastructure established before use: error handling before commands, metadata before functions, globals before references
3. **Bottom-Up Dependency** - Lower-level components defined first. Each function safely calls previously defined functions
4. **Testing/Maintenance** - Source scripts to test functions, extract utilities, understand code quickly
5. **Error Prevention** - Ordering prevents undefined functions, uninitialized variables, premature logic execution
6. **Documentation Through Structure** - Layout documents organization: infrastructure (1-8) → implementation (9-10) → orchestration (11-12)
7. **Production Readiness** - Version tracking, error handling, terminal detection, argument validation, clear flow

---

## The 13 Mandatory Steps

### Step 1: Shebang

```bash
#!/bin/bash
#!/usr/bin/bash
#!/usr/bin/env bash
```

`env` approach: portable, respects PATH. For dual-purpose scripts, shebang can indicate executable section start.

### Step 2: ShellCheck Directives (if needed)

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
```

Always include explanatory comments. Use only when necessary.

### Step 3: Brief Description Comment

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

### Step 4: `set -euo pipefail`

**Mandatory - MUST precede all commands:**

```bash
set -euo pipefail
```

- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

**Optional Bash >= 5 test:**
```bash
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; }
```

### Step 5: `shopt` Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- `inherit_errexit` - Subshells inherit `set -e`
- `shift_verbose` - Catch argument parsing bugs
- `extglob` - Extended pattern matching
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata

```bash
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Alternative:** `$(realpath -- "$0")`

**Namespace-locked:**
```bash
[[ -v ALX_VERSION ]] || {
  declare -xr ALX_VERSION='1.0.0'
  #shellcheck disable=SC2155
  declare -xr ALX_PATH=$(realpath -- "${BASH_SOURCE[0]}")
  declare -xr ALX_DIR=${ALX_PATH%/*} ALX_NAME=${ALX_PATH##*/}
}
```

**Note:** SC2155 safely ignored with `realpath`. May be builtin (10x faster).

### Step 7: Global Variable Declarations

```bash
# Configuration
declare -- PREFIX='/usr/local'
declare -- CONFIG_FILE=''

# Runtime state
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i FORCE=0

# Arrays
declare -a INPUT_FILES=()
declare -a WARNINGS=()
```

**Types:** `declare -i` (integers), `declare --` (strings), `declare -a` (indexed), `declare -A` (associative)

### Step 8: Color Definitions (if terminal output)

**Preferred:**
```bash
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Alternative (tput):**
```bash
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  RESET=$(tput sgr0)
  readonly -- RED GREEN RESET
else
  declare -r RED='' GREEN='' RESET=''
fi
```

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
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**Simplified (no colors):**
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
error() { >&2 echo "${FUNCNAME[0]}: $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

Remove unused functions in production.

### Step 10: Business Logic Functions

```bash
check_prerequisites() {
  local -i missing=0
  local -- cmd

  for cmd in git make gcc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Required command not found '$cmd'"
      missing+=1
    fi
  done

  ((missing==0)) || die 1 "Missing $missing required commands"
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist '$PREFIX'"
  success 'Configuration validated'
}

install_files() {
  local -- source_dir=$1 target_dir=$2

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install from '$source_dir' to '$target_dir'"
    return 0
  fi

  [[ -d "$source_dir" ]] || die 2 "Source not found '$source_dir'"
  mkdir -p "$target_dir" || die 1 "Cannot create '$target_dir'"
  cp -r "$source_dir"/* "$target_dir"/ || die 1 'Installation failed'
  success "Installed to '$target_dir'"
}
```

Organize low-level first (validation, file ops), then higher-level (orchestration).

### Step 11: `main()` Function and Argument Parsing

**Required for scripts >200 lines:**

```bash
main() {
  # Parse arguments
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift; PREFIX="$1" ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--force)    FORCE=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
      -h|--help)     usage; exit 0 ;;

      -[pvqnfVh]*) #shellcheck disable=SC2046
                   set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
      -*)          die 22 "Invalid option: $1" ;;
      *)           INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  # Make readonly after parsing
  readonly -- PREFIX CONFIG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  # Execute workflow
  ((DRY_RUN==0)) || info 'DRY-RUN mode enabled'

  check_prerequisites
  validate_config
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share

  success 'Installation complete'
}
```

**Why:** Testing (source and test), organization (single entry), scoping (local parsing vars), debugging (hooks)

**Exception:** Scripts <100 lines can skip `main()`.

### Step 12: Script Invocation

```bash
main "$@"
```

Always quote `"$@"`. For scripts without `main()`, write business logic here.

### Step 13: End Marker

```bash
#fin
```

Or `#end`. Confirms completeness (not truncated), tool compatibility, consistency.

---

## Anti-Patterns

See **BCS010102**:
1. Missing `set -euo pipefail`
2. Variables used before declaration
3. Business logic before utilities
4. No `main()` in large scripts
5. Missing end marker
6. Premature `readonly`
7. Scattered declarations
8. Unprotected sourcing

---

## Edge Cases

See **BCS010103**:
1. Tiny scripts (<200 lines) - May skip `main()`
2. Sourced libraries - Skip `set -e`, `main()`, invocation
3. External configuration - Add config sourcing
4. Platform-specific code - Add platform detection
5. Cleanup traps - Add trap handlers

---

## Structural Tables

### Executable Scripts

| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1 | Opt | ShellCheck |
| 2 | Opt | Description |
| 3 | Man | `set -euo pipefail` |
| 4 | Opt | Bash 5 test |
| 5 | Rec | `shopt` |
| 6 | Rec | Metadata |
| 7 | Rec | Globals |
| 8 | Rec | Colors |
| 9 | Rec | Utilities |
| 10 | Rec | Business logic |
| 11 | Rec | `main()` |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` |

### Module/Library Scripts

| Order | Status | Step |
|-------|--------|------|
| 0 | Man | Shebang |
| 1-9 | Opt | See executable (skip step 3) |
| 10 | Rec | Business logic |
| 13 | Man | `#end` |

### Dual-Purpose Scripts

| Order | Step |
|-------|------|
| 0-10 | Module section |
| 14 | `[[ "${BASH_SOURCE[0]}" == "$0" ]] \|\| return 0` |
| 14.0-14.13 | Executable section |

---

## Summary

**13-step layout strongly recommended:**

1. **Safety** - Error handling first
2. **Consistency** - Same pattern everywhere
3. **Testing** - `main()` enables sourcing
4. **Error Prevention** - Dependencies defined before use
5. **Documentation** - Structure reveals intent
6. **Maintenance** - Predictable organization

**Scripts >100 lines:** All 13 steps
**Scripts <100 lines:** Steps 11-12 optional

Use complete structure when in doubt. Deviations rare and well-justified.
