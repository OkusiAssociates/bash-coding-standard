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

**All Bash scripts follow mandatory 13-step structural layout for consistency, maintainability, and safe initialization.**

Core elements: shebang â†' metadata â†' shopt settings â†' dual-purpose patterns â†' FHS compliance â†' extension guidelines â†' bottom-up function organization (low-level utilities before high-level orchestration).

Key principles:
- Consistent initialization order prevents subtle bugs
- FHS compliance ensures system integration
- Bottom-up organization enables function dependencies

**Ref:** BCS0100


---


**Rule: BCS010101**

### Complete Working Example

**Production installation script demonstrating all 13 BCS0101 mandatory steps.**

---

## Core Pattern (Minimal)

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- PREFIX=/usr/local
declare -i DRY_RUN=0 VERBOSE=1

main() {
  while (($#)); do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -h|--help)    show_help; return 0 ;;
      -*)           die 22 "Invalid option ${1@Q}" ;;
    esac
    shift
  done
  readonly PREFIX DRY_RUN VERBOSE
  # business logic here
}
main "$@"
#fin
```

## Key Elements

| Step | Purpose |
|------|---------|
| 1-5 | Shebang, shellcheck, description, strict mode, shopt |
| 6-7 | Metadata (VERSION, SCRIPT_*), globals |
| 8-9 | Colors (TTY-aware), utility functions |
| 10-11 | Business logic, main() with arg parsing |
| 12-13 | `main "$@"`, `#fin` marker |

## Critical Patterns

- **Dry-run**: Check `((DRY_RUN))` before every operation
- **Derived paths**: Update dependent vars when base changes
- **Progressive readonly**: Lock vars after argument parsing
- **Validation first**: Check prerequisites before filesystem ops

## Anti-patterns

- âœ— Modifying readonly vars after `readonly` declaration
- âœ— Missing `#fin` end marker

**Ref:** BCS010101


---


**Rule: BCS010102**

### Layout Anti-Patterns

**Avoid these 8 critical violations of BCS0101 13-step layout to prevent silent failures and unmaintainable code.**

#### Critical Anti-Patterns

| Anti-Pattern | Consequence |
|--------------|-------------|
| Missing `set -euo pipefail` | Silent failures, corrupt operations |
| Variables used before declaration | "Unbound variable" errors with `set -u` |
| Business logic before utilities | Forward references, harder to understand |
| No `main()` in large scripts (200+ lines) | No clear entry point, untestable |
| Missing `#fin` end marker | Cannot detect truncated files |
| `readonly` before argument parsing | Cannot modify config vars |
| Scattered global declarations | State variables hard to track |
| Unprotected sourcing | Modifies caller's shell, auto-runs |

#### Correct Pattern (Minimal)

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # Modified during parsing

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do case $1 in --prefix) shift; PREFIX=$1 ;; esac; shift; done
  readonly -- PREFIX
}

main "$@"
#fin
```

#### Dual-Purpose Script Guard

```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102


---


**Rule: BCS010103**

### Edge Cases and Variations

**Standard 13-step layout may be simplified/extended for specific scenarios.**

#### Skip `main()` (<200 lines)
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
for file in "$@"; do [[ ! -f "$file" ]] || ((count++)); done
#fin
```

#### Libraries (sourced files)
Skip `set -e` (affects caller), skip `main()`, define functions only.

#### Extensions
- **Config sourcing**: After metadata, before `readonly`
- **Platform detection**: After globals, use `case $(uname -s)`
- **Cleanup traps**: After function defs, before temp file creation: `trap 'cleanup $?' SIGINT SIGTERM EXIT`

#### Key Principles
1. `set -euo pipefail` still first (unless library)
2. Dependencies before usage
3. Document deviations

#### Anti-patterns
`set -e` after functions â†' **Wrong**: safety must come first
Globals scattered between functions â†' **Wrong**: group declarations

**Ref:** BCS010103


---


**Rule: BCS0101**

## Script Layout

**All scripts follow 13-step bottom-up structure: infrastructure â†' implementation â†' orchestration.**

### Rationale
1. **Safe initialization** - `set -euo pipefail` runs before any commands
2. **Dependency resolution** - functions defined before they're called
3. **Predictability** - components always in same location

### The 13 Steps

| # | Element | Required |
|---|---------|----------|
| 1 | `#!/bin/bash` | âœ“ |
| 2 | `#shellcheck` directives | opt |
| 3 | Brief description | opt |
| 4 | `set -euo pipefail` | âœ“ |
| 5 | `shopt -s inherit_errexit extglob nullglob` | rec |
| 6 | Metadata: `VERSION`, `SCRIPT_PATH/DIR/NAME` | rec |
| 7 | Global declarations (`declare -i/-a/-A/--`) | rec |
| 8 | Color definitions (if terminal) | opt |
| 9 | Utility functions (messaging) | rec |
| 10 | Business logic functions | rec |
| 11 | `main()` with arg parsing | rec |
| 12 | `main "$@"` | rec |
| 13 | `#fin` or `#end` | âœ“ |

### Minimal Example

```bash
#!/bin/bash
set -euo pipefail
declare -r VERSION=1.0.0
declare -i VERBOSE=0

info() { ((VERBOSE)) && >&2 echo "â—‰ $*"; }
die() { (($#<2)) || >&2 echo "âœ— ${@:2}"; exit "${1:-1}"; }

main() {
  while (($#)); do case $1 in -v) VERBOSE=1;; *) break;; esac; shift; done
  info "Running..."
}
main "$@"
#fin
```

### Anti-Patterns
- **Missing `set -euo pipefail`** â†' errors silently ignored
- **Business logic before utilities** â†' undefined function calls

**Ref:** BCS0101


---


**Rule: BCS010201**

### Dual-Purpose Scripts

**Scripts executable AND sourceable must apply `set -euo pipefail`/`shopt` ONLY when executed directly, never when sourced.**

