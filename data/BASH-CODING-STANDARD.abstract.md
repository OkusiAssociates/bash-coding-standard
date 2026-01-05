# Bash Coding Standard

**Bash 5.2+ standard. Not a compatibility guide.**

## Principles
- K.I.S.S. â€” Remove unused functions/variables
- "Everything as simple as possible, but not simpler"

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

**Mandatory 13-step layout for all Bash scripts: shebang â†' metadata â†' functions â†' main â†' `#fin`.**

Core elements: shebang, `set -euo pipefail`, shopt settings, metadata block, bottom-up function organization, `main()` function, end marker.

**Ref:** BCS0100


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## 13-Step Pattern (Minimal)

```bash
#!/bin/bash
#shellcheck disable=SC2034
# Description comment
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION=1.0.0
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -- CONFIG_VAR=default
declare -i DRY_RUN=0

# Colors (TTY-aware)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Messaging functions
error() { >&2 echo "$SCRIPT_NAME: ${RED}âœ—${NC} $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Business logic
do_work() { ((DRY_RUN)) && { echo '[DRY-RUN]'; return 0; }; }

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      *)            die 22 "Invalid: ${1@Q}" ;;
    esac
    shift
  done
  readonly -i DRY_RUN
  do_work
}

main "$@"
#fin
```

## Key Patterns

- **Metadata** â†' VERSION, SCRIPT_PATH/DIR/NAME with grouped `readonly --`
- **TTY colors** â†' `[[ -t 1 && -t 2 ]]` conditional
- **Dry-run** â†' `declare -i DRY_RUN=0`, check via `((DRY_RUN))`
- **Progressive readonly** â†' After arg parsing: `readonly -i DRY_RUN`

**Ref:** BCS010101


---


**Rule: BCS010102**

### Layout Anti-Patterns

**Eight critical BCS0101 violations with corrections.**

---

**1. Missing strict mode** â†' silent failures
```bash
# âœ— set -euo pipefail missing
# âœ“ Add immediately after shebang
```

**2. Variables after use** â†' "unbound variable" with `set -u`
```bash
# âœ— main() uses VERBOSE before declaration
# âœ“ Declare all globals before functions
```

**3. Utilities after business logic** â†' harder to trace dependencies
```bash
# âœ— process_files() calls die() defined below
# âœ“ Define utilities first, business logic after
```

**4. No main() in large scripts** â†' no clear entry point, untestable
```bash
# âœ— Logic runs directly after functions
# âœ“ Use main() for scripts >40 lines
```

**5. Missing `#fin`** â†' can't detect truncated files

**6. Readonly before parsing** â†' can't modify via `--prefix`
```bash
# âœ— readonly -- PREFIX before arg parsing
# âœ“ readonly -- PREFIX after parsing complete
```

**7. Scattered declarations** â†' hard to see all state
```bash
# âœ— Globals interspersed with functions
# âœ“ All globals grouped together
```

**8. Unprotected sourcing** â†' runs main when sourced
```bash
# âœ“ Dual-purpose pattern:
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Standard 13-step layout modifications for specific use cases: small scripts, libraries, external config, platform detection, cleanup traps.**

---

## Legitimate Simplifications

- **<200 lines** â†' skip `main()`, run directly
- **Library files** â†' skip `set -e`, `main()`, execution (avoid affecting caller)
- **One-off utilities** â†' may skip colors, verbose messaging

## Legitimate Extensions

- **External config** â†' source between metadata and business logic; `readonly` after sourcing
- **Platform detection** â†' add platform globals after standard globals
- **Cleanup traps** â†' after utility functions, before business logic
- **Lock files** â†' acquisition/release around main execution

## Core Example â€” Library Pattern

```bash
#!/usr/bin/env bash
# Library - meant to be sourced, not executed
# No set -e (affects caller), no readonly (caller may modify)

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
# No main(), no execution
#fin
```

## Anti-Pattern

```bash
# âœ— Functions before set -e
validate() { : ... }
set -euo pipefail  # Too late!
VERSION=1.0.0
check() { : ... }
declare -- PREFIX=/usr  # Globals scattered
```

## Invariant Principles

Even when deviating:
1. **Safety first** â€” `set -euo pipefail` still comes first (unless library)
2. **Dependencies before usage** â€” bottom-up organization applies
3. **Document reasons** â€” comment why deviating

**Ref:** BCS010103


---


**Rule: BCS0101**

## General Script Layout

**All scripts follow a mandatory 13-step structure ensuring safe initialization and bottom-up dependency resolution.**

### The 13 Steps

1. **Shebang** `#!/bin/bash` or `#!/usr/bin/env bash`
2. **ShellCheck directives** (if needed)
3. **Brief description** - one-line purpose
4. **`set -euo pipefail`** - MUST precede any commands
5. **`shopt -s inherit_errexit shift_verbose extglob nullglob`**
6. **Metadata** - `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`
7. **Global declarations** - typed (`-i`/`--`/`-a`/`-A`)
8. **Colors** (conditional on `[[ -t 1 && -t 2 ]]`)
9. **Utility functions** - messaging (`info`, `warn`, `error`, `die`)
10. **Business logic** - organized bottom-up
11. **`main()`** - argument parsing, orchestration
12. **`main "$@"`** - invocation
13. **`#fin`** - mandatory end marker

### Minimal Example

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
declare -r VERSION=1.0.0
die() { >&2 echo "error: ${2:-}"; exit "${1:-1}"; }
main() { echo 'Hello'; }
main "$@"
#fin
```

### Key Rationale

- **Bottom-up**: functions call only previously-defined functions
- **`set -euo pipefail` first**: error handling before execution
- **`main()` required** for scripts >100 lines (enables testing)

### Anti-Patterns

- âœ— Business logic before `set -euo pipefail` â†' runtime failures
- âœ— Missing `main()` in large scripts â†' untestable

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts

**Scripts that work both as executables AND sourceable libraries must apply `set -euo pipefail` only when executed directly, never when sourced.**

Sourcing applies shell options to the caller's environment, breaking error handling.

**Detection:** `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`

**Pattern:**
```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0
# --- Executable section ---
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Key Rules:**
- Functions defined BEFORE detection line (available in both modes)
- `set`/`shopt` AFTER detection (executable only)
- Use `return` not `exit` for sourced errors
- Guard metadata: `[[ ! -v VAR ]] && declare...` for idempotence

**Anti-patterns:**
- `set -e` before detection â†' pollutes caller's shell
- `exit 1` in sourced mode â†' terminates caller's shell

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**First lines: shebang â†' optional shellcheck â†' description â†' `set -euo pipefail`**

**Allowed shebangs:** `#!/bin/bash` (Linux) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (portable)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Key points:**
- `set -euo pipefail` MUST be first executable command
- Strict mode before any other code executes

**Anti-patterns:** `#!/bin/sh` â†' not Bash | Missing `set -euo pipefail` â†' silent failures

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME immediately after `shopt`, using `declare -r` for immutability.**

**Rationale:** Reliable path resolution via `realpath`; consistent resource location; prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:** VERSION (semver) â†' SCRIPT_PATH (`realpath -- "$0"`) â†' SCRIPT_DIR (`${SCRIPT_PATH%/*}`) â†' SCRIPT_NAME (`${SCRIPT_PATH##*/}`)

**Anti-patterns:**
- `SCRIPT_PATH="$0"` â†' use `realpath -- "$0"` (resolves symlinks/relative paths)
- `dirname`/`basename` â†' use parameter expansion (faster, no external command)
- `SCRIPT_DIR=$PWD` â†' derive from SCRIPT_PATH (PWD is current dir, not script location)

**Edge cases:** Root directory (`SCRIPT_DIR` empty) â†' handle with `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`; Sourced scripts â†' use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103


---


**Rule: BCS0104**

## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search for resourcesâ€”enables predictable locations, multi-environment support, and package manager compatibility.**

**Key rationale:** Eliminates hardcoded paths; works in dev/local/system install modes; XDG support for user files.

**FHS locations:** `/usr/local/{bin,share,lib,etc}/` (local install) â†' `/usr/{bin,share}/` (system) â†' `$HOME/.local/{bin,share}/` (user) â†' `${XDG_CONFIG_HOME:-$HOME/.config}/` (user config)

**Core patternâ€”FHS search:**
```bash
find_data_file() {
  local -- filename=$1
  local -a search_paths=(
    "$SCRIPT_DIR"/"$filename"                              # Development
    /usr/local/share/myapp/"$filename"                     # Local install
    /usr/share/myapp/"$filename"                           # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$filename"  # User
  )
  local -- path
  for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  return 1
}
```

**PREFIX pattern:** `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin` â†' supports `make PREFIX=/usr install`

**Anti-patterns:**
- `source /usr/local/lib/myapp/common.sh` â†' hardcoded path breaks portability
- `install myapp /opt/random/` â†' non-FHS location, breaks package managers

**When NOT to use:** Single-user scripts, project-specific tools, containers with `/app`

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt Settings

**Configure `shopt -s inherit_errexit shift_verbose extglob nullglob` for robust error handling and glob behavior.**

### Required Settings

| Option | Purpose |
|--------|---------|
| `inherit_errexit` | Makes `set -e` work in `$(...)` subshells |
| `shift_verbose` | Error on invalid shift (no silent failure) |
| `extglob` | Extended patterns: `!(*.txt)`, `+([0-9])` |

### Glob Behavior (Choose One)

- **`nullglob`** â†' Unmatched glob = empty (for loops/arrays)
- **`failglob`** â†' Unmatched glob = error (strict scripts)

### Why inherit_errexit is Critical

```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!
echo 'Still runs'  # Executes

shopt -s inherit_errexit
result=$(false)  # Script exits here
```

### Anti-Pattern

```bash
# âœ— Default: unmatched glob = literal string
for f in *.txt; do rm "$f"; done  # Tries "rm *.txt" if no match!

# âœ“ With nullglob: loop skipped if no matches
shopt -s nullglob
for f in *.txt; do rm "$f"; done
```

### Optional

`globstar` enables `**/*.sh` recursive matching (slow on deep trees).

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` only (non-executable); PATH-available commands: no extension.**

### Quick Rules
- Executable scripts â†' `.sh` or extensionless
- Libraries (sourced) â†' `.sh`, chmod 644
- Global commands (in PATH) â†' no extension

### Anti-Pattern
`mylib` (no extension, executable library) â†' `mylib.sh` (chmod 644)

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: primitives first, `main()` last. Dependencies flow downward only.**

### Rationale
- No forward referencesâ€”Bash reads top-to-bottom
- Readabilityâ€”understand primitives before compositions
- Testabilityâ€”low-level functions testable independently

### 7-Layer Pattern

1. **Messaging** `_msg()`, `info()`, `warn()`, `error()`, `die()`
2. **Documentation** `show_help()`, `show_version()`
3. **Utilities** `yn()`, `noarg()`, `trim()`
4. **Validation** `check_prerequisites()`, `validate_input()`
5. **Business logic** Domain operations
6. **Orchestration** `run_build_phase()`, `cleanup()`
7. **main()** Top-level flow â†' `main "$@"` â†' `#fin`

