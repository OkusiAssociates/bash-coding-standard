**Rule: BCS00**

# Bash Coding Standard

**Bash 5.2+ coding standard for systems engineering.**

## Principles
- **K.I.S.S.** — Keep It Simple, Stupid
- No over-engineering; remove unused functions/variables

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

**Mandatory 13-step structural layout for all Bash scripts ensuring consistency, maintainability, and safe initialization.**

Covers: shebang → metadata → shopt → dual-purpose patterns → FHS compliance → file extensions → bottom-up function organization (utilities before orchestration).

**Ref:** BCS0100


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality template demonstrating all 13 mandatory BCS0101 layout steps in a realistic installation script.**

---

## Key Rationale

1. **Proven integration** — Shows all 13 steps working together in production code
2. **Copy-paste foundation** — Ready template reduces errors vs building from scratch

## Minimal Example (Core Pattern)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0 SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -i DRY_RUN=0 VERBOSE=1

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help) echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      -*) echo "Invalid: $1" >&2; exit 22 ;;
    esac; shift
  done
  readonly DRY_RUN VERBOSE
  # Business logic here
}
main "$@"
#fin
```

## Critical Patterns

- **Dry-run mode**: Every operation checks flag before executing
- **Progressive readonly**: Variables immutable after arg parsing
- **Derived paths**: Update dependent paths when PREFIX changes → `update_derived_paths()`

## Anti-Patterns

- ✗ Skipping `#fin` marker → breaks integrity verification
- ✗ Missing `readonly` after parsing → allows accidental modification

**Ref:** BCS010101


---


**Rule: BCS010102**

### Layout Anti-Patterns

**Avoid these 8 critical violations of BCS0101 13-step layout that cause silent failures and maintenance nightmares.**

#### Critical Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Missing `set -euo pipefail` | Silent failures, partial execution | Place immediately after shebang |
| Variables after use | Unbound variable errors with `-u` | Declare all globals before `main()` |
| Business logic before utilities | Forward-reference confusion | Define `die()`, `error()` first |
| No `main()` (>200 lines) | Untestable, scattered logic | Centralize entry point |
| Missing `#fin` | Truncation undetectable | Always end with marker |
| Premature `readonly` | Can't modify during arg parsing | `readonly` after parsing completes |
| Scattered declarations | State variables hard to find | Group all globals together |
| Unprotected sourcing | Modifies caller's shell | Guard with `[[ "${BASH_SOURCE[0]}" == "$0" ]]` |

#### Correct Minimal Layout

```bash
#!/usr/bin/env bash
set -euo pipefail
declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # mutable until parsed

die() { (($# < 2)) || >&2 echo "ERROR: ${*:2}"; exit "${1:-0}"; }

main() {
  [[ "${1:-}" == --prefix ]] && { shift; PREFIX=$1; shift; }
  readonly -- PREFIX
}
main "$@"
#fin
```

#### Dual-Purpose Guard

```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Standard 13-step layout may be modified for specific use cases.**

#### When to Skip `main()`

**Scripts <200 lines** can run directly without `main()` wrapper.

#### Sourced Libraries

**Library files** skip `set -e` (affects caller), `main()`, and execution block—only define functions.

#### Legitimate Extensions

- **External config**: Source between metadata and business logic; make readonly after
- **Platform detection**: Add platform-specific globals after standard globals
- **Cleanup traps**: Set trap after cleanup function, before temp file creation

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a TEMP_FILES=()
cleanup() {
  for file in "${TEMP_FILES[@]}"; do
    [[ ! -f "$file" ]] || rm -f "$file"
  done
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

#### Key Principles

Even when deviating: safety first (`set -euo pipefail`), dependencies before usage, document why.

**Anti-patterns:**
- `✗` Functions before `set -e` → errors in functions go uncaught
- `✗` Globals scattered between functions → unpredictable state

**Ref:** BCS010103


---


**Rule: BCS0101**

## Script Layout

**Follow 13-step bottom-up structure: shebang → shellcheck → description → `set -euo pipefail` → shopt → metadata → globals → colors → utilities → business logic → main() → invocation → #fin**

**Rationale:** Bottom-up ordering ensures dependencies defined before use; `set -euo pipefail` MUST precede all commands.

```bash
#!/bin/bash
#shellcheck disable=SC2155
# Brief description
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -i VERBOSE=0 DRY_RUN=0
info() { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; }
die() { (($#<2)) || >&2 echo "$SCRIPT_NAME: ${*:2}"; exit "${1:-1}"; }
main() {
  while (($#)); do
    case $1 in
      -v) VERBOSE=1 ;; -n) DRY_RUN=1 ;;
      -h) echo "Usage: $SCRIPT_NAME [-v] [-n]"; return 0 ;;
      *) die 22 "Unknown: $1" ;;
    esac; shift
  done
  info "Running..."
}
main "$@"
#fin
```

**Anti-pattern:** Missing `set -euo pipefail` or placing it after commands.

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts

**Scripts working as both executables and source libraries must apply `set -euo pipefail` and `shopt` ONLY when executed directly, never when sourced.**

**Rationale:** Sourcing applies settings to caller's shell, breaking its error handling/glob behavior.

**Pattern (early return):**
```bash
#!/bin/bash
my_function() {
  local -- arg="$1"
  echo "Processing: $arg"
}
declare -fx my_function

# Stop here when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable mode only
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
```

**Key rules:**
- Functions defined BEFORE source detection → available in both modes
- `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` → early exit when sourced
- Use `return` (not `exit`) for errors in sourced code
- Guard metadata: `[[ ! -v VAR ]]` for idempotent re-sourcing

**Anti-patterns:**
- `set -e` at top of sourceable script → breaks caller's shell
- Using `exit` instead of `return` when sourced → terminates caller

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**Every script starts: shebang → optional shellcheck → description → `set -euo pipefail`.**

**Shebangs:** `#!/bin/bash` (standard) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (max portability)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Why:** `set -euo pipefail` must be first command—enables strict error handling before any execution.

**Anti-pattern:** Any command before `set -euo pipefail` → errors may go undetected.

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after `shopt`, before any other code.**

**Rationale:** Reliable path resolution via `realpath`; consistent resource location; immutable prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:** VERSION=semantic version → SCRIPT_PATH=`realpath -- "$0"` → SCRIPT_DIR=`${SCRIPT_PATH%/*}` → SCRIPT_NAME=`${SCRIPT_PATH##*/}`

**Anti-patterns:**
- `SCRIPT_PATH="$0"` → use `realpath -- "$0"`
- `SCRIPT_DIR=$(dirname "$0")` → use `${SCRIPT_PATH%/*}`
- `SCRIPT_DIR=$PWD` → PWD is cwd, not script location
- Declaring metadata late in script → declare after shopt

**Edge cases:** Root dir (`SCRIPT_DIR` empty) → check/default to `/`. Sourced scripts → use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103


---


**Rule: BCS0104**

## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search resources—enables predictable locations, package manager compatibility, and multi-environment support.**

**Rationale:** Predictability (standard paths); portability across distros; no hardcoded paths.

**Key Locations:**
- `/usr/local/bin|share|lib|etc/` – Local installs
- `/usr/bin|share/` – System (package manager)
- `$HOME/.local/bin|share/` – User installs
- `${XDG_CONFIG_HOME:-$HOME/.config}/` – User config

**FHS Search Pattern:**
```bash
find_resource() {
  local -a paths=(
    "$SCRIPT_DIR"/"$1"                    # Development
    /usr/local/share/myapp/"$1"           # Local install
    /usr/share/myapp/"$1"                 # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$1"
  )
  local p; for p in "${paths[@]}"; do
    [[ -f "$p" ]] && { echo "$p"; return 0; } ||:
  done; return 1
}
```

**PREFIX Pattern:** `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

**Anti-patterns:**
- `source /usr/local/lib/app/x.sh` → Use FHS search function
- `BIN_DIR=/usr/local/bin` (hardcoded) → Use `PREFIX=${PREFIX:-/usr/local}`
- Overwriting user config → Check `[[ -f config ]] ||` before install

**When NOT to use:** Single-user scripts, project-specific tools, containers.

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt

**Configure shell options for robust error handling and glob behavior.**

### Recommended Settings

```bash
shopt -s inherit_errexit  # CRITICAL: set -e works in $() subshells
shopt -s shift_verbose    # Catches shift errors
shopt -s extglob          # Extended patterns: !(*.txt), @(jpg|png)
shopt -s nullglob         # Unmatched glob → empty (for loops/arrays)
# OR: shopt -s failglob   # Unmatched glob → error (strict scripts)
```

### Critical Rationale

1. **inherit_errexit**: Without it, `result=$(false)` silently succeeds—errors in command substitutions don't propagate
2. **nullglob/failglob**: Default bash passes literal `*.txt` to commands when no match—causes silent failures or wrong file operations

### Anti-Patterns

- `for f in *.txt` without nullglob → iterates with literal `*.txt` if no matches
- Relying on `set -e` in subshells without `inherit_errexit` → errors silently ignored

### Typical Configuration

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Use `.sh` for libraries (non-executable); no extension for PATH-available executables.**

### Rules
- **Executables**: `.sh` or no extension
- **Libraries**: `.sh` required, not executable
- **Global PATH commands**: no extension

### Quick Reference
| Type | Extension | Executable |
|------|-----------|------------|
| Library | `.sh` | No |
| Local script | `.sh` | Yes |
| PATH command | none | Yes |

### Anti-patterns
- `mylib` without `.sh` → confuses library/executable distinction
- `mytool.sh` in PATH → inconsistent with Unix conventions

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: primitives first → composition layers → `main()` last. Eliminates forward references; dependencies flow downward only.**

### Rationale
- **No forward references**: Bash reads top-to-bottom; called functions must exist before use
- **Debugging**: Read top-down to understand dependencies immediately
- **Maintainability**: Clear hierarchy shows where to add new functions

### 7-Layer Pattern

```bash
# 1. Messaging (lowest): _msg(), info(), warn(), error(), die()
# 2. Helpers: noarg(), trim()
# 3. Documentation: show_help(), show_version()
# 4. Validation: check_root(), check_prerequisites()
# 5. Business logic: build_project(), process_file()
# 6. Orchestration: run_build_phase(), cleanup()
# 7. main() - calls all layers

main() { check_deps; build; deploy; }
main "$@"
#fin
```

### Anti-Patterns

```bash
# ✗ main() at top (forward refs)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✓ main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Circular deps (A→B→A) → extract common logic to lower layer
```

### Key Rules
- Higher functions call lower functions only
- Group with section comments per layer
- Within layers: alphabetical or by execution order
- Private functions (`_name`) stay with their public wrappers

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Use explicit `declare` for type safety and predictable behavior.**

Type hints: `declare -i` (integer), `declare --` (string), `declare -a` (array), `declare -A` (associative). Use `readonly` for constants. Naming: `UPPER_CASE` constants, `lower_case` variables. Scope with `local` in functions.

```bash
declare -i count=0          # Integer arithmetic
readonly VERSION="1.0"      # Immutable constant
local -i result             # Function-scoped integer
declare -a items=()         # Indexed array
```

**Anti-patterns:** Untyped `var=val` → type coercion bugs; missing `local` → global pollution.

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) for type safety and intent clarity.**

### Rationale
- Integer `-i` enforces numeric ops, catches non-numeric → 0
- Array declarations prevent accidental scalar overwrites
- `--` separator prevents option injection if name starts with `-`

### Declaration Types

| Type | Syntax | Use Case |
|------|--------|----------|
| Integer | `declare -i` | counters, ports, exit codes |
| String | `declare --` | paths, text, user input |
| Indexed array | `declare -a` | lists, sequences |
| Assoc array | `declare -A` | key-value maps (Bash 4.0+) |
| Readonly | `declare -r` | constants |
| Local | `local --` | function-scoped vars |

### Example

```bash
declare -i count=0
declare -- filename=data.txt
declare -a files=()
declare -A config=([port]=8080)
declare -r VERSION=1.0.0

process() {
  local -- input=$1
  local -i attempts=0
  local -a results=()
}
```

### Anti-Patterns

```bash
# ✗ No declaration → intent unclear
count=0

# ✓ Explicit type
declare -i count=0

# ✗ Missing -A → creates indexed array
declare CONFIG; CONFIG[key]=val

# ✓ Explicit associative
declare -A CONFIG=(); CONFIG[key]=val

# ✗ Global leak in function
func() { temp=$1; }

# ✓ Local scope
func() { local -- temp=$1; }
```

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function variables with `local` to prevent namespace pollution.**

Globals at script top with `declare`; function vars with `local -a`, `local -i`, `local --`.

```bash
main() {
  local -a items=()    # Local array
  local -i count=0     # Local integer
  local -- path        # Local string
}
```

**Why:** Without `local`, variables overwrite globals, persist after return, break recursion.

**Anti-pattern:** `file=$1` → `local -- file=$1`

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use case-based naming to distinguish scope: UPPER_CASE for constants/globals, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Local variables | lower_case | `local file_count=0` |
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

**Rationale:** UPPER_CASE globals visible at script-wide scope; lower_case locals prevent shadowing; underscore prefix signals internal use.

**Anti-patterns:** `PATH`, `HOME`, `USER` as variable names → conflicts with shell; single-letter lowercase → reserved.

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly`/`declare -r` for immutable values; `export`/`declare -x` for subprocess inheritance.**

### Core Pattern

```bash
declare -r VERSION=1.0.0              # Constant (immutable)
declare -ri MAX_RETRIES=3             # Readonly integer
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Exported (child processes)
declare -rx BUILD_ENV=production      # Both: readonly + exported
```

### Key Differences

| Feature | `readonly` | `export` |
|---------|------------|----------|
| Prevents modification | ✓ | ✗ |
| Available in subprocesses | ✗ | ✓ |

### Rationale

- `readonly` prevents accidental modification of true constants
- `export` only for values child processes actually need
- Combine `-rx` when subprocess needs immutable config

### Anti-patterns

```bash
# ✗ Exporting internal constants
export MAX_RETRIES=3
# ✓ readonly -- MAX_RETRIES=3

# ✗ Readonly before allowing override
readonly -- OUTPUT_DIR="$HOME"/out
# ✓ OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/out}; readonly -- OUTPUT_DIR
```

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables with values first, then make all readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; groups related constants visibly; explicit immutability contract.

**Three-Step Pattern** (for args/runtime config):
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
# 2. Modify in main() during parsing
# 3. Make readonly AFTER parsing
readonly -- VERBOSE DRY_RUN
```

**Standard Groups:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors/Paths/Config**: Use readonly-after-group

**Minimal Example:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Anti-patterns:**
- `readonly -- X` before all values set → inconsistent protection
- Missing `--` separator → option injection risk
- Mixing unrelated variables in same readonly group

**Key:** Always use `--` separator. Make readonly as soon as values are final.

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

Anti-pattern: `CONST=value` → mutable, can be overwritten accidentally.

**Ref:** BCS0206


---


**Rule: BCS0207**

### Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Why
- Element boundaries preserved regardless of content (spaces, globs)
- Safe command construction with arbitrary arguments

#### Declaration & Usage
```bash
declare -a arr=()              # Empty indexed array
declare -A map=()              # Associative (Bash 4.0+)
arr+=("$item")                 # Append
for x in "${arr[@]}"; do       # Iterate (MUST quote)
readarray -t arr < <(cmd)      # From command output
"${cmd[@]}"                    # Execute array as command
```

#### Anti-Patterns
```bash
# ✗ Unquoted → word splitting
rm ${files[@]}
# ✓ Quoted
rm "${files[@]}"

# ✗ Word split to array
arr=($string)
# ✓ Use readarray
readarray -t arr <<< "$string"
```

#### Quick Reference
| Op | Syntax |
|----|--------|
| Length | `${#arr[@]}` |
| Last | `${arr[-1]}` |
| Slice | `${arr[@]:2:3}` |

**Ref:** BCS0207


---


**Rule: BCS0208**

### Reserved for Future Use

**Placeholder for future variable-related topics** (nameref, indirect expansion, typed variables).

Do not use BCS0208 in documentation or compliance checking.

**Status:** Reserved

**Ref:** BCS0208


---


**Rule: BCS0209**

## Derived Variables

**Compute variables from base values; group with section comments; update all derived variables when base changes during argument parsing.**

### Rationale
- **DRY**: Single source of truth—change PREFIX, all paths update
- **Correctness**: Forgetting to update derived vars after base change causes subtle bugs
- **Maintainability**: Section comments clarify dependency chains

### Pattern

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived paths (from PREFIX)
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"

# Update function for argument parsing
update_paths() {
  BIN_DIR="$PREFIX"/bin
  CONFIG_DIR=/etc/"$APP_NAME"
}

# In main(): after --prefix changes PREFIX, call update_paths
# Make readonly AFTER all parsing complete
readonly -- PREFIX APP_NAME BIN_DIR CONFIG_DIR
```

### Anti-Patterns

```bash
# ✗ Duplicating instead of deriving
BIN_DIR=/usr/local/bin  # Hardcoded, not "$PREFIX"/bin

# ✗ Not updating derived vars when base changes
--prefix) PREFIX=$1 ;;  # BIN_DIR now stale!

# ✗ Making derived readonly before parsing
readonly BIN_DIR="$PREFIX"/bin  # Can't update later!
```

### Key Points
- Group derived vars with `# Derived from PREFIX` comments
- Use `update_derived_paths()` function when many variables
- XDG fallbacks: `${XDG_CONFIG_HOME:-"$HOME"/.config}`
- Document hardcoded exceptions (e.g., `/etc/profile.d` always fixed)

**Ref:** BCS0209


---


**Rule: BCS0210**

### Parameter Expansion & Braces

**Use `"$var"` by default; only use `"${var}"` when syntactically required.**

#### Braces Required

- **Expansion ops:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Concatenation (no separator):** `"${var}suffix"` `"${a}${b}"`
- **Arrays:** `"${arr[@]}"` `"${#arr[@]}"`
- **Special:** `"${@:2}"` `"${10}"` `"${!var}"`

#### No Braces Needed

Standalone or with separators: `"$var"` `"$HOME/bin"` `"$PREFIX"/lib`

#### Key Expansions

```bash
${var##*/}              # Remove longest prefix
${var%/*}               # Remove shortest suffix
${var:-default}         # Default if unset/null
${var//old/new}         # Replace all
${var,,}  ${var^^}      # Lower/upper case
```

#### Anti-patterns

- `"${var}"` when `"$var"` suffices → visual noise
- `"${PREFIX}/bin"` → separator already delimits

**Ref:** BCS0210


---


**Rule: BCS0211**

## Boolean Flags

**Use `declare -i` integers (0/1) for boolean state; test with `(())`.**

### Pattern

```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && echo 'dry-run' ||:
if ((VERBOSE)); then log_debug; fi
```

### Rules

- `declare -i`/`local -i` for all flags
- Initialize explicitly: `=0` (false) or `=1` (true)
- ALL_CAPS naming (`DRY_RUN`, `SKIP_BUILD`)
- Test: `((FLAG))` → true if non-zero

### Anti-patterns

- `if [ "$flag" = "true" ]` → use `((flag))`
- Uninitialized flags → always init to 0/1

**Ref:** BCS0211


---


**Rule: BCS0300**

# Strings & Quoting

**Single quotes for literals, double quotes for expansion.**

## Rules (7)

| Rule | Focus |
|------|-------|
| BCS0301 | Static `'...'` vs dynamic `"..."` |
| BCS0302 | Quote `$(cmd)` results |
| BCS0303 | Variables in `[[ ]]` |
| BCS0304 | Heredoc delimiter quoting |
| BCS0305 | printf format strings |
| BCS0306 | `${param@Q}` safe display |
| BCS0307 | Common quoting mistakes |

## Core Pattern

```bash
readonly STATIC='no expansion'
msg="Hello, ${name}"
result="$(cmd)"  # Always quote
```

## Anti-Patterns

```bash
# WRONG → CORRECT
file=$path      → file="$path"
$(cat file)     → "$(cat file)"
```

**Ref:** BCS0300


---


**Rule: BCS0301**

### Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: Variable expansion required
- **Mixed**: `"Option '$1' invalid"` — literal display with variable
- **One-word exception**: Simple alphanumeric (`a-zA-Z0-9_-.`) may be unquoted

```bash
info 'Static message'           # Single: no expansion
info "Found $count files"       # Double: expansion needed
die 1 "Unknown option '$1'"     # Mixed: literal quotes shown
STATUS=success                  # Unquoted: simple alphanumeric
EMAIL='user@domain.com'         # Quoted: special char @
```

#### Path Concatenation

Prefer separate quoting for clarity:
```bash
"$PREFIX"/bin                   # Variable quoted separately
"$dir"/"$file"                  # Clear variable boundaries
```

#### Anti-Patterns

- `info "Static..."` �' `info 'Static...'` (use single for static)
- `EMAIL=user@domain.com` �' `EMAIL='user@domain.com'` (quote special chars)
- `PATTERN=*.log` �' `PATTERN='*.log'` (quote globs)

**Ref:** BCS0301


---


**Rule: BCS0302**

### Command Substitution

**Quote `$()` in strings; omit quotes for simple assignment; always quote when using result.**

#### Rules

- **In strings:** `echo "Time: $(date)"` — double quotes required
- **Simple assignment:** `VAR=$(cmd)` — no quotes needed
- **Concatenation:** `VAR="$(cmd)".suffix` — quotes required
- **Usage:** `echo "$VAR"` — always quote to prevent word splitting

#### Example

```bash
# Assignment (no quotes needed)
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')

# Concatenation (quotes required)
VERSION="$(git describe --tags)".beta

# Usage (always quote)
echo "$VERSION"
```

#### Anti-patterns

- `VERSION="$(cmd)"` �' unnecessary quotes on simple assignment
- `echo $result` �' word splitting occurs without quotes

**Ref:** BCS0302


---


**Rule: BCS0303**

### Quoting in Conditionals

**Always quote variables in conditionals.** Unquoted �' word splitting, glob expansion, empty-value errors, injection risk.

```bash
# Variables always quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]

# Pattern/regex: pattern UNQUOTED
[[ "$file" == *.txt ]]           # Glob match
[[ "$input" =~ $pattern ]]       # Regex (quoting makes literal)
```

**Anti-patterns:** `[[ -f $file ]]` �' breaks on spaces/globs; `[[ "$x" =~ "$pattern" ]]` �' pattern treated as literal.

**Ref:** BCS0303


---


**Rule: BCS0304**

### Here Documents

**Quote delimiter (`<<'EOF'`) to prevent expansion; unquoted (`<<EOF`) for variable substitution.**

#### Delimiter Quoting

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

#### Examples

```bash
# Expansion enabled
cat <<EOF
User: $USER
EOF

# Literal content (no expansion)
cat <<'EOF'
{"name": "$VAR"}
EOF
```

#### Anti-Pattern

```bash
# ✗ Unquoted �' SQL injection risk
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0304


---


**Rule: BCS0305**

### printf Patterns

**Single-quote format strings, double-quote variable arguments; prefer printf over echo -e.**

#### Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format: single, vars: double
echo 'Static text'                         # No vars: single quotes
printf '%s\n' "$var"                       # %s=string %d=int %f=float %%=literal
```

#### Anti-patterns

- `echo -e "...\n..."` �' Use `printf '...\n...\n'` or `$'...\n...'` (echo -e behavior varies)
- `printf "$fmt"` �' Format strings must be single-quoted (security, escapes)

**Ref:** BCS0305


---


**Rule: BCS0306**

### Parameter Quoting with @Q

**`${param@Q}` produces shell-quoted output safe for display—prevents injection in error messages and logs.**

#### Core Behavior

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | literal | `'*.txt'` |

#### Usage Pattern

```bash
# Error messages - safe display of untrusted input
die 2 "Unknown option ${1@Q}"
info "Processing ${file@Q}"

# Dry-run - quote array for display
printf -v quoted '%s ' "${cmd[@]@Q}"
```

#### When to Use

- **Use @Q:** Error messages, logging user input, dry-run display
- **Don't use:** Normal expansion (`"$file"`), comparisons

#### Anti-Patterns

```bash
# ✗ Injection risk
die 2 "Unknown option $1"

# ✓ Safe
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0306


---


**Rule: BCS0307**

### Quoting Anti-Patterns

**Single quotes for static text, double quotes for variables, avoid unnecessary braces.**

#### Critical Anti-Patterns

| Wrong | Correct | Why |
|-------|---------|-----|
| `"literal"` | `'literal'` | Static strings need single quotes |
| `$var` | `"$var"` | Prevents word splitting/glob expansion |
| `"${HOME}/bin"` | `"$HOME"/bin` | Braces only when needed |
| `${arr[@]}` | `"${arr[@]}"` | Arrays require quotes |

#### When Braces ARE Required

```bash
"${var:-default}"    # Default value
"${file##*/}"        # Parameter expansion
"${array[@]}"        # Array expansion
"${var1}${var2}"     # Adjacent variables
```

#### Glob Danger

```bash
pattern='*.txt'
echo $pattern    # ✗ Expands to all .txt files!
echo "$pattern"  # ✓ Outputs literal: *.txt
```

#### Here-doc: Quote Delimiter for Literals

```bash
# ✗ Variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted delimiter prevents expansion
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0307


---


**Rule: BCS0400**

# Functions

**Define functions with `lowercase_underscores`, use `main()` for scripts >200 lines, organize bottom-up (messaging→helpers→logic→main).**

## Key Rules
- `declare -fx func_name` for exported library functions
- Remove unused utility functions in production scripts
- Bottom-up order ensures functions call only previously-defined functions

## Pattern
```bash
msg() { printf '%s\n' "$1"; }
validate_input() { [[ -n "$1" ]] || return 1; }
process_data() { validate_input "$1" && msg "Processing"; }
main() { process_data "$@"; }
main "$@"
```

## Anti-Patterns
- `myFunc` → use `my_func`
- Calling functions before definition
- Keeping unused utility functions in production

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

**Anti-pattern:** `local file="$1"` �' `local -- file="$1"` (always use `--` separator)

**Ref:** BCS0401


---


**Rule: BCS0402**

## Function Names

**Use lowercase_with_underscores; prefix private functions with `_`.**

### Core Pattern

```bash
process_log_file() { … }     # ✓ Public
_validate_input() { … }      # ✓ Private (internal)
```

### Why

- Matches Unix conventions (`grep`, `sed`)
- Avoids conflicts with built-ins (all lowercase)
- `_prefix` signals internal-only use

### Anti-Patterns

```bash
MyFunction() { … }           # ✗ CamelCase
PROCESS_FILE() { … }         # ✗ UPPER_CASE
my-function() { … }          # ✗ Dashes cause issues
cd() { builtin cd "$@"; }    # ✗ Overriding built-in
```

�' Wrap built-ins with different name: `change_dir()` not `cd()`

**Ref:** BCS0402


---


**Rule: BCS0403**

## Main Function

**Use `main()` for scripts >200 lines as single entry point; place `main "$@"` at bottom before `#fin`.**

**Rationale:** Single entry point for testability; functions can be sourced without execution; centralized exit code handling.

**When to use:** >200 lines, multiple functions, argument parsing, complex logic. Skip for trivial scripts <200 lines.

**Structure:**
```bash
#!/bin/bash
set -euo pipefail

helper_function() { : ...; }

main() {
  local -i verbose=0
  while (($#)); do case $1 in
    -v) verbose=1 ;; -h) show_help; return 0 ;;
    *) die 22 "Invalid: ${1@Q}" ;;
  esac; shift; done
  readonly -- verbose
  return 0
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
main "$@"
#fin
```

**Anti-patterns:**
- `main` without `"$@"` �' args not passed
- Parsing args outside main �' consumed before main runs
- Functions defined after `main "$@"` �' not available during execution

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

Anti-pattern: `export -f func` �' use `declare -fx func` instead (consistent with BCS declaration style).

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
# ✗ Shipping unused utilities
declare -- PROMPT='> '    # Never used
debug() { :; }            # Never called
```

**Ref:** BCS0405


---


**Rule: BCS0406**

### Dual-Purpose Scripts

**Rule:** Scripts executable directly OR sourceable as libraries using `BASH_SOURCE[0]` check.

**Key:** `set -e` MUST come AFTER source check—library code must not impose error handling on caller.

**Rationale:** Reusable functions without duplication; testing flexibility (source functions independently).

#### Pattern

```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "${arg@Q}"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail
main() { my_func "$@"; }
main "$@"
```

**Idempotent:** Use `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION=1.0.0` to prevent double-init.

#### Anti-Patterns

`my_func() { :; }` without `declare -fx` �' cannot call from subshells after sourcing.

`set -euo pipefail` before source check �' risky `return 0` behavior.

**See Also:** BCS0607 (Library Patterns), BCS0604 (Function Export)

**Ref:** BCS0406


---


**Rule: BCS0407**

### Library Patterns

**Rule: BCS0407**

**Libraries must prevent direct execution and define functions without side effects.**

#### Rationale
- Code reuse across scripts with consistent interfaces
- Namespace isolation prevents function collisions
- Easier testing via explicit initialization

#### Pattern

```bash
#!/usr/bin/env bash
# lib-validation.sh - Source only

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: Must be sourced, not executed'; exit 1
}

