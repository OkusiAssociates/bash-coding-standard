# Bash Coding Standard

**Bash 5.2+ standard; not a compatibility guide.**

## Principles
- K.I.S.S. — No over-engineering
- Remove unused functions/variables

## Sections
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

**All Bash scripts follow mandatory 13-step structural layout for consistency, safety, and maintainability.**

Covers: shebang → metadata → shopt → dual-purpose patterns → FHS compliance → file extensions → bottom-up function organization (utilities before orchestration).

**Ref:** BCS0100


---


**Rule: BCS010101**

### Complete Working Example

**Production-quality script demonstrating all 13 mandatory BCS0101 layout steps.**

---

## Minimal Example (Core Pattern)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CONFIG_VAR=${CONFIG_VAR:-default}
declare -i DRY_RUN=0

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    echo "Usage: $SCRIPT_NAME [-n]"; return 0 ;;
      -*)           echo "Invalid: $1" >&2; exit 22 ;;
    esac
    shift
  done
  readonly CONFIG_VAR DRY_RUN
  # Business logic here
}

main "$@"
#fin
```

## Key Patterns

- **Dry-run:** Every operation checks flag before executing
- **Derived paths:** Update dependents when base changes (`update_derived_paths()`)
- **Progressive readonly:** Variables immutable after argument parsing
- **Validation first:** Check prerequisites before filesystem operations

## Anti-Patterns

- `set -e` alone → Must use full `set -euo pipefail` + `inherit_errexit`
- Modifying readonly vars → Make mutable during parsing, readonly after

**Ref:** BCS010101


---


**Rule: BCS010102**

### Layout Anti-Patterns

**Avoid these 8 critical violations of the 13-step layout pattern.**

### Critical Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Missing `set -euo pipefail` | Silent failures, corruption | Always first after shebang |
| Variables after use | Unbound variable errors with `-u` | Declare all globals before functions |
| Business logic before utilities | Forward references, poor readability | Utilities → business logic → main |
| No `main()` in large scripts | Untestable, scattered args | Use `main()` for 200+ lines |
| Missing `#fin` | Can't detect truncation | Always end with `#fin` |
| Premature `readonly` | Can't modify during arg parsing | `readonly` after parsing complete |
| Scattered declarations | Hard to track state | Group all globals together |
| Unprotected sourcing | Modifies caller's shell | Guard with `[[ "${BASH_SOURCE[0]}" == "$0" ]]` |

### Correct Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # mutable until parsed