**Why:** Sourcing applies settings to caller's shell, breaking its error handling/glob behavior.

**Pattern:**
```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

# Early return when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable section only
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
my_func "$@"
```

**Rules:**
- Functions BEFORE source detection
- `return 0` for sourced mode (not `exit`)
- Guard metadata: `[[ ! -v VAR ]]` for idempotence

**Anti-patterns:**
- `set -euo pipefail` at top of dual-purpose script â†' breaks caller's shell
- Using `exit` when sourced â†' terminates caller's shell

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

**Declare VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME as readonly immediately after `shopt`, before any other code.**

### Rationale
- `realpath` provides canonical paths, fails early if script missing
- SCRIPT_DIR enables reliable companion file/library loading
- Readonly prevents accidental modification breaking resource loading

### Pattern
```bash
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

### Variables
| Variable | Derivation | Purpose |
|----------|------------|---------|
| VERSION | Manual | Semantic version (Major.Minor.Patch) |
| SCRIPT_PATH | `realpath -- "$0"` | Absolute canonical path |
| SCRIPT_DIR | `${SCRIPT_PATH%/*}` | Script directory for resources |
| SCRIPT_NAME | `${SCRIPT_PATH##*/}` | Basename for logs/errors |

### Anti-patterns
- `SCRIPT_PATH="$0"` â†' Use `realpath -- "$0"` (resolves symlinks/relative)
- `SCRIPT_DIR=$(dirname "$0")` â†' Use `${SCRIPT_PATH%/*}` (faster, no subprocess)
- `SCRIPT_DIR=$PWD` â†' Wrong! PWD is CWD, not script location
- `readonly VAR=$(cmd)` â†' Use `declare -r` (readonly can't assign from expansion)

### Edge Cases
- **Root dir**: `${SCRIPT_PATH%/*}` yields empty; add `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`
- **Sourced**: Use `${BASH_SOURCE[0]}` instead of `$0`

**Ref:** BCS0103


---


**Rule: BCS0104**

## FHS Preference

**Follow Filesystem Hierarchy Standard for predictable file locations, multi-environment support, and package manager compatibility.**

**Key locations:** `/usr/local/{bin,share,lib,etc}` (local install) â†' `/usr/{bin,share}` (system) â†' `$HOME/.local/{bin,share}` (user) â†' `${XDG_CONFIG_HOME:-$HOME/.config}` (user config)

**Rationale:** Predictable paths for users/package managers; no hardcoded paths; portable across distros.

**FHS search pattern:**
```bash
find_data_file() {
  local -a search_paths=(
    "$SCRIPT_DIR"/"$1"                    # Development
    /usr/local/share/myapp/"$1"           # Local install
    /usr/share/myapp/"$1"                 # System install
    "${XDG_DATA_HOME:-$HOME/.local/share}"/myapp/"$1"
  )
  local -- path; for path in "${search_paths[@]}"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; } ||:
  done; return 1
}
```

**Anti-patterns:**
- `data=/home/user/myapp/data.txt` â†' use FHS search
- `source /usr/local/lib/myapp/common.sh` â†' search multiple locations
- `BIN_DIR=/usr/local/bin` â†' use `PREFIX=${PREFIX:-/usr/local}; BIN_DIR="$PREFIX"/bin`

**When NOT FHS:** Single-user scripts, project-specific tools, containers, embedded systems.

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

**Rationale:** No forward references (Bash reads top-to-bottom); clear dependency hierarchy aids debugging/maintenance.

**7-Layer Pattern:**
1. Messaging (`_msg`, `info`, `warn`, `error`, `die`)
2. Documentation (`show_help`, `show_version`)
3. Utilities (`noarg`, `yn`, `trim`)
4. Validation (`check_root`, `check_prerequisites`)
5. Business logic (domain operations)
6. Orchestration (coordinate business logic)
7. `main()` â†' `main "$@"` invocation

```bash
# Layer 1: Messaging (no deps)
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4: Validation (uses messaging)
check_deps() { command -v git || die 1 "git required"; }

# Layer 5: Business logic (uses all above)
build() { check_deps; make all; }

# Layer 7: main (calls everything)
main() { build; }
main "$@"
```

**Anti-patterns:**
- `main()` at top â†' forward references fail
- Circular deps (Aâ†”B) â†' extract shared logic to lower layer
- Random/alphabetical order ignoring deps â†' breaks call chain

**Ref:** BCS0107


---


**Rule: BCS0200**

# Variable Declarations & Constants

**Explicit declaration with type hints ensures predictable behavior and prevents common errors.**

## Core Rules

- **Type declarations**: `declare -i` (integer), `declare --` (string), `declare -a` (array), `declare -A` (hash)
- **Naming**: `UPPER_CASE` constants, `lower_case` variables
- **Scope**: `local` for function variables, global at script level
- **Constants**: `readonly` or grouped `readonly VAR1 VAR2`
- **Booleans**: Use integers (`flag=1`/`flag=0`) not strings

## Example

```bash
declare -i count=0
declare -- name="value"
readonly VERSION="1.0"
local -i result
```

## Anti-patterns

- `count=0` â†' `declare -i count=0` (type safety)
- `flag="true"` â†' `flag=1` (boolean as integer)

**Ref:** BCS0200


---


**Rule: BCS0201**

## Type-Specific Declarations

**Use explicit type declarations (`declare -i/-a/-A`, `declare --`, `local --`) to enforce type safety and document intent.**

**Rationale:** Integer declarations catch non-numeric assignments (become 0). Array declarations prevent scalar overwrites. `--` separator prevents option injection.

**Declaration types:**
- `-i` integers: counters, ports, exit codes â†' auto-arithmetic, type-checked
- `--` strings: paths, text, config â†' default for text data
- `-a` indexed arrays: lists, args â†' safe word-splitting
- `-A` associative arrays: key-value maps â†' fast lookups (Bash 4.0+)
- `-r` readonly: constants â†' immutable after init
- `local` in functions: ALL function variables â†' prevents global pollution

```bash
declare -i count=0 port=8080
declare -- filename=data.txt
declare -a files=()
declare -A config=([key]=value)
declare -r VERSION=1.0.0

process() {
  local -- input=$1
  local -i attempts=0
  local -a items=()
}
```

**Anti-patterns:**
```bash
count=0              # â†' declare -i count=0
files=file.txt       # â†' files=(file.txt) or files+=(file.txt)
local name=$1        # â†' local -- name=$1 (prevents -n injection)
declare CONFIG       # â†' declare -A CONFIG=() (for assoc array)
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

**Use consistent case conventions to distinguish scope and avoid shell conflicts.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Local variables | lower_case | `local file_count=0` |
| Private functions | _prefix | `_validate_input()` |

```bash
declare -r SCRIPT_VERSION=1.0.0
process_data() {
  local -i line_count=0
  local -- temp_file
}
_internal_helper() { :; }
```

**Rationale:** UPPER_CASE signals script-wide scope; lower_case prevents shadowing globals; underscore prefix marks internal functions.

**Anti-patterns:** Using shell reserved names (`PATH`, `HOME`) â†' variable collision; lowercase globals â†' confusion with locals.

**Ref:** BCS0203


---


**Rule: BCS0204**

## Constants and Environment Variables

**Use `declare -r` for immutable constants; `declare -x` for child process visibility.**

| Attribute | `readonly` | `export` |
|-----------|-----------|----------|
| Prevents change | âœ“ | âœ— |
| Subprocess access | âœ— | âœ“ |

**Rationale:**
- `readonly` prevents accidental modification, signals intent
- `export` required only when child processes need the value
- Combine with `declare -rx` when both immutability and export needed

**Example:**
```bash
declare -r VERSION=2.1.0              # Constant (script only)
declare -x LOG_LEVEL=${LOG_LEVEL:-INFO}  # Exported, user-overridable
declare -rx BUILD_ENV=production      # Immutable + exported
readonly -- SCRIPT_DIR               # Lock after calculation
```

**Anti-patterns:**
- `export MAX_RETRIES=3` â†' Use `readonly` if children don't need it
- `CONFIG=/etc/app.conf` without `readonly` â†' Allows accidental modification
- `readonly OUTPUT_DIR=$HOME/out` â†' Blocks user override; use `${VAR:-default}` first

**Ref:** BCS0204


---


**Rule: BCS0205**

## Readonly After Group

**Declare variables with values first, then make entire group readonly in single statement.**

**Rationale:** Prevents assignment-to-readonly errors; makes immutability contract explicit; fails if uninitialized.

**Three-step pattern** (for args/config that need parsing):
```bash
# 1. Declare with defaults
declare -i VERBOSE=0 DRY_RUN=0
declare -- OUTPUT_FILE=''

# 2. Parse/modify in main()
main() {
  while (($#)); do case $1 in
    -v) VERBOSE+=1 ;; -n) DRY_RUN=1 ;;
  esac; shift; done
  # 3. Readonly AFTER parsing
  readonly -- VERBOSE DRY_RUN OUTPUT_FILE
}
```

**Group patterns:**
- **Metadata**: Use `declare -r` (BCS0103 exception)
- **Colors**: Conditional `declare -r` in if/else
- **Paths/Config**: Initialize â†' `readonly --` group

**Anti-patterns:**
- `readonly -- VAR` before derived vars set â†' inconsistent protection
- Missing `--` separator â†' option injection risk
- `readonly` inside conditional â†' may not execute

**Ref:** BCS0205


---


**Rule: BCS0206**

## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

**Anti-pattern:** Omitting `-r` on values that should never change â†' silent bugs from accidental reassignment.

**Ref:** BCS0206


---


**Rule: BCS0207**

## Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Rationale
- Element boundaries preserved regardless of content (spaces, globs)
- Safe command construction with arbitrary arguments

#### Declaration & Usage
```bash
declare -a files=()              # Empty indexed array
declare -A config=()             # Associative (Bash 4.0+)
files+=("$1")                    # Append element
for f in "${files[@]}"; do       # Iterate (quoted!)
  process "$f"
done
readarray -t lines < <(cmd)      # From command output
```

#### Key Operations
| Op | Syntax |
|----|--------|
| Length | `${#arr[@]}` |
| Last | `${arr[-1]}` |
| Slice | `${arr[@]:1:3}` |

#### Anti-Patterns
- `rm ${files[@]}` â†' `rm "${files[@]}"` (quote expansion)
- `arr=($string)` â†' `readarray -t arr <<< "$string"` (no word-split)
- `for x in "${arr[*]}"` â†' `"${arr[@]}"` (use @ not *)

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

**Compute variables from base values; group with section comments; update derived when base changes (especially during argument parsing).**

**Rationale:** DRY principle (single source of truth) â†' consistency when PREFIX changes â†' prevents subtle bugs from stale derived values.

**Core pattern:**

```bash
# Base values
declare -- PREFIX=/usr/local APP_NAME=myapp

# Derived from PREFIX and APP_NAME
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=/etc/"$APP_NAME"
declare -- CONFIG_FILE="$CONFIG_DIR"/config.conf

# XDG fallback pattern
declare -- CONFIG_BASE=${XDG_CONFIG_HOME:-"$HOME"/.config}
```

**Update function when base changes:**

```bash
update_derived_paths() {
  BIN_DIR="$PREFIX"/bin
  LIB_DIR="$PREFIX"/lib
  CONFIG_FILE="$CONFIG_DIR"/config.conf
}

# In argument parsing:
--prefix) shift; PREFIX=$1; update_derived_paths ;;
```

**Anti-patterns:**

```bash
# âœ— Duplicating values instead of deriving
BIN_DIR=/usr/local/bin   # â†' BIN_DIR="$PREFIX"/bin

# âœ— Not updating derived when base changes
PREFIX=$1  # BIN_DIR now wrong! â†' call update_derived_paths

# âœ— Making readonly before parsing complete
readonly BIN_DIR  # â†' readonly after all parsing done
```

**Key rules:**
- Group derived vars with `# Derived from PREFIX` comments
- Update ALL derived vars when any base changes
- Make readonly AFTER argument parsing complete
- Document hardcoded exceptions (e.g., `/etc/profile.d` fixed path)

**Ref:** BCS0209


---


**Rule: BCS0210**

## Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### Braces Required

- **Expansion ops:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Adjacent concat:** `${prefix}suffix` `${var1}${var2}`
- **Arrays:** `${array[@]}` `${array[i]}` `${#array[@]}`
- **Special:** `${10}` `${@:2}` `${!var}` `${#var}`

#### No Braces (separators delimit)

`"$var"` `"$HOME"` `"$PREFIX"/bin` `"$var-suffix"` `"$var.suffix"`

```bash
# Pattern/default/substring
name=${path##*/}; dir=${path%/*}; val=${var:-default}
# âœ“ "$PREFIX"/bin  â†' âœ— "${PREFIX}"/bin
# âœ“ "$var"         â†' âœ— "${var}"
```

| Context | Form |
|---------|------|
| Standalone | `"$var"` |
| With separator | `"$var"/path` |
| Expansion op | `"${var%pat}"` |
| Concat (no sep) | `"${a}${b}"` |

**Ref:** BCS0210


---


**Rule: BCS0211**

## Boolean Flags

**Use `declare -i` integers (0/1) for boolean state; test with `(())`.**

### Rationale
- Arithmetic `((FLAG))` eliminates string comparison bugs
- Integer declaration prevents accidental string assignment

### Pattern
```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && info 'Dry-run mode'
if ((VERBOSE)); then log_debug; fi
```

### Anti-patterns
- `if [[ "$FLAG" == "true" ]]` â†' use `((FLAG))`
- Uninitialized flags â†' always init to 0 or 1

**Ref:** BCS0211


---


**Rule: BCS0300**

# Strings & Quoting

**Single quotes for literals, double quotes for expansion.**

## Rules (7)

| Rule | Purpose |
|------|---------|
| BCS0301 | Quoting fundamentals: static vs dynamic |
| BCS0302 | Quote `$(...)` command substitution |
| BCS0303 | Variable quoting in `[[ ]]` |
| BCS0304 | Heredoc delimiter quoting |
| BCS0305 | printf format/argument quoting |
| BCS0306 | `${param@Q}` safe display |
| BCS0307 | Common quoting anti-patterns |

## Core Pattern

```bash
readonly STATIC='literal text'     # Single: no expansion
msg="Hello, ${name}"               # Double: expansion needed
```

## Key Anti-Patterns

- `$var` â†' `"$var"` (unquoted variables cause word-splitting)
- `echo $@` â†' `echo "$@"` (preserve argument boundaries)

**Ref:** BCS0300


---


**Rule: BCS0301**

## Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: Variable expansion required
- **Mixed**: `"Option '$1' invalid"` â€” literal display with variable
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

- `info "Static..."` â†' `info 'Static...'` (use single for static)
- `EMAIL=user@domain.com` â†' `EMAIL='user@domain.com'` (quote special chars)
- `PATTERN=*.log` â†' `PATTERN='*.log'` (quote globs)

**Ref:** BCS0301


---


**Rule: BCS0302**

## Command Substitution

**Quote `$()` in strings; omit quotes for simple assignment; always quote when using result.**

#### Rules

- **In strings:** `echo "Time: $(date)"` â€” double quotes required
- **Simple assignment:** `VAR=$(cmd)` â€” no quotes needed
- **Concatenation:** `VAR="$(cmd)".suffix` â€” quotes required
- **Usage:** `echo "$VAR"` â€” always quote to prevent word splitting

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

- `VERSION="$(cmd)"` â†' unnecessary quotes on simple assignment
- `echo $result` â†' word splitting occurs without quotes

**Ref:** BCS0302


---


**Rule: BCS0303**

## Quoting in Conditionals

**Always quote variables in conditionals.** Unquoted â†' word splitting, glob expansion, empty-value errors, injection risk.

```bash
# Variables always quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]

# Pattern/regex: pattern UNQUOTED
[[ "$file" == *.txt ]]           # Glob match
[[ "$input" =~ $pattern ]]       # Regex (quoting makes literal)
```

**Anti-patterns:** `[[ -f $file ]]` â†' breaks on spaces/globs; `[[ "$x" =~ "$pattern" ]]` â†' pattern treated as literal.

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
# âœ— Unquoted â†' SQL injection risk
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# âœ“ Quoted for literal SQL
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

- `echo -e "...\n..."` â†' Use `printf '...\n...\n'` or `$'...\n...'` (echo -e behavior varies)
- `printf "$fmt"` â†' Format strings must be single-quoted (security, escapes)

**Ref:** BCS0305


---


**Rule: BCS0306**

## Parameter Quoting with @Q

**`${param@Q}` produces shell-quoted output safe for displayâ€”prevents injection in error messages and logs.**

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
# âœ— Injection risk
die 2 "Unknown option $1"

# âœ“ Safe
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
echo $pattern    # âœ— Expands to all .txt files!
echo "$pattern"  # âœ“ Outputs literal: *.txt
```

#### Here-doc: Quote Delimiter for Literals

```bash
# âœ— Variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# âœ“ Quoted delimiter prevents expansion
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0307


---


**Rule: BCS0400**

# Functions

**Functions use `lowercase_with_underscores`, require `main()` for scripts >200 lines, organized bottom-up.**

**Organization:** messaging â†' helpers â†' business logic â†' `main()` (each function calls only previously defined functions).

**Export:** Use `declare -fx func_name` for sourceable libraries.

**Production:** Remove unused utility functions from mature scripts.

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
- `main` without `"$@"` â†' args not passed
- Parsing args outside main â†' consumed before main runs
- Functions defined after `main "$@"` â†' not available during execution

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

**Rule:** Scripts executable directly OR sourceable as libraries using `BASH_SOURCE[0]` check.

**Key:** `set -e` MUST come AFTER source checkâ€”library code must not impose error handling on caller.

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

`my_func() { :; }` without `declare -fx` â†' cannot call from subshells after sourcing.

`set -euo pipefail` before source check â†' risky `return 0` behavior.

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

- `source lib.sh` with immediate side effects â†' Define functions only, use `lib_init` for initialization
- Unprefixed functions â†' Use namespace prefix: `myapp_init`, `myapp_cleanup`

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

- `which curl` â†' `command -v curl` (POSIX compliant)
- Silent `curl "$url"` â†' Check first with helpful message

**Ref:** BCS0408


---


**Rule: BCS0500**

# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic; avoid pipes to while loops.**

## Core Rules

- `[[ ]]` over `[ ]` â€” safer word splitting, supports `&&`/`||`/regex
- `(( ))` for arithmetic conditionals â€” cleaner than `[[ $x -gt 5 ]]`
- Process substitution `< <(cmd)` over pipes â€” avoids subshell variable loss

## Safe Arithmetic

```bash
i+=1              # Safe increment (string append works for integers)
((i++)) || true   # Guard: ((i++)) fails with set -e when i=0
```

`((i+=1))` â†' fails when result is 0; `((i++))` â†' returns original value (fails at i=0)

## Anti-Patterns

- `cmd | while read` â†' variables lost in subshell; use `while read < <(cmd)`
- `[ $var = "x" ]` â†' word splitting/glob issues; use `[[ $var == "x" ]]`

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
# âœ— Old [ ] syntax â†' use [[ ]]
[ -f "$file" -a -r "$file" ]  # Deprecated -a/-o
# âœ“ [[ -f "$file" && -r "$file" ]]

# âœ— Arithmetic with [[ ]] â†' use (())
[[ "$count" -gt 10 ]]
# âœ“ ((count > 10))
```

**Ref:** BCS0501


---


**Rule: BCS0502**

## Case Statements

**Use `case` for multi-way pattern matching; prefer over if/elif chains for single-variable tests. Always include `*)` default case.**

**Rationale:** Pattern matching with wildcards/alternation â†' single evaluation (faster than if/elif) â†' clearer visual structure with column alignment.

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

**Pattern syntax:** Literal `start)` â†' Wildcard `*.txt)` â†' Alternation `-v|--verbose)` â†' Extglob `@(a|b)` (requires `shopt -s extglob`)

**Anti-patterns:**

```bash
# âœ— Missing default case
case "$action" in start) ;; stop) ;; esac  # Silent failure on unknown

# âœ— Use if/elif when testing multiple variables or numeric ranges
if [[ "$a" && "$b" ]]; then ...  # Not: nested case statements
```

**Key rules:** Quote test variable `case "$var"` â†' Don't quote patterns `start)` not `"start")` â†' Always `;;` terminator â†' Use if for complex/multi-var logic.

**Ref:** BCS0502


---


**Rule: BCS0503**

## Loops

**Use `for` for arrays/globs/ranges, `while` for input streams/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

### Key Patterns

**For loops:** `for item in "${array[@]}"` | `for file in *.txt` | `for ((i=0; i<n; i+=1))`

**While input:** `while IFS= read -r line; do ... done < file` or `< <(command)`

**Infinite:** `while ((1))` (fastest) â†' `while :` (POSIX) â†' avoid `while true` (15-22% slower)

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

**Never pipe to while loopsâ€”pipes create subshells where variable assignments are lost. Use `< <(command)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshell for while body â†' variable modifications discarded on exit â†' counters=0, arrays=empty, no errors shown.

### Rationale

- Variables modified in pipe subshell don't persist to parent
- Silent failureâ€”script runs but produces wrong values
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
# âœ— Pipe loses state
cmd | while read -r x; do arr+=("$x"); done
echo "${#arr[@]}"  # 0!

# âœ“ Process substitution preserves state
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

**Use `bc` or `awk` for float math; Bash only supports integers natively.**

#### Rationale
- Bash `$(())` truncates decimals â†' data loss
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

`result=$((10/3))` â†' returns 3, not 3.333 â†' use `echo '10/3' | bc -l`

`[[ "$a" > "$b" ]]` â†' string comparison â†' use `(($(echo "$a > $b" | bc -l)))`

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506


---


**Rule: BCS0600**

# Error Handling

**Mandate `set -euo pipefail` + `shopt -s inherit_errexit` before any commands for automatic error detection.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures. Prefer conditionals over suppression.

## Anti-patterns
- âœ— Error handling after commands â†' âœ“ Configure first
- âœ— Unchecked return values â†' âœ“ Check or use `||`

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

**Use cleanup functions with trap to ensure resource cleanup on all exit paths (normal, error, signals).**

### Standard Pattern

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

1. **Set trap BEFORE creating resources** â†' prevents leaks if early exit
2. **Disable trap inside cleanup** â†' prevents recursion
3. **Use `$?` in trap** â†' preserves original exit code
4. **Single quotes in trap** â†' delays variable expansion

### Anti-Patterns

```bash
# âœ— Overwrites exit code
trap 'rm -f "$f"; exit 0' EXIT
# âœ“ Preserve exit code
trap 'ec=$?; rm -f "$f"; exit $ec' EXIT

# âœ— Variables expand immediately
trap "rm -f $file" EXIT
# âœ“ Expand at runtime
trap 'rm -f "$file"' EXIT
```

**Ref:** BCS0603


---


**Rule: BCS0604**

## Checking Return Values

**Always check return values explicitlyâ€”`set -e` misses pipelines, command substitution, and conditionals.**

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
- `cmd1; cmd2; if (($?))` â†' checks cmd2 not cmd1
- `output=$(failing_cmd)` without `|| die` â†' silent failure
- Generic errors `die 1 "failed"` â†' no context for debugging

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
# âœ“ Safe - cleanup may have nothing to do
# Rationale: Temp files may not exist
rm -f "$CACHE"/*.tmp 2>/dev/null || true

# âœ— DANGEROUS - critical operation
cp "$config" "$dest" 2>/dev/null || true

# âœ“ Correct - check critical operations
cp "$config" "$dest" || die 1 "Copy failed"
```

### Anti-Patterns

```bash
# âœ— Suppress without documenting why
some_cmd 2>/dev/null || true

# âœ— Suppress entire function
process() { ...; } 2>/dev/null

# âœ— Using set +e to suppress
set +e; critical_op; set -e
```

**Key:** Every suppression is a deliberate decisionâ€”document it with a comment.

**Ref:** BCS0605


---


**Rule: BCS0606**

## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Rationale:**
- `(())` returns exit code 1 when false â†' `set -e` terminates script
- `|| :` (colon = no-op returning 0) provides safe fallback
- Traditional Unix idiom; `:` preferred over `true` (built-in, 1 char)

**Pattern:**

```bash
set -euo pipefail
declare -i complete=0

# âœ— DANGEROUS: exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# âœ“ SAFE: continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use for:** optional declarations, conditional exports, feature-gated actions, debug output.

**Don't use for:** critical operations needing error handling â†' use `if` with explicit error checks.

**Anti-patterns:**

```bash
# âœ— Missing || : - script exits on false
((flag)) && action

# âœ— Suppressing critical operations
((confirmed)) && delete_files || :  # hides failures!

# âœ“ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606


---


**Rule: BCS0700**

# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: STDOUT for data, STDERR for diagnostics.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core messaging (uses FUNCNAME) | varies |
| `error()` | Unconditional errors | STDERR |
| `die()` | Exit with error message | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDOUT |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDOUT |
| `vecho()` | Verbose output | STDOUT |
| `yn()` | Yes/no prompts | STDERR |

## Key Rules

- **STDERR redirect first**: `>&2 echo "error"` â†' NOT `echo "error" >&2`
- Data output â†' STDOUT (pipeable)
- Diagnostics/errors â†' STDERR

## Example

```bash
error() { >&2 echo "ERROR: $*"; }
die()   { error "$@"; exit 1; }
info()  { echo "INFO: $*"; }
```

## Anti-patterns

- `echo "Error" >&2` â†' Use `>&2 echo "Error"` (redirect first)
- Mixing data and diagnostics on same stream

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

**Use private `_msg()` with `FUNCNAME[1]` inspection to auto-format messages; wrapper functions control verbosity and stream routing.**

### Rationale
- `FUNCNAME` auto-detects caller â†' single DRY implementation
- Conditional output via `VERBOSE`/`DEBUG` flags
- Proper streams: errorsâ†'stderr, dataâ†'stdout (enables `data=$(./script)`)

### Core Pattern
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
- `echo "Error: ..."` â†' no stderr, no prefix, no color
- `$(date ...)` in log â†' subshell per call; use `printf '%()T'`
- `die() { error "$@"; exit 1; }` â†' no exit code param

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
- `echo "Usage..."` â†' Use heredoc for multiline help
- Missing `-h|--help` option

**Ref:** BCS0704


---


**Rule: BCS0705**

## Echo vs Messaging Functions

**Use messaging functions (`info`, `warn`, `error`) for operational status â†' stderr; use `echo` for data output â†' stdout.**

**Rationale:**
- Stream separation: messagingâ†'stderr (user-facing), echoâ†'stdout (parseable data)
- Verbosity: messaging respects `VERBOSE`, echo always displays
- Pipeability: only stdout should contain data for capture/piping

**Decision matrix:**
- Status/progress â†' messaging function
- Data/return values â†' echo
- Help/version â†' echo (always display)
- Errors â†' `error()` to stderr

**Example:**
```bash
get_data() {
  info "Processing..."    # Status â†' stderr
  echo "$result"          # Data â†' stdout
}
output=$(get_data)        # Captures only data
```

**Anti-patterns:**
```bash
# âœ— Using info() for data - can't capture
get_email() { info "$email"; }     # Goes to stderr!

# âœ“ Use echo for data output
get_email() { echo "$email"; }     # Capturable

# âœ— Echo for status - mixes with data
echo "Processing..."               # Pollutes stdout

# âœ“ Messaging for status
info "Processing..."               # Clean separation
```

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

**Use terminal check `[[ -t 1 ]]` before TUI output; restore cursor on exit.**

#### Key Patterns

- **Spinner**: Background process with `kill`/cleanup
- **Progress bar**: `printf '\r[...]'` with `%*s | tr ' ' 'â–ˆ'`
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
    "$(printf '%*s' "$f" ''|tr ' ' 'â–ˆ')" \
    "$(printf '%*s' $((w-f)) ''|tr ' ' 'â–‘')" \
    $((cur*100/tot))
}
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

#### Anti-Pattern

`progress_bar 50 100` without `[[ -t 1 ]]` â†' garbage output to non-terminal

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
# âœ— Assuming terminal support
echo -e '\033[31mError\033[0m'  # â†' garbage in pipes

# âœ“ Conditional output
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# âœ— Hardcoded width â†' use ${TERM_COLS:-80}
```

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708


---


**Rule: BCS0800**

# Command-Line Arguments

**Standard argument parsing with short (`-h`) and long (`--help`) options for consistent CLI interfaces.**

Core requirements:
- Version format: `scriptname X.Y.Z`
- Validate required args; detect option conflicts
- Simple scripts: top-level parsing; complex: in `main()`

```bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) usage; exit 0 ;;
    -v|--version) echo "${0##*/} 1.0.0"; exit 0 ;;
    --) shift; break ;;
    -*) die "Unknown option: $1" ;;
    *) args+=("$1") ;;
  esac; shift