declare -rx LIB_VALIDATION_VERSION=1.0.0

valid_email() {
  [[ $1 =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
declare -fx valid_email
```

#### Sourcing

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR"/lib-validation.sh

# With check
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing ${lib_path@Q}"
```

#### Anti-Patterns

- `source lib.sh` with immediate side effects �' Define functions only, use `lib_init` for initialization
- Unprefixed functions �' Use namespace prefix: `myapp_init`, `myapp_cleanup`

**Ref:** BCS0407


---


**Rule: BCS0408**

### Dependency Management

**Use `command -v` to verify external dependencies exist before use, with clear error messages.**

#### Rationale
- Clear errors for missing tools vs cryptic failures
- Enables graceful degradation with optional deps
- Documents script requirements explicitly

#### Dependency Check

```bash
# Single/multiple checks
command -v curl >/dev/null || die 1 'curl required'

for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && result=$(jq -r '.f' <<<"$json")
```

#### Version Check

```bash
((BASH_VERSINFO[0] < 5)) && die 1 "Requires Bash 5+"
```

#### Anti-Patterns

- `which curl` �' `command -v curl` (POSIX compliant)
- Silent `curl "$url"` �' Check first with helpful message

**Ref:** BCS0408


---


**Rule: BCS0500**

# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic, process substitution over pipes to while loops.**

## Core Rules

- `[[ ]]` not `[ ]` for conditionals (safer, more features)
- `(( ))` for arithmetic tests
- `< <(cmd)` not `cmd | while` (avoids subshell variable loss)
- Safe increment: `i+=1` or `((++i))` → `((i++))` fails at i=0 with `set -e`

## Example

```bash
while IFS= read -r line; do
    ((count++)) || true
done < <(find . -name "*.sh")
[[ $count -gt 0 ]] && echo "Found: $count"
```

## Anti-Patterns

- `cmd | while read` → variables lost after loop
- `((i++))` with `set -e` → exits when i=0

**Ref:** BCS0500


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

### Why `[[ ]]` over `[ ]`
- No word splitting/glob expansion on variables
- Pattern matching (`==`, `=~`) and logical ops (`&&`, `||`) inside
- `<`/`>` for lexicographic comparison

### Core Pattern
```bash
[[ -f "$file" ]] && source "$file" ||:
((count > MAX)) && die 1 'Limit exceeded' ||:
[[ -n "$var" ]] && ((count)) && process_data
[[ "$str" =~ ^[0-9]+$ ]] && echo "Number"
```

### Key Operators
**File:** `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` exec, `-s` non-empty
**String:** `-z` empty, `-n` non-empty, `==` equal, `=~` regex
**Arithmetic:** `>`, `>=`, `<`, `<=`, `==`, `!=`

### Anti-patterns
```bash
# ✗ Old [ ] syntax �' use [[ ]]
[ -f "$file" -a -r "$file" ]  # Deprecated -a/-o
# ✓ [[ -f "$file" && -r "$file" ]]

# ✗ Arithmetic with [[ ]] �' use (())
[[ "$count" -gt 10 ]]
# ✓ ((count > 10))
```

**Ref:** BCS0501


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way pattern matching; prefer over if/elif chains for single-variable tests. Always include `*)` default case.**

**Rationale:** Pattern matching with wildcards/alternation �' single evaluation (faster than if/elif) �' clearer visual structure with column alignment.

**Formats:**
- **Compact:** Single actions on same line, align `;;` at consistent column
- **Expanded:** Multi-line logic, `;;` on separate line with blank line after

**Core example:**

```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Pattern syntax:** Literal `start)` �' Wildcard `*.txt)` �' Alternation `-v|--verbose)` �' Extglob `@(a|b)` (requires `shopt -s extglob`)

**Anti-patterns:**

```bash
# ✗ Missing default case
case "$action" in start) ;; stop) ;; esac  # Silent failure on unknown