die() { (($#<2)) || >&2 echo "ERROR: ${*:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do case $1 in --prefix) shift; PREFIX=$1 ;; esac; shift; done
  readonly -- PREFIX
}

main "$@"
#fin
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Standard 13-step layout may be modified for: tiny scripts (<200 lines), sourced libraries, external config, platform detection, cleanup traps.**

#### When to Simplify
- **<200 lines**: Skip `main()`, run directly
- **Libraries**: Skip `set -e` (affects caller), skip `main()`, no execution block
- **One-off utilities**: May skip color/verbose features

#### When to Extend
- **External config**: Source between metadata and logic; make readonly *after* sourcing
- **Platform detection**: Add platform-specific globals after standard globals
- **Cleanup traps**: Set trap after cleanup function, before temp file creation

#### Core Example (Library)
```bash
#!/usr/bin/env bash
# Library - meant to be sourced, not executed
# No set -e (affects caller), no main()

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
#fin
```

#### Anti-Patterns
- `set -euo pipefail` after functions → error handling fails
- Globals scattered between functions → unpredictable state
- Arbitrary reordering without documented reason

#### Key Principles (Even When Deviating)
1. Safety first (`set -euo pipefail` unless library)
2. Dependencies before usage
3. Document *why* deviating

**Ref:** BCS010103


---


**Rule: BCS0101**

## BCS0101: Script Layout

**All Bash scripts follow 13-step bottom-up structure: infrastructure before implementation, utilities before business logic.**

### Rationale
- **Safe initialization**: `set -euo pipefail` runs before any commands; functions defined before called
- **Predictability**: Standard locations—metadata step 6, utilities step 9, business step 10
- **Error prevention**: Structure prevents undefined functions/variables classes of bugs

### 13 Steps (Executable Scripts)
1. `#!/bin/bash` 2. ShellCheck directives 3. Description comment 4. `set -euo pipefail` (MANDATORY first command) 5. `shopt -s inherit_errexit shift_verbose extglob nullglob` 6. Metadata (`VERSION`, `SCRIPT_PATH/DIR/NAME`) 7. Global declarations 8. Colors (if terminal) 9. Utility functions 10. Business logic 11. `main()` with arg parsing 12. `main "$@"` 13. `#fin`

### Minimal Example
```bash
#!/bin/bash
# Brief description
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
main() { echo "Hello"; }
main "$@"
#fin
```

### Anti-Patterns
- ✗ Missing `set -euo pipefail` → script continues after errors
- ✗ Business logic before utilities → undefined function calls

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts

**`set -euo pipefail` and `shopt` ONLY when executed directly, NEVER when sourced.** Sourcing applies settings to caller's shell, breaking their error handling.

**Pattern:** Functions first → early return for sourced → executable section with strict mode.

```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0
# --- Executable section ---
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
my_func "$@"
```

**Key points:**
- `return 0` exits cleanly when sourced; execution continues when run directly
- Guard metadata: `[[ ! -v VAR ]]` for safe re-sourcing
- Use `return` not `exit` for errors when sourced

**Anti-patterns:**
- `set -euo pipefail` at top of dual-purpose script → breaks caller's shell
- Missing `declare -fx` → functions unavailable to subshells when sourced

**Ref:** BCS010201


---


**Rule: BCS0102**

## Shebang and Initial Setup

**Every script starts: shebang → optional shellcheck → description → `set -euo pipefail`.**

**Shebangs:** `#!/bin/bash` (standard) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (portable PATH search)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Key:** `set -euo pipefail` must be first command—enables strict error handling before any execution.

**Ref:** BCS0102


---


**Rule: BCS0103**

## Script Metadata

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after shopt, before any other code.**

**Rationale:** Reliable path resolution via `realpath` fails early if script missing; SCRIPT_DIR enables resource loading; readonly prevents accidental modification.

**Pattern:**
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

source "$SCRIPT_DIR"/lib/common.sh
```

**Anti-patterns:**
- `SCRIPT_PATH="$0"` → use `realpath -- "$0"` (resolves symlinks/relative paths)
- `SCRIPT_DIR=$(dirname "$0")` → use `${SCRIPT_PATH%/*}` (parameter expansion faster)
- `SCRIPT_DIR=$PWD` → PWD is working dir, not script location

**Edge cases:** Root dir (`SCRIPT_DIR` empty) → add `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`; Sourced scripts → use `${BASH_SOURCE[0]}` instead of `$0`.

**Ref:** BCS0103


---


**Rule: BCS0104**

## FHS Preference

**Follow Filesystem Hierarchy Standard for scripts that install files or search for resources—enables predictable locations, multi-environment support, and package manager compatibility.**

### Rationale
- Predictable file locations (`/usr/local/bin/`, `/usr/share/`)
- Eliminates hardcoded paths; supports PREFIX customization
- Works across dev, local, system, and user installs

### Key Locations
- `/usr/local/{bin,share,lib,etc}/` — local installs
- `/usr/{bin,share}/` — system (package manager)
- `$HOME/.local/{bin,share}/` — user installs
- `${XDG_CONFIG_HOME:-$HOME/.config}/` — user config

### FHS Search Pattern
```bash
find_data_file() {
  local -a paths=("$SCRIPT_DIR"/"$1" /usr/local/share/app/"$1" /usr/share/app/"$1")
  local p; for p in "${paths[@]}"; do [[ -f "$p" ]] && { echo "$p"; return 0; }; done
  return 1
}
```

### Anti-Patterns
- `source /usr/local/lib/app/x.sh` → Use FHS search function
- `BIN_DIR=/usr/local/bin` hardcoded → `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

### When NOT to Use
Single-user scripts, project-specific tools, containers with custom paths.

**Ref:** BCS0104


---


**Rule: BCS0105**

## shopt

**Configure shell options for robust error handling and glob behavior.**

### Recommended Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

### Critical Options

| Option | Effect |
|--------|--------|
| `inherit_errexit` | Makes `set -e` work in `$(...)` subshells |
| `shift_verbose` | Error on shift when no args remain |
| `extglob` | Extended patterns: `!(*.txt)`, `@(jpg|png)` |
| `nullglob` | Unmatched glob → empty (for loops/arrays) |
| `failglob` | Unmatched glob → error (strict mode) |
| `globstar` | Enable `**` recursive matching (slow on deep trees) |

### Why `inherit_errexit` is Critical

```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!
# With inherit_errexit: exits as expected
```

### `nullglob` vs Default

```bash
# ✗ Default: unmatched glob stays literal
for f in *.txt; do rm "$f"; done  # Tries to delete "*.txt"!

# ✓ nullglob: unmatched → empty, loop skips
shopt -s nullglob
for f in *.txt; do rm "$f"; done  # Safe
```

**Ref:** BCS0105


---


**Rule: BCS0106**

## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` (non-executable); PATH commands: no extension.**

### Rationale
- No extension for PATH commands prevents implementation leakage (`myutil` not `myutil.sh`)
- `.sh` on libraries signals they're meant for sourcing, not direct execution

### Pattern
```bash
# Executable script (local use)
myscript.sh

# Library (source only, chmod 644)
lib_utils.sh

# PATH command (no extension)
/usr/local/bin/myutil
```

### Anti-patterns
- `myutil.sh` in PATH → exposes implementation detail
- Executable library → `source lib.sh` should be only invocation method

**Ref:** BCS0106


---


**Rule: BCS0107**

## Function Organization

**Organize functions bottom-up: primitives first → compositions → `main()` last. Dependencies flow downward only.**

**Why:** No forward references (Bash reads top-to-bottom); clear dependency hierarchy; debugging reads naturally.

**7-layer pattern:**
1. Messaging (`_msg`, `info`, `warn`, `error`, `die`)
2. Utilities (`noarg`, `trim`)
3. Documentation (`show_help`)
4. Validation (`check_prerequisites`)
5. Business logic (domain operations)
6. Orchestration (coordinate business logic)
7. `main()` → `main "$@"` → `#fin`

```bash
# Layer 1: Messaging (lowest)
_msg() { ... }
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4-5: Validation/Business
check_deps() { ... }
build() { check_deps; ... }

# Layer 7: main (highest)
main() { build; deploy; }
main "$@"
```

**Anti-patterns:**
- `main()` at top → forward reference errors
- Circular dependencies → extract common logic to lower layer
- Scattered messaging functions → group all at top

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Explicit `declare` with type hints ensures predictable behavior and prevents common shell errors.**

## Core Rules

- **Types**: `declare -i` (int), `declare --` (string), `declare -a` (array), `declare -A` (assoc)
- **Naming**: `UPPER_CASE` constants, `lower_case` variables
- **Scope**: `local` in functions; globals at script top only
- **Constants**: `declare -r` or `readonly` for immutables

## Rationale

1. Type declarations catch arithmetic errors at assignment vs runtime
2. Explicit scoping prevents accidental global state pollution
3. Readonly prevents silent overwrites of critical values

## Example

```bash
declare -r VERSION="1.0.0"
declare -i count=0
declare -- name="value"

func() {
    local -i result=0
    ((result = count + 1))
}
```

## Anti-patterns

- `count=0` → `declare -i count=0` (untyped allows string assignment)
- Global vars inside functions → use `local`

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `-a`, `-A`, `--`) for type safety, intent clarity, and bash's built-in type checking.**

**Rationale:** Type safety catches errors early; explicit types document intent; arrays prevent scalar assignment bugs.

**Declaration types:**
- `declare -i` — integers (counters, ports, exit codes)
- `declare --` — strings (paths, text); `--` prevents option injection
- `declare -a` — indexed arrays (lists)
- `declare -A` — associative arrays (key-value maps)
- `declare -r` — read-only constants
- `local --`/`local -i`/`local -a` — function-scoped variables

**Example:**
```bash
declare -i count=0 max_retries=3
declare -- config_path=/etc/app.conf
declare -a files=()
declare -A CONFIG=([timeout]='30' [retries]='3')

process() {
  local -- input=$1
  local -i attempts=0
  while ((attempts < max_retries)); do attempts+=1; done
}
```

**Anti-patterns:**
- `count=0` → `declare -i count=0` (unclear intent)
- `declare CONFIG` then `CONFIG[key]=val` → `declare -A CONFIG` (creates indexed, not associative)
- `local filename=$1` → `local -- filename=$1` (option injection risk if $1 is "-n")

**Ref:** BCS0201


---


**Rule: BCS0202**

## Variable Scoping

**Always declare function variables as `local` to prevent namespace pollution.**

- Without `local`: variables become global, overwrite existing globals, persist after return, break recursion
- Globals at top with `declare`; function vars always `local`

```bash
main() {
  local -a items=()    # Local array
  local -i count=0     # Local integer
  local -- name=$1     # Local string
}
```

**Anti-pattern:** `file=$1` → `local -- file=$1`

**Ref:** BCS0202


---


**Rule: BCS0203**

## Naming Conventions

**Use consistent case conventions: UPPER_CASE for constants/globals/exports, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Globals | UPPER_CASE/CamelCase | `VERBOSE=1` |
| Locals | lower_case | `local file_count=0` |
| Private funcs | _prefix | `_validate_input()` |
| Exports | UPPER_CASE | `export DATABASE_URL` |

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -i VERBOSE=1
process_data() {
  local -i line_count=0
}
_internal_helper() { :; }
```

**Why:** UPPER_CASE signals script-wide scope; lower_case locals prevent shadowing globals; underscore prefix prevents namespace conflicts.

**Anti-patterns:** `PATH`, `HOME`, `USER` as variable names → conflicts with shell; single lowercase letters (`a`, `n`) → reserved by shell.

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `readonly`/`declare -r` for immutable values; `export`/`declare -x` for subprocess visibility.**

| Attribute | `readonly` | `export` |
|-----------|------------|----------|
| Prevents modification | ✓ | ✗ |
| Subprocess access | ✗ | ✓ |

**Rationale:**
- `readonly` prevents accidental modification of constants (VERSION, paths)
- `export` required only when child processes need the value
- Combine with `declare -rx` for immutable exported values

**Pattern:**
```bash
declare -r VERSION=2.1.0              # Script constant
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Env for children
declare -rx BUILD_ENV=production      # Both: readonly + exported

# Allow override then lock
OUTPUT_DIR=${OUTPUT_DIR:-"$HOME"/output}
readonly -- OUTPUT_DIR
```

**Anti-patterns:**
- `export MAX_RETRIES=3` → Use `readonly` if children don't need it
- `CONFIG=/etc/app.conf` (unprotected) → Use `readonly -- CONFIG=...`
- `readonly -- VAR=default` before allowing override → Set default first, then `readonly`

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables first, then make entire group readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; makes immutability contract explicit; script fails if variable uninitialized before readonly.

**Three-step pattern** (for args/runtime config):
```bash
declare -i VERBOSE=0 DRY_RUN=0          # 1. Declare defaults
# 2. Parse/modify in main()
readonly -- VERBOSE DRY_RUN             # 3. Lock after parsing
```

**Standard groups:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors/paths/config**: readonly-after-group pattern

```bash
PREFIX=${PREFIX:-/usr/local}
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share
readonly -- PREFIX BIN_DIR SHARE_DIR    # All together
```

**Anti-patterns:**
```bash
# ✗ Premature readonly
PREFIX=/usr/local
readonly -- PREFIX    # Too early!
BIN_DIR="$PREFIX"/bin # Not protected if this fails

# ✗ Missing -- separator
readonly PREFIX       # Risky if name starts with -
```

**Key rules:**
- Initialize in dependency order → readonly together
- Always use `--` separator
- Delayed readonly after arg parsing: `readonly -- VERBOSE DRY_RUN`
- Conditional values: `[[ -z "$VAR" ]] || readonly -- VAR`

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

Anti-pattern: Mutable constants → `CONST=value` without `-r` allows reassignment.

**Ref:** BCS0206


---


**Rule: BCS0207**

## Arrays

**Always quote array expansions `"${array[@]}"` to preserve element boundaries and prevent word splitting.**

#### Core Operations

| Operation | Syntax |
|-----------|--------|
| Declare | `declare -a arr=()` |
| Append | `arr+=("value")` |
| Length | `${#arr[@]}` |
| All | `"${arr[@]}"` |
| Slice | `"${arr[@]:2:3}"` |
| Assoc | `declare -A map=()` |

#### Rationale

- Element boundaries preserved regardless of spaces/special chars
- `"${array[@]}"` prevents glob expansion and word splitting
- Safe command construction with arbitrary arguments

#### Example

```bash
declare -a cmd=(app --config "$cfg")
((verbose)) && cmd+=(--verbose) ||:
"${cmd[@]}"  # Execute safely

readarray -t lines < <(grep pat file)
for line in "${lines[@]}"; do process "$line"; done
```

#### Anti-Patterns

- `${arr[@]}` → `"${arr[@]}"` (unquoted breaks on spaces)
- `arr=($str)` → `readarray -t arr <<< "$str"` (word splitting)
- `"${arr[*]}"` in loops → `"${arr[@]}"` (single word vs multiple)

**Ref:** BCS0207


---


**Rule: BCS0208**

## Reserved for Future Use

**Placeholder for future Variables & Data Types expansion.**

Reserved to maintain BCS numbering sequence and prevent external reference conflicts.

#### Possible Future Topics

- Nameref variables (`declare -n`)
- Indirect expansion (`${!var}`)
- Variable attributes/introspection

**Status:** Reserved | Do not use in compliance checking.

**Ref:** BCS0208


---


**Rule: BCS0209**

## Derived Variables

**Compute variables from base values; group with section comments; update derived vars when base changes.**

**Rationale:**
- DRY: Single source of truth—change PREFIX once, all paths update
- Correctness: Forgetting to update derived vars after base changes causes subtle bugs

**Pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived paths (update these when base changes)
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf

# Update function for argument parsing
update_derived() {
  BIN_DIR="$PREFIX"/bin
  CONFIG_DIR=/etc/"$APP_NAME"
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}
```

**Anti-patterns:**

```bash
# ✗ Duplicating instead of deriving
BIN_DIR=/usr/local/bin  # Hardcoded, won't update with PREFIX

# ✗ Not updating derived vars when base changes
--prefix) PREFIX=$1 ;;  # BIN_DIR now wrong!

# ✓ Always update derived vars
--prefix) PREFIX=$1; update_derived ;;
```

**Key rules:**
- Group derived vars with `# Derived from PREFIX` comments
- Use `update_derived()` function when multiple vars need updating
- Make readonly AFTER all parsing complete
- XDG fallbacks: `${XDG_CONFIG_HOME:-"$HOME"/.config}`

**Ref:** BCS0209


---


**Rule: BCS0210**

## Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### When Braces Required
- **Expansion ops:** `${var:-default}` `${var##*/}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Concatenation (no separator):** `${var}suffix` `${a}${b}`
- **Arrays:** `${arr[@]}` `${arr[i]}` `${#arr[@]}`
- **Special:** `${10}` `${@:2}` `${!var}` `${#var}`

#### When Braces NOT Required
- Standalone: `"$var"` `"$HOME"` → not `"${var}"`
- With separators: `"$var/path"` `"$var-suffix"` → not `"${var}/path"`

#### Core Operations
```bash
${var##*/}      # Longest prefix removal
${var%/*}       # Shortest suffix removal
${var:-default} # Default if unset
${var:0:5}      # Substring
${var//old/new} # Replace all
${var,,}        # Lowercase (Bash 4+)
```

#### Anti-patterns
- `"${HOME}"` → `"$HOME"` (unnecessary braces)
- `"${PREFIX}/bin"` → `"$PREFIX/bin"` (separator delimits)

**Ref:** BCS0210


---


**Rule: BCS0211**

## Boolean Flags

**Use `declare -i` with 0/1 for boolean state; test with `(())`.**

### Why
- `(())` arithmetic returns proper exit codes (0=false, non-zero=true)
- Integer declaration prevents string pollution
- Explicit initialization prevents unset variable errors

### Pattern
```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && echo 'dry-run' ||:
if ((VERBOSE)); then debug_output; fi
```

### Anti-patterns
- `if [[ $FLAG == "true" ]]` → string comparison fragile
- `if [ $FLAG ]` → fails on unset or "0" string

**Ref:** BCS0211


---


**Rule: BCS0300**

# Strings & Quoting

**Quote all strings: single quotes for literals, double quotes for expansion.**

## Rules

| Code | Rule |
|------|------|
| BCS0301 | **Quoting Fundamentals** - `'literal'` vs `"$expand"` |
| BCS0302 | **Command Substitution** - Always quote `"$(cmd)"` |
| BCS0303 | **Conditionals** - Quote vars in `[[ "$var" ]]` |
| BCS0304 | **Here Documents** - `<<'EOF'` literal, `<<EOF` expand |
| BCS0305 | **printf** - `printf '%s\n' "$var"` |
| BCS0306 | **Parameter Quoting** - `${param@Q}` for safe display |
| BCS0307 | **Anti-Patterns** - Avoid unquoted expansions |

## Core Pattern

```bash
readonly MSG='Static text'           # Single: literal
echo "Hello, ${USER}"                # Double: expansion
file_list="$(ls -1)"                 # Always quote $()
[[ -n "$var" ]] && echo "$var"       # Quote in conditionals
printf '%s\n' "$@"                   # Quote arguments
```

## Critical Anti-Patterns

```bash
# WRONG → RIGHT
echo $var           → echo "$var"
cmd=$(ls)           → cmd="$(ls)"
[ -n $var ]         → [[ -n "$var" ]]
```

## Key Rationale

1. **Unquoted variables cause word-splitting** - `$var` with spaces becomes multiple args
2. **Single quotes prevent injection** - No expansion = no code execution
3. **ShellCheck enforces** - SC2086 catches unquoted expansions

**Ref:** BCS0300


---


**Rule: BCS0301**

## Quoting Fundamentals

**Single quotes for static strings; double quotes when variable expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: When variables must expand
- **Mixed**: `"Unknown '$1'"` → literal quotes around expanded value
- **Unquoted**: Simple alphanumeric (`a-zA-Z0-9_-.`) allowed: `STATUS=success`

**Mandatory quoting**: spaces, `@`, `*`, empty strings `''`, `$`, quotes, backslashes.

#### Path Concatenation

```bash
# Preferred - explicit boundaries
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"

# Acceptable
"$PREFIX/bin"
```

#### Anti-Patterns

```bash
# ✗ Double quotes for static
info "Processing..."        # → info 'Processing...'
[[ "$x" == "active" ]]      # → [[ "$x" == active ]]

# ✗ Special chars unquoted
EMAIL=user@domain.com       # → EMAIL='user@domain.com'
```

#### Quick Reference

| Content | Quote | Example |
|---------|-------|---------|
| Static | Single | `'text'` |
| Variable | Double | `"$var"` |
| Special chars | Single | `'@*.txt'` |

**Ref:** BCS0301


---


**Rule: BCS0302**

## Command Substitution

**Quote command substitution in strings; quote results when used.**

Variable assignment: quotes only needed with concatenation.
- `VERSION=$(git describe)` ✓
- `VERSION="$(git describe)".beta` ✓ (concatenation)
- `VERSION="$(git describe)"` ✗ (unnecessary)

```bash
# Assignment: no quotes needed
result=$(command)
# Usage: always quote to prevent word splitting
echo "$result"
echo "Found $(wc -l < "$file") lines"
```

**Anti-pattern:** `echo $result` → word splitting on whitespace.

**Ref:** BCS0302


---


**Rule: BCS0303**

## Quoting in Conditionals

**Always quote variables in conditionals.** Static literals: single quotes or unquoted one-word.

**Why:** Unquoted vars break on spaces/globs, empty vars cause syntax errors, security risk.

```bash
[[ -f "$file" ]]              # ✓ Variable quoted
[[ "$action" == 'start' ]]    # ✓ Literal single-quoted
[[ "$name" == *.txt ]]        # ✓ Glob pattern unquoted
[[ "$input" =~ $pattern ]]    # ✓ Regex pattern unquoted
```

**Anti-patterns:** `[[ -f $file ]]` → breaks with spaces; `[[ "$x" =~ "$pattern" ]]` → becomes literal match.

**Ref:** BCS0303


---


**Rule: BCS0304**

## Here Documents

**Quote delimiter (`<<'EOF'`) for literal content; unquoted (`<<EOF`) for variable expansion.**

#### Delimiter Behavior

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | JSON, SQL, literals |

`<<-EOF` strips leading tabs (not spaces).

#### Example

```bash
# Variables expand
cat <<EOF
User: $USER
EOF

# Literal (no expansion)
cat <<'EOF'
{"key": "$VAR"}
EOF
```

#### Anti-Pattern

`<<EOF` with untrusted data → SQL injection risk. Use `<<'EOF'` for literals with `$` symbols.

**Ref:** BCS0304


---


**Rule: BCS0305**

## printf Patterns

**Single-quote format strings, double-quote variable arguments. Prefer printf over echo -e for portable escape handling.**

#### Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format=single, args=double
echo 'Static text'                         # Static=single quotes
printf '%s\n' 'literal' "$var"            # Mixed: literal single, var double
```

#### Format Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

#### Anti-patterns

- `echo -e "text\n"` → behavior varies across shells; use `printf 'text\n'` or `$'text\n'`
- `printf "$var"` → format string injection; use `printf '%s' "$var"`

**Ref:** BCS0305


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of user input in error messages and logs.**

#### @Q Operator

`${var@Q}` expands to shell-quoted value safe for display/reuse.

```bash
name='$(rm -rf /)'
echo "${name@Q}"  # Output: '$(rm -rf /)' (literal, safe)

# Error messages - ALWAYS use @Q
die 2 "Unknown option ${1@Q}"
```

#### Behavior Comparison

| Input | `$var` | `${var@Q}` |
|-------|--------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | globs | `'*.txt'` |

#### When to Use

**Use @Q:** Error messages, logging input, dry-run display
**Don't use:** Normal expansion (`"$file"`), comparisons

#### Anti-Patterns

- `die "Unknown $1"` → injection risk
- `die "Unknown '$1'"` → still unsafe with embedded quotes

**Ref:** BCS0306


---


**Rule: BCS0307**

## Quoting Anti-Patterns

**Always quote variables; use single quotes for literals, double for expansions; braces only when required.**

#### Critical Anti-Patterns

| Wrong | Correct | Issue |
|-------|---------|-------|
| `"literal"` | `'literal'` | Unnecessary parsing |
| `$var` | `"$var"` | Word splitting/glob |
| `"${HOME}/bin"` | `"$HOME"/bin` | Unnecessary braces |
| `${arr[@]}` | `"${arr[@]}"` | Element splitting |

#### Braces Required For
```bash
"${var:-default}"    # Parameter expansion
"${file##*/}"        # Substring ops
"${array[@]}"        # Arrays
"${v1}${v2}"         # Adjacent vars
```

#### Glob Danger
```bash
pattern='*.txt'
echo $pattern    # ✗ Expands!
echo "$pattern"  # ✓ Literal
```

#### Here-doc
```bash
cat <<'EOF'      # ✓ Quoted = literal
cat <<EOF        # ✗ Variables expand
```

**Ref:** BCS0307


---


**Rule: BCS0400**

# Functions

**Use `lowercase_with_underscores` naming; organize bottom-up (utilities→helpers→logic→`main`); scripts >200 lines require `main()` function.**

## Organization

1. Messaging functions first
2. Helper utilities
3. Business logic
4. `main()` last (calls previously defined functions)

## Key Patterns

- Export for libraries: `declare -fx function_name`
- Remove unused utility functions in production scripts

## Minimal Example

```bash
log_info() { printf '[INFO] %s\n' "$1"; }
validate_input() { [[ -n "$1" ]] || return 1; }
process_data() { validate_input "$1" && log_info "Processing: $1"; }
main() { process_data "$@"; }
main "$@"
```

## Anti-patterns

- `camelCase` or `PascalCase` naming → use `snake_case`
- Defining `main()` before helper functions → bottom-up order

**Ref:** BCS0400


---


**Rule: BCS0401**

## Function Definition Pattern

**Use `fname() { }` syntax with `local` declarations at function start.**

### Key Rules
- Single-line for trivial ops: `fname() { cmd; }`
- Multi-line: `local -i` for integers, `local --` for strings
- Always `return "$exitcode"` with quoted variable

### Rationale
- `local` prevents variable leakage to global scope
- Typed locals (`-i`) catch assignment errors early

### Example
```bash
main() {
  local -i exitcode=0
  local -- result
  return "$exitcode"
}
```

### Anti-patterns
- `function fname` → use `fname()` (POSIX-compatible)
- Unquoted `return $var` → use `return "$var"`

**Ref:** BCS0401


---


**Rule: BCS0402**

## Function Names

**Use lowercase_underscores; prefix private functions with `_`.**

**Rationale:** Matches Unix conventions (`grep`, `sed`); avoids builtin conflicts; `_prefix` signals internal use.

```bash
process_log_file() { …; }     # ✓ Public
_validate_input() { …; }      # ✓ Private
MyFunction() { …; }           # ✗ CamelCase
```

**Anti-patterns:** Don't override builtins (`cd()`) → use `change_dir()`. Avoid dashes (`my-function`) → use underscores.

**Ref:** BCS0402


---


**Rule: BCS0403**

## Main Function

**Include `main()` for scripts >200 lines as single entry point; place `main "$@"` at script end before `#fin`.**

**Rationale:** Testability (source without executing), scope control (locals prevent global pollution), centralized exit code handling.

**When required:** >200 lines, multiple functions, argument parsing, complex flow. **Skip for:** trivial wrappers, linear scripts <200 lines.

**Core pattern:**
```bash
helper_func() { : ...; }

main() {
  local -i verbose=0; local -a files=()
  while (($#)); do case $1 in
    -v) verbose=1 ;; -h) show_help; return 0 ;;
    --) shift; break ;; -*) die 22 "Invalid: $1" ;;
    *) files+=("$1") ;;
  esac; shift; done
  files+=("$@"); readonly -a files
  # ... logic ...
  return 0
}
main "$@"
#fin
```

**Testable sourcing:** `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before main.

**Anti-patterns:** No main in complex scripts → untestable | main() not at end → undefined functions | `main` without `"$@"` → arguments lost | parsing args outside main → consumed before main called | mixing global/local state.

**Ref:** BCS0403


---


**Rule: BCS0404**

## Function Export

**Use `declare -fx` to export functions for subshell/subprocess access.**

### Rationale
- Subshells don't inherit functions without explicit export
- `export -f` is equivalent but `declare -fx` is more consistent with variable exports

### Example
```bash
grep() { /usr/bin/grep "$@"; }
declare -fx grep
```

### Anti-pattern
`→` Defining functions without export, then wondering why subprocess can't find them

**Ref:** BCS0404


---


**Rule: BCS0405**

## Production Script Optimization

**Remove all unused functions/variables before deployment.**

### Rationale
- Reduces script size and attack surface
- Eliminates maintenance burden for dead code

### Pattern
```bash
# Keep only what's called:
# ✓ error(), die() if used
# ✗ yn(), decp(), trim() if NOT used
# ✗ SCRIPT_DIR, DEBUG if NOT referenced
```

### Anti-patterns
- `source utils.sh` → using 2 of 20 functions
- Keeping "might need later" code in production

**Ref:** BCS0405


---


**Rule: BCS0406**

## Dual-Purpose Scripts

**Scripts that execute directly OR source as libraries via `BASH_SOURCE[0]` detection.**

#### Key Points
- Functions before `set -e`; `set -e` AFTER source check (library shouldn't impose error handling)
- Use `declare -fx` to export functions for subshells
- Idempotent init: `[[ -v LIB_VERSION ]] || declare -rx LIB_VERSION=...`

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

#### Anti-Patterns
- `set -e` before source check → risky `return 0`
- Missing `declare -fx` → functions unavailable in subshells

**See Also:** BCS0607, BCS0604

**Ref:** BCS0406


---


**Rule: BCS0407**

## Library Patterns

**Rule:** Create sourced-only libraries with namespace prefixes and no side effects.

**Rationale:** Code reuse, consistent interfaces, testability, namespace isolation.

#### Core Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Must be sourced
[[ "${BASH_SOURCE[0]}" != "$0" ]] || { >&2 echo 'Must be sourced'; exit 1; }

declare -rx LIB_MYAPP_VERSION=1.0.0

myapp_validate() { [[ $1 =~ ^[0-9]+$ ]]; }
declare -fx myapp_validate
```

#### Sourcing

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR"/lib-myapp.sh
[[ -f "$lib" ]] && source "$lib" || die 1 "Missing ${lib@Q}"
```

#### Configurable Defaults

```bash
: "${CONFIG_DIR:=/etc/myapp}"  # Override before sourcing
```

#### Anti-Patterns

- `source lib.sh` that modifies global state → require explicit `lib_init` call
- Unprefixed functions → always use `libname_funcname` pattern

**See Also:** BCS0606, BCS0608

**Ref:** BCS0407


---


**Rule: BCS0408**

## Dependency Management

**Use `command -v` to check dependencies; provide clear error messages for missing tools.**

---

#### Rationale
- Clear errors for missing tools vs cryptic failures
- Enables graceful degradation with optional deps
- Documents requirements explicitly

---

#### Dependency Check

```bash
# Single/multiple commands
command -v curl >/dev/null || die 1 'curl required'

for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && result=$(jq -r '.field' <<<"$json")
```

#### Version Check

```bash
((BASH_VERSINFO[0] < 5)) && die 1 "Requires Bash 5+"
```

---

#### Anti-Patterns

`which curl` → `command -v curl` (POSIX compliant)

Silent `curl "$url"` → Check first with helpful message

---

**See Also:** BCS0607 (Library Patterns)

**Ref:** BCS0408


---


**Rule: BCS0500**

# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic; avoid pipes to while loops due to subshell variable loss.**

## Core Rules

- `[[ ]]` over `[ ]` — safer word splitting, supports `&&`/`||`/regex
- `(( ))` for arithmetic conditions — no `$` needed inside
- Process substitution `< <(cmd)` preserves variables vs pipe to while
- Safe increment: `i+=1` or `((++i))` — avoid `((i++))` (fails at 0 with `set -e`)

## Pattern

```bash
while IFS= read -r line; do
    ((count++)) || true  # Safe with set -e
done < <(find . -type f)
[[ -n $line && $line != "#"* ]] && process "$line"
```

## Anti-patterns

- `cmd | while read` → variables lost in subshell
- `((i++))` with `set -e` → exits when i=0

**Ref:** BCS0500


---


**Rule: BCS0501**

## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

### Why `[[ ]]` over `[ ]`
- No word splitting/glob expansion on variables
- Pattern matching (`==`, `=~`), logical ops (`&&`, `||`) inside
- `<`/`>` for lexicographic comparison

### Core Pattern
```bash
[[ -f "$file" ]] && source "$file" ||:
[[ "$var" == pattern* ]] && process ||:
((count > MAX)) && die 1 'Limit exceeded' ||:
if [[ -n "$var" ]] && ((count)); then process; fi
```

### Anti-Patterns
- `[ ]` → use `[[ ]]`; `[ -a ]`/`[ -o ]` → use `[[ && ]]`/`[[ || ]]`
- `[[ "$n" -gt 5 ]]` → use `((n > 5))`

### File Tests (`[[ ]]`)
`-e` exists | `-f` file | `-d` dir | `-r` read | `-w` write | `-x` exec | `-s` non-empty | `-L` link | `-nt` newer | `-ot` older

### String Tests (`[[ ]]`)
`-z` empty | `-n` non-empty | `==` equal | `!=` not equal | `=~` regex | `<`/`>` lexicographic

**Ref:** BCS0501


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way branching on pattern matching; more readable/efficient than if/elif chains. Always include default `*)` case.**

**Rationale:** Single evaluation (faster than if/elif), native pattern matching with wildcards/alternation, exhaustive matching via `*)`

**When to use:** Single variable against multiple values, pattern matching, argument parsing
**When NOT to use:** Different variables, complex conditionals, numeric ranges → use if/elif

**Case expression:** No quotes needed (`case $1 in` not `case "$1" in`)

**Compact format** (single actions):
```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** (multi-line actions): Action on next line indented, `;;` on separate line, blank lines between cases.

