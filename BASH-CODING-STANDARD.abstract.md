# Bash Coding Standard

**Comprehensive Bash coding standard for Bash 5.2+** (not a compatibility standard).

## Coding Principles
- **K.I.S.S.** - Keep It Simple, Stupid
- **"The best process is no process"** - Minimize unnecessary complexity
- **"Everything should be made as simple as possible, but not any simpler."** - Einstein's razor

**Critical**: Do not over-engineer scripts. Remove unused functions and variables.

## Contents
1. Script Structure & Layout
2. Variable Declarations & Constants
3. Variable Expansion & Parameter Substitution
4. Quoting & String Literals
5. Arrays
6. Functions
7. Control Flow
8. Error Handling
9. Input/Output & Messaging
10. Command-Line Arguments
11. File Operations
12. Security Considerations
13. Code Style & Best Practices
14. Advanced Patterns

**Ref:** BCS00


---


**Rule: BCS0100**

# Script Structure & Layout

**All Bash scripts must follow a mandatory 13-step structural layout** from shebang through `#fin` marker.

**Coverage:** Shebang, metadata, strict mode (`set -euo pipefail`), shopt settings, dual-purpose patterns, FHS paths, file extensions, bottom-up function organization (low-level utilities before high-level orchestration).

**Rationale:** Ensures consistency, safe initialization, and maintainability across all scripts.

**Ref:** BCS01


---


**Rule: BCS010101**

### Complete Working Example

**Production script demonstrating all 13 BCS0101 steps.**

```bash
#!/bin/bash
# Installation script
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

VERSION='2.1.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- PREFIX='/usr/local'
declare -i DRY_RUN=0

if [[ -t 1 ]]; then
  readonly -- RED=$'\033[0;31m' NC=$'\033[0m'
else
  readonly -- RED='' NC=''
fi

_msg() { printf '%s\n' "$SCRIPT_NAME: $*"; }
error() { >&2 _msg "$@"; }
die() { error "${@:2}"; exit "${1:-1}"; }

check() { command -v install >/dev/null || die 1 'Missing install'; }
validate() { [[ -n "$PREFIX" ]] || die 22 'PREFIX empty'; }
install_bin() {
  ((DRY_RUN)) && { _msg '[DRY-RUN] Would install'; return 0; }
  install -m 755 "$SCRIPT_DIR/bin"/* "$PREFIX/bin"/ || die 1 'Failed'
}

main() {
  while (($#)); do
    case $1 in
      -p) shift; PREFIX="$1" ;;
      -n) DRY_RUN=1 ;;
      *) die 2 "Invalid '$1'" ;;
    esac
    shift
  done
  readonly -- PREFIX
  readonly -i DRY_RUN
  check
  validate
  install_bin
}

main "$@"
#fin
```

**Shows:** Shebangâ†’strict modeâ†’metadataâ†’globalsâ†’colorsâ†’utilitiesâ†’functionsâ†’`main()`â†’invocationâ†’`#fin`

**Ref:** BCS010101


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**Eight critical BCS0101 violations with concrete impact.**

---

**1. Missing `set -euo pipefail`** â†’ Silent failures, data corruption
```bash
# âœ— Wrong: No error handling
#!/usr/bin/env bash
rm -rf /data  # Fails silently
# âœ“ Correct: set -euo pipefail after shebang
```

**2. Variables After Use** â†’ `set -u` unbound errors
```bash
# âœ— declare -i VERBOSE=0 after main()
# âœ“ Declare before use
```

**3. Business Logic Before Utilities** â†’ Undefined function calls
```bash
# âœ— process_files() calls die() (not defined yet)
# âœ“ die() defined before process_files()
```

**4. No `main()` in Large Script** â†’ Untestable, scattered logic
```bash
# âœ— Direct execution at file level (>40 lines)
# âœ“ main() { ... }; main "$@"
```

**5. Missing `#fin`** â†’ No truncation detection

**6. Readonly Before Parsing** â†’ Can't modify `PREFIX="$1"`
```bash
# âœ“ readonly -- PREFIX after arg parsing
```

**7. Mixed Declarations** â†’ Globals scattered through file
```bash
# âœ“ All globals together before functions
```

**8. Unprotected Sourcing** â†’ Modifies caller shell, runs code
```bash
# âœ“ [[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
# Then set -euo pipefail
```

---

**Impact:** Each violation = specific bug class. Structure prevents 100%.

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Special scenarios where the standard 13-step BCS0101 layout may be modified for specific use cases.**

---

## Legitimate Deviations

**Small scripts (<200 lines):** Skip `main()`, run directly â†’ overhead not justified for trivial scripts.

**Sourced libraries:** Skip `set -e` (affects caller), skip `main()`, no execution section â†’ only function definitions.

**External configuration:** Add config sourcing between metadata and business logic â†’ allows config to override defaults. Make variables `readonly` AFTER sourcing.

**Platform detection:** Add platform-specific globals after standard globals â†’ enables cross-platform compatibility.

**Cleanup traps:** Add trap setup after utility functions but before business logic â†’ ensures cleanup function exists before trap is set.

```bash
# Trap pattern
cleanup() {
  local -i exit_code=${1:-$?}
  # ... cleanup logic
  return "$exit_code"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

## Core Principles (Always Maintain)

1. `set -euo pipefail` comes first (except library files)
2. Dependencies before usage (bottom-up organization)
3. Clear, predictable structure
4. Minimal deviation with documented reasons

## Anti-Patterns

`set -e` after functions â†’ too late for safety
Scattered globals â†’ breaks readability
Arbitrary reordering â†’ no clear benefit

**Ref:** BCS010103


---


**Rule: BCS0101**

## General Layouts for Standard Script

**13-step mandatory layout ensures consistency and safety through bottom-up organization.**

**Rationale:** Predictability, safe initialization, bottom-up dependency resolution prevents undefined function calls.

### The 13 Steps

1. **Shebang**: `#!/bin/bash` or `#!/usr/bin/env bash`
2. **ShellCheck**: `#shellcheck disable=SC#### # reason` (if needed)
3. **Description**: `# Brief purpose statement`
4. **Strict mode**: `set -euo pipefail` (MANDATORY before any commands)
5. **Shopt**: `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. **Metadata**: `VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME` then `readonly --`
7. **Globals**: `declare -i` (integers), `declare --` (strings), `declare -a` (arrays)
8. **Colors**: `if [[ -t 1 && -t 2 ]]; then readonly -- RED=... fi` (if needed)
9. **Utilities**: `_msg() vecho() info() warn() error() die() yn()` (lowest level)
10. **Business logic**: Core functions using utilities
11. **main()**: Argument parsing + workflow (required >100 lines)
12. **Invocation**: `main "$@"`
13. **End marker**: `#fin` (mandatory)

**Example snippet:**
```bash
#!/bin/bash
set -euo pipefail
VERSION='1.0.0'
readonly -- VERSION
die() { (($#>1)) && error "${@:2}"; exit "${1:-0}"; }
main() { die 0 'Not implemented'; }
main "$@"
#fin
```

**Anti-pattern:** Missing `set -euo pipefail`, using vars before declaring, no `main()` in large scripts.

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

**Scripts that work both as executables and source libraries MUST NOT apply `set -euo pipefail` or modify `shopt` when sourced** - this would alter the caller's shell environment.

**Rationale:** Sourced scripts provide functions/variables without side effects. Applying `set -e` breaks caller's error handling. Modifying `shopt` changes caller's glob behavior.

**Pattern (early return - preferred):**
```bash
#!/bin/bash
# Functions first
my_function() {
  local -- arg="$1"
  echo "Processing: $arg"
}
declare -fx my_function

# Early return when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# Executable section (only runs when executed)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata with re-source guard
if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION='1.0.0'
  readonly -- SCRIPT_VERSION
fi

# Main execution
my_function "$@"
#fin
```

**Key points:**
- Functions before sourced/executed check
- `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` ’ sourced mode exits early
- `set -euo pipefail` only in executable section
- Guard metadata: `[[ ! -v VAR ]]` prevents re-initialization
- Use `return` not `exit` for errors when sourced

**Anti-patterns:**
- `set -e` before sourcing check ’ breaks caller
- No `declare -fx` ’ functions unavailable to subshells
- No re-source guard ’ errors on second source

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**First lines: shebang, optional `#shellcheck` directives, brief description, then `set -euo pipefail`.**

**Allowable shebangs:**
- `#!/bin/bash` (most portable Linux)
- `#!/usr/bin/bash` (BSD/FreeBSD)
- `#!/usr/bin/env bash` (maximum portability, searches PATH)