# ✗ Use if/elif when testing multiple variables or numeric ranges
if [[ "$a" && "$b" ]]; then ...  # Not: nested case statements
```

**Key rules:** Quote test variable `case "$var"` �' Don't quote patterns `start)` not `"start")` �' Always `;;` terminator �' Use if for complex/multi-var logic.

**Ref:** BCS0502


---


**Rule: BCS0503**

## Loops

**Use `for` for arrays/globs/ranges, `while` for input streams/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

### Key Patterns

**For loops:** `for item in "${array[@]}"` | `for file in *.txt` | `for ((i=0; i<n; i+=1))`

**While input:** `while IFS= read -r line; do ... done < file` or `< <(command)`

**Infinite:** `while ((1))` (fastest) �' `while :` (POSIX) �' avoid `while true` (15-22% slower)

**Arg parsing:** `while (($#)); do case $1 in ... esac; shift; done`

### Core Example

```bash
local -- file
local -i count=0

# Process command output (preserves variable scope)
while IFS= read -r -d '' file; do
  [[ -f "$file" ]] || continue
  count+=1
done < <(find . -name '*.sh' -print0)

echo "Processed $count files"
```

### Critical Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `for f in $(ls *.txt)` | `for f in *.txt` |
| `cat file \| while read` | `while read < file` or `< <(cat)` |
| `for x in ${array[@]}` | `for x in "${array[@]}"` |
| `for ((i=0;i<n;i++))` | `for ((i=0;i<n;i+=1))` |
| `while (($# > 0))` | `while (($#))` |
| `local x` inside loop | declare locals before loop |

### Essential Rules

- Enable `nullglob` for glob loops (empty match = zero iterations)
- Use `break 2` for nested loop exit (explicit level)
- Use `IFS= read -r` always (preserves whitespace/backslashes)
- Declare loop variables before loop, not inside

**Ref:** BCS0503


---


**Rule: BCS0504**

## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variable assignments are lost. Use `< <(command)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshell for while body �' variable modifications discarded on exit �' counters=0, arrays=empty, no errors shown.

### Rationale

- Variables modified in pipe subshell don't persist to parent
- Silent failure—script runs but produces wrong values
- Process substitution runs loop in current shell, preserving state

### Solutions

**Process substitution** (most common):
```bash
while IFS= read -r line; do
  count+=1
done < <(command)
```

**readarray** (collecting lines):
```bash
readarray -t lines < <(command)
```

**Here-string** (variable input):
```bash
while IFS= read -r line; do
  count+=1
done <<< "$input"
```

### Anti-Patterns

```bash
# ✗ Pipe loses state
cmd | while read -r x; do arr+=("$x"); done
echo "${#arr[@]}"  # 0!

# ✓ Process substitution preserves state
while read -r x; do arr+=("$x"); done < <(cmd)
```

### Edge Cases

- **Large files**: `readarray` loads all into RAM; while loop streams line-by-line
- **Null-delimited**: Use `read -r -d ''` and `find -print0`

**Ref:** BCS0504


---


**Rule: BCS0505**

## Arithmetic Operations

**Use `declare -i` for integers, `(())` for comparisons, and `i+=1` for increments.**

### Core Rules

- **Declare integers**: `declare -i count=0` — enables auto-arithmetic, type safety
- **Increment**: `i+=1` ONLY �' requires `declare -i`; `((i++))` exits with `set -e` when i=0
- **Comparisons**: Use `(())` not `[[ -eq ]]` �' `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` — non-zero is truthy

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
# ✗ NEVER - exits with set -e when i=0
((i++))

# ✗ Verbose/old-style
[[ "$count" -gt 10 ]]

# ✓ Correct
((count > 10))
i+=1
```

### Why `((i++))` Fails

```bash
set -e; i=0
((i++))  # Returns 0 (old value) = "false" �' script exits!
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

### Floating-Point Operations

**Use `bc` or `awk` for float math; Bash only supports integers natively.**

#### Rationale
- Bash `$(())` truncates decimals �' data loss
- `bc -l` provides arbitrary precision; `awk` handles inline ops
- Float string comparison (`[[ "$a" > "$b" ]]`) gives wrong results

#### Core Patterns

```bash
# bc: precision calculation
result=$(echo "$width * $height" | bc -l)

# awk: formatted output with variables
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# Float comparison (bc returns 1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then
  echo "$a is greater"
fi
```

#### Anti-Patterns

`result=$((10/3))` �' returns 3, not 3.333 �' use `echo '10/3' | bc -l`

`[[ "$a" > "$b" ]]` �' string comparison �' use `(($(echo "$a > $b" | bc -l)))`

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506


---


**Rule: BCS0600**

# Error Handling

**Configure `set -euo pipefail` + `shopt -s inherit_errexit` before any commands to catch failures early.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures → Never leave unchecked commands in pipelines.

**Ref:** BCS0600


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
# ✗ Exits before check (set -e triggers on substitution)
result=$(failing_cmd)
[[ -n "$result" ]] && echo "$result"

# ✓ Conditional protects from exit
if result=$(failing_cmd); then echo "$result"; fi
```

**Anti-patterns:** Leaving flags disabled longer than necessary �' re-enable immediately after risky operation.

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
- `exit 1` for all errors �' Use specific codes
- Codes 64+ �' Reserved for system use

**Ref:** BCS0602


---


**Rule: BCS0603**

## Trap Handling

**Use cleanup functions with trap to ensure resources are released on exit, signals, or errors.**

### Core Pattern

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Key Signals

| Signal | Trigger |
|--------|---------|
| `EXIT` | Any script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |

### Critical Rules

1. **Set trap BEFORE creating resources** → prevents leaks if script exits early
2. **Disable trap in cleanup** → `trap - SIGINT SIGTERM EXIT` prevents recursion
3. **Preserve exit code** → `trap 'cleanup $?'` captures original status
4. **Single quotes** → `trap 'rm "$f"'` delays expansion; double quotes expand immediately

### Anti-Patterns

```bash
trap 'rm -f "$f"; exit 0' EXIT      # ✗ Always exits 0
trap "rm -f $file" EXIT             # ✗ Expands $file now, not at trap time
temp=$(mktemp); trap 'cleanup' EXIT # ✗ Resource before trap → leak risk
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values explicitly—`set -e` misses pipelines, command substitution, and conditionals.**

**Rationale:** Explicit checks enable contextual errors, controlled recovery, and catch failures `set -e` misses.

**`set -e` limitations:** Pipelines (except last), conditionals, command substitution in assignments.

**Patterns:**

```bash
# || die pattern
mv "$f" "$d/" || die 1 "Failed to move ${f@Q}"

# || block for cleanup
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Check command substitution
out=$(cmd) || die 1 "cmd failed"

# PIPESTATUS for pipelines
cat f | grep x; ((PIPESTATUS[0])) && die 1 "cat failed"
```

**Critical settings:**
```bash
set -euo pipefail
shopt -s inherit_errexit  # Subshells inherit set -e
```

**Anti-patterns:**
- `cmd1; cmd2; if (($?))` �' checks cmd2 not cmd1
- `output=$(failing_cmd)` without `|| die` �' silent failure
- Generic errors `die 1 "failed"` �' no context for debugging

**Ref:** BCS0604


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe to continue. Always document WHY.**

**Rationale:** Masks real bugs; silent failures appear successful; creates debugging nightmares.

### Safe to Suppress

- **Command/file existence checks:** `command -v tool >/dev/null 2>&1`
- **Cleanup operations:** `rm -f /tmp/app_* 2>/dev/null || true`
- **Idempotent operations:** `install -d "$dir" 2>/dev/null || true`

### NEVER Suppress

- File operations, data processing, system config, security ops, required dependencies

### Suppression Patterns

| Pattern | Use When |
|---------|----------|
| `2>/dev/null` | Hide messages, still check return |
| `|| true` | Ignore return, keep stderr |
| Both combined | Both irrelevant |

### Example

```bash
# ✓ Safe - cleanup may have nothing to do
# Rationale: Temp files may not exist
rm -f "$CACHE"/*.tmp 2>/dev/null || true

# ✗ DANGEROUS - critical operation
cp "$config" "$dest" 2>/dev/null || true

# ✓ Correct - check critical operations
cp "$config" "$dest" || die 1 "Copy failed"
```

### Anti-Patterns

```bash
# ✗ Suppress without documenting why
some_cmd 2>/dev/null || true

# ✗ Suppress entire function
process() { ...; } 2>/dev/null

# ✗ Using set +e to suppress
set +e; critical_op; set -e
```

**Key:** Every suppression is a deliberate decision—document it with a comment.

**Ref:** BCS0605


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Rationale:**
- `(())` returns exit code 1 when false �' `set -e` terminates script
- `|| :` (colon = no-op returning 0) provides safe fallback
- Traditional Unix idiom; `:` preferred over `true` (built-in, 1 char)

**Pattern:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ SAFE: continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use for:** optional declarations, conditional exports, feature-gated actions, debug output.

**Don't use for:** critical operations needing error handling �' use `if` with explicit error checks.

**Anti-patterns:**

```bash
# ✗ Missing || : - script exits on false
((flag)) && action

# ✗ Suppressing critical operations
((confirmed)) && delete_files || :  # hides failures!

# ✓ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606


---


**Rule: BCS0700**

# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: data→STDOUT, diagnostics→STDERR.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core (uses FUNCNAME) | varies |
| `error()` | Unconditional error | STDERR |
| `die()` | Exit with error | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDERR |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDERR |
| `vecho()` | Verbose output | STDERR |
| `yn()` | Yes/no prompts | STDERR |

## Key Rules

- STDERR for all diagnostics; STDOUT only for data
- Place `>&2` at command start for clarity
- Use messaging functions, not bare `echo` for status

## Example

```bash
info "Processing file"
[[ -f "$file" ]] || die "File not found: $file"
warn "Large file detected"
success "Complete"
```

## Anti-patterns

- `echo "Error"` → `error "Error"` (use functions)
- `cmd >&2` at end → `>&2 cmd` (redirection first)

**Ref:** BCS0700


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
- Empty strings when piped �' safe for log files
- `declare -r` prevents accidental modification

### Anti-Patterns

`echo -e "\e[31m"` �' non-portable; `[[ -t 1 ]]` alone �' misses stderr redirection

**Ref:** BCS0701


---


**Rule: BCS0702**

## STDOUT vs STDERR

**All error messages �' STDERR; place `>&2` at beginning for clarity.**

```bash
>&2 echo "[$(date -Ins)]: $*"
```

Anti-pattern: `echo "error" >&2` �' harder to spot redirection at line end.

**Ref:** BCS0702


---


**Rule: BCS0703**

## Core Message Functions

**Use private `_msg()` with `FUNCNAME[1]` inspection to auto-format messages; wrapper functions control verbosity and stream routing.**

### Rationale
- `FUNCNAME` auto-detects caller �' single DRY implementation
- Conditional output via `VERBOSE`/`DEBUG` flags
- Proper streams: errors�'stderr, data�'stdout (enables `data=$(./script)`)

### Core Pattern
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Wrappers
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### File Logging
```bash
# Use printf builtin (10-50x faster than $(date))
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }
```

### Anti-Patterns
- `echo "Error: ..."` �' no stderr, no prefix, no color
- `$(date ...)` in log �' subshell per call; use `printf '%()T'`
- `die() { error "$@"; exit 1; }` �' no exit code param

**Ref:** BCS0703


---


**Rule: BCS0704**

## Usage Documentation

**Every script MUST provide `show_help()` with name, version, description, options, and examples.**

### Rationale
- Self-documenting scripts reduce support burden
- Consistent format enables automated help extraction

### Required Structure
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose   Increase verbosity
  -h|--help      This help
Examples:
  $SCRIPT_NAME -v file.txt
EOT
}
```

### Anti-patterns
- `echo "Usage..."` �' Use heredoc for multiline help
- Missing `-h|--help` option

**Ref:** BCS0704


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status→stderr; plain `echo` for data output→stdout.**

**Key principles:**
- Stream separation: messaging→stderr (user-facing), echo→stdout (pipeable data)
- Verbosity: messaging respects `VERBOSE`; echo always displays
- Pipeability: only stdout data captured; stderr messages visible

**Decision:** Status/diagnostics → messaging | Data/help/reports → echo

**Core pattern:**
```bash
get_data() {
  info "Processing..."    # stderr, verbosity-controlled
  echo "$result"          # stdout, always outputs, capturable
}
data=$(get_data)          # captures only echo output
```

**Anti-patterns:**
```bash
# ✗ info() for data - goes to stderr, can't capture
get_email() { info "$email"; }
result=$(get_email)  # empty!

# ✗ echo for status - mixes with data stream
process() { echo "Starting..."; cat "$file"; }

# ✓ Correct separation
process() { info "Starting..."; cat "$file"; }
```

**Rules:** Help/version→always echo (not verbose-dependent) | Errors→always stderr | Multi-line→here-docs not multiple info()

**Ref:** BCS0705


---


**Rule: BCS0706**

## Color Management Library

**Use dedicated color library for sophisticated color needs: two-tier system, auto-detection, `_msg` integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` — default, minimal namespace
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
- ❌ Scattered inline `RED=$'\033[0;31m'` in every script �' use library
- ❌ `[[ -t 1 ]]` only �' test both stdout AND stderr
- ❌ `color_set always` hardcoded �' use `${COLOR_MODE:-auto}`

**Ref:** BCS0706


---


**Rule: BCS0707**

### TUI Basics

**Use terminal check `[[ -t 1 ]]` before TUI output; restore cursor on exit.**

#### Key Patterns

- **Spinner**: Background process with `kill`/cleanup
- **Progress bar**: `printf '\r[...]'` with `%*s | tr ' ' '█'`
- **Cursor**: Hide `\033[?25l`, show `\033[?25h`, trap EXIT
- **Clear**: Line `\033[2K\r`, screen `\033[2J\033[H`

#### Rationale

- Visual feedback for long operations
- Interactive menus improve UX

#### Example

```bash
# Progress bar with terminal check
progress_bar() {
  local -i cur=$1 tot=$2 w=50 f=$((cur*w/tot))
  printf '\r[%s%s] %3d%%' \
    "$(printf '%*s' "$f" ''|tr ' ' '█')" \
    "$(printf '%*s' $((w-f)) ''|tr ' ' '░')" \
    $((cur*100/tot))
}
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

#### Anti-Pattern

`progress_bar 50 100` without `[[ -t 1 ]]` �' garbage output to non-terminal

**Ref:** BCS0707


---


**Rule: BCS0708**

### Terminal Capabilities

**Detect terminal features with `[[ -t 1 ]]` before using colors/cursor control; provide fallbacks for pipes/redirects.**

#### Key Points
- Prevents garbage output in non-terminal contexts
- Enables graceful degradation for limited terminals
- Use `tput` for portable capability queries

#### Terminal Detection

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with fallback
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
trap 'TERM_COLS=$(tput cols 2>/dev/null || echo 80)' WINCH
```

#### Anti-Patterns

```bash
# ✗ Assuming terminal support
echo -e '\033[31mError\033[0m'  # �' garbage in pipes

# ✓ Conditional output
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# ✗ Hardcoded width �' use ${TERM_COLS:-80}
```

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708


---


**Rule: BCS0800**

# Command-Line Arguments

**Standard argument parsing supporting short (`-h`) and long (`--help`) options with consistent interfaces.**

Core requirements: canonical version format (`scriptname X.Y.Z`), validation for required args, option conflict detection, parsing placement based on complexity.

**Ref:** BCS0800


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` with `noarg` validation.**

### Core Pattern
```bash
while (($#)); do case $1 in
  -o|--output)  noarg "$@"; shift; output=$1 ;;
  -v|--verbose) VERBOSE+=1 ;;
  -V|--version) echo "$VERSION"; exit 0 ;;
  -[ovV]?*)     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            files+=("$1") ;;
esac; shift; done
```

### Key Elements
- **Loop**: `(($#))` arithmetic test (faster than `[[ $# -gt 0 ]]`)
- **Options w/args**: `noarg "$@"; shift` before capturing value
- **Flags**: Set variable, shift handled at loop end
- **Bundling**: `-[opts]?*)` pattern peels first option, `continue` restarts
- **noarg helper**: `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }`

### Anti-Patterns
- `while [[ $# -gt 0 ]]` → use `while (($#))`
- Missing `noarg` before shift → silent failure on missing arg
- Missing final `shift` → infinite loop
- `if/elif` chains → use `case` statement

**Ref:** BCS0801


---


**Rule: BCS0802**

## Version Output Format

**Output `<script_name> <version_number>` with space separator — no "version" word.**

```bash
# ✓ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Why:** GNU standards; consistent with Unix utilities.

**Ref:** BCS0802


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Validation Helpers

| Helper | Purpose | Pattern |
|--------|---------|---------|
| `noarg()` | Existence check | `(($# > 1)) && [[ ${2:0:1} != '-' ]]` |
| `arg2()` | String + safe quoting | `((${#@}-1<1)) \|\| [[ "${2:0:1}" == '-' ]]` |
| `arg_num()` | Numeric validation | `[[ ! "$2" =~ ^[0-9]+$ ]]` |

### Implementation

```bash
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric argument" ||:; }

while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
esac; shift; done
```

### Key Points

- Call validator BEFORE `shift` (needs `$2`)
- `${1@Q}` safely quotes option in error messages
- Catches `--output --verbose` (missing filename) → prevents using next option as value

### Anti-Patterns

```bash
# ✗ No validation → --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# ✗ No numeric validation → --depth abc causes later arithmetic errors
-d|--depth) shift; MAX_DEPTH=$1 ;;
```

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

Top-level parsing in scripts >200 lines �' harder to test, pollutes global scope.

**Ref:** BCS0804


---


**Rule: BCS0805**

# Short-Option Disaggregation

**Split bundled options (`-abc` → `-a -b -c`) for Unix-compliant CLI parsing.**

## Iterative Method (Recommended)

53-119x faster than alternatives (~24,000-53,000 iter/sec), pure bash, no shellcheck warnings:

```bash
-[ovnVh]?*)  # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

**Mechanism:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder; `continue` restarts loop.

## Alternatives

| Method | Speed | Notes |
|--------|-------|-------|
| grep | ~445/sec | `set -- '' $(printf '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` — requires SC2046 |
| fold | ~460/sec | Same as grep, uses `fold -w1` |
| Bash loop | ~318/sec | Verbose, no external deps |

## Critical Rules

- Options with arguments → end of bundle or separate: `-vno out.txt` ✓, `-von out.txt` ✗
- Pattern lists valid options explicitly: `-[ovnVh]?*`
- Place before `-*)` invalid option case

## Anti-Patterns

- `./script -von out.txt` → `-o` captures `n` as argument
- Missing `continue` in iterative method → infinite loop

**Ref:** BCS0805


---


**Rule: BCS0900**

# File Operations

**Safe file handling: quote tests, explicit paths for globs, process substitution for variable preservation.**

## Core Rules

- **Test operators**: `-e` (exists), `-f` (file), `-d` (dir), `-r/-w/-x` (perms) — ALWAYS quote: `[[ -f "$file" ]]`
- **Safe wildcards**: Use explicit paths `rm ./*` → never `rm *`
- **Process substitution**: `while read -r line; do ... done < <(cmd)` preserves variables (avoids subshell)
- **Here-docs**: `<<'EOF'` (no expansion) vs `<<EOF` (with expansion)

## Example

```bash
[[ -f "$config" && -r "$config" ]] && source "$config"
while read -r f; do process "$f"; done < <(find . -name "*.log")
rm -f ./*.tmp  # Safe: explicit path
```

## Anti-patterns

- `rm *` → catastrophic if in wrong dir; use `rm ./*`
- `cmd | while read` → variables lost in subshell; use `< <(cmd)`

**Ref:** BCS0900


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
- `[[ -f $file ]]` �' `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` �' `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` without test �' validate first with `|| die`

**Ref:** BCS0901


---


**Rule: BCS0902**

## Wildcard Expansion

**Always use explicit `./*` path prefix for wildcard operations.**

Prevents filenames starting with `-` from being interpreted as command flags.

```bash
rm -v ./*                    # ✓ Safe
for f in ./*.txt; do         # ✓ Safe
# rm -v *                    # ✗ -file.txt becomes flag
```

**Ref:** BCS0902


---


**Rule: BCS0903**

## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to eliminate temp files and avoid subshell variable scope issues.**

**Rationale:** No temp file cleanup; preserves variables unlike pipes; enables parallel processing.

**Core patterns:**

```bash
# Compare outputs (no temp files)
diff <(sort file1) <(sort file2)

# Avoid subshell - variables preserved
declare -i count=0
while read -r line; do ((count+=1)); done < <(cat file)
echo "$count"  # Correct!

# Populate array safely
readarray -t files < <(find /data -type f -print0)
```

**Anti-patterns:**

```bash
# ✗ Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# ✗ Temp files when process sub works
temp=$(mktemp); sort file > "$temp"; diff "$temp" other; rm "$temp"
# �' Use: diff <(sort file) other
```

**When NOT to use:** Simple cases where direct methods work:
- `result=$(command)` �' not `result=$(cat <(command))`
- `grep pat file` �' not `grep pat < <(cat file)`
- `cmd <<< "$var"` �' not `cmd < <(echo "$var")`

**Ref:** BCS0903


---


**Rule: BCS0904**

## Here Documents

**Use heredocs for multi-line strings/input; quote delimiter to prevent expansion.**

`<<'EOF'` �' literal (no expansion) | `<<EOF` �' variables expand

```bash
cat <<'EOT'
Literal $VAR text
EOT

cat <<EOT
Expanded: $USER
EOT
```

**Anti-pattern:** Using `echo` with embedded newlines �' use heredoc instead.

**Ref:** BCS0904


---


**Rule: BCS0905**

## Input Redirection vs Cat

**Use `< file` instead of `cat file` to eliminate fork overhead: 3-100x speedup.**

### Key Rules

- **Command substitution**: `$(< file)` = 100x faster than `$(cat file)` (zero forks)
- **Single input**: `grep pat < file` = 3-4x faster than `cat file | grep pat`
- **Loops**: Fork overhead multiplies; 1000 iterations = 1000 avoided forks

### When cat Required

- Multiple files: `cat file1 file2`
- Cat options needed: `-n`, `-b`, `-A`, `-E`, `-s`
- `< file` alone does nothing (needs consuming command)

### Example

```bash
# CORRECT - Fast
content=$(< "$file")
grep ERROR < "$logfile"

# AVOID - Slow (forks cat)
content=$(cat "$file")
cat "$logfile" | grep ERROR
```

### Anti-patterns

| Avoid | Use |
|-------|-----|
| `$(cat file)` | `$(< file)` |
| `cat file \| cmd` | `cmd < file` |

**Ref:** BCS0905


---


**Rule: BCS1000**

# Security Considerations

**Production bash scripts require security-first practices across five areas: SUID/SGID prohibition, PATH validation, IFS safety, eval avoidance, and input sanitization.**

## Critical Rules

- **Never** use SUID/SGID on bash scripts → privilege escalation risk
- Lock down PATH: `PATH='/usr/local/bin:/usr/bin:/bin'` or validate explicitly
- Reset IFS: `IFS=$' \t\n'` to prevent word-splitting attacks
- **Avoid eval** → command injection; requires explicit justification if unavoidable
- Sanitize input early → prevent path traversal, injection vectors

## Minimal Example

```bash
#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
readonly user_input="${1:-}"
[[ "$user_input" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 1
```

## Anti-Patterns

- `eval "$user_data"` → injection
- Trusting inherited PATH/IFS → hijacking

**Ref:** BCS1000


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—critical security prohibition, no exceptions.**

### Why Dangerous

SUID/SGID changes effective UID/GID to file owner during execution. For scripts, kernel executes interpreter with elevated privileges, then interpreter processes script—creating attack vectors:

- **IFS/PATH manipulation**: Attacker controls word splitting or substitutes malicious interpreter before script's PATH is set
- **LD_PRELOAD injection**: Malicious code runs with root privileges before script executes
- **Race conditions**: TOCTOU vulnerabilities in file operations

### Correct Approach

```bash
# ✗ NEVER
chmod u+s /usr/local/bin/myscript.sh

# ✓ Use sudo with sudoers config
sudo /usr/local/bin/myscript.sh
# /etc/sudoers.d/myapp:
# username ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh
```

### Anti-Patterns

| Wrong | Right |
|-------|-------|
| `chmod u+s script.sh` | Configure sudoers, use `sudo` |
| `chmod g+s script.sh` | Use PolicyKit, systemd service, or compiled wrapper |

### Detection

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Key principle:** If you need SUID on a script, redesign using sudo, PolicyKit, systemd, or compiled wrapper.

**Ref:** BCS1001


---


**Rule: BCS1002**

## PATH Security

**Lock down PATH at script start to prevent command hijacking and trojan injection.**

**Rationale:**
- Attacker-controlled directories allow malicious binaries to replace system commands
- Empty PATH elements (`:`, `::`, trailing `:`) resolve to current directory
- PATH inherited from caller's environment may be malicious

**Secure PATH pattern:**
```bash
#!/bin/bash
set -euo pipefail
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Validate PATH (if not resetting):**
```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|:::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Anti-patterns:**
- `# No PATH setting` �' inherits untrusted environment
- `PATH=.:$PATH` �' current directory searchable
- `PATH=/tmp:$PATH` �' world-writable dir in PATH
- `PATH=::` or leading/trailing `:` �' empty = current dir
- Setting PATH late �' commands before it use inherited PATH

**Key:** Set `readonly PATH` immediately after `set -euo pipefail`. Use absolute paths (`/bin/tar`) for critical commands as defense in depth.

**Ref:** BCS1002


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust inherited IFS; always protect IFS changes to prevent field splitting attacks.**

**Why:** Attackers manipulate IFS to exploit word splitting �' command injection, privilege escalation, bypass validation.

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
# ✗ Global modification without restore
IFS=','
read -ra fields <<< "$data"
# IFS stays ',' for rest of script!

# ✗ Trusting inherited IFS
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

**Never use `eval` with untrusted input. Avoid entirely—safer alternatives exist for all common use cases.**

### Why It Matters
- **Code injection**: `eval` executes arbitrary code with full script privileges
- **Bypasses validation**: Sanitized input can still contain exploitable metacharacters
- **Better alternatives**: Arrays, indirect expansion, associative arrays cover all use cases

### Safe Alternatives

```bash
# ✗ eval for variable indirection
eval "value=\$$var_name"
# ✓ Indirect expansion
echo "${!var_name}"

# ✗ eval for dynamic assignment
eval "$var_name='$value'"
# ✓ printf -v
printf -v "$var_name" '%s' "$value"

# ✗ eval for command building
eval "$cmd"
# ✓ Array execution
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# ✗ eval for function dispatch
eval "${action}_function"
# ✓ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns
- `eval "$user_input"` → Use whitelist case statement
- `eval "$var='$val'"` → Use `printf -v`
- `eval "echo \$$var"` → Use `${!var}`

**Key principle:** If you think you need `eval`, use arrays, indirect expansion, or associative arrays instead.

**Ref:** BCS1004


---


**Rule: BCS1005**

## Input Sanitization

**Validate/sanitize all user input to prevent injection and traversal attacks.**

### Rationale
- Prevents command injection, directory traversal (`../../../etc/passwd`)
- Enforces expected data types; rejects invalid input early

### Core Patterns

**Filename sanitization:**
```bash
sanitize_filename() {
  local -- name=$1
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}
```

**Path containment:** Use `realpath -e` �' verify path starts with allowed dir.

**Numeric:** `[[ "$input" =~ ^[0-9]+$ ]]` �' reject leading zeros for integers.

**Whitelist choices:** Loop array, match exact �' `die` if no match.

### Critical Rules
- **Always use `--`** separator: `rm -- "$file"` prevents option injection
- **Never use `eval`** with user input
- **Whitelist > blacklist**: Define allowed chars, not forbidden ones

### Anti-patterns
```bash
# ✗ Trusting input
rm -rf "$user_dir"  # user_dir="/" = disaster

# ✓ Validate first
validate_path "$user_dir" "/safe/base"; rm -rf -- "$user_dir"
```

**Ref:** BCS1005


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` for temp files/dirs; use EXIT trap for cleanup; never hard-code paths.**

**Rationale:** mktemp creates files atomically with secure permissions (0600/0700); EXIT trap guarantees cleanup on failure/interruption; prevents race conditions and file collisions.

**Pattern:**

```bash
declare -a TEMP_FILES=()
cleanup() {
  local -- f; for f in "${TEMP_FILES[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"; [[ -d "$f" ]] && rm -rf "$f"
  done
}
trap cleanup EXIT

temp=$(mktemp) || die 1 'Failed to create temp file'
TEMP_FILES+=("$temp")
```

**Anti-patterns:**

```bash
# ✗ Hard-coded path �' predictable, no cleanup
temp=/tmp/myapp.txt

# ✗ Multiple traps overwrite each other
trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT  # t1 never cleaned!

# ✓ Single cleanup function for all resources
```

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

### Background Job Management

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

- `command &` without `pid=$!` �' cannot manage job later
- Using `$$` for background PID �' wrong; `$$` is parent, `$!` is child

**Ref:** BCS1101


---


**Rule: BCS1102**

### Parallel Execution Patterns

**Execute multiple commands concurrently while tracking PIDs and collecting results.**

#### Rationale
- Significant speedup for I/O-bound tasks
- Better resource utilization

#### Basic Pattern (PID Tracking)

```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
```

#### Output Capture Pattern

Use temp files per job, cleanup via trap:
```bash
temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT
```

#### Concurrency Limit

Use `wait -n` with PID array, check `kill -0 "$pid"` to prune completed jobs.

#### Anti-Patterns

`count=0; { process; ((count++)); } &` �' subshell loses variable changes. Use temp files: `echo 1 >> "$temp"/count`, then `wc -l < "$temp"/count`.

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102


---


**Rule: BCS1103**

### Wait Patterns

**Always capture exit codes from `wait` and track failures across parallel jobs.**

#### Rationale
- Exit codes lost without capture �' silent failures
- Orphan processes consume resources
- Scripts hang on failed processes without proper tracking

#### Pattern

```bash
# Track multiple jobs with error collection
declare -a pids=()
for task in "${tasks[@]}"; do
  process_task "$task" &
  pids+=($!)
done

declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors++))
done
((errors)) && die 1 "$errors jobs failed"
```

#### Anti-Patterns

```bash
# ✗ Exit code lost
command &
wait $!

# ✓ Capture exit code
command &
wait $! || die 1 'Command failed'
```

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103


---


**Rule: BCS1104**

### Timeout Handling

**Use `timeout` command to prevent hanging on unresponsive commands; exit 124 = timeout.**

#### Rationale
- Prevents script hangs and resource exhaustion
- Critical for network operations and automated systems

#### Pattern

```bash
if timeout 30 long_running_command; then
  success 'Completed'
else
  ((exit_code=$?))
  ((exit_code == 124)) && warn 'Timed out' || error "Exit $exit_code"
fi

# Graceful kill: TERM first, KILL after grace period
timeout --signal=TERM --kill-after=10 60 command
```

**Exit codes:** 124=timeout, 125=timeout failed, 137=SIGKILL

#### Built-in Timeouts

```bash
read -r -t 10 -p 'Input: ' val          # read timeout
ssh -o ConnectTimeout=10 "$srv" cmd     # SSH timeout
curl --connect-timeout 10 --max-time 60 "$url"
```

#### Anti-Pattern

`ssh "$srv" cmd` �' `timeout 300 ssh -o ConnectTimeout=10 "$srv" cmd`

**Ref:** BCS1104


---


**Rule: BCS1105**

### Exponential Backoff

**Use exponential delay (`2^attempt`) for retry logic to handle transient failures without overwhelming services.**

#### Rationale
- Prevents thundering herd on failing services
- Enables automatic recovery from transient errors
- Configurable max attempts and delay caps

#### Pattern

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5} attempt=1
  shift
  while ((attempt <= max_attempts)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    ((++attempt))
  done
  return 1
}
```

**Enhancements:** Add `max_delay` cap; add jitter (`RANDOM % base_delay`) to prevent synchronized retries.

#### Anti-Patterns

`sleep 5` in loop �' `sleep $((2 ** attempt))` (fixed delay floods service)

`while ! cmd; do :; done` �' `retry_with_backoff 5 cmd` (immediate retry = DoS)

**Ref:** BCS1105


---


**Rule: BCS1200**

# Style & Development

**Code formatting, documentation, and development patterns for maintainable Bash.**

## Rules

| Rule | Focus |
|------|-------|
| BCS1201 | Indentation, line length, structure |
| BCS1202 | Comment style/placement |
| BCS1203 | Blank lines for readability |
| BCS1204 | Visual section delimiters |
| BCS1205 | Bash-specific idioms |
| BCS1206 | Version control, testing habits |
| BCS1207 | Debug output/tracing |
| BCS1208 | Dry-run for destructive ops |
| BCS1209 | Test structure/assertions |
| BCS1210 | Multi-stage operation tracking |

**Principle:** Consistent formatting enables maintainability by humans and AI.

**Ref:** BCS1200


---


**Rule: BCS1201**

## Code Formatting

**Use 2-space indentation (never tabs); keep lines ≤100 chars (URLs/paths exempt).**

### Core Rules
- 2 spaces per indent level, consistent throughout
- Line continuation: `\` for long commands
- Long paths/URLs may exceed limit

### Anti-patterns
`TAB` indentation �' 2 spaces | Lines >100 chars without justification �' wrap or split

**Ref:** BCS1201


---


**Rule: BCS1202**

## Comments

**Explain WHY (rationale, decisions) not WHAT (code already shows).**

```bash
# ✓ WHY - explains rationale
# PROFILE_DIR hardcoded for system-wide bash profile integration
declare -- PROFILE_DIR=/etc/profile.d
((max_depth > 0)) || max_depth=255  # -1 means unlimited

# ✗ WHAT - restates code
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good:** Business rules, intentional deviations, complex logic rationale, gotchas �' **Avoid:** Obvious code, self-explanatory names

**Icons:** `◉` info | `⦿` debug | `▲` warn | `✓` success | `✗` error

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
                                          # ← After metadata group
# Default values                          # ← Before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ← Before function
check_prerequisites() {
  info 'Checking...'
                                          # ← Between logical blocks
  if ! command -v gcc &>/dev/null; then
    die 1 'gcc not found'
  fi
}
                                          # ← Between functions
main() {
  check_prerequisites
}
```

### Anti-Patterns

- `✗` Multiple consecutive blank lines �' `✓` Single blank sufficient
- `✗` No separation between unrelated blocks �' `✓` Add visual breaks

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

**Anti-pattern:** Heavy box-drawing or 80-dash separators for minor groupings �' use simple `# Label` instead.

**Ref:** BCS1204


---


**Rule: BCS1205**

## Language Best Practices

**Use `$()` for command substitution; prefer builtins over external commands (10-100x faster).**

### Command Substitution
Always `$()` �' never backticks. Nests naturally without escaping.

```bash
outer=$(echo "inner: $(date +%T)")   # ✓ Clean nesting
outer=`echo "inner: \`date +%T\`"`   # ✗ Requires escaping
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
# ✓ Builtin - instant (no process creation)
result=$((i * 2))
string=${var,,}

# ✗ External - spawns process each call
result=$(expr $i \* 2)
string=$(echo "$var" | tr A-Z a-z)
```

**Use external only when no builtin exists:** `sha256sum`, `sort`, `whoami`.

### Anti-patterns
- `` `command` `` �' `$(command)`
- `[ -f "$file" ]` �' `[[ -f "$file" ]]`
- `$(expr $x + $y)` �' `$((x + y))`

**Ref:** BCS1205


---


**Rule: BCS1206**

## Development Practices

**ShellCheck mandatory; end scripts with `#fin`; program defensively.**

### ShellCheck
- **Compulsory** for all scripts: `shellcheck -x script.sh`
- Disable only with documented reason: `#shellcheck disable=SC2155  # reason`

### Script Termination
```bash
main "$@"
#fin
```

### Defensive Programming
```bash
: "${VERBOSE:=0}"              # Default values
[[ -n "$1" ]] || die 1 'Arg required'  # Validate early
set -u                         # Guard unset vars
```

### Performance
Minimize subshells �' use builtins over external commands �' batch ops �' process substitution over temp files.

### Testing
Testable functions, dependency injection, verbose/debug modes, meaningful exit codes.

**Ref:** BCS1206


---


**Rule: BCS1207**

## Debugging

**Use environment-controlled debug mode with enhanced trace output.**

**Rationale:** Environment variable control allows runtime debugging without code changes; enhanced PS4 provides file:line:function context.

```bash
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
```

**Anti-pattern:** Hardcoded debug flags �' use `DEBUG=${DEBUG:-0}` for runtime control.

**Ref:** BCS1207


---


**Rule: BCS1208**

## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `-n|--dry-run` flag.**

```bash
declare -i DRY_RUN=0
# Parse: -n|--dry-run) DRY_RUN=1 ;; -N|--not-dry-run) DRY_RUN=0 ;;

install_files() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' "  $BIN_DIR/app"
    return 0
  fi
  install -m 755 build/bin/app "$BIN_DIR"/
}
```

**Pattern:** Check `((DRY_RUN))` at function start → show `[DRY-RUN]` prefixed preview → `return 0` early.

**Anti-patterns:** Skipping dry-run in destructive functions → Silent dry-run (no preview output)

**Rationale:** Safe preview of destructive ops; identical control flow in both modes; users verify paths before execution.

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

- `find "$@"` directly �' cannot mock; use `FIND_CMD "$@"`
- Hardcoded paths �' use conditional `DATA_DIR` based on `TEST_MODE`

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

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

**Structure:** 1) Declare flags with defaults → 2) Parse args → 3) Adjust flags on conditions → 4) Execute on final state

**Key principles:**
- Separate user intent flags (`BUILTIN_REQUESTED`) from runtime state (`INSTALL_BUILTIN`)
- Disable features when prerequisites/builds fail (fail-safe)
- Never modify flags during execution phase

```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse: set flags from args
[[ $1 == --builtin ]] && { INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1; }

# Validate: adjust based on conditions
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0
check_support || { ((BUILTIN_REQUESTED)) && try_install || INSTALL_BUILTIN=0; }
((INSTALL_BUILTIN)) && ! build && INSTALL_BUILTIN=0

# Execute: act on final state
((INSTALL_BUILTIN)) && install_builtin
```

**Anti-patterns:**
- `if can_install && user_wants; then install; fi` → Nested conditions obscure why decisions made
- Modifying flags during execution phase → Unpredictable state

**Ref:** BCS1210


---


**Rule: BCS????**

# Bash Coding Standard

**Bash 5.2+ coding standard for systems engineering.**

## Principles
- **K.I.S.S.** — Keep It Simple, Stupid
- No over-engineering; remove unused functions/variables

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

**Mandatory 13-step structural layout for all Bash scripts ensuring consistency, maintainability, and safe initialization.**

Covers: shebang → metadata → shopt → dual-purpose patterns → FHS compliance → file extensions → bottom-up function organization (utilities before orchestration).

**Ref:** BCS0100


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality template demonstrating all 13 mandatory BCS0101 layout steps in a realistic installation script.**

---

## Key Rationale

1. **Proven integration** — Shows all 13 steps working together in production code
2. **Copy-paste foundation** — Ready template reduces errors vs building from scratch

## Minimal Example (Core Pattern)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0 SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -i DRY_RUN=0 VERBOSE=1

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help) echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      -*) echo "Invalid: $1" >&2; exit 22 ;;
    esac; shift
  done
  readonly DRY_RUN VERBOSE
  # Business logic here
}
main "$@"
#fin
```

## Critical Patterns

- **Dry-run mode**: Every operation checks flag before executing
- **Progressive readonly**: Variables immutable after arg parsing
- **Derived paths**: Update dependent paths when PREFIX changes → `update_derived_paths()`

## Anti-Patterns

- ✗ Skipping `#fin` marker → breaks integrity verification
- ✗ Missing `readonly` after parsing → allows accidental modification

**Ref:** BCS010101


---


**Rule: BCS010102**

### Layout Anti-Patterns

**Avoid these 8 critical violations of BCS0101 13-step layout that cause silent failures and maintenance nightmares.**

#### Critical Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Missing `set -euo pipefail` | Silent failures, partial execution | Place immediately after shebang |
| Variables after use | Unbound variable errors with `-u` | Declare all globals before `main()` |
| Business logic before utilities | Forward-reference confusion | Define `die()`, `error()` first |
| No `main()` (>200 lines) | Untestable, scattered logic | Centralize entry point |
| Missing `#fin` | Truncation undetectable | Always end with marker |
| Premature `readonly` | Can't modify during arg parsing | `readonly` after parsing completes |
| Scattered declarations | State variables hard to find | Group all globals together |
| Unprotected sourcing | Modifies caller's shell | Guard with `[[ "${BASH_SOURCE[0]}" == "$0" ]]` |

#### Correct Minimal Layout

```bash
#!/usr/bin/env bash
set -euo pipefail
declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # mutable until parsed

die() { (($# < 2)) || >&2 echo "ERROR: ${*:2}"; exit "${1:-0}"; }

main() {
  [[ "${1:-}" == --prefix ]] && { shift; PREFIX=$1; shift; }
  readonly -- PREFIX
}
main "$@"
#fin
```

#### Dual-Purpose Guard

```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Standard 13-step layout may be modified for specific use cases.**

#### When to Skip `main()`

**Scripts <200 lines** can run directly without `main()` wrapper.

#### Sourced Libraries

**Library files** skip `set -e` (affects caller), `main()`, and execution block—only define functions.

#### Legitimate Extensions

- **External config**: Source between metadata and business logic; make readonly after
- **Platform detection**: Add platform-specific globals after standard globals
- **Cleanup traps**: Set trap after cleanup function, before temp file creation

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a TEMP_FILES=()
cleanup() {
  for file in "${TEMP_FILES[@]}"; do
    [[ ! -f "$file" ]] || rm -f "$file"
  done
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

#### Key Principles

Even when deviating: safety first (`set -euo pipefail`), dependencies before usage, document why.

**Anti-patterns:**
- `✗` Functions before `set -e` → errors in functions go uncaught
- `✗` Globals scattered between functions → unpredictable state

**Ref:** BCS010103


---


**Rule: BCS0101**

## Script Layout

**Follow 13-step bottom-up structure: shebang → shellcheck → description → `set -euo pipefail` → shopt → metadata → globals → colors → utilities → business logic → main() → invocation → #fin**

**Rationale:** Bottom-up ordering ensures dependencies defined before use; `set -euo pipefail` MUST precede all commands.

```bash
#!/bin/bash
#shellcheck disable=SC2155
# Brief description
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -i VERBOSE=0 DRY_RUN=0
info() { ((VERBOSE)) && >&2 echo "$SCRIPT_NAME: $*"; }
die() { (($#<2)) || >&2 echo "$SCRIPT_NAME: ${*:2}"; exit "${1:-1}"; }
main() {
  while (($#)); do
    case $1 in
      -v) VERBOSE=1 ;; -n) DRY_RUN=1 ;;
      -h) echo "Usage: $SCRIPT_NAME [-v] [-n]"; return 0 ;;
      *) die 22 "Unknown: $1" ;;
    esac; shift
  done
  info "Running..."
}
main "$@"
#fin
```

**Anti-pattern:** Missing `set -euo pipefail` or placing it after commands.

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts

**Scripts working as both executables and source libraries must apply `set -euo pipefail` and `shopt` ONLY when executed directly, never when sourced.**

**Rationale:** Sourcing applies settings to caller's shell, breaking its error handling/glob behavior.

**Pattern (early return):**
```bash
#!/bin/bash
my_function() {
  local -- arg="$1"
  echo "Processing: $arg"
}
declare -fx my_function

# Stop here when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable mode only
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
```

**Key rules:**
- Functions defined BEFORE source detection → available in both modes
- `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` → early exit when sourced
- Use `return` (not `exit`) for errors in sourced code
- Guard metadata: `[[ ! -v VAR ]]` for idempotent re-sourcing

**Anti-patterns:**
- `set -e` at top of sourceable script → breaks caller's shell
- Using `exit` instead of `return` when sourced → terminates caller

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**Every script starts: shebang → optional shellcheck → description → `set -euo pipefail`.**

**Shebangs:** `#!/bin/bash` (standard) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (max portability)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Why:** `set -euo pipefail` must be first command—enables strict error handling before any execution.

**Anti-pattern:** Any command before `set -euo pipefail` → errors may go undetected.

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after `shopt`, before any other code.**

**Rationale:** Reliable path resolution via `realpath`; consistent resource location; immutable prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

**Variables:** VERSION=semantic version → SCRIPT_PATH=`realpath -- "$0"` → SCRIPT_DIR=`${SCRIPT_PATH%/*}` → SCRIPT_NAME=`${SCRIPT_PATH##*/}`

**Anti-patterns:**
- `SCRIPT_PATH="$0"` → use `realpath -- "$0"`
- `SCRIPT_DIR=$(dirname "$0")` → use `${SCRIPT_PATH%/*}`
- `SCRIPT_DIR=$PWD` → PWD is cwd, not script location
- Declaring metadata late in script → declare after shopt

**Edge cases:** Root dir (`SCRIPT_DIR` empty) → check/default to `/`. Sourced scripts → use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103


---


**Rule: BCS0104**

## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search resources—enables predictable locations, package manager compatibility, and multi-environment support.**

**Rationale:** Predictability (standard paths); portability across distros; no hardcoded paths.

**Key Locations:**
- `/usr/local/bin|share|lib|etc/` – Local installs
- `/usr/bin|share/` – System (package manager)
- `$HOME/.local/bin|share/` – User installs
- `${XDG_CONFIG_HOME:-$HOME/.config}/` – User config

**FHS Search Pattern:**
```bash
find_resource() {
  local -a paths=(
    "$SCRIPT_DIR"/"$1"                    # Development
    /usr/local/share/myapp/"$1"           # Local install
    /usr/share/myapp/"$1"                 # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$1"
  )
  local p; for p in "${paths[@]}"; do
    [[ -f "$p" ]] && { echo "$p"; return 0; } ||:
  done; return 1
}
```

**PREFIX Pattern:** `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

**Anti-patterns:**
- `source /usr/local/lib/app/x.sh` → Use FHS search function
- `BIN_DIR=/usr/local/bin` (hardcoded) → Use `PREFIX=${PREFIX:-/usr/local}`
- Overwriting user config → Check `[[ -f config ]] ||` before install

**When NOT to use:** Single-user scripts, project-specific tools, containers.

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt

**Configure shell options for robust error handling and glob behavior.**

### Recommended Settings

```bash
shopt -s inherit_errexit  # CRITICAL: set -e works in $() subshells
shopt -s shift_verbose    # Catches shift errors
shopt -s extglob          # Extended patterns: !(*.txt), @(jpg|png)
shopt -s nullglob         # Unmatched glob → empty (for loops/arrays)
# OR: shopt -s failglob   # Unmatched glob → error (strict scripts)
```

### Critical Rationale

1. **inherit_errexit**: Without it, `result=$(false)` silently succeeds—errors in command substitutions don't propagate
2. **nullglob/failglob**: Default bash passes literal `*.txt` to commands when no match—causes silent failures or wrong file operations

### Anti-Patterns

- `for f in *.txt` without nullglob → iterates with literal `*.txt` if no matches
- Relying on `set -e` in subshells without `inherit_errexit` → errors silently ignored

### Typical Configuration

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Use `.sh` for libraries (non-executable); no extension for PATH-available executables.**

### Rules
- **Executables**: `.sh` or no extension
- **Libraries**: `.sh` required, not executable
- **Global PATH commands**: no extension

### Quick Reference
| Type | Extension | Executable |
|------|-----------|------------|
| Library | `.sh` | No |
| Local script | `.sh` | Yes |
| PATH command | none | Yes |

### Anti-patterns
- `mylib` without `.sh` → confuses library/executable distinction
- `mytool.sh` in PATH → inconsistent with Unix conventions

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: primitives first → composition layers → `main()` last. Eliminates forward references; dependencies flow downward only.**

### Rationale
- **No forward references**: Bash reads top-to-bottom; called functions must exist before use
- **Debugging**: Read top-down to understand dependencies immediately
- **Maintainability**: Clear hierarchy shows where to add new functions

### 7-Layer Pattern

```bash
# 1. Messaging (lowest): _msg(), info(), warn(), error(), die()
# 2. Helpers: noarg(), trim()
# 3. Documentation: show_help(), show_version()
# 4. Validation: check_root(), check_prerequisites()
# 5. Business logic: build_project(), process_file()
# 6. Orchestration: run_build_phase(), cleanup()
# 7. main() - calls all layers

main() { check_deps; build; deploy; }
main "$@"
#fin
```

### Anti-Patterns

```bash
# ✗ main() at top (forward refs)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✓ main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Circular deps (A→B→A) → extract common logic to lower layer
```

### Key Rules
- Higher functions call lower functions only
- Group with section comments per layer
- Within layers: alphabetical or by execution order
- Private functions (`_name`) stay with their public wrappers

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Use explicit `declare` for type safety and predictable behavior.**

Type hints: `declare -i` (integer), `declare --` (string), `declare -a` (array), `declare -A` (associative). Use `readonly` for constants. Naming: `UPPER_CASE` constants, `lower_case` variables. Scope with `local` in functions.

```bash
declare -i count=0          # Integer arithmetic
readonly VERSION="1.0"      # Immutable constant
local -i result             # Function-scoped integer
declare -a items=()         # Indexed array
```

**Anti-patterns:** Untyped `var=val` → type coercion bugs; missing `local` → global pollution.

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) for type safety and intent clarity.**

### Rationale
- Integer `-i` enforces numeric ops, catches non-numeric → 0
- Array declarations prevent accidental scalar overwrites
- `--` separator prevents option injection if name starts with `-`

### Declaration Types

| Type | Syntax | Use Case |
|------|--------|----------|
| Integer | `declare -i` | counters, ports, exit codes |
| String | `declare --` | paths, text, user input |
| Indexed array | `declare -a` | lists, sequences |
| Assoc array | `declare -A` | key-value maps (Bash 4.0+) |
| Readonly | `declare -r` | constants |
| Local | `local --` | function-scoped vars |

### Example

```bash
declare -i count=0
declare -- filename=data.txt
declare -a files=()
declare -A config=([port]=8080)
declare -r VERSION=1.0.0

process() {
  local -- input=$1
  local -i attempts=0
  local -a results=()
}
```

### Anti-Patterns

```bash
# ✗ No declaration → intent unclear
count=0

# ✓ Explicit type
declare -i count=0

# ✗ Missing -A → creates indexed array
declare CONFIG; CONFIG[key]=val

# ✓ Explicit associative
declare -A CONFIG=(); CONFIG[key]=val

# ✗ Global leak in function
func() { temp=$1; }

# ✓ Local scope
func() { local -- temp=$1; }
```

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function variables with `local` to prevent namespace pollution.**

Globals at script top with `declare`; function vars with `local -a`, `local -i`, `local --`.

```bash
main() {
  local -a items=()    # Local array
  local -i count=0     # Local integer
  local -- path        # Local string
}
```

**Why:** Without `local`, variables overwrite globals, persist after return, break recursion.

**Anti-pattern:** `file=$1` → `local -- file=$1`

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use case-based naming to distinguish scope: UPPER_CASE for constants/globals, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Local variables | lower_case | `local file_count=0` |
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

**Rationale:** UPPER_CASE globals visible at script-wide scope; lower_case locals prevent shadowing; underscore prefix signals internal use.

**Anti-patterns:** `PATH`, `HOME`, `USER` as variable names → conflicts with shell; single-letter lowercase → reserved.

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly`/`declare -r` for immutable values; `export`/`declare -x` for subprocess inheritance.**

### Core Pattern

```bash
declare -r VERSION=1.0.0              # Constant (immutable)
declare -ri MAX_RETRIES=3             # Readonly integer
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Exported (child processes)
declare -rx BUILD_ENV=production      # Both: readonly + exported
```

### Key Differences

| Feature | `readonly` | `export` |
|---------|------------|----------|
| Prevents modification | ✓ | ✗ |
| Available in subprocesses | ✗ | ✓ |

### Rationale

- `readonly` prevents accidental modification of true constants
- `export` only for values child processes actually need
- Combine `-rx` when subprocess needs immutable config

### Anti-patterns

```bash
# ✗ Exporting internal constants
export MAX_RETRIES=3
# ✓ readonly -- MAX_RETRIES=3

# ✗ Readonly before allowing override
readonly -- OUTPUT_DIR="$HOME"/out
# ✓ OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/out}; readonly -- OUTPUT_DIR
```

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables with values first, then make all readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; groups related constants visibly; explicit immutability contract.

**Three-Step Pattern** (for args/runtime config):
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
# 2. Modify in main() during parsing
# 3. Make readonly AFTER parsing
readonly -- VERBOSE DRY_RUN
```

**Standard Groups:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors/Paths/Config**: Use readonly-after-group

**Minimal Example:**
```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR
```

**Anti-patterns:**
- `readonly -- X` before all values set → inconsistent protection
- Missing `--` separator → option injection risk
- Mixing unrelated variables in same readonly group

**Key:** Always use `--` separator. Make readonly as soon as values are final.

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

Anti-pattern: `CONST=value` → mutable, can be overwritten accidentally.

**Ref:** BCS0206


---


**Rule: BCS0207**

## Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Why
- Element boundaries preserved regardless of content (spaces, globs)
- Safe command construction with arbitrary arguments

#### Declaration & Usage
```bash
declare -a arr=()              # Empty indexed array
declare -A map=()              # Associative (Bash 4.0+)
arr+=("$item")                 # Append
for x in "${arr[@]}"; do       # Iterate (MUST quote)
readarray -t arr < <(cmd)      # From command output
"${cmd[@]}"                    # Execute array as command
```

#### Anti-Patterns
```bash
# ✗ Unquoted → word splitting
rm ${files[@]}
# ✓ Quoted
rm "${files[@]}"

# ✗ Word split to array
arr=($string)
# ✓ Use readarray
readarray -t arr <<< "$string"
```

#### Quick Reference
| Op | Syntax |
|----|--------|
| Length | `${#arr[@]}` |
| Last | `${arr[-1]}` |
| Slice | `${arr[@]:2:3}` |

**Ref:** BCS0207


---


**Rule: BCS0208**

## Reserved for Future Use

**Placeholder for future variable-related topics** (nameref, indirect expansion, typed variables).

Do not use BCS0208 in documentation or compliance checking.

**Status:** Reserved

**Ref:** BCS0208


---


**Rule: BCS0209**

## Derived Variables

**Compute variables from base values; group with section comments; update all derived variables when base changes during argument parsing.**

### Rationale
- **DRY**: Single source of truth—change PREFIX, all paths update
- **Correctness**: Forgetting to update derived vars after base change causes subtle bugs
- **Maintainability**: Section comments clarify dependency chains

### Pattern

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived paths (from PREFIX)
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"

# Update function for argument parsing
update_paths() {
  BIN_DIR="$PREFIX"/bin
  CONFIG_DIR=/etc/"$APP_NAME"
}

# In main(): after --prefix changes PREFIX, call update_paths
# Make readonly AFTER all parsing complete
readonly -- PREFIX APP_NAME BIN_DIR CONFIG_DIR
```

### Anti-Patterns

```bash
# ✗ Duplicating instead of deriving
BIN_DIR=/usr/local/bin  # Hardcoded, not "$PREFIX"/bin

# ✗ Not updating derived vars when base changes
--prefix) PREFIX=$1 ;;  # BIN_DIR now stale!

# ✗ Making derived readonly before parsing
readonly BIN_DIR="$PREFIX"/bin  # Can't update later!
```

### Key Points
- Group derived vars with `# Derived from PREFIX` comments
- Use `update_derived_paths()` function when many variables
- XDG fallbacks: `${XDG_CONFIG_HOME:-"$HOME"/.config}`
- Document hardcoded exceptions (e.g., `/etc/profile.d` always fixed)

**Ref:** BCS0209


---


**Rule: BCS0210**

## Parameter Expansion & Braces

**Use `"$var"` by default; only use `"${var}"` when syntactically required.**

#### Braces Required

- **Expansion ops:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Concatenation (no separator):** `"${var}suffix"` `"${a}${b}"`
- **Arrays:** `"${arr[@]}"` `"${#arr[@]}"`
- **Special:** `"${@:2}"` `"${10}"` `"${!var}"`

#### No Braces Needed

Standalone or with separators: `"$var"` `"$HOME/bin"` `"$PREFIX"/lib`

#### Key Expansions

```bash
${var##*/}              # Remove longest prefix
${var%/*}               # Remove shortest suffix
${var:-default}         # Default if unset/null
${var//old/new}         # Replace all
${var,,}  ${var^^}      # Lower/upper case
```

#### Anti-patterns

- `"${var}"` when `"$var"` suffices → visual noise
- `"${PREFIX}/bin"` → separator already delimits

**Ref:** BCS0210


---


**Rule: BCS0211**

## Boolean Flags

**Use `declare -i` integers (0/1) for boolean state; test with `(())`.**

### Pattern

```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && echo 'dry-run' ||:
if ((VERBOSE)); then log_debug; fi
```

### Rules

- `declare -i`/`local -i` for all flags
- Initialize explicitly: `=0` (false) or `=1` (true)
- ALL_CAPS naming (`DRY_RUN`, `SKIP_BUILD`)
- Test: `((FLAG))` → true if non-zero

### Anti-patterns

- `if [ "$flag" = "true" ]` → use `((flag))`
- Uninitialized flags → always init to 0/1

**Ref:** BCS0211


---


**Rule: BCS0300**

# Strings & Quoting

**Single quotes for literals, double quotes for expansion.**

## Rules (7)

| Rule | Focus |
|------|-------|
| BCS0301 | Static `'...'` vs dynamic `"..."` |
| BCS0302 | Quote `$(cmd)` results |
| BCS0303 | Variables in `[[ ]]` |
| BCS0304 | Heredoc delimiter quoting |
| BCS0305 | printf format strings |
| BCS0306 | `${param@Q}` safe display |
| BCS0307 | Common quoting mistakes |

## Core Pattern

```bash
readonly STATIC='no expansion'
msg="Hello, ${name}"
result="$(cmd)"  # Always quote
```

## Anti-Patterns

```bash
# WRONG → CORRECT
file=$path      → file="$path"
$(cat file)     → "$(cat file)"
```

**Ref:** BCS0300


---


**Rule: BCS0301**

## Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: Variable expansion required
- **Mixed**: `"Option '$1' invalid"` — literal display with variable
- **One-word exception**: Simple alphanumeric (`a-zA-Z0-9_-.`) may be unquoted

```bash
info 'Static message'           # Single: no expansion
info "Found $count files"       # Double: expansion needed
die 1 "Unknown option '$1'"     # Mixed: literal quotes shown
STATUS=success                  # Unquoted: simple alphanumeric
EMAIL='user@domain.com'         # Quoted: special char @
```

#### Path Concatenation

Prefer separate quoting for clarity:
```bash
"$PREFIX"/bin                   # Variable quoted separately
"$dir"/"$file"                  # Clear variable boundaries
```

#### Anti-Patterns

- `info "Static..."` �' `info 'Static...'` (use single for static)
- `EMAIL=user@domain.com` �' `EMAIL='user@domain.com'` (quote special chars)
- `PATTERN=*.log` �' `PATTERN='*.log'` (quote globs)

**Ref:** BCS0301


---


**Rule: BCS0302**

## Command Substitution

**Quote `$()` in strings; omit quotes for simple assignment; always quote when using result.**

#### Rules

- **In strings:** `echo "Time: $(date)"` — double quotes required
- **Simple assignment:** `VAR=$(cmd)` — no quotes needed
- **Concatenation:** `VAR="$(cmd)".suffix` — quotes required
- **Usage:** `echo "$VAR"` — always quote to prevent word splitting

#### Example

```bash
# Assignment (no quotes needed)
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')

# Concatenation (quotes required)
VERSION="$(git describe --tags)".beta

# Usage (always quote)
echo "$VERSION"
```

#### Anti-patterns

- `VERSION="$(cmd)"` �' unnecessary quotes on simple assignment
- `echo $result` �' word splitting occurs without quotes

**Ref:** BCS0302


---


**Rule: BCS0303**

## Quoting in Conditionals

**Always quote variables in conditionals.** Unquoted �' word splitting, glob expansion, empty-value errors, injection risk.

```bash
# Variables always quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]

# Pattern/regex: pattern UNQUOTED
[[ "$file" == *.txt ]]           # Glob match
[[ "$input" =~ $pattern ]]       # Regex (quoting makes literal)
```

**Anti-patterns:** `[[ -f $file ]]` �' breaks on spaces/globs; `[[ "$x" =~ "$pattern" ]]` �' pattern treated as literal.

**Ref:** BCS0303


---


**Rule: BCS0304**

## Here Documents

**Quote delimiter (`<<'EOF'`) to prevent expansion; unquoted (`<<EOF`) for variable substitution.**

#### Delimiter Quoting

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

#### Examples

```bash
# Expansion enabled
cat <<EOF
User: $USER
EOF

# Literal content (no expansion)
cat <<'EOF'
{"name": "$VAR"}
EOF
```

#### Anti-Pattern

```bash
# ✗ Unquoted �' SQL injection risk
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0304


---


**Rule: BCS0305**

## printf Patterns

**Single-quote format strings, double-quote variable arguments; prefer printf over echo -e.**

#### Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format: single, vars: double
echo 'Static text'                         # No vars: single quotes
printf '%s\n' "$var"                       # %s=string %d=int %f=float %%=literal
```

#### Anti-patterns

- `echo -e "...\n..."` �' Use `printf '...\n...\n'` or `$'...\n...'` (echo -e behavior varies)
- `printf "$fmt"` �' Format strings must be single-quoted (security, escapes)

**Ref:** BCS0305


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**`${param@Q}` produces shell-quoted output safe for display—prevents injection in error messages and logs.**

#### Core Behavior

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | literal | `'*.txt'` |

#### Usage Pattern

```bash
# Error messages - safe display of untrusted input
die 2 "Unknown option ${1@Q}"
info "Processing ${file@Q}"

# Dry-run - quote array for display
printf -v quoted '%s ' "${cmd[@]@Q}"
```

#### When to Use

- **Use @Q:** Error messages, logging user input, dry-run display
- **Don't use:** Normal expansion (`"$file"`), comparisons

#### Anti-Patterns

```bash
# ✗ Injection risk
die 2 "Unknown option $1"

# ✓ Safe
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0306


---


**Rule: BCS0307**

## Quoting Anti-Patterns

**Single quotes for static text, double quotes for variables, avoid unnecessary braces.**

#### Critical Anti-Patterns

| Wrong | Correct | Why |
|-------|---------|-----|
| `"literal"` | `'literal'` | Static strings need single quotes |
| `$var` | `"$var"` | Prevents word splitting/glob expansion |
| `"${HOME}/bin"` | `"$HOME"/bin` | Braces only when needed |
| `${arr[@]}` | `"${arr[@]}"` | Arrays require quotes |

#### When Braces ARE Required

```bash
"${var:-default}"    # Default value
"${file##*/}"        # Parameter expansion
"${array[@]}"        # Array expansion
"${var1}${var2}"     # Adjacent variables
```

#### Glob Danger

```bash
pattern='*.txt'
echo $pattern    # ✗ Expands to all .txt files!
echo "$pattern"  # ✓ Outputs literal: *.txt
```

#### Here-doc: Quote Delimiter for Literals

```bash
# ✗ Variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted delimiter prevents expansion
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0307


---


**Rule: BCS0400**

# Functions

**Define functions with `lowercase_underscores`, use `main()` for scripts >200 lines, organize bottom-up (messaging→helpers→logic→main).**

## Key Rules
- `declare -fx func_name` for exported library functions
- Remove unused utility functions in production scripts
- Bottom-up order ensures functions call only previously-defined functions

## Pattern
```bash
msg() { printf '%s\n' "$1"; }
validate_input() { [[ -n "$1" ]] || return 1; }
process_data() { validate_input "$1" && msg "Processing"; }
main() { process_data "$@"; }
main "$@"
```

## Anti-Patterns
- `myFunc` → use `my_func`
- Calling functions before definition
- Keeping unused utility functions in production

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

**Anti-pattern:** `local file="$1"` �' `local -- file="$1"` (always use `--` separator)

**Ref:** BCS0401


---


**Rule: BCS0402**

## Function Names

**Use lowercase_with_underscores; prefix private functions with `_`.**

### Core Pattern

```bash
process_log_file() { … }     # ✓ Public
_validate_input() { … }      # ✓ Private (internal)
```

### Why

- Matches Unix conventions (`grep`, `sed`)
- Avoids conflicts with built-ins (all lowercase)
- `_prefix` signals internal-only use

### Anti-Patterns

```bash
MyFunction() { … }           # ✗ CamelCase
PROCESS_FILE() { … }         # ✗ UPPER_CASE
my-function() { … }          # ✗ Dashes cause issues
cd() { builtin cd "$@"; }    # ✗ Overriding built-in
```

�' Wrap built-ins with different name: `change_dir()` not `cd()`

**Ref:** BCS0402


---


**Rule: BCS0403**

## Main Function

**Use `main()` for scripts >200 lines as single entry point; place `main "$@"` at bottom before `#fin`.**

**Rationale:** Single entry point for testability; functions can be sourced without execution; centralized exit code handling.

**When to use:** >200 lines, multiple functions, argument parsing, complex logic. Skip for trivial scripts <200 lines.

**Structure:**
```bash
#!/bin/bash
set -euo pipefail

helper_function() { : ...; }

main() {
  local -i verbose=0
  while (($#)); do case $1 in
    -v) verbose=1 ;; -h) show_help; return 0 ;;
    *) die 22 "Invalid: ${1@Q}" ;;
  esac; shift; done
  readonly -- verbose
  return 0
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
main "$@"
#fin
```

**Anti-patterns:**
- `main` without `"$@"` �' args not passed
- Parsing args outside main �' consumed before main runs
- Functions defined after `main "$@"` �' not available during execution

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

Anti-pattern: `export -f func` �' use `declare -fx func` instead (consistent with BCS declaration style).

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
# ✗ Shipping unused utilities
declare -- PROMPT='> '    # Never used
debug() { :; }            # Never called
```

**Ref:** BCS0405


---


**Rule: BCS0406**

## Dual-Purpose Scripts

**Rule:** Scripts executable directly OR sourceable as libraries using `BASH_SOURCE[0]` check.

**Key:** `set -e` MUST come AFTER source check—library code must not impose error handling on caller.

**Rationale:** Reusable functions without duplication; testing flexibility (source functions independently).

#### Pattern

```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "${arg@Q}"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail
main() { my_func "$@"; }
main "$@"
```

**Idempotent:** Use `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION=1.0.0` to prevent double-init.

#### Anti-Patterns

`my_func() { :; }` without `declare -fx` �' cannot call from subshells after sourcing.

`set -euo pipefail` before source check �' risky `return 0` behavior.

**See Also:** BCS0607 (Library Patterns), BCS0604 (Function Export)

**Ref:** BCS0406


---


**Rule: BCS0407**

## Library Patterns

**Rule: BCS0407**

**Libraries must prevent direct execution and define functions without side effects.**

#### Rationale
- Code reuse across scripts with consistent interfaces
- Namespace isolation prevents function collisions
- Easier testing via explicit initialization

#### Pattern

```bash
#!/usr/bin/env bash
# lib-validation.sh - Source only

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: Must be sourced, not executed'; exit 1
}

declare -rx LIB_VALIDATION_VERSION=1.0.0

valid_email() {
  [[ $1 =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
declare -fx valid_email
```

#### Sourcing

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR"/lib-validation.sh

# With check
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing ${lib_path@Q}"
```

#### Anti-Patterns

- `source lib.sh` with immediate side effects �' Define functions only, use `lib_init` for initialization
- Unprefixed functions �' Use namespace prefix: `myapp_init`, `myapp_cleanup`

**Ref:** BCS0407


---


**Rule: BCS0408**

## Dependency Management

**Use `command -v` to verify external dependencies exist before use, with clear error messages.**

#### Rationale
- Clear errors for missing tools vs cryptic failures
- Enables graceful degradation with optional deps
- Documents script requirements explicitly

#### Dependency Check

```bash
# Single/multiple checks
command -v curl >/dev/null || die 1 'curl required'

for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && result=$(jq -r '.f' <<<"$json")
```

#### Version Check

```bash
((BASH_VERSINFO[0] < 5)) && die 1 "Requires Bash 5+"
```

#### Anti-Patterns

- `which curl` �' `command -v curl` (POSIX compliant)
- Silent `curl "$url"` �' Check first with helpful message

**Ref:** BCS0408


---


**Rule: BCS0500**

# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic, process substitution over pipes to while loops.**

## Core Rules

- `[[ ]]` not `[ ]` for conditionals (safer, more features)
- `(( ))` for arithmetic tests
- `< <(cmd)` not `cmd | while` (avoids subshell variable loss)
- Safe increment: `i+=1` or `((++i))` → `((i++))` fails at i=0 with `set -e`

## Example

```bash
while IFS= read -r line; do
    ((count++)) || true
done < <(find . -name "*.sh")
[[ $count -gt 0 ]] && echo "Found: $count"
```

## Anti-Patterns

- `cmd | while read` → variables lost after loop
- `((i++))` with `set -e` → exits when i=0

**Ref:** BCS0500


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

### Why `[[ ]]` over `[ ]`
- No word splitting/glob expansion on variables
- Pattern matching (`==`, `=~`) and logical ops (`&&`, `||`) inside
- `<`/`>` for lexicographic comparison

### Core Pattern
```bash
[[ -f "$file" ]] && source "$file" ||:
((count > MAX)) && die 1 'Limit exceeded' ||:
[[ -n "$var" ]] && ((count)) && process_data
[[ "$str" =~ ^[0-9]+$ ]] && echo "Number"
```

### Key Operators
**File:** `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` exec, `-s` non-empty
**String:** `-z` empty, `-n` non-empty, `==` equal, `=~` regex
**Arithmetic:** `>`, `>=`, `<`, `<=`, `==`, `!=`

### Anti-patterns
```bash
# ✗ Old [ ] syntax �' use [[ ]]
[ -f "$file" -a -r "$file" ]  # Deprecated -a/-o
# ✓ [[ -f "$file" && -r "$file" ]]

# ✗ Arithmetic with [[ ]] �' use (())
[[ "$count" -gt 10 ]]
# ✓ ((count > 10))
```

**Ref:** BCS0501


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way pattern matching; prefer over if/elif chains for single-variable tests. Always include `*)` default case.**

**Rationale:** Pattern matching with wildcards/alternation �' single evaluation (faster than if/elif) �' clearer visual structure with column alignment.

**Formats:**
- **Compact:** Single actions on same line, align `;;` at consistent column
- **Expanded:** Multi-line logic, `;;` on separate line with blank line after

**Core example:**

```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Pattern syntax:** Literal `start)` �' Wildcard `*.txt)` �' Alternation `-v|--verbose)` �' Extglob `@(a|b)` (requires `shopt -s extglob`)

**Anti-patterns:**

```bash
# ✗ Missing default case
case "$action" in start) ;; stop) ;; esac  # Silent failure on unknown