done
```

Anti-patterns: No `getopt`/`getopts` for long options â†' use `case`; no silent failures on missing required args.

**Ref:** BCS0800


---


**Rule: BCS0801**

## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all CLI parsing.**

### Core Pattern

```bash
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift; output=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -V|--version)   echo "$VERSION"; exit 0 ;;
  -[ovV]?*)       set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

### Key Components

- **`noarg()`**: `(($# > 1)) || die 2 "Option ${1@Q} requires an argument"` â†' validate before shift
- **Bundling**: `-[opts]?*)` splits `-vvn` â†' `-v -vn` â†' `-v -v -n` iteratively
- **Exit handlers**: `-V`, `-h` print and `exit 0` immediately
- **Default case**: `*)` collects positional args to array

### Anti-Patterns

- `while [[ $# -gt 0 ]]` â†' use `while (($#))`
- Missing `noarg "$@"` before shift â†' silent failures
- Missing `shift` after `esac` â†' infinite loop

### Rationale

1. `(($#))` arithmetic test more efficient than `[[ ]]`
2. Case statements more readable than if/elif chains
3. Bundling support (`-vvn`) follows Unix conventions

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

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Rationale
- Catches `--output --verbose` where filename is missing â†' prevents using next option as value
- Provides immediate clear errors vs silent failures or late arithmetic crashes