**Rationale:** Covers all common scenarios. `set -euo pipefail` must be first command for immediate strict error handling.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Anti-patterns:** `set -e` after other commands ’ errors may occur before strict mode enabled.

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt`, make readonly as group.**

**Rationale:** `realpath` provides canonical paths and fails early if missing; enables deployment tracking and relative resource loading; readonly prevents modification.

**Pattern:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**Variables:**
- `VERSION` - Semantic version (Major.Minor.Patch)
- `SCRIPT_PATH` - Absolute path via `realpath -- "$0"`
- `SCRIPT_DIR` - Directory: `${SCRIPT_PATH%/*}`
- `SCRIPT_NAME` - Basename: `${SCRIPT_PATH##*/}`

**Usage:**

```bash
source "$SCRIPT_DIR/lib/common.sh"  # Relative loading
info "Starting $SCRIPT_NAME $VERSION"  # Logging
die() { >&2 echo "$SCRIPT_NAME: error: $*"; exit "$1"; }
```

**Anti-patterns:** Using `$0` directly without `realpath` â†’ no symlink resolution; using `dirname`/`basename` commands â†’ slower; making readonly individually â†’ breaks derivation; using `$PWD` for script location â†’ wrong directory; declaring late â†’ should be after `shopt`.

**Ref:** BCS0103


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**Scripts installing files/searching resources should follow FHS for predictable locations and package manager compatibility.**

**Rationale:** Standard locations expected by users/package managers; works in dev/local/system/user scenarios; eliminates hardcoded paths.

**Key locations:** `/usr/local/{bin,share,lib,etc}/` (local), `/usr/{bin,share}/` (system), `$HOME/.local/{bin,share}/` (user), `${XDG_CONFIG_HOME:-$HOME/.config}/` (config)

**FHS search pattern:**
```bash
find_data_file() {
  local -a search_paths=(
    "$SCRIPT_DIR/$1"
    "/usr/local/share/myapp/$1"
    "/usr/share/myapp/$1"
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$1"
  )
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**PREFIX-based install:**
```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"

install_files() {
  install -d "$BIN_DIR" "$PREFIX/share/myapp"
  install -m 755 myapp "$BIN_DIR/myapp"
  install -m 644 data/file.txt "$PREFIX/share/myapp/file.txt"
}
```

**Anti-patterns:**
- Hardcoded paths â†’ FHS search
- `source /usr/local/lib/lib.sh` â†’ Search multiple locations
- `source ../lib/file.sh` â†’ `"$SCRIPT_DIR/../lib/file.sh"`
- `BIN_DIR=/usr/local/bin` â†’ `BIN_DIR="$PREFIX/bin"`

**Skip FHS:** Single-user scripts, project tools, containers, embedded systems.

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt

**Strongly recommended: `shopt -s inherit_errexit shift_verbose extglob nullglob`**

**Critical settings:**
- `inherit_errexit` - Makes `set -e` work in subshells/command substitutions (without it: `result=$(false)` won't exit)
- `shift_verbose` - Catches shift errors when no arguments remain
- `extglob` - Enables patterns: `!(*.txt)`, `*.@(jpg|png)`, `+([0-9])`

**Choose glob behavior:**
- `nullglob` - Unmatched glob â†’ empty (loops/arrays: `for f in *.txt; do` skips if none)
- `failglob` - Unmatched glob â†’ error (strict scripts)
- Default behavior is dangerous: `*.txt` with no matches â†’ literal string `"*.txt"`

**Optional:**
- `globstar` - Enables `**/*.sh` recursive matching (slow on deep trees)

**Example:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Anti-pattern:** Omitting `inherit_errexit` allows silent failures in `$(...)` substitutions.

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` (non-executable); global PATH commands: no extension.**

**Rationale:** No extension for system-like commands (cleaner invocation); `.sh` identifies sourceable libraries; prevents accidental execution of libraries.

**Examples:**
```bash
# Executables
deploy.sh           # Local script
deploy              # Global command
./process-logs.sh   # Development

# Libraries (non-executable)
lib-auth.sh         # Source only
lib-utils.sh        # Cannot execute
```

**Anti-patterns:** Libraries without `.sh` ’ `source utils` unclear; global commands with `.sh` ’ `backup.sh` looks temporary.

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: messaging/utilities first â†’ composition layers â†’ `main()` last. Each function calls only functions defined above it.**

**Rationale:**
- No forward references (Bash reads top-to-bottom)
- Primitives before compositions aids comprehension
- Clear dependency hierarchy simplifies debugging/maintenance

**7-Layer Pattern:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging (primitives)
_msg() { ... }
info() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($#>1)) && error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation
show_help() { ... }

# 3. Helpers
yn() { ... }

# 4. Validation
check_prerequisites() { ... }

# 5. Business logic
build_project() { ... }

# 6. Orchestration
run_build_phase() { build_project; ... }

# 7. Main (highest level)
main() {
  check_prerequisites
  run_build_phase
}

main "$@"
#fin
```

**Anti-patterns:**
- `main()` at top â†’ `âœ— build_project` undefined
- Business logic before utilities it calls
- Circular dependencies (Aâ†’B, Bâ†’A) â†’ extract common logic to lower layer
- Random/alphabetical order ignoring dependencies

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Explicit variable declarations with type hints ensure predictable behavior and prevent shell scripting errors.** Use type-specific declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`), proper scoping (global vs local), UPPER_CASE for constants/environment, lower_case for variables, readonly for immutability, integer booleans for flags (`declare -i FLAG=0`), and derived patterns for computed values.

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:** Type safety enforces operations, prevents bugs, improves readability. Integers auto-evaluate arithmetic. Arrays prevent scalar assignment. Type mismatches caught early.

**Types:**

```bash
# Integers (counters, exit codes, ports)
declare -i count=0
count=count+1  # Auto-evaluates

# Strings (paths, text)
declare -- filename='data.txt'  # `--` prevents option injection

# Indexed arrays (lists)
declare -a files=('one' 'two')
for file in "${files[@]}"; do echo "$file"; done

# Associative arrays (key-value maps)
declare -A config=([app]='myapp' [port]='8080')
echo "${config[app]}"

# Constants
readonly -- VERSION='1.0.0'

# Local (function-scoped)
process() {
  local -- param="$1"
  local -i count=0
}
```

**Anti-patterns:**
- `count=0` â†’ use `declare -i count=0` (intent unclear)
- `declare CONFIG; CONFIG[key]='val'` â†’ use `declare -A CONFIG=()` (creates indexed array, not associative)
- Global vars in functions â†’ use `local --`
- `declare filename='-x'` â†’ use `declare -- filename='-x'` (option injection)

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function-specific variables as `local` to prevent namespace pollution.**

**Rationale:** Without `local`, function variables become global and can: (1) overwrite global variables with the same name, (2) persist after function returns causing unexpected behavior, (3) interfere with recursive function calls.

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
process_file() {
  local -- file="$1"      # Scoped to function only
  local -- dir
  dir=$(dirname -- "$file")
}
```

**Anti-patterns:**
- `file="$1"` without `local` ’ overwrites global `$file`
- `total=0` in recursive functions ’ each call resets shared variable

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use UPPER_CASE for constants/globals, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Local variables | lower_case | `local file_count=0` |
| Private functions | prefix with _ | `_validate_input()` |
| Environment vars | UPPER_CASE | `export DATABASE_URL` |

```bash
# Constants
readonly -- SCRIPT_VERSION='1.0.0'

# Globals
declare -i VERBOSE=1

# Locals
process_data() {
  local -i line_count=0
  local -- temp_file
}

# Private (underscore prefix)
_internal_helper() { :; }
```

**Rationale:** UPPER_CASE signals global scope; lower_case prevents shadowing; underscore prefix prevents namespace conflicts.

**Anti-patterns:** Using `PATH`, `HOME`, `USER` as variable names ’ overwrites shell environment. Single-letter lowercase names (`a`, `n`) ’ conflicts with shell reserved names.

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly` for constants; `declare -x`/`export` for environment variables passed to child processes.**

**Constants (readonly):**
```bash
readonly -- SCRIPT_VERSION='1.0.0' MAX_RETRIES=3

# Group declarations
VERSION='1.0.0'
AUTHOR='John Doe'
readonly -- VERSION AUTHOR
```

**Environment variables (export):**
```bash
declare -x DATABASE_URL='postgresql://localhost/db'
export LOG_LEVEL='DEBUG'
```

**When to use:**
- `readonly`: Script metadata, config paths, derived constants ’ prevents modification
- `declare -x`/`export`: Values for child processes, environment config ’ makes available in subprocesses

**Key difference:** `readonly` prevents modification but isn't inherited; `export` is inherited but modifiable.

**Combined (readonly + export):**
```bash
declare -rx BUILD_ENV='production'
readonly -x MAX_CONNECTIONS=100
```

**Anti-patterns:**
- `export MAX_RETRIES=3` ’ Use `readonly --` (no child process needs it)
- `CONFIG_FILE='/etc/app.conf'` ’ Use `readonly --` (protect from modification)
- `readonly -- OUTPUT_DIR="$HOME/output"` (too early) ’ Allow override first: `OUTPUT_DIR="${OUTPUT_DIR:-$HOME/output}"; readonly -- OUTPUT_DIR`

**Example:**
```bash
# Constants (not exported)
readonly -- SCRIPT_VERSION='2.1.0'

# Environment (exported, overridable)
declare -x LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Combined
declare -rx BUILD_ENV='production'
```

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables first, then make readonly in single statement.**

**Rationale:**
- Prevents assignment-to-readonly errors
- Visual grouping of related constants
- Explicit immutability contract

**Pattern:**

```bash
# Initialize
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
# Protect
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**Groups:**

```bash
# Metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Colors (conditional)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' NC=$'\033[0m'
else
  RED='' GREEN='' NC=''
fi
readonly -- RED GREEN NC
```

**Delayed (after args):**

```bash
declare -i VERBOSE=0 DRY_RUN=0
# Parse...
while (($#)); do case $1 in
  -v) VERBOSE=1 ;; -n) DRY_RUN=1 ;;
esac; shift; done
readonly -- VERBOSE DRY_RUN
```

**Anti-patterns:**

```bash
# âœ— Individual readonly
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(realpath -- "$0")

# âœ— Premature
VERSION='1.0.0'
readonly -- VERSION  # Too early!
SCRIPT_PATH=$(realpath -- "$0")

# âœ“ Correct
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH
```

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `readonly` for constants to prevent modification.**

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
readonly -- SCRIPT_PATH="$(realpath -- "$0")"
```

**Ref:** BCS0206


---


**Rule: BCS0207**

## Boolean Flags Pattern

**Use integer variables with `declare -i` for boolean state tracking.**

**Rationale:**
- `(())` arithmetic evaluation provides clean true/false testing (non-zero=true, zero=false)
- Integer type prevents string assignment errors
- Explicit initialization documents intent

**Example:**
```bash
declare -i DRY_RUN=0
declare -i VERBOSE=0

# Test with (())
((DRY_RUN)) && info 'Dry-run enabled'

if ((VERBOSE)); then
  show_details
fi

# Set from arguments
case $1 in
  --dry-run) DRY_RUN=1 ;;
  --verbose) VERBOSE=1 ;;
esac
```

**Anti-patterns:**
- `if [[ $FLAG == 1 ]]` ’ Use `if ((FLAG))`
- `declare FLAG=false` ’ Use `declare -i FLAG=0`

**Ref:** BCS0207


---


**Rule: BCS0209**

## Derived Variables

**Compute variables from base values using section comments to show dependencies. Update derived variables when base values change during argument parsing.**

**Rationale:** DRY principle - single source of truth ensures consistency when base values change.

**Pattern:**

```bash
# Base values
PREFIX='/usr/local'
APP_NAME='myapp'

# Derived from PREFIX
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"
DOC_DIR="$PREFIX/share/doc/$APP_NAME"

# Update when PREFIX changes
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
}
```

**Environment fallbacks:**
```bash
CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$CONFIG_BASE/$APP_NAME"
```

**Anti-patterns:**
```bash
# âœ— Duplicate values
PREFIX='/usr/local'
BIN_DIR='/usr/local/bin'

# âœ“ Derive
PREFIX='/usr/local'
BIN_DIR="$PREFIX/bin"

# âœ— Not updating after base changes
--prefix) PREFIX="$1" ;;  # BIN_DIR now wrong

# âœ“ Update derived
--prefix)
  PREFIX="$1"
  BIN_DIR="$PREFIX/bin"
  ;;

# âœ— Readonly before parsing
BIN_DIR="$PREFIX/bin"
readonly BIN_DIR  # Can't update!

# âœ“ Readonly after parsing
# Parse args...
readonly PREFIX BIN_DIR
```

**Ref:** BCS0209


---


**Rule: BCS0300**

# Variable Expansion & Parameter Substitution

**Default: `"$var"` without braces. Use braces only when syntactically required.**

**Required cases:**
- Parameter operations: `"${var##pattern}"`, `"${var:-default}"`, `"${var/old/new}"`
- Arrays: `"${array[@]}"`, `"${array[*]}"`, `"${!array[@]}"`
- Concatenation: `"${var1}${var2}"`, `"${var}suffix"`
- Disambiguation: `"${var}_text"` (brace prevents `$var_text` misparse)

**Not required:**
- Simple expansion: `"$var"` ’ not `"${var}"`
- In arithmetic: `((count + 1))` ’ not `((${count} + 1))`
- Command substitution: `$(command "$var")` ’ not `$(command "${var}")`

**Rationale:** Reduce visual clutter; braces signal "special operation happening here."

**Example:**
```bash
#  Correct
file="$HOME/docs/report.txt"
echo "$file"
backup="${file}.bak"
default_path="${path:-/usr/local}"
prefix="${file%%.*}"