# ✗ Use if/elif when testing multiple variables or numeric ranges
if [[ "$a" && "$b" ]]; then ...  # Not: nested case statements
```

**Key rules:** Quote test variable `case "$var"` �' Don't quote patterns `start)` not `"start")` �' Always `;;` terminator �' Use if for complex/multi-var logic.

**Ref:** BCS0502


---


**Rule: BCS0503**

## Loops

**Use `for` for arrays/globs/ranges, `while` for input streams/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

### Key Patterns

**For loops:** `for item in "${array[@]}"` | `for file in *.txt` | `for ((i=0; i<n; i+=1))`

**While input:** `while IFS= read -r line; do ... done < file` or `< <(command)`

**Infinite:** `while ((1))` (fastest) �' `while :` (POSIX) �' avoid `while true` (15-22% slower)

**Arg parsing:** `while (($#)); do case $1 in ... esac; shift; done`

### Core Example

```bash
local -- file
local -i count=0

# Process command output (preserves variable scope)
while IFS= read -r -d '' file; do
  [[ -f "$file" ]] || continue
  count+=1
done < <(find . -name '*.sh' -print0)

echo "Processed $count files"
```

### Critical Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `for f in $(ls *.txt)` | `for f in *.txt` |
| `cat file \| while read` | `while read < file` or `< <(cat)` |
| `for x in ${array[@]}` | `for x in "${array[@]}"` |
| `for ((i=0;i<n;i++))` | `for ((i=0;i<n;i+=1))` |
| `while (($# > 0))` | `while (($#))` |
| `local x` inside loop | declare locals before loop |

### Essential Rules

- Enable `nullglob` for glob loops (empty match = zero iterations)
- Use `break 2` for nested loop exit (explicit level)
- Use `IFS= read -r` always (preserves whitespace/backslashes)
- Declare loop variables before loop, not inside

**Ref:** BCS0503


---


**Rule: BCS0504**

## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variable assignments are lost. Use `< <(command)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshell for while body �' variable modifications discarded on exit �' counters=0, arrays=empty, no errors shown.

### Rationale

- Variables modified in pipe subshell don't persist to parent
- Silent failure—script runs but produces wrong values
- Process substitution runs loop in current shell, preserving state

### Solutions

**Process substitution** (most common):
```bash
while IFS= read -r line; do
  count+=1
done < <(command)
```

**readarray** (collecting lines):
```bash
readarray -t lines < <(command)
```

**Here-string** (variable input):
```bash
while IFS= read -r line; do
  count+=1
done <<< "$input"
```

### Anti-Patterns

```bash
# ✗ Pipe loses state
cmd | while read -r x; do arr+=("$x"); done
echo "${#arr[@]}"  # 0!

# ✓ Process substitution preserves state
while read -r x; do arr+=("$x"); done < <(cmd)
```

### Edge Cases

- **Large files**: `readarray` loads all into RAM; while loop streams line-by-line
- **Null-delimited**: Use `read -r -d ''` and `find -print0`

**Ref:** BCS0504


---


**Rule: BCS0505**

## Arithmetic Operations

**Use `declare -i` for integers, `(())` for comparisons, and `i+=1` for increments.**

### Core Rules

- **Declare integers**: `declare -i count=0` — enables auto-arithmetic, type safety
- **Increment**: `i+=1` ONLY �' requires `declare -i`; `((i++))` exits with `set -e` when i=0
- **Comparisons**: Use `(())` not `[[ -eq ]]` �' `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` — non-zero is truthy

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
# ✗ NEVER - exits with set -e when i=0
((i++))

# ✗ Verbose/old-style
[[ "$count" -gt 10 ]]

# ✓ Correct
((count > 10))
i+=1
```

### Why `((i++))` Fails

```bash
set -e; i=0
((i++))  # Returns 0 (old value) = "false" �' script exits!
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

**Use `bc` or `awk` for float math; Bash only supports integers natively.**

#### Rationale
- Bash `$(())` truncates decimals �' data loss
- `bc -l` provides arbitrary precision; `awk` handles inline ops
- Float string comparison (`[[ "$a" > "$b" ]]`) gives wrong results

#### Core Patterns

```bash
# bc: precision calculation
result=$(echo "$width * $height" | bc -l)

# awk: formatted output with variables
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# Float comparison (bc returns 1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then
  echo "$a is greater"
fi
```

#### Anti-Patterns

`result=$((10/3))` �' returns 3, not 3.333 �' use `echo '10/3' | bc -l`

`[[ "$a" > "$b" ]]` �' string comparison �' use `(($(echo "$a > $b" | bc -l)))`

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506


---


**Rule: BCS0600**

# Error Handling

**Configure `set -euo pipefail` + `shopt -s inherit_errexit` before any commands to catch failures early.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures → Never leave unchecked commands in pipelines.

**Ref:** BCS0600


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
# ✗ Exits before check (set -e triggers on substitution)
result=$(failing_cmd)
[[ -n "$result" ]] && echo "$result"

# ✓ Conditional protects from exit
if result=$(failing_cmd); then echo "$result"; fi
```

**Anti-patterns:** Leaving flags disabled longer than necessary �' re-enable immediately after risky operation.

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
- `exit 1` for all errors �' Use specific codes
- Codes 64+ �' Reserved for system use

**Ref:** BCS0602


---


**Rule: BCS0603**

## Trap Handling

**Use cleanup functions with trap to ensure resources are released on exit, signals, or errors.**

### Core Pattern

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Key Signals

| Signal | Trigger |
|--------|---------|
| `EXIT` | Any script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |

### Critical Rules

1. **Set trap BEFORE creating resources** → prevents leaks if script exits early
2. **Disable trap in cleanup** → `trap - SIGINT SIGTERM EXIT` prevents recursion
3. **Preserve exit code** → `trap 'cleanup $?'` captures original status
4. **Single quotes** → `trap 'rm "$f"'` delays expansion; double quotes expand immediately

### Anti-Patterns

```bash
trap 'rm -f "$f"; exit 0' EXIT      # ✗ Always exits 0
trap "rm -f $file" EXIT             # ✗ Expands $file now, not at trap time
temp=$(mktemp); trap 'cleanup' EXIT # ✗ Resource before trap → leak risk
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values explicitly—`set -e` misses pipelines, command substitution, and conditionals.**

**Rationale:** Explicit checks enable contextual errors, controlled recovery, and catch failures `set -e` misses.

**`set -e` limitations:** Pipelines (except last), conditionals, command substitution in assignments.

**Patterns:**

```bash
# || die pattern
mv "$f" "$d/" || die 1 "Failed to move ${f@Q}"

# || block for cleanup
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Check command substitution
out=$(cmd) || die 1 "cmd failed"

# PIPESTATUS for pipelines
cat f | grep x; ((PIPESTATUS[0])) && die 1 "cat failed"
```

**Critical settings:**
```bash
set -euo pipefail
shopt -s inherit_errexit  # Subshells inherit set -e
```

**Anti-patterns:**
- `cmd1; cmd2; if (($?))` �' checks cmd2 not cmd1
- `output=$(failing_cmd)` without `|| die` �' silent failure
- Generic errors `die 1 "failed"` �' no context for debugging

**Ref:** BCS0604


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe to continue. Always document WHY.**

**Rationale:** Masks real bugs; silent failures appear successful; creates debugging nightmares.

### Safe to Suppress

- **Command/file existence checks:** `command -v tool >/dev/null 2>&1`
- **Cleanup operations:** `rm -f /tmp/app_* 2>/dev/null || true`
- **Idempotent operations:** `install -d "$dir" 2>/dev/null || true`

### NEVER Suppress

- File operations, data processing, system config, security ops, required dependencies

### Suppression Patterns

| Pattern | Use When |
|---------|----------|
| `2>/dev/null` | Hide messages, still check return |
| `|| true` | Ignore return, keep stderr |
| Both combined | Both irrelevant |

### Example

```bash
# ✓ Safe - cleanup may have nothing to do
# Rationale: Temp files may not exist
rm -f "$CACHE"/*.tmp 2>/dev/null || true

# ✗ DANGEROUS - critical operation
cp "$config" "$dest" 2>/dev/null || true

# ✓ Correct - check critical operations
cp "$config" "$dest" || die 1 "Copy failed"
```

### Anti-Patterns

```bash
# ✗ Suppress without documenting why
some_cmd 2>/dev/null || true

# ✗ Suppress entire function
process() { ...; } 2>/dev/null

# ✗ Using set +e to suppress
set +e; critical_op; set -e
```

**Key:** Every suppression is a deliberate decision—document it with a comment.

**Ref:** BCS0605


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Rationale:**
- `(())` returns exit code 1 when false �' `set -e` terminates script
- `|| :` (colon = no-op returning 0) provides safe fallback
- Traditional Unix idiom; `:` preferred over `true` (built-in, 1 char)

**Pattern:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ SAFE: continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use for:** optional declarations, conditional exports, feature-gated actions, debug output.

**Don't use for:** critical operations needing error handling �' use `if` with explicit error checks.

**Anti-patterns:**

```bash
# ✗ Missing || : - script exits on false
((flag)) && action

# ✗ Suppressing critical operations
((confirmed)) && delete_files || :  # hides failures!

# ✓ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606


---


**Rule: BCS0700**

# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: data→STDOUT, diagnostics→STDERR.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core (uses FUNCNAME) | varies |
| `error()` | Unconditional error | STDERR |
| `die()` | Exit with error | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDERR |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDERR |
| `vecho()` | Verbose output | STDERR |
| `yn()` | Yes/no prompts | STDERR |

## Key Rules

- STDERR for all diagnostics; STDOUT only for data
- Place `>&2` at command start for clarity
- Use messaging functions, not bare `echo` for status

## Example

```bash
info "Processing file"
[[ -f "$file" ]] || die "File not found: $file"
warn "Large file detected"
success "Complete"
```

## Anti-patterns

- `echo "Error"` → `error "Error"` (use functions)
- `cmd >&2` at end → `>&2 cmd` (redirection first)

**Ref:** BCS0700


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
- Empty strings when piped �' safe for log files
- `declare -r` prevents accidental modification

### Anti-Patterns

`echo -e "\e[31m"` �' non-portable; `[[ -t 1 ]]` alone �' misses stderr redirection

**Ref:** BCS0701


---


**Rule: BCS0702**

## STDOUT vs STDERR

**All error messages �' STDERR; place `>&2` at beginning for clarity.**

```bash
>&2 echo "[$(date -Ins)]: $*"
```

Anti-pattern: `echo "error" >&2` �' harder to spot redirection at line end.

**Ref:** BCS0702


---


**Rule: BCS0703**

## Core Message Functions

**Use private `_msg()` with `FUNCNAME[1]` inspection to auto-format messages; wrapper functions control verbosity and stream routing.**

### Rationale
- `FUNCNAME` auto-detects caller �' single DRY implementation
- Conditional output via `VERBOSE`/`DEBUG` flags
- Proper streams: errors�'stderr, data�'stdout (enables `data=$(./script)`)

### Core Pattern
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Wrappers
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### File Logging
```bash
# Use printf builtin (10-50x faster than $(date))
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }
```

### Anti-Patterns
- `echo "Error: ..."` �' no stderr, no prefix, no color
- `$(date ...)` in log �' subshell per call; use `printf '%()T'`
- `die() { error "$@"; exit 1; }` �' no exit code param

**Ref:** BCS0703


---


**Rule: BCS0704**

## Usage Documentation

**Every script MUST provide `show_help()` with name, version, description, options, and examples.**

### Rationale
- Self-documenting scripts reduce support burden
- Consistent format enables automated help extraction

### Required Structure
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose   Increase verbosity
  -h|--help      This help
Examples:
  $SCRIPT_NAME -v file.txt
EOT
}
```

### Anti-patterns
- `echo "Usage..."` �' Use heredoc for multiline help
- Missing `-h|--help` option

**Ref:** BCS0704


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status→stderr; plain `echo` for data output→stdout.**

**Key principles:**
- Stream separation: messaging→stderr (user-facing), echo→stdout (pipeable data)
- Verbosity: messaging respects `VERBOSE`; echo always displays
- Pipeability: only stdout data captured; stderr messages visible

**Decision:** Status/diagnostics → messaging | Data/help/reports → echo

**Core pattern:**
```bash
get_data() {
  info "Processing..."    # stderr, verbosity-controlled
  echo "$result"          # stdout, always outputs, capturable
}
data=$(get_data)          # captures only echo output
```

**Anti-patterns:**
```bash
# ✗ info() for data - goes to stderr, can't capture
get_email() { info "$email"; }
result=$(get_email)  # empty!

# ✗ echo for status - mixes with data stream
process() { echo "Starting..."; cat "$file"; }

# ✓ Correct separation
process() { info "Starting..."; cat "$file"; }
```

**Rules:** Help/version→always echo (not verbose-dependent) | Errors→always stderr | Multi-line→here-docs not multiple info()

**Ref:** BCS0705


---


**Rule: BCS0706**

## Color Management Library

**Use dedicated color library for sophisticated color needs: two-tier system, auto-detection, `_msg` integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` — default, minimal namespace
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
- ❌ Scattered inline `RED=$'\033[0;31m'` in every script �' use library
- ❌ `[[ -t 1 ]]` only �' test both stdout AND stderr
- ❌ `color_set always` hardcoded �' use `${COLOR_MODE:-auto}`

**Ref:** BCS0706


---


**Rule: BCS0707**

## TUI Basics

**Use terminal check `[[ -t 1 ]]` before TUI output; restore cursor on exit.**

#### Key Patterns

- **Spinner**: Background process with `kill`/cleanup
- **Progress bar**: `printf '\r[...]'` with `%*s | tr ' ' '█'`
- **Cursor**: Hide `\033[?25l`, show `\033[?25h`, trap EXIT
- **Clear**: Line `\033[2K\r`, screen `\033[2J\033[H`

#### Rationale

- Visual feedback for long operations
- Interactive menus improve UX

#### Example

```bash
# Progress bar with terminal check
progress_bar() {
  local -i cur=$1 tot=$2 w=50 f=$((cur*w/tot))
  printf '\r[%s%s] %3d%%' \
    "$(printf '%*s' "$f" ''|tr ' ' '█')" \
    "$(printf '%*s' $((w-f)) ''|tr ' ' '░')" \
    $((cur*100/tot))
}
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

#### Anti-Pattern

`progress_bar 50 100` without `[[ -t 1 ]]` �' garbage output to non-terminal

**Ref:** BCS0707


---


**Rule: BCS0708**

## Terminal Capabilities

**Detect terminal features with `[[ -t 1 ]]` before using colors/cursor control; provide fallbacks for pipes/redirects.**

#### Key Points
- Prevents garbage output in non-terminal contexts
- Enables graceful degradation for limited terminals
- Use `tput` for portable capability queries

#### Terminal Detection

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with fallback
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
trap 'TERM_COLS=$(tput cols 2>/dev/null || echo 80)' WINCH
```

#### Anti-Patterns

```bash
# ✗ Assuming terminal support
echo -e '\033[31mError\033[0m'  # �' garbage in pipes

# ✓ Conditional output
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# ✗ Hardcoded width �' use ${TERM_COLS:-80}
```

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708


---


**Rule: BCS0800**

# Command-Line Arguments

**Standard argument parsing supporting short (`-h`) and long (`--help`) options with consistent interfaces.**

Core requirements: canonical version format (`scriptname X.Y.Z`), validation for required args, option conflict detection, parsing placement based on complexity.

**Ref:** BCS0800


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` with `noarg` validation.**

### Core Pattern
```bash
while (($#)); do case $1 in
  -o|--output)  noarg "$@"; shift; output=$1 ;;
  -v|--verbose) VERBOSE+=1 ;;
  -V|--version) echo "$VERSION"; exit 0 ;;
  -[ovV]?*)     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            files+=("$1") ;;
esac; shift; done
```

### Key Elements
- **Loop**: `(($#))` arithmetic test (faster than `[[ $# -gt 0 ]]`)
- **Options w/args**: `noarg "$@"; shift` before capturing value
- **Flags**: Set variable, shift handled at loop end
- **Bundling**: `-[opts]?*)` pattern peels first option, `continue` restarts
- **noarg helper**: `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }`

### Anti-Patterns
- `while [[ $# -gt 0 ]]` → use `while (($#))`
- Missing `noarg` before shift → silent failure on missing arg
- Missing final `shift` → infinite loop
- `if/elif` chains → use `case` statement

**Ref:** BCS0801


---


**Rule: BCS0802**

## Version Output Format

**Output `<script_name> <version_number>` with space separator — no "version" word.**

```bash
# ✓ Correct
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong
-V|--version)   echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
```

**Why:** GNU standards; consistent with Unix utilities.

**Ref:** BCS0802


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Validation Helpers

| Helper | Purpose | Pattern |
|--------|---------|---------|
| `noarg()` | Existence check | `(($# > 1)) && [[ ${2:0:1} != '-' ]]` |
| `arg2()` | String + safe quoting | `((${#@}-1<1)) \|\| [[ "${2:0:1}" == '-' ]]` |
| `arg_num()` | Numeric validation | `[[ ! "$2" =~ ^[0-9]+$ ]]` |

### Implementation

```bash
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric argument" ||:; }

while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
esac; shift; done
```

### Key Points

- Call validator BEFORE `shift` (needs `$2`)
- `${1@Q}` safely quotes option in error messages
- Catches `--output --verbose` (missing filename) → prevents using next option as value

### Anti-Patterns

```bash
# ✗ No validation → --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# ✗ No numeric validation → --depth abc causes later arithmetic errors
-d|--depth) shift; MAX_DEPTH=$1 ;;
```

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

Top-level parsing in scripts >200 lines �' harder to test, pollutes global scope.

**Ref:** BCS0804


---


**Rule: BCS0805**

## Short-Option Disaggregation

**Split bundled options (`-abc` → `-a -b -c`) for Unix-compliant CLI parsing.**

## Iterative Method (Recommended)

53-119x faster than alternatives (~24,000-53,000 iter/sec), pure bash, no shellcheck warnings:

```bash
-[ovnVh]?*)  # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

**Mechanism:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder; `continue` restarts loop.

## Alternatives

| Method | Speed | Notes |
|--------|-------|-------|
| grep | ~445/sec | `set -- '' $(printf '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` — requires SC2046 |
| fold | ~460/sec | Same as grep, uses `fold -w1` |
| Bash loop | ~318/sec | Verbose, no external deps |

## Critical Rules

- Options with arguments → end of bundle or separate: `-vno out.txt` ✓, `-von out.txt` ✗
- Pattern lists valid options explicitly: `-[ovnVh]?*`
- Place before `-*)` invalid option case

## Anti-Patterns

- `./script -von out.txt` → `-o` captures `n` as argument
- Missing `continue` in iterative method → infinite loop

**Ref:** BCS0805


---


**Rule: BCS0900**

# File Operations

**Safe file handling: quote tests, explicit paths for globs, process substitution for variable preservation.**

## Core Rules

- **Test operators**: `-e` (exists), `-f` (file), `-d` (dir), `-r/-w/-x` (perms) — ALWAYS quote: `[[ -f "$file" ]]`
- **Safe wildcards**: Use explicit paths `rm ./*` → never `rm *`
- **Process substitution**: `while read -r line; do ... done < <(cmd)` preserves variables (avoids subshell)
- **Here-docs**: `<<'EOF'` (no expansion) vs `<<EOF` (with expansion)

## Example

```bash
[[ -f "$config" && -r "$config" ]] && source "$config"
while read -r f; do process "$f"; done < <(find . -name "*.log")
rm -f ./*.tmp  # Safe: explicit path
```

## Anti-patterns

- `rm *` → catastrophic if in wrong dir; use `rm ./*`
- `cmd | while read` → variables lost in subshell; use `< <(cmd)`

**Ref:** BCS0900


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
- `[[ -f $file ]]` �' `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` �' `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` without test �' validate first with `|| die`

**Ref:** BCS0901


---


**Rule: BCS0902**

## Wildcard Expansion

**Always use explicit `./*` path prefix for wildcard operations.**

Prevents filenames starting with `-` from being interpreted as command flags.

```bash
rm -v ./*                    # ✓ Safe
for f in ./*.txt; do         # ✓ Safe
# rm -v *                    # ✗ -file.txt becomes flag
```

**Ref:** BCS0902


---


**Rule: BCS0903**

## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to eliminate temp files and avoid subshell variable scope issues.**

**Rationale:** No temp file cleanup; preserves variables unlike pipes; enables parallel processing.

**Core patterns:**

```bash
# Compare outputs (no temp files)
diff <(sort file1) <(sort file2)

# Avoid subshell - variables preserved
declare -i count=0
while read -r line; do ((count+=1)); done < <(cat file)
echo "$count"  # Correct!

# Populate array safely
readarray -t files < <(find /data -type f -print0)
```

**Anti-patterns:**

```bash
# ✗ Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# ✗ Temp files when process sub works
temp=$(mktemp); sort file > "$temp"; diff "$temp" other; rm "$temp"
# �' Use: diff <(sort file) other
```

**When NOT to use:** Simple cases where direct methods work:
- `result=$(command)` �' not `result=$(cat <(command))`
- `grep pat file` �' not `grep pat < <(cat file)`
- `cmd <<< "$var"` �' not `cmd < <(echo "$var")`

**Ref:** BCS0903


---


**Rule: BCS0904**

## Here Documents

**Use heredocs for multi-line strings/input; quote delimiter to prevent expansion.**

`<<'EOF'` �' literal (no expansion) | `<<EOF` �' variables expand

```bash
cat <<'EOT'
Literal $VAR text
EOT

cat <<EOT
Expanded: $USER
EOT
```

**Anti-pattern:** Using `echo` with embedded newlines �' use heredoc instead.

**Ref:** BCS0904


---


**Rule: BCS0905**

## Input Redirection vs Cat

**Use `< file` instead of `cat file` to eliminate fork overhead: 3-100x speedup.**

### Key Rules

- **Command substitution**: `$(< file)` = 100x faster than `$(cat file)` (zero forks)
- **Single input**: `grep pat < file` = 3-4x faster than `cat file | grep pat`
- **Loops**: Fork overhead multiplies; 1000 iterations = 1000 avoided forks

### When cat Required

- Multiple files: `cat file1 file2`
- Cat options needed: `-n`, `-b`, `-A`, `-E`, `-s`
- `< file` alone does nothing (needs consuming command)

### Example

```bash
# CORRECT - Fast
content=$(< "$file")
grep ERROR < "$logfile"

# AVOID - Slow (forks cat)
content=$(cat "$file")
cat "$logfile" | grep ERROR
```

### Anti-patterns

| Avoid | Use |
|-------|-----|
| `$(cat file)` | `$(< file)` |
| `cat file \| cmd` | `cmd < file` |

**Ref:** BCS0905


---


**Rule: BCS1000**

# Security Considerations

**Production bash scripts require security-first practices across five areas: SUID/SGID prohibition, PATH validation, IFS safety, eval avoidance, and input sanitization.**

## Critical Rules

- **Never** use SUID/SGID on bash scripts → privilege escalation risk
- Lock down PATH: `PATH='/usr/local/bin:/usr/bin:/bin'` or validate explicitly
- Reset IFS: `IFS=$' \t\n'` to prevent word-splitting attacks
- **Avoid eval** → command injection; requires explicit justification if unavoidable
- Sanitize input early → prevent path traversal, injection vectors

## Minimal Example

```bash
#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
readonly user_input="${1:-}"
[[ "$user_input" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 1
```

## Anti-Patterns

- `eval "$user_data"` → injection
- Trusting inherited PATH/IFS → hijacking

**Ref:** BCS1000


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—critical security prohibition, no exceptions.**

### Why Dangerous

SUID/SGID changes effective UID/GID to file owner during execution. For scripts, kernel executes interpreter with elevated privileges, then interpreter processes script—creating attack vectors:

- **IFS/PATH manipulation**: Attacker controls word splitting or substitutes malicious interpreter before script's PATH is set
- **LD_PRELOAD injection**: Malicious code runs with root privileges before script executes
- **Race conditions**: TOCTOU vulnerabilities in file operations

### Correct Approach

```bash
# ✗ NEVER
chmod u+s /usr/local/bin/myscript.sh

# ✓ Use sudo with sudoers config
sudo /usr/local/bin/myscript.sh
# /etc/sudoers.d/myapp:
# username ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh
```

### Anti-Patterns

| Wrong | Right |
|-------|-------|
| `chmod u+s script.sh` | Configure sudoers, use `sudo` |
| `chmod g+s script.sh` | Use PolicyKit, systemd service, or compiled wrapper |

### Detection

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Key principle:** If you need SUID on a script, redesign using sudo, PolicyKit, systemd, or compiled wrapper.

**Ref:** BCS1001


---


**Rule: BCS1002**

## PATH Security

**Lock down PATH at script start to prevent command hijacking and trojan injection.**

**Rationale:**
- Attacker-controlled directories allow malicious binaries to replace system commands
- Empty PATH elements (`:`, `::`, trailing `:`) resolve to current directory
- PATH inherited from caller's environment may be malicious

**Secure PATH pattern:**
```bash
#!/bin/bash
set -euo pipefail
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Validate PATH (if not resetting):**
```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|:::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Anti-patterns:**
- `# No PATH setting` �' inherits untrusted environment
- `PATH=.:$PATH` �' current directory searchable
- `PATH=/tmp:$PATH` �' world-writable dir in PATH
- `PATH=::` or leading/trailing `:` �' empty = current dir
- Setting PATH late �' commands before it use inherited PATH

**Key:** Set `readonly PATH` immediately after `set -euo pipefail`. Use absolute paths (`/bin/tar`) for critical commands as defense in depth.

**Ref:** BCS1002


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust inherited IFS; always protect IFS changes to prevent field splitting attacks.**

**Why:** Attackers manipulate IFS to exploit word splitting �' command injection, privilege escalation, bypass validation.

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
# ✗ Global modification without restore
IFS=','
read -ra fields <<< "$data"
# IFS stays ',' for rest of script!

# ✗ Trusting inherited IFS
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

**Never use `eval` with untrusted input. Avoid entirely—safer alternatives exist for all common use cases.**

### Why It Matters
- **Code injection**: `eval` executes arbitrary code with full script privileges
- **Bypasses validation**: Sanitized input can still contain exploitable metacharacters
- **Better alternatives**: Arrays, indirect expansion, associative arrays cover all use cases

### Safe Alternatives

```bash
# ✗ eval for variable indirection
eval "value=\$$var_name"
# ✓ Indirect expansion
echo "${!var_name}"

# ✗ eval for dynamic assignment
eval "$var_name='$value'"
# ✓ printf -v
printf -v "$var_name" '%s' "$value"

# ✗ eval for command building
eval "$cmd"
# ✓ Array execution
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# ✗ eval for function dispatch
eval "${action}_function"
# ✓ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns
- `eval "$user_input"` → Use whitelist case statement
- `eval "$var='$val'"` → Use `printf -v`
- `eval "echo \$$var"` → Use `${!var}`

**Key principle:** If you think you need `eval`, use arrays, indirect expansion, or associative arrays instead.

**Ref:** BCS1004


---


**Rule: BCS1005**

## Input Sanitization

**Validate/sanitize all user input to prevent injection and traversal attacks.**

### Rationale
- Prevents command injection, directory traversal (`../../../etc/passwd`)
- Enforces expected data types; rejects invalid input early

### Core Patterns

**Filename sanitization:**
```bash
sanitize_filename() {
  local -- name=$1
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}
```

**Path containment:** Use `realpath -e` �' verify path starts with allowed dir.

**Numeric:** `[[ "$input" =~ ^[0-9]+$ ]]` �' reject leading zeros for integers.

**Whitelist choices:** Loop array, match exact �' `die` if no match.

### Critical Rules
- **Always use `--`** separator: `rm -- "$file"` prevents option injection
- **Never use `eval`** with user input
- **Whitelist > blacklist**: Define allowed chars, not forbidden ones

### Anti-patterns
```bash
# ✗ Trusting input
rm -rf "$user_dir"  # user_dir="/" = disaster

# ✓ Validate first
validate_path "$user_dir" "/safe/base"; rm -rf -- "$user_dir"
```

**Ref:** BCS1005


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` for temp files/dirs; use EXIT trap for cleanup; never hard-code paths.**

**Rationale:** mktemp creates files atomically with secure permissions (0600/0700); EXIT trap guarantees cleanup on failure/interruption; prevents race conditions and file collisions.

**Pattern:**

```bash
declare -a TEMP_FILES=()
cleanup() {
  local -- f; for f in "${TEMP_FILES[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"; [[ -d "$f" ]] && rm -rf "$f"
  done
}
trap cleanup EXIT

temp=$(mktemp) || die 1 'Failed to create temp file'
TEMP_FILES+=("$temp")
```

**Anti-patterns:**

```bash
# ✗ Hard-coded path �' predictable, no cleanup
temp=/tmp/myapp.txt

# ✗ Multiple traps overwrite each other
trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT  # t1 never cleaned!

# ✓ Single cleanup function for all resources
```

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

- `command &` without `pid=$!` �' cannot manage job later
- Using `$$` for background PID �' wrong; `$$` is parent, `$!` is child

**Ref:** BCS1101


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Execute multiple commands concurrently while tracking PIDs and collecting results.**

#### Rationale
- Significant speedup for I/O-bound tasks
- Better resource utilization

#### Basic Pattern (PID Tracking)

```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
```

#### Output Capture Pattern

Use temp files per job, cleanup via trap:
```bash
temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT
```

#### Concurrency Limit

Use `wait -n` with PID array, check `kill -0 "$pid"` to prune completed jobs.

#### Anti-Patterns

`count=0; { process; ((count++)); } &` �' subshell loses variable changes. Use temp files: `echo 1 >> "$temp"/count`, then `wc -l < "$temp"/count`.

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102


---


**Rule: BCS1103**

## Wait Patterns

**Always capture exit codes from `wait` and track failures across parallel jobs.**

#### Rationale
- Exit codes lost without capture �' silent failures
- Orphan processes consume resources
- Scripts hang on failed processes without proper tracking

#### Pattern

```bash
# Track multiple jobs with error collection
declare -a pids=()
for task in "${tasks[@]}"; do
  process_task "$task" &
  pids+=($!)
done

declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors++))
done
((errors)) && die 1 "$errors jobs failed"
```

#### Anti-Patterns

```bash
# ✗ Exit code lost
command &
wait $!

# ✓ Capture exit code
command &
wait $! || die 1 'Command failed'
```

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103


---


**Rule: BCS1104**

## Timeout Handling

**Use `timeout` command to prevent hanging on unresponsive commands; exit 124 = timeout.**

#### Rationale
- Prevents script hangs and resource exhaustion
- Critical for network operations and automated systems

#### Pattern

```bash
if timeout 30 long_running_command; then
  success 'Completed'
else
  ((exit_code=$?))
  ((exit_code == 124)) && warn 'Timed out' || error "Exit $exit_code"
fi

# Graceful kill: TERM first, KILL after grace period
timeout --signal=TERM --kill-after=10 60 command
```

**Exit codes:** 124=timeout, 125=timeout failed, 137=SIGKILL

#### Built-in Timeouts

```bash
read -r -t 10 -p 'Input: ' val          # read timeout
ssh -o ConnectTimeout=10 "$srv" cmd     # SSH timeout
curl --connect-timeout 10 --max-time 60 "$url"
```

#### Anti-Pattern

`ssh "$srv" cmd` �' `timeout 300 ssh -o ConnectTimeout=10 "$srv" cmd`

**Ref:** BCS1104


---


**Rule: BCS1105**

## Exponential Backoff

**Use exponential delay (`2^attempt`) for retry logic to handle transient failures without overwhelming services.**

#### Rationale
- Prevents thundering herd on failing services
- Enables automatic recovery from transient errors
- Configurable max attempts and delay caps

#### Pattern

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5} attempt=1
  shift
  while ((attempt <= max_attempts)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    ((++attempt))
  done
  return 1
}
```

**Enhancements:** Add `max_delay` cap; add jitter (`RANDOM % base_delay`) to prevent synchronized retries.

#### Anti-Patterns

`sleep 5` in loop �' `sleep $((2 ** attempt))` (fixed delay floods service)

`while ! cmd; do :; done` �' `retry_with_backoff 5 cmd` (immediate retry = DoS)

**Ref:** BCS1105


---


**Rule: BCS1200**

# Style & Development

**Code formatting, documentation, and development patterns for maintainable Bash.**

## Rules

| Rule | Focus |
|------|-------|
| BCS1201 | Indentation, line length, structure |
| BCS1202 | Comment style/placement |
| BCS1203 | Blank lines for readability |
| BCS1204 | Visual section delimiters |
| BCS1205 | Bash-specific idioms |
| BCS1206 | Version control, testing habits |
| BCS1207 | Debug output/tracing |
| BCS1208 | Dry-run for destructive ops |
| BCS1209 | Test structure/assertions |
| BCS1210 | Multi-stage operation tracking |

**Principle:** Consistent formatting enables maintainability by humans and AI.

**Ref:** BCS1200


---


**Rule: BCS1201**

## Code Formatting

**Use 2-space indentation (never tabs); keep lines ≤100 chars (URLs/paths exempt).**

### Core Rules
- 2 spaces per indent level, consistent throughout
- Line continuation: `\` for long commands
- Long paths/URLs may exceed limit

### Anti-patterns
`TAB` indentation �' 2 spaces | Lines >100 chars without justification �' wrap or split

**Ref:** BCS1201


---


**Rule: BCS1202**

## Comments

**Explain WHY (rationale, decisions) not WHAT (code already shows).**

```bash
# ✓ WHY - explains rationale
# PROFILE_DIR hardcoded for system-wide bash profile integration
declare -- PROFILE_DIR=/etc/profile.d
((max_depth > 0)) || max_depth=255  # -1 means unlimited

# ✗ WHAT - restates code
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d
```

**Good:** Business rules, intentional deviations, complex logic rationale, gotchas �' **Avoid:** Obvious code, self-explanatory names

**Icons:** `◉` info | `⦿` debug | `▲` warn | `✓` success | `✗` error

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
                                          # ← After metadata group
# Default values                          # ← Before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ← Before function
check_prerequisites() {
  info 'Checking...'
                                          # ← Between logical blocks
  if ! command -v gcc &>/dev/null; then
    die 1 'gcc not found'
  fi
}
                                          # ← Between functions
main() {
  check_prerequisites
}
```

### Anti-Patterns

- `✗` Multiple consecutive blank lines �' `✓` Single blank sufficient
- `✗` No separation between unrelated blocks �' `✓` Add visual breaks

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

**Anti-pattern:** Heavy box-drawing or 80-dash separators for minor groupings �' use simple `# Label` instead.

**Ref:** BCS1204


---


**Rule: BCS1205**

## Language Best Practices

**Use `$()` for command substitution; prefer builtins over external commands (10-100x faster).**

### Command Substitution
Always `$()` �' never backticks. Nests naturally without escaping.

```bash
outer=$(echo "inner: $(date +%T)")   # ✓ Clean nesting
outer=`echo "inner: \`date +%T\`"`   # ✗ Requires escaping
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
# ✓ Builtin - instant (no process creation)
result=$((i * 2))
string=${var,,}

# ✗ External - spawns process each call
result=$(expr $i \* 2)
string=$(echo "$var" | tr A-Z a-z)
```

**Use external only when no builtin exists:** `sha256sum`, `sort`, `whoami`.

### Anti-patterns
- `` `command` `` �' `$(command)`
- `[ -f "$file" ]` �' `[[ -f "$file" ]]`
- `$(expr $x + $y)` �' `$((x + y))`

**Ref:** BCS1205


---


**Rule: BCS1206**

## Development Practices

**ShellCheck mandatory; end scripts with `#fin`; program defensively.**

### ShellCheck
- **Compulsory** for all scripts: `shellcheck -x script.sh`
- Disable only with documented reason: `#shellcheck disable=SC2155  # reason`

### Script Termination
```bash
main "$@"
#fin
```

### Defensive Programming
```bash
: "${VERBOSE:=0}"              # Default values
[[ -n "$1" ]] || die 1 'Arg required'  # Validate early
set -u                         # Guard unset vars
```

### Performance
Minimize subshells �' use builtins over external commands �' batch ops �' process substitution over temp files.

### Testing
Testable functions, dependency injection, verbose/debug modes, meaningful exit codes.

**Ref:** BCS1206


---


**Rule: BCS1207**

## Debugging

**Use environment-controlled debug mode with enhanced trace output.**

**Rationale:** Environment variable control allows runtime debugging without code changes; enhanced PS4 provides file:line:function context.

```bash
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
```

**Anti-pattern:** Hardcoded debug flags �' use `DEBUG=${DEBUG:-0}` for runtime control.

**Ref:** BCS1207


---


**Rule: BCS1208**

## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `-n|--dry-run` flag.**

```bash
declare -i DRY_RUN=0
# Parse: -n|--dry-run) DRY_RUN=1 ;; -N|--not-dry-run) DRY_RUN=0 ;;

install_files() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' "  $BIN_DIR/app"
    return 0
  fi
  install -m 755 build/bin/app "$BIN_DIR"/
}
```

**Pattern:** Check `((DRY_RUN))` at function start → show `[DRY-RUN]` prefixed preview → `return 0` early.

**Anti-patterns:** Skipping dry-run in destructive functions → Silent dry-run (no preview output)

**Rationale:** Safe preview of destructive ops; identical control flow in both modes; users verify paths before execution.

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

- `find "$@"` directly �' cannot mock; use `FIND_CMD "$@"`
- Hardcoded paths �' use conditional `DATA_DIR` based on `TEST_MODE`

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

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

**Structure:** 1) Declare flags with defaults → 2) Parse args → 3) Adjust flags on conditions → 4) Execute on final state

**Key principles:**
- Separate user intent flags (`BUILTIN_REQUESTED`) from runtime state (`INSTALL_BUILTIN`)
- Disable features when prerequisites/builds fail (fail-safe)
- Never modify flags during execution phase

```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse: set flags from args
[[ $1 == --builtin ]] && { INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1; }

# Validate: adjust based on conditions
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0
check_support || { ((BUILTIN_REQUESTED)) && try_install || INSTALL_BUILTIN=0; }
((INSTALL_BUILTIN)) && ! build && INSTALL_BUILTIN=0

# Execute: act on final state
((INSTALL_BUILTIN)) && install_builtin
```

**Anti-patterns:**
- `if can_install && user_wants; then install; fi` → Nested conditions obscure why decisions made
- Modifying flags during execution phase → Unpredictable state

**Ref:** BCS1210
#fin
#fin