```bash
# Layer 1: Messaging (lowest)
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4: Validation
check_prerequisites() { info 'Checking...'; }

# Layer 5: Business logic
build_project() { check_prerequisites; make all; }

# Layer 7: main() (highest)
main() { build_project; }
main "$@"
#fin
```

### Anti-Patterns

```bash
# âœ— main() at top (forward references)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# âœ— Random ordering
cleanup(); build(); check_deps(); main()

# âœ— Circular dependencies
func_a() { func_b; }
func_b() { func_a; }  # Extract common logic instead
```

**Key:** Each function calls only functions defined above it.

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Explicit declaration with type hints for safety and clarity.**

Core practices: `declare -i` (integers), `declare --` (strings), `declare -a` (arrays), `declare -A` (associative). Scoping: globals at script level, `local --` in functions. Naming: `UPPER_CASE` constants, `lower_case` variables. Use `readonly --` for immutables. Boolean flags as integers (`declare -i FLAG=0`). Derived variables compute from others.

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Use explicit type declarations (`declare -i`, `declare --`, `-a`, `-A`) for type safety, intent documentation, and error prevention.**

### Declaration Types

| Type | Purpose | Example |
|------|---------|---------|
| `-i` | Integers | `declare -i count=0` |
| `--` | Strings | `declare -- path=/tmp` |
| `-a` | Indexed arrays | `declare -a files=()` |
| `-A` | Associative arrays | `declare -A config=()` |
| `readonly` | Constants | `readonly -- VERSION=1.0` |
| `local` | Function scope | `local -- file=$1` |

### Core Rules

- **Always use `--` separator** with `declare`, `local`, `readonly` â†' prevents option injection
- **Integer vars** auto-evaluate: `count='5+3'` â†' 8
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`

### Example

```bash
declare -i count=0
declare -- config_path=/etc/app.conf
declare -a files=()
declare -A status=()

process() {
  local -- file=$1
  local -i lines
  lines=$(wc -l < "$file")
}
```

### Anti-Patterns

```bash
# âœ— No type (intent unclear)     â†' âœ“ declare -i count=0
count=0

# âœ— Missing -- separator         â†' âœ“ local -- file=$1
local file=$1

# âœ— Scalar to array              â†' âœ“ files=(file.txt)
files=file.txt
```

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function variables as `local` to prevent namespace pollution.**

Without `local`: variables become global â†' overwrite globals, persist after return, break recursion.

```bash
process_file() {
  local -- file=$1    # âœ“ Scoped to function
  local -i count=0    # âœ“ Local integer
}
```

**Anti-patterns:** `file=$1` in function â†' overwrites global `$file`; recursive functions without `local` share state across calls.

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use UPPER_CASE for globals/constants, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `MAX_RETRIES=3` |
| Locals | lower_case | `local file_count=0` |
| Private functions | _prefix | `_validate_input()` |

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -i VERBOSE=1
process_data() {
  local -i line_count=0
  local -- temp_file
}
_internal_helper() { :; }
```

**Why:** UPPER_CASE signals script-wide scope; lower_case prevents shadowing; underscore prefix marks internal-only. Avoid shell reserved names (`PATH`, `HOME`, single-letter).

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly` for immutable values; `declare -x`/`export` for subprocess-visible variables.**

| Feature | `readonly` | `declare -x` |
|---------|-----------|--------------|
| Prevents modification | âœ“ | âœ— |
| Available to children | âœ— | âœ“ |

**Key patterns:**
- Group `readonly -- VAR1 VAR2` after assignment block
- Combine: `declare -rx` for immutable + exported
- Allow override first: `VAR=${VAR:-default}; readonly -- VAR`

```bash
# Constants (not exported)
readonly -- SCRIPT_VERSION=2.1.0

# Environment for children
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}

# Combined: readonly + exported
declare -rx BUILD_ENV=production
```

**Anti-patterns:**
- `export MAX_RETRIES=3` â†' Children don't need internal constants; use `readonly --`
- `CONFIG_FILE=/path` without `readonly` â†' Accidental modification risk
- `readonly -- OUTPUT_DIR="$val"` before allowing user override

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Initialize all related variables first, then protect entire group with single `readonly --` statement.**

### Rationale
- Prevents assignment-to-readonly errors
- Groups related constants visibly
- Explicit immutability contract

### Three-Step Pattern (for parsed variables)
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
# 2. Modify during parsing (in main)
# 3. Make readonly AFTER parsing
readonly -- VERBOSE DRY_RUN
```

### Standard Groups

