# Bash Coding Standard

Comprehensive Bash coding standard for Bash 5.2+. Not a compatibility standard.

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not simpler."

Remove unused functions/variables from production scripts.

## Contents
1. [Script Structure & Layout](#script-structure--layout)
2. [Variable Declarations & Constants](#variable-declarations--constants)
3. [Variable Expansion & Parameter Substitution](#variable-expansion--parameter-substitution)
4. [Quoting & String Literals](#quoting--string-literals)
5. [Arrays](#arrays)
6. [Functions](#functions)
7. [Control Flow](#control-flow)
8. [Error Handling](#error-handling)
9. [Input/Output & Messaging](#inputoutput--messaging)
10. [Command-Line Arguments](#command-line-arguments)
11. [File Operations](#file-operations)
12. [Security Considerations](#security-considerations)
13. [Code Style & Best Practices](#code-style--best-practices)
14. [Advanced Patterns](#advanced-patterns)

**Ref:** BSC00


---


**Rule: BCS0100**

# Script Structure & Layout

**Scripts must follow mandatory 13-step layout for consistency and safe initialization.**

Steps: (1) Shebang `#!/usr/bin/env bash`, (2) ShellCheck directives if needed, (3) Brief description comment, (4) `set -euo pipefail`, (5) `shopt -s inherit_errexit shift_verbose extglob nullglob`, (6) Metadata (`VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` made `readonly`), (7) Global variables, (8) Colors if terminal output, (9) Utility functions (messaging, helpers), (10) Business logic functions, (11) `main()` for scripts >40 lines, (12) Script invocation `main "$@"`, (13) End marker `#fin`.

**Function organization: bottom-up.** Define messaging functions first (lowest level), then helpers, validators, business logic, with `main()` last (highest orchestration level). Each function safely calls functions defined above it.

**Dual-purpose scripts** (executable and sourceable): Check `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` early. When sourced, skip `set -e` to avoid modifying caller's shell.

**FHS compliance:** Install to `/usr/local/share/{org}/{project}/` (local) or `/usr/share/{org}/{project}/` (system). Support uninstalled mode (script directory) for development.

**File extensions:** Omit `.sh` for user-facing commands; use `.sh` for libraries and internal tools.

**Ref:** BCS01


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality installation script demonstrating all 13 mandatory BCS0101 steps in ~450 lines.**

**Key elements:**
- Shebang + shellcheck + description � `set -euo pipefail` + shopt
- Metadata: `VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME` (readonly after group)
- Globals: config vars (`PREFIX='/usr/local'`), runtime flags (`DRY_RUN=0`), arrays (`WARNINGS=()`)
- Terminal-aware colors: `if [[ -t 1 && -t 2 ]]` conditional assignment
- Standard messaging: `_msg()` + helpers (vecho, info, warn, error, die, yn)
- Business logic: validation � creation � installation � summary (bottom-up)
- Argument parsing: Short/long options (`-p|--prefix`), `noarg()` validation
- Progressive readonly: Variables locked after parsing
- `main()` orchestrates workflow
- Invocation: `main "$@"`
- End: `#fin`

**Patterns demonstrated:**
- **Dry-run:** `((DRY_RUN)) && { info '[DRY-RUN] Would...'; return 0; }`
- **Derived paths:** `update_derived_paths()` recomputes when `PREFIX` changes
- **Force mode:** Overwrite control with `((FORCE))` checks
- **Error accumulation:** `WARNINGS+=()` array for summary
- **Validation first:** `check_prerequisites` � `validate_config` before action
- **Conditional features:** `((INSTALL_SYSTEMD))` guards systemd operations

**Production features:** help text, version info, verbose/quiet modes, config generation, permission management, comprehensive summary report.

**Ref:** BCS01010101


---


**Rule: BCS010102**

### Common Layout Anti-Patterns

**Eight critical BCS0101 violations causing silent failures and runtime errors.**

1. **Missing `set -euo pipefail`** → Silent corruption. Place at line 4.

2. **Variables after use** → Unbound variable errors. Declare globals in Step 7 before functions.

3. **Business logic before utilities** → Calls undefined helpers. Order: messaging → helpers → business → main().

4. **No `main()` in large scripts** → Scattered execution, untestable. Required for scripts >40 lines.

5. **Missing `#fin`** → No completion proof. Always end with `#fin`.

6. **Readonly before parsing** → Cannot modify during argument parsing. Make readonly after values finalized.

7. **Scattered declarations** → Hard to track state. Group all globals in Step 7.

8. **Unprotected sourcing** → Modifies caller's shell. Use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `set -e`.

**Wrong:**
```bash
#!/usr/bin/env bash
VERSION='1.0.0'  # No set -e!
readonly -- PREFIX  # Too early
process_files()  # Calls undefined die()
main "$@"  # No wrapper
```

**Correct:**
```bash
#!/usr/bin/env bash
set -euo pipefail
VERSION='1.0.0'
declare -- PREFIX='/usr'
die() { error "$*"; exit 1; }
process_files() { die "error"; }
main() { process_files; readonly -- PREFIX; }
main "$@"
#fin
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Special scenarios where BCS0101's 13-step layout is modified for specific use cases.**

#### Small Scripts (<200 lines)
Skip `main()` and run directly. **Rationale:** Overhead unjustified for trivial scripts.

```bash
#!/usr/bin/env bash
set -euo pipefail
declare -i count=0
for file in "$@"; do
  [[ ! -f "$file" ]] || count+=1
done
echo "Found $count files"
#fin
```

#### Sourced Libraries
Skip `set -e`, `main()`, execution—no environment modification. Export functions only.

```bash
#!/usr/bin/env bash
is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
#fin
```

#### External Configuration
Source config after metadata, **then** make variables readonly.

```bash
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/myapp/config.sh"
[[ -r "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
readonly -- CONFIG_FILE
```

#### Platform Detection
Add platform-specific globals after standard globals using case statements.

#### Cleanup Traps
Set trap **after** cleanup function defined, **before** temp file creation.

```bash
cleanup() { rm -f "${TEMP_FILES[@]}"; }
trap 'cleanup' EXIT SIGINT SIGTERM
```

**Anti-patterns:**
- `→` Functions before `set -e` (unsafe)
- `→` Globals scattered arbitrarily
- `→` Deviation without documented reason

**Key principles when deviating:**
1. Safety first (`set -e` comes first unless library)
2. Dependencies before usage (bottom-up)
3. Deviate only when necessary

**Ref:** BCS010103


---


**Rule: BCS0101**

## General Layouts for Standard Script

**Mandatory 13-step structural layout for all Bash scripts.**

### The 13 Steps

1. **Shebang**: `#!/bin/bash` (or `#!/usr/bin/bash`, `#!/usr/bin/env bash`)
2. **ShellCheck directives** (if needed): `#shellcheck disable=SCxxxx` with comments
3. **Brief description**: One-line purpose comment
4. **Error handling**: `set -euo pipefail` (MANDATORY before commands)
5. **Shell options**: `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. **Metadata**: `declare -r VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME` (readonly together)
7. **Global variables**: Explicit types - `declare -i`, `declare --`, `declare -a`, `declare -A`
8. **Color definitions** (if terminal output): Conditional with readonly
9. **Utility functions**: `_msg()`, `vecho()`, `info()`, `warn()`, `error()`, `die()` - lowest level
10. **Business logic**: Core functions organized bottom-up
11. **main()**: Required >100 lines; includes argument parsing; readonly after parsing
12. **Invocation**: `main "$@"` (always quote)
13. **End marker**: `#fin` or `#end` (MANDATORY)

**Rationale**: Guarantees safe initialization, prevents undefined references, enables testing.

**Anti-pattern**: Missing `set -euo pipefail`, variables before declaration, logic before utilities, no `main()` in large scripts.

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts (Executable and Sourceable)

**Dual-purpose scripts work as executables AND source libraries. Apply `set -euo pipefail` and `shopt` ONLY when executed, NOT when sourced (prevents modifying caller's shell state).**

**Pattern (early return - recommended):**
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

my_function "$@"
#fin
```

**Key rules:**
- Functions before sourced/executed check
- Early return: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`
- `set`/`shopt` after early return (executable section only)
- Metadata guard: `[[ ! -v SCRIPT_VERSION ]]` for idempotence
- Use `return` (not `exit`) for errors when sourced
- Test both: `./script.sh` (execute), `source script.sh` (source)

**Alternative (if/else):**
```bash
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  set -euo pipefail  # Executed mode
  process_data
else
  return 0  # Sourced mode
fi
```

**Rationale:** Sourcing must not alter caller's error handling or glob behavior.

**Anti-pattern:** Applying `set -e` at script top (breaks sourced mode).

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**All scripts must start with shebang, optional shellcheck directives, brief description, then `set -euo pipefail` as first command.**

**Allowable shebangs:**
- `#!/bin/bash` → Most portable (standard Linux)
- `#!/usr/bin/bash` → FreeBSD/BSD systems
- `#!/usr/bin/env bash` → Maximum portability (searches PATH)

**Rationale:** Strict error handling must activate before any commands execute.

**Example:**
```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Anti-pattern:** `set -euo pipefail` after variable declarations → errors undetected during initialization.

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt` using `declare -r` for immutability.**

**Rationale:** Reliable path resolution (realpath resolves symlinks/fails early), VERSION for tracking, SCRIPT_DIR for resource location, SCRIPT_NAME for logging, readonly prevents modification.

**Pattern:**

```bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:**
- **VERSION**: Semantic version (Major.Minor.Patch)
- **SCRIPT_PATH**: Absolute path via `realpath -- "$0"` (fails if missing)
- **SCRIPT_DIR**: Directory via `${SCRIPT_PATH%/*}` (parameter expansion)
- **SCRIPT_NAME**: Filename via `${SCRIPT_PATH##*/}`

**Use realpath not readlink:** Simpler, builtin available, POSIX-compliant, fails early.

**SC2155 acceptable:** realpath failure should terminate; concise pattern preferred.

**Anti-patterns:**
- `$0` directly without realpath → relative/symlink issues
- `dirname`/`basename` → slower external commands
- `$PWD` for SCRIPT_DIR → wrong (current directory not script location)
- `readonly` individually → `readonly SCRIPT_DIR=${SCRIPT_PATH%/*}` fails
- Late declaration → must follow shopt immediately

**Ref:** BCS0103


---


**Rule: BCS0104**

## Filesystem Hierarchy Standard (FHS) Preference

**Scripts installing files or searching resources should follow FHS for predictable locations, multi-environment support, and package manager compatibility.**

**Rationale:** Predictable paths users/package managers expect; works across dev/local/system/user installs; eliminates hardcoded paths.

**Locations:**
- `/usr/local/{bin,share}` - User-installed system-wide
- `/usr/{bin,share}` - System (package manager)
- `$HOME/.local/{bin,share}` - User-specific
- `${XDG_CONFIG_HOME:-$HOME/.config}` - User config

**Search pattern:**
```bash
find_data() {
  local -a paths=(
    "$SCRIPT_DIR/$1"                                      # Dev
    /usr/local/share/myapp/"$1"                           # Local
    /usr/share/myapp/"$1"                                 # System
    "${XDG_DATA_HOME:-$HOME/.local/share}/myapp/$1"       # User
  )
  local -- p
  for p in "${paths[@]}"; do
    [[ -f "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}
```

**PREFIX customization:**
```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/myapp"
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Anti-patterns:** Hardcoded paths → FHS search; Fixed install location → `PREFIX="$PREFIX/bin"`; Relative `source ../lib/` → Breaks from different CWD; Overwrite config → Check first `[[ -f "$cfg" ]] || install`

**Skip when:** Single-user scripts, project-specific tools, containers, embedded systems.

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt

**Apply these `shopt` settings immediately after `set -euo pipefail` in every script.**

**Critical settings:**
```bash
shopt -s inherit_errexit  # Makes set -e work in $(...) and (...)
shopt -s shift_verbose    # Errors when shift has no args
shopt -s extglob          # Enables !(pattern), +(pattern), *(pattern)
```

**Choose one glob behavior:**
```bash
shopt -s nullglob   # Unmatched globs � empty (safe for loops/arrays)
# OR
shopt -s failglob   # Unmatched globs � error (strict mode)
```

**Optional:**
```bash
shopt -s globstar   # Enables ** recursive matching (slow on deep trees)
```

**Rationale:**
- `inherit_errexit`: Without this, `result=$(false)` does NOT exit script despite `set -e` � errors in command substitutions silently ignored
- `shift_verbose`: Prevents silent failures when `shift` called with no args
- `extglob`: Enables `rm !(*.txt)`, `[[ $x == +([0-9]) ]]`, `*.@(jpg|png)`
- `nullglob`: `for f in *.txt` � loop skips if no matches (default behavior: `f="*.txt"` literal string causes bugs)
- `failglob`: Strict alternative where unmatched glob exits script

**Anti-patterns:**
- Omitting `inherit_errexit` � `set -e` ineffective in subshells
- No glob option � `for f in *.txt` executes with literal `"*.txt"` when no matches

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` required; global PATH tools: no extension.**

**Rationale:** No-extension executables appear as commands (`deploy` not `deploy.sh`). Libraries need `.sh` for identification and must be non-executable to prevent accidental execution.

**Example:**
```bash
# Executable (global)
/usr/local/bin/backup          # No extension

# Executable (local)
./scripts/build.sh             # .sh extension

# Library (non-executable)
lib-common.sh                  # .sh extension, chmod 644
```

**Anti-patterns:** `chmod +x lib-*.sh` ' libraries must not be executable | `/usr/bin/tool.sh` ' omit extension for PATH executables.

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize bottom-up: primitives first, `main()` last. Each layer calls only functions defined above.**

**Rationale:** No forward references; primitives understood before compositions; clear dependency flow.

**7-layer pattern:**

```bash
# 1. Messaging (lowest)
_msg() { echo "[$FUNCNAME[1]] $*"; }
info() { >&2 _msg "$@"; }
die() { error "$@"; exit "${1:-1}"; }

# 2. Documentation
show_help() { ... }

# 3. Helpers
noarg() { (($# < 2)) && die "Option $1 needs arg"; }

# 4. Validation
check_prerequisites() { ... }

# 5. Business logic
build_project() { ... }

# 6. Orchestration
run_build() { build_project; test_project; }

# 7. Main (highest)
main() {
  check_prerequisites
  run_build
}
main "$@"
```

**Layer definitions:**
1. Messaging - `_msg()`, `info()`, `warn()`, `error()`, `die()`
2. Documentation - `show_help()`, `show_version()`
3. Helpers - `yn()`, `noarg()`, utilities
4. Validation - `check_*()`, `validate_*()`
5. Business logic - domain operations
6. Orchestration - coordinate business logic
7. `main()` - top orchestrator

**Anti-patterns:**
```bash
# ✗ main() at top → forward references
main() { build(); }  # Not defined!

# ✗ Circular deps (A→B, B→A)
# ✓ Extract common logic to lower layer

# ✗ Random ordering
# ✓ Dependency-ordered
```

**Within-layer:** Order by severity (messaging) or logical sequence.

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) for clarity and safety.** Apply proper scoping (global vs local), naming conventions (UPPER_CASE for constants/environment, lower_case for variables), readonly patterns (individual or group), boolean flags as integers, and derived variables computed from other variables.

**Rationale:** Type hints prevent errors, explicit declarations make intent clear, proper scoping avoids conflicts.

**Example:**
```bash
declare -i count=0                    # Integer
declare -- name="example"             # String
declare -a files=()                   # Indexed array
declare -A config=([key]="value")     # Associative array
readonly VERSION='1.0.0' AUTHOR='name'
```

**Anti-patterns:** Untyped variables `count=0`, missing `readonly` for constants, using strings for booleans.

**Ref:** BCS02


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:** Type declarations prevent bugs through automatic type checking, serve as inline documentation, and enable bash's built-in type enforcement.

**Declaration types:**

**1. Integers (`declare -i`)** - Counters, exit codes, ports:
```bash
declare -i count=0
count='5 + 3'  # Evaluates to 8
```

**2. Strings (`declare --`)** - Paths, text (use `--` to prevent option injection):
```bash
declare -- filename='data.txt'
```

**3. Indexed arrays (`declare -a`)** - Ordered lists:
```bash
declare -a files=('one' 'two')
for f in "${files[@]}"; do process "$f"; done
```

**4. Associative arrays (`declare -A`)** - Key-value maps:
```bash
declare -A config=([key]='value')
```

**5. Constants (`readonly --`)** - Immutable after init:
```bash
readonly -- VERSION='1.0.0'
```

**6. Function locals (`local`)** - Always use for ALL function variables:
```bash
func() {
  local -i count=0
  local -- text="$1"
}
```

**Anti-patterns:**
```bash
# ✗ Wrong - no declaration
count=0
# ✓ Correct
declare -i count=0

# ✗ Wrong - missing -A
declare CONFIG; CONFIG[key]='val'  # Creates indexed array!
# ✓ Correct
declare -A CONFIG=(); CONFIG[key]='val'

# ✗ Wrong - global leak
func() { temp="$1"; }
# ✓ Correct
func() { local -- temp="$1"; }
```

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function-specific variables as `local` to prevent namespace pollution.**

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path dir          # Local strings
  dir=$(dirname -- "$name")
}
```

**Rationale:** Without `local`, variables become global and: (1) overwrite globals with same name, (2) persist after return causing unexpected behavior, (3) break recursive functions.

**Anti-patterns:**
- `file="$1"` � Overwrites global `$file` | Use: `local -- file="$1"`
- `total=0` in recursive function � Each call resets it | Use: `local -i total=0`

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use consistent naming to prevent conflicts and clarify scope.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Globals | UPPER_CASE | `VERBOSE=1` |
| Locals | lower_case | `local file_count=0` |
| Private functions | prefix _ | `_validate_input()` |
| Environment | UPPER_CASE | `export DATABASE_URL` |

**Example:**
```bash
# Constants/globals
readonly -- SCRIPT_VERSION='1.0.0'
declare -i VERBOSE=1

# Locals in functions
process_data() {
  local -i line_count=0
  local -- temp_file
}

# Private functions
_internal_helper() {
  # Internal use only
}
```

**Rationale:**
- UPPER_CASE for globals/constants: visible scope, shell conventions
- lower_case for locals: prevents shadowing globals
- Underscore prefix: signals internal use, prevents conflicts

**Anti-patterns:**
- Lowercase single letters (`a`, `b`, `n`) � shell reserved
- Shell variable names (`PATH`, `HOME`, `USER`) � causes conflicts

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly` for immutable values; `declare -x`/`export` for child process variables.**

```bash
# Constants (readonly)
readonly -- VERSION='1.0.0' MAX_RETRIES=3 CONFIG_DIR='/etc/myapp'

# Environment variables (export)
declare -x DATABASE_URL='postgresql://localhost/db' LOG_LEVEL='DEBUG'

# Combined (readonly + export)
declare -rx BUILD_ENV='production'
```

**When to use:**
- `readonly`: Script metadata, config paths, calculated constants (prevents modification)
- `declare -x`/`export`: Values needed by subprocesses, tool config, inherited settings

**Key difference:** readonly prevents changes; export passes to subprocesses.

**Anti-patterns:**
```bash
# ✗ Exporting unnecessary constants
export MAX_RETRIES=3  # Child processes don't need this
# ✓ Only readonly
readonly -- MAX_RETRIES=3

# ✗ Not protecting true constants
CONFIG_FILE='/etc/app.conf'  # Could be modified
# ✓ Make readonly
readonly -- CONFIG_FILE='/etc/app.conf'

# ✗ Making user-configurable readonly too early
readonly -- OUTPUT_DIR="$HOME/output"  # Can't override!
# ✓ Allow override first
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/output}"
readonly -- OUTPUT_DIR
```

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables first, then make readonly in single statement.**

**Rationale:** Prevents assignment errors; visual grouping; clear immutability contract.

**Three-step progressive workflow:**

```bash
# Step 1 - Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- PREFIX='/usr/local'

# Step 2 - Parse/modify in main()
main() {
  while (($#)); do case $1 in
    -v) VERBOSE=1 ;;
    --prefix) shift; PREFIX="$1" ;;
  esac; shift; done

  # Step 3 - Readonly after parsing
  readonly -- VERBOSE DRY_RUN PREFIX
}
```

Variables mutable during parsing → readonly after.

**Exception:** Script metadata prefers `declare -r` (see BCS0103). Readonly-after-group valid but `declare -r` now recommended.

**Standard groups:**

```bash
# Metadata (exception: uses declare -r)
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")

# Colors (conditional)
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' NC=$'\033[0m'
else
  RED='' NC=''
fi
readonly -- RED NC

# Paths
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR
```

**Anti-patterns:**

```bash
# ✗ Wrong - readonly before all values set
PREFIX='/usr'
readonly -- PREFIX
BIN_DIR="$PREFIX/bin"  # Not protected

# ✓ Correct
PREFIX='/usr'
BIN_DIR="$PREFIX/bin"
readonly -- PREFIX BIN_DIR

# ✗ Wrong - missing --
readonly PREFIX  # Risky

# ✓ Correct
readonly -- PREFIX
```

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
readonly -- SCRIPT_PATH="$(realpath -- "$0")"
```

**Ref:** BCS0206


---


**Rule: BCS0207**

## Boolean Flags Pattern

**Use `declare -i` for boolean state flags, test with `(())`.**

```bash
declare -i DRY_RUN=0
declare -i VERBOSE=0

# Test in conditionals
((DRY_RUN)) && info 'Dry-run enabled'

if ((VERBOSE)); then
  debug "Details here"
fi

# Set from arguments
--dry-run) DRY_RUN=1 ;;
```

**Rules:**
- `declare -i FLAG=0` → explicit integer declaration
- ALL_CAPS naming (DRY_RUN, SKIP_BUILD)
- Initialize to `0` (false) or `1` (true)
- Test: `((FLAG))` → true if non-zero
- Toggle: `((FLAG)) && FLAG=0 || FLAG=1`

**Anti-patterns:**
- `if [[ $FLAG -eq 1 ]]` → use `((FLAG))`
- `declare FLAG=false` → strings not testable with `(())`

**Ref:** BCS0207


---


**Rule: BCS0209**

## Derived Variables

**Derive variables from base values rather than duplicating. Group with section comments. Update all derived variables when base values change (especially during argument parsing).**

**Rationale:**
- DRY principle - single source of truth, automatic updates when base changes
- Prevents inconsistency bugs when base values change but derived don't update
- Section comments make dependencies explicit for maintainability

**Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Base values
declare -- PREFIX='/usr/local'
declare -- APP_NAME='myapp'

# Derived paths
declare -- BIN_DIR="$PREFIX/bin"
declare -- LIB_DIR="$PREFIX/lib"
declare -- CONFIG_DIR="/etc/$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR/config.conf"

# Update function for argument parsing
update_derived_paths() {
  BIN_DIR="$PREFIX/bin"
  LIB_DIR="$PREFIX/lib"
  CONFIG_DIR="/etc/$APP_NAME"
  CONFIG_FILE="$CONFIG_DIR/config.conf"
}

main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX="$1"; update_derived_paths ;;
      *) break ;;
    esac
    shift
  done
  readonly -- PREFIX BIN_DIR LIB_DIR CONFIG_DIR CONFIG_FILE
}
main "$@"
#fin
```

**Anti-patterns:**
- `BIN_DIR='/usr/local/bin'` � Duplicates `PREFIX`, won't update if `PREFIX` changes
- Changing `PREFIX` without updating `BIN_DIR="$PREFIX/bin"` � Inconsistent state
- Making derived variables `readonly` before base values finalized � Can't update

**Ref:** BCS0209


---


**Rule: BCS0300**

# Variable Expansion & Parameter Substitution

**Default to `"$var"` without braces; use `"${var}"` only when syntactically required.**

**When braces required:**
- Parameter expansion: `"${var##pattern}"`, `"${var:-default}"`, `"${var/pattern/replacement}"`
- Array expansion: `"${array[@]}"`, `"${array[*]}"`
- Concatenation: `"${var1}${var2}"`, `"${var}_suffix"`
- Disambiguation: `"${var}text"` (prevents parsing ambiguity)

**When braces NOT required:**
- Simple expansion: `"$var"` not `"${var}"`
- Command substitution: `"$(command)"` not `"${$(command)}"`
- Arithmetic: `"$((expr))"` not `"${$((expr))}"`
- In conditionals: `[[ -f "$file" ]]` not `[[ -f "${file}" ]]`

**Rationale:** Reduces visual noise, matches standard shell idioms, reserves braces for operations that genuinely require them.

**Example:**
```bash
# ✓ Correct - braces only where needed
name='deploy'
version='1.0.0'
file="${name}-${version}.tar.gz"    # Concatenation
default_path="${HOME:-/tmp}/bin"    # Parameter expansion
echo "Installing $file to $default_path"  # Simple expansion

# ✗ Wrong - unnecessary braces
echo "Installing ${file} to ${default_path}"
```

**Anti-patterns:**
- `"${var}"` when `"$var"` works → Unnecessary complexity
- `"$var1$var2"` without braces → Fails to concatenate properly (use `"${var1}${var2}"`)

**Ref:** BCS0300


---


**Rule: BCS0301**

## Parameter Expansion

**Use parameter expansion for string manipulation and defaults instead of external commands.**

**Rationale:** Native bash operations are 10-100x faster than subshells/external commands; reduces process creation overhead; enables atomic variable manipulation.

**Core patterns:**
```bash
# Pattern removal (paths)
SCRIPT_NAME=${SCRIPT_PATH##*/}   # Remove longest prefix (dirname)
SCRIPT_DIR=${SCRIPT_PATH%/*}     # Remove shortest suffix (basename)

# Defaults and substrings
${var:-default}                  # Use default if unset/null
${var:offset:length}             # Extract substring
${#var}                          # String length
${#array[@]}                     # Array length

# Case conversion (Bash 4.0+)
${var,,}                         # Lowercase
${var^^}                         # Uppercase

# Positional parameters
"${@:2}"                         # All args from 2nd onward
```

**Anti-patterns:**
- `$(basename "$file")` � Use `${file##*/}`
- `$(dirname "$file")` � Use `${file%/*}`
- `"${var:=$default}"` in readonly context � Use `${var:-$default}`

**Ref:** BCS0301


---


**Rule: BCS0302**

## Variable Expansion Guidelines

**Always use `"$var"` as default. Only use braces `"${var}"` when syntactically required.**

**Rationale:** Braces add visual noise without value. Using them only when necessary makes code cleaner and highlights actual requirements.

#### Braces Required

1. **Parameter expansion:** `"${var##*/}"`, `"${var%/*}"`, `"${var:-default}"`, `"${var:0:5}"`, `"${var//old/new}"`, `"${var,,}"`
2. **Concatenation (no separator):** `"${var1}${var2}"`, `"${prefix}suffix"`
3. **Arrays:** `"${array[i]}"`, `"${array[@]}"`, `"${#array[@]}"`
4. **Special parameters:** `"${@:2}"`, `"${10}"`, `"${!var}"`

#### Braces Not Required

```bash
# ✓ Correct - simple form
"$var"
"$HOME/path"
"$PREFIX"/bin
[[ -f "$SCRIPT_DIR"/file ]]
echo "Found $count files in $dir"

# ✗ Wrong - unnecessary braces
"${var}"
"${HOME}/path"
"${PREFIX}"/bin
```

**Path patterns:** `"$var"/literal/"$var"` → Quotes protect variables, separators (`/`, `-`, `.`) delimit naturally.

**Edge case - alphanumeric follows with no separator:**
```bash
"${var}_suffix"    # ✓ Required - prevents $var_suffix
"$var-suffix"      # ✓ No braces - dash separates
```

**Key Principle:** Default to `"$var"`. Add braces only when shell requires them for correct parsing.

**Ref:** BCS0302


---


**Rule: BCS0400**

# Quoting & String Literals

**Use single quotes for static text, double quotes when shell processing (variables/substitution/escapes) needed.**

**Rationale:**
- Prevents word-splitting/globbing errors in variables
- Semantic signal: `'literal'` vs `"$processed"`

**Core Patterns:**

```bash
# Static strings → single quotes
info 'Processing complete'

# Variables/substitution → double quotes
info "Found $count files in $dir"
echo "Result: $(command)"

# Conditionals → always quote variables
[[ -f "$file" ]] && [[ "$status" == 'active' ]]

# Arrays → quote expansion
for item in "${array[@]}"; do
  process "$item"
done
```

**Critical Anti-Patterns:**

```bash
# ✗ Wrong - double quotes for static text
echo "Processing files..."

# ✗ Wrong - unquoted variable in test
[[ -f $file ]]

# ✗ Wrong - unquoted array expansion
for item in ${array[@]}; do

# ✓ Correct
echo 'Processing files...'
[[ -f "$file" ]]
for item in "${array[@]}"; do
```

**Ref:** BCS0400


---


**Rule: BCS0401**

## Static Strings and Constants

**Always use single quotes for string literals with no variables.**

**Rationale:**
1. **Performance**: Faster (no parsing)
2. **Clarity**: Signals literal string
3. **Safety**: Prevents accidental expansion of `$`, `` ` ``, `\`, `!`

**Core pattern:**

```bash
# Single quotes - static strings
info 'Checking prerequisites...'
DEFAULT_PATH='/usr/local/bin'
[[ "$status" == 'success' ]]

# Double quotes - variables needed
info "Found $count files"
msg="Current time: $(date)"
```

**Anti-patterns:**

```bash
#  Double quotes for static
info "Checking prerequisites..."  # � Use single quotes
msg="The cost is \$5.00"          # � msg='The cost is $5.00'

#  Variables in single quotes
greeting='Hello, $name'  # Not expanded � greeting="Hello, $name"
```

**Rule:** Single quotes `'...'` for all static strings. Double quotes `"..."` only when variables or command substitution needed.

**Ref:** BCS0401


---


**Rule: BCS0402**

## Exception: One-Word Literals

**One-word literals (alphanumeric, `_`, `-`, `.`, `/` only) may be left unquoted in assignments/conditionals, but quoting is safer and recommended.**

**Rationale:** Acknowledges common practice while encouraging defensive programming - unquoted values risk bugs if changed.

**Qualifies:** No spaces/special chars (`*?[]{}$`"'\;&|<>()!#`), shouldn't start with `-`.

**Examples:**
```bash
#  Acceptable (but quoting better)
LEVEL=INFO
PATH=/usr/local
[[ "$status" == success ]]

#  Better - always quote
LEVEL='INFO'
PATH='/usr/local'
[[ "$status" == 'success' ]]
```

**Mandatory quoting:**
```bash
#  Must quote
MESSAGE='Hello world'    # spaces
PATTERN='*.txt'          # wildcards
EMAIL='user@domain.com'  # special chars
VALUE=''                 # empty
```

**Anti-pattern:**
```bash
#  Wrong - unquoted special/multi-word
EMAIL=admin@example.com  # @ is special
MESSAGE=File not found   # syntax error
```

**Best practice:** Quote everything except trivial cases. When in doubt, quote. Consistency eliminates mental overhead and prevents bugs.

**Ref:** BCS0402


---


**Rule: BCS0403**

## Strings with Variables

**Use double quotes when strings contain variables needing expansion.**

```bash
die 1 "Unknown option '$1'"
info "Installing to $PREFIX/bin"
echo "$SCRIPT_NAME $VERSION"
```

**Ref:** BCS0403


---


**Rule: BCS0404**

## Mixed Quoting

**Nest single quotes inside double quotes to show literals around variables.**

```bash
die 2 "Unknown option '$1'"
warn "Cannot access '$file_path'"
info "Would remove: '$old' � '$new'"
```

**Ref:** BCS0404


---


**Rule: BCS0405**

## Command Substitution in Strings

**Always use double quotes when including command substitution** - enables variable expansion and preserves output as single argument.

```bash
# Command substitution in messages
echo "Current time: $(date +%T)"
info "Found $(wc -l "$file") lines"

# Assignment with command substitution
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
```

**Ref:** BCS0405


---


**Rule: BCS0406**

## Variables in Conditionals

**Always quote variables in test expressions; static comparison values use single quotes for literals or remain unquoted for one-word values.**

**Rationale:**
- Prevents word splitting/glob expansion on multi-word values or wildcards
- Empty variables cause syntax errors when unquoted
- Security: prevents injection via input manipulation

**Core patterns:**

```bash
# File tests - quote variable
[[ -f "$file" ]]           # ✓ Correct
[[ -f $file ]]             # ✗ Fails with spaces

# String comparison - quote variable, single-quote literal
[[ "$mode" == 'production' ]]  # ✓ Correct
[[ "$mode" == production ]]    # ✓ Also valid (one-word)
[[ "$mode" == "production" ]]  # ✗ Unnecessary double quotes

# Integer comparison - quote variable
[[ "$count" -eq 0 ]]       # ✓ Correct

# Pattern matching - quote variable, unquote pattern
[[ "$file" == *.txt ]]     # ✓ Glob matching
[[ "$file" == '*.txt' ]]   # ✓ Literal match

# Regex - quote variable, unquote pattern
pattern='^[0-9]+$'
[[ "$input" =~ $pattern ]] # ✓ Correct
[[ "$input" =~ "$pattern" ]] # ✗ Treats as literal
```

**Anti-patterns:**
- `[[ -f $file ]]` → Fails if `$file` contains spaces or wildcards
- `[[ -z $empty ]]` → Syntax error if `$empty` is unset/empty
- `[[ "$mode" == "production" ]]` → Use single quotes for static strings

**Ref:** BCS0406


---


**Rule: BCS0407**

## Array Expansions

**Always quote array expansions: `"${array[@]}"` for separate elements, `"${array[*]}"` for concatenated string.**

**Rationale:** Unquoted arrays undergo word splitting and glob expansion, breaking elements on whitespace/patterns. Quoted `[@]` preserves boundaries, empty elements, and special characters. Unquoted loses empty elements, splits on IFS, expands globs.

**Use `[@]` (separate):** Iteration, function/command args, array copying.
**Use `[*]` (single string):** Display, logging, CSV with custom IFS.

```bash
declare -a files=('file 1.txt' 'file 2.txt')

#  Iteration (3 elements preserved)
for file in "${files[@]}"; do
  echo "$file"
done

#  Unquoted splits on space (4 elements!)
for file in ${files[@]}; do echo "$file"; done
# Output: file, 1.txt, file, 2.txt

#  Concatenate with custom separator
IFS=','; csv="${files[*]}"  # file 1.txt,file 2.txt

#  Pass to function/command
process "${files[@]}"
grep pattern "${files[@]}"

#  Copy array
copy=("${files[@]}")
```

**Anti-patterns:**
- `${array[@]}` � word splitting/glob expansion
- `"${array[*]}"` in loops � single iteration
- Unquoted in assignments/function calls � lost boundaries

**Edge cases:** Empty arrays iterate zero times. Empty elements preserved only when quoted. Newlines/spaces in elements require quotes.

**Ref:** BCS0407


---


**Rule: BCS0408**

## Here Documents

**Quote delimiter with single quotes to prevent expansion; leave unquoted (or double-quoted) to enable expansion.**

```bash
# Literal (no expansion)
cat <<'EOF'
$VAR not expanded
EOF

# With expansion
cat <<EOF
Script: $SCRIPT_NAME
EOF
```

**Anti-pattern:** Using double quotes thinking it differs from unquoted � both enable expansion.

**Ref:** BCS0408


---


**Rule: BCS0409**

## Echo and Printf Statements

**Use single quotes for static strings, double quotes when variables/commands needed.**

```bash
# Static - single quotes
echo 'Installation complete'

# Variables - double quotes
echo "Installing to $PREFIX/bin"
printf 'Found %d files in %s\n' "$count" "$dir"
```

**Anti-pattern:** `echo "static string"` � wastes quoting, use `echo 'static string'`

**Ref:** BCS0409


---


**Rule: BCS0410**

## Summary Reference

**Quick reference table for quote style selection based on content type.**

| Content Type | Quote Style | Example |
|--------------|-------------|---------|
| Static string | Single `'...'` | `info 'Starting process'` |
| One-word literal (assignment) | Optional | `VAR=value` or `VAR='value'` |
| One-word literal (conditional) | Optional | `[[ $x == value ]]` |
| String with variable | Double `"..."` | `info "Processing $file"` |
| Variable in string | Double `"..."` | `echo "Count: $count"` |
| Literal quotes in string | Double + nested single | `die 1 "Unknown '$1'"` |
| Command substitution | Double `"..."` | `echo "Time: $(date)"` |
| Variables in conditionals | Double `"$var"` | `[[ -f "$file" ]]` |
| Static in conditionals | Single or unquoted | `[[ "$x" == 'value' ]]` |
| Array expansion | Double `"${arr[@]}"` | `for i in "${arr[@]}"` |
| Here doc (no expansion) | Single on delimiter | `cat <<'EOF'` |
| Here doc (with expansion) | No quotes on delimiter | `cat <<EOF` |

**Ref:** BCS0410


---


**Rule: BCS0411**

## Anti-Patterns (What NOT to Do)

**Avoid quoting mistakes causing security flaws, word splitting bugs, and poor maintainability.**

**Critical rationale:**
- **Security:** Improper quoting enables injection attacks
- **Reliability:** Unquoted variables cause word splitting/glob expansion

**Top anti-patterns:**

1. **Double quotes for static** �' `info 'text'` not `info "text"`
2. **Unquoted variables** �' `[[ -f "$file" ]]` not `[[ -f $file ]]`
3. **Unnecessary braces** �' `"$HOME/bin"` not `"${HOME}/bin"`
4. **Unquoted arrays** �' `"${items[@]}"` not `${items[@]}`

**Example:**

```bash
# ✗ Wrong
info "Starting..."          # Use single quotes
[[ -f $file ]]              # Quote variable
path="${HOME}/bin"          # Braces not needed
for x in ${arr[@]}; do      # Quote array

# ✓ Correct
info 'Starting...'
[[ -f "$file" ]]
path="$HOME/bin"
for x in "${arr[@]}"; do
```

**Quick check:**

```bash
'static'                 ✓
"static"                 ✗
"text $var"              ✓  # No braces
"text ${var}"            ✗  # Unnecessary
[[ -f "$file" ]]         ✓
[[ -f $file ]]           ✗  # Dangerous
"${array[@]}"            ✓  # Needs braces+quotes
${array[@]}              ✗
```

**Key:** Quote variables always, single quotes for static text, avoid unnecessary braces.

**Ref:** BCS0411


---


**Rule: BCS0412**

## String Trimming

**Use parameter expansion for whitespace trimming - faster than external commands.**

```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

**Ref:** BCS0412


---


**Rule: BCS0413**

## Display Declared Variables

**Use `decp()` helper to inspect variable declarations without type flags.**

```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```

Shows variable values cleanly: `decp VERSION` � `VERSION='1.0.0'` (strips `declare -r`).

**Ref:** BCS0413


---


**Rule: BCS0414**

## Pluralisation Helper

**Use `s()` helper for conditional plurals in messages.**

**Rationale:** Prevents grammatically incorrect messages like "1 files processed" or verbose conditionals throughout code.

**Implementation:**
```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

**Usage:**
```bash
echo "$count file$(s "$count") processed"
# Outputs: "1 file processed" or "5 files processed"
```

**Anti-patterns:** `�` Writing conditional logic inline: `[[ $n -eq 1 ]] && echo "file" || echo "files"`

**Ref:** BCS0414


---


**Rule: BCS0415**

## Parameter Quoting with `${parameter@Q}`

**Use `${parameter@Q}` to safely quote parameter values in error messages, logging, and debug output.**

**Rationale:** Prevents injection attacks by displaying user input literally without expansion; shows exact values including whitespace and metacharacters.

**Primary use cases:**

1. **Error messages** - Safe display of user input:
```bash
die 2 "Unknown option ${1@Q}"
# Input: --opt='$(rm -rf /)'  � Output: Unknown option '$(rm -rf /)'
```

2. **Argument validation:**
```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

3. **Debug/logging** - Show exact values:
```bash
debug "Processing ${filename@Q}"
printf -v cmd '%s ' "${cmd_array[@]@Q}"  # Dry-run display
```

**Comparison:**

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `hello world` | `hello world` | `'hello world'` |
| `$(date)` | *executes* | `'$(date)'` (literal) |
| `$HOME` | */home/user* | `'$HOME'` (literal) |

**Use for:** Error messages, logging user input, debug output, dry-run displays

**Don't use for:** Normal logic (`process "$file"`), data output, assignments, comparisons

**Anti-pattern:**
```bash
#  Wrong - injection risk
die 2 "Unknown option $1"
#  Correct
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0415


---


**Rule: BCS0500**

# Arrays

**Proper array declaration and safe iteration patterns for indexed (`declare -a`) and associative (`declare -A`) arrays, preventing word-splitting issues with `"${array[@]}"` and enabling safe handling of filenames with spaces/special characters.**

**Ref:** BCS0500


---


**Rule: BCS0501**

## Array Declaration and Usage

**Always declare arrays explicitly with `declare -a` (or `local -a` in functions) for clarity and type safety.**

**Rationale:** Signals array type to readers, prevents scalar assignment, enables scope control with `local -a`.

**Core patterns:**
```bash
declare -a files=()              # Empty array
files+=("$item")                 # Append element
readarray -t lines < <(command)  # Read output (use -t, process subst)

# Iteration - always quote "${array[@]}"
for item in "${array[@]}"; do
  process "$item"
done

${#array[@]}                     # Length
```

**Anti-patterns:**
- `${array[@]}` � unquoted breaks with spaces
- `for x in "$array"` � only first element
- `array=($string)` � dangerous word splitting/glob expansion
- `"${array[*]}"` � all elements as one string

**Ref:** BCS0501


---


**Rule: BCS0502**

## Arrays for Safe List Handling

**Use arrays to store lists of elements safelyarrays preserve element boundaries regardless of content (spaces, special chars, wildcards).**

**Rationale:**
- Arrays eliminate word splitting/glob expansion bugs inherent in string-based lists
- Safe command construction with arbitrary arguments containing spaces/special chars
- Each element processed exactly once during iteration

**Anti-pattern:** String lists fail with spaces:
```bash
#  files_str="file1.txt file with spaces.txt"
# for file in $files_str; do ... done  # 4 iterations, not 2!
```

**Core pattern:**
```bash
#  Array declaration and safe usage
declare -a files=(
  'file1.txt'
  'file with spaces.txt'
)

# Safe iteration
for file in "${files[@]}"; do
  process "$file"
done

# Safe command construction
declare -a cmd=('myapp' '--output' "$file")
((verbose)) && cmd+=('--verbose')
"${cmd[@]}"  # Executes with proper boundaries
```

**Key anti-patterns:**
- `files_str="a b c"; cmd $files_str` � Use `declare -a files=('a' 'b' 'c'); cmd "${files[@]}"`
- `cmd_args="-o file"; mycmd $cmd_args` � Use `declare -a args=('-o' 'file'); mycmd "${args[@]}"`
- `$(ls *.txt)` � Use `declare -a files=(*.txt)`
- `${array[@]}` unquoted � Always `"${array[@]}"`

**Summary:** Arrays are mandatory for all lists (files, arguments, options). String-based lists inevitably fail with edge cases. Always expand with `"${array[@]}"` (quoted).

**Ref:** BCS0502


---


**Rule: BCS0600**

# Functions

**Use lowercase_with_underscores naming; require `main()` for scripts >200 lines; organize bottom-up (messaging�helpers�business logic�main).**

**Rationale:** Bottom-up organization ensures dependencies exist before use; `main()` enables testing/sourcing without execution; consistent naming improves readability.

**Pattern:**
```bash
#!/usr/bin/env bash
set -euo pipefail

_msg() { local lvl=$1; shift; >&2 echo "[$lvl] $*"; }
error() { _msg ERROR "$@"; }
die() { error "$@"; exit 1; }

process_file() {
  local file=$1
  [[ -f "$file" ]] || die "File not found: $file"
  # business logic
}

main() {
  process_file "$1"
}

main "$@"
#fin
```

**Export for libraries:** `declare -fx function_name` after definition.

**Production optimization:** Remove unused utility functions once scripts mature.

**Anti-patterns:** `function` keyword (omit it); top-down organization; missing `main()` in large scripts.

**Ref:** BCS0600


---


**Rule: BCS0601**

## Function Definition Pattern

**Use single-line format for simple operations; multi-line with `local` declarations for complex functions.**

**Syntax:**
```bash
# Single-line: no local vars, simple logic
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line: local vars, complex logic
main() {
  local -i exitcode=0
  local -- variable
  # body
  return "$exitcode"
}
```

**Rationale:** Single-line saves space for trivial functions; multi-line improves readability and enables proper variable scoping for complex logic.

**Anti-patterns:** `�` Mixing formats inconsistently; omitting `local` for function-scope variables.

**Ref:** BCS0601


---


**Rule: BCS0602**

## Function Names

**Use lowercase_with_underscores; prefix private functions with underscore.**

**Rationale:** Matches Unix/shell conventions, avoids conflicts with built-ins, clear visibility distinction.

**Example:**
```bash
#  Public function
process_log_file() {
  &
}

#  Private function
_validate_input() {
  &
}

#  Avoid
MyFunction() { & }      # CamelCase confusing
cd() { & }              # Overrides built-in
my-function() { & }     # Dashes problematic
```

**Anti-patterns:** Overriding built-ins without prefix/suffix (`cd()` � use `change_dir()`), CamelCase, special characters.

**Ref:** BCS0602


---


**Rule: BCS0603**

## Main Function

**Include `main()` for scripts >200 lines as single entry point; place `main "$@"` before `#fin`.**

**Rationale:** Enables testability (source without executing), organization, and scope control.

**Structure:**
```bash
main() {
  local -i verbose=0
  local -- output_dir=''
  local -a files=()

  # Parse args
  while (($#)); do case $1 in
    -v|--verbose) verbose=1 ;;
    -o|--output) shift; output_dir="$1" ;;
    -h|--help) usage; return 0 ;;
    -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done

  readonly -- verbose output_dir
  readonly -a files

  # Validation & logic
  [[ ${#files[@]} -eq 0 ]] && die 22 'No files'

  return 0
}

main "$@"
#fin
```

**Testable pattern:**
```bash
main() { : ; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
#fin
```

**Anti-pattern:**
```bash
# ✗ Args parsed outside main
while (($#)); do : ; done
main "$@"  # Args already consumed!

# ✓ Parse in main
main() {
  while (($#)); do : ; done
}
main "$@"
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Function Export

**Export functions with `declare -fx` when they must be available to subshells or child processes.**

```bash
# Export wrapper functions
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

**Rationale:** Functions are not inherited by subshells unless explicitly exported; `-fx` makes them available to child processes.

**Anti-pattern:** Defining functions without export when subshells need them � function not found errors.

**Ref:** BCS0604


---


**Rule: BCS0605**

## Production Script Optimization

**Remove unused utilities/variables once script is production-ready** - reduces size, improves clarity, eliminates maintenance burden.

### Core Principle
Strip functions/variables not called in your script. Simple script needing only `error()` and `die()` shouldn't carry full messaging suite (`vecho()`, `yn()`, `decp()`, `trim()`, `s()`, etc.).

### Example
```bash
# ✗ Development - carries unused functions
vecho() { ... }; yn() { ... }; decp() { ... }
error() { ... }; die() { ... }  # Only these used

# ✓ Production - stripped to essentials
error() { >&2 _msg ERROR "$@"; }
die() { error "$@"; exit "${2:-1}"; }
```

### Anti-Pattern
**Keeping dead code** → Bloated scripts, confusing maintenance, false dependencies.

**Ref:** BCS0605


---


**Rule: BCS0700**

# Control Flow

**Always use `[[ ]]` for test expressions (not `[ ]`), `(())` for arithmetic conditionals, and prefer process substitution `< <(command)` over pipes to while loops (avoids subshell variable persistence issues).**

**Rationale:** `[[ ]]` prevents word splitting/globbing, supports pattern matching (`==`/`!=`), and has cleaner syntax; `(())` enables natural arithmetic; process substitution keeps variables in parent scope.

**Critical arithmetic pattern:** Use `i+=1` or `((i+=1))` never `((i++))` - postfix returns original value, fails with `set -e` when i=0.

**Example:**
```bash
# Conditionals
[[ -f "$file" && -r "$file" ]] && process_file "$file"
(( count > 0 )) && info "Processing $count items"

# Safe loop avoiding subshell
declare -i total=0
while IFS= read -r line; do
  ((total+=1))
done < <(command)
```

**Anti-patterns:**
- `[ "$var" = "value" ]` � use `[[ $var == value ]]`
- `command | while read line; do count+=1; done` � variables lost (subshell)
- `((i++))` in loops � fails when i=0 with `set -e`

**Ref:** BCS0700


---


**Rule: BCS0701**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

```bash
# String/file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists'
[[ "$status" == 'success' ]] && continue

# Arithmetic - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Combined
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi
```

**Why `[[ ]]` over `[ ]`:** No word splitting/glob expansion, pattern matching (`==`, `=~`), logical operators (`&&`, `||`) work inside, more operators (`<`, `>` for strings).

**Pattern matching:**
```bash
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || die 22 'Invalid'
```

**Anti-patterns:** `[ ]` syntax � use `[[ ]]`; `-a`/`-o` operators � use `&&`/`||`; arithmetic with `-gt`/`-lt` � use `(())`

**Common operators:**
- File: `-e` (exists), `-f` (file), `-d` (dir), `-r` (readable), `-w` (writable), `-x` (executable), `-s` (not empty)
- String: `-z` (empty), `-n` (not empty), `==`/`!=` (equal/not), `<`/`>` (lexicographic), `=~` (regex)
- Arithmetic: `>`, `>=`, `<`, `<=`, `==`, `!=` (use in `(())`)

**Ref:** BCS0701


---


**Rule: BCS0702**

## Case Statements

**Use `case` for multi-way branching on single variable pattern matching; more readable than `if/elif` chains.**

**Rationale:** Pattern matching support, faster single evaluation, easier maintenance.

**Format options:**

**Compact** (single-line actions):
```bash
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    usage; exit 0 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT="$1" ;;
  --)           shift; break ;;
  -*)           die 22 "Invalid: $1" ;;
esac
```

**Expanded** (multi-line actions):
```bash
case $1 in
  -p|--prefix)  noarg "$@"
                shift
                PREFIX="$1"
                ;;
  *)            die 22 "Invalid: $1"
                ;;
esac
```

**Patterns:**
- Literal: `start)` (unquoted)
- Wildcards: `*.txt)` `*.md|*.rst)`
- Alternation: `-h|--help)`
- Extglob: `+([0-9]))` `@(start|stop)` `!(*.tmp)`
- Brackets: `[0-9])` `[a-z])` `[!a-zA-Z0-9])`

**Anti-patterns:**
```bash
# ✗ Unquoted test variable
case $file in

# ✗ Quoted literal patterns
case "$val" in "start")

# ✗ Missing default case
case "$act" in start) ;; stop) ;; esac

# ✗ Inconsistent alignment
-v) VERBOSE=1 ;;
-o) shift; OUT="$1" ;;
-h) usage; exit 0 ;;

# ✓ Correct
case "$file" in
  *.txt) process ;;
  *) die 22 "Unknown: $file" ;;
esac
```

**Use case for:** Single variable patterns, file routing, CLI args
**Use if/elif for:** Multiple variables, numeric ranges, complex conditions

**Ref:** BCS0702


---


**Rule: BCS0703**

## Loops

**Use `for` for collections/ranges, `while` for streams/conditions. Quote arrays `"${array[@]}"`, use `< <(cmd)` to avoid subshell, use `break`/`continue` for control.**

**Rationale:** For loops iterate arrays/globs safely. While with process substitution avoids subshell scope issues.

**For loops:**
```bash
for file in "${files[@]}"; do process "$file"; done  # Array
for file in *.txt; do process "$file"; done  # Glob
for ((i=0; i<10; i+=1)); do echo "$i"; done  # C-style (i+=1 not i++)
for i in {1..10}; do echo "$i"; done  # Brace
```

**While loops:**
```bash
while IFS= read -r line; do process "$line"; done < file.txt  # File
while IFS= read -r line; do ((count+=1)); done < <(cmd)  # Cmd
while (($#)); do case $1 in -v) V=1 ;; esac; shift; done  # Args
```

**Infinite:**
```bash
while ((1)); do process; done  # Fastest
while :; do process; done  # POSIX (+9-14%)
# Avoid: while true (+15-22%)
```

**Control:**
```bash
[[ "$f" =~ $pat ]] && break  # Early exit
[[ ! -r "$f" ]] && continue  # Skip
((i*j>50)) && break 2  # Nested break
```

**Anti-patterns:**
```bash
# ✗ cat file | while read line; do ((c+=1)); done  # Subshell
# ✓ while read -r line; do ((c+=1)); done < <(cat file)

# ✗ for item in ${array[@]}; do  # Unquoted
# ✓ for item in "${array[@]}"; do

# ✗ for f in $(ls *.txt); do  # Parse ls
# ✓ for f in *.txt; do
```

**Ref:** BCS0703


---


**Rule: BCS0704**

## Pipes to While Loops

**Never pipe to `while` loopspipes create subshells where variable changes are lost. Use `< <(command)` or `readarray` instead.**

**Rationale:** Pipes create subshells; variables modified inside don't persist outsidecounters stay 0, arrays stay empty, no errors shown.

**Pattern:**

```bash
#  Wrong - variables lost
count=0
echo -e "a\nb\nc" | while read -r x; do ((count+=1)); done
echo "$count"  # 0 (lost!)

#  Correct - process substitution
count=0
while read -r x; do ((count+=1)); done < <(echo -e "a\nb\nc")
echo "$count"  # 3

#  Correct - readarray for line collection
readarray -t lines < <(echo -e "a\nb\nc")
echo "${#lines[@]}"  # 3
```

**Examples:**

```bash
# Counter accumulation
while read -r line; do ((count+=1)); done < <(grep ERROR log)

# Array building
while read -r file; do files+=("$file"); done < <(find /data -type f)

# Readarray (simpler)
readarray -t users < <(cut -d: -f1 /etc/passwd)

# Null-delimited (safe for filenames)
readarray -d '' -t files < <(find /data -print0)
```

**Anti-pattern:**

```bash
#  All variable changes lost in subshell
cat file | while read -r line; do
  ((count+=1))
  array+=("$line")
done
# count=0, array=() - both lost!
```

**Ref:** BCS0704


---


**Rule: BCS0705**

## Arithmetic Operations

**Always declare integers with `declare -i` (BCS0201).** Use `i+=1` or `((i+=1))` for increments. Never `((i++))` - returns old value, fails with `set -e` when i=0.

**Rationale:**
- **Type safety**: `declare -i` enables automatic arithmetic, catches non-numeric errors
- **set -e safety**: `((i++))` returns 0 when i=0, causing exit
- **Performance**: Eliminates repeated `$(())` overhead

**Core patterns:**

```bash
declare -i count=0 max=10

# Safe increments
i+=1              # Preferred
((i+=1))          # Always returns 0 (success)

# Expressions
((result = x * y + z))
result=$((a + b))

# Conditionals - use (()) not [[ ]]
((count > 10)) && process
if ((i < max)); then echo 'Continue'; fi
```

**Operators:** `+ - * / % **` | **Comparisons:** `< <= > >= == !=` (native C-style in `(())`)

**Anti-patterns:**

```bash
# ✗ Post-increment �' ✓ Use +=1
((i++))              # Fails when i=0 with set -e
i+=1

# ✗ [[ ]] for integers �' ✓ Use (())
[[ "$count" -gt 10 ]]
((count > 10))       # No quotes needed

# ✗ External expr �' ✓ Native arithmetic
result=$(expr $i + $j)
result=$((i + j))

# ✗ $ inside (()) �' ✓ No $ needed
((result = $i + $j))
((result = i + j))
```

**Gotcha:** Integer division truncates: `((result = 10 / 3))` �' 3. Use `bc`/`awk` for floating point.

**Ref:** BCS0705


---


**Rule: BCS0800**

# Error Handling

**Consolidated section covering automatic error detection, exit codes, traps, return checking, and safe error suppression.**

**Core mandate:** `set -euo pipefail` plus `shopt -s inherit_errexit` before any commands. Catches undefined variables, pipeline failures, command errors. Configure at line 4 after description comment.

**Exit codes:** 0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument, 126=not executable, 127=not found, 128+N=signal N, 130=Ctrl-C.

**Traps:** Use `trap cleanup_function EXIT ERR` for guaranteed cleanup (temp files, locks). EXIT runs on normal/error exit. ERR runs on command failure. Place after `set -e` declaration.

**Return checking:** Test commands explicitly when needed: `if ! command; then error 'Failed'; fi` or `command || die 'Failed'`. Never ignore return codes silently.

**Safe suppression:** Three patterns:
- `|| true` - Ignore specific failure
- `|| :` - Same (`:` is no-op builtin)
- `if command; then ...; fi` - Conditional without error

**Arithmetic safety:** Use `i+=1` not `((i++))` - postfix returns original value, fails with `set -e` when i=0.

**Critical:** Error handling must be first executable code (after shebang/comments). Prevents silent failures during initialization.

**Ref:** BCS0800


---


**Rule: BCS0801**

## Exit on Error

**Always use `set -euo pipefail` at script start (line 4 after description).**

**Flags:**
- `-e`: Exit on command failure (non-zero)
- `-u`: Exit on undefined variable reference
- `-o pipefail`: Pipeline fails if any command fails (not just last)

**Rationale:**
- Catches errors immediately preventing cascading failures
- Scripts behave predictably like compiled languages

**Handle expected failures:**
```bash
command || true                           # Allow failure
if command; then ... else ... fi          # Capture result
set +e; risky_command; set -e            # Temporarily disable
[[ -n "${VAR:-}" ]] && use "$VAR"        # Test undefined vars
```

**Critical gotcha:** `result=$(failing_command)` exits immediately with `set -e` � use `if result=$(cmd); then` or wrap in `set +e; ...; set -e`.

**Ref:** BCS0801


---


**Rule: BCS0802**

## Exit Codes

**Use standardized exit codes: 0=success, 1=general error, 2=usage error, 22=invalid argument (EINVAL).**

**Rationale:**
- 0 is universal Unix convention for success
- 1 is safe catchall for general errors
- 2 matches bash builtin behavior for argument errors
- 22 (EINVAL) is standard errno for invalid arguments
- Consistency enables reliable error handling in scripts and CI/CD

**Core implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success
die 1 'General error'    # General error
die 2 'Missing argument' # Usage error
die 22 'Invalid option'  # Invalid argument
```

**Standard codes:**
- `0` = Success
- `1` = General error (catchall)
- `2` = Misuse of shell builtin/missing argument
- `22` = Invalid argument (EINVAL)
- `126` = Command cannot execute (permission issue)
- `127` = Command not found
- `128+n` = Fatal signal (e.g., 130 = Ctrl+C)

**Best practice - named constants:**
```bash
readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3
die "$ERR_CONFIG" 'Failed to load configuration'
```

**Anti-patterns:**
- Inconsistent exit codes across similar errors � `die 1` for all failures
- Using high numbers (>125) for custom codes (conflicts with signals)
- Exiting with 0 on errors or non-zero on success

**Ref:** BCS0802


---


**Rule: BCS0803**

## Trap Handling

**Standard cleanup pattern ensures resource cleanup on any exit (error, signal, normal).**

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
- Guarantees cleanup of temp files/locks/processes even on Ctrl+C, kill, or errors with `set -e`
- Preserves original exit code via `$?` for proper error propagation
- Prevents recursion by disabling trap before cleanup operations

**Key signals:** `EXIT` (always runs), `SIGINT` (Ctrl+C), `SIGTERM` (kill command)

**Critical rules:**
1. **Set trap BEFORE creating resources** → `trap 'cleanup $?' EXIT` then `temp_file=$(mktemp)`
2. **Disable trap first in cleanup** → Prevents infinite recursion if cleanup fails
3. **Use single quotes** → `trap 'rm "$var"' EXIT` delays expansion until triggered
4. **Capture exit code immediately** → `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`

**Anti-patterns:**
- `trap 'rm "$file"; exit 0' EXIT` → Loses original exit code
- Creating resources before installing trap → Resource leaks if early exit
- `trap "rm $temp_file" EXIT` → Expands variable now, not on trap execution

**Ref:** BCS0803


---


**Rule: BCS0804**

## Checking Return Values

**Always check return values of commands and functions; `set -e` alone is insufficient for pipelines, command substitution, and conditionals.**

**Rationale:** `set -e` doesn't catch: pipeline failures (except last), commands in conditionals, command substitution in assignments, or commands with `||`. Explicit checks provide contextual error messages and controlled recovery.

**Patterns:**

```bash
# Explicit if check (informative)
if ! mv "$source" "$dest/"; then
  error "Failed to move $source to $dest"
  exit 1
fi

# || with die (concise)
mv "$source" "$dest/" || die 1 "Failed to move $source"

# || with cleanup
mv "$temp" "$final" || {
  error "Move failed: $temp � $final"
  rm -f "$temp"
  exit 1
}

# Capture return code
command_that_might_fail
if (($? != 0)); then
  error "Command failed with exit code $?"
  return 1
fi

# Pipelines: use pipefail
set -o pipefail
cat file | grep pattern  # Exits if cat fails

# Command substitution
output=$(cmd) || die 1 "cmd failed"

# With inherit_errexit
shopt -s inherit_errexit
output=$(failing_cmd)  # Exits with set -e
```

**Anti-patterns:**

```bash
#  Ignoring return
mv "$file" "$dest"  # No check!

#  Checking $? too late
command1
command2
if (($? != 0)); then  # Checks command2!

#  Generic error
mv "$file" "$dest" || die 1 "Move failed"

#  Specific context
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"
```

**Ref:** BCS0804


---


**Rule: BCS0805**

## Error Suppression

**Only suppress when failure is expected, non-critical, and safe. Always document WHY. Suppression masks bugs.**

**Appropriate:**
- Optional checks: `command -v tool >/dev/null 2>&1`
- Cleanup: `rm -f /tmp/myapp_* 2>/dev/null || true`
- Idempotent: `install -d "$dir" 2>/dev/null || true`

**NEVER suppress:**

```bash
# ✗ Critical file ops
cp "$config" "$dest" 2>/dev/null || true
# ✓ Correct
cp "$config" "$dest" || die 1 "Copy failed"

# ✗ Data processing
process < in.txt > out.txt 2>/dev/null || true
# ✓ Correct
process < in.txt > out.txt || die 1 'Processing failed'

# ✗ Security ops
chmod 600 "$key" 2>/dev/null || true
# ✓ Correct
chmod 600 "$key" || die 1 "Failed to secure $key"
```

**Patterns:**
- `2>/dev/null` - Suppress messages, check return
- `|| true` - Ignore return code
- `2>/dev/null || true` - Suppress both

**Documentation required:**

```bash
# Suppress: temp files may not exist (non-critical)
rm -f /tmp/myapp_* 2>/dev/null || true

# ✗ WRONG - no reason
cmd 2>/dev/null || true
```

**Anti-patterns:**

```bash
# ✗ Function-wide suppression
process() { ...; } 2>/dev/null

# ✗ Using set +e
set +e; operation; set -e
```

**Principle:** Suppression is exceptional. Document every `2>/dev/null` and `|| true` with WHY.

**Ref:** BCS0805


---


**Rule: BCS0806**

## Conditional Declarations with Exit Code Handling

**Append `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit.**

**Rationale:**
- Arithmetic `(())` returns 0 (true) or 1 (false); under `set -e`, exit code 1 terminates script
- False condition in `((x)) && action` returns 1, causing unwanted exit
- `|| :` provides safe fallback (colon always returns 0, traditional Unix idiom)

**Example:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ Script exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ Script continues
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Common patterns:**

```bash
# Conditional declarations
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :

# Feature-gated actions
((VERBOSE)) && echo "Processing $file" || :

# Nested conditionals
((outer)) && {
  action1
  ((inner)) && action2 || :
} || :
```

**Use when:** Optional declarations, feature flags, debug output, tier-based variables

**Don't use for:** Critical operations (use explicit error handling)

**Anti-patterns:**

```bash
# ✗ Missing || :, exits on false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ Suppressing critical errors
((confirmed)) && delete_all_files || :

# ✓ Explicit check for critical ops
if ((confirmed)); then
  delete_all_files || die 1 "Failed"
fi
```

**Ref:** BCS0806


---


**Rule: BCS0900**

# Input/Output & Messaging

**Standardized messaging with proper stream separation and color support.**

STDOUT = data, STDERR = diagnostics. Always prefix error output: `>&2 echo "error"`.

**Core messaging suite:**
- `_msg()` - Core using FUNCNAME for caller name
- `vecho()` - Verbose output (respects VERBOSE flag)
- `success()`, `warn()`, `info()`, `debug()` - Status messages
- `error()` - Unconditional stderr output
- `die()` - Exit with error message
- `yn()` - Yes/no prompts

**Implementation:**
```bash
_msg() { local level=$1 color=$2; shift 2; >&2 echo -e "${color}[${level}]${RESET} ${FUNCNAME[2]}: $*"; }
vecho() { ((VERBOSE)) && echo "$@"; }
success() { _msg SUCCESS "$GREEN" "$@"; }
warn() { _msg WARNING "$YELLOW" "$@"; }
info() { _msg INFO "$CYAN" "$@"; }
error() { _msg ERROR "$RED" "$@"; }
die() { error "$@"; exit "${2:-1}"; }
```

**Anti-patterns:** `echo "error" >&2` � use `>&2 echo "error"` (clarity); bare `echo` for diagnostics � use messaging functions.

**Ref:** BCS0900


---


**Rule: BCS0901**

## Standardized Messaging and Color Support

**Detect terminal output before enabling colors; use ANSI escape codes via `$'...'` syntax; make color variables readonly.**

**Rationale:** Terminal detection (`[[ -t 1 && -t 2 ]]`) prevents ANSI codes in logs/pipes. Empty string fallback ensures clean non-terminal output. `readonly` prevents accidental modification.

**Pattern:**
```bash
# Message control flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Color support (terminal detection)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' \
              YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Anti-patterns:**
- `RED="\033[0;31m"` � Wrong: double quotes don't interpret escapes, use `$'...'`
- No terminal check � ANSI codes appear in logs
- Mutable colors � Can be accidentally changed mid-script

**Ref:** BCS0901


---


**Rule: BCS0902**

## STDOUT vs STDERR

**All error messages must go to STDERR with `>&2` at command beginning.**

**Rationale:**
- Separates error output from normal output (enables piping/redirection)
- Leading `>&2` improves readability vs trailing

**Example:**
```bash
# Preferred - redirect at start
error() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Acceptable - redirect at end
warn() {
  echo "Warning: $*" >&2
}
```

**Anti-patterns:**
- `echo "error"` � STDOUT (errors invisible when piped)
- Mixing error/normal output on same stream

**Ref:** BCS0902


---


**Rule: BCS0903**

## Core Message Functions

**Use private `_msg()` that inspects `FUNCNAME[1]` to auto-format based on caller.**

**Rationale:** DRY implementation, consistent colored output, proper stdout/stderr separation.

**Implementation:**

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
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

die() {
  local -i exit_code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}
```

**Colors:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
readonly -- RED GREEN YELLOW CYAN NC
```

**Flags:** `declare -i VERBOSE=0 DEBUG=0 PROMPT=1`

**Anti-pattern:**
```bash
# ✗ Wrong
echo "Error: $msg"
# ✓ Correct
error 'Error message'
```

**Ref:** BCS0903


---


**Rule: BCS0904**

## Usage Documentation

**Use heredoc with `cat <<EOT` for multi-line help text including script metadata, options, and examples.**

**Format:** Title line with `$SCRIPT_NAME $VERSION`, description, `Usage:` line, options with short/long forms, examples section.

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}
```

**Rationale:** Heredoc prevents escaping issues, enables variable expansion, maintains formatting.

**Ref:** BCS0904


---


**Rule: BCS0905**

## Echo vs Messaging Functions

**Use messaging functions for operational status (stderr); use `echo` for data output (stdout).**

**Rationale:**
- **Stream separation** - Status (stderr) vs data (stdout) enables clean piping
- **Verbosity control** - Messaging respects `VERBOSE`, echo always displays
- **Parseability** - Only stdout data is pipeable/capturable

**Messaging functions (`info`, `success`, `warn`, `error`):**
- Operational status: `info 'Processing...'`
- Diagnostics: `debug "count=$count"`
- Messages respecting verbosity

**Plain `echo`:**
- Function return values: `echo "$result"` (capturable via `var=$(func)`)
- Help/version text (must always display)
- Reports, structured output
- Pipeable data

**Example:**
```bash
get_home() {
  echo "$(getent passwd "$1" | cut -d: -f6)"  # Data
}

main() {
  info "Looking up: $user"     # Status → stderr
  home=$(get_home "$user")     # Capture stdout
  echo "Home: $home"           # Data → stdout
}
```

**Anti-patterns:**
```bash
# ✗ info() for data → stderr, can't capture
get_email() { info "$email"; }
# ✓ echo for data → stdout
get_email() { echo "$email"; }

# ✗ echo for status → mixes with data
process() { echo 'Processing...'; cat "$file"; }
# ✓ messaging for status → separates streams
process() { info 'Processing...'; cat "$file"; }
```

**Decision: Data → `echo` (stdout), Status → messaging (stderr)**

**Ref:** BCS0905


---


**Rule: BCS0906**

## Color Management Library

**Use dedicated color library with two-tier system (basic/complete), auto terminal detection, and BCS _msg integration for sophisticated color management.**

**Rationale:** Two-tier prevents namespace pollution; auto-detection supports deployment flexibility; _msg integration initializes VERBOSE/DEBUG/DRY_RUN/PROMPT in one call.

**Tiers:**
- **Basic (default):** NC, RED, GREEN, YELLOW, CYAN
- **Complete (opt-in):** +BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE

**Function:** `color_set [OPTIONS...]`
**Options:** `basic|complete`, `auto|always|never`, `verbose`, `flags`

**Example:**
```bash
source color-set.sh
color_set complete flags  # Colors + _msg vars
info "Starting"           # CYAN, respects VERBOSE
echo "${BOLD}${RED}ERROR${NC}"
```

**Implementation:**
```bash
color_set() {
  local -i color=-1 complete=0 flags=0
  # Parse options
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }
  ((flags)) && declare -ig VERBOSE=${VERBOSE:-1}
  ((complete && flags)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  ((color)) && declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' || declare -g NC='' RED='' GREEN='' YELLOW='' CYAN=''
}
```

**Anti-patterns:** Scattered inline declarations → centralize; always complete tier → use basic when sufficient; `[[ -t 1 ]]` only → test both `[[ -t 1 && -t 2 ]]`; hardcode mode → use `${COLOR_MODE:-auto}`.

**Ref:** BCS0906


---


**Rule: BCS1000**

# Command-Line Arguments

**Standard argument parsing supporting short (`-h`, `-v`) and long (`--help`, `--version`) options with consistent patterns.**

**Core requirements:**
- Canonical version format: `scriptname X.Y.Z`
- Validation patterns for required arguments and option conflicts
- Placement: main function (complex scripts) vs top-level (simple scripts)
- Predictable, user-friendly interfaces for interactive and automated usage

**Ref:** BCS1000


---


**Rule: BCS1001**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` pattern with short option support.**

**Core structure:**
```bash
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift; output_file=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -[ovVh]*)       set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

**Rationale:**
- `(($#))` more efficient than `[[ $# -gt 0 ]]` for loop condition
- Case statement more readable/scannable than if/elif chains
- Short bundling pattern (`-[ovVh]*`) enables `-vvv` and `-vno output.txt` syntax
- Mandatory `noarg "$@"` before shift prevents missing-argument errors

**Helper function (required):**
```bash
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }
```

**Anti-patterns:**
- `while [[ $# -gt 0 ]]` � use `while (($#))`
- Missing `noarg` before shift � causes failures on missing args
- Forgetting `shift` at loop end � infinite loop
- if/elif chains � use case statement

**Ref:** BCS1001


---


**Rule: BCS1002**

## Version Output Format

**Format `--version` output as: `<script_name> <version_number>` without the word "version".**

```bash
#  Correct
-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

#  Wrong
-V|--version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Rationale:** GNU/Unix standard format (e.g., `bash --version` � "GNU bash, version 5.2.15").

**Ref:** BCS1002


---


**Rule: BCS1003**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures like `--output --verbose` (missing filename), catches type errors early, provides clear error messages.

### Three Validators

**1. `noarg()` - Basic check:**
```bash
noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}
```

**2. `arg2()` - Enhanced with safe quoting:**
```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

**3. `arg2_num()` - Numeric validation:**
```bash
arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}
```

**Usage:**
```bash
while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT="$1" ;;
  -d|--depth)  arg2_num "$@"; shift; MAX_DEPTH="$1" ;;
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done
```

**Validator selection:**
- `noarg()`: Simple existence (`-o FILE`)
- `arg2()`: Strings, prevent `-` prefix (`--prefix PATH`)
- `arg2_num()`: Integer args (`--depth NUM`)

**Critical:** Call validator BEFORE `shift` (needs `$2`). Use `${1@Q}` for safe error messages.

**Anti-pattern:**
```bash
#  No validation
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose � OUTPUT='--verbose'

#  Validated
-o|--output) arg2 "$@"; shift; OUTPUT="$1" ;;
```

**Ref:** BCS1003


---


**Rule: BCS1004**

## Argument Parsing Location

**Place argument parsing inside `main()` function, not at top level.**

**Rationale:** Enables testability (can invoke `main()` with test arguments), cleaner scoping (parsing variables local to `main()`), better encapsulation.

**Pattern:**

```bash
main() {
  while (($#)); do
    case $1 in
      --opt)    FLAG=1 ;;
      --prefix) shift; PREFIX="$1" ;;
      -h|--help) show_help; exit 0 ;;
      -*)       die 22 "Invalid option '$1'" ;;
      *)        die 2 "Unknown option '$1'" ;;
    esac
    shift
  done

  check_prerequisites
  process_data
}

main "$@"
```

**Exception:** Simple scripts <200 lines without `main()` may parse at top level � `while (($#)); do case $1 in -v) VERBOSE=1 ;; esac; shift; done`

**Ref:** BCS1004


---


**Rule: BCS1005**

## Short-Option Disaggregation in Command-Line Processing Loops

**Split bundled short options (`-abc` → `-a -b -c`) for Unix-standard processing. Allows `script -vvn` instead of `script -v -v -n`.**

## Three Methods

### Method 1: grep (Current)
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```
~190 iter/sec | Requires `grep` + SC2046 disable

### Method 2: fold
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}" ;;
```
~195 iter/sec (+2.3%) | Requires `fold` + SC2046 disable

### Method 3: Pure Bash (Recommended)
```bash
-[amLpvqVh]*) # Pure bash method
  local -- opt=${1:1}; local -a new_args=()
  while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```
~318 iter/sec (**+68%**) | No external deps | No shellcheck warnings

## Rationale

1. **68% faster** - Eliminates subprocess overhead
2. **No external dependencies** - Works in minimal environments
3. **Cleaner code** - No shellcheck disables

## Key Points

- List valid options in pattern (`-[ovnVh]*`) prevents invalid disaggregation
- Place before `-*)` case
- Options with arguments at end: `-vno file.txt` ✓, `-von` ✗ (`-o` captures `n`)

## Anti-Patterns

`((i++))` → Use `i+=1` (fails with `set -e` when i=0)
`[[ -f $file ]]` → Use `[[ -f "$file" ]]` (quote variables)

**Ref:** BCS1005


---


**Rule: BCS1100**

# File Operations

**Safe file handling to prevent data loss and handle edge cases reliably.**

**Core Requirements:**
- Always quote variables in file tests: `[[ -f "$file" ]]` never `[[ -f $file ]]`
- Use explicit paths for wildcards: `rm ./*` never `rm *` (prevents accidental root deletion)
- Use `< <(command)` process substitution instead of pipes to `while` loops (avoids subshell variable loss)
- File test operators: `-e` (exists), `-f` (regular file), `-d` (directory), `-r` (readable), `-w` (writable), `-x` (executable)

**Anti-Patterns:**
- `rm *` � Expands to `rm /` if run in empty directory with `nullglob`
- `cat file | while read line` � Variables modified in loop are lost (subshell)
- `[[ -f $file ]]` � Breaks with filenames containing spaces or special chars

**Minimal Example:**
```bash
shopt -s nullglob
declare -- file='/path/to/file'

[[ -f "$file" ]] || die "File not found: $file"
[[ -r "$file" ]] || die "File not readable: $file"

# Safe wildcard (explicit path)
for f in ./*.txt; do
  process "$f"
done

# Process substitution (preserves variables)
while IFS= read -r line; do
  count+=1
done < <(command)
```

**Ref:** BCS1100


---


**Rule: BCS1101**

## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests to prevent word splitting and glob expansion.**

**Rationale:** Unquoted variables break with spaces/special chars; `[[ ]]` more robust than `[ ]`; testing before use prevents runtime errors; failing fast with informative messages aids debugging.

**Core operators:**
- `-f` regular file, `-d` directory, `-e` any type, `-L` symlink
- `-r` readable, `-w` writable, `-x` executable, `-s` not empty
- `-nt` newer than, `-ot` older than, `-ef` same file

**Example:**
```bash
# Validate and source config
[[ -f "$config" ]] || die 3 "Config not found: $config"
[[ -r "$config" ]] || die 5 "Cannot read: $config"
source "$config"

# Update if source newer
[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"

# Validate executable
validate_executable() {
  [[ -f "$1" ]] || die 2 "Not found: $1"
  [[ -x "$1" ]] || die 126 "Not executable: $1"
}
```

**Anti-patterns:**
- `[[ -f $file ]]` � `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` � `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` � validate first with `-f` and `-r`

**Ref:** BCS1101


---


**Rule: BCS1102**

## Wildcard Expansion

**Always prefix wildcards with explicit path to prevent filenames starting with `-` from being interpreted as flags.**

**Rationale:** Files like `-rf` or `--force` become command flags without path prefix, causing catastrophic execution errors or unintended destructive operations.

**Example:**
```bash
# ✓ Correct
rm -v ./*
for file in ./*.txt; do process "$file"; done

# ✗ Wrong - `-rf.txt` becomes `rm -v -rf.txt`
rm -v *
```

**Anti-patterns:** `rm *`, `cp * dest/`, `for f in *.sh` → Use `./*`, `./*.sh`

**Ref:** BCS1102


---


**Rule: BCS1103**

## Process Substitution

**Use `<(cmd)` for input, `>(cmd)` for output to avoid temp files and subshells.**

**Rationale:** Eliminates temp files, preserves variable scope (no subshell), enables parallelism.

**Input:** `<(cmd)` treats output as readable file:
```bash
diff <(sort file1) <(sort file2)
readarray -t users < <(getent passwd | cut -d: -f1)
while read -r line; do ((count+=1)); done < <(cat file)
```

**Output:** `>(cmd)` treats command as writable file:
```bash
cat log | tee >(grep ERROR > err.txt) >(wc -l > count.txt) > /dev/null
```

**Use cases:**
- Compare outputs: `diff <(ls dir1) <(ls dir2)`
- Avoid subshell in loops: `while read -r x; do count+=1; done < <(cmd)`
- Parallel processing: `cat log | tee >(process1) >(process2) > out`
- Multiple inputs: `paste <(cut -f1 file) <(cut -f2 file)`

**Anti-pattern:**
```bash
# ✗ Temp files
tmp=$(mktemp); sort file1 > "$tmp"; diff "$tmp" file2; rm "$tmp"
# ✓ Process substitution
diff <(sort file1) file2

# ✗ Pipe creates subshell
count=0; cat file | while read -r x; do ((count+=1)); done
echo "$count"  # Still 0!
# ✓ Preserves scope
count=0; while read -r x; do ((count+=1)); done < <(cat file)
```

**Ref:** BCS1103


---


**Rule: BCS1104**

## Here Documents

**Use here-docs for multi-line strings/input; quote delimiter to prevent expansion.**

**Rationale:** Here-docs provide clean multi-line text without escaping. Quoting the delimiter (`<<'EOF'`) prevents variable expansion; unquoted allows expansion.

**Example:**
```bash
# No expansion (quoted delimiter)
cat <<'EOF'
Literal $USER text
EOF

# With expansion
cat <<EOF
User: $USER
EOF
```

**Anti-patterns:**
- `echo -e "line1\nline2"` � Use here-doc for readability
- Forgetting to quote delimiter when literal text needed

**Ref:** BCS1104


---


**Rule: BCS1105**

## Input Redirection vs Cat: Performance Optimization

**Replace `cat filename` with `< filename` in performance-critical contexts for 3-100x speedup.**

**Rationale:** Eliminates process fork/exec overhead. Critical in loops and command substitution.

**Use `< filename` for:**

- **Command substitution** (107x faster): `content=$(< file.txt)` not `$(cat file.txt)`
- **Single input**: `grep "pattern" < file.txt` not `cat file.txt | grep "pattern"`
- **Loops**: `data=$(< "$file")` not `data=$(cat "$file")`

**Example:**
```bash
# Recommended - 100x faster
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

# Avoid - forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
    process "$data"
done
```

**Use `cat` when:**

- Multiple files: `cat file1 file2`
- Need options: `cat -n file`
- Concatenation required

**Anti-pattern:**
```bash
# ✗ Wrong - 100x slower
content=$(cat file.txt)

# ✓ Correct
content=$(< file.txt)
```

**Ref:** BCS1105


---


**Rule: BCS1200**

# Security Considerations

**Security-first practices for production bash scripts covering privilege controls, PATH validation, field separator safety, eval dangers, and input sanitization to prevent privilege escalation, command injection, path traversal, and other attack vectors.**

**Core mandates**: Never SUID/SGID on bash scripts (inherent race conditions, predictable temp files, signal vulnerabilities); lock down PATH or validate explicitly (prevents command hijacking); understand IFS word-splitting risks; avoid `eval` unless justified (injection vector); sanitize all user input early (regex validation, whitelisting).

**Ref:** BCS1200


---


**Rule: BCS1201**

## SUID/SGID

**Never use SUID/SGID bits on Bash scripts - catastrophically dangerous with no exceptions.**

```bash
# ✗ NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID

# ✓ Use sudo
sudo script.sh
# Or configure: username ALL=(root) NOPASSWD: /path/script.sh
```

**Rationale:** Kernel executes interpreter with elevated privileges before script runs, creating attack vectors: IFS exploitation splits words maliciously; caller's PATH finds trojan interpreter before script's PATH sets; `LD_PRELOAD` injects code; race conditions on file operations; shell expansions exploitable; no compilation means readable/modifiable source.

**Attack example:**
```bash
# Attacker's trojan in /tmp/evil/bash runs as root BEFORE script's PATH setting
export PATH=/tmp/evil:$PATH
./suid-script.sh  # Kernel finds /tmp/evil/bash via caller's PATH
```

**Safe alternatives:** sudo with `/etc/sudoers.d/` config; capabilities on compiled programs (`setcap`); compiled C wrapper that sanitizes environment then `execl()` script; PolicyKit; systemd service.

**Detection:** `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.

**Modern Linux ignores SUID on scripts but don't rely on it - many Unix variants honor it.**

**Ref:** BCS1201


---


**Rule: BCS1202**

## PATH Security

**Lock down PATH immediately to prevent command hijacking and trojan binary injection.**

**Rationale:**
- Attacker-controlled directories allow malicious binaries to replace system commands
- `.` or empty elements (`:` `::`) cause execution from current directory
- Earlier directories searched first, enabling priority-based attacks

**Secure PATH patterns:**

```bash
#!/bin/bash
set -euo pipefail

# Pattern 1: Complete lockdown (recommended)
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH

# Pattern 2: Full paths (maximum security)
/bin/tar -czf backup.tar.gz data/
/usr/bin/systemctl restart nginx
```

**Validation approach:**

```bash
# Check for dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Critical anti-patterns:**

```bash
#  Trusting inherited PATH
#!/bin/bash
# No PATH setting - uses caller's environment

#  Current directory in PATH
export PATH=.:$PATH

#  Empty elements (:: = current dir)
export PATH=/usr/local/bin::/usr/bin:/bin
```

**Key principle:** Set PATH in first few lines after `set -euo pipefail`. Use `readonly PATH` to prevent modification. Never include `.`, empty elements, `/tmp`, or user directories.

**Ref:** BCS1202


---


**Rule: BCS1203**

## IFS Manipulation Safety

**Always protect IFS changes to prevent field splitting attacks and command injection.**

**Rationale:** Attackers manipulate inherited IFS values to exploit word splitting, bypass validation, or inject commands through unquoted expansions.

**Safe Patterns:**

```bash
# Set at script start
IFS=$' \t\n'
readonly IFS

# One-line scope (preferred)
IFS=',' read -ra fields <<< "$csv"

# Local scope in functions
local -- IFS
IFS=','
read -ra fields <<< "$csv"

# Subshell isolation
fields=( $(IFS=','; printf '%s\n' $csv) )

# Save/restore
saved_ifs="$IFS"
IFS=','
read -ra fields <<< "$csv"
IFS="$saved_ifs"
```

**Attack Example:**

```bash
#  Vulnerable - trusts inherited IFS
read -ra parts <<< "$user_input"
# Attacker: export IFS='/'; script splits on '/' not spaces

#  Protected
IFS=$' \t\n'
readonly IFS
read -ra parts <<< "$user_input"
```

**Anti-pattern:**

```bash
#  Wrong - global IFS change without restore
IFS=','
read -ra fields <<< "$data"
# All subsequent operations broken!
```

**Ref:** BCS1203


---


**Rule: BCS1204**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely—safer alternatives exist for all use cases.**

**Rationale:**
- **Code injection** - Executes arbitrary commands with full script privileges
- **Double expansion** - Expands twice, enabling command substitution attacks
- **Bypasses validation** - Sanitized input still vulnerable to metacharacters

**Core danger:**
```bash
user_input="$1"
eval "$user_input"  # ✗ Executes: rm -rf / or worse
```

**Safe alternatives:**

```bash
# ✗ eval for command building
eval "find /data -name '$pattern'"

# ✓ Use arrays
cmd=(find /data -name "$pattern")
"${cmd[@]}"

# ✗ eval for indirection → ✓ Use ${!var}
eval "value=\$$var_name"  # ✗
value="${!var_name}"       # ✓

# ✗ eval for dynamic vars → ✓ Use associative arrays
eval "var_$i='value'"     # ✗
declare -A data; data["var_$i"]='value'  # ✓

# ✗ eval for dispatch → ✓ Use case/array
eval "${action}_func"     # ✗
case "$action" in
  start) start_func ;;
  stop)  stop_func ;;
  *)     die 22 "Invalid" ;;
esac
```

**Anti-patterns:**
- `eval "$input"` → Whitelist with case
- `eval "$var='$val'"` → `printf -v "$var" '%s' "$val"`
- `eval "source $file"` → `source "$file"`

**Key principle:** Use arrays, indirect expansion (`${!var}`), or associative arrays instead of `eval`.

**Ref:** BCS1204


---


**Rule: BCS1205**

## Input Sanitization

**Always validate user input to prevent injection attacks and directory traversal.**

**Rationale:** Never trust user input—validate type, format, range before processing.

**Patterns:**

```bash
# Filename validation
sanitize_filename() {
  [[ -n "$1" ]] || die 22 'Empty'
  local n="${1//\.\./}"; n="${n//\//}"
  [[ "$n" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Unsafe: $n"
}

# Integer range
validate_port() {
  [[ "$1" =~ ^[0-9]+$ ]] || die 22 "Invalid: $1"
  ((1 <= $1 && $1 <= 65535)) || die 22 "Range: $1"
}

# Path containment
validate_path() {
  local p=$(realpath -e -- "$1") || die 22 "Invalid: $1"
  [[ "$p" == "$2"* ]] || die 5 "Outside: $p"
}

# Whitelist
validate_choice() {
  local in="$1"; shift
  for c in "$@"; do [[ "$in" == "$c" ]] && return 0; done
  die 22 "Invalid: $in"
}
```

**Injection prevention:**

```bash
# ✗ Command injection
eval "$user_cmd"          # NEVER!
cat "$file"               # file="; rm -rf /"

# ✓ Safe
case "$cmd" in start|stop) systemctl "$cmd" app ;; esac
cat -- "$file"            # Use -- separator

# ✗ Option injection  
rm "$file"                # file="--delete-all"
# ✓ Safe
rm -- "$file"
ls ./"$file"
```

**Anti-pattern:**

```bash
# ✗ Blacklist (incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid'
# ✓ Whitelist
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die 1 'Invalid'
```

**Ref:** BCS1205


---


**Rule: BCS1300**

# Code Style & Best Practices

**Comprehensive coding conventions for readable, maintainable Bash 5.2+ scripts organized by theme.**

## Core Standards

**Formatting**: 2-space indentation (never tabs), 100-char lines (URLs/paths excepted), consistent alignment.

**Comments**: Explain WHY (rationale, business logic), not WHAT (code shows). Focus on intent and non-obvious decisions.

**Visual Structure**: Blank lines separate logical sections; banner-style section markers: `# === Section Name ===`

## Language Practices

**Bash Idioms**: Use modern features (`[[ ]]`, `(())`, process substitution), prefer built-ins over externals.

**Patterns**: `"$var"` default → braces only when required; single quotes for static strings; `i+=1` not `((i++))`

## Development Standards

**ShellCheck**: Compulsory compliance; document disabled checks with rationale comments.

**Testing**: Validate all code paths; use `set -x` for debugging; trap ERR for diagnostics.

**Version Control**: Atomic commits; meaningful messages; `.gitignore` temporaries.

**Ref:** BCS1300


---


**Rule: BCS1301**

## Code Formatting

**Use 2 spaces for indentation (never tabs), maintain consistency, keep lines under 100 characters (except paths/URLs), use `\` for line continuation.**

**Rationale:**
- 2-space indentation balances readability with nesting depth in complex scripts
- 100-char limit ensures readability in split terminals/code reviews without horizontal scrolling

**Example:**
```bash
if [[ -f "$config_file" ]]; then
  long_command --option1 value1 \
    --option2 value2 \
    --option3 value3
fi
```

**Anti-patterns:**
- `�` Using tabs for indentation (breaks visual consistency across editors)
- `�` Lines exceeding 100 chars without continuation (forces horizontal scrolling)

**Ref:** BCS1301


---


**Rule: BCS1302**

## Comments

**Explain WHY, not WHAT. Code shows what happens; comments explain rationale, business logic, and non-obvious decisions.**

**Rationale:**
- Self-documenting code reduces maintenance burden; comments decay when code changes
- WHY explanations capture decision context that code structure cannot express

```bash
#  Explains rationale and special cases
# PROFILE_DIR hardcoded to /etc/profile.d for system-wide integration,
# regardless of PREFIX, ensuring builtins available in all sessions
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited

#  Restates what code shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Comment when:**
- Non-obvious business rules/edge cases exist
- Intentional deviations from patterns occur
- Specific approach chosen over alternatives requires explanation

**Don't comment:**
- Simple assignments � `PREFIX=/usr/local`
- Self-explanatory code with clear naming
- Standard BCS patterns

**Section separators:** 80 dashes
```bash
# --------------------------------------------------------------------------------
```

**Documentation icons:** � (info), � (debug), � (warn),  (success),  (error)

**Ref:** BCS1302


---


**Rule: BCS1303**

## Blank Line Usage

**Strategic blank lines improve readability by separating logical blocks.**

**Core rules:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between variable groups
- Blank lines before/after multi-line conditionals or loops
- Never use multiple consecutive blank lines
- No blank line between short, related statements

**Minimal example:**

```bash
#!/bin/bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")

PREFIX=/usr/local
DRY_RUN=0

BIN_DIR="$PREFIX"/bin
LIB_DIR="$PREFIX"/lib

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

**Anti-patterns:**
- `function1() { ... }\nfunction2() { ... }` → No blank line between functions
- Multiple consecutive blank lines → Use single blank line only

**Ref:** BCS1303


---


**Rule: BCS1304**

## Section Comments

**Use lightweight `# Description` comments to group related code blocks (variables, functions, logical groups).**

**Format**: Simple `# Description` (no dashes/decorations), 2-4 words, placed immediately before group.

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

# Core message function
_msg() { local -- prefix="$SCRIPT_NAME:" msg; }

# Conditional messaging
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Unconditional messaging
error() { >&2 _msg "$@"; }
```

**Common patterns**: `# Default values`, `# Derived paths`, `# Helper functions`, `# Business logic`, `# Validation functions`

Reserve 80-dash separators for major script divisions only.

**Ref:** BCS1304


---


**Rule: BCS1305**

## Language Best Practices

**Use `$()` for command substitution, never backticks.** `$()` nests naturally without escaping, has better syntax highlighting, and is more readable. Backticks require escaping (`\``) when nested.

**Prefer shell builtins over external commands.** Builtins are 10-100x faster (no process creation), guaranteed available, and have no PATH dependencies.

```bash
#  Builtins
result=$((x + y))
upper=${var^^}
lower=${var,,}
base=${path##*/}
dir=${path%/*}
[[ -f "$file" ]]

#  External commands
result=$(expr "$x" + "$y")
upper=$(echo "$var" | tr '[:lower:]' '[:upper:]')
base=$(basename "$path")
[ -f "$file" ]
```

**Common replacements:** `expr` � `$(())`, `basename` � `${var##*/}`, `dirname` � `${var%/*}`, `tr` (case) � `${var^^}` / `${var,,}`, `test`/`[` � `[[`, `seq` � `{1..10}` or `((i=1; i<=10; i++))`.

**Rationale:** Performance (no subshell/process spawn), reliability (no external dependencies), portability (guaranteed in bash).

**Ref:** BCS1305


---


**Rule: BCS1306**

## Development Practices

**ShellCheck is compulsory.** Document all `#shellcheck disable=SCxxxx` directives with reasons.

```bash
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
```

**End scripts with `#fin` marker** (mandatory).

```bash
main "$@"
#fin
```

**Defensive patterns:** Set defaults with `: "${VAR:=default}"`, validate inputs early (`[[ -n "$1" ]] || die 1 'Required'`), use `set -u`.

**Performance:** Minimize subshells, use built-in string ops over external commands, prefer process substitution over temp files.

**Testing:** Make functions testable, use dependency injection, support verbose/debug modes, return meaningful exit codes.

**Ref:** BCS1306


---


**Rule: BCS1307**

## Emoticons

**Use standardized icons in documentation for consistent severity/status signaling.**

### Standard Severity Levels
```
◉  info: Informational
⦿ debug: Verbose/Debug
▲  warn: Warning
✗  error: Error
✓  success: Success/Done
```

### Extended Icons
```
⚠  Caution/Important/Alert
☢  Fatal/Critical
↻  Redo/Retry/Update/Refresh
◆  Checkpoint
●  In Progress
○  Pending
◐  Partial
⟲  Cycle/Repeat
▶  Start/Execute
■  Stop/Halt
⏸  Pause
⏹  Terminate
⎆  Power/System
☰  Menu/List
⚙  Settings/Config
→  Forward/Next
←  Back/Previous
↑  Up/Upgrade/Increase
↓  Down/Downgrade/Decrease
⇄  Swap/Exchange
⇅  Sync/Bidirectional
⤴  Return/Back Up
⤵  Forward/Down Into
⟳  Processing/Loading
⏱  Timer/Duration
```

**Rationale:** Consistent visual language reduces cognitive load, enables rapid status scanning, and provides language-independent communication across diverse teams.

**Ref:** BCS1307


---


**Rule: BCS1400**

# Advanced Patterns

**Section covers 10 production-grade patterns:** debugging (`set -x`, PS4 customization), dry-run mode, secure temporary files (`mktemp`), environment variables, regex matching, background jobs, structured logging, performance profiling, testing methodologies, progressive state management.

**Core use cases:** Safe pre-deployment testing, performance optimization, robust error handling, maintainable state logic separating decision from execution.

**Ref:** BCS1400


---


**Rule: BCS1401**

## Debugging and Development

**Enable debugging features using `DEBUG` flag and enhanced trace mode.**

**Core pattern:**
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

**Key elements:**
- `set -x` � trace execution when `DEBUG=1`
- `PS4` � shows file:line:function in trace output
- `debug()` � conditional debug messages via stderr

**Ref:** BCS1401


---


**Rule: BCS1402**

## Dry-Run Pattern

**Preview mode pattern: Check flag at function start, show preview message, return early without executing operations.**

```bash
declare -i DRY_RUN=0

# Parse options
-n|--dry-run) DRY_RUN=1 ;;

# Pattern in functions
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi
  make standalone || die 1 'Build failed'
}
```

**Structure:**
1. Check `((DRY_RUN))` at function start
2. Display preview with `[DRY-RUN]` prefix via `info`
3. Return early (exit 0) without operations
4. Execute real operations when disabled

**Rationale:** Separates decision logic from action � script flows through same functions/logic paths whether previewing or executing � users verify paths/commands safely before destructive operations � maintains identical control flow for debugging.

**Anti-patterns:**
- `if ! ((DRY_RUN))` � Inverted logic harder to read
- Mixing dry-run checks with business logic � Test flag once at top, exit early

**Ref:** BCS1402


---


**Rule: BCS1403**

## Temporary File Handling

**Always use `mktemp` for temp files/directories; use `trap` EXIT handlers for guaranteed cleanup.**

**Rationale:** mktemp creates files atomically with secure permissions (0600) preventing race conditions. EXIT trap ensures cleanup even on failure/interruption.

**Basic pattern:**

```bash
# Single temp file
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file

# Temp directory
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
readonly -- temp_dir
```

**Multiple temp resources:**

```bash
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=$?
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
    [[ -d "$file" ]] && rm -rf "$file"
  done
  return "$exit_code"
}
trap cleanup EXIT

temp1=$(mktemp) || die 1 'Failed'
TEMP_FILES+=("$temp1")
```

**Critical anti-patterns:**

```bash
# ✗ Hard-coded path → collisions, insecure
temp_file="/tmp/myapp_temp.txt"

# ✗ PID in filename → predictable, race conditions  
temp_file="/tmp/myapp_$$.txt"

# ✗ No trap → file remains on exit/failure
temp_file=$(mktemp)

# ✗ Multiple traps overwrite → only last executes
trap 'rm -f "$temp1"' EXIT
trap 'rm -f "$temp2"' EXIT  # temp1 lost!

# ✓ Single trap for all
trap 'rm -f "$temp1" "$temp2"' EXIT
```

**Template:** `mktemp /tmp/script.XXXXXX` (≥3 X's)

**Ref:** BCS1403


---


**Rule: BCS1404**

## Environment Variable Best Practices

**Validate required environment variables at script startup using parameter expansion error syntax.**

**Rationale:** Fail-fast prevents runtime errors in production when critical configuration missing. Parameter expansion `${VAR:?message}` provides atomic check-and-error.

**Implementation:**
```bash
# Required (exit if unset)
: "${DATABASE_URL:?DATABASE_URL must be set}"

# Optional with default
: "${LOG_LEVEL:=INFO}"

# Bulk validation
declare -a REQUIRED=(DATABASE_URL API_KEY)
for var in "${REQUIRED[@]}"; do
  [[ -n "${!var:-}" ]] || die "Required: $var"
done
```

**Anti-patterns:**
- Checking environment variables deep in business logic � validate at startup
- Using `if [[ -z "$VAR" ]]` � prefer `${VAR:?error}` for required vars

**Ref:** BCS1404


---


**Rule: BCS1405**

## Regular Expression Guidelines

**Use POSIX character classes and store complex patterns in readonly variables.**

**Rationale:** POSIX classes ensure locale-independent portability; predefined patterns reduce errors and improve maintainability.

**Example:**
```bash
# POSIX classes
[[ "$var" =~ ^[[:alnum:]]+$ ]]        # Alphanumeric
[[ "$var" =~ ^[[:digit:]]+$ ]]        # Digits

# Store patterns
readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 'Invalid email'

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
fi
```

**Anti-patterns:**
- `[a-zA-Z]` → Use `[[:alpha:]]` (locale-safe)
- Inline complex regex → Define as readonly variable

**Ref:** BCS1405


---


**Rule: BCS1406**

## Background Job Management

**Manage background processes using `&`, `$!`, and `wait` with proper error handling.**

**Pattern:**
```bash
# Track and monitor
long_running_command &
PID=$!
kill -0 "$PID" 2>/dev/null  # Check running

# Wait with timeout
timeout 10 wait "$PID" || kill "$PID" 2>/dev/null

# Multiple jobs
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done
for pid in "${PIDS[@]}"; do wait "$pid"; done
```

**Critical**: Use `kill -0` to test process existence, `timeout` for bounded waits, array for multiple PIDs. Exit code 124 indicates timeout.

**Ref:** BCS1406


---


**Rule: BCS1407**

## Logging Best Practices

**Structured logging for production scripts using consistent format and level filtering.**

```bash
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
  local -- level="$1" message="${*:2}"
  printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"
}
```

**Rationale:** ISO8601 timestamps enable chronological sorting/filtering; structured format (`[timestamp] [script] [level] message`) supports grep/awk analysis; readonly LOG_FILE/LOG_LEVEL prevent runtime modification.

**Anti-patterns:** `echo "error" >> log.txt` (unstructured, no timestamp) � use `log ERROR "description"`; hardcoded log paths � use `${LOG_FILE:-default}` for environment override.

**Ref:** BCS1407


---


**Rule: BCS1408**

## Performance Profiling

**Use `SECONDS` or `EPOCHREALTIME` builtins for timing operations.**

**Rationale:** Built-in timing variables avoid external `date` calls; `EPOCHREALTIME` provides microsecond precision (Bash 5.0+).

**Pattern:**
```bash
# Basic timing with SECONDS
SECONDS=0
operation
info "Completed in ${SECONDS}s"

# High-precision with EPOCHREALTIME
start=$EPOCHREALTIME
operation
end=$EPOCHREALTIME
runtime=$(awk "BEGIN {print $end - $start}")
```

**Anti-patterns:**
- `date +%s` � Use `SECONDS` builtin instead
- External `time` command � Use builtins for programmatic timing

**Ref:** BCS1408


---


**Rule: BCS1409**

## Testing Support Patterns

**Use dependency injection and test mode flags to make scripts testable without modifying production code.**

**Rationale:** Testability requires isolating external dependencies (commands, file systems) while maintaining production behavior.

**Example:**
```bash
# Dependency injection - override for tests
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"

if ((TEST_MODE)); then
  DATA_DIR='./test_data'
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR='/var/lib/app'
  RM_CMD() { rm "$@"; }
fi

# Assert helper
assert() {
  local -- expected="$1" actual="$2" message="${3:-Assertion failed}"
  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
}

# Test runner
run_tests() {
  local -i passed=0 failed=0
  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1; echo " $test_func"
    else
      failed+=1; echo " $test_func"
    fi
  done
  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```

**Anti-pattern:** Modifying production code for tests or using global mocks that affect all functions.

**Ref:** BCS1409


---


**Rule: BCS1410**

## Progressive State Management

**Modify boolean flags based on runtime conditions, separating decision logic from execution.**

**Pattern:**
1. Declare flags with initial values (`declare -i INSTALL_BUILTIN=0`)
2. Parse arguments, set flags from user input
3. Adjust flags: dependency checks → build failures → user overrides
4. Execute based on final flag state

**Example:**
```bash
# Initial state
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0

# Parse: user requested --builtin
INSTALL_BUILTIN=1
BUILTIN_REQUESTED=1

# Validate: check prerequisites
if ! check_builtin_support; then
  ((BUILTIN_REQUESTED)) && install_bash_builtins || INSTALL_BUILTIN=0
fi

# Build: disable on failure
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

# Execute: only if still enabled
((INSTALL_BUILTIN)) && install_builtin
```

**Benefits:** Decision/action separation, traceable flag changes, fail-safe behavior, preserves user intent.

**Guidelines:**
- Separate flags for user intent (`*_REQUESTED`) vs. runtime state (`INSTALL_*`)
- Apply state changes in order: parse → validate → execute
- Never modify flags during execution phase
- Document state transitions

**Anti-patterns:**
- `[[ "$FLAG" == "yes" ]]` → Use `((FLAG))` for booleans
- Changing flags inside action functions → Disable before actions
- Single flag for request and state → Separate concerns

**Ref:** BCS1410
#fin