**Pattern syntax:**
- Literals: `start)` → don't quote
- Wildcards: `*.txt)`, `???)`
- Alternation: `-h|--help)`
- Extglob: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`

**Anti-patterns:**
- Missing `*)` default → silent failures
- Quoting patterns: `"start")` → use `start)`
- Inconsistent alignment
- Nested case for multi-var → use if/elif
- Missing `;;` terminator

**Ref:** BCS0502


---


**Rule: BCS0503**

## Loops

**Use `for` for arrays/globs/ranges, `while` for streaming input/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

**Rationale:** Array iteration with quotes preserves element boundaries; pipe to while loses variable changes; `while ((1))` is 15-22% faster than `while true`.

**Core patterns:**

```bash
# Array iteration
for file in "${files[@]}"; do process "$file"; done

# Read file/command output (preserves variables)
while IFS= read -r line; do
  count+=1
done < <(find . -name '*.txt')

# C-style (use +=1 not ++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Infinite loop (fastest)
while ((1)); do work; [[ -f stop ]] && break; done
```

**Anti-patterns:**

```bash
# ✗ Pipe loses variables    → ✓ Use < <(cmd)
cat f | while read x; do n+=1; done  # n unchanged!

# ✗ Parse ls output         → ✓ Use glob directly
for f in $(ls *.txt); do  # for f in *.txt; do