#  Wrong
file="${HOME}/docs/report.txt"  # Unnecessary braces
echo "${file}"                  # Unnecessary braces
```

**Anti-patterns:**
- `"${var}"` when `"$var"` works ’ Adds clutter
- `$var` unquoted in word context ’ Risks word splitting

**Ref:** BCS0300


---


**Rule: BCS0301**

## Parameter Expansion

**Use parameter expansion for string manipulation and defaults instead of external commands.**

**Rationale:** Native bash operations are 10-100x faster than spawning subprocesses; eliminates subprocess overhead; reduces dependencies on external utilities.

**Core patterns:**
```bash
# Pattern removal
SCRIPT_NAME=${SCRIPT_PATH##*/}  # Remove longest prefix (dirname)
SCRIPT_DIR=${SCRIPT_PATH%/*}    # Remove shortest suffix (basename)

# Defaults and substring
${var:-default}                 # Use default if unset/empty
${var:0:1}                      # Substring (offset:length)

# Array/string operations
${#array[@]}                    # Array length
${var,,}                        # Lowercase (${var^^} uppercase)
"${@:2}"                        # Args from position 2 onward
```

**Anti-patterns:** `basename "$path"` ’ use `${path##*/}`; `dirname "$path"` ’ use `${path%/*}`; external commands for simple string ops.

**Ref:** BCS0301


---


**Rule: BCS0302**

## Variable Expansion Guidelines

**Default: `"$var"` (no braces). Use `"${var}"` ONLY when syntactically required.**

**Rationale:** Braces add visual noise; using only when necessary makes required cases stand out.

#### Braces REQUIRED

1. **Parameter expansion:** `"${var##*/}"` `"${var:-default}"` `"${var:0:5}"` `"${var//old/new}"`
2. **Concatenation (no separator):** `"${var1}${var2}"` `"${prefix}suffix"`
3. **Arrays:** `"${array[i]}"` `"${array[@]}"` `"${#array[@]}"`
4. **Special:** `"${@:2}"` `"${10}"` `"${!var}"`

#### Braces NOT Required

Standalone variables and paths with separators:

```bash
#  Correct
"$var" "$HOME" "$1"
"$PREFIX"/bin
"$PREFIX/bin"
echo "Installing to $PREFIX/bin"
[[ -d "$path" ]]

#  Wrong
"${var}" "${HOME}"
"${PREFIX}"/bin
echo "Installing to ${PREFIX}/bin"
[[ -d "${path}" ]]
```

**Pattern `"$var"/literal` acceptable:** Quotes protect variables; separators (`/` `-` `.`) naturally delimit.

#### Edge Cases

- **Alphanumeric follows (no separator):** `"${var}_suffix"` `"${prefix}123"` ’ braces required
- **Separator present:** `"$var-suffix"` `"$var.suffix"` `"$var/path"` ’ no braces

| Situation | Form | Example |
|-----------|------|---------|
| Standalone | `"$var"` | `"$HOME"` |
| Path+separator | `"$var"/path` | `"$BIN_DIR"/file` |
| Expansion ops | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation | `"${var1}${var2}"` | `"${a}${b}"` |
| Arrays | `"${array[i]}"` | `"${args[@]}"` |

**Ref:** BCS0302


---


**Rule: BCS0400**

# Quoting & String Literals

**Core principle:** Single quotes (`'...'`) for static literals, double quotes (`"..."`) when variable expansion/command substitution needed.

**Rationale:**
1. Single quotes prevent word-splitting errors (most critical security/reliability issue)
2. Quote choice signals intent: `'literal'` vs `"$processed"`reduces cognitive load 40%
3. Always quote variables in conditionals prevents pathname expansion bugs

**Pattern:**
```bash
# Static strings
info 'Processing complete'           #  Single quotes

# Variables/commands
info "Found $count files"             #  Double quotes
output=$(command)                     #  Command substitution

# Conditionals - always quote
[[ -f "$file" ]]                      #  Prevents splitting
[[ "$var" == 'literal' ]]             #  Mixed quoting

# Arrays
"${array[@]}"                         #  Preserve elements
```

**Anti-patterns:**
```bash
info "Static string"                  #  Wrong quotes (static)
[[ -f $file ]]                        #  Unquoted variable
echo $var                             #  Word-splitting risk
```

**Ref:** BCS0400


---


**Rule: BCS0401**

## Static Strings and Constants

**Always use single quotes for string literals without variables.**

```bash
# Static strings
info 'Checking prerequisites...'
DEFAULT_PATH='/usr/local/bin'
[[ "$status" == 'success' ]]

# Variables/substitution ’ double quotes
info "Found $count files in $directory"
msg="Current time: $(date +%H:%M:%S)"
```

**Rationale:**
1. **Performance** - Single quotes faster (no parsing for variables/escapes)
2. **Clarity** - Signals literal string, no substitution expected
3. **Safety** - No escaping needed for `$`, `` ` ``, `\`, `!`

**Anti-patterns:**
```bash
#  Unnecessary double quotes
info "Checking prerequisites..."  # No variables ’ use 'single'
[[ "$status" == "active" ]]       # Right side ’ 'active'

#  Escaping in double quotes (avoidable)
msg="The cost is \$5.00"          # Use: msg='The cost is $5.00'

#  Variables in single quotes
greeting='Hello, $name'           # $name not expanded ’ use "double"
```

**Rule:** Single quotes `'static'` for literals; double quotes `"$var"` when expansion needed.

**Ref:** BCS0401


---


**Rule: BCS0402**

## Exception: One-Word Literals

**One-word alphanumeric literals may be unquoted in assignments/conditionals, but quoting is safer and recommended.**

**Rationale:** Common practice; reduces visual noise. However, defensive programming favors always quoting.

**Qualifies as one-word literal:**
- Only `a-zA-Z0-9`, `_`, `-`, `.`, `/`
- No spaces, tabs, shell specials (`*?[]{}$` `` ` ```;`&|<>()!#`), quotes, backslashes
- Not starting with hyphen (in conditionals)

**Examples:**
```bash
#  Acceptable (but quoting better)
ORGANIZATION=Okusi
LOG_LEVEL=INFO
[[ "$status" == success ]]

#  Better - always quote
ORGANIZATION='Okusi'
LOG_LEVEL='INFO'
[[ "$status" == 'success' ]]

#  MANDATORY - quote multi-word/special
APP_NAME='My Application'
PATTERN='*.log'
EMAIL='admin@example.com'
```

**Always quote:**
- Spaces: `'Hello world'`
- Wildcards: `'*.txt'`
- Special chars: `'user@domain.com'`, `'test(1).txt'`
- Empty: `''`
- Variables: `"$var"` (never `$var`)

**Anti-pattern:**
```bash
#  Wrong
MESSAGE=File not found    # Syntax error
EMAIL=admin@example.com   # @ is special
PATTERN=*.log             # Glob expansion

#  Correct
MESSAGE='File not found'
EMAIL='admin@example.com'
PATTERN='*.log'
```

**Best practice:** Always quote everything except most trivial cases. When in doubt, quote it.

**Ref:** BCS0402


---


**Rule: BCS0403**

## Strings with Variables

**Use double quotes when strings contain variables needing expansion.**

**Rationale:** Variables require double quotes for shell expansion; prevents word splitting and glob expansion on variable contents.

```bash
# Message functions with variables
die 1 "Unknown option '$1'"
info "Installing to $PREFIX/bin"
success "Processed $count files"

# Echo with variables
echo "$SCRIPT_NAME $VERSION"
echo "Binary: $BIN_DIR/mailheader"
```

**Anti-patterns:**
- `info 'Installing to $PREFIX/bin'` â†’ Variable won't expand (prints literal `$PREFIX`)

**Ref:** BCS0403


---


**Rule: BCS0404**

## Mixed Quoting

**Use double quotes containing single-quoted literals to protect variables while showing them distinctly in messages.**

**Rationale:** Single quotes inside double quotes remain literal, visually delimiting variable values in error/info messages without escaping complexity.

**Pattern:**
```bash
die 2 "Unknown option '$1'"
warn "Cannot access '$file_path'"
info "Would remove: '$old' â†’ '$new'"
```

**Anti-pattern:** `error "Missing $file"` â†’ unclear boundaries if `$file` is empty/whitespace

**Ref:** BCS0404


---


**Rule: BCS0405**

## Command Substitution in Strings

**Always use double quotes when including command substitution** â€“ required for expansion and proper word splitting.

**Rationale:**
- Command substitution `$()` only expands inside double quotes
- Prevents word splitting of multi-word output
- Enables safe string interpolation with commands

**Pattern:**
```bash
# Always quote command substitution
echo "Time: $(date +%T)"
info "Found $(wc -l "$file") lines"
VERSION="$(git describe --tags)"
```

**Anti-patterns:**
- `echo 'Time: $(date)'` â†’ Single quotes prevent expansion
- `count=$(wc -l $file)` â†’ Unquoted variable in command

**Ref:** BCS0405


---


**Rule: BCS0406**

## Variables in Conditionals

**Always quote variables in test expressions; static values follow normal quoting (single quotes for literals, unquoted for one-word).**

**Rationale:**
- Unquoted variables undergo word splitting (breaks multi-word values)
- Prevents glob expansion (`*`, `?`, `[` trigger pathname expansion)
- Empty unquoted variables cause syntax errors (`[[ -z $var ]]` ’ `[[ -z ]]`)

**Core pattern:**

```bash
# File tests - quote variable
[[ -f "$file" ]]        #  Correct
[[ -f $file ]]          #  Wrong - word splitting

# String comparisons - quote variable, literal single-quoted
[[ "$name" == 'start' ]]  #  Correct
[[ $name == start ]]      #  Wrong

# Integer comparisons - quote variable
[[ "$count" -eq 0 ]]    #  Correct
[[ $count -eq 0 ]]      #  Wrong

# Pattern matching - quote variable, pattern unquoted
[[ "$file" == *.txt ]]  #  Glob matching
[[ "$file" == '*.txt' ]]  #  Literal match
```

**Anti-patterns:**

```bash
#  Unquoted variable with spaces
file='my file.txt'
[[ -f $file ]]          # Syntax error! ’ [[ -f my file.txt ]]

#  Unquoted empty variable
name=''
[[ -z $name ]]          # Syntax error! ’ [[ -z ]]

#  Correct - always quote
[[ -f "$file" ]]
[[ -z "$name" ]]
```

**Ref:** BCS0406


---


**Rule: BCS0407**

## Array Expansions

**Always quote array expansions: `"${array[@]}"` for separate elements, `"${array[*]}"` for single string.**

**Rationale:** Unquoted arrays undergo word splitting and glob expansion, breaking elements on whitespace/special chars.

**Forms:**

`"${array[@]}"` - Separate words (iteration, function/command args):
```bash
for item in "${array[@]}"; do process "$item"; done
my_function "${array[@]}"
```

`"${array[*]}"` - Single string (display, CSV with IFS):
```bash
echo "Items: ${array[*]}"
IFS=','; csv="${array[*]}"
```

**Anti-pattern:**
```bash
#  Wrong - unquoted (word splitting)
declare -a files=('file 1.txt' 'file2.txt')
for f in ${files[@]}; do echo "$f"; done  # Splits 'file 1.txt' into 'file' and '1.txt'

#  Correct - quoted
for f in "${files[@]}"; do echo "$f"; done
```

**Ref:** BCS0407


---


**Rule: BCS0408**

## Here Documents

**Quote delimiter for literal text; unquoted for expansion.**

```bash
# Literal (no expansion) - quote delimiter
cat <<'EOF'
$VAR not expanded
$(cmd) not executed
EOF

# Expansion enabled - unquoted delimiter
cat <<EOF
Script: $SCRIPT_NAME
Time: $(date)
EOF
```

**Anti-pattern:** `cat <<"EOF"` ’ double quotes same as unquoted (misleading)

**Ref:** BCS0408


---


**Rule: BCS0409**

## Echo and Printf Statements

**Single quotes for static strings, double quotes when variables/commands needed.**

```bash
# Static ’ single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# Variables ’ double quotes
echo "$SCRIPT_NAME $VERSION"
echo "Installing to $PREFIX/bin"
printf 'Found %d files in %s\n' "$count" "$dir"

# Mixed content
echo "  " Binary: $BIN_DIR/mailheader"
echo "  " Version: $VERSION (released $(date))"
```

**Anti-patterns:** Double quotes on static strings ’ `echo "Processing..."` (use single quotes).

**Ref:** BCS0409


---


**Rule: BCS0410**

## Summary Reference

**Quick reference table for quoting decisions across common contexts.**

| Content | Quote | Example |
|---------|-------|---------|
| Static string | Single `'...'` | `info 'Starting'` |
| String + variable | Double `"..."` | `info "File: $file"` |
| One-word literal | Optional | `VAR=value` or `VAR='value'` |
| Variable in test | Double `"$var"` | `[[ -f "$file" ]]` |
| Static in test | Single/unquoted | `[[ $x == 'val' ]]` or `[[ $x == val ]]` |
| Array expand | Double `"${arr[@]}"` | `for i in "${arr[@]}"` |
| Command subst | Double `"..."` | `"Time: $(date)"` |
| Literal quote | Double + single | `"Unknown '$1'"` |
| Here doc expand | No quotes | `cat <<EOF` |
| Here doc literal | Single quotes | `cat <<'EOF'` |

**Ref:** BCS0410


---


**Rule: BCS0411**

## Anti-Patterns (What NOT to Do)

**Avoid quoting mistakes that cause security vulnerabilities, word-splitting, and glob expansion bugs.**

**Rationale:** Improper quoting enables code injection; unquoted variables cause unpredictable failures; unnecessary braces add noise.

**Critical patterns:**

```bash
# âœ— Double quotes for static â†’ âœ“ Single quotes
info "Starting..."              # Wrong
info 'Starting...'              # Correct

# âœ— Unquoted variables â†’ âœ“ Quoted
[[ -f $file ]]                  # Wrong
[[ -f "$file" ]]                # Correct
echo $result                    # Wrong
echo "$result"                  # Correct

# âœ— Unnecessary braces â†’ âœ“ No braces
echo "${HOME}/bin"              # Wrong
echo "$HOME/bin"                # Correct

# Braces only when needed:
"${var##*/}" "${array[@]}" "${var1}${var2}" "${var:-default}"

# âœ— Unquoted arrays â†’ âœ“ Quoted
for item in ${items[@]}         # Wrong - breaks on spaces
for item in "${items[@]}"       # Correct
```

**Quick reference:**
- Static â†’ `'text'` not `"text"`
- Variables â†’ `"$var"` not `"${var}"` or `$var`
- Arrays â†’ `"${array[@]}"` not `${array[@]}`
- Conditionals â†’ `[[ -f "$file" ]]` not `[[ -f $file ]]`
- Here-docs â†’ `<<'EOF'` (literal) or `<<EOF` (expand)

**Ref:** BCS0411


---


**Rule: BCS0412**

## String Trimming

**Use parameter expansion for whitespace trimming - no external commands.**

**Rationale:** Pure Bash (no subshells), handles all POSIX blank chars (space/tab), preserves internal whitespace.

**Pattern:**
```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

**Anti-pattern:** `$(echo "$var" | xargs)` ’ spawns subshell, fails with newlines.

**Ref:** BCS0412


---


**Rule: BCS0413**

## Display Declared Variables

**Utility to inspect variable values without declaration syntax.**

```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```

**Use:** `decp VAR1 VAR2` ’ Shows `VAR="value"` without `declare -x` prefix.

**Ref:** BCS0413


---


**Rule: BCS0414**

**Pluralisation Helper** - Conditional 's' suffix function for dynamic messages.

```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

**Usage:** `echo "$count file$(s "$count") processed"` ’ "1 file processed" or "2 files processed"

**Rationale:** Eliminates message duplication (separate singular/plural paths); single statement handles both cases; improves maintainability.

**Anti-pattern:** `if ((count == 1)); then echo "$count file"; else echo "$count files"; fi` ’ duplicates message logic.

**Ref:** BCS0414


---


**Rule: BCS0500**

# Arrays

**Proper array declaration and usage for safe item handling.** Arrays prevent word-splitting issues and handle filenames with spaces/special characters. Use indexed arrays (`declare -a`) or associative arrays (`declare -A`). Always quote expansions: `"${array[@]}"` for all elements, `"${array[i]}"` for single element.

**Rationale:** Space/newline-separated strings fail with special characters; arrays preserve element boundaries safely. Prevents catastrophic file operation errors (e.g., `rm "$files"` vs `rm "${files[@]}"`).

**Example:**
```bash
declare -a files=('file 1.txt' 'file2.txt')
for file in "${files[@]}"; do
  [[ -f "$file" ]] && process "$file"
done

declare -A config=([host]='example.com' [port]=443)
echo "${config[host]}:${config[port]}"
```

**Anti-patterns:** Unquoted `${array[@]}` (word-splits), `${array[*]}` in loops (treats as single string), space-separated strings for lists.

**Ref:** BCS0500


---


**Rule: BCS0501**

## Array Declaration and Usage

**Always use `declare -a` for explicit array declaration; quote expansions with `"${array[@]}"` for safe iteration.**

**Rationale:** Type safety prevents scalar assignment bugs; quoted `[@]` preserves spacing in filenames with spaces/newlines; explicit declaration signals array type to readers.

**Declaration and operations:**

```bash
# Explicit declaration
declare -a files=('*.sh' '*.txt')
local -a paths=()

# Append elements
files+=("$new_file")
all+=("${arr1[@]}" "${arr2[@]}")

# Iterate safely (quoted!)
for file in "${files[@]}"; do
  process "$file"
done

# Length and tests
((${#array[@]} > 0)) && process
```

**Critical anti-patterns:**

- `${array[@]}` unquoted ’ breaks with spaces
- `"$array"` without `[@]` ’ only first element
- `"${array[*]}"` in loops ’ iterates once (all as single string)
- `array=($string)` ’ word splitting/glob expansion

**Ref:** BCS0501


---


**Rule: BCS0502**

## Arrays for Safe List Handling

**Use arrays for all lists to prevent word splitting and glob expansion.**

**Rationale:** Element boundaries preserved; `"${array[@]}"` prevents word splitting; wildcards literal; safe dynamic building.

**Safe patterns:**

```bash
# Build commands
declare -a cmd=('myapp' '--config' '/etc/app.conf')
((verbose)) && cmd+=('--verbose')
"${cmd[@]}"

# File lists with glob
declare -a files=(*.txt)
for file in "${files[@]}"; do process "$file"; done

# Dynamic
declare -a logs=()
while IFS= read -r -d '' f; do logs+=("$f"); done < <(find "$dir" -name '*.log' -print0)
```

**Anti-patterns:**

```bash
# âœ— String list â†’ word splitting
files="a.txt file with spaces.txt"
for f in $files; do echo "$f"; done  # 5 iterations not 2

# âœ“ Array preserves boundaries
declare -a files=('a.txt' 'file with spaces.txt')
for f in "${files[@]}"; do echo "$f"; done

# âœ— String args break on spaces
args="-o out.txt"; cmd $args

# âœ“ Array args safe
declare -a args=('-o' 'out.txt'); cmd "${args[@]}"

# âœ— Unquoted â†’ word splitting
cmd ${array[@]}

# âœ“ Quoted (mandatory)
cmd "${array[@]}"
```

**Pass to functions:**

```bash
func() { local -a items=("$@"); for i in "${items[@]}"; do echo "$i"; done; }
declare -a list=('a' 'b with spaces'); func "${list[@]}"
```

**Key principle:** Always use arrays for lists. Always quote: `"${array[@]}"`. String lists fail with spaces/wildcards.

**Ref:** BCS0502


---


**Rule: BCS0600**

# Functions

**Function patterns, naming (lowercase_with_underscores), and organization principles.** Mandate `main()` for scripts >200 lines. Export functions for sourceable libraries (`declare -fx`). Remove unused utilities in production. Organize bottom-up: messaging ’ helpers ’ business logic ’ `main()` (ensures safe forward references, primitives understood before composition).

**Ref:** BCS0600


---


**Rule: BCS0601**

## Function Definition Pattern

**Single-line for simple operations; multi-line with `local` declarations for complex logic.**

**Rationale:** Single-line syntax (`func() { cmd; }`) minimizes overhead for trivial operations. Multi-line format with explicit `local` declarations prevents variable pollution and improves debugging.

**Example:**
```bash
# Single-line for simple operations
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line with local variables
main() {
  local -i exitcode=0
  local -- variable
  return "$exitcode"
}
```

**Anti-patterns:** Missing `local` declarations ’ global scope pollution; multi-line function without braces on separate lines ’ readability issues.

**Ref:** BCS0601


---


**Rule: BCS0602**

## Function Names

**Use lowercase with underscores; prefix private functions with underscore.**

**Rationale:**
- Matches Unix utility naming conventions (grep, sed, awk)
- Avoids conflicts with built-in commands and variables

**Example:**
```bash
#  Public functions
process_log_file() { & }
validate_input() { & }

#  Private functions (leading underscore)
_internal_helper() { & }

#  Avoid CamelCase/UPPER_CASE
MyFunction() { & }     # Don't
PROCESS_FILE() { & }   # Don't
```

**Anti-patterns:**
- Never override built-ins: `cd() { & }` ’ Use `change_dir() { & }`
- No dashes: `my-function()` ’ Use `my_function()`

**Ref:** BCS0602


---


**Rule: BCS0603**

## Main Function

**Use `main()` for scripts >200 lines as single entry point. Place `main "$@"` before `#fin`.**

**Rationale:** Enables testing (scripts can be sourced without executing), centralizes argument parsing/validation, controls scope (prevents global pollution), and provides clear execution flow.

**Basic structure:**

```bash
main() {
  local -i verbose=0
  local -- output=''

  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -o|--output) shift; output="$1" ;;
    -h|--help) usage; return 0 ;;
    --) shift; break ;;
    -*) die 22 "Invalid: $1" ;;
    *) break ;;
  esac; shift; done

  readonly -- verbose output

  # Main logic
  return 0
}

main "$@"
```

**Testable pattern:** Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"` for dual-purpose (executable/sourceable).

**Anti-pattern:**

```bash
# âœ— Wrong - no main in 200+ line script
# ... 200 lines directly in script ...

# âœ— Wrong - parse outside main
while (($#)); do ...; done
main "$@"  # Args consumed!

# âœ“ Correct
main() {
  while (($#)); do ...; done
}
main "$@"
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Function Export

**Export functions with `declare -fx` when needed by subshells or external commands.**

**Rationale:** Functions aren't inherited by subshells unless exported; prevents "command not found" errors in pipelines/backgrounded processes.

**Pattern:**
```bash
# Wrapper overriding external command
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

**Anti-patterns:**
- `export -f func` ’ Use `declare -fx` (consistent with modern practice)
- Forgetting to export functions used in subshells ’ Runtime failures

**Ref:** BCS0604


---


**Rule: BCS0605**

## Production Script Optimization

**Remove unused utilities before production deployment:** Delete unreferenced functions (`yn()`, `decp()`, `trim()`, `s()`), unused variables (`PROMPT`, `DEBUG`), and messaging functions not called.

**Rationale:** Reduces script size, eliminates maintenance burden, improves clarity.

**Example:**
```bash
# Minimal production script
error() { >&2 printf '%s\n' "ERROR: $*"; }
die() { error "$@"; exit 1; }

main() {
  [[ -f "$config" ]] || die 'Config not found'
  # Business logic only
}
```

**Anti-patterns:** Keeping full messaging suite (`vecho()`, `success()`, `warn()`, `info()`, `debug()`) when script only needs `error()` and `die()`.

**Ref:** BCS0605


---


**Rule: BCS0700**

# Control Flow

**Patterns for conditionals, loops, case statements, and arithmetic.** Use `[[ ]]` (not `[ ]`) for tests, `(())` for arithmetic conditionals. Prefer process substitution `< <(command)` over pipes to while (avoids subshell variable issues). Safe increment: `i+=1` or `((i+=1))` â†’ never `((i++))` (returns original value, fails with `set -e` when i=0).

**Ref:** BCS0700


---


**Rule: BCS0701**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic conditionals.**

**Rationale:** `[[ ]]` prevents word splitting/glob expansion, enables pattern matching (`==`, `=~`), supports logical operators (`&&`, `||`) internally. `(())` provides natural C-style arithmetic syntax.

**Example:**

```bash
# String/file tests
[[ -f "$file" ]] && source "$file"
[[ "$status" == 'success' ]] && continue

# Arithmetic tests
((count > 5)) || return 1
((VERBOSE)) && set -x

# Pattern matching
[[ "$file" == *.txt ]] && process "$file"
[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]] || die 22 'Invalid email'
```

**Anti-patterns:**

- `[ ]` syntax â†’ use `[[ ]]`
- `-a`/`-o` operators â†’ use `&&`/`||` inside `[[ ]]`
- `-gt`/`-lt` for arithmetic â†’ use `(())` with `>`/`<`

**Ref:** BCS0701


---


**Rule: BCS0702**

## Case Statements

**Use `case` for multi-way pattern matching; choose compact format for single actions, expanded for multi-line logic.**

**Rationale:** Clearer than if/elif chains for single-variable tests; native pattern matching; faster evaluation.

**Format selection:**

```bash
# Compact - single actions
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -h|--help)    usage; exit 0 ;;
  --)           shift; break ;;
  -*)           die 22 "Invalid: $1" ;;
  *)            FILES+=("$1") ;;
esac

# Expanded - multi-line actions
case $1 in
  -p|--prefix)      noarg "$@"
                    shift
                    PREFIX="$1"
                    BIN_DIR="$PREFIX/bin"
                    ;;

  -v|--verbose)     VERBOSE=1
                    info 'Verbose enabled'
                    ;;

  *)                die 22 "Invalid: $1"
                    ;;
esac
```

**Pattern syntax:**
- Literal: `start)` (unquoted)
- Wildcards: `*.txt)`, `*.@(jpg|png))`
- Alternation: `-h|--help)`
- Extglob: `+([0-9]))` (needs `shopt -s extglob`)

**Anti-patterns:**
```bash
#  Wrong
case $var in         # Unquoted test variable
  "start")           # Quoted literal pattern
  *.txt) ;;          # Missing default case
esac

#  Correct
case "$var" in
  start) ;;
  *.txt) ;;
  *) die 22 "Invalid" ;;
esac
```

**When to use:**
- `case`: Single variable, pattern matching, argument parsing
- `if/elif`: Multiple variables, ranges, complex conditions

**Ref:** BCS0702


---


**Rule: BCS0703**

## Loops

**Use `for` for arrays/globs/ranges, `while` for input/conditions. Quote arrays `"${array[@]}"`, use `< <(cmd)` to avoid subshell, use `i+=1` never `i++`, prefer `while ((1))` for infinite loops.**

**Rationale:** Prevents subshell variable scope issues and `set -e` failures.

**Examples:**
```bash
# Array iteration
for f in "${files[@]}"; do [[ -f "$f" ]] && process "$f"; done

# Glob (nullglob required)
for f in "$dir"/*.txt; do process "$f"; done

# C-style (never i++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Read file (avoid subshell)
count=0
while IFS= read -r line; do
  ((count+=1))
done < <(find . -name '*.sh')

# Argument parsing
while (($#)); do
  case $1 in
    -v) VERBOSE=1 ;;
    --) shift; break ;;
    *) FILES+=("$1") ;;
  esac
  shift
done

# Infinite (fastest)
while ((1)); do process_item || break; sleep 1; done

# Break nested
for i in {1..10}; do
  for j in {1..10}; do
    ((i * j > 50)) && break 2
  done
done
```

**Anti-patterns:**
```bash
# âœ— Pipe creates subshell
cat file | while read line; do count+=1; done

# âœ— Parse ls
for f in $(ls); do process "$f"; done

# âœ— Unquoted array
for f in ${files[@]}; do process "$f"; done

# âœ— i++ fails with set -e when i=0
for ((i=0; i<10; i++)); do echo "$i"; done

# âœ— Redundant
while (($# > 0)); do shift; done  # Use: while (($#))
```

**Ref:** BCS0703


---


**Rule: BCS0704**

## Pipes to While Loops

**Never pipe to whileâ€”creates subshells where variable changes don't persist. Use `< <(cmd)` or `readarray`.**

**Rationale:** Pipe subshells lose all variable modifications silently.

**Anti-pattern:**
```bash
# âœ— Lost in subshell
count=0
echo -e "a\nb" | while read -r line; do ((count+=1)); done
echo "$count"  # 0 (not 2!)
```

**Solutions:**
```bash
# âœ“ Process substitution
count=0
while read -r line; do ((count+=1)); done < <(echo -e "a\nb")
echo "$count"  # 2

# âœ“ Readarray for lines
readarray -t lines < <(echo -e "a\nb")

# âœ“ Here-string when var input
while read -r line; do ((count+=1)); done <<< "$input"
```

**Common bugs:**
```bash
# âœ— Counter stays 0
grep ERROR log | while read -r line; do ((errors+=1)); done

# âœ“ Fix
while read -r line; do ((errors+=1)); done < <(grep ERROR log)

# âœ— Array stays empty
find . -name '*.txt' | while read -r f; do files+=("$f"); done

# âœ“ Fix
readarray -d '' -t files < <(find . -name '*.txt' -print0)

# âœ— Hash lost
cat cfg | while IFS='=' read k v; do config[$k]="$v"; done

# âœ“ Fix
while IFS='=' read k v; do config[$k]="$v"; done < <(cat cfg)
```

**Ref:** BCS0704


---


**Rule: BCS0705**

## Arithmetic Operations

**Use `declare -i` for integer variables** â†’ automatic arithmetic context, type safety, performance.

```bash
declare -i i=0 counter max_retries=3
```

**Increment safely:**
- `i+=1` (clearest, always safe)
- `((i+=1))` (safe, returns 0)
- `((++i))` (pre-increment, safe)
- `((i++))` â†’ **DANGEROUS**: post-increment returns old value; if `i=0`, returns 0 (false), triggers `set -e` exit

**Rationale:**
- `((i++))` returns original value before incrementing
- When `i=0`, expression returns 0 (false in arithmetic context)
- With `set -e`, zero return causes script exit before seeing new value
- `i+=1` and `((++i))` always succeed

**Example:**
```bash
set -e
i=0
((i++))  # Returns 0, script exits here
echo "Never reached"  # Dead code
```

**Arithmetic operations:**
```bash
# (()) - no $ needed
((result = x * y + z))
((i >= 10)) && action

# $(()) - for assignments/substitution
result=$((x * y + z))
```

**Operators:** `+ - * / % **` (exponentiation), `< <= > >= == !=`, `+=` `-=`

**Anti-patterns:**
- `[[ "$count" -gt 10 ]]` â†’ use `((count > 10))`
- `expr $i + $j` â†’ use `$((i + j))`
- `((result = $i + $j))` â†’ unnecessary `$` inside `(())`
- Integer division truncates: `((10 / 3))` = 3

**Ref:** BCS0705


---


**Rule: BCS0800**

# Error Handling

**Robust error handling through automatic detection, standard exit codes, trap cleanup, and explicit suppression.**

## Core Requirements

**Mandatory:** `set -euo pipefail` before commands (exits on: errors, unset vars, pipe failures).

**Recommended:** `shopt -s inherit_errexit` (propagates `set -e` to subshells).

**Exit codes:** 0=success, 1=general, 2=misuse, 5=IO, 22=invalid arg.

**Traps:** Use for cleanup (`trap cleanup EXIT ERR`).

**Return checking:** Check explicitly or use `set -e`. Suppress with `|| true` or `|| :` only when justified.

## Rationale

1. **Auto-detection** prevents silent failures corrupting state
2. **Standard codes** enable proper error handling by callers
3. **Cleanup traps** prevent resource leaks (files, locks, processes)

## Example

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT ERR

TEMP_DIR=$(mktemp -d)
command1 || die "Failed"  # Explicit
optional_cmd || true      # Intentional suppress
```

## Anti-Patterns

- No strict mode â†’ silent failures
- No traps â†’ resource leaks
- Blind `|| true` â†’ masks real errors

**Ref:** BCS0800


---


**Rule: BCS0801**

## Exit on Error

**Mandatory strict mode flags:** `set -euo pipefail` must appear at line 4 (after shebang, shellcheck directives, description).

**Flags:**
- `-e` (errexit): Exit immediately on command failure (non-zero return)
- `-u` (nounset): Exit on undefined variable reference
- `-o pipefail`: Pipeline fails if ANY command fails (not just last)

**Rationale:** Prevents cascading failures, catches errors immediately, enforces fail-fast behavior.

**Handling expected failures:**

```bash
# Allow specific failure
command || true

# Conditional execution
if command; then
  success_action
fi

# Temporarily disable (use sparingly)
set +e
risky_command
set -e
```

**Critical gotcha:**
```bash
#  Exits before check
result=$(cmd)  # Exits here if cmd fails

#  Disable errexit first
set +e; result=$(cmd); set -e
```

**Ref:** BCS0801


---


**Rule: BCS0802**

## Exit Codes

**Use standardized exit codes with `die()` function for consistent error handling.**

**Core implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success
die 1 'General error'    # Catchall
die 2 'Missing argument' # Usage error
die 22 'Invalid option'  # Invalid argument (EINVAL)
```

**Standard codes:**
- **0** = Success
- **1** = General error (catchall)
- **2** = Misuse of shell builtin (missing argument/keyword)
- **22** = Invalid argument (errno EINVAL)
- **126** = Command cannot execute (permission issue)
- **127** = Command not found (typo/PATH issue)
- **128+n** = Fatal signal n (e.g., 130 = Ctrl+C)
- **255** = Exit status out of range

**Rationale:**
1. **0 = success** - Universal Unix/Linux convention; enables `command && next` chaining
2. **1-125 custom range** - Avoids signal conflicts (128+); safe for script-specific meanings
3. **22 = EINVAL** - Standard errno improves interoperability with C libraries/system tools

**Define constants for readability:**
```bash
readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3
die "$ERR_CONFIG" 'Failed to load configuration'
```

**Anti-patterns:**
- `exit` ’ Use `die 1 'reason'` (provides context)
- High exit codes (>125) ’ Conflict with signal codes

**Ref:** BCS0802


---


**Rule: BCS0803**

## Trap Handling

**Always use traps to ensure resource cleanup on exit, errors, and signals.**

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:**
- **Resource cleanup**: Temp files/locks/processes cleaned up on any exit
- **Preserves exit code**: `$?` captures original status before cleanup
- **Signal handling**: Responds to Ctrl+C, kill, normal exit, and errors

**Key signals:** `EXIT` (any exit), `SIGINT` (Ctrl+C), `SIGTERM` (kill)

**Critical patterns:**
- **Set trap early** (before creating resources) â†’ `trap 'cleanup $?' EXIT; temp_file=$(mktemp)`
- **Disable trap in cleanup** â†’ prevents recursion if cleanup fails
- **Single quotes** â†’ delay variable expansion: `trap 'rm "$file"' EXIT` not `trap "rm $file" EXIT`
- **Preserve exit code** â†’ `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`

**Anti-patterns:**
```bash
# âœ— Wrong - doesn't preserve exit code
trap 'rm "$file"; exit 0' EXIT

# âœ— Wrong - trap set after resource creation (leak risk)
temp_file=$(mktemp); trap 'rm "$temp_file"' EXIT

# âœ— Wrong - double quotes expand now, not on trap
trap "rm $temp_file" EXIT

# âœ“ Correct
trap 'cleanup $?' EXIT
temp_file=$(mktemp)
```

**Ref:** BCS0803


---


**Rule: BCS0804**

## Checking Return Values

**Always check return values with contextual error messages. While `set -e` helps, explicit checks provide better control and messaging.**

**Rationale:** `set -e` doesn't catch: pipeline failures (except last), conditionals, `||` operations, command substitution in assignments. Explicit checks provide context, enable recovery, aid debugging.

**Patterns:**

1. **Explicit if:** `if ! mv "$src" "$dst/"; then error "Failed to move $src to $dst"; exit 1; fi`
2. **|| with die:** `mv "$src" "$dst/" || die 1 "Failed to move $src"`
3. **|| with cleanup:** `mv "$tmp" "$final" || { error "Move failed"; rm -f "$tmp"; exit 1; }`
4. **Capture code:** `cmd; exit_code=$?; ((exit_code != 0)) && die 1 "Failed: $exit_code"`
5. **Function returns:** Use meaningful codes (2=not found, 5=permission, 22=invalid)

**Pipelines:**
```bash
set -o pipefail  # Fail if any pipeline command fails
cat file | grep pattern | sort  # Exits if any fails
```

**Command substitution:**
```bash
output=$(cmd) || die 1 "cmd failed"  # Check after
shopt -s inherit_errexit  # Inherit set -e (Bash 4.4+)
```

**Anti-patterns:**
```bash
#  No check
mv "$file" "$dest"

#  Check too late
cmd1; cmd2; (($? != 0))  # Checks cmd2!

#  Generic error
mv "$f" "$d" || die 1 "Failed"

#  Unchecked substitution
output=$(cmd)  # Doesn't exit on failure!
```

**Ref:** BCS0804


---


**Rule: BCS0805**

## Error Suppression

**Only suppress when failure is expected, non-critical, and safe. Always document WHY.**

**Rationale:** Masks bugs, creates silent failures, security risks, debugging impossible.

**Appropriate suppression:**

```bash
# Optional check
command -v tool >/dev/null 2>&1 && have_tool=1 || have_tool=0

# Cleanup (may not exist)
rm -f /tmp/app_* 2>/dev/null || true

# Idempotent
install -d "$dir" 2>/dev/null || true
```

**Dangerous suppression:**

```bash
# âœ— Critical operation â†’ script continues with missing file
cp "$important" "$dest" 2>/dev/null || true

# âœ“ Correct
cp "$important" "$dest" || die 1 "Copy failed"

# âœ— Security â†’ wrong permissions = vulnerability
chmod 600 "$key" 2>/dev/null || true

# âœ“ Correct
chmod 600 "$key" || die 1 "Failed to secure key"
```

**Patterns:**
- `2>/dev/null` â†’ Suppress messages, check return code
- `|| true` â†’ Ignore return code, keep messages
- `2>/dev/null || true` â†’ Suppress both (rarely)
- Always comment: `# Suppress: files may not exist (non-critical)`

**Critical anti-patterns:**
- `} 2>/dev/null` â†’ Suppresses ALL function errors (catastrophic)
- `set +e; cmd; set -e` â†’ Disables checking for block
- Suppressing dependencies â†’ later fails mysteriously
- Suppressing data ops â†’ silent data loss

**Key:** `2>/dev/null` and `|| true` are deliberate decisions this failure is safe. Document why.

**Ref:** BCS0805


---


**Rule: BCS0806**

## Conditional Declarations with Exit Code Handling

**Append `|| :` after `((condition)) && action` to prevent false arithmetic conditions from triggering `set -e` script exit.**

**Rationale:** Under `set -e`, `(())` returns 1 when false, causing script exit. `|| :` provides safe fallback (colon always returns 0).

**Core pattern:**

```bash
set -euo pipefail
declare -i complete=0

# âœ— Script exits if complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# âœ“ Safe - script continues
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Common use:**

```bash
# Conditional declarations
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :

# Nested conditionals
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' || :
fi

# Conditional blocks
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :
```

**Use `|| :` for:** Optional declarations, feature-gated actions, debug output, tier-based variables.

**Don't use for:** Critical operations (use explicit checks), operations where failure matters.

**Anti-pattern:**

```bash
# âœ— No || :, exits on false
((complete)) && declare -g BLUE=$'\033[0;34m'

# âœ— Suppresses critical errors
((confirmed)) && delete_files || :
```

**Cross-ref:** BCS0705 (Arithmetic), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Ref:** BCS0806


---


**Rule: BCS0900**

# Input/Output & Messaging

**Standardized messaging with color support, proper stream handling, and complete function suite.**

**Core principle:** STDOUT for data, STDERR for diagnostics. Error output uses `>&2` at command beginning.

**Standard functions:** `_msg()` (core using FUNCNAME), `vecho()` (verbose), `success()`, `warn()`, `info()`, `debug()`, `error()` (stderr), `die()` (exit with error), `yn()` (yes/no prompts).

**Critical pattern:** Place `>&2` at beginning of error commands for clarity: `>&2 echo "error"` not `echo "error" >&2`.

**Ref:** BCS0900


---


**Rule: BCS0901**

## Standardized Messaging and Color Support

**Detect terminal output (`-t 1 && -t 2`), set ANSI colors if yes, empty strings if no.**

**Rationale:** Prevents ANSI escape codes in logs/pipes (breaks parsers); terminal-only colors improve UX.

**Pattern:**
```bash
# Flags for messaging
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Color detection
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Anti-pattern:** `RED=$'\033[0;31m'` (unconditional) ’ breaks piped output.

**Ref:** BCS0901


---


**Rule: BCS0902**

## STDOUT vs STDERR

**All error messages must go to STDERR; place `>&2` at the beginning of commands for clarity.**

**Rationale:**
- Standard Unix convention: errors ’ STDERR, normal output ’ STDOUT
- Enables proper output separation in pipes/redirections (`script.sh > output.log`)

**Code Example:**
```bash
# Preferred - redirect at beginning
error() {
  >&2 echo "[ERROR]: $*"
}

# Also acceptable - redirect at end
warn() {
  echo "[WARN]: $*" >&2
}
```

**Anti-patterns:**
- `echo "Error: ..." #  Goes to STDOUT, breaks pipes`
- `echo "Error: ..." 1>&2 #  Explicit fd 1 unnecessary`

**Ref:** BCS0902


---


**Rule: BCS0903**

## Core Message Functions

**Use `_msg()` core with `FUNCNAME[1]` inspection for auto-formatted colored output.**

**Rationale:** DRY (single impl), auto-context, proper streams (errorsâ†’stderr).

**Pattern:**

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die()     { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }
```

**Flags:** `declare -i VERBOSE=0 DEBUG=0 PROMPT=1`

**Colors:** `if [[ -t 1 && -t 2 ]]; then RED=$'\033[0;31m'; else RED=''; fi; readonly -- RED GREEN YELLOW CYAN NC`

**Anti-patterns:** `echo "Error"` â†’ `error 'Message'` | duplicate function logic â†’ use `_msg()` core | errors to stdout â†’ `>&2` prefix | ignore flags â†’ check `VERBOSE`/`DEBUG`

**Ref:** BCS0903


---


**Rule: BCS0904**

## Usage Documentation

**Use `show_help()` with heredoc for multi-line help text.**

**Rationale:** Heredocs preserve formatting; readable structure for users.

**Example:**
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose  Verbose output
  -h|--help     Show help
EOT
}
```

**Anti-pattern:** `echo` chains â†’ `show_help() { echo "line1"; echo "line2"; }`

**Ref:** BCS0904


---


**Rule: BCS0905**

## Echo vs Messaging Functions

**Use messaging functions for operational status (stderr); use `echo` for data output (stdout).**

**Rationale:**
- Stream separation: Statusâ†’stderr, dataâ†’stdout
- Messaging respects `VERBOSE`; `echo` always displays
- `echo` enables piping without mixing status

**Use messaging:** Status (`info 'Starting'`, `success 'Done'`), diagnostics (`debug "var=$val"`)

**Use `echo`:** Data output (capturable), help text (always show), reports/parsing

**Example:**

```bash
# Data function â†’ echo
get_user_home() {
  echo "$(getent passwd "$1" | cut -d: -f6)"
}

# Proper streams
main() {
  info "Looking up: $user"      # stderr
  home=$(get_user_home "$user") # capture
  success "Found: $user"        # stderr
  echo "Home: $home"            # stdout
}
```

**Anti-patterns:**

```bash
# âœ— info() for data â†’ stderr, uncapturable
get_value() { info "$result"; }
# âœ“ echo for data â†’ stdout, capturable
get_value() { echo "$result"; }

# âœ— echo for status â†’ mixes with data
process() { echo "Processing..."; cat "$file"; }
# âœ“ Messaging for status â†’ separate streams
process() { info 'Processing...'; cat "$file"; }
```

**Decision**: Status/diagnostics â†’ messaging. Data/parseable â†’ `echo`. Respects verbosity â†’ messaging. Always display â†’ `echo`.

**Ref:** BCS0905


---


**Rule: BCS0906**

## Color Management Library

**Use dedicated color management library for sophisticated color needs: two-tier system (basic 5 vars / complete 12 vars), auto-detection, `_msg` integration.**

**Rationale:** Namespace control, terminal auto-detection (stdout+stderr), integration with BCS control flags (VERBOSE/DEBUG/DRY_RUN/PROMPT), reusable dual-purpose pattern, centralized definitions.

**Two-Tier System:**
- **Basic** (default): `NC RED GREEN YELLOW CYAN`
- **Complete** (opt-in): adds `BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE`

**Function:** `color_set [OPTIONS...]`

**Options:** `basic` (default) | `complete` | `auto` (default, checks stdout+stderr) | `always` | `never`/`none` | `verbose`/`-v` | `flags` (sets VERBOSE/DEBUG/DRY_RUN/PROMPT)

**Example:**
```bash
#!/bin/bash
source color-set.sh
color_set complete flags  # Colors + _msg system

info "Starting"         # Uses CYAN, respects VERBOSE
success "Completed"     # Uses GREEN
error "Failed"          # Uses RED
```

**Dual-Purpose (BCS010201):**
```bash
# Source as library
source color-set.sh && color_set complete

# Execute for demo
./color-set.sh complete verbose
```

**Anti-patterns:** Scattered inline declarations ’ centralize | Always complete tier ’ use basic when sufficient | Test only stdout `[[ -t 1 ]]` ’ test both `[[ -t 1 && -t 2 ]]`

**Ref:** BCS0906


---


**Rule: BCS1000**

# Command-Line Arguments

**Standard argument parsing supporting both short (`-h`, `-v`) and long options (`--help`, `--version`).**

Defines canonical version output format (`scriptname X.Y.Z`), validation patterns for required arguments and option conflicts, and argument parsing placement (main function vs top-level) based on script complexity.

**Ref:** BCS1000


---


**Rule: BCS1001**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` with short option bundling support.**

**Rationale:** Arithmetic test `(($#))` more efficient than `[[ $# -gt 0 ]]`; case statement more readable than if/elif chains; supports Unix conventions (bundled shorts, long options).

**Pattern:**

```bash
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift; output_file=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -h|--help)      show_help; exit 0 ;;
  -[ovh]*)        set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              files+=("$1") ;;
esac; shift; done

noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }
```

**Key elements:** Options with args use `noarg "$@"; shift` ’ prevents missing arg errors. Bundling pattern `-[ovh]*` splits `-voh` ’ `-v -o -h`. Invalid option `-*)` catches unknowns. Positional args `*)` append to array. Mandatory `shift` at loop end prevents infinite loop.

**Anti-patterns:** `while [[ $# -gt 0 ]]` (verbose) ’ use `while (($#))`. Missing `noarg` before shift ’ fails on missing args. Forgetting `shift` at end ’ infinite loop. if/elif chains ’ use case.

**Ref:** BCS1001


---


**Rule: BCS1002**

## Version Output Format

**Format: `<script_name> <version_number>` (no "version" word between them)**

**Rationale:** Follows GNU standards (e.g., `bash --version` outputs "GNU bash, version 5.2.15"). Consistent with Unix/Linux utilities.

**Example:**
```bash
# âœ“ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# âœ— Wrong â†’ includes "version" word
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3
```

**Ref:** BCS1002


---


**Rule: BCS1003**

## Argument Validation

**Validate option arguments before use - prevent silent failures and undefined behavior.**

**Rationale:** Missing arguments cause options to consume next flag/argument as value, breaking parse logic. Early validation with clear errors prevents debugging nightmares in production.

**Pattern:**
```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"; }

# Usage in parsing
-o|--output)
  noarg "$@"
  OUTPUT_FILE=$2
  shift 2
  ;;
```

**Anti-patterns:**
- `OUTPUT_FILE=$2` without validation ’ consumes next flag as filename
- Custom validation per option ’ code duplication, inconsistent errors

**Ref:** BCS1003


---


**Rule: BCS1004**

## Argument Parsing Location

**Place argument parsing inside `main()` function, not at top level.**

**Rationale:** Better testability (can invoke `main()` with test arguments), cleaner variable scoping (parsing vars are local), proper encapsulation of execution flow.

**Exception:** Simple scripts <200 lines without `main()` may parse at top level.

```bash
# Recommended: Parse inside main()
main() {
  while (($#)); do
    case $1 in
      --option)  VAR=1 ;;
      --prefix)  shift; PREFIX="$1" ;;
      -h|--help) show_help; exit 0 ;;
      -*)        die 22 "Invalid option '$1'" ;;
    esac
    shift
  done

  check_prerequisites
  run_logic
}

main "$@"
#fin
```

**Anti-pattern:** Top-level parsing in complex scripts (â‰¥200 lines) â†’ untestable, global scope pollution.

**Ref:** BCS1004


---


**Rule: BCS1005**

## Short-Option Disaggregation

**Split bundled short options (`-abc` ’ `-a -b -c`) to support Unix conventions where `script -vvn` equals `script -v -v -n`.**

**Three Implementation Methods:**

**Method 1: grep** (190 iter/sec, external dependency)
```bash
-[amvh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**Method 2: fold** (195 iter/sec, 2.3% faster, external dependency)
```bash
-[amvh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**Method 3: Pure Bash** (318 iter/sec, **68% faster**, recommended)
```bash
-[amvh]*) # Split up single options (pure bash)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}"
  ;;
```

**Rationale:** Pure bash eliminates external command overhead and shellcheck warnings. Performance matters for interactive tools, build systems, and frequently-called scripts.

**Critical Requirements:**
- Pattern `-[amvh]*` lists valid short options explicitly
- Place before `-*)` catch-all case
- Options with arguments must be at bundle end: `-vno output.txt` works, `-von output.txt` fails (captures 'n' as argument)

**Anti-Patterns:**
- `` Options requiring arguments mid-bundle ’ captured incorrectly
- `` Missing valid options from pattern ’ caught as invalid options

**Ref:** BCS1005


---


**Rule: BCS1100**

# File Operations

**Safe file handling practices preventing common shell scripting pitfalls.** Covers file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`) with mandatory quoting, safe wildcard expansion using explicit paths (`rm ./*` never `rm *`), process substitution (`< <(command)`) to avoid subshell variable issues, and here document patterns for multi-line input.

**Rationale:** Prevents accidental file deletion, handles special characters safely, ensures reliable operations across environments.

**Example:**
```bash
# File tests (always quote)
[[ -f "$config" ]] && source "$config"
[[ -d "$dir" && -w "$dir" ]] && cd "$dir"

# Safe wildcards (explicit paths)
rm ./*.tmp                    #  Explicit path
rm -- *.tmp                   #  Dangerous without ./

# Process substitution (avoids subshell)
while IFS= read -r line; do
  count+=1                    #  Variable persists
done < <(command)
```

**Anti-patterns:**
- Unquoted test variables: `[[ -f $file ]]` ’ fails with spaces
- Bare wildcards: `rm *.log` ’ deletes from wrong directory if cd fails

**Ref:** BCS11


---


**Rule: BCS1101**

## Safe File Testing

**Always quote variables in `[[ ]]` tests; validate files before use.**

**Core operators:** `-e` (exists), `-f` (regular file), `-d` (directory), `-r` (readable), `-w` (writable), `-x` (executable), `-s` (not empty), `-nt` (newer than), `-ot` (older than)

**Rationale:**
- Quoting prevents word splitting/glob expansion with spaces/special chars
- `[[ ]]` more robust than `[ ]` or `test`
- Pre-validation prevents runtime errors from missing/inaccessible files

**Minimal example:**

```bash
# Validate and source config
validate_config() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found: $file"
  [[ -r "$file" ]] || die 5 "Cannot read: $file"
  source "$file"
}

# Process only if modified
[[ "$source" -nt "$marker" ]] && { process "$source"; touch "$marker"; }
```

**Critical anti-patterns:**

- `[[ -f $file ]]` ’ Unquoted (breaks with spaces) ’ Use `[[ -f "$file" ]]`
- `source "$config"` ’ No validation ’ Check `-f` and `-r` first

**Ref:** BCS1101


---


**Rule: BCS1102**

## Wildcard Expansion

**Always prefix wildcards with `./` to prevent filenames starting with `-` from being interpreted as flags.**

**Rationale:** Files like `-rf` or `--help` become command flags without path prefix, causing command failures or destructive operations.

**Example:**
```bash
#  Correct
rm ./*
for file in ./*.txt; do process "$file"; done

#  Wrong - `-file.txt` becomes a flag
rm *
```

**Anti-patterns:** `rm *`, `mv * dest/`, `cp * dest/` ’ Use `rm ./*`, `mv ./* dest/`, `cp ./* dest/`

**Ref:** BCS1102


---


**Rule: BCS1103**

## Process Substitution

**Use `<(command)` for input and `>(command)` for output to provide command streams as file-like objects, eliminating temp files and avoiding subshell variable scope issues.**

**Rationale:** Streams data through FIFOs without disk I/O, preserves variable scope (unlike pipes), enables parallel processing.

**Basic patterns:**
```bash
# Input: compare outputs
diff <(sort file1) <(sort file2)

# Output: parallel processing
cat log | tee >(grep ERROR > errors.txt) >(wc -l > count.txt) > /dev/null

# Avoid subshell - variables persist
count=0
while read -r line; do
  ((count+=1))
done < <(cat file)
echo "$count"  # Correct value (not 0)

# Array population
readarray -t users < <(getent passwd | cut -d: -f1)
```

**Anti-patterns:**
```bash
#  Temp files
temp=$(mktemp); sort file1 > "$temp"; diff "$temp" file2; rm "$temp"

#  Process substitution
diff <(sort file1) file2

#  Pipe to while (subshell - variables don't persist)
cat file | while read -r line; do count+=1; done

#  Process substitution (no subshell)
while read -r line; do count+=1; done < <(cat file)
```

**Ref:** BCS1103


---


**Rule: BCS1104**

## Here Documents

**Use here documents for multi-line strings/input with quoted delimiter for literal text, unquoted for variable expansion.**

**Rationale:** Here docs prevent quoting complexity in multi-line strings; delimiter quoting controls expansion behavior explicitly.

```bash
# Literal (no expansion)
cat <<'EOF'
Static text
EOF

# With expansion
cat <<EOF
User: $USER
EOF
```

**Anti-patterns:** `'EOF'` ’ unquoted EOF (unexpected expansion); echo chains for multi-line output.

**Ref:** BCS1104


---


**Rule: BCS1105**

## Input Redirection vs Cat: Performance Optimization

**Replace `cat filename` with `< filename` to eliminate fork overhead (3-107x speedup).**

### Benchmark (1000 iterations)

- `$(cat file)` 0.965s â†’ `$(< file)` 0.009s (**107x**)
- `cat file | cmd` 0.792s â†’ `cmd < file` 0.234s (**3.4x**)

**Rationale:** `cat` forks process, execs binary. `< file` opens FD in shell (zero processes). `$(< file)` bash reads directly.

### Usage Patterns

**Command substitution (107x faster):**
```bash
content=$(< file.txt)      # RECOMMENDED
content=$(cat file.txt)    # AVOID
```

**Single file input (3-4x faster):**
```bash
grep "pattern" < file.txt           # RECOMMENDED
cat file.txt | grep "pattern"       # AVOID
```

**Loops (cumulative gains):**
```bash
for file in *.json; do
    data=$(< "$file")      # 107x per iteration
done
```

**Impact:** 100 files, 4 reads = 400 forks â†’ 1 (concatenation) = 300 eliminated, **10-100x faster**

### When NOT to Use

| Scenario | Use cat |
|----------|---------|
| Multiple files | `cat file1 file2` |
| Options | `cat -n file` |
| Direct output | `cat file` |

### Anti-Pattern

```bash
# âœ— No output
< file.txt

# âœ— Invalid
< file1.txt file2.txt

# âœ“ Correct
cat file1.txt file2.txt
```

**Note:** `<` is redirection operator. Needs consuming command (except `$()`).

### Recommendation

**SHOULD:** `$(< file)` (107x), `cmd < file` (3-4x), loops

**MUST use cat:** Multiple files, options

**Ref:** BCS1105


---


**Rule: BCS1200**

# Security Considerations

**Security-first practices for production bash scripts across five essential areas: SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, and input sanitization.**

Prevents privilege escalation, command injection, path traversal, and common attack vectors.

**Ref:** BCS12


---


**Rule: BCS1201**

## SUID/SGID

**Never use SUID/SGID bits on Bash scriptsâ€”catastrophic security risk with zero exceptions.**

```bash
# âœ— NEVER
chmod u+s script.sh    # SUID
chmod g+s script.sh    # SGID

# âœ“ Use sudo
sudo script.sh
```

**Rationale:** Kernel executes interpreter with elevated privileges before script runs. Attack vectors: IFS exploitation splits words unexpectedly; PATH manipulation substitutes malicious interpreter; `LD_PRELOAD` injects code; race conditions in file operations.

**IFS Attack:**
```bash
# SUID script reads file
export IFS='/'
./suid_script.sh "../../etc/shadow"  # Path split into words
```

**PATH Attack:** Attacker creates fake bash in `/tmp/evil/bash` that steals data, then sets `PATH=/tmp/evil:$PATH`. Kernel uses caller's PATH to find interpreter!

**Safe Alternatives:**

1. **Sudo with permissions:**
```bash
# /etc/sudoers.d/app
user ALL=(root) NOPASSWD: /usr/local/bin/script.sh
```

2. **Compiled SUID wrapper** (validates, sanitizes environment, executes script)

3. **Capabilities** (compiled programs): `setcap cap_net_bind_service=+ep binary`

4. **Systemd service** with `User=root`

**Detection:**
```bash
# Find SUID/SGID scripts (should be empty!)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Modern Linux ignores SUID on scripts, but many Unix variants honor it. Never rely on OS protectionâ€”avoid entirely.**

**Ref:** BCS1201


---


**Rule: BCS1202**

## PATH Security

**Lock down PATH immediately at script start to prevent command hijacking attacks.**

**Rationale:** Inherited PATH may contain attacker-controlled directories allowing malicious binaries to replace system commands. Empty elements (`::`), current directory (`.`), or world-writable paths enable privilege escalation.

**Pattern 1 - Complete lockdown (recommended):**
```bash
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Pattern 2 - Validation with reset:**
```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Pattern 3 - Absolute paths (maximum security):**
```bash
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
```

**Anti-patterns:**
```bash
# âœ— No PATH setting - inherits environment
ls /etc

# âœ— Includes current directory
export PATH=.:$PATH

# âœ— Empty elements (:: = current dir)
export PATH=/usr/bin::/bin

# âœ— World-writable paths
export PATH=/tmp:$PATH
```

**Key principles:**
- Set PATH immediately after `set -euo pipefail`
- Use `readonly PATH` to prevent modification
- Never include `.`, empty elements, `/tmp`, user directories
- Validate inherited PATH or replace with secure default

**Ref:** BCS1202


---


**Rule: BCS1203**

## IFS Manipulation Safety

**Never trust inherited IFS values. Always protect IFS changes to prevent field splitting attacks.**

**Rationale:**
- Attackers can manipulate IFS in calling environment to exploit scripts
- Malicious IFS causes splitting at unexpected characters, enabling command injection
- IFS is inherited from parent processes and may be attacker-controlled

**Safe Patterns:**

```bash
# 1. One-line assignment (preferred for single operations)
IFS=',' read -ra fields <<< "$csv_data"  # Auto-resets after command

# 2. Local IFS in function
parse_csv() {
  local -- IFS  # Scope IFS to function
  IFS=','
  read -ra fields <<< "$data"
}  # Auto-restores on return

# 3. Explicit set at script start (defense against inheritance)
IFS=$' \t\n'  # Space, tab, newline
readonly IFS
export IFS
```

**Attack Example:**
```bash
# Vulnerable: trusts inherited IFS
read -ra files <<< "$file_list"

# Attack:
export IFS='/'
./script.sh  # Splits on '/' not spaces ’ bypasses validation
```

**Anti-patterns:**
```bash
#  Global modification without restore
IFS=','
read -ra fields <<< "$data"
# IFS is ',' for rest of script ’ breaks subsequent operations

#  Trusting inherited IFS
read -ra parts <<< "$user_input"  # Vulnerable to manipulation
```

**Key principle:** IFS is security-critical. Use one-line assignment `IFS=',' read`, local IFS in functions, or readonly at script start.

**Ref:** BCS1203


---


**Rule: BCS1204**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirelyâ€”safer alternatives exist.**

**Rationale:**
- Code injection enables complete system compromise
- No sandboxingâ€”runs with full script privileges
- Bypasses validationâ€”metacharacters enable injection despite sanitization
- Better alternatives: arrays, indirect expansion, associative arrays

**Attack vectors:** Direct injection (`eval "$user_input"`), variable name injection, escaped character bypass, log injection.

**Safe Alternatives:**

```bash
# âœ— Wrong - eval for command building
cmd="find /data -name '$pattern'"
eval "$cmd"

# âœ“ Correct - use array
cmd=(find /data -name "$pattern")
"${cmd[@]}"

# âœ— Wrong - eval for variable indirection
eval "value=\$$var_name"

# âœ“ Correct - indirect expansion
echo "${!var_name}"

# âœ— Wrong - dynamic variables
eval "var_$i='value'"

# âœ“ Correct - associative array
declare -A data
data["var_$i"]="value"
```

**Anti-patterns:**
- `eval "$user_command"` â†’ Validate whitelist with `case` statement
- `eval "$var='$val'"` â†’ Use `printf -v "$var" '%s' "$val"`
- `eval "source $file"` â†’ Use `source "$file"` directly
- `eval "echo \$$var"` â†’ Use `"${!var}"` indirect expansion

**Key principle:** If you think you need `eval`, solve differentlyâ€”arrays, indirect expansion (`${!var}`), associative arrays (`declare -A`), or case statements handle 99.9% of use cases safely.

**Ref:** BCS1204


---


**Rule: BCS1205**

## Input Sanitization

**Always validate and sanitize user input before processing to prevent injection attacks, directory traversal, and data corruption.**

**Rationale:**
- Prevents command/SQL injection attacks
- Blocks directory traversal (`../../../etc/passwd`)
- Defense in depth - never trust user input

**Example validation:**

```bash
sanitize_filename() {
  local -- name="$1"
  [[ -n "$name" ]] || die 22 'Filename cannot be empty'
  name="${name//\.\./}"; name="${name//\//}"  # Strip .. and /
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename: $name"
  [[ ! "$name" =~ ^\. ]] || die 22 "Cannot start with dot: $name"
  ((${#name} <= 255)) || die 22 "Filename too long: $name"
  echo "$name"
}

safe_file=$(sanitize_filename "$user_input")
cat -- "$safe_file"  # Use -- to prevent option injection
```

**Validation patterns:**
- **Numeric**: `[[ "$input" =~ ^[0-9]+$ ]]` â†’ validates positive integer
- **Path**: Use `realpath -e` then check within allowed directory
- **Whitelist**: Define allowed values, reject all else

**Critical anti-patterns:**
- `eval "$user_input"` â†’ Command injection vulnerability
- `rm "$file"` â†’ Option injection if file=`--delete-all`; use `rm -- "$file"`
- Blacklist approach â†’ Always incomplete; use whitelist

**Security principles:**
1. Whitelist over blacklist (define what IS allowed)
2. Validate early (before processing)
3. Use `--` separator (prevents option injection)
4. Never use `eval` with user input

**Ref:** BCS1205


---


**Rule: BCS1300**

# Code Style & Best Practices

**Comprehensive coding conventions** covering formatting (2-space indentation, 100-char lines, alignment), comments (explain WHY not WHATrationale/business logic only), blank lines (visual separation), section markers (banner-style), language practices (Bash idioms, modern features), and development (mandatory ShellCheck, testing, version control).

**Rationale:** Consistent style ensures readability and maintainability; focus on intent over mechanics; leverage Bash 5.2+ features.

**Example:**
```bash
# Configuration paths - support FHS and local overrides
declare -- CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"/myapp
declare -- SYSTEM_CONFIG=/etc/myapp

# Process configuration - user settings override system defaults
load_config() {
  [[ -f "$SYSTEM_CONFIG" ]] && source "$SYSTEM_CONFIG"
  [[ -f "$CONFIG_DIR/config" ]] && source "$CONFIG_DIR/config"
}
```

**Anti-patterns:**
- `echo "Processing files"` ’ Comment states WHAT code shows
- 4-space indent, tabs, 120+ char lines ’ Inconsistent formatting

**Ref:** BCS1300


---


**Rule: BCS1301**

## Code Formatting

**Use 2 spaces for indentation (never tabs), maintain 100-character line limit (except URLs/paths), use `\` for line continuation.**

**Rationale:** Consistent 2-space indentation ensures readability across all editors without tab-width conflicts. 100-character limit balances readability on standard terminals while allowing exceptions for unavoidable long paths/URLs.

**Example:**
```bash
# Correct - 2 spaces, line continuation
if [[ -f "$config_file" ]]; then
  very_long_command --option1 value1 \
    --option2 value2 --option3 value3
fi

# Wrong - tabs, no continuation
if [[ -f "$config_file" ]]; then
	very_long_command --option1 value1 --option2 value2 --option3 value3
fi
```

**Anti-patterns:** Tabs ’ `Use 2 spaces`; Lines >100 chars without reason ’ `Use \`

**Ref:** BCS1301


---


**Rule: BCS1302**

## Comments

**Explain WHY (rationale/business logic/decisions), not WHAT (code already shows).**

```bash
# âœ“ Good - explains rationale
# PROFILE_DIR hardcoded to /etc/profile.d for system-wide integration
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited

# âœ— Bad - restates code
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Comment:** Non-obvious business rules, intentional deviations, complex logic rationale, gotchas. **Avoid:** Simple assignments, obvious conditionals, self-explanatory code.

**Icons:** Use only: â—‰ (info), â¦¿ (debug), â–² (warn), âœ“ (success), âœ— (error).

**Ref:** BCS1302


---


**Rule: BCS1303**

## Blank Line Usage

**Use single blank lines to separate logical blocks for readability.**

**Rationale:**
- Visual separation improves code scanning speed
- Groups related statements, isolates unrelated ones

**Example:**
```bash
#!/bin/bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH

declare -- PREFIX=/usr/local
declare -i DRY_RUN=0

check_prerequisites() {
  info 'Checking prerequisites...'

  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'
}

main() {
  check_prerequisites
  install_files
}

main "$@"
#fin
```

**Rules:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between variable groups
- `’` Avoid multiple consecutive blank lines (use one)
- `’` No blank line between short related statements

**Ref:** BCS1303


---


**Rule: BCS1304**

## Section Comments

**Use lightweight `# Description` comments to organize code into logical groups** (no dashes/boxes). Place immediately before group, follow with blank line after group.

**Rationale:** Provides visual structure without heaviness of 80-dash separators; improves readability and navigation in long scripts; groups related declarations/functions logically.

**Example:**
```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

# Core message function
_msg() { local -- prefix="$SCRIPT_NAME:" msg; ...; }

# Conditional messaging functions
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
```

**Anti-patterns:** Heavy box-drawing (`#### Section ####`) ’ use simple format; verbose descriptions ’ keep 2-4 words.

**Ref:** BCS1304


---


**Rule: BCS1305**

## Language Best Practices

**Always use `$()` for command substitution** (never backticks). `$()` nests naturally, has better editor support, and is visually clearer.

**Prefer shell builtins over external commands.** Builtins are 10-100x faster (no process creation), don't depend on PATH, and eliminate subshell failures.

```bash
#  Builtins
addition=$((x + y))
uppercase=${var^^}
[[ -f "$file" ]]

#  External commands
addition=$(expr "$x" + "$y")  # spawns process
uppercase=$(echo "$var" | tr '[:lower:]' '[:upper:]')
[ -f "$file" ]  # use [[ instead
```

**Common replacements:** `expr` ’ `$(())`, `basename` ’ `${var##*/}`, `dirname` ’ `${var%/*}`, `tr` (case) ’ `${var^^}` / `${var,,}`, `seq` ’ `{1..10}`

**Ref:** BCS1305


---


**Rule: BCS1306**

## Development Practices

**ShellCheck compliance is compulsory.** Document all `#shellcheck disable=` directives with explanatory comments.

**Rationale:** Catches 95% of common bash errors; reduces debugging time by 3-5x; enforces portability.

```bash
# Document why disabling
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"

# Run during development
shellcheck -x script.sh
```

**Scripts must end with `#fin` marker** (or `#end`). Signals intentional completion vs truncation.

**Defensive patterns:**
- Default critical variables: `: "${VERBOSE:=0}"`
- Validate inputs early: `[[ -n "$1" ]] || die 1 'Argument required'`
- Use `set -u` to catch unset variables

**Performance:** Minimize subshells â†’ use `${var##pattern}` not `basename`; process substitution over temp files; batch operations.

**Testing:** Export testable functions (`declare -fx`), support verbose/debug modes, return meaningful exit codes (0=success, 1=general error, 2=usage error).

**Anti-patterns:**
- `shellcheck` failures ignored without documentation
- Missing `#fin` marker (looks incomplete)
- No input validation â†’ runtime failures in production

**Ref:** BCS1306


---


**Rule: BCS1307**

## Emoticons

**Standard documentation icons for codebase use (internal/external).**

**Severity levels:**
```
É  info          ¿ debug         ²  warn
  error           success
```

**Extended icons:**
```
   Caution       "  Fatal         »  Redo/Update
Æ  Checkpoint    Ï  In Progress   Ë  Pending
Ð  Partial       ¶  Start            Stop
ø  Pause         ù  Terminate     †  Power
0  Menu          ™  Settings      ’  Forward
  Back          ‘  Up            “  Down
Ä  Swap          Å  Sync          ó  Processing
ñ  Timer
```

**Rationale:** Consistent visual semantics; universally recognized symbols; improves scanability in logs/docs; reduces text verbosity.

**Ref:** BCS1307


---


**Rule: BCS1400**

# Advanced Patterns

**Section covers 10 production-grade patterns for system administration and automation scripts.**

**Patterns:**
1. **Debugging** - `set -x`, `PS4` customization
2. **Dry-run mode** - Safe testing before deployment
3. **Temporary files** - Secure `mktemp` usage with traps
4. **Environment variables** - Safe defaults, validation
5. **Regular expressions** - Pattern matching with `[[ =~ ]]`
6. **Background jobs** - Parallel execution, `wait` coordination
7. **Structured logging** - Consistent log formats, rotation
8. **Performance profiling** - `time`, optimization techniques
9. **Testing** - Validation methodologies
10. **Progressive state management** - Boolean flags separating decision logic from execution

**Core principle:** Solve real-world challenges through safe testing, performance optimization, robust error handling, and maintainable state logic.

**Ref:** BCS1400


---


**Rule: BCS1401**

## Debugging and Development

**Use `DEBUG` flag with trace mode and enhanced `PS4` for development troubleshooting.**

**Rationale:**
- `set -x` trace output shows exact command execution for diagnosing failures
- Enhanced `PS4` adds file/line/function context (default `PS4='+ '` lacks detail)

**Implementation:**

```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}
```

**Usage:** `DEBUG=1 ./script.sh`

**Anti-patterns:**
- `set -x` without custom `PS4` ’ unreadable trace
- Using `echo` instead of `debug()` function ’ pollutes normal output

**Ref:** BCS1401


---


**Rule: BCS1402**

## Dry-Run Pattern

**Implement preview mode allowing users to see planned changes without execution.**

**Rationale:** Prevents destructive errors in installation/deployment scripts; identical control flow regardless of mode simplifies testing.

**Pattern:**
```bash
# Declaration
declare -i DRY_RUN=0

# CLI parsing
-n|--dry-run) DRY_RUN=1 ;;

# Function implementation
install_files() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install to /usr/local/bin'
    return 0
  fi
  # Actual operations
  install -m 755 file "$BIN_DIR"/
}
```

**Structure:**
1. Check `((DRY_RUN))` at function start
2. Display `[DRY-RUN]` prefixed message using `info`
3. Return 0 early without modifications
4. Execute real operations only when disabled

**Anti-patterns:**
- `if ! ((DRY_RUN))` ’ Inverted logic harder to read
- Multiple dry-run checks within function ’ Duplicates decision logic

**Ref:** BCS1402


---


**Rule: BCS1403**

## Temporary File Handling

**Always use `mktemp` with EXIT trap cleanup. Never hard-code paths.**

**Rationale:**
- **Security**: Atomic creation, 0600 permissions (files), 0700 (dirs)
- **Uniqueness**: Prevents collisions/race conditions
- **Cleanup guarantee**: EXIT trap ensures cleanup on failure/interruption

**Basic pattern:**

```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file
echo 'data' > "$temp_file"
```

**Multiple files (array):**

```bash
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
    [[ -d "$file" ]] && rm -rf "$file"
  done
}

trap cleanup_temp_files EXIT

temp1=$(mktemp) || die 1 'Failed'
TEMP_FILES+=("$temp1")
```

**Anti-patterns:**

```bash
# âœ— Hard-coded â†’ collisions, security risk
temp_file="/tmp/myapp_temp.txt"

# âœ— PID-based â†’ predictable, race conditions
temp_file="/tmp/myapp_$$.txt"

# âœ— No trap â†’ file persists on failure
temp_file=$(mktemp)

# âœ— Manual cleanup â†’ fails if error before rm
temp_file=$(mktemp); rm -f "$temp_file"

# âœ— Multiple traps â†’ overwrites previous
trap 'rm -f "$temp1"' EXIT
trap 'rm -f "$temp2"' EXIT  # temp1 lost!

# âœ“ Single trap or cleanup function
trap 'rm -f "$temp1" "$temp2"' EXIT
```

**Ref:** BCS1403


---


**Rule: BCS1404**

## Environment Variable Best Practices

**Validate required variables early using `:` null command with `${VAR:?message}` expansion.** Set optional variables with `${VAR:=default}`. Always quote variable references.

**Rationale:** Early validation prevents runtime failures in production. The `:` builtin is POSIX-standard, exits immediately with error message if variable unset, and has zero overhead.

**Example:**
```bash
# Required validation (exits if unset)
: "${DATABASE_URL:?DATABASE_URL must be set}"
: "${API_KEY:?API_KEY required}"

# Optional with defaults
: "${LOG_LEVEL:=INFO}"
export LOG_LEVEL

# Multi-variable check
declare -a REQUIRED=(DATABASE_URL API_KEY SECRET_TOKEN)
for var in "${REQUIRED[@]}"; do
  [[ -n "${!var:-}" ]] || die "Required variable '$var' not set"
done
```

**Anti-patterns:**
- `if [[ -z "$VAR" ]]; then echo "error"; exit 1; fi` ’ Use `:` validation
- Checking variables deep in business logic ’ Validate at script start

**Ref:** BCS1404


---


**Rule: BCS1405**

## Regular Expression Guidelines

**Use POSIX character classes for portability; store complex patterns as readonly variables; access captures via `BASH_REMATCH` array.**

**Rationale:** POSIX classes (`[[:alnum:]]`) work consistently across locales; named pattern variables document intent and enable reuse; inline complex regex reduces maintainability.

```bash
# POSIX character classes
[[ "$var" =~ ^[[:alnum:]]+$ ]]      # Alphanumeric
[[ "$var" =~ ^[[:digit:]]+$ ]]      # Digits only

# Store complex patterns
readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 'Invalid email'

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
fi
```

**Anti-patterns:** Inline complex regex `’` readonly pattern variable; raw `[a-z]` ranges `’` `[[:alpha:]]` (locale-safe)

**Ref:** BCS1405


---


**Rule: BCS1406**

## Background Job Management

**Track background processes using `$!` for PID capture, `kill -0` for status checks, and `wait` for synchronization.**

**Rationale:** Prevents zombie processes, enables timeout enforcement, allows parallel execution with controlled completion.

```bash
# Track and manage background jobs
long_running_command &
PID=$!

# Check running status
kill -0 "$PID" 2>/dev/null && info "Running: $PID"

# Wait with timeout
timeout 10 wait "$PID" || kill "$PID" 2>/dev/null

# Multiple jobs pattern
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done
for pid in "${PIDS[@]}"; do wait "$pid"; done
```

**Anti-patterns:** `wait` without PID tracking ’ can't enforce timeouts; missing `kill -0` checks ’ operate on terminated PIDs.

**Ref:** BCS1406


---


**Rule: BCS1407**

## Logging Best Practices

**Implement structured file logging for production scripts with ISO8601 timestamps and severity levels.**

**Rationale:** Structured logs enable post-hoc debugging, compliance auditing, and automated monitoring without impacting script performance.

**Pattern:**
```bash
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"

[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"

log() {
  printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$1" "${*:2}" >> "$LOG_FILE"
}

log_info() { log INFO "$@"; }
log_error() { log ERROR "$@"; }
```

**Anti-patterns:** Logging to stdout/stderr only (lost on pipe/redirect) â†’ Use dedicated file; unstructured messages without timestamps â†’ Unparseable.

**Ref:** BCS1407


---


**Rule: BCS1408**

## Performance Profiling

**Use `SECONDS` builtin for simple timing, `EPOCHREALTIME` for high-precision measurements.**

**Rationale:** Native Bash timing eliminates external dependencies; `SECONDS` auto-resets on assignment; `EPOCHREALTIME` provides microsecond precision (Bash 5.0+).

**Example:**
```bash
# Simple timing
profile_op() {
  SECONDS=0
  eval "$1"
  info "Completed in ${SECONDS}s"
}

# High-precision timing
timer() {
  local -- start=$EPOCHREALTIME
  "$@"
  awk "BEGIN {print $EPOCHREALTIME - $start}" | read -r runtime
  info "Runtime: ${runtime}s"
}
```

**Anti-patterns:** Using `date +%s` (second precision only, subprocess overhead).

**Ref:** BCS1408


---


**Rule: BCS1409**

## Testing Support Patterns

**Make scripts testable via dependency injection and test mode flags.**

**Rationale:** Testability requires mocking external commands and conditional behavior. Function wrappers enable test overrides without altering production code.

```bash
# Dependency injection (override in tests)
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }

find_files() { FIND_CMD "$@"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"
((TEST_MODE)) && DATA_DIR='./test_data' || DATA_DIR='/var/lib/app'

# Assert helper
assert() {
  [[ "$1" != "$2" ]] && >&2 echo "FAIL: ${3:-Assertion failed}" && return 1
  return 0
}
```

**Anti-patterns:** Direct command calls (`find "$@"`) instead of wrappers â†’ untestable; no TEST_MODE flag â†’ can't isolate tests.

**Ref:** BCS1409


---


**Rule: BCS1410**

## Progressive State Management

**Use boolean flags that change based on runtime conditions, separating decision logic from execution.**

```bash
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0

# Parse args
--builtin)    INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1 ;;
--no-builtin) INSTALL_BUILTIN=0 ;;

# Adjust based on conditions
! check_support && INSTALL_BUILTIN=0
! build_step && INSTALL_BUILTIN=0

# Execute based on final state
((INSTALL_BUILTIN)) && install_builtin
```

**Pattern:** (1) Declare flags with defaults, (2) Set from args, (3) Adjust based on runtime checks (dependencies, build failures), (4) Execute actions using final state.

**Rationale:** Separates decisions from actions. Track user intent separately from runtime state (e.g., `BUILTIN_REQUESTED` vs `INSTALL_BUILTIN`). Apply changes in order: parse ’ validate ’ execute. Never modify flags during execution.

**Anti-pattern:**
```bash
#  Decision mixed with execution
if ((BUILTIN_REQUESTED)) && check_support && build_step; then
  install_builtin  # Logic repeated, hard to trace
fi
```

**Ref:** BCS1410
#fin
