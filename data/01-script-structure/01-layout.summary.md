## General Layouts for Standard Script

**All Bash scripts follow a 13-step structural layout ensuring consistency and correctness. Bottom-up organization places utilities before business logic, allowing safe function calls. Structure is mandatory.**

See BCS010101 (complete example), BCS010102 (anti-patterns), BCS010103 (edge cases).

---

## Rationale

1. **Predictability** - Components always in known locations (metadata step 6, utilities step 9, business logic step 10)
2. **Safe Initialization** - Error handling configured before commands run; metadata available before functions execute
3. **Bottom-Up Dependencies** - Lower-level components defined before higher-level ones that depend on them
4. **Testing/Maintenance** - Source scripts to test functions; consistent structure aids debugging
5. **Error Prevention** - Strict ordering prevents undefined functions, uninitialized variables, premature execution
6. **Production Readiness** - Includes version tracking, error handling, terminal detection, argument validation

---

## The 13 Mandatory Steps

### Step 1: Shebang

```bash
#!/bin/bash
```

**Alternatives:**
```bash
#!/usr/bin/bash
#!/usr/bin/env bash
```

`env` approach is portable across systems where bash location varies.

### Step 2: ShellCheck Directives (if needed)

```bash
#shellcheck disable=SC2034  # Unused variables OK (sourced by other scripts)
#shellcheck disable=SC1091  # Don't follow sourced files
#shellcheck disable=SC2155  # I promise I'll be good.
```

**Always include explanatory comments** for disabled checks.

### Step 3: Brief Description Comment

```bash
# Comprehensive installation script with configurable paths and dry-run mode
```

One-line purpose statement—not a full header block.

### Step 4: `set -euo pipefail`

```bash
set -euo pipefail
```

- `set -e` - Exit on command failure
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Pipelines fail if any command fails

**MUST come before any commands** (except shebang/comments/shellcheck).

**Optional Bash >= 5 test** (if really necessary):
```bash
#!/bin/bash
#shellcheck disable=1090
# Backup program for sql databases
set -euo pipefail
((${BASH_VERSINFO[0]:-0} > 4)) || { >&2 echo 'error: Require Bash version >= 5'; exit 95; } # check bash version >= 5

```

### Step 5: `shopt` Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- `inherit_errexit` - Subshells inherit set -e
- `shift_verbose` - Warn on shift with no arguments
- `extglob` - Extended pattern matching: `@(pattern)`, `!(pattern)`
- `nullglob` - Empty globs expand to nothing

### Step 6: Script Metadata

```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

- `VERSION` - For --version, logging, compatibility
- `SCRIPT_PATH` - Absolute canonical path (resolves symlinks)
- `SCRIPT_DIR` - Directory for relative file access
- `SCRIPT_NAME` - Basename for messages, logging

**Alternative with namespace:**
```bash
[[ -v ALX_VERSION ]] || {
  declare -xr ALX_VERSION=1.0.0
  #shellcheck disable=SC2155
  declare -xr ALX_PATH=$(realpath -- "${BASH_SOURCE[0]}")
  declare -xr ALX_DIR=${ALX_PATH%/*} ALX_NAME=${ALX_PATH##*/}
}
```

SC2155 can be safely ignored with `realpath`/`readlink`.

### Step 7: Global Variable Declarations

```bash
# Configuration variables
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- CONFIG_FILE=''
declare -- LOG_FILE=''

# Runtime state
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i FORCE=0

# Arrays for accumulation
declare -a INPUT_FILES=()
declare -a WARNINGS=()
```

**Type declarations:**
- `declare -i` for integers
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

Colors only work on terminals—skip when piped/redirected.

### Step 9: Utility Functions

```bash
declare -i VERBOSE=1
#declare -i DEBUG=0 PROMPT=1