# ✗ Unquoted array          → ✓ Quote expansion
for x in ${arr[@]}; do    # for x in "${arr[@]}"; do

# ✗ i++ fails at 0 with -e  → ✓ Use i+=1
for ((i=0; i<10; i++))    # for ((i=0; i<10; i+=1))

# ✗ Redundant comparison    → ✓ Arithmetic is truthy
while (($# > 0)); do      # while (($#)); do
```

**Ref:** BCS0503


---


**Rule: BCS0504**

## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variable changes are lost. Use `< <(cmd)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshells; variables modified inside vanish when the pipe ends. No error—just wrong values.

### Solutions

**Process substitution** (variables persist):
```bash
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep ERROR "$log")
echo "$count"  # Correct!
```

**readarray** (collect lines):
```bash
readarray -d '' -t files < <(find /data -print0)
```

**Here-string** (input in variable):
```bash
while read -r line; do count+=1; done <<< "$input"
```

### Anti-Patterns

```bash
# ✗ Pipe loses state
cat file | while read -r l; do arr+=("$l"); done  # arr stays empty!

# ✓ Process substitution
while read -r l; do arr+=("$l"); done < <(cat file)
```

### Key Points

- `| while` = subshell = lost variables (counters=0, arrays=empty)
- `< <(cmd)` runs loop in current shell
- `readarray -d ''` for null-delimited (safe filenames)
- Silent failure—test with actual data

**Ref:** BCS0504


---


**Rule: BCS0505**

## Arithmetic Operations

**Use `declare -i` for integers; use `i+=1` for increments; use `(())` for comparisons.**

### Core Rules

- **`declare -i`**: Required for all integers (enables auto-arithmetic context)
- **Increment**: Only `i+=1` — never `((i++))` (fails with `set -e` when i=0)
- **Comparisons**: Use `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` for non-zero checks

### Operators

`+` `-` `*` `/` `%` `**` | Comparisons: `<` `<=` `>` `>=` `==` `!=`

### Example

```bash
declare -i i=0 max=5
while ((i < max)); do
  process_item
  i+=1
done
((i < max)) || die 1 'Max reached'
```

### Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `((i++))` | `i+=1` |
| `[[ "$x" -gt 5 ]]` | `((x > 5))` |
| `((result = $i + $j))` | `((result = i + j))` |
| `expr $i + $j` | `$((i + j))` |

**Note:** Integer division truncates; use `bc` for floats.

**Ref:** BCS0505


---


**Rule: BCS0506**

## Floating-Point Operations

**Use `bc -l` or `awk` for float math; Bash only supports integers.**

#### Rationale
- Bash `$((...))` truncates: `$((10/3))` → 3, not 3.333
- `bc` returns 1/0 for comparisons; `awk` uses exit codes

#### bc Usage
```bash
result=$(echo '3.14 * 2.5' | bc -l)
# Comparison (1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then ...
```

#### awk Usage
```bash
result=$(awk -v w="$w" -v h="$h" 'BEGIN {printf "%.2f", w * h}')
# Comparison via exit code
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then ...
```

#### Anti-Patterns
```bash
# ✗ Integer division loses precision
result=$((10 / 3))  # → 3
# ✗ String comparison on floats
[[ "$a" > "$b" ]]   # lexicographic!
# ✓ Use bc/awk for numeric comparison
```

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506


---


**Rule: BCS0600**

# Error Handling

**Configure `set -euo pipefail` with `shopt -s inherit_errexit` before any commands to catch failures early.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures; prefer conditional checks over blanket suppression.

## Anti-patterns
- ✗ Missing `set -e` → silent failures propagate
- ✗ `set -e` after other commands → early errors missed

**Ref:** BCS0600


---


**Rule: BCS0601**

## Exit on Error

**Always use `set -euo pipefail` at script start for strict mode.**

- `-e`: Exit on command failure
- `-u`: Exit on undefined variable
- `-o pipefail`: Pipeline fails if any command fails

**Rationale:** Catches errors immediately; prevents cascading failures.

**Handling expected failures:**
```bash
command_that_might_fail || true      # Allow failure
if result=$(failing_cmd); then       # Check in conditional
  echo "$result"
fi
${OPTIONAL_VAR:-}                    # Safe undefined access
```

**Critical gotcha:** `result=$(failing_cmd)` exits before you can check `$result` → wrap in conditional or use `set +e`.

**Anti-patterns:**
- `set -e` after logic starts → must be at top
- Forgetting `pipefail` → `cmd1 | cmd2` hides `cmd1` failures

**Ref:** BCS0601


---


**Rule: BCS0602**

## Exit Codes

**Use consistent exit codes; 0=success, 1=general, 2=usage, 3-25=BCS categories.**

### die() Function
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### BCS Exit Codes (Key)

| Code | Name | Use |
|------|------|-----|
| 0 | SUCCESS | OK |
| 1 | ERR_GENERAL | Catchall |
| 2 | ERR_USAGE | CLI usage |
| 3 | ERR_NOENT | File not found |
| 8 | ERR_REQUIRED | Missing arg |
| 13 | ERR_ACCESS | Permission denied |
| 18 | ERR_NODEP | Missing dep |
| 22 | ERR_INVAL | Invalid arg |
| 24 | ERR_TIMEOUT | Timeout |

### Reserved: 64-78 (sysexits), 126-127 (Bash), 128+n (signals)

### Usage
```bash
[[ -f "$cfg" ]] || die 3 "Not found ${cfg@Q}"
command -v jq &>/dev/null || die 18 'Missing: jq'
```

### Anti-patterns
- `exit 1` for all errors → loses diagnostic info
- Codes 64+ → reserved ranges

**Ref:** BCS0602


---


**Rule: BCS0603**

## Trap Handling

**Use cleanup function with trap to ensure resource cleanup on exit, signals, or errors.**

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
| `SIGTERM` | kill command |

### Critical Rules

1. **Set trap BEFORE creating resources** - prevents leaks if script exits early
2. **Disable trap inside cleanup** - `trap - SIGINT SIGTERM EXIT` prevents recursion
3. **Preserve exit code** - capture `$?` in trap: `trap 'cleanup $?' EXIT`
4. **Single quotes** - `trap 'rm "$file"' EXIT` delays expansion until execution

### Anti-Patterns

```bash
trap 'rm "$f"; exit 0' EXIT      # → Always exits 0, loses real code
trap "rm $file" EXIT             # → Expands now, not at trap time
temp=$(mktemp); trap '...' EXIT  # → Set trap BEFORE mktemp
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values explicitly—`set -e` misses pipelines, command substitution, and conditionals.**

### Rationale
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution assignments
- Explicit checks enable contextual error messages and controlled cleanup

### Core Patterns

```bash
# Pattern 1: || die (concise)
mv "$src" "$dst/" || die 1 "Failed: ${src@Q} → ${dst@Q}"

# Pattern 2: || { } for cleanup
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Pattern 3: Command substitution
output=$(cmd) || die 1 'cmd failed'

# Pattern 4: Pipelines - use PIPESTATUS
cat f | grep p | sort
((PIPESTATUS[0] == 0)) || die 1 'cat failed'
```

### Critical Settings

```bash
set -euo pipefail
shopt -s inherit_errexit  # Bash 4.4+: cmd subst inherits set -e
```

### Anti-Patterns

- `mv "$f" "$d"`→No check, silent failure
- `cmd1; cmd2; (($?))`→Checks cmd2, not cmd1
- `die 1 'failed'`→No context; use `die 1 "Failed: ${var@Q}"`
- `out=$(cmd)` alone→Failure undetected without `|| die`

**Ref:** BCS0604


---


**Rule: BCS0605**

## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe; always document WHY.**

### Rationale
- Masks bugs, creates silent failures, security risks
- Suppressed errors make debugging impossible

### When Suppression is Safe
- **Existence checks**: `command -v tool >/dev/null 2>&1`
- **Optional cleanup**: `rm -f /tmp/app_* 2>/dev/null || true`
- **Idempotent ops**: `install -d "$dir" 2>/dev/null || true`

### When Suppression is DANGEROUS
- File operations, data processing, system config, security ops, required deps

```bash
# ✗ DANGEROUS - script continues with missing file
cp "$config" "$dest" 2>/dev/null || true

# ✓ Correct - fail explicitly
cp "$config" "$dest" || die 1 "Copy failed"
```

### Patterns
| Pattern | Use When |
|---------|----------|
| `2>/dev/null` | Suppress messages, still check return |
| `\|\| true` | Ignore return code |
| Both combined | Both irrelevant |

### Anti-Patterns
- `→` Suppressing critical ops (data, security, deps)
- `→` Suppressing without documenting why
- `→` Using `set +e` blocks instead of `|| true`
- `→` Redirecting entire function stderr

**Ref:** BCS0605


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Why:** `(())` returns exit code 1 when false → `set -e` terminates script. `:` is a no-op returning 0.

**Core pattern:**
```bash
set -euo pipefail
declare -i flag=0

# ✗ DANGEROUS: exits if flag=0
((flag)) && declare -g VAR=value

# ✓ SAFE: continues when flag=0
((flag)) && declare -g VAR=value || :
```

**Use for:** Optional declarations, conditional exports, feature-gated logging, verbose output.

**Anti-patterns:**
- `((cond)) && action` without `|| :` → script exits on false
- `((cond)) && critical_op || :` → hides critical failures; use explicit `if` with error handling instead

**When NOT to use:** Critical operations requiring error handling—use explicit `if` blocks with proper failure checks.

**Prefer `:` over `true`:** Traditional idiom, 1 char, no PATH lookup.

**Ref:** BCS0606


---


**Rule: BCS0700**

# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: data→STDOUT, diagnostics→STDERR.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core (uses FUNCNAME) | varies |
| `error()` | Errors | STDERR |
| `die()` | Exit with error | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDERR |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDERR |
| `vecho()` | Verbose output | STDERR |
| `yn()` | Yes/no prompts | STDERR |

## Stream Rules

- **STDOUT**: Script data/results only (pipeable)
- **STDERR**: All diagnostics, prompts, progress
- Place `>&2` at command start: `>&2 echo "error"`

## Example

```bash
error() { >&2 printf '%s\n' "ERROR: $*"; }
die() { error "$@"; exit 1; }
info() { >&2 printf '%s\n' "INFO: $*"; }
```

## Anti-patterns

- `echo "Error"` → `>&2 echo "Error"` (errors must go to STDERR)
- `echo >&2 "msg"` → `>&2 echo "msg"` (redirection at start)

**Ref:** BCS0700


---


**Rule: BCS0701**

## Color Support

**Test `[[ -t 1 && -t 2 ]]` before setting colors; empty strings when non-TTY.**

### Rationale
- Prevents escape codes corrupting pipes/files
- Enables automatic CI/log-safe output

### Pattern
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi
```

### Anti-patterns
- `RED='\033[0;31m'` unconditionally → corrupts redirected output
- Missing `-t 2` check → stderr escapes leak to logs

**Ref:** BCS0701


---


**Rule: BCS0702**

## STDOUT vs STDERR

**Errors → STDERR; place `>&2` at command start for clarity.**

### Rationale
- Enables `2>/dev/null` filtering without losing output
- Allows proper pipeline composition (stdout = data, stderr = diagnostics)

### Pattern
```bash
log_err() { >&2 echo "[$(date -Ins)]: $*"; }
```

### Anti-patterns
- `echo "Error"` → errors lost in stdout stream
- `echo "msg" >&2` → redirection at end less visible

**Ref:** BCS0702


---


**Rule: BCS0703**

## Core Message Functions

**Use `_msg()` core with `FUNCNAME[1]` inspection for DRY, auto-formatted messaging.**

### Rationale
- `FUNCNAME[1]` auto-detects caller → no format params, consistent output
- Single implementation, impossible to pass wrong level
- Proper streams: errors→stderr, data→stdout (enables `data=$(./script)`)

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

# Conditional (VERBOSE), unconditional (error), exit (die)
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ echo direct (no stderr, no prefix, no VERBOSE)
echo "Error: failed"
# ✓ error 'Failed'

# ✗ $(date) in log (subshell overhead)
echo "[$(date)] $*" >> "$LOG"
# ✓ printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG"
```

**Ref:** BCS0703


---


**Rule: BCS0704**

## Usage Documentation

**Provide structured `show_help()` with name, version, description, options, and examples.**

### Rationale
- Users need consistent, discoverable interface documentation
- Enables `--help` / `-h` patterns expected by Unix conventions

### Template
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -n|--num NUM      Set num to NUM
  -v|--verbose      Verbose output
  -h|--help         This help

Examples:
  $SCRIPT_NAME -v file.txt
EOT
}
```

### Anti-patterns
- Missing version/name variables → hardcoded strings break maintenance
- No examples section → users guess at syntax

**Ref:** BCS0704


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `success`, `warn`, `error`) for operational status to stderr; use `echo` for data output to stdout.**

**Rationale:**
- Stream separation enables pipelines (data=stdout, status=stderr)
- Messaging respects `VERBOSE`; `echo` always displays (critical for captures)
- Data output must be parseable without formatting interference

**Decision:** Status/progress → messaging. Data/help/reports → echo.

**Core Pattern:**
```bash
get_data() {
  info "Processing..."     # stderr, verbose-controlled
  echo "$result"           # stdout, always outputs (capturable)
}
show_help() { cat <<EOT
Usage: $SCRIPT_NAME [OPTIONS]
EOT
}
```

**Anti-patterns:**
```bash
# ✗ info() for data - goes to stderr, can't capture
get_email() { info "$email"; }
email=$(get_email)  # Empty!

# ✗ echo for status - mixes with data in pipeline
process() { echo "Processing..."; cat "$file"; }
```

**Rules:** Help/version → always echo. Errors → always stderr (`error()`). Data functions → echo only. Progress → messaging functions.

**Ref:** BCS0705


---


**Rule: BCS0706**

## Color Management Library

**Use dedicated color library with two-tier system, terminal auto-detection, and BCS _msg integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` — minimal namespace
- **Complete (12):** Basic + `BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE`

**Key Options:** `basic|complete`, `auto|always|never`, `flags` (sets VERBOSE/DEBUG/DRY_RUN/PROMPT), `verbose`

**Rationale:** Namespace control via tiered loading; centralized definitions; dual-purpose pattern (BCS010201).

**Usage:**
```bash
source color-set complete flags
echo "${RED}Error:${NC} Failed"
info "Starting"  # _msg integration ready
```

**Anti-patterns:**
- `color_set complete` when only basic needed → namespace pollution
- `[[ -t 1 ]]` only → must test both: `[[ -t 1 && -t 2 ]]`
- `color_set always` hardcoded → use `${COLOR_MODE:-auto}`

**Ref:** BCS0706


---


**Rule: BCS0707**

## TUI Basics

**Rule: BCS0707**

**TUI elements require terminal detection (`[[ -t 1 ]]`) before rendering visual output.**

#### Key Patterns

- **Spinner**: Background process with `kill` cleanup
- **Progress bar**: `\r` carriage return for in-place updates
- **Cursor control**: ANSI escapes (`\033[?25l` hide, `\033[?25h` show)
- **Always trap**: `trap 'show_cursor' EXIT` to restore cursor

#### Progress Bar

```bash
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' $((width - filled)) '' | tr ' ' '░')
  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}
```

#### Anti-Pattern

```bash
# ✗ TUI without terminal check → garbage output
progress_bar 50 100

# ✓ Check terminal first
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

**See Also:** BCS0708, BCS0701

**Ref:** BCS0707


---


**Rule: BCS0708**

## Terminal Capabilities

**Rule:** Detect terminal features with `[[ -t 1 ]]` before using colors/cursor control; provide graceful fallbacks.

**Why:** Prevents garbage output in pipes/redirects; ensures portability across environments.

#### Core Pattern

```bash
if [[ -t 1 ]]; then
  declare -r RED=$'\033[31m' NC=$'\033[0m'
  TERM_COLS=$(tput cols 2>/dev/null || echo 80)
else
  declare -r RED='' NC=''
  TERM_COLS=80
fi
```

#### Capabilities

- **Size:** `tput cols`/`tput lines` with 80/24 defaults; trap WINCH for resize
- **Colors:** `tput colors` → check `>=256` for extended palette
- **Unicode:** `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`

#### Anti-Patterns

`echo -e '\033[31mError\033[0m'` without TTY check → garbage in pipes
`printf '%-80s\n'` hardcoded → use `${TERM_COLS:-80}`

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708


---


**Rule: BCS0800**

# Command-Line Arguments

**Standard argument parsing with short (`-h`) and long (`--help`) options for consistent CLI interfaces.**

- Version format: `scriptname X.Y.Z`
- Validate required args, detect option conflicts
- Simple scripts: top-level parsing; Complex: main function

**Ref:** BCS0800


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all argument parsing.**

### Core Pattern
```bash
while (($#)); do case $1 in
  -o|--out)    noarg "$@"; shift; out=$1 ;;
  -v|--verbose) VERBOSE+=1 ;;
  -V|--version) echo "$NAME $VER"; exit 0 ;;
  -[ovV]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)          die 22 "Invalid option ${1@Q}" ;;
  *)           args+=("$1") ;;
esac; shift; done
```

### Key Rules
- **`noarg`**: `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }` — call before shift for options with args
- **Bundled shorts**: `-[ovV]?*` pattern splits `-vo out` → `-v -o out` iteratively
- **`VERBOSE+=1`**: Allows stacking (`-vvv` = 3)
- **Exit code 22**: EINVAL for invalid options

### Anti-Patterns
```bash
while [[ $# -gt 0 ]]; do  # → while (($#)); do
-o) shift; out=$1 ;;      # → noarg "$@"; shift; out=$1
esac; done                # → esac; shift; done (prevents infinite loop)
```

**Ref:** BCS0801


---


**Rule: BCS0802**

## Version Output Format

**Format: `<script_name> <version_number>` — no "version"/"v" prefix.**

```bash
# ✓ Correct
-V|--version)  echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong
echo "$SCRIPT_NAME version $VERSION"  # → "myscript version 1.2.3"
```

**Rationale:** GNU standard; avoids redundancy (bash outputs "GNU bash, version 5.2.15" not "version version").

**Ref:** BCS0802


---


**Rule: BCS0803**

## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Rationale
- Catches `--output --verbose` (missing filename) before silent failures
- Validates types at parse time → immediate clear errors vs. late arithmetic failures

### Three Validators

| Function | Purpose | Check |
|----------|---------|-------|
| `noarg()` | Existence | Has arg, not `-` prefixed |
| `arg2()` | String args | Same + `${1@Q}` quoting |
| `arg_num()` | Integers | Matches `^[0-9]+$` |

```bash
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric" ||:; }

while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; DEPTH=$1 ;;
esac; shift; done
```

### Anti-Patterns

```bash
# ✗ No validation → --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# ✓ Validate BEFORE shift
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
```

**Critical:** Call validator BEFORE `shift`—validator inspects `$2`.

**Ref:** BCS0803


---


**Rule: BCS0804**

## Argument Parsing Location

**Parse arguments inside `main()` rather than at top level.**

**Why:** Testability (test `main()` with different args), local variable scoping, encapsulation. Exception: simple scripts (<200 lines) may use top-level parsing.

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
  # main logic here
}
main "$@"
```

**Anti-pattern:** Top-level parsing in complex scripts → poor testability, polluted global scope.

**Ref:** BCS0804


---


**Rule: BCS0805**

## Short-Option Disaggregation

**Split bundled options (`-abc` → `-a -b -c`) for Unix-compliant argument parsing.**

## Iterative Method (Recommended)

```bash
-[ovnVh]?*)  # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