### Validation Helpers

```bash
# String arg validation (prevents -prefix as value)
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

# Numeric arg validation (integer only)
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric argument" ||:; }

# Usage in case statement
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
-d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
```

### Validator Selection

| Validator | Use Case |
|-----------|----------|
| `arg2()` | String args, prevent `-` prefix |
| `arg_num()` | Integer args only |

### Anti-Patterns

```bash
# âœ— No validation â†' --output --verbose makes OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# âœ— No type check â†' --depth abc causes late arithmetic error
-d|--depth) shift; MAX_DEPTH=$1 ;;
```

**Critical:** Call validator BEFORE `shift` â€” validator inspects `$2`.

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

## Iterative Method (Recommended)

```bash
-[ovnVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

**Pattern:** `${1:0:2}` extracts first option; `"-${1:2}"` creates remainder; `continue` reprocesses.

## Rationale

- **53-119Ã— faster** than grep/fold (~24,000-53,000 vs ~450 iter/sec)
- Pure bash, no external deps, no shellcheck warnings

## Alternatives

| Method | Speed | Notes |
|--------|-------|-------|
| grep | ~445/s | `set -- '' $(printf '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` SC2046 |
| fold | ~460/s | Same pattern with `fold -w1` |
| bash loop | ~318/s | More verbose, no `continue` needed |

## Anti-patterns

```bash
# âœ— Options with args mid-bundle
-von file    # -o captures "n" as argument

# âœ“ Args at end or separate
-vno file    # -v -n -o file
```

## Edge Cases

- List valid options explicitly: `-[ovnVh]?*` prevents unknown option disaggregation
- Options requiring arguments must be at bundle end or separate

**Ref:** BCS0805


---


**Rule: BCS0900**

# File Operations

**Use explicit paths, quote all variables, prefer process substitution over pipes.**

## File Tests
Always quote: `[[ -f "$file" ]]` `[[ -d "$dir" ]]` `[[ -r "$path" ]]`

## Safe Wildcards
`rm ./*` â†' never `rm *`; explicit path prevents catastrophic deletion

## Process Substitution
```bash
while IFS= read -r line; do
    ((count++))
done < <(command)
# Variables persist (no subshell)
```

## Anti-Patterns
- `rm *` â†' use `rm ./*`
- `cat file | while read` â†' use `while read < <(cat file)` or `< file`

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
# âœ— Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# âœ— Temp files when process sub works
temp=$(mktemp); sort file > "$temp"; diff "$temp" other; rm "$temp"
# â†' Use: diff <(sort file) other
```

**When NOT to use:** Simple cases where direct methods work:
- `result=$(command)` â†' not `result=$(cat <(command))`
- `grep pat file` â†' not `grep pat < <(cat file)`
- `cmd <<< "$var"` â†' not `cmd < <(echo "$var")`

**Ref:** BCS0903


---


**Rule: BCS0904**

## Here Documents

**Use heredocs for multi-line strings/input; quote delimiter to prevent expansion.**

`<<'EOF'` â†' literal (no expansion) | `<<EOF` â†' variables expand

```bash
cat <<'EOT'
Literal $VAR text
EOT

cat <<EOT
Expanded: $USER
EOT
```

**Anti-pattern:** Using `echo` with embedded newlines â†' use heredoc instead.

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

**Security-first practices covering SUID/SGID prohibition, PATH lockdown, IFS safety, eval avoidance, and input sanitization.**

## Core Rules

- **Never SUID/SGID** on bash scripts â†' inherent privilege escalation risk
- **Lock PATH**: `PATH='/usr/local/bin:/usr/bin:/bin'` or validate explicitly
- **IFS safety**: Reset to default `$' \t\n'` before word-splitting operations
- **Avoid eval**: Injection risk; require explicit justification if unavoidable
- **Sanitize input early**: Validate/clean user input at entry points

## Rationale

1. Bash scripts ignore SUID bit but SGID still exploitable via environment manipulation
2. Unvalidated PATH enables command hijacking via malicious executables
3. Modified IFS causes unexpected word-splitting in `read`, loops, command substitution

## Example

```bash
#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
readonly INPUT="${1:-}"
[[ "$INPUT" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "Invalid input" >&2; exit 1; }
```

## Anti-Patterns

- `eval "$user_input"` â†' command injection
- Trusting inherited PATH/IFS â†' environment-based attacks

**Ref:** BCS1000


---


**Rule: BCS1001**

## SUID/SGID

**Never use SUID/SGID bits on Bash scriptsâ€”critical security prohibition, no exceptions.**

### Why Dangerous

SUID/SGID changes effective UID/GID to file owner during execution. For scripts, kernel executes interpreter with elevated privileges, then interpreter processes scriptâ€”creating attack vectors:

- **IFS/PATH manipulation**: Attacker controls word splitting or substitutes malicious interpreter before script's PATH is set
- **LD_PRELOAD injection**: Malicious code runs with root privileges before script executes
- **Race conditions**: TOCTOU vulnerabilities in file operations

### Correct Approach

```bash
# âœ— NEVER
chmod u+s /usr/local/bin/myscript.sh

# âœ“ Use sudo with sudoers config
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
- `# No PATH setting` â†' inherits untrusted environment
- `PATH=.:$PATH` â†' current directory searchable
- `PATH=/tmp:$PATH` â†' world-writable dir in PATH
- `PATH=::` or leading/trailing `:` â†' empty = current dir
- Setting PATH late â†' commands before it use inherited PATH

**Key:** Set `readonly PATH` immediately after `set -euo pipefail`. Use absolute paths (`/bin/tar`) for critical commands as defense in depth.

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

**Never use `eval` with untrusted input. Avoid `eval` entirelyâ€”safer alternatives exist for all common use cases.**

### Rationale
- **Code injection**: `eval` executes arbitrary code with full script privilegesâ€”complete system compromise
- **Bypasses validation**: Even sanitized input can contain metacharacters enabling injection
- **Better alternatives**: Arrays, indirect expansion, associative arrays handle all use cases safely

### Safe Alternatives

```bash
# âœ— eval for variable indirection
eval "value=\$$var_name"
# âœ“ Indirect expansion
echo "${!var_name}"

# âœ— eval for dynamic assignment
eval "$var_name='$value'"
# âœ“ printf -v
printf -v "$var_name" '%s' "$value"

# âœ— eval for command building
eval "$cmd"
# âœ“ Array execution
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# âœ— eval for function dispatch
eval "${action}_function"
# âœ“ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns

```bash
# âœ— eval with user input â†' `case` whitelist
eval "$user_command"

# âœ— eval in loop â†' associative array dispatch
for f in *.txt; do eval "process_${f%.txt}"; done
```

**Key principle:** If you think you need `eval`, use arrays, indirect expansion `${!var}`, or associative arrays instead.

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

**Path containment:** Use `realpath -e` â†' verify path starts with allowed dir.

**Numeric:** `[[ "$input" =~ ^[0-9]+$ ]]` â†' reject leading zeros for integers.

**Whitelist choices:** Loop array, match exact â†' `die` if no match.

### Critical Rules
- **Always use `--`** separator: `rm -- "$file"` prevents option injection
- **Never use `eval`** with user input
- **Whitelist > blacklist**: Define allowed chars, not forbidden ones

### Anti-patterns
```bash
# âœ— Trusting input
rm -rf "$user_dir"  # user_dir="/" = disaster

# âœ“ Validate first
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
# âœ— Hard-coded path â†' predictable, no cleanup
temp=/tmp/myapp.txt

# âœ— Multiple traps overwrite each other
trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT  # t1 never cleaned!

# âœ“ Single cleanup function for all resources
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

- `command &` without `pid=$!` â†' cannot manage job later
- Using `$$` for background PID â†' wrong; `$$` is parent, `$!` is child

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

`count=0; { process; ((count++)); } &` â†' subshell loses variable changes. Use temp files: `echo 1 >> "$temp"/count`, then `wc -l < "$temp"/count`.

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102


---


**Rule: BCS1103**

## Wait Patterns

**Always capture exit codes from `wait` and track failures across parallel jobs.**

#### Rationale
- Exit codes lost without capture â†' silent failures
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
# âœ— Exit code lost
command &
wait $!

# âœ“ Capture exit code
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

`ssh "$srv" cmd` â†' `timeout 300 ssh -o ConnectTimeout=10 "$srv" cmd`

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

`sleep 5` in loop â†' `sleep $((2 ** attempt))` (fixed delay floods service)

`while ! cmd; do :; done` â†' `retry_with_backoff 5 cmd` (immediate retry = DoS)

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
Minimize subshells â†' use builtins over external commands â†' batch ops â†' process substitution over temp files.

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

**Anti-pattern:** Hardcoded debug flags â†' use `DEBUG=${DEBUG:-0}` for runtime control.

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

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

### Pattern Structure
1. Declare flags with defaults â†' 2. Parse args â†' 3. Adjust by conditions â†' 4. Execute on final state

### Example
```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse args: --builtin sets both flags, --no-builtin sets SKIP
# Runtime adjustments:
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0 ||:
check_builtin_support || { ((BUILTIN_REQUESTED)) && install_bash_builtins || INSTALL_BUILTIN=0; }
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0
# Execute on final state
((INSTALL_BUILTIN)) && install_builtin
```

### Key Benefits
- Separation of decision/action logic; easy state tracing
- Fail-safe: disable features when prerequisites fail
- User intent preserved (`*_REQUESTED` vs runtime state)

### Anti-patterns
- Modifying flags during execution phase â†' only in setup/validation
- Single flag for both intent and state â†' use separate flags

### Guidelines
- Group related flags (`INSTALL_*`, `SKIP_*`); document transitions
- State changes in order: parse â†' validate â†' execute

**Ref:** BCS1210
#fin