# _Core messaging function using FUNCNAME
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    vecho)   : ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
#    debug)   prefix+=" ${CYAN}DEBUG${NC}" ;;
    success) prefix+=" ${GREEN}✓${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Verbose output (respects VERBOSE flag)
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
# Info messages
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
# Warnings (non-fatal)
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
# Debug output (respects DEBUG flag)
#debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
# Success messages
success() { ((VERBOSE)) || return 0; >&2 _msg "$@" || return 0; }
# Error output (unconditional)
error() { >&2 _msg "$@"; }
# Exit with error
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
# Yes/no prompt
yn() {
  #((PROMPT)) || return 0
  local -- REPLY
  read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-'Continue?'} y/n "
  echo
  [[ ${REPLY,,} == y ]]
}
```

**Simplified alternative** for scripts without color/verbosity:
```bash
info() { >&2 echo "${FUNCNAME[0]}: $*"; }
debug() { >&2 echo "${FUNCNAME[0]}: $*"; }
success() { >&2 echo "${FUNCNAME[0]}: $*"; }
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
  success 'All prerequisites satisfied'
}

validate_config() {
  [[ -n "$PREFIX" ]] || die 22 'PREFIX cannot be empty'
  [[ -d "$PREFIX" ]] || die 2 "PREFIX directory does not exist ${PREFIX@Q}"
  success 'Configuration validated'
}

install_files() {
  local -- source_dir=$1
  local -- target_dir=$2
  if ((DRY_RUN)); then
    info "[DRY-RUN] Would install files from ${source_dir@Q} to ${target_dir@Q}"
    return 0
  fi
  [[ -d "$source_dir" ]] || die 2 "Source directory not found ${source_dir@Q}"
  mkdir -p "$target_dir" || die 1 "Failed to create target directory ${target_dir@Q}"
  cp -r "$source_dir"/* "$target_dir"/ || die 1 'Installation failed'
  success "Installed files to ${target_dir@Q}"
}
```

**Organize bottom-up:** Lower-level functions first, higher-level later.

### Step 11: `main()` Function and Argument Parsing

```bash
main() {
  while (($#)); do
    case $1 in
      -p|--prefix)   noarg "$@"; shift
                     PREFIX=$1 ;;
      -v|--verbose)  VERBOSE+=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--force)    FORCE=1 ;;
      -V|--version)  echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)     show_help; return 0 ;;
      -[pvqnfVh]?*)  # Bundled short options
                     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      -*)            die 22 "Invalid option ${1@Q}" ;;
      *)             INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  readonly -- PREFIX CONFIG_FILE LOG_FILE
  readonly -i VERBOSE DRY_RUN FORCE

  ((DRY_RUN)) && info 'DRY-RUN mode enabled' ||:

  check_prerequisites
  validate_config
  install_files "$SCRIPT_DIR"/data "$PREFIX"/share

  success 'Installation complete'
}
```

**Required for scripts >200 lines.** Exception: Scripts <100 lines can skip `main()`.

### Step 12: Script Invocation

```bash
main "$@"
```

**ALWAYS quote `"$@"`** to preserve argument array.

### Step 13: End Marker

```bash
#fin
```

OR: `#end`

Visual confirmation script is complete (not truncated).

---

## Anti-Patterns

See BCS010102 for eight critical anti-patterns:
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

See BCS010103 for five variations:
1. Tiny scripts (<200 lines) - May skip `main()`
2. Sourced libraries - Skip `set -e`, `main()`, invocation
3. External configuration - Add config sourcing
4. Platform-specific code - Add platform detection
5. Cleanup traps - Add trap handlers

---

## Script Type Structure Summary

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
| 11 | Rec | `main()` function |
| 12 | Rec | `main "$@"` |
| 13 | Man | `#end` marker |

### Module/Library Scripts

Skip steps 3, 5, 11, 12. Keep shebang, business logic, end marker mandatory.

### Combined Module-Executable

Add step 14: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` then repeat executable structure.

---

## Summary

The 13-step layout guarantees safety, ensures consistency, enables testing, prevents errors, and simplifies maintenance. Scripts >100 lines should use all steps; smaller scripts may skip main() but keep other steps.

#end