**How:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder with dash; `continue` reprocesses.

## Performance

| Method | Iter/Sec | Dependencies | Shellcheck |
|--------|----------|--------------|------------|
| **Iterative** | **24K-53K** | None | Clean |
| grep | ~445 | grep | SC2046 |
| fold | ~460 | fold | SC2046 |

**Iterative is 53-119× faster** with no external dependencies.

## Alternative: grep/fold

```bash
-[ovnVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

## Critical Rules

- **Pattern must list valid options:** `-[ovnVh]?*` prevents disaggregating unknown options
- **Options with arguments:** Must be at end of bundle or separate (`-vno out.txt` ✓, `-von out.txt` ✗)
- Place disaggregation case **before** `-*)` invalid option handler

## Anti-Patterns

```bash
# ✗ Missing continue (infinite loop)
-[ovnVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}" ;;

# ✗ Option with arg in middle of bundle
./script -von out.txt  # -o captures "n" as argument!
```

**Ref:** BCS0805


---


**Rule: BCS0900**

# File Operations

**Safe file handling: explicit paths, proper testing, process substitution.**

## File Tests
Quote variables: `[[ -f "$file" ]]`. Operators: `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` executable.

## Safe Wildcards
Always explicit paths → `rm ./*` never `rm *`. Prevents accidental deletion in wrong directory.

## Process Substitution
Avoid subshell variable loss: `while read -r line; do ...; done < <(command)`

## Here Documents
```bash
cat <<'EOF'
Multi-line content (single-quoted EOF = no expansion)
EOF
```

**Anti-patterns:** `rm *` (unsafe) → `rm ./*` | Unquoted `[[ -f $file ]]` → `[[ -f "$file" ]]`

**Ref:** BCS0900


---


**Rule: BCS0901**

## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests.**

### Key Operators

| Op | Test | Op | Test |
|----|------|----|------|
| `-f` | Regular file | `-r` | Readable |
| `-d` | Directory | `-w` | Writable |
| `-e` | Exists (any) | `-x` | Executable |
| `-L` | Symlink | `-s` | Non-empty |
| `-nt` | Newer than | `-ot` | Older than |

### Rationale

- `"$var"` prevents word splitting/glob expansion
- `[[ ]]` more robust than `[ ]` or `test`
- Test before use → prevents missing file errors

### Pattern

```bash
# Validate file exists and readable
[[ -f "$file" ]] || die 2 "Not found ${file@Q}"
[[ -r "$file" ]] || die 5 "Cannot read ${file@Q}"

# Ensure writable directory
[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ -w "$dir" ]] || die 5 "Not writable ${dir@Q}"
```

### Anti-Patterns

```bash
# ✗ Unquoted → breaks with spaces
[[ -f $file ]]
# ✓ Always quote
[[ -f "$file" ]]

# ✗ Silent failure
[[ -d "$dir" ]] || mkdir "$dir"
# ✓ Catch errors
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Failed ${dir@Q}"
```

**Ref:** BCS0901


---


**Rule: BCS0902**

## Wildcard Expansion

**Always use explicit path prefix (`./*`) with wildcards to prevent filenames starting with `-` from being interpreted as flags.**

```bash
# ✓ Correct
rm -v ./*
for f in ./*.txt; do process "$f"; done

# ✗ Wrong - `-rf` file becomes flag
rm *
```

**Rationale:** Files named `-rf` or `--help` become command flags without path prefix.

**Ref:** BCS0902


---


**Rule: BCS0903**

## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to treat command I/O as files, eliminating temp files and avoiding subshell variable scope issues.**

### Key Benefits
- **No temp files**: Data streams via FIFOs, no disk I/O
- **Preserves scope**: Unlike pipes, variables survive while loops
- **Parallel execution**: Multiple substitutions run simultaneously

### Core Patterns

```bash
# Compare outputs (no temp files)
diff <(sort file1) <(sort file2)

# Avoid subshell in while loop
declare -i count=0
while read -r line; do ((count++)); done < <(cat file)
echo "$count"  # Correct!

# Parallel processing with tee
cat log | tee >(grep ERROR > err.txt) >(wc -l > cnt.txt) >/dev/null
```

### Anti-Patterns

```bash
# ✗ Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
# ✗ Unquoted variables inside substitution
diff <(sort $file1) <(sort $file2)
```

→ Use `<<<` for simple variable input instead of `< <(echo "$var")`
→ Use direct `grep pattern file` instead of `grep pattern < <(cat file)`

**Ref:** BCS0903


---


**Rule: BCS0904**

## Here Documents

**Use heredocs for multi-line strings; quote delimiter to prevent expansion.**

| Syntax | Expansion |
|--------|-----------|
| `<<'EOT'` | None (literal) |
| `<<EOT` | Variables expand |

```bash
cat <<'EOT'    # No expansion
Literal $VAR
EOT

cat <<EOT      # Expands variables
User: $USER
EOT
```

**Ref:** BCS0904


---


**Rule: BCS0905**

## Input Redirection vs Cat

**Use `< file` instead of `cat file` for 3-100x speedup by eliminating fork/exec overhead.**

### Key Patterns

| Context | Anti-pattern → Correct | Speedup |
|---------|------------------------|---------|
| Command substitution | `$(cat f)` → `$(< f)` | **107x** |
| Single file input | `cat f \| cmd` → `cmd < f` | **3-4x** |
| Loops | Multiplied savings per iteration | **10-100x** |

### Why

- `cat`: fork→exec→load binary→read→exit→cleanup (7 steps)
- `<`: open fd→read→close (3 steps, no process)
- `$(< file)`: Bash reads directly, zero processes

### Example

```bash
# CORRECT
content=$(< "$file")
grep ERROR < "$logfile"

# WRONG - forks cat process
content=$(cat "$file")
cat "$logfile" | grep ERROR
```

### When cat IS Required

- Multiple files: `cat f1 f2`
- Options needed: `cat -n file`
- Direct output (standalone `< file` produces nothing)

**Ref:** BCS0905


---


**Rule: BCS1000**

# Security Considerations

**Prevent privilege escalation, command injection, and input attacks through PATH control, eval avoidance, and input sanitization.**

## Core Rules

- **No SUID/SGID**: Never set on bash scripts (security risk)
- **PATH**: Lock down or validate explicitly; prevent command hijacking
- **IFS**: Reset to default (`$' \t\n'`) to prevent word-splitting exploits
- **eval**: Avoid; if unavoidable, document justification and sanitize all inputs
- **Input**: Validate/sanitize user input at entry point

## Minimal Pattern

```bash
readonly PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
[[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid input"
```

## Anti-Patterns

- `eval "$user_input"` → injection vector
- Unvalidated PATH → command hijacking

**Ref:** BCS1000


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—critical security prohibition, no exceptions.**

### Why Dangerous

Multi-step execution (kernel→interpreter→script) creates attack vectors:
- **PATH manipulation**: Kernel uses caller's PATH to find interpreter → trojan attacks
- **LD_PRELOAD/LD_LIBRARY_PATH**: Inject malicious code before script runs
- **IFS exploitation**: Control word splitting with elevated privileges

### Anti-Patterns

```bash
# ✗ NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID
```

### Safe Alternatives

```bash
# ✓ Use sudo with sudoers config
sudo /usr/local/bin/myscript.sh

# /etc/sudoers.d/myapp:
# user ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh
```

Other options: PolicyKit (`pkexec`), systemd services, compiled C wrappers (sanitize env).

### Detection

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Key principle:** If you think you need SUID on a script, redesign using sudo/PolicyKit/systemd.

**Ref:** BCS1001


---


**Rule: BCS1002**

## PATH Security

**Lock down PATH at script start to prevent command hijacking and trojan injection.**

### Why

- Attacker-controlled PATH directories execute malicious binaries instead of system commands
- Empty elements (`::`, leading/trailing `:`) and `.` resolve to current directory
- Inherited PATH from caller's environment may be compromised

### Pattern

```bash
#!/bin/bash
set -euo pipefail

# Set immediately after shebang/strict mode
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

### Validation (if must use inherited PATH)

```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

### Anti-Patterns

```bash
# ✗ No PATH set → inherits potentially malicious environment
#!/bin/bash
ls /etc

# ✗ Current dir in PATH → trojans in cwd execute
export PATH=.:$PATH

# ✗ World-writable dir → attackers place trojans
export PATH=/tmp:$PATH

# ✗ Set too late → commands before this use inherited PATH
whoami
export PATH='/usr/bin:/bin'
```

### Custom Paths

```bash
readonly -- BASE_PATH='/usr/local/bin:/usr/bin:/bin'
export PATH="$BASE_PATH:/opt/myapp/bin"
readonly -- PATH
```

**Ref:** BCS1002


---


**Rule: BCS1003**

## IFS Manipulation Safety

**Never trust inherited IFS. Always protect IFS changes to prevent field splitting attacks.**

**Rationale:** Attackers manipulate IFS in calling environment to exploit word splitting; unprotected IFS enables command injection; changes cause global side effects breaking subsequent operations.

**Safe Patterns:**

```bash
# Pattern 1: One-line assignment (preferred) - applies only to command
IFS=',' read -ra fields <<< "$csv_data"

# Pattern 2: Set at script start, make readonly
IFS=$' \t\n'; readonly IFS; export IFS

# Pattern 3: Local scope in functions
local -- IFS; IFS=','

# Pattern 4: Save/restore
saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"

# Pattern 5: Subshell isolation
( IFS=','; read -ra fields <<< "$data" )
```

**Anti-patterns:**

```bash
# ✗ Modifying IFS without restore - breaks rest of script
IFS=','; read -ra fields <<< "$data"

# ✗ Trusting inherited IFS - vulnerable to manipulation
#!/bin/bash
read -ra parts <<< "$user_input"  # No IFS protection!
```

**Ref:** BCS1003


---


**Rule: BCS1004**

## Eval Command

**Never use `eval` with untrusted input. Avoid entirely—safer alternatives exist for all common use cases.**

### Rationale
- **Code injection**: Executes arbitrary code with full script privileges—complete system compromise
- **Double expansion**: `eval "echo $var"` expands `$var` twice, executing embedded commands
- **Unauditable**: Dynamic code construction defeats security review

### Safe Alternatives

```bash
# ✗ eval for variable indirection
eval "value=\$$var_name"
# ✓ Indirect expansion
echo "${!var_name}"

# ✗ eval for dynamic commands
eval "$cmd"
# ✓ Array execution
declare -a cmd=(find /data -name "*.txt")
"${cmd[@]}"

# ✗ eval for variable assignment
eval "$var_name='$value'"
# ✓ printf -v
printf -v "$var_name" '%s' "$value"

# ✗ eval for function dispatch
eval "${action}_function"
# ✓ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns
- `eval "$user_input"` → Use `case` whitelist or array execution
- `eval "$var='$val'"` → Use `printf -v` or associative arrays

**Ref:** BCS1004


---


**Rule: BCS1005**

## Input Sanitization

**Validate and sanitize all user input to prevent injection attacks and directory traversal.**

**Rationale:** Prevent injection/traversal attacks; fail early on invalid input; whitelist > blacklist.

**Core Pattern:**
```bash
sanitize_filename() {
  local -- name=$1
  [[ -n "$name" ]] || die 22 'Empty filename'
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}

validate_path() {
  local -- real_path
  real_path=$(realpath -e -- "$1") || die 22 "Invalid path"
  [[ "$real_path" == "$2"* ]] || die 5 "Path outside allowed dir"
  echo "$real_path"
}
```

**Critical Rules:**
- Use `--` separator → prevents option injection (`rm -- "$file"`)
- Whitelist validation → `[[ "$x" =~ ^[a-zA-Z0-9]+$ ]]`
- Never `eval` user input
- Validate type/format/range/length before use

**Anti-patterns:**
```bash
# ✗ Direct use without validation
rm -rf "$user_dir"        # user_dir="/" = disaster

# ✗ Blacklist (bypassable)
[[ "$input" != *'rm'* ]]  # Use whitelist instead

# ✓ Validate then use
user_dir=$(validate_path "$user_dir" "/safe/base")
rm -rf -- "$user_dir"
```

**Ref:** BCS1005


---


**Rule: BCS1006**

## Temporary File Handling

**Always use `mktemp` for temp files/dirs; never hard-code paths. Use EXIT trap for guaranteed cleanup.**

### Rationale
- **Security**: mktemp creates files with 0600 permissions atomically
- **Uniqueness**: Prevents collisions and race conditions
- **Cleanup**: EXIT trap ensures removal even on failure/interruption

### Pattern
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file
echo 'data' > "$temp_file"
```

For directories: `mktemp -d` with `rm -rf` in trap.

For multiple files, use array + cleanup function:
```bash
declare -a TEMP_FILES=()
cleanup() { for f in "${TEMP_FILES[@]}"; do rm -rf "$f"; done; }
trap cleanup EXIT
```

### Anti-Patterns
- `temp=/tmp/myapp.txt` → Predictable, collisions, no cleanup
- `trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT` → Second trap overwrites first; combine: `trap 'rm -f "$t1" "$t2"' EXIT`

**Ref:** BCS1006


---


**Rule: BCS1100**

# Concurrency & Jobs

**Parallel execution, job management, and wait strategies for Bash 5.2+.**

**5 Rules:** Background Jobs (BCS1101) • Parallel Execution (BCS1102) • Wait Patterns (BCS1103) • Timeout Handling (BCS1104) • Exponential Backoff (BCS1105)

**Key:** Always clean up background jobs; handle partial failures gracefully.

**Ref:** BCS1100


---


**Rule: BCS1101**

## Background Job Management

**Always track PIDs with `$!` and implement cleanup traps for background processes.**

#### Rationale
- Enables parallel processing and non-blocking execution
- Proper cleanup prevents orphaned processes on termination

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
- `$!` — last background PID → `kill -0 "$pid"` — check if running → `wait "$pid"` — block until done

#### Anti-Patterns
- `command &` without `pid=$!` → cannot manage/wait later
- Using `$$` for background PID → wrong (parent PID, not child)

**Ref:** BCS1101


---


**Rule: BCS1102**

## Parallel Execution Patterns

**Execute multiple commands concurrently using PID arrays and wait loops.**

**Why:** I/O-bound speedup; better resource utilization; efficient batch processing.

#### Pattern

```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || true; done
```

**Output capture:** Use temp files (`mktemp -d`) per job, display in order after all complete.

**Concurrency limit:** Track active PIDs with `kill -0`, use `wait -n` to reap completed jobs.

#### Anti-Pattern

```bash
# ✗ Variable lost in subshell
count=0; for t in "${tasks[@]}"; do { process "$t"; ((count++)); } & done
echo "$count"  # Always 0!
# ✓ Use temp files: echo 1 >> "$temp"/count; count=$(wc -l < "$temp"/count)
```

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102


---


**Rule: BCS1103**

## Wait Patterns

**Always capture wait exit codes; use `wait -n` for first-completion processing.**

**Rationale:** Ensures exit codes captured correctly, prevents hangs on failed processes.

#### Patterns

```bash
# Basic: capture exit code
cmd &; wait "$!" || die 1 'failed'

# Multiple jobs with error tracking
for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done

# First-completion (Bash 4.3+): wait -n
```

#### Anti-Pattern

`wait $!` without checking return → `wait $! || die 1 'msg'`

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103


---


**Rule: BCS1104**

## Timeout Handling

**Prevent hangs: wrap commands with `timeout`, check exit 124 for timeout condition.**

Exit codes: 124=timed out, 125=timeout failed, 137=SIGKILL (128+9)

#### Pattern

```bash
if timeout 30 long_command; then
  echo 'Done'
elif (($? == 124)); then
  echo 'Timed out'
fi

# Graceful: TERM first, KILL after 10s
timeout --signal=TERM --kill-after=10 60 cmd
```

#### Built-in Timeouts

- `read -t 10` → input timeout
- `ssh -o ConnectTimeout=10` → connection timeout
- `curl --connect-timeout 10 --max-time 60` → request timeout

#### Anti-Pattern

`ssh "$server" 'cmd'` → hangs forever. Use: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'cmd'`

**See Also:** BCS1105 (Exponential Backoff)

**Ref:** BCS1104


---


**Rule: BCS1105**

## Exponential Backoff

**Rule: BCS1105** — Implement retry logic with exponential delay for transient failures.

#### Rationale
- Reduces load on failing services (prevents thundering herd)
- Enables automatic recovery without manual intervention

#### Pattern

```bash
retry_with_backoff() {
  local -i max=5 attempt=1 delay
  while ((attempt <= max)); do
    "$@" && return 0
    delay=$((2 ** attempt))
    sleep "$delay"
    attempt+=1
  done
  return 1
}
```

**Jitter:** Add `jitter=$((RANDOM % delay))` to prevent synchronized retries.

**Cap:** Use `((delay > 60)) && delay=60 ||:` to limit maximum delay.

#### Anti-Patterns

`while ! cmd; do sleep 5; done` → Fixed delay doesn't reduce pressure

`while ! curl "$url"; do :; done` → Immediate retry floods service

**See Also:** BCS1104 (Timeout), BCS1101 (Background Jobs)

**Ref:** BCS1105


---


**Rule: BCS1200**

# Style & Development

**Consistent formatting and documentation for maintainable scripts.**

## Rules (10)

| ID | Rule | Core Requirement |
|----|------|------------------|
| BCS1201 | Code Formatting | 4-space indent, 80-char lines, structured blocks |
| BCS1202 | Comments | `#` with space, explain why not what |
| BCS1203 | Blank Lines | Single between logical blocks, two before functions |
| BCS1204 | Section Markers | `#--- SECTION ---#` delimiters for major sections |
| BCS1205 | Language Practices | Use `[[`, `(())`, prefer builtins over externals |
| BCS1206 | Development Practices | Version control, incremental testing, shellcheck |
| BCS1207 | Debugging | `DEBUG` flag gates trace output |
| BCS1208 | Dry-Run Mode | `DRY_RUN` prevents destructive ops, shows intent |
| BCS1209 | Testing | Assertions, edge cases, exit code verification |
| BCS1210 | Progressive State | Track multi-stage operations with state variables |

## Essential Pattern

```bash
#--- CONFIGURATION ---#
readonly DEBUG="${DEBUG:-false}"
readonly DRY_RUN="${DRY_RUN:-false}"

#--- MAIN ---#
main() {
    [[ "$DEBUG" == "true" ]] && set -x
    [[ "$DRY_RUN" == "true" ]] && echo "[DRY-RUN] Would execute"
}
```

## Anti-patterns

- `#no space` → `# with space`
- Mixing tabs/spaces → consistent 4-space indent
- No section markers in 100+ line scripts

**Ref:** BCS1200


---


**Rule: BCS1201**

## Code Formatting

**Use 2-space indentation (no tabs), lines under 100 chars.**

### Rules
- **Indentation**: 2 spaces, consistent throughout
- **Line length**: ≤100 chars; paths/URLs may exceed; use `\` for continuation

### Rationale
- 2-space aligns with Google Shell Style Guide
- Consistent indentation enables automated linting

### Example
```bash
process_files() {
  local file
  for file in "${files[@]}"; do
    validate "$file" \
      && process "$file"
  done
}
```

### Anti-patterns
- `→` Tabs or 4-space indent
- `→` Lines >100 chars without continuation

**Ref:** BCS1201


---


**Rule: BCS1202**

## Comments

**Comment WHY (rationale, decisions), not WHAT (code shows that).**

### Good vs Bad

```bash
# ✓ WHY: hardcoded for system-wide profile integration
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited

# ✗ BAD: "Set PROFILE_DIR to /etc/profile.d" → restates code
```

### Patterns

**Comment:** business rules, intentional deviations, complex logic, approach rationale, gotchas
**Skip:** obvious assignments, self-explanatory code, standard patterns

### Icons

`◉` info | `⦿` debug | `▲` warn | `✓` success | `✗` error

**Ref:** BCS1202


---


**Rule: BCS1203**

## Blank Line Usage

**Use single blank lines to visually separate logical blocks.**

**Guidelines:**
- One blank between functions, logical sections, section comments, variable groups
- Blank lines before/after multi-line conditionals/loops
- Never multiple consecutive blanks → one is sufficient
- No blank needed between short related statements

```bash
#!/bin/bash
set -euo pipefail

declare -r VERSION=1.0.0
                                # ← After variable group
check_prerequisites() {
  info 'Checking...'
                                # ← Between logical sections
  if ! command -v gcc &>/dev/null; then
    die 1 "'gcc' not found"
  fi
}
                                # ← Between functions
main() {
  check_prerequisites
}

main "$@"
```

**Anti-patterns:** Multiple consecutive blanks → wastes space, inconsistent separation → harder to scan

**Ref:** BCS1203


---


**Rule: BCS1204**

## Section Comments

**Use lightweight `# Description` comments (2-4 words) to group related code; reserve 80-dash separators for major divisions only.**

### Key Points
- Simple format: `# Default values` → no dashes/boxes
- Place immediately before group, blank line after
- Group related variables, functions, or logical blocks

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
`# Default values` `# Derived paths` `# Helper functions` `# Business logic` `# Validation`

**Ref:** BCS1204


---


**Rule: BCS1205**

## Language Best Practices

**Use `$()` for command substitution and prefer builtins over external commands for 10-100x performance gains.**

### Command Substitution
Use `$()` not backticks → nests naturally, better readability.

```bash
# ✓ Modern - nests cleanly
outer=$(echo "inner: $(date +%T)")

# ✗ Deprecated - requires escaping
outer=`echo "inner: \`date +%T\`"`
```

### Builtins vs External Commands
Builtins: no process spawn, no PATH dependency, no pipe failures.

| External | Builtin |
|----------|---------|
| `expr $x + $y` | `$((x + y))` |
| `basename "$p"` | `${p##*/}` |
| `dirname "$p"` | `${p%/*}` |
| `tr A-Z a-z` | `${var,,}` |
| `[ -f ]` | `[[ -f ]]` |
| `seq 1 10` | `{1..10}` |

```bash
# ✓ Builtin - instant
result=$((i * 2))
string=${var,,}

# ✗ External - spawns process each call
result=$(expr $i \* 2)
```

Use externals only when no builtin exists (sha256sum, sort, whoami).

**Ref:** BCS1205


---


**Rule: BCS1206**

## Development Practices

**ShellCheck is compulsory; end scripts with `#fin`; program defensively.**

### Core Requirements

1. **ShellCheck**: Run `shellcheck -x` on all scripts; disable only with documented reason
2. **Termination**: End with `main "$@"` then `#fin` marker
3. **Defensive**: Use `set -u`, validate inputs early, provide defaults

### Rationale
- ShellCheck catches 80%+ common bugs automatically
- Markers enable tooling to verify complete scripts

### Example
```bash
#!/usr/bin/env bash
set -euo pipefail
: "${VERBOSE:=0}"
[[ -n "${1:-}" ]] || { echo "Arg required" >&2; exit 1; }
main "$@"
#fin
```

### Anti-patterns
- `#shellcheck disable` without comment → unexplained exceptions
- Missing `set -u` → silent failures from typos

**Ref:** BCS1206


---


**Rule: BCS1207**

## Debugging and Development

**Use `DEBUG` env var with `set -x` and enhanced `PS4` for trace debugging.**

```bash
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
```

**Anti-patterns:** Hardcoded debug flags → use env var; bare `set -x` → loses context without PS4

**Ref:** BCS1207


---


**Rule: BCS1208**

## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `DRY_RUN` flag with early return.**

### Pattern

```bash
declare -i DRY_RUN=0
-n|--dry-run) DRY_RUN=1 ;;

func() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would do X'
    return 0
  fi
  # actual operations
}
```

### Key Points

- Check `((DRY_RUN))` at function start → show `[DRY-RUN]` prefix → `return 0`
- Same control flow in both modes (identical function calls/logic paths)
- Safe preview of destructive ops; verify paths/commands before execution

### Anti-Patterns

- `if ! ((DRY_RUN)); then ...` → inverted logic obscures intent
- Skipping dry-run for "minor" operations → inconsistent preview

**Ref:** BCS1208


---


**Rule: BCS1209**

## Testing Support Patterns

**Make scripts testable via dependency injection, test mode flags, and assertion helpers.**

### Core Techniques

1. **Dependency Injection**: Wrap external commands in overridable functions
2. **TEST_MODE Flag**: Toggle test vs production behavior
3. **Assert Helper**: Standardized comparison with failure output

### Pattern

```bash
# Dependency injection - override in tests
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

# Assert helper
assert() {
  [[ "$1" == "$2" ]] && return 0
  >&2 echo "FAIL: ${3:-Assertion failed}: '$1' != '$2'"
  return 1
}
```

### Anti-Patterns

- `rm -rf` directly → Use `RM_CMD` wrapper for testability
- Hardcoded paths → Use configurable `DATA_DIR` variables

**Ref:** BCS1209


---


**Rule: BCS1210**

## Progressive State Management

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

**Structure:** 1) Declare flags with defaults → 2) Parse args → 3) Adjust by runtime conditions → 4) Execute on final state

```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse: set flags from user input
[[ $1 == --builtin ]] && { INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1; }

# Validate: adjust based on conditions
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0
check_builtin_support || INSTALL_BUILTIN=0

# Execute: act on final state only
((INSTALL_BUILTIN)) && install_builtin
```

**Key principles:**
- Separate user intent flag (`REQUESTED`) from runtime state (`INSTALL`)
- Never modify flags during execution phase
- State changes in logical order: parse → validate → execute

**Anti-patterns:**
- Mixing state decisions with execution → unmaintainable control flow
- Single flag for both intent and state → loses "why" information

**Ref:** BCS1210
#fin