**Colors** (conditional):
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m' NC=$'\033[0m'
else
  RED='' NC=''
fi
readonly -- RED NC
```

**Paths** (derived):
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR
```

### Exception
Script metadata uses `declare -r` instead (see BCS0103).

### Anti-Patterns

```bash
# âœ— Premature readonly
PREFIX=/usr/local
readonly -- PREFIX  # Too early!
BIN_DIR="$PREFIX"/bin  # PREFIX locked before group complete

# âœ— Missing -- separator
readonly PREFIX BIN_DIR  # Risky if var starts with -

# âœ— Readonly inside conditional
if [[ -f conf ]]; then
  CONFIG=conf
  readonly -- CONFIG  # May not execute!
fi

# âœ“ Correct
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
readonly -- PREFIX BIN_DIR
```

### Delayed Readonly
Variables modified by argument parsing â†' make readonly after parsing completes:
```bash
[[ -z "$CONFIG" ]] || readonly -- CONFIG
```

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git)
readonly -- SCRIPT_PATH=$(realpath -- "$0")
```

**Anti-pattern:** Omitting `readonly` for values that should never change â†' silent bugs from accidental overwrites.

**Ref:** BCS0206


---


**Rule: BCS0207**

## Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Declaration & Operations

```bash
declare -a files=()              # Indexed array
declare -A config=()             # Associative (Bash 4.0+)
files+=("$path")                 # Append element
count=${#files[@]}               # Length
first=${files[0]}                # Access (0-indexed)
```

#### Safe Iteration

```bash
for f in "${files[@]}"; do process "$f"; done
```

#### Safe Population

```bash
readarray -t lines < <(command)  # From command
IFS=',' read -ra fields <<< "$csv"  # Split string
```

#### Command Construction

```bash
local -a cmd=(app '--config' "$cfg")
((verbose)) && cmd+=('--verbose') ||:
"${cmd[@]}"                      # Execute safely
```

#### Critical Anti-Patterns

`rm ${files[@]}` â†' `rm "${files[@]}"` (unquoted breaks on spaces)

`array=($string)` â†' `readarray -t array <<< "$string"` (word splitting unsafe)

`for x in "${arr[*]}"` â†' `for x in "${arr[@]}"` (single word vs separate)

| Op | Syntax |
|----|--------|
| All | `"${arr[@]}"` |
| Length | `${#arr[@]}` |
| Slice | `"${arr[@]:1:3}"` |
| Indices | `"${!arr[@]}"` |

**Ref:** BCS0207


---


**Rule: BCS0208**

## Reserved for Future Use

**BCS0208 is a placeholder reserved for future Variables & Data Types expansion.**

#### Purpose

Maintains code sequence integrity and prevents external reference conflicts.

#### Possible Future Topics

- Nameref variables (`declare -n`)
- Indirect expansion (`${!var}`)
- Variable attributes/introspection

**Status:** Reserved â€” do not use in compliance checking.

**Ref:** BCS0208


---


**Rule: BCS0209**

## Derived Variables

**Compute variables from base values; update all derivations when base changes.**

**Rationale:** DRY principleâ€”single source of truth; automatic consistency when PREFIX changes; prevents subtle bugs from stale derived values.

**Pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived from PREFIX
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib/"$APP_NAME"

# Update function for arg parsing
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib/"$APP_NAME"
}

# After --prefix changes: update_derived_paths
# Make readonly AFTER all parsing complete
readonly -- PREFIX BIN_DIR LIB_DIR
```

**XDG fallbacks:** `CONFIG_BASE=${XDG_CONFIG_HOME:-$HOME/.config}`

**Anti-patterns:**

```bash
# âœ— Duplicating base value
BIN_DIR=/usr/local/bin  # Hardcoded, not derived!

# âœ— Not updating after base changes
PREFIX=$1  # BIN_DIR now stale!

# âœ— Readonly before parsing complete
readonly -- BIN_DIR  # Can't update later!
```

**Key rules:**
- Group derived vars with section comments
- Update ALL derivations when base changes
- `readonly` only after parsing complete
- Document hardcoded exceptions

**Ref:** BCS0209


---


**Rule: BCS0210**

## Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### Braces Required

```bash
"${var##*/}"      # Pattern removal
"${var:-default}" # Default value
"${var:0:5}"      # Substring
"${var//old/new}" # Substitution
"${var,,}"        # Lowercase
"${array[@]}"     # Array access
"${var1}${var2}"  # No-separator concat
"${prefix}suffix" # Alphanumeric follows
```

#### No Braces Needed

```bash
"$var"           # Standalone
"$PREFIX"/bin    # Separator delimits
"$var-suffix"    # Dash/dot/slash separates
```

#### Key Operations

| Op | Syntax | Use |
|----|--------|-----|
| Prefix rm | `${v##*/}` | Basename |
| Suffix rm | `${v%/*}` | Dirname |
| Default | `${v:-x}` | Fallback |
| Replace | `${v//a/b}` | Subst all |
| Length | `${#v}` | Char count |

**Anti-patterns:** `"${var}"` standalone â†' `"$var"` | `"${PREFIX}/bin"` â†' `"$PREFIX"/bin`

**Ref:** BCS0210


---


**Rule: BCS0211**

## Boolean Flags

**Use `declare -i` integer variables for boolean state; test with `(())`.**

### Why
- Arithmetic truthiness (`((FLAG))`) is cleaner than string comparison
- Integer type prevents accidental non-numeric assignment

### Pattern
```bash
declare -i DRY_RUN=0
((DRY_RUN)) && info 'Dry-run mode'
case $1 in --dry-run) DRY_RUN=1 ;; esac
```

### Anti-patterns
- `DRY_RUN=false` â†' Use `0`/`1`, not strings
- `[[ "$FLAG" -eq 1 ]]` â†' Use `((FLAG))`

**Ref:** BCS0211


---


**Rule: BCS0300**

# Strings & Quoting

**Single quotes for static strings; double quotes when variable expansion needed.**

## 7 Rules

| Code | Rule |
|------|------|
| BCS0301 | Quoting Fundamentals - static vs dynamic |
| BCS0302 | Command Substitution - quote `$(...)` |
| BCS0303 | Conditionals - quote vars in `[[ ]]` |
| BCS0304 | Here Documents - delimiter quoting |
| BCS0305 | printf - format string quoting |
| BCS0306 | Parameter Quoting - `${param@Q}` |
| BCS0307 | Anti-Patterns - common mistakes |

## Core Pattern

```bash
info 'Static message'           # Single quotes
info "Processing $file"         # Double quotes for vars
[[ -f "$path" ]]               # Always quote in conditionals
```

## Anti-Patterns

`echo $var` â†' `echo "$var"` (unquoted expansion)
`info "Literal text"` â†' `info 'Literal text'` (wrong quote type)

**Ref:** BCS0300


---


**Rule: BCS0301**

## Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Pattern

```bash
info 'Static message'              # Single - no expansion
info "Found $count files"          # Double - variable needed
die 1 "Unknown option '$1'"        # Mixed - literal quotes in output
```

#### Path Concatenation (Recommended)

```bash
"$PREFIX"/bin                      # Separate quoting - clearer boundaries
"$SCRIPT_DIR"/data/"$filename"     # Variable boundaries explicit
```

#### Rationale

1. **Safety**: Single quotes prevent accidental expansion of `$`, backticks
2. **Clarity**: Quote type signals intent (literal vs. expansion)
3. **Path readability**: Separate quoting makes variable boundaries visible

#### Anti-Patterns

```bash
info "Checking..."        # â†' info 'Checking...'     (static = single)
EMAIL=user@domain.com     # â†' EMAIL='user@domain.com' (special chars)
[[ "$x" == "active" ]]    # â†' [[ "$x" == 'active' ]] (literal comparison)
```

#### Quick Rules

- Static text â†' single quotes
- Variables needed â†' double quotes
- Special chars (`@`, `*`, `$`) â†' always quote
- Empty string â†' `''`
- One-word alphanumeric â†' quotes optional but recommended

**Ref:** BCS0301


---


**Rule: BCS0302**

## Command Substitution

**Always double-quote strings containing `$()` and quote variables holding command output to prevent word splitting.**

#### Core Pattern

```bash
# âœ“ Correct
echo "Time: $(date +%T)"
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
result=$(cmd); echo "$result"
```

#### Anti-Pattern

`echo $result` â†' word splitting on whitespace

**Ref:** BCS0302


---


**Rule: BCS0303**

## Quoting in Conditionals

**Always quote variables in conditionals.** Static values use single quotes.

```bash
[[ -f "$file" ]]              # Variable quoted
[[ "$name" == 'value' ]]      # Literal single-quoted
[[ "$input" =~ $pattern ]]    # Regex pattern unquoted
```

**Why:** Unquoted variables break on spaces/globs, empty values cause syntax errors, injection risk.

**Anti-patterns:** `[[ -f $file ]]` â†' breaks with spaces; `[[ "$x" == "literal" ]]` â†' use single quotes for static strings.

**Ref:** BCS0303


---


**Rule: BCS0304**

## Here Documents

**Quote delimiter (`<<'EOF'`) to prevent expansion; unquoted (`<<EOF`) for variable substitution.**

#### Delimiter Types

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

#### Core Pattern

```bash
# Variables expand
cat <<EOF
User: $USER
EOF

# Literal content (no expansion)
cat <<'EOF'
{"name": "$APP_NAME"}
EOF
```

#### Indentation

`<<-` removes leading tabs only (not spaces).

#### Anti-Pattern

`<<EOF` with SQL â†' injection risk if variables contain user input. Use `<<'EOF'` for literal queries with placeholders.

**Ref:** BCS0304


---


**Rule: BCS0305**

## printf Patterns

**Single-quote format strings; double-quote variable arguments. Prefer printf over echo -e.**

#### Pattern

```bash
printf '%s: %d found\n' "$name" "$count"  # Format static, args quoted
echo 'Done'                                # Static: single quotes
echo "$SCRIPT_NAME $VERSION"               # Variables: double quotes
```

#### Key Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

#### Anti-Patterns

`echo -e "a\nb"` â†' `printf 'a\nb\n'` or `echo $'a\nb'`

**Ref:** BCS0305


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of user input in error messages and logging.**

`${var@Q}` expands to shell-quoted value preventing injection and command execution.

#### Core Behavior

```bash
name='$(rm -rf /)'
echo "${name@Q}"    # Output: '$(rm -rf /)' (safe, literal)
```

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | `*.txt` | `'*.txt'` |

#### When to Use

**Use @Q:** Error messages, logging input, dry-run display
```bash
die 2 "Unknown option ${1@Q}"
info "[DRY-RUN] ${cmd[@]@Q}"
```

**Don't use @Q:** Normal expansion (`"$file"`), comparisons

#### Anti-Pattern

```bash
# âœ— Wrong - injection risk
die 2 "Unknown option $1"

# âœ“ Correct
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0306


---


**Rule: BCS0307**

## Quoting Anti-Patterns

**Avoid common quoting mistakes that cause word splitting, glob expansion, and inconsistent code.**

---

#### Critical Anti-Patterns

**Static strings:** Use single quotes â†' `info 'message'` not `info "message"`

**Unquoted variables:** Always quote â†' `"$var"` not `$var`

**Unnecessary braces:** Omit when not needed â†' `"$HOME"/bin` not `"${HOME}/bin"`

**Braces required for:** `${var:-default}`, `${file##*/}`, `"${array[@]}"`, `${var1}${var2}`

**Arrays:** Always quote â†' `"${items[@]}"` not `${items[@]}`

**Glob danger:** `echo "$pattern"` preserves literal; `echo $pattern` expands

**Here-docs:** Quote delimiter for literal content â†' `<<'EOF'` not `<<EOF`

---

#### Example

```bash
# âœ— Wrong
info "Starting..."
[[ -f $file ]]
echo "${HOME}/bin"

# âœ“ Correct
info 'Starting...'
[[ -f "$file" ]]
echo "$HOME"/bin
```

---

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static | `'literal'` | `"literal"` |
| Variable | `"$var"` | `$var` |
| Path | `"$HOME"/bin` | `"${HOME}/bin"` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Ref:** BCS0307


---


**Rule: BCS0400**

# Functions

**Function definition patterns, naming (`lowercase_with_underscores`), organization, export (`declare -fx`), and production optimization.**

## Core Requirements

- `main()` required for scripts >200 lines â†' improves testability
- Bottom-up organization: messaging â†' helpers â†' business logic â†' `main()`
- Remove unused utility functions in production scripts

## Export Pattern

```bash
my_lib_func() { :; }
declare -fx my_lib_func
```

## Anti-patterns

- `main()` missing in large scripts â†' poor structure, untestable
- Top-down organization â†' forward reference issues

**Ref:** BCS0400


---


**Rule: BCS0401**

## Function Definition Pattern

**Use single-line syntax for simple operations; multi-line with `local --` for complex functions.**

```bash
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

main() {
  local -i exitcode=0
  local -- variable
  return "$exitcode"
}
```

**Anti-pattern:** `local file="$1"` â†' `local -- file="$1"` (always use `--` separator)

**Ref:** BCS0401


---


**Rule: BCS0402**

## Function Names

**Use lowercase_with_underscores; prefix private functions with `_`.**

### Core Pattern

```bash
process_log_file() { â€¦ }     # âœ“ Public
_validate_input() { â€¦ }      # âœ“ Private (internal)
```

### Why

- Matches Unix conventions (`grep`, `sed`)
- Avoids conflicts with built-ins (all lowercase)
- `_prefix` signals internal-only use

### Anti-Patterns

```bash
MyFunction() { â€¦ }           # âœ— CamelCase
PROCESS_FILE() { â€¦ }         # âœ— UPPER_CASE
my-function() { â€¦ }          # âœ— Dashes cause issues
cd() { builtin cd "$@"; }    # âœ— Overriding built-in
```

â†' Wrap built-ins with different name: `change_dir()` not `cd()`

**Ref:** BCS0402


---


**Rule: BCS0403**

## Main Function

**Use `main()` for scripts >200 lines as single entry point; place `main "$@"` before `#fin`.**

**Rationale:** Testability (source without executing), scope control (locals in main), centralized exit code handling.

**Core pattern:**
```bash
main() {
  local -i verbose=0
  local -- output=''
  local -a files=()

  while (($#)); do case $1 in
    -v) verbose=1 ;;
    -o) shift; output=$1 ;;
    --) shift; break ;;
    -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done
  files+=("$@")
  readonly -- verbose output; readonly -a files

  # Business logic...
  return 0
}
main "$@"
#fin
```

**Sourceable pattern:** `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `main "$@"`.

**Anti-patterns:**
- `main` without `"$@"` â†' arguments lost
- Defining functions after `main "$@"` â†' undefined at runtime
- Parsing arguments outside main â†' consumed before main runs

**Ref:** BCS0403


---


**Rule: BCS0404**

## Function Export

**Use `declare -fx` to export functions for subshell access.**

Required when functions must be available to: `xargs`, `find -exec`, parallel execution, or any child process.

```bash
grep() { /usr/bin/grep "$@"; }
declare -fx grep
```

Anti-pattern: `export -f func` â†' use `declare -fx func` instead (consistent with BCS declaration style).

**Ref:** BCS0404


---


**Rule: BCS0405**

## Production Script Optimization

**Remove unused functions/variables from mature production scripts.**

### Why
- Reduces size, improves clarity, eliminates maintenance burden

### Pattern
```bash
# Development: full toolkit
source lib/messaging.sh  # All utilities

# Production: keep only what's used
error() { >&2 printf '%s\n' "ERROR: $*"; }
die() { error "$@"; exit 1; }
# Removed: info, warn, debug, yn, trim...
```

### Anti-Pattern
```bash
# âœ— Shipping unused utilities
declare -- PROMPT='> '    # Never used
debug() { :; }            # Never called
```

**Ref:** BCS0405


---


**Rule: BCS0406**

## Dual-Purpose Scripts

**Scripts that execute directly OR source as libraries, using `BASH_SOURCE[0]` detection.**

#### Pattern

```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "${arg@Q}"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail
main() { my_func "$@"; }
main "$@"
#fin
```

#### Critical Rules

- Define functions BEFORE `set -e` â†' sourcing parent controls error handling
- Export functions: `declare -fx func_name` â†' enables subshell access
- Idempotent init: `[[ -v LIB_VERSION ]] || declare -rx LIB_VERSION=1.0`

#### Anti-Patterns

```bash
# âœ— set -e before source check
set -euo pipefail
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Risky

# âœ— Functions not exported â†' subshell access fails
my_func() { :; }
```

**Ref:** BCS0406


---


**Rule: BCS0407**

## Library Patterns

**Create reusable libraries with source guards, namespacing, and explicit exports.**

---

#### Key Points

- Source guard prevents execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || exit 1`
- Export functions with `declare -fx func_name`
- Namespace all functions: `myapp_init()`, `myapp_cleanup()`
- Configurable defaults: `: "${CONFIG_DIR:=/etc/myapp}"`

---

#### Library Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Namespaced library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: Must be sourced, not executed'
  exit 1
}

declare -rx LIB_MYAPP_VERSION=1.0.0

myapp_init() { :; }
myapp_process() { local -- input=$1; echo "$input"; }

declare -fx myapp_init myapp_process
#fin
```

#### Sourcing Libraries

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR/lib-utils.sh"

# With existence check
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing ${lib_path@Q}"
```

---

#### Anti-Patterns

- `source lib.sh` with immediate side effects â†' Correct: define functions only, call `lib_init` explicitly

---

**Ref:** BCS0407


---


**Rule: BCS0408**

## Dependency Management

**Use `command -v` for dependency checks; provide clear errors for missing tools; support graceful degradation with availability flags.**

#### Core Rationale
- Clear errors vs cryptic failures from missing tools
- Enables optional dependency fallbacks
- Documents requirements explicitly

#### Pattern

```bash
# Required dependencies
for cmd in curl jq; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done

# Optional with fallback
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && jq -r '.f' <<< "$json" || grep -oP '"f":"\K[^"]+'
```

#### Anti-Patterns

`which curl` â†' `command -v curl` (POSIX compliant)

Silent `curl "$url"` â†' explicit check first with helpful install message

**Ref:** BCS0408


---


**Rule: BCS0500**

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
- `[ "$var" = "value" ]` ’ use `[[ $var == value ]]`
- `command | while read line; do count+=1; done` ’ variables lost (subshell)
- `((i++))` in loops ’ fails when i=0 with `set -e`

**Ref:** BCS0700


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

**Why `[[ ]]` over `[ ]`:** No word splitting/glob expansion, pattern matching (`==`, `=~`), logical operators inside (`&&`, `||`), no `-a`/`-o` needed.

```bash
# String/file tests
[[ -f "$file" && -r "$file" ]] && source "$file" ||:
[[ "$name" == *.txt ]] && process "$name"

# Arithmetic tests
((count)) && echo "Items: $count"
((i >= MAX)) && die 1 'Limit exceeded'

# Combined
if [[ -n "$var" ]] && ((count)); then process; fi
```

**Key operators:** `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` executable, `-z` empty, `-n` not-empty, `=~` regex.

**Anti-patterns:**
- `[ ]` syntax â†' use `[[ ]]`
- `[ -f "$f" -a -r "$f" ]` â†' `[[ -f "$f" && -r "$f" ]]`
- `[[ "$count" -gt 10 ]]` â†' `((count > 10))`

**Ref:** BCS0501


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way pattern matching on single variable; use compact format for simple actions, expanded for multi-line logic; always include `*)` default case.**

**Rationale:** Faster than if/elif chains (single evaluation), native pattern/wildcard support, visually organized with column alignment.

**Case vs if/elif:** Case for single-variable pattern matching; if/elif for multiple variables, numeric ranges, or complex boolean logic.

**Core patterns:**
```bash
# Compact (single actions, align ;;)
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -o|--output)  shift; OUTPUT=$1 ;;
  -*)           die 22 "Invalid: ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac

# Pattern matching
case "$file" in
  *.txt|*.md) process_text ;;
  *.jpg|*.png) process_image ;;
  *)          die 1 'Unknown type' ;;
esac
```

**Expression quoting:** Don't quote case expression (`case $1 in` not `case "$1" in`)â€”word splitting doesn't apply there.

**Pattern syntax:** Literals (`start`), wildcards (`*.txt`, `?`), alternation (`a|b|c`), extglob (`@(x|y)`, `!(*.tmp)`), character classes (`[0-9]`).

**Anti-patterns:**
- `case "${1:-}" in` â†' `case ${1:-} in` (unnecessary quotes)
- Missing `*)` default â†' silent failures on unexpected input
- Mixing compact/expanded formats inconsistently
- `[0-9]+` in case â†' not regex; use `+([0-9])` with extglob
- Nested case for multiple variables â†' use if/elif instead

**Ref:** BCS0502


---


**Rule: BCS0503**

## Loops

**Use `for` for arrays/globs/ranges, `while` for input/conditions; always quote arrays as `"${array[@]}"`, use `< <(cmd)` not pipes to avoid subshell issues.**

### Key Rationale
- Process substitution preserves variable scope (pipes create subshells)
- `while ((1))` is 15-22% faster than `while true`
- `nullglob` prevents literal pattern iteration on no-match

### Core Patterns

```bash
# Array iteration (safe with spaces)
for file in "${files[@]}"; do process "$file"; done

# Command output (preserves variables)
while IFS= read -r line; do count+=1; done < <(find . -name '*.txt')

# C-style (use i+=1, NEVER i++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Argument parsing
while (($#)); do case $1 in -v) VERBOSE=1 ;; esac; shift; done

# Infinite (fastest)
while ((1)); do work; ((done)) && break; done
```

### Anti-Patterns

```bash
# âœ— Pipe loses variables     â†' âœ“ Use < <(cmd)
cmd | while read -r x; do n+=1; done  # n stays 0!

# âœ— Parse ls output          â†' âœ“ Use glob directly
for f in $(ls *.txt); do ...          # for f in *.txt

# âœ— Unquoted array           â†' âœ“ Quote expansion
for x in ${arr[@]}; do ...            # "${arr[@]}"

# âœ— i++ fails at 0 with -e   â†' âœ“ Use i+=1
for ((i=0; i<n; i++)); do ...         # i+=1

# âœ— local inside loop        â†' âœ“ Declare before loop
for f in *; do local x; ...           # local x; for f in *
```

**Ref:** BCS0503


---


**Rule: BCS0504**

## Pipes to While Loops

**Never pipe to while loopsâ€”pipes create subshells where variables don't persist. Use `< <(cmd)` or `readarray`.**

### Why It Fails

```bash
# âœ— Variables lost in subshell
count=0
cmd | while read -r x; do count+=1; done
echo "$count"  # Always 0!
```

### Solutions

**Process substitution** (most common):
```bash
# âœ“ Loop runs in current shell
while IFS= read -r line; do
  count+=1
done < <(command)
```

**readarray** (collecting lines):
```bash
# âœ“ Direct to array
readarray -t lines < <(command)
readarray -d '' -t files < <(find . -print0)  # null-delimited
```

**Here-string** (variable input):
```bash
while read -r x; do ...; done <<< "$var"
```

### Anti-Patterns

```bash
# âœ— Counter stays 0
grep PAT file | while read -r l; do n+=1; done

# âœ— Array stays empty
find . | while read -r f; do arr+=("$f"); done

# âœ— Assoc array empty
cat cfg | while IFS='=' read -r k v; do m[$k]=$v; done

# âœ“ All fixed with: done < <(command)
```

### Key Points

- Subshell vars discarded when pipe ends â†' silent bugs
- No error messagesâ€”script runs with wrong values
- `< <(cmd)` keeps loop in current shell
- `readarray -d ''` for null-delimited (filenames with spaces)
- For counts only: `grep -c` avoids the issue

**Ref:** BCS0504


---


**Rule: BCS0505**

## Arithmetic Operations

**Use `declare -i` for integers, `(())` for comparisons, and `i+=1` for increments.**

### Core Rules

- **Declare integers**: `declare -i count=0` â€” enables auto-arithmetic, type safety
- **Increment**: `i+=1` ONLY â†' requires `declare -i`; `((i++))` exits with `set -e` when i=0
- **Comparisons**: Use `(())` not `[[ -eq ]]` â†' `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` â€” non-zero is truthy

### Pattern

```bash
declare -i i=0 max=5
while ((i < max)); do
  process_item
  i+=1
done
((i < max)) || die 1 'Max reached'
```

### Anti-Patterns

```bash
# âœ— NEVER - exits with set -e when i=0
((i++))

# âœ— Verbose/old-style
[[ "$count" -gt 10 ]]

# âœ“ Correct
((count > 10))
i+=1
```

### Why `((i++))` Fails

```bash
set -e; i=0
((i++))  # Returns 0 (old value) = "false" â†' script exits!
```

### Operators

| Op | Use | Note |
|----|-----|------|
| `+=` | `i+=1` | Only increment form |
| `(())` | Comparisons | `<` `>` `==` `!=` `<=` `>=` |
| `$(())` | Expressions | `result=$((a + b))` |

**Ref:** BCS0505


---


**Rule: BCS0506**

## Floating-Point Operations

**Bash only supports integer arithmetic; use `bc` (precision) or `awk` (inline) for floats.**

#### Tools

**bc** â€” arbitrary precision:
```bash
result=$(echo "$width * $height" | bc -l)
```

**awk** â€” inline with formatting:
```bash
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')
```

#### Comparisons

```bash
# bc returns 1=true, 0=false
if (($(echo "$a > $b" | bc -l))); then

# awk comparison
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then
```

#### Anti-Patterns

```bash
# âœ— Integer division loses precision
result=$((10 / 3))  # Returns 3, not 3.333
# âœ“ Use bc
result=$(echo '10 / 3' | bc -l)

# âœ— String comparison of floats
[[ "$a" > "$b" ]]  # Wrong!
# âœ“ Use bc/awk numeric comparison
```

**Ref:** BCS0506


---


**Rule: BCS0600**

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


**Rule: BCS0601**

## Exit on Error

**Mandatory `set -euo pipefail` enables strict mode: exit on command failure (`-e`), undefined variables (`-u`), or pipe failures (`-o pipefail`).**

**Why:** Catches errors immediately; prevents cascading failures; makes scripts behave like compiled languages.

### Handling Expected Failures

```bash
# Allow failure
cmd_might_fail || true

# Capture in conditional (avoids set -e exit)
if result=$(failing_cmd); then
  echo "OK: $result"
fi

# Temporary disable
set +e; risky_cmd; set -e
```

### Critical Gotcha

```bash
# âœ— Exits before check (set -e triggers on substitution)
result=$(failing_cmd)
[[ -n "$result" ]] && echo "$result"

# âœ“ Conditional protects from exit
if result=$(failing_cmd); then echo "$result"; fi
```

**Anti-patterns:** Leaving flags disabled longer than necessary â†' re-enable immediately after risky operation.

**Ref:** BCS0601


---


**Rule: BCS0602**

## Exit Codes

**Use consistent exit codes for predictable error handling across scripts.**

### die() Function
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
die 3 'File not found'
```

### Core Codes
| Code | Name | Use |
|------|------|-----|
| 0 | SUCCESS | OK |
| 1 | ERR_GENERAL | Catchall |
| 2 | ERR_USAGE | CLI error |
| 3-7 | File ops | NOENT/ISDIR/IO/NOTDIR/EMPTY |
| 8-10,22 | Validation | REQUIRED/RANGE/TYPE/INVAL |
| 11-13 | Permissions | PERM/READONLY/ACCESS |
| 14-17 | Resources | NOMEM/NOSPC/BUSY/EXIST |
| 18-21 | Environment | NODEP/CONFIG/ENV/STATE |
| 23-25 | Network | NETWORK/TIMEOUT/HOST |

### Reserved: 64-78 (sysexits), 126-127 (Bash), 128+n (signals)

### Usage
```bash
[[ -f "$cfg" ]] || die 3 "Not found ${cfg@Q}"
command -v jq &>/dev/null || die 18 'Missing: jq'
```

### Anti-Patterns
- `exit 1` for all errors â†' Use specific codes
- Codes 64+ â†' Reserved for system use

**Ref:** BCS0602


---


**Rule: BCS0603**

## Trap Handling

**Use cleanup functions with `trap 'cleanup $?' SIGINT SIGTERM EXIT` to ensure resources are released on any exit.**

### Core Pattern

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -d "$temp_dir" ]] && rm -rf "$temp_dir"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Critical Rules

- **Set trap early** â€” before creating resources (prevents leaks if script fails between creation and trap)
- **Disable trap first in cleanup** â€” prevents infinite recursion if cleanup fails
- **Capture `$?` in trap command** â€” `trap 'cleanup $?' EXIT` preserves original exit code
- **Single quotes** â€” delays variable expansion until trap fires

### Signals

| Signal | Trigger |
|--------|---------|
| `EXIT` | Any script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |

### Anti-Patterns

```bash
# âœ— Exit code lost
trap 'rm "$f"; exit 0' EXIT
# âœ“ Preserve exit code
trap 'ec=$?; rm "$f"; exit $ec' EXIT

# âœ— Double quotes expand NOW
trap "rm $temp" EXIT
# âœ“ Single quotes expand on TRAP
trap 'rm "$temp"' EXIT

# âœ— Resource before trap (leak risk)
temp=$(mktemp); trap 'rm "$temp"' EXIT
# âœ“ Trap before resource
trap 'rm "$temp"' EXIT; temp=$(mktemp)
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values explicitlyâ€”`set -e` misses pipelines, conditionals, and command substitution.**

**Why:** Better error messages with context â†' Controlled recovery/cleanup â†' Catches `set -e` blind spots â†' Debugging aid

**`set -e` blind spots:** Pipelines (except last) â†' Conditionals (`if cmd`) â†' Command substitution in assignments â†' Commands with `||`

**Patterns:**

```bash
# Pattern 1: || die (concise)
mv "$src" "$dst" || die 1 "Failed to move ${src@Q}"

# Pattern 2: || { } (with cleanup)
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Pattern 3: Capture $?
wget "$url"; case $? in 0) ;; 4) die 4 'Network failure' ;; esac

# Pattern 4: Command substitution
output=$(cmd) || die 1 'cmd failed'

# Pattern 5: PIPESTATUS for pipelines
cat f | grep p; ((PIPESTATUS[0])) && die 1 'cat failed'
```

**Edge cases:**
- Pipelines: Use `set -o pipefail` or check `PIPESTATUS[]`
- Command substitution: Add `|| die` or use `shopt -s inherit_errexit`
- Conditionals: Add explicit `die` in else branch

**Anti-patterns:**

```bash
# âœ— No check after command
mv "$f" "$d"

# âœ— Generic error message
mv "$f" "$d" || die 1 'failed'

# âœ— $? checked too late
cmd1; cmd2; (($?))  # Checks cmd2!

# âœ— No cleanup on failure
cp "$s" "$d" || exit 1  # Leaves partial file
```

**Ref:** BCS0604


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe. Always document WHY.**

**Rationale:** Masks bugs, silent failures, debugging nightmare, security risk.

### Safe to Suppress

- Command existence: `command -v tool >/dev/null 2>&1`
- Optional files: `[[ -f "$optional" ]]`
- Cleanup: `rm -f /tmp/app_* 2>/dev/null || true`
- Idempotent ops: `install -d "$dir" 2>/dev/null || true`

### NEVER Suppress

- Critical file ops â†' must verify success
- Data processing â†' silent data loss
- System config â†' `systemctl` must check
- Security ops â†' `chmod 600` must succeed
- Required deps â†' fail early

### Patterns

```bash
# Suppress stderr, check return
if ! command 2>/dev/null; then handle_error; fi

# Ignore return (stderr visible)
command || true

# Full suppression (document why!)
# Rationale: temp files may not exist
rm -f /tmp/app_* 2>/dev/null || true
```

### Anti-Patterns

```bash
# âœ— Suppressing critical op
cp "$file" "$backup" 2>/dev/null || true

# âœ— Undocumented suppression
some_cmd 2>/dev/null || true

# âœ— Block suppression
set +e; critical_op; set -e

# âœ“ Check critical ops
cp "$file" "$dest" || die 1 'Failed'
```

**Key:** Every suppression needs a comment explaining why failure is safe to ignore.

**Ref:** BCS0605


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from terminating script.**

**Core Problem:** `(())` returns 1 (failure) when false â†' `set -e` exits script.

**Rationale:**
- `|| :` provides safe fallback (`:` always returns 0)
- Traditional Unix idiom for "ignore this error"

**Pattern:**

```bash
declare -i complete=0

# âœ— DANGEROUS: Script exits if complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# âœ“ SAFE: Script continues
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use `:` over `true`:** Traditional, concise (1 char), built-in, no PATH lookup.

**When to use:** Optional declarations, conditional exports, feature-gated actions, optional logging.

**When NOT to use:** Critical operations needing explicit error handling â†' use `if` statement instead.

**Anti-patterns:**

```bash
# âœ— Missing || : - exits on false
((flag)) && action

# âœ— Suppressing critical operations
((confirmed)) && delete_files || :

# âœ“ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606


---


**Rule: BCS0700**

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

**Anti-patterns:** `echo "error" >&2` ’ use `>&2 echo "error"` (clarity); bare `echo` for diagnostics ’ use messaging functions.

**Ref:** BCS0900


---


**Rule: BCS0701**

## Color Support

**Detect terminal capability and define colors conditionally; disable when piped.**

### Pattern

```bash
declare -i VERBOSE=1 DEBUG=0
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' NC=''
fi
```

### Key Points

- Test both stdout (`-t 1`) and stderr (`-t 2`) for TTY
- Use `$'\033[...]'` ANSI escape syntax
- Empty strings when piped â†' safe for log files
- `declare -r` prevents accidental modification

### Anti-Patterns

`echo -e "\e[31m"` â†' non-portable; `[[ -t 1 ]]` alone â†' misses stderr redirection

**Ref:** BCS0701


---


**Rule: BCS0702**

## STDOUT vs STDERR

**All error messages â†' STDERR; place `>&2` at beginning for clarity.**

```bash
>&2 echo "[$(date -Ins)]: $*"
```

Anti-pattern: `echo "error" >&2` â†' harder to spot redirection at line end.

**Ref:** BCS0702


---


**Rule: BCS0703**

## Core Message Functions

**Use private `_msg()` with `FUNCNAME[1]` inspection for auto-formatted, DRY messaging.**

**Key points:**
- `FUNCNAME[1]` detects caller â†' determines color/symbol automatically
- Conditional: `info`/`warn`/`success` respect `VERBOSE`; `error` always shows
- Errors to stderr (`>&2`); separates data from messages
- `die()` takes exit code first: `die 1 'message'`

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Anti-patterns:**
- `echo "Error: ..."` â†' Use `error` function (no prefix, wrong stream)
- Duplicate logic per function â†' Use single `_msg()` with FUNCNAME
- `error()` to stdout â†' Must use `>&2`
- `info()` ignoring VERBOSE â†' Always check: `((VERBOSE)) || return 0`

**Ref:** BCS0703


---


**Rule: BCS0704**

## Usage Documentation

**Implement `show_help()` with here-doc containing: name/version, description, usage line, options (grouped), examples.**

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [args]

Options:
  -n|--num NUM   Set num
  -v|--verbose   Verbose output
  -h|--help      This help
EOT
}
```

Anti-patterns: `echo` statements â†' use here-doc; missing `$SCRIPT_NAME`/`$VERSION` â†' use variables; ungrouped options â†' group logically

**Ref:** BCS0704


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status to stderr; use `echo` for data output to stdout.**

**Key Distinction:**
- **Messaging** â†' stderr, respects `VERBOSE`, has formatting/colors
- **echo** â†' stdout, always displays, parseable/pipeable

**Use messaging for:** status updates, diagnostics, progress, color-coded feedback
**Use echo for:** data returns, help/version, reports, parseable output

```bash
# Messaging: operational status (stderr)
info 'Processing...'
error "File not found ${file@Q}"

# Echo: data output (stdout, capturable)
get_value() { echo "$result"; }
val=$(get_value)

# Help text always uses echo/cat (not messaging)
show_help() { cat <<'EOT'
Usage: script.sh [OPTIONS]
EOT
}
```

**Anti-patterns:**

```bash
# âœ— info() for data - goes to stderr, cannot capture
get_email() { info "$email"; }

# âœ— echo for status - mixes with data in stdout
echo "Processing..."  # Use info instead

# âœ— Help via info() - hidden if VERBOSE=0
show_help() { info 'Usage: ...'; }

# âœ— Error to stdout
echo "Error: failed"  # Use: error "failed"
```

**Stream separation enables pipeline composition:** data piped/captured, status visible to user.

**Ref:** BCS0705


---


**Rule: BCS0706**

## Color Management Library

**Use dedicated color library for sophisticated color needs: two-tier system, auto-detection, `_msg` integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` â€” default, minimal namespace
- **Complete (12):** Basic + `BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE`

**Options:** `basic|complete`, `auto|always|never`, `verbose`, `flags`

**Rationale:** Namespace control via tiers; centralized definitions; `flags` initializes `VERBOSE DEBUG DRY_RUN PROMPT`

**Core Pattern:**
```bash
source color-set complete flags
info 'Starting'  # Colors + _msg ready
echo "${RED}Error:${NC} Failed"

# Auto-detect checks BOTH streams
[[ -t 1 && -t 2 ]] && color=1 || color=0
```

**Anti-patterns:**
- âŒ Scattered inline `RED=$'\033[0;31m'` in every script â†' use library
- âŒ `[[ -t 1 ]]` only â†' test both stdout AND stderr
- âŒ `color_set always` hardcoded â†' use `${COLOR_MODE:-auto}`

**Ref:** BCS0706


---


**Rule: BCS0707**

## TUI Basics

**Build terminal UI elements: spinners, progress bars, menusâ€”always with terminal detection.**

#### Core Patterns

**Spinner:** Background process with `kill "$pid"` cleanup:
```bash
spinner() {
  local -a frames=('â ‹' 'â ™' 'â ¹' 'â ¸' 'â ¼' 'â ´' 'â ¦' 'â §' 'â ‡' 'â ')
  local -i i=0
  while :; do printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"; i+=1; sleep 0.1; done
}
spinner 'Working...' & spinner_pid=$!
```

**Progress bar:** `printf '\r[%s] %3d%%' "$bar" $((cur*100/total))`

**Cursor:** `hide_cursor() { printf '\033[?25l'; }` â†' trap restore on EXIT

**Menu:** Arrow keys via escape sequences `$'\x1b'[A/B`, return selection as `$?`

#### Critical Rule

**Always check `[[ -t 1 ]]`** before TUI output â†' fall back to plain text for non-terminals.

```bash
# âœ— progress_bar 50 100  # Garbage if piped
# âœ“ [[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

**Ref:** BCS0707


---


**Rule: BCS0708**

## Terminal Capabilities

**Detect terminal features before using; provide graceful fallbacks for pipes/redirects.**

#### Why
- Prevents garbage output in non-TTY contexts
- Enables rich output when available
- Ensures cross-environment compatibility

#### Core Patterns

```bash
# TTY detection with color fallback
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with WINCH trap
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
trap 'TERM_COLS=$(tput cols 2>/dev/null || echo 80)' WINCH

# Unicode check
[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
```

#### ANSI Quick Reference

| Type | Codes |
|------|-------|
| Colors | `\033[31m` (red) `\033[32m` (green) `\033[0m` (reset) |
| Styles | `\033[1m` (bold) `\033[2m` (dim) `\033[4m` (underline) |
| Cursor | `\033[?25l` (hide) `\033[?25h` (show) |

#### Anti-Patterns

```bash
# âœ— Assumes terminal support
echo -e '\033[31mError\033[0m'

# âœ“ Conditional on TTY
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# âœ— Hardcoded width â†' âœ“ Use ${TERM_COLS:-80}
```

**Ref:** BCS0708


---


**Rule: BCS0800**

# Command-Line Arguments

**Standard argument parsing supporting short (`-h`, `-v`) and long (`--help`, `--version`) options with consistent patterns.**

**Core requirements:**
- Canonical version format: `scriptname X.Y.Z`
- Validation patterns for required arguments and option conflicts
- Placement: main function (complex scripts) vs top-level (simple scripts)
- Predictable, user-friendly interfaces for interactive and automated usage

**Ref:** BCS1000


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all CLI argument parsing.**

### Core Pattern

```bash
while (($#)); do case $1 in
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;
  -o|--output)    noarg "$@"; shift; output=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -[Vhov]*)       #shellcheck disable=SC2046
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

### Essential Helper

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

### Key Rationale

- `(($#))` more efficient than `[[ $# -gt 0 ]]`
- `case` more readable than if/elif chains
- Short bundling: `-vvv` â†' `VERBOSE=3`

### Anti-Patterns

```bash
# âœ— Missing shift â†' infinite loop
esac; done

# âœ— Missing noarg â†' fails silently
-o|--output) shift; output=$1 ;;

# âœ“ Correct
esac; shift; done
-o|--output) noarg "$@"; shift; output=$1 ;;
```

**Ref:** BCS0801


---


**Rule: BCS0802**

## Version Output Format

**Output `<script_name> <version_number>` with space separator â€” no "version" word.**

```bash
# âœ“ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# âœ— Wrong
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Why:** GNU standards; consistent with Unix utilities.

**Ref:** BCS0802


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and have correct types before processing.**

### Core Validators

```bash
# Basic existence check
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }

# String validation with safe quoting
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

# Numeric validation
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

### Usage Pattern

```bash
while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
esac; shift; done
```

**Critical:** Call validator BEFORE `shift` â€” validator inspects `$2`.

### Validator Selection

| Validator | Use Case |
|-----------|----------|
| `noarg()` | Simple existence check |
| `arg2()` | String args, prevent `-` prefix |
| `arg_num()` | Numeric integers only |

### Anti-Patterns

```bash
# âœ— No validation â†' --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT="$1" ;;

# âœ“ Validated
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
```

**`${1@Q}` pattern:** Safe shell quoting prevents expansion of special characters in error messages.

**Ref:** BCS0803


---


**Rule: BCS0804**

## Argument Parsing Location

**Place argument parsing inside `main()` for testability and scoping.**

### Rationale
- Testability: call `main` with synthetic args
- Scoping: parsing vars stay local to `main()`

### Pattern

```bash
main() {
  while (($#)); do
    case $1 in
      --prefix) shift; PREFIX=$1 ;;
      -h|--help) show_help; exit 0 ;;
      -*) die 22 "Invalid option ${1@Q}" ;;
    esac
    shift
  done
  # main logic
}
main "$@"
```

### Anti-Pattern

Top-level parsing in scripts >200 lines â†' harder to test, pollutes global scope.

**Ref:** BCS0804


---


**Rule: BCS0805**

## Short-Option Disaggregation

**Split bundled options (`-abc` â†' `-a -b -c`) for Unix-compliant CLI parsing.**

## Methods (Performance)

| Method | Speed | Dependencies |
|--------|-------|--------------|
| grep | ~190/s | External, SC2046 |
| fold | ~195/s | External, SC2046 |
| **Pure Bash** | **~318/s** | **None** |

## Pure Bash (Recommended)

```bash
-[ovnVh]*)  # Split bundled options
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```

## grep/fold Alternative

```bash
-[ovnVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

## Critical Rules

1. List valid options in pattern: `-[ovnVh]*`
2. Options with arguments â†' end of bundle or separate
3. Place before `-*)` invalid option case

## Anti-Patterns

```bash
# âœ— Option with arg in middle of bundle
./script -von out.txt  # -o captures 'n' as argument!

# âœ“ Correct placement
./script -vno out.txt  # -n -o out.txt
```

**Ref:** BCS0805


---


**Rule: BCS0900**

# File Operations

**Safe file handling to prevent data loss and handle edge cases reliably.**

**Core Requirements:**
- Always quote variables in file tests: `[[ -f "$file" ]]` never `[[ -f $file ]]`
- Use explicit paths for wildcards: `rm ./*` never `rm *` (prevents accidental root deletion)
- Use `< <(command)` process substitution instead of pipes to `while` loops (avoids subshell variable loss)
- File test operators: `-e` (exists), `-f` (regular file), `-d` (directory), `-r` (readable), `-w` (writable), `-x` (executable)

**Anti-Patterns:**
- `rm *` ’ Expands to `rm /` if run in empty directory with `nullglob`
- `cat file | while read line` ’ Variables modified in loop are lost (subshell)
- `[[ -f $file ]]` ’ Breaks with filenames containing spaces or special chars

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


**Rule: BCS0901**

## Safe File Testing

**Always quote variables and use `[[ ]]` for all file tests.**

**Key operators:** `-f` (file), `-d` (dir), `-r` (readable), `-w` (writable), `-x` (executable), `-s` (non-empty), `-e` (exists), `-L` (symlink), `-nt`/`-ot` (newer/older than), `-ef` (same inode).

**Core pattern:**
```bash
[[ -f "$file" && -r "$file" ]] || die 3 "Cannot read ${file@Q}"
[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ "$src" -nt "$dst" ]] && cp "$src" "$dst"
```

**Rationale:** Quoting prevents word splitting/glob expansion; `[[ ]]` safer than `[ ]`; test-before-use prevents runtime errors.

**Anti-patterns:**
- `[[ -f $file ]]` â†' `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` â†' `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` without test â†' validate first with `|| die`

**Ref:** BCS0901


---


**Rule: BCS0902**

## Wildcard Expansion

**Always use explicit `./*` path prefix for wildcard operations.**

Prevents filenames starting with `-` from being interpreted as command flags.

```bash
rm -v ./*                    # âœ“ Safe
for f in ./*.txt; do         # âœ“ Safe
# rm -v *                    # âœ— -file.txt becomes flag
```

**Ref:** BCS0902


---


**Rule: BCS0903**

## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to eliminate temp files, avoid subshell scope issues, and enable parallel processing.**

**Why:** No temp file cleanup; preserves variable scope (unlike pipes); multiple substitutions run in parallel; efficient FIFO/fd streaming.

**Core patterns:**

```bash
# Compare command outputs
diff <(sort file1) <(sort file2)

# Array from command (avoids subshell)
readarray -t arr < <(cmd)

# While loop preserving scope
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(cat file)
echo "$count"  # Correct!

# Parallel output processing
cat log | tee >(grep ERR > e.log) >(wc -l > n.txt) >/dev/null
```

**Anti-patterns:**

```bash
# âœ— Pipe to while (subshell loses vars)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# âœ— Temp files for diff
sort f1 > /tmp/a; sort f2 > /tmp/b; diff /tmp/a /tmp/b

# âœ— Unquoted variables inside substitution
diff <(sort $file1) <(sort $file2)

# âœ— Overcomplicated - use here-string
cmd < <(echo "$var")  # â†' cmd <<< "$var"
```

**When NOT to use:** Simple `result=$(cmd)` or `grep pat file` â€” don't overcomplicate.

**Ref:** BCS0903


---


**Rule: BCS0904**

## Here Documents

**Use heredocs for multi-line strings or input to commands.**

### Syntax

| Delimiter | Expansion |
|-----------|-----------|
| `<<'EOF'` | No variable expansion (literal) |
| `<<EOF` | Variables expand (`$USER`, `$HOME`) |

### Example

```bash
# Literal (quoted delimiter)
cat <<'EOF'
$USER stays literal
EOF

# Expanded (unquoted delimiter)
cat <<EOF
User: $USER
EOF
```

**Ref:** BCS0904


---


**Rule: BCS0905**

## Input Redirection vs Cat

**Replace `cat file` with `< file` redirection to eliminate process fork overhead (3-107x speedup).**

### Key Patterns

| Context | Speedup | Technique |
|---------|---------|-----------|
| Command substitution | **107x** | `$(< file)` |
| Single file to command | **3-4x** | `cmd < file` |
| Loops | **cumulative** | Avoid repeated forks |

### Core Example

```bash
# âœ“ CORRECT - 107x faster (zero processes)
content=$(< config.json)
errors=$(grep -c ERROR < "$logfile")

# âœ— AVOID - forks cat process each time
content=$(cat config.json)
errors=$(cat "$logfile" | grep -c ERROR)
```

### When `cat` is Required

- **Multiple files**: `cat file1 file2` (syntax requirement)
- **cat options**: `-n`, `-b`, `-A`, `-E` (no redirection equivalent)
- **Direct output**: `< file` alone produces nothing

### Anti-Patterns

```bash
# âœ— Does nothing - no command to consume stdin
< /tmp/test.txt

# âœ— Invalid syntax
< file1.txt file2.txt
```

### Why It Works

`$(< file)` is Bash magic: shell reads file directly into substitution result with zero external processes. Regular `< file` only opens file descriptorâ€”requires a command to consume it.

**Ref:** BCS0905


---


**Rule: BCS1000**

# Security Considerations

**Security-first practices for production bash scripts covering privilege controls, PATH validation, field separator safety, eval dangers, and input sanitization to prevent privilege escalation, command injection, path traversal, and other attack vectors.**

**Core mandates**: Never SUID/SGID on bash scripts (inherent race conditions, predictable temp files, signal vulnerabilities); lock down PATH or validate explicitly (prevents command hijacking); understand IFS word-splitting risks; avoid `eval` unless justified (injection vector); sanitize all user input early (regex validation, whitelisting).

**Ref:** BCS1200


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scriptsâ€”no exceptions.**

```bash
# âœ— NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID

# âœ“ Use sudo instead
sudo /usr/local/bin/script.sh
```

**Why prohibited:**
- **IFS exploitation**: Attacker controls word splitting with elevated privileges
- **PATH attack**: Kernel uses caller's PATH to find interpreterâ€”trojan injection before script's PATH is set
- **LD_PRELOAD**: Malicious libraries execute with root privileges before script runs
- **Race conditions**: TOCTOU vulnerabilities in file operations

**Safe alternatives:**
- `sudo` with `/etc/sudoers.d/` granular permissions
- Compiled C wrapper that sanitizes environment
- systemd service with `User=root`
- Linux capabilities for compiled binaries

**Anti-patterns:**
- `chmod 4755 script.sh` â†' catastrophic security hole
- Assuming modern kernels ignore SUID on scripts â†' many Unix variants honor it

**Audit:** `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`

**Ref:** BCS1001


---


**Rule: BCS1002**

## PATH Security

**Lock PATH immediately after `set -euo pipefail` to prevent command hijacking attacks.**

**Why:** Attacker-controlled directories allow trojan binaries; `.`, `::`, or `/tmp` in PATH enable current-directory/world-writable attacks; inherited PATH may be malicious.

**Correct pattern:**

```bash
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Validation if inherited PATH needed:**

```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Anti-patterns:**

- `# No PATH setting` â†' inherits unsafe environment
- `PATH=.:$PATH` â†' current directory hijacking
- `PATH=/tmp:$PATH` â†' world-writable directory
- `PATH=/home/user/bin:$PATH` â†' user-controlled
- `PATH=/usr/bin::/bin` â†' `::` equals current dir
- Setting PATH late â†' commands before it are unsafe

**Critical:** Use `readonly PATH` to prevent modification. For maximum security, use absolute paths: `/bin/tar`, `/bin/rm`.

**Ref:** BCS1002


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust inherited IFS; always protect IFS changes to prevent field splitting attacks.**

**Why:** Attackers manipulate IFS to exploit word splitting â†' command injection, privilege escalation, bypass validation.

**Safe Patterns:**

```bash
# Pattern 1: One-line (preferred for single commands)
IFS=',' read -ra fields <<< "$csv_data"

# Pattern 2: Local IFS in function
local -- IFS; IFS=','
read -ra fields <<< "$data"

# Pattern 3: Script start protection
IFS=$' \t\n'; readonly IFS; export IFS
```

**Anti-patterns:**

```bash
# âœ— Global modification without restore
IFS=','
read -ra fields <<< "$data"
# IFS stays ',' for rest of script!

# âœ— Trusting inherited IFS
#!/bin/bash
read -ra parts <<< "$input"  # Attacker controls IFS!
```

**Key Rules:**
- Set `IFS=$' \t\n'; readonly IFS` at script start
- Use `IFS='x' read` for single operations (auto-resets)
- Use `local -- IFS` in functions for scoped changes
- Use subshells `( IFS=','; ... )` for isolation

**Ref:** BCS1003


---


**Rule: BCS1004**

## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirelyâ€”safer alternatives exist for all use cases.**

### Why It Matters
- Code injection: arbitrary command execution with full script privileges
- Bypasses all validation via metacharacters; impossible to audit
- Double expansion enables attacks: `eval "echo $var"` executes `$(whoami)` in `var`

### Safe Alternatives

| Need | Use Instead |
|------|-------------|
| Dynamic commands | Arrays: `cmd=(find -name "*.txt"); "${cmd[@]}"` |
| Variable indirection | `${!var_name}` or `printf -v "$var" '%s' "$val"` |
| Dynamic data | Associative arrays: `declare -A data; data[$key]=$val` |
| Function dispatch | Case or array lookup: `"${actions[$action]}"` |

### Core Pattern
```bash
# âœ— NEVER - eval with user input
eval "$user_cmd"

# âœ“ Safe - array-based command construction
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# âœ“ Safe - indirect expansion for variable access
echo "${!var_name}"
```

### Anti-Patterns
- `eval "$var_name='$value'"` â†' use `printf -v "$var_name" '%s' "$value"`
- `eval "echo $$var_name"` â†' use `echo "${!var_name}"`

**Ref:** BCS1004


---


**Rule: BCS1005**

## Input Sanitization

**Always validate and sanitize user input before processing.**

**Rationale:** Prevents injection attacks, directory traversal (`../../../etc/passwd`), and type mismatches. Defense in depthâ€”never trust user input.

**Core Patternâ€”Filename Validation:**

```bash
sanitize_filename() {
  local -- name=$1
  [[ -n "$name" ]] || die 22 'Filename cannot be empty'
  name="${name//\.\./}"; name="${name//\//}"  # Strip traversal
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}
```

**Injection Prevention:**

```bash
# Option injection - always use -- separator
rm -- "$user_file"    # âœ“ Safe
rm "$user_file"       # âœ— Dangerous if file="-rf /"

# Command injection - whitelist, never eval
case "$cmd" in start|stop) systemctl "$cmd" app ;; esac  # âœ“
eval "$user_cmd"      # âœ— NEVER with user input
```

**Validation Types:** Integer (`^-?[0-9]+$`), path (realpath + directory check), email (`^[a-zA-Z0-9._%+-]+@...`), whitelist (array membership).

**Anti-Patterns:**

- `rm -rf "$user_dir"` without validation â†' validate_path first
- Blacklist approach (`!= *rm*`) â†' whitelist regex instead
- Trusting "looks safe" input â†' always validate type/format/range/length

**Security Principles:** Whitelist over blacklist; validate early; fail securely; use `--` separator; avoid `eval`; principle of least privilege.

**Ref:** BCS1005


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` for temp files/dirs with EXIT trap cleanupâ€”never hard-code paths.**

**Rationale:** Secure permissions (0600/0700), unique names prevent collisions, atomic creation prevents races, EXIT trap guarantees cleanup on failure/interrupt.

**Core pattern:**

```bash
declare -a TEMP_FILES=()
cleanup() {
  local -- f; for f in "${TEMP_FILES[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"
    [[ -d "$f" ]] && rm -rf "$f"
  done
}
trap cleanup EXIT

temp=$(mktemp) || die 1 'Failed to create temp file'
TEMP_FILES+=("$temp")
```

**Anti-patterns:**

```bash
# âœ— Hard-coded path (collisions, predictable, no cleanup)
temp=/tmp/myapp_temp.txt

# âœ— PID-based (still predictable, race conditions)
temp=/tmp/myapp_$$.txt

# âœ— Multiple traps overwrite (temp1 leaked!)
trap 'rm -f "$temp1"' EXIT
trap 'rm -f "$temp2"' EXIT

# âœ— No error check
temp=$(mktemp)  # May fail silently

# âœ“ Correct
temp=$(mktemp) || die 1 'Failed'
trap 'rm -f "$temp"' EXIT
```

**Key rules:**
- `mktemp -d` for directories â†' `rm -rf` in trap
- Check success: `|| die`
- Single cleanup function for multiple temps
- Template: `mktemp /tmp/name.XXXXXX` (min 3 X's)
- Trap signals too: `trap cleanup EXIT SIGINT SIGTERM`

**Ref:** BCS1006


---


**Rule: BCS1100**

# Concurrency & Jobs

**Parallel execution, background jobs, and robust waiting for Bash 5.2+.**

## Rules

| Code | Rule | Focus |
|------|------|-------|
| BCS1101 | Background Jobs | `&`, process groups, cleanup |
| BCS1102 | Parallel Execution | Concurrent tasks, output capture |
| BCS1103 | Wait Patterns | `wait -n`, error collection |
| BCS1104 | Timeout Handling | `timeout` command, exit 124/125 |
| BCS1105 | Exponential Backoff | Retry with increasing delays |

## Core Pattern

```bash
declare -a pids=()
for item in "${items[@]}"; do
  process_item "$item" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid" || failures+=1
done
```

## Key Principles

- **Always cleanup** background jobs (trap handlers)
- **Handle partial failures** gracefully
- **Capture output** per-job when needed

**Ref:** BCS1100


---


**Rule: BCS1101**

## Background Job Management

**Always track PIDs with `$!`; use trap-based cleanup for proper process lifecycle.**

#### Core Pattern

```bash
declare -a PIDS=()
cleanup() {
  trap - SIGINT SIGTERM EXIT
  for pid in "${PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
}
trap 'cleanup' SIGINT SIGTERM EXIT

command & PIDS+=($!)
wait "${PIDS[@]}"
```

#### Key Operations

- **Start:** `cmd &` then `pid=$!`
- **Check:** `kill -0 "$pid" 2>/dev/null`
- **Wait:** `wait "$pid"` (specific) or `wait -n` (any, Bash 4.3+)

#### Anti-Patterns

- `command &` without `pid=$!` â†' cannot manage job later
- Using `$$` for background PID â†' wrong; `$$` is parent, `$!` is child

**Ref:** BCS1101


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Track PIDs with `pids+=($!)`, wait with `wait "$pid"`, limit concurrency with `wait -n` and `kill -0`.**

**Rationale:** 10-100x speedup for I/O-bound tasks; better resource utilization; ordered output via temp files.

---

#### Core Patterns

**Basic parallel with PID tracking:**
```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || true; done
```

**Concurrency limit (pool pattern):**
```bash
while ((${#pids[@]} >= max_jobs)); do
  wait -n 2>/dev/null || true
  # Prune completed PIDs with kill -0
done
```

---

#### Anti-Pattern

```bash
# âœ— Variables lost in subshell
count=0; for t in "${tasks[@]}"; do { process "$t"; count+=1; } & done
echo "$count"  # Always 0!

# âœ“ Use temp files: echo 1 >> "$temp"/count; count=$(wc -l < "$temp"/count)
```

---

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102


---


**Rule: BCS1103**

## Wait Patterns

**Synchronize background processes: capture exit codes, track failures, avoid hangs.**

---

#### Why

- Exit codes lost without `wait` capture â†' silent failures
- Unwaited processes â†' zombie/resource leaks
- `wait -n` enables first-completion processing (Bash 4.3+)

---

#### Core Patterns

```bash
# Basic: capture exit code
cmd &
wait "$!" || die 1 'Command failed'

# Multiple jobs: track failures
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors+=1))
done
((errors)) && warn "$errors jobs failed"

# Wait-any (4.3+): process as completed
while ((${#pids[@]})); do
  wait -n; code=$?
  # Update active list via kill -0
done
```

---

#### Anti-Pattern

`wait $!` without checking `$?` â†' exit code silently discarded â†' `wait "$pid" || handle_error`

---

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103


---


**Rule: BCS1104**

## Timeout Handling

**Use `timeout` command to prevent hangs; exit code 124 = timed out.**

#### Rationale
- Prevents indefinite hangs on unresponsive commands
- Avoids resource exhaustion from stuck processes
- Exit 124=timeout, 137=SIGKILL (128+9)

#### Pattern

```bash
if timeout 30 long_command; then
  success 'Completed'
else
  local -i ec=$?
  ((ec == 124)) && warn 'Timed out' || error "Failed: $ec"
fi

# Graceful: SIGTERM then SIGKILL
timeout --signal=TERM --kill-after=10 60 command

# Read with timeout
read -r -t 10 -p 'Value: ' val || val='default'
```

#### Anti-Pattern

`ssh "$server" cmd` â†' `timeout 300 ssh -o ConnectTimeout=10 "$server" cmd`

**Ref:** BCS1104


---


**Rule: BCS1105**

## Exponential Backoff

**Implement retry logic with exponential delay (`2^attempt`) for transient failures; add jitter to prevent thundering herd.**

#### Rationale
- Reduces load on failing services vs fixed-delay retry
- Automatic recovery without manual intervention

#### Pattern

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5} attempt=1
  shift
  while ((attempt <= max_attempts)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    attempt+=1
  done
  return 1
}
```

**With jitter:** `delay=$((base_delay + RANDOM % base_delay))`

**With cap:** `((delay > max_delay)) && delay=$max_delay`

#### Anti-Patterns

```bash
# âœ— Fixed delay â†' same load pressure
while ! cmd; do sleep 5; done

# âœ“ Exponential backoff
retry_with_backoff 5 curl -f "$url"
```

`while ! curl "$url"; do :; done` â†' Immediate retry floods service

**Ref:** BCS1105


---


**Rule: BCS1200**

# Style & Development

**Consistent formatting and documentation make scripts maintainable by humans and AI.**

## 10 Rules

| Code | Rule | Focus |
|------|------|-------|
| BCS1201 | Code Formatting | Indentation, line length |
| BCS1202 | Comments | Style, placement |
| BCS1203 | Blank Lines | Readability whitespace |
| BCS1204 | Section Markers | Visual delimiters |
| BCS1205 | Language Practices | Bash idioms |
| BCS1206 | Development Practices | VCS, testing |
| BCS1207 | Debugging | Debug output, tracing |
| BCS1208 | Dry-Run Mode | Safe destructive previews |
| BCS1209 | Testing | Structure, assertions |
| BCS1210 | Progressive State | Multi-stage tracking |

**Ref:** BCS12


---


**Rule: BCS1201**

## Code Formatting

**Use 2-space indentation (never tabs); keep lines â‰¤100 chars (URLs/paths exempt).**

### Core Rules
- 2 spaces per indent level, consistent throughout
- Line continuation: `\` for long commands
- Long paths/URLs may exceed limit

### Anti-patterns
`TAB` indentation â†' 2 spaces | Lines >100 chars without justification â†' wrap or split

**Ref:** BCS1201


---


**Rule: BCS1202**

## Comments

**Explain WHY (rationale, decisions) not WHAT (code already shows).**

```bash
# âœ“ WHY - explains rationale
# PROFILE_DIR hardcoded for system-wide bash profile integration
declare -- PROFILE_DIR=/etc/profile.d
((max_depth > 0)) || max_depth=255  # -1 means unlimited

# âœ— WHAT - restates code
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good:** Business rules, intentional deviations, complex logic rationale, gotchas â†' **Avoid:** Obvious code, self-explanatory names

**Icons:** `â—‰` info | `â¦¿` debug | `â–²` warn | `âœ“` success | `âœ—` error

**Ref:** BCS1202


---


**Rule: BCS1203**

## Blank Line Usage

**Use single blank lines to separate logical blocks; never use multiple consecutive blanks.**

### Guidelines

- One blank between functions, logical sections, variable groups
- One blank after section comments
- Blanks before/after multi-line conditionals/loops
- No blank needed between short related statements

### Pattern

```bash
declare -r VERSION=1.0.0
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
                                          # â† After metadata group
# Default values                          # â† Before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # â† Before function
check_prerequisites() {
  info 'Checking...'
                                          # â† Between logical blocks
  if ! command -v gcc &>/dev/null; then
    die 1 'gcc not found'
  fi
}
                                          # â† Between functions
main() {
  check_prerequisites
}
```

### Anti-Patterns

- `âœ—` Multiple consecutive blank lines â†' `âœ“` Single blank sufficient
- `âœ—` No separation between unrelated blocks â†' `âœ“` Add visual breaks

**Ref:** BCS1203


---


**Rule: BCS1204**

## Section Comments

**Use simple `# Description` comments to organize code into logical groups.**

### Format
- `# Short description` (2-4 words, no dashes/boxes)
- Place immediately before group; blank line after group
- Reserve 80-dash separators for major divisions only

### Example
```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin

# Conditional messaging
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
```

### Common Patterns
`# Default values` | `# Derived paths` | `# Helper functions` | `# Business logic` | `# Validation`

**Anti-pattern:** Heavy box-drawing or 80-dash separators for minor groupings â†' use simple `# Label` instead.

**Ref:** BCS1204


---


**Rule: BCS1205**

## Language Best Practices

**Use `$()` for command substitution; prefer builtins over external commands (10-100x faster).**

### Command Substitution
Always `$()` â†' never backticks. Nests naturally without escaping.

```bash
outer=$(echo "inner: $(date +%T)")   # âœ“ Clean nesting
outer=`echo "inner: \`date +%T\`"`   # âœ— Requires escaping
```

### Builtins vs External Commands

| External | Builtin | Example |
|----------|---------|---------|
| `expr` | `$(())` | `$((x + y))` |
| `basename` | `${var##*/}` | `${path##*/}` |
| `dirname` | `${var%/*}` | `${path%/*}` |
| `tr` (case) | `${var^^}` `${var,,}` | `${str,,}` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` |
| `seq` | `{1..10}` | Brace expansion |

```bash
# âœ“ Builtin - instant (no process creation)
result=$((i * 2))
string=${var,,}

# âœ— External - spawns process each call
result=$(expr $i \* 2)
string=$(echo "$var" | tr A-Z a-z)
```

**Use external only when no builtin exists:** `sha256sum`, `sort`, `whoami`.

### Anti-patterns
- `` `command` `` â†' `$(command)`
- `[ -f "$file" ]` â†' `[[ -f "$file" ]]`
- `$(expr $x + $y)` â†' `$((x + y))`

**Ref:** BCS1205


---


**Rule: BCS1206**

## Development Practices

**ShellCheck is compulsory; document all `disable=` directives with rationale. End scripts with `#fin` marker.**

### Core Patterns

```bash
#shellcheck disable=SC2046  # Intentional word splitting
shellcheck -x myscript.sh   # Run during development

: "${VERBOSE:=0}"           # Default critical vars
[[ -n "$1" ]] || die 1 'Argument required'
set -u                      # Guard unset variables

main "$@"
#fin
```

### Performance & Testing

- Minimize subshells; prefer builtins over external commands
- Use process substitution over temp files
- Return meaningful exit codes; support debug modes

`undocumented disable=` â†' silent violations | missing `#fin` â†' incomplete script

**Ref:** BCS1206


---


**Rule: BCS1207**

## Debugging

**Enable debug mode via environment variable with `set -x` trace and enhanced PS4.**

```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
```

**Why:** PS4 shows file:line:function for trace output â†' `DEBUG=1 ./script.sh`

**Anti-pattern:** Hardcoded debug flags â†' use environment variable

**Ref:** BCS1207


---


**Rule: BCS1208**

## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `DRY_RUN` flag with early-return pattern.**

### Implementation

```bash
declare -i DRY_RUN=0
-n|--dry-run) DRY_RUN=1 ;;

deploy() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would deploy to' "$TARGET"
    return 0
  fi
  rsync -av "$SRC" "$TARGET"/
}
```

### Pattern

1. Check `((DRY_RUN))` at function start
2. Display `[DRY-RUN]` prefixed message via `info`
3. `return 0` without performing operations
4. Real operations only when flag is 0

### Key Points

- **Same control flow** â†' identical function calls in both modes
- **Safe preview** â†' verify paths/commands before execution
- **Debug installs** â†' essential for system modification scripts

**Anti-pattern:** Scattering dry-run checks throughout code â†' use function-level guards instead.

**Ref:** BCS1208


---


**Rule: BCS1209**

## Testing Support Patterns

**Make scripts testable via dependency injection and test mode flags.**

### Why
- Enables mocking external commands without modifying production code
- Isolates destructive operations during testing
- Provides consistent test infrastructure across scripts

### Pattern

```bash
# Dependency injection - define if not exists
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"

if ((TEST_MODE)); then
  DATA_DIR=./test_data
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR=/var/lib/app
  RM_CMD() { rm "$@"; }
fi
```

### Anti-Patterns

- `find "$@"` directly â†' cannot mock; use `FIND_CMD "$@"`
- Hardcoded paths â†' use conditional `DATA_DIR` based on `TEST_MODE`

### Test Infrastructure

```bash
assert() {
  local -- expected=$1 actual=$2 message=${3:-Assertion failed}
  [[ "$expected" = "$actual" ]] && return 0
  >&2 echo "FAIL: $message - expected '$expected', got '$actual'"
  return 1
}

run_tests() {
  local -i passed=0 failed=0
  for f in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    "$f" && passed+=1 || failed+=1
  done
  ((failed == 0))
}
```

**Ref:** BCS1209


---


**Rule: BCS1210**

## Progressive State Management

**Manage state via boolean flags modified by runtime conditions; separate decisions from execution.**

### Pattern

1. Declare flags at top with defaults
2. Parse args â†' set flags from user input
3. Progressively adjust based on: dependencies, failures, overrides
4. Execute actions from final flag state

```bash
declare -i INSTALL_FEAT=0 FEAT_REQUESTED=0 SKIP_FEAT=0

# Parse phase
case $1 in --feat) INSTALL_FEAT=1; FEAT_REQUESTED=1 ;; esac

# Validation phase - progressively disable
((SKIP_FEAT)) && INSTALL_FEAT=0
check_deps || { ((FEAT_REQUESTED)) && try_install || INSTALL_FEAT=0; }
((INSTALL_FEAT)) && ! build_feat && INSTALL_FEAT=0

# Execution phase - act on final state
((INSTALL_FEAT)) && install_feat
```

### Key Points

- Separate intent flag (`FEAT_REQUESTED`) from state flag (`INSTALL_FEAT`)
- Never modify flags during execution phase
- State changes in order: parse â†' validate â†' execute

### Anti-Patterns

- `if ((INSTALL_FEAT)); then install_feat; INSTALL_FEAT=0; fi` â†' modifying flags during execution
- Single flag for both user intent and runtime state â†' loses why vs. what distinction

**Ref:** BCS1210
#fin
