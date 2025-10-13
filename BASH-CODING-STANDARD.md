# Bash Coding Standard

**Comprehensive Bash coding standard for Bash 5.2+. Not a compatibility standard.**

**Coding Principles:**
- K.I.S.S.
- "Best process is no process"
- "Simple as possible, but not simpler"

**NOTE:** Don't over-engineer. Remove unused functions/variables.

**14 Sections:** Script Structure, Variables, Expansion, Quoting, Arrays, Functions, Control Flow, Error Handling, I/O, Arguments, File Ops, Security, Code Style, Advanced Patterns

**Ref:** See 00-header.md for complete table of contents

---

## Script Structure & Layout

Mandatory 13-step structural layout from shebang to #fin marker, including metadata, shopt settings, FHS compliance, and bottom-up function organization.

---

### Standard Script General Layout

**All scripts follow mandatory 13-step structure: (1) shebang → (2) shellcheck directives → (3) description → (4) `set -euo pipefail` → (5) shopt → (6) metadata → (7) globals → (8) colors → (9) utilities → (10) business logic → (11) main() → (12) invocation → (13) #fin**

**Rationale:**
- **Safety**: Error handling (`set -euo pipefail`) before any commands run
- **Dependencies**: Bottom-up organization - utilities before business logic before main()
- **Testability**: Consistent structure allows sourcing scripts to test functions

```bash
#!/usr/bin/env bash
set -euo pipefail
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH
declare -i VERBOSE=0
die() { >&2 echo "ERROR: $*"; exit "${1:-1}"; }
validate() { [[ -f "$1" ]] || die 2 "Not found: $1"; }
main() { while (($#)); do case $1 in -v) VERBOSE=1 ;; *) break ;; esac; shift; done; readonly -i VERBOSE; validate "$@"; }
main "$@"
#fin
```

**Anti-pattern:** `set -euo pipefail` after variables/commands → unprotected execution
**Anti-pattern:** No main() in scripts >40 lines → can't source/test
**Anti-pattern:** Variables declared after functions that use them → unbound variable errors

**Ref:** See 01-layout.md for complete examples, edge cases, and all 13 steps explained

---

### Dual-Purpose Scripts (Executable and Sourceable)

Dual-purpose scripts: apply `set -euo pipefail`/`shopt` **only when executed**, not when sourced.

**Pattern:**
```bash
# Functions first
my_function() { ...; }
declare -fx my_function

# Early return when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# -----------------------------------------------------------------------------
# Executable section (only runs when executed)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata with guard
if [[ ! -v SCRIPT_VERSION ]]; then
  SCRIPT_VERSION='1.0.0'
  SCRIPT_PATH=$(realpath -- "$0")
  readonly -- SCRIPT_VERSION SCRIPT_PATH
fi

my_function "$@"
```

**Key:** Functions before detection → early return → separator → `set`/`shopt` → executable code.

**Examples:** `bash-coding-standard`, `getbcscode.sh`

---

### Shebang and Initial Setup

**First lines: shebang, shellcheck directives (optional), description, `set -euo pipefail`.**

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. **`#!/bin/bash`** - Most portable, works on most Linux
   - Use when: Running on known Linux systems

2. **`#!/usr/bin/bash`** - FreeBSD/BSD systems
   - Use when: Targeting BSD where bash is in /usr/bin

3. **`#!/usr/bin/env bash`** - Maximum portability
   - Use when: Bash location varies across systems
   - Searches PATH for bash, works in diverse environments

**Rationale:** These three cover all common scenarios while maintaining compatibility. First command must be `set -euo pipefail` for strict error handling immediately.

**Key principle:** Use `#!/bin/bash` for Linux, `#!/usr/bin/env bash` for portability. First command after shebang/comments is always `set -euo pipefail`.

**Ref:** See 02-shebang.md for shebang selection criteria, env considerations, special cases

---

### Script Metadata

**MUST declare metadata immediately after shopt. Make readonly as group.**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

# Metadata - immediately after shopt
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

**Uses:**
```bash
source "$SCRIPT_DIR/lib/common.sh"         # Load relative files
die() { >&2 echo "$SCRIPT_NAME: $*"; }     # Error messages
echo "$SCRIPT_NAME $VERSION"                # Version display
```

**Anti-pattern:**
```bash
# ✗ Don't use $0 directly or PWD
SCRIPT_PATH="$0"  # Could be relative/symlink!

# ✓ Use realpath
SCRIPT_PATH=$(realpath -- "$0")
```

**Ref:** See 03-metadata.md

---

### FHS Compliance

**Install files to FHS-standard locations: `/usr/local` (default) or `/usr` (system-wide).**

```bash
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"           # Executables
LIB_DIR="$PREFIX/lib"           # Libraries
SHARE_DIR="$PREFIX/share/app"   # Data files
DOC_DIR="$PREFIX/share/doc/app" # Documentation
MAN_DIR="$PREFIX/share/man"     # Man pages
```

**Key:** Use `PREFIX` variable, default to `/usr/local`, allow override.

**Ref:** See 04-fhs.md

---

### Shopt Settings

**Strongly recommended shopt settings immediately after `set -euo pipefail`:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Settings:**
- `inherit_errexit`: Subshells inherit `set -e`
- `shift_verbose`: Error if `shift` with no args
- `extglob`: Extended pattern matching `@(pattern)`, `*(pattern)`
- `nullglob`: Empty glob expands to nothing (not literal)

**Key:** These prevent common bugs and enable advanced features.

**Ref:** See 05-shopt.md

---

### File Extensions

**Executables:** `.sh` extension or no extension. **If available globally via PATH, always use no extension.**

**Libraries:** Must have `.sh` extension, should not be executable.

**Dual-purpose:** Can have `.sh` or no extension.

**Ref:** See 06-extensions.md for detailed guidelines

---

### Function Organization

**Organize functions bottom-up: utilities first, then business logic, then `main()` last.**

**Order:** Messaging → Helpers → Validation → Business logic → Main

**Rationale:** Each function can call functions defined above it. Readers understand primitives first.

```bash
# 1. Messaging
_msg() { ... }
error() { >&2 _msg "$@"; }

# 2. Helpers
validate_file() { [[ -f "$1" ]] || die 2 "Not found: $1"; }

# 3. Business logic
process_file() { validate_file "$1"; ... }

# 4. Main (last)
main() { process_file "$@"; }
main "$@"
```

**Key:** Bottom-up dependency order.

**Ref:** See 07-function-organization.md

---

## Variable Declarations & Constants

Explicit variable declarations with type hints (`declare -i`, `declare -a`, `declare -A`), proper scoping, naming conventions (UPPER_CASE for constants), readonly patterns, boolean flags, and derived variables.

---

### Type-Specific Declarations

**Use explicit type declarations for clarity and type safety.**

```bash
declare -i count=0 port=8080        # Integers
declare -- filename='data.txt'      # Strings (default)
declare -a files=()                 # Indexed arrays
declare -A config=([key]='value')   # Associative arrays
readonly -- VERSION='1.0.0'         # Constants
local -- temp="$1"                  # Local in functions
```

**Anti-patterns:**
```bash
# ✗ No type declaration
count=0; files=()

# ✓ Explicit types
declare -i count=0
declare -a files=()
```

**Key:** Type declarations document intent, enable type checking.

**Ref:** See 01-type-specific.md

---

### Variable Scoping

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

**Rationale:** Without `local`, function variables:
1. **Overwrite global variables** with same name
2. **Persist after function returns**, causing unexpected behavior
3. **Interfere with recursive calls**

**Anti-pattern:**
```bash
# ✗ Wrong - no local
process_file() {
  file="$1"  # Overwrites any global $file!
}

# ✓ Correct - local
process_file() {
  local -- file="$1"  # Scoped to function only
}
```

**Recursive function gotcha:**
```bash
# ✗ Without local, breaks recursion
count_files() {
  total=0  # Global! Each call resets it
  for file in "$1"/*; do ((total++)); done
  echo "$total"
}

# ✓ Correct
count_files() {
  local -i total=0  # Each invocation gets its own
  for file in "$1"/*; do ((total++)); done
  echo "$total"
}
```

**Key principle:** Always use `local` for function variables. Without it, functions pollute global namespace and break recursion.

**Ref:** See 02-scoping.md for global variable patterns, scope inheritance, advanced examples

---

### Naming Conventions

**Follow these conventions to maintain consistency and avoid conflicts.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case | `local file_count=0` |
| |  CamelCase for important locals | `local ConfigData` |
| Private functions | prefix with _ | `_validate_input()` |
| Environment | UPPER_CASE | `export DATABASE_URL` |

**Examples:**
```bash
# Constants
readonly -- SCRIPT_VERSION='1.0.0'
readonly -- MAX_CONNECTIONS=100

# Global variables
declare -i VERBOSE=1
declare -- ConfigFile='/etc/myapp.conf'

# Local variables
process_data() {
  local -i line_count=0
  local -- temp_file
  local -- CurrentSection  # CamelCase for important
}

# Private functions
_internal_helper() {
  # Internal use only
}
```

**Rationale:**
- **UPPER_CASE for globals/constants**: Immediately visible as script-wide scope
- **lower_case for locals**: Distinguishes from globals, prevents shadowing
- **Underscore prefix**: Signals "internal use only"
- **Avoid lowercase single-letter**: Reserved for shell (`a`, `b`, `n`)
- **Avoid shell variable names**: Don't use `PATH`, `HOME`, `USER`

**Key principle:** UPPER_CASE for globals/constants/env, lower_case for locals, underscore prefix for private functions.

**Ref:** See 03-naming.md for complete conventions, special cases, conflicts
---

### Constants and Environment Variables

**Constants:** `UPPER_CASE`, make readonly
**Environment:** `UPPER_CASE`, export if needed

```bash
# Constants (readonly)
readonly -- MAX_RETRIES=3
readonly -- DEFAULT_TIMEOUT=30

# Environment variables
export PATH='/usr/local/bin:/usr/bin:/bin'
export LANG='en_US.UTF-8'

# Environment with default
: "${PREFIX:=/usr/local}"
export PREFIX
```

**Key:** Constants are readonly, environment vars are exported. Both use UPPER_CASE.

**Ref:** See 04-constants-env.md

---

### Readonly After Group

**Declare variables first with values, then make readonly in single statement.**

```bash
# Phase 1: Initialize
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}

# Phase 2: Protect group
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR
```

**Anti-pattern:**
```bash
# ✗ Individually
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(realpath -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}  # Can't assign to readonly!

# ✓ Group
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH
```

**Key:** Initialize all, then readonly together. Makes immutability contract explicit.

**Ref:** See 05-readonly-after-group.md

---

### Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155 # if realpath fails, bigger problems exist
readonly -- SCRIPT_PATH="$(realpath -- "$0")"
```

**Key principle:** Mark constants readonly immediately after initialization.

**Ref:** See 06-readonly-declaration.md, also 05-readonly-after-group.md for group pattern

---

### Boolean Flags Pattern

**For boolean state tracking, use integer variables with `declare -i`:**

```bash
# Boolean flags - declare as integers with explicit initialization
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i DRY_RUN=0

# Test flags using (())
((DRY_RUN)) && info 'Dry-run mode enabled'

if ((INSTALL_BUILTIN)); then
  install_loadable_builtins
fi

# Toggle flags
((VERBOSE)) && VERBOSE=0 || VERBOSE=1

# Set flags from command-line parsing
case $1 in
  --dry-run)    DRY_RUN=1 ;;
  --skip-build) SKIP_BUILD=1 ;;
esac
```

**Guidelines:**
- Use `declare -i` for integer-based boolean flags
- Name flags descriptively in ALL_CAPS (`DRY_RUN`, `INSTALL_BUILTIN`)
- Initialize explicitly to `0` (false) or `1` (true)
- Test with `((FLAG))` in conditionals (non-zero=true, zero=false)
- Avoid mixing boolean flags with integer counters

**Key principle:** Integer flags (`declare -i FLAG=0`) tested with `((FLAG))` provide clean boolean logic. `0`=false, non-zero=true.

**Ref:** See 07-boolean-flags.md for toggle patterns, complex flag logic, state management

---

### Derived Variables

**Derive variables from base values to avoid duplication (DRY principle). When base changes, update all derived values via update function. Prevents inconsistency when PREFIX/APP_NAME change.**

**Rationale:**
- **Single source of truth**: Define PREFIX once, derive BIN_DIR/LIB_DIR/etc from it
- **Consistency**: Changing PREFIX updates all paths atomically via update function
- **Maintainability**: Clear dependency hierarchy (base → derived)

```bash
# Base → Derived → Update when base changes
PREFIX='/usr/local'
APP_NAME='myapp'
BIN_DIR="$PREFIX/bin"              # Derived from PREFIX
LIB_DIR="$PREFIX/lib"
CONFIG_DIR="/etc/$APP_NAME"        # Derived from APP_NAME
CONFIG_FILE="$CONFIG_DIR/app.conf" # Derived from CONFIG_DIR

update_derived() { BIN_DIR="$PREFIX/bin"; LIB_DIR="$PREFIX/lib"; CONFIG_DIR="/etc/$APP_NAME"; CONFIG_FILE="$CONFIG_DIR/app.conf"; }

# When parsing arguments that change base values:
case $1 in --prefix) shift; PREFIX="$1"; update_derived ;; esac  # Update all derived
readonly -- PREFIX APP_NAME BIN_DIR LIB_DIR CONFIG_DIR CONFIG_FILE  # After parsing
```

**Anti-pattern:** Duplicating paths → `/usr/local` repeated in BIN_DIR, LIB_DIR, etc
**Anti-pattern:** Not updating derived after base changes → stale values
**Anti-pattern:** Circular dependencies → DIR_A depends on DIR_B depends on DIR_A

**Ref:** See 08-derived-variables.md for XDG patterns, platform-specific, environment fallbacks

---

## Variable Expansion & Parameter Substitution

Default to `"$var"` without braces. Use braces only when required: parameter expansion operations, concatenation, array expansions, or disambiguation.

---

### Parameter Expansion

**Common parameter expansion patterns:**

```bash
SCRIPT_NAME=${SCRIPT_PATH##*/} # Remove longest prefix pattern
SCRIPT_DIR=${SCRIPT_PATH%/*}   # Remove shortest suffix pattern
${var:-default}                # Default value
${var:0:1}                     # Substring
${#array[@]}                   # Array length
${var,,}                       # Lowercase conversion
"${@:2}"                       # All args starting from 2nd
```

**Key principle:** Use `${...}` braces when performing operations or transformations on variables.

**Ref:** See 01-parameter-expansion.md for complete operator reference, 02-guidelines.md for brace usage rules

---

### Variable Expansion Guidelines

**Rule:** Use `"$var"` by default. Only use braces `"${var}"` when syntactically necessary.

**When braces ARE required:**
```bash
"${var##*/}"        # Parameter expansion operations
"${var:-default}"   # Default values
"${var1}${var2}"    # Concatenation (no separator)
"${array[@]}"       # Array access
"${prefix}_suffix"  # Variable + alphanumeric (no separator)
```

**When braces NOT required:**
```bash
# ✓ Correct - no braces
"$var"
"$PREFIX"/bin       # Separator present
"$HOME/path"        # Separator present
echo "Count: $count items"  # Space separates

# ✗ Wrong - unnecessary braces
"${var}"            # No operation
"${PREFIX}"/bin     # Separator present
"${HOME}/path"      # Separator present
```

**Key:** Separators (/ . - space) make braces unnecessary. Only use when shell requires them.

**Ref:** See 02-guidelines.md

---

## Quoting & String Literals

**General Principle:** Use single quotes (`'...'`) for static string literals. Use double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.

**Rationale:** Single quotes prevent shell interpretation (safer, clearer for literal strings). Double quotes signal "this string needs shell processing".

---

### Static Strings and Constants

**Use single quotes for string literals with no variables.**

```bash
# Messages
info 'Checking prerequisites...'
success 'Operation completed'

# Assignments
MESSAGE='Operation completed'
DEFAULT_PATH='/usr/local/bin'

# Conditionals
[[ "$status" == 'success' ]]  # ✓ Correct
[[ "$status" == "success" ]]  # ✗ Unnecessary double quotes
```

**Rationale:** Single quotes = literal (no expansion), faster, clearer, safer.

**When double quotes needed:**
```bash
# Variables must expand
info "Found $count files"

# Command substitution
msg="Time: $(date)"
```

**Anti-pattern:**
```bash
# ✗ Double quotes for static
info "Checking..."  # No variables!

# ✓ Single quotes
info 'Checking...'
```

**Key:** Single quotes signal "literal content", double quotes signal "expansion here".

**Ref:** See 01-static-strings.md

---

### One-Word Literals

**One-word literals CAN be unquoted (e.g., `VAR=value`), but quoting is safer (`VAR='value'`). Multi-word/special chars MUST be quoted. In conditionals, ALWAYS quote the variable: `[[ "$var" == value ]]`**

**Rationale:**
- **Future-proofing**: Value might become multi-word later
- **Consistency**: All assignments look the same when quoted
- **Safety**: Quotes prevent bugs if value changes

```bash
# Acceptable but not recommended
name=alice
count=42

# Better - defensive programming
name='alice'
count='42'

# MANDATORY - spaces/special chars
app='My App'
email='admin@example.com'
pattern='*.txt'
empty=''

# MANDATORY - variables in tests (quote the variable, not the literal)
[[ "$status" == active ]]  # ✓ Variable quoted
[[ $status == active ]]    # ✗ Variable unquoted - dangerous!
```

**Anti-pattern:** `msg=Hello World` → only assigns "Hello"
**Anti-pattern:** `[[ $var == value ]]` → unquoted $var (word splitting risk)
**Anti-pattern:** `default=` → unclear if empty or undefined, use `default=''`

**Ref:** See 02-one-word-literals.md for complete quoting rules, edge cases

---

### Strings with Variables

**Use double quotes when string contains variables that need expansion:**

```bash
# Message functions with variables
die 1 "Unknown option '$1'"
error "'$compiler' not found"
info "Installing to $PREFIX/bin"
success "Processed $count files"

# Echo statements with variables
echo "$SCRIPT_NAME $VERSION"
echo "Binary: $BIN_DIR/mailheader"

# Multi-line messages
info '[DRY-RUN] Would install:' \
     "  $BIN_DIR/mailheader" \
     "  $BIN_DIR/mailmessage" \
     "  $LIB_DIR/mailheader.so"
```

**Key principle:** Use double quotes for strings containing variables. Variables expand inside double quotes. Single quotes for literals only.

**Ref:** See 03-strings-with-vars.md for interpolation patterns, mixed quoting

---

### Mixed Quoting

**When a string contains both static text and variables, use double quotes with single quotes nested for literal protection.**

```bash
# Protect literal quotes around variables
die 2 "Unknown option '$1'"              # Single quotes are literal
die 1 "'gcc' compiler not found."        # 'gcc' shows literally with quotes
warn "Cannot access '$file_path'"        # Path shown with quotes

# Complex messages
info "Would remove: '$old_file' → '$new_file'"
error "Permission denied for directory '$dir_path'"
```

**Key principle:** Double quotes for outer string, single quotes for literal text within (e.g., `"Unknown '$1'"`).

**Ref:** See 04-mixed-quoting.md for complete patterns

---

### Command Substitution in Strings

**Use double quotes when including command substitution.**

```bash
# Command substitution requires double quotes
echo "Current time: $(date +%T)"
info "Found $(wc -l "$file") lines"
die 1 "Checksum failed: expected $expected, got $(sha256sum "$file")"

# Assign with command substitution
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
TIMESTAMP="$(date -Ins)"
```

**Key principle:** Double quotes required for strings containing `$(...)` command substitution.

**Ref:** See 05-command-substitution.md for complete patterns

---

### Variables in Conditionals

**ALWAYS quote variables in `[[ ]]` conditionals. Even though `[[ ]]` is safer than `[ ]`, quoting is still required.**

```bash
# ✓ Always quote
[[ -f "$file" ]]
[[ "$var" == 'value' ]]
[[ -n "$string" ]]

# ✗ Never unquoted
[[ -f $file ]]  # Can fail with spaces
```

**Right side of `==`:** Quote variables, not literals.
```bash
[[ "$status" == 'active' ]]  # ✓ Literal unquoted
[[ "$var1" == "$var2" ]]     # ✓ Variable quoted
```

**Key:** Quote variables on left and in variable comparisons. Literals on right can be unquoted.

**Ref:** See 06-vars-in-conditionals.md

---

### Array Expansions

**ALWAYS quote: `"${array[@]}"` for separate elements, `"${array[*]}"` for single string.**

```bash
# ✓ [@] for iteration/function args (most common)
for item in "${array[@]}"; do process "$item"; done
my_function "${array[@]}"
copy=("${original[@]}")

# ✓ [*] for single string/display
echo "Items: ${array[*]}"
IFS=','; csv="${array[*]}"

# ✗ NEVER unquoted
for item in ${array[@]}; do  # BREAKS with spaces!
```

**Problem:**
```bash
files=('file1.txt' 'file 2.txt')

# ✗ Unquoted: 3 iterations (word splitting!)
for f in ${files[@]}; do

# ✓ Quoted: 2 iterations (preserves elements)
for f in "${files[@]}"; do
```

**Key:** Unquoted arrays ALWAYS break with spaces. `"${array[@]}"` is the ONLY safe form.

**Ref:** See 07-array-expansions.md

---

### Here Documents

**Use appropriate quoting for here documents based on whether expansion is needed:**

```bash
# No expansion - single quotes on delimiter
cat <<'EOF'
This text is literal.
$VAR is not expanded.
$(command) is not executed.
EOF

# With expansion - no quotes on delimiter
cat <<EOF
Script: $SCRIPT_NAME
Version: $VERSION
Time: $(date)
EOF

# Double quotes on delimiter (same as no quotes for here-docs)
cat <<"EOF"
Script: $SCRIPT_NAME
EOF
```

**Key principle:** Use `<<'EOF'` (single quotes) for literal content. Use `<<EOF` (no quotes) when you need variable expansion and command substitution.

**Ref:** See 08-here-documents.md for indented here-docs, piping, advanced patterns

---

### Echo and Printf Statements

```bash
# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
echo "Installing to $PREFIX/bin"
printf 'Found %d files in %s\n' "$count" "$dir"

# Mixed content
echo "  • Binary: $BIN_DIR/mailheader"
echo "  • Version: $VERSION (released $(date))"
```

**Key principle:** Single quotes for static echo/printf strings, double quotes when variables/commands present.

**Ref:** See 09-echo-printf.md for complete patterns

---

### Summary Reference

| Content Type | Quote Style | Example |
|--------------|-------------|---------|
| Static string | Single `'...'` | `info 'Starting process'` |
| One-word literal (assignment) | Optional | `VAR=value` or `VAR='value'` |
| One-word literal (conditional) | Optional | `[[ $x == value ]]` |
| String with variable | Double `"..."` | `info "Processing $file"` |
| Literal quotes in string | Double with nested single | `die 1 "Unknown '$1'"` |
| Command substitution | Double `"..."` | `echo "Time: $(date)"` |
| Variables in conditionals | Double `"$var"` | `[[ -f "$file" ]]` |
| Array expansion | Double `"${arr[@]}"` | `for i in "${arr[@]}"` |
| Here doc (no expansion) | Single on delimiter | `cat <<'EOF'` |
| Here doc (with expansion) | No quotes on delimiter | `cat <<EOF` |

**Ref:** See 10-summary.md for complete quoting reference

---

### Anti-Patterns

**Critical mistakes:**

```bash
# ✗ Double quotes for static strings
info "Starting..."       # Wrong
info 'Starting...'       # ✓ Correct

# ✗ Unquoted variables (DANGEROUS!)
[[ -f $file ]]           # Wrong - word splitting
[[ -f "$file" ]]         # ✓ Correct
rm $temp_file            # Wrong - glob expansion
rm "$temp_file"          # ✓ Correct

# ✗ Unnecessary braces
echo "${HOME}/bin"       # Wrong
echo "$HOME/bin"         # ✓ Correct

# ✗ Unquoted array
for i in ${arr[@]}; do   # Wrong - breaks on spaces
for i in "${arr[@]}"; do # ✓ Correct
```

**Quick check:** Static→single quotes `'...'`, Variables→quoted `"$var"` (no braces), Arrays→`"${arr[@]}"`.

**Ref:** See 11-anti-patterns.md for complete examples

---

### String Trimming

```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

**Key principle:** Trim leading/trailing whitespace using parameter expansion.

**Ref:** See 12-string-trimming.md for explanation and alternatives

---

### Display Declared Variables

```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```

**Usage:** Display variable declarations without the `declare -X` prefix.

**Key principle:** Debug helper to show variable values cleanly.

**Ref:** See 13-display-vars.md for usage examples

---

### Pluralisation Helper

```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

**Usage:** `echo "Found $count file$(s "$count")"` → "Found 1 file" or "Found 3 files"

**Key principle:** Simple pluralization for count-based messages.

**Ref:** See 14-pluralisation.md for usage examples

---

## Arrays

Arrays provide safe list handling and are essential for managing collections of data in Bash scripts.

---

### Array Declaration and Usage

```bash
# Declare arrays
declare -a paths=('dir1' 'dir2' 'dir3')
local -a files=()

# Append
paths+=("$new_path")

# Iterate (ALWAYS quote!)
for path in "${paths[@]}"; do
  process "$path"
done

# Length
((${#files[@]} > 0)) && process_files

# Read into array
readarray -t lines < <(command)  # Preferred
IFS=',' read -ra fields <<< "$csv"  # Split by delimiter

# Accessing
first=${array[0]}
last=${array[-1]}
"${array[@]}"      # All elements
"${array[@]:2:3}"  # Slice: 3 elements from index 2
```

**Anti-patterns:**
```bash
# ✗ Unquoted expansion
for i in ${arr[@]}; do  # BREAKS with spaces!

# ✓ Always quote
for i in "${arr[@]}"; do
```

**Key:** Always `"${array[@]}"`, never `${array[@]}`.

**Ref:** See 01-declaration-usage.md

---

### Safe List Handling

**Use arrays for lists. NEVER use space-separated strings - they break with spaces in elements.**

```bash
# ✓ Arrays (safe)
declare -a files=('file1.txt' 'file 2.txt' 'file3.txt')
for file in "${files[@]}"; do process "$file"; done

# ✗ Space-separated string (BREAKS!)
files='file1.txt file 2.txt file3.txt'
for file in $files; do  # 4 iterations, not 3!
```

**Building arrays:**
```bash
declare -a args=('-v')
((DEBUG)) && args+=('--debug')
command "${args[@]}"
```

**Key:** Arrays preserve elements with spaces, strings don't.

**Ref:** See 02-safe-list-handling.md

---

## Functions

Function definition patterns, naming (lowercase_with_underscores), main() for scripts >40 lines, function export (declare -fx), production optimization, and bottom-up organization (messaging → helpers → business logic → main).

---

### Function Definition Pattern

```bash
# Single-line functions for simple operations
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line functions with local variables
main() {
  local -i exitcode=0
  local -- variable
  # Function body
  return "$exitcode"
}
```

**Key principle:** Single-line for simple operations, multi-line with `local` declarations for complex logic.

**Ref:** See 01-definition-pattern.md for complete patterns

---

### Function Names

**Use lowercase with underscores to match shell conventions and avoid conflicts with built-ins.**

```bash
# ✓ Good - lowercase with underscores
my_function() { … }
process_log_file() { … }

# ✓ Private functions use leading underscore
_my_private_function() { … }
_validate_input() { … }

# ✗ Avoid - CamelCase or UPPER_CASE
MyFunction() { … }      # Don't
PROCESS_FILE() { … }    # Don't
```

**Rationale:**
- **Lowercase with underscores**: Matches Unix/Linux utility naming
- **Avoid CamelCase**: Can be confused with variables or commands
- **Underscore prefix**: Signals internal/private use only
- **Consistency**: All built-in bash commands are lowercase

**Anti-patterns:**
```bash
# ✗ Don't override built-ins without good reason
cd() {           # Dangerous!
  builtin cd "$@" && ls
}

# ✓ Use different name if wrapping built-ins
change_dir() {
  builtin cd "$@" && ls
}

# ✗ Don't use special characters
my-function() {  # Dash creates issues
  …
}
```

**Key principle:** Use `lowercase_with_underscores` for all function names. Use leading underscore `_private_function` for internal functions.

**Ref:** See 02-function-names.md for naming conventions, built-in conflicts, best practices

---

### Main Function

**Scripts over 40 lines should use a `main()` function that orchestrates execution. Place argument parsing, configuration, and workflow orchestration in main(). This enables testing, improves organization, and makes execution flow obvious.**

**Rationale:**
- **Testability**: Can source script and test main() with specific arguments
- **Organization**: Single entry point, clear execution flow
- **Scoping**: Argument parsing variables can be local to main()
- **Debugging**: Easy to add hooks before/after main()
- **Reusability**: Functions can be sourced without auto-execution

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
  # Parse arguments
  while (($#)); do
    case $1 in
      -v|--verbose) VERBOSE=1 ;;
      -h|--help) usage; exit 0 ;;
      *) die 22 "Invalid: $1" ;;
    esac
    shift
  done

  readonly -i VERBOSE

  # Execute workflow
  check_prerequisites
  process_data
  generate_output
}

main "$@"
#fin
```

**When to use:** Required for scripts >40 lines. Skip for simple scripts <40 lines (unnecessary overhead).

**Anti-pattern:** No main() in large script → can't source for testing, no clear entry point
**Anti-pattern:** Direct execution in global scope → runs immediately when sourced

**Key principle:** main() separates definition (functions) from execution (orchestration), enabling testing and reuse.

**Ref:** See 03-main-function.md for benefits, testing patterns, conditional execution

---

### Function Export

**Export functions when needed by subshells using `declare -fx`.**

```bash
# Export functions for subshell availability
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

**Key principle:** Use `declare -fx` to export functions for use in subshells.

**Ref:** See 04-function-export.md for use cases and patterns

---

### Production Script Optimization

**Once a script is mature and ready for production, remove unused code:**

- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()` if not used)
- Remove unused global variables (e.g., `PROMPT`, `DEBUG` if not referenced)
- Remove unused messaging functions
- Keep only what your script actually needs

**Benefits:** Reduces script size, improves clarity, eliminates maintenance burden.

**Example:** A simple script may only need `error()` and `die()`, not the full messaging suite.

**Key principle:** Remove unused code from mature production scripts to minimize complexity.

**Ref:** See 05-production-optimization.md for systematic approach

---

## Control Flow

Use `[[ ]]` for conditionals, `(())` for arithmetic, process substitution over pipes to while loops, and safe arithmetic patterns (`i+=1` not `((i++))`). Covers case statements and loop patterns.

---

### Conditionals

**Use `[[ ]]` for strings/files, `(())` for arithmetic.**

```bash
# String/file tests
[[ -f "$file" ]] && source "$file"
[[ "$status" == 'success' ]] && continue

# Arithmetic tests
((count > 0)) && process
((i >= MAX)) && break

# Pattern matching (only in [[ ]])
[[ "$file" == *.txt ]] && process
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-z]+\.[a-z]{2,}$ ]] || die 22 "Invalid email"

# Short-circuit
[[ -d "$dir" ]] || mkdir -p "$dir"
((DEBUG)) && set -x
```

**Anti-patterns:**
```bash
# ✗ Old [ ] syntax
[ -f "$file" ]

# ✓ Use [[ ]]
[[ -f "$file" ]]

# ✗ Arithmetic with -gt
[[ "$count" -gt 10 ]]

# ✓ Use (())
((count > 10))
```

**Ref:** See 01-conditionals.md

---

### Case Statements

**Use `case` for multi-way branching on single variable. Compact format (all on one line) for simple actions, expanded format (multi-line) for complex logic. Quote test variable, don't quote literal patterns. Always include `*)` default case.**

**Rationale:**
- **Performance**: Single evaluation vs multiple if/elif tests
- **Readability**: Pattern matching intent immediately obvious
- **Pattern matching**: Native wildcards (`*.txt`), alternation (`-h|--help`)

```bash
# Compact: argument parsing
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -*)           die 22 "Invalid: $1" ;;
    *)            FILES+=("$1") ;;
  esac; shift
done

# Expanded: multi-line logic
case $1 in
  --prefix)  noarg "$@"; shift; PREFIX="$1"; BIN_DIR="$PREFIX/bin" ;;
  *.txt)     process_text "$1" ;;
  *.pdf)     process_pdf "$1" ;;
  @(start|stop|restart))  handle_service "$1" ;;  # Requires extglob
  *)         die 1 "Unknown: $1" ;;
esac
```

**Anti-pattern:** `case $var in` → unquoted test variable (word splitting risk)
**Anti-pattern:** Missing `*)` case → silent failures on unexpected values
**Anti-pattern:** `"literal")` → don't quote literal patterns (unnecessary)
**Anti-pattern:** Long if/elif for pattern matching → use case instead

**Ref:** See 02-case-statements.md for extglob patterns, file routing, service control examples

---

### Loops

**Use `for` for arrays/globs/ranges, `while` for reading input/argument parsing/conditions. Always quote arrays `"${arr[@]}"`, use `< <(cmd)` to avoid subshell, use `i+=1` not `i++` in C-style loops.**

**Rationale:**
- **Subshell avoidance**: `< <(cmd)` keeps variables in same shell (pipe creates subshell)
- **Array safety**: `"${array[@]}"` preserves elements with spaces
- **Set -e compatibility**: `i++` returns 0 when i=0, fails with set -e; use `i+=1`

```bash
# For: arrays/globs
for file in "${files[@]}"; do process "$file"; done
for file in *.txt; do process "$file"; done
for ((i=0; i<10; i+=1)); do echo "$i"; done

# While: reading/parsing
while IFS= read -r line; do process "$line"; done < <(find . -name '*.txt')
while (($#)); do case $1 in -v) VERBOSE=1 ;; *) break ;; esac; shift; done
```

**Anti-pattern:** `cat file | while read line` → subshell, variables don't persist
**Anti-pattern:** `for file in $(ls)` → never parse ls, use globs
**Anti-pattern:** `for item in ${arr[@]}` → unquoted array breaks on spaces
**Anti-pattern:** `for ((i=0; i<10; i++))` → fails with set -e when i=0

**Ref:** See 03-loops.md for complete examples, until loops, nested loops, infinite loops, edge cases

---

### Pipes to While Loops

**NEVER pipe to while. Pipes create subshells - variable changes are LOST. Use process substitution `< <(command)` instead.**

```bash
# ✗ WRONG - subshell loses changes
declare -i count=0
echo -e "a\nb\nc" | while read -r line; do
  ((count+=1))
done
echo "$count"  # Output: 0 (NOT 3!) - BUG!

# ✓ CORRECT - process substitution
declare -i count=0
while read -r line; do
  ((count+=1))
done < <(echo -e "a\nb\nc")
echo "$count"  # Output: 3 (correct!)
```

**Solutions:**
```bash
# 1. Process substitution
while read -r line; do
  ((count+=1))
done < <(grep 'ERROR' "$log")

# 2. Readarray (simpler for lines)
readarray -t lines < <(grep 'ERROR' "$log")

# 3. Here-string
while read -r line; do
  process
done <<< "$input"
```

**Key:** Piping to while is a BUG, not style. Variables are ALWAYS lost.

**Ref:** See 04-pipes-to-while.md

---

### Arithmetic Operations

```bash
# Declare integers
declare -i counter=0 max=100

# Increment (NEVER use i++)
i+=1               # ✓ Preferred
((i+=1))           # ✓ Also safe
((++i))            # ✓ Safe pre-increment
((i++))            # ✗ DANGEROUS with set -e! Returns old value

# Arithmetic
((result = x * y + z))
result=$((x * y + z))

# Conditionals (use (()) not [[ ]])
((count > 0)) && process
((i >= max)) && break

# Operators: + - * / % ** += -= *= /=
# Comparisons: < <= > >= == !=
```

**Why `((i++))` is dangerous:**
```bash
set -e
i=0
((i++))  # Returns 0 (old value) = false, script EXITS!
```

**Anti-patterns:**
```bash
# ✗ Old-style [[ ]]
[[ "$count" -gt 10 ]]

# ✓ Use (())
((count > 10))

# ✗ Post-increment
((i++))

# ✓ Use +=1
i+=1
```

**Ref:** See 05-arithmetic.md

---

## Error Handling

Mandatory `set -euo pipefail`, standard exit codes (0=success, 1=error, 2=misuse, 5=IO, 22=invalid), trap handling for cleanup, return value checking, and safe error suppression patterns.

---

### Exit on Error

**MANDATORY: `set -euo pipefail` immediately after shebang.**

```bash
#!/bin/bash
set -euo pipefail
```

**What it does:**
- `-e`: Exit on any command failure
- `-u`: Exit on unset variable
- `-o pipefail`: Pipe fails if any command fails

**Key:** Prevents scripts from continuing after errors, catches bugs early.

**Ref:** See 01-exit-on-error.md

---

### Exit Codes

**Use standard exit codes: 0=success, 1=general error, 2=misuse, specific codes for specific errors.**

```bash
# Standard codes
exit 0    # Success
exit 1    # General error
exit 2    # Misuse (bad arguments)
exit 5    # Permission denied / EIO
exit 22   # Invalid argument / EINVAL
exit 126  # Command not executable
exit 127  # Command not found
```

**Usage:**
```bash
die() { local -i code=${1:-1}; shift; error "$@"; exit "$code"; }
[[ -f "$file" ]] || die 2 "File not found"
[[ -r "$file" ]] || die 5 "Cannot read"
```

**Key:** Consistent, meaningful exit codes aid debugging.

**Ref:** See 02-exit-codes.md

---

### Trap Handling

**Standard cleanup pattern:**
```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  exit "$exitcode"
}

trap 'cleanup $?' SIGINT SIGTERM EXIT  # Install EARLY

# Create resources after trap
temp_dir=$(mktemp -d)
```

**Simple temp file:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
```

**Critical rules:**
1. Disable trap in cleanup: `trap - SIGINT SIGTERM EXIT`
2. Preserve exit code: `trap 'cleanup $?' EXIT`
3. Use single quotes: `trap 'rm "$temp"' EXIT` (not double!)
4. Set trap EARLY, before creating resources

**Anti-pattern:**
```bash
# ✗ Double quotes - expands NOW
trap "rm $temp" EXIT  # Expands to literal value!

# ✓ Single quotes - expands on trap
trap 'rm "$temp"' EXIT
```

**Ref:** See 03-trap-handling.md

---

### Checking Return Values

**Always check command returns with informative errors.**

```bash
# Pattern 1: || with die
mv "$source" "$dest" || die 1 "Failed to move $source to $dest"

# Pattern 2: if check (for context)
if ! cp "$config" "$backup"; then
  error "Failed to backup $config"
  error "Check permissions and disk space"
  exit 1
fi

# Pattern 3: Function returns
validate_file() {
  [[ -f "$1" ]] || return 2  # Not found
  [[ -r "$1" ]] || return 5  # Permission denied
  return 0
}

validate_file "$config" || die $? "Config validation failed"
```

**Pipelines:**
```bash
set -o pipefail  # From set -euo pipefail
cat file | grep pattern  # Exits if cat fails
```

**Command substitution:**
```bash
# ✓ Check after
output=$(command) || die 1 "Command failed"

# ✓ Or use inherit_errexit
shopt -s inherit_errexit
```

**Principle:** Assume operations can fail. Check immediately, provide context in errors.

**Ref:** See 04-return-values.md

---

### Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. ALWAYS document WHY.**

**When appropriate:**
```bash
# ✓ Checking existence
command -v tool >/dev/null 2>&1 && use_tool

# ✓ Cleanup (may not exist)
rm -f /tmp/myapp_* 2>/dev/null || true

# ✓ Optional with fallback
md2ansi < "$file" || cat "$file"
```

**When DANGEROUS:**
```bash
# ✗ File operations - silently fails!
cp "$config" "$dest" 2>/dev/null || true

# ✗ Security - creates vulnerabilities!
chmod 600 "$key" 2>/dev/null || true

# ✗ No documentation - why suppressed?
command 2>/dev/null || true
```

**Key:** Every `2>/dev/null` or `|| true` is a deliberate decision. Document why it's safe to ignore.

**Ref:** See 05-error-suppression.md

---

## Input/Output & Messaging

Standard messaging functions (_msg, vecho, success, warn, info, debug, error, die, yn) with color support, STDOUT vs STDERR separation, usage documentation patterns, and `>&2` at command beginning for errors.

---

### Standardized Messaging and Color Support

```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Key principle:** Define colors only when stdout/stderr are terminals (`-t 1 && -t 2`), otherwise empty strings.

**Ref:** See 01-color-support.md for extended color palettes

---

### STDOUT vs STDERR

**All error messages should go to STDERR. Place `>&2` at the *beginning* of commands for clarity.**

```bash
# ✓ Preferred format - redirect at beginning
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# ✓ Also acceptable - redirect at end
somefunc() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

**Key principle:** Error output to STDERR (`>&2`), prefer placing redirect at beginning for clarity.

**Ref:** See 02-stdout-stderr.md for complete guidelines

---

### Core Message Functions

**Implement standard messaging using private `_msg()` that inspects `FUNCNAME` for auto-formatting.**

```bash
# Private core
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Public wrappers
vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
die()     { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }
```

**Colors:**
```bash
if [[ -t 1 && -t 2 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; NC=''
fi
```

**Key:** `FUNCNAME` inspection eliminates duplication. Errors to stderr, data to stdout.

**Ref:** See 03-core-functions.md

---

### Usage Documentation

**Standard help message pattern using here-doc:**

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Detailed description.

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -n|--num NUM      Set num to NUM

  -v|--verbose      Increase verbose output
  -q|--quiet        No verbosity

  -V|--version      Print version ('$SCRIPT_NAME $VERSION')
  -h|--help         This help message

Examples:
  # Example 1
  $SCRIPT_NAME -v file.txt
EOT
}
```

**Key principle:** Use here-doc for help text. Include version, usage line, options, and examples. Call with `-h|--help`.

**Ref:** See 04-usage-docs.md for advanced help formatting, multi-command patterns

---

### Echo vs Messaging Functions

**Echo for data (stdout), messaging functions for user messages (stderr). This separates data from messages, enabling pipelines.**

**Rationale:**
- **Stream separation**: Data (stdout) vs messages (stderr) → `script | process` sees only data
- **Consistency**: `info/warn/error/die` provide uniform formatting
- **Verbosity control**: Messages respect VERBOSE flag, echo doesn't

```bash
# Echo: data output
result=$(get_value)
echo "$result"  # To stdout, can be piped
generate_list | process

# Messaging: user communication
info 'Processing files...'  # To stderr
warn 'Config not found'
error 'Connection failed'
die 1 'Fatal error'
```

**Anti-pattern:** `echo "ERROR: failed"` → goes to stdout, mixes with data
**Anti-pattern:** `result=$(info "value")` → info goes to stderr, doesn't capture

**Ref:** See 05-echo-vs-messaging.md for full messaging function implementations

---

## Command-Line Arguments

Standard parsing pattern supporting short and long options (-h/--help, -v/--version), canonical version format (scriptname X.Y.Z), validation patterns, and guidance on parsing location (main vs top-level).

---

### Standard Argument Parsing Pattern

**Complete pattern:**
```bash
while (($#)); do case $1 in
  -m|--depth)     noarg "$@"; shift; max_depth="$1" ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;
  -[mvVh]*)     #shellcheck disable=SC2046
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Key components:**
- `noarg "$@"; shift` → Validate option has argument
- `-[mvVh]*` → Bundle short options: `-vvv` or `-mvh`
- `VERBOSE+=1` → Allow stacking: `-vvv` = VERBOSE=3
- `esac; shift; done` → **Critical**: moves to next arg (else infinite loop!)

**The noarg helper:**
```bash
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }
```

**Ref:** See 01-parsing-pattern.md

---

### Version Output Format

**Standard format:** `<script_name> <version_number>`

**The `--version` option should output script name, space, version number. Do NOT include the word "version".**

```bash
# ✓ Correct
-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
# Output: myscript 1.2.3

# ✗ Wrong - don't include "version"
-V|--version) echo "$SCRIPT_NAME version $VERSION"; exit 0 ;;
# Output: myscript version 1.2.3  (incorrect)
```

**Rationale:** Follows GNU standards, consistent with Unix/Linux utilities (e.g., `bash --version` outputs "GNU bash, version 5.2.15").

**Key principle:** Format is `$SCRIPT_NAME $VERSION` with space separator, no "version" word.

**Ref:** See 02-version-format.md for semantic versioning, build metadata

---

### Argument Validation

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"; }
```

**Usage:** Validates that an option has a required argument and it doesn't start with `-`.

**Key principle:** Use `noarg()` helper to validate option arguments before processing.

**Ref:** See 03-validation.md for validation patterns and error handling

---

### Argument Parsing Location

**Recommendation:** Place argument parsing inside `main()` function rather than at top level.

**Benefits:**
- **Testability**: Can test `main()` with different arguments
- **Scoping**: Parsing vars are local to `main()`
- **Encapsulation**: Argument handling is part of main execution flow
- **Mocking**: Easier to mock/test in unit tests

**Recommended pattern:**
```bash
main() {
  # Parse command-line arguments
  while (($#)); do case $1 in
    --builtin)    INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1 ;;
    --no-builtin) SKIP_BUILTIN=1 ;;
    --prefix)     shift; PREFIX="$1"
                  # Update derived paths
                  BIN_DIR="$PREFIX"/bin
                  LOADABLE_DIR="$PREFIX"/lib/bash/loadables ;;
    -h|--help)    show_help; exit 0 ;;
    -*)           die 22 "Invalid option '$1'" ;;
    *)            >&2 show_help; die 2 "Unknown option '$1'" ;;
  esac; shift; done

  # Proceed with main logic
  check_prerequisites
  build_components
  install_components
}

main "$@"
#fin
```

**Alternative for simple scripts (<40 lines):**
```bash
#!/bin/bash
set -euo pipefail

# Simple scripts can parse at top level
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           die 22 "Invalid option '$1'" ;;
  *)            FILES+=("$1") ;;
esac; shift; done

# Rest of simple script logic
```

**Key principle:** For scripts with `main()` function, parse arguments inside `main()` for better testability and encapsulation. For simple scripts without `main()`, top-level parsing is acceptable.

**Ref:** See 04-parsing-location.md for testing examples, complex parsing patterns, argument validation

---

## File Operations

File testing operators (-e, -f, -d, -r, -w, -x) with quoting, safe wildcard expansion (rm ./* never rm *), process substitution (< <(command)), and here document patterns for multi-line input.

---

### Safe File Testing

**Always quote and use `[[ ]]`:**
```bash
[[ -f "$file" ]] && source "$file"
[[ -d "$dir" ]] || die 1 "Not a directory"
[[ -r "$file" ]] || die 5 "Cannot read"
[[ -x "$script" ]] || die 126 "Not executable"
[[ -s "$log" ]] || warn 'Empty log'
```

**Common tests:**
- `-f` Regular file, `-d` Directory, `-L` Symlink
- `-r` Readable, `-w` Writable, `-x` Executable, `-s` Not empty
- `-nt` Newer than, `-ot` Older than

**Pattern:**
```bash
validate_file() {
  [[ -f "$1" ]] || die 2 "Not found: $1"
  [[ -r "$1" ]] || die 5 "Cannot read: $1"
}
```

**Anti-pattern:**
```bash
# ✗ Unquoted
[[ -f $file ]]

# ✓ Always quote
[[ -f "$file" ]]
```

**Ref:** See 01-file-testing.md

---

### Wildcard Expansion

**Always use explicit path when doing wildcard expansion to avoid issues with filenames starting with `-`.**

```bash
# ✓ Correct - explicit path prevents flag interpretation
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

# ✗ Wrong - filenames starting with - become flags
rm -v *
```

**Key principle:** Prefix wildcards with `./` to prevent filenames starting with `-` from being interpreted as flags.

**Ref:** See 02-wildcard-expansion.md for advanced patterns

---

### Process Substitution

**Use `<(command)` for command output as file input. Eliminates temp files, avoids subshell issues.**

```bash
# Compare outputs
diff <(sort file1) <(sort file2)

# Read into array (no subshell)
readarray -t users < <(getent passwd | cut -d: -f1)

# Avoid pipe-to-while bug
declare -i count=0
while read -r line; do
  ((count+=1))
done < <(cat file)
echo "$count"  # Correct (not 0)!

# Parallel processing
cat log | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  > all.log
```

**Anti-pattern:**
```bash
# ✗ Temp files
temp=$(mktemp); sort f1 > "$temp"; diff "$temp" f2; rm "$temp"

# ✓ Process substitution
diff <(sort f1) f2
```

**Key:** Eliminates temp files, preserves variable scope, enables parallelism.

**Ref:** See 03-process-substitution.md

---

### Here Documents

**Use for multi-line strings or input.**

```bash
# No variable expansion (note single quotes)
cat <<'EOF'
This is a multi-line
string with no variable
expansion.
EOF

# With variable expansion
cat <<EOF
User: $USER
Home: $HOME
EOF
```

**Key principle:** `<<'EOF'` for literal content, `<<EOF` for variable expansion.

**Ref:** See 04-here-documents.md, also 04-quoting/08-here-documents.md for complete patterns

---

## Security Considerations

Never use SUID/SGID on bash scripts, lock down PATH, understand IFS safety, avoid eval (require justification), validate and sanitize inputs early. Prevents privilege escalation and injection attacks.

---

### SUID/SGID

**NEVER use SUID/SGID on Bash scripts. This is catastrophically dangerous.**

```bash
# ✗ NEVER do this
chmod u+s /usr/local/bin/script.sh  # CATASTROPHIC!

# ✓ Use sudo
sudo /usr/local/bin/script.sh

# ✓ Configure sudoers
# In /etc/sudoers:
# username ALL=(ALL) NOPASSWD: /path/to/script.sh
```

**Why dangerous:**
- **PATH Manipulation**: Kernel uses caller's PATH to find interpreter → trojan attacks
- **IFS Exploitation**: Attacker controls word splitting with elevated privileges
- **Library Injection**: LD_PRELOAD injects malicious code
- **No Sandboxing**: Shell expansions can be exploited

**Safe alternatives:**
1. sudo with configured permissions
2. setuid wrapper (compiled C program)
3. PolicyKit (pkexec)
4. systemd service

**Key:** If you think you need SUID on shell script, you're solving the wrong problem.

**Ref:** See 01-suid-sgid.md

---

### PATH Security

**Secure PATH immediately to prevent command hijacking attacks.**

**Lock down at script start:**
```bash
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Attack example:**
```bash
# Attacker creates malicious /tmp/ls
# Sets PATH=/tmp:$PATH
# Script executes /tmp/ls instead of /bin/ls!
```

**Secure patterns:**
```bash
# 1. Complete lockdown
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'

# 2. Full command paths (maximum security)
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
```

**Anti-patterns:**
```bash
# ✗ Trusting inherited PATH
#!/bin/bash
ls /etc  # Could execute trojan!

# ✗ PATH includes current directory
export PATH=.:$PATH  # Any command hijackable!

# ✗ PATH includes /tmp
export PATH=/tmp:$PATH  # World-writable directory!

# ✗ Empty elements (interpreted as current dir)
export PATH=/usr/bin::/bin  # :: = current dir
```

**Principle:** Attacker who controls PATH controls which code runs. Lock it first.

**Ref:** See 02-path-security.md

---

### IFS Manipulation Safety

**IFS controls word splitting. Protect it to prevent field splitting attacks.**

**Safe patterns:**
```bash
# ✓ One-line (most concise)
IFS=',' read -ra fields <<< "$csv_data"  # Auto-reset after command

# ✓ Local IFS in function
parse_csv() {
  local -- IFS=','  # Auto-restored on return
  read -ra fields <<< "$csv_data"
}

# ✓ Lock at script start (maximum security)
#!/bin/bash
set -euo pipefail
IFS=$' \t\n'  # Space, tab, newline
readonly IFS
```

**Attack example:**
```bash
# Attacker sets IFS=$'\n'
# Now "file1.txt file2.txt" is NOT split on spaces!
# Becomes single element: files=("file1.txt file2.txt")
```

**Anti-patterns:**
```bash
# ✗ Modifying IFS without protection
IFS=','
read -ra fields <<< "$csv"
# IFS is now ',' for rest of script - BROKEN!

# ✓ Correct
local -- IFS=','
read -ra fields <<< "$csv"
```

**Principle:** IFS is security-critical. Use one-line assignment or local scoping.

**Ref:** See 03-ifs-safety.md

---

### Eval Command

**NEVER use `eval` with untrusted input. Avoid entirely - better alternatives exist.**

**Why dangerous:** `eval` performs expansion TWICE, enabling code injection. No sandboxing, runs with full privileges.

```bash
# ✗ NEVER: eval "$user_input"  # Complete system compromise

# ✓ Safe alternatives:
# 1. Arrays for commands: cmd=(find "$dir"); "${cmd[@]}"
# 2. Indirect expansion: echo "${!var_name}"
# 3. Associative arrays: declare -A data; data[$key]="$val"
# 4. Case/arrays for dispatch: case "$action" in start) start_fn ;; esac
# 5. printf -v for assignment: printf -v "$var" '%s' "$value"
```

**Attack:**
```bash
user_input="; rm -rf /"
eval "$user_input"  # Disaster!
```

**Key:** If you think you need `eval`, you're solving the wrong problem. Use arrays/indirect expansion instead.

**Ref:** See 04-eval-command.md

---

### Input Sanitization

**Always validate user input to prevent injection attacks.**

```bash
# Filename sanitization
sanitize_filename() {
  local -- name="$1"
  [[ -n "$name" ]] || die 22 'Empty filename'
  name="${name//\.\./}"  # Remove ..
  name="${name//\//}"    # Remove /
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename"
  echo "$name"
}

# Numeric validation
validate_port() {
  [[ "$1" =~ ^[0-9]+$ ]] || die 22 "Invalid port"
  ((1 <= $1 && $1 <= 65535)) || die 22 "Port range 1-65535"
}

# Path validation (prevent traversal)
validate_path() {
  local -- real_path
  real_path=$(realpath -e -- "$1") || die 22 "Invalid path"
  [[ "$real_path" == "$2"* ]] || die 5 "Path outside allowed dir"
}

# Whitelist validation
validate_choice() {
  case $1 in start|stop|restart) return 0 ;; esac
  die 22 "Invalid choice: $1"
}
```

**Anti-patterns:**
```bash
# ✗ NEVER use eval with user input
eval "$user_command"     # CATASTROPHIC!

# ✗ Always use -- separator
rm "$user_file"          # Fails if file=--delete-all
rm -- "$user_file"       # ✓ Correct
```

**Principle:** Never trust user input. Validate type, format, range. Use whitelist and `--` separator.

**Ref:** See 05-input-sanitization.md

---

## Code Style & Best Practices

Code formatting (2-space indent, 100-char lines), commenting practices (explain WHY not WHAT), blank line usage, section banners, language-specific practices, mandatory ShellCheck compliance, and testing patterns.

---

### Code Formatting

**Indentation:** Use 2 spaces (NOT tabs), maintain consistency throughout.

**Line Length:** Keep lines under 100 characters when practical. Long file paths/URLs can exceed when necessary. Use `\` for line continuation.

**Key principle:** 2-space indentation, 100-char lines, consistent formatting.

**Ref:** See 01-code-formatting.md for complete formatting guidelines

---

### Comments

**Focus comments on explaining WHY (rationale, business logic) rather than WHAT (code shows).**

```bash
# ✓ Good - explains WHY (rationale and special cases)
# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide
# bash profile integration, regardless of PREFIX
declare -- PROFILE_DIR=/etc/profile.d

((max_depth > 0)) || max_depth=255  # -1 means unlimited (WHY -1 is special)

# If user explicitly requested --builtin, try to install dependencies
if ((BUILTIN_REQUESTED)); then
  warn 'bash-builtins not found, attempting install...'
fi

# ✗ Bad - restates WHAT code already shows
# Set PROFILE_DIR to /etc/profile.d
declare -- PROFILE_DIR=/etc/profile.d

# Check if max_depth is greater than 0, otherwise set to 255
((max_depth > 0)) || max_depth=255

# If BUILTIN_REQUESTED is non-zero
if ((BUILTIN_REQUESTED)); then
  # Print warning message
  warn 'bash-builtins not found...'
fi
```

**Good comment patterns:**
- Explain non-obvious business rules or edge cases
- Document intentional deviations from normal patterns
- Clarify complex logic not immediately apparent
- Note why specific approach chosen over alternatives
- Warn about subtle gotchas or side effects

**Avoid commenting:**
- Simple variable assignments
- Obvious conditionals
- Standard patterns already documented in style guide
- Code that is self-explanatory through good naming

**Key principle:** Comment the WHY (rationale, business logic, decisions), not the WHAT (code already shows). Good code is self-documenting; comments explain the reasoning.

**Ref:** See 02-comments.md for section comments, documentation patterns, comment styles

---

### Blank Line Usage

**Use blank lines strategically to create visual separation between logical blocks.**

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
readonly -- VERSION SCRIPT_PATH
                                          # ← After metadata group

# Default values                          # ← Before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ← After variable group

# Derived paths
BIN_DIR="$PREFIX"/bin
                                          # ← Before function
check_prerequisites() {
  info 'Checking prerequisites...'

  # Check for gcc                         # ← After info call
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' not found"
  fi

  success 'Prerequisites check passed'    # ← Between checks
}
                                          # ← Between functions
main() {
  check_prerequisites
  install_files
}

main "$@"
#fin
```

**Guidelines:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between groups of related variables
- Blank lines before/after multi-line conditionals or loops
- Avoid multiple consecutive blank lines (one is sufficient)
- No blank line needed between short, related statements

**Key principle:** Use blank lines to create visual paragraphs that group related code, making structure clear at a glance.

**Ref:** See 03-blank-lines.md for complete examples, edge cases, style guidelines

---

### Blank Line Usage

**Use blank lines strategically to improve readability by creating visual separation between logical blocks.**

**Guidelines:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between groups of related variables
- Blank lines before and after multi-line conditional or loop blocks
- Avoid multiple consecutive blank lines (one is sufficient)
- No blank line needed between short, related statements

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
VERSION='1.0.0'
readonly -- VERSION
                        # ← Blank line after metadata group

# Default values         # ← Blank line before section comment
declare -- PREFIX=/usr/local
                        # ← Blank line after variable group

check_prerequisites() {
  info 'Checking prerequisites...'
                        # ← Blank line after info call
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' not found."
  fi
                        # ← Blank line between checks
  success 'Check passed'
}
                        # ← Blank line between functions
main() {
  check_prerequisites
}
```

**Key principle:** One blank line for visual separation between logical groups, avoid multiple consecutive blank lines.

**Ref:** See 03-blank-lines.md for complete guidelines

---

### Section Comments

**Use lightweight section comments to organize code into logical groups:**

```bash
# Default values
declare -- PREFIX=/usr/local
declare -i VERBOSE=1
declare -i DRY_RUN=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib

# Core message function
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  # ...
}

# Conditional messaging functions
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Unconditional messaging functions
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

**Guidelines:**
- Use simple `# Description` format (no dashes, no box drawing)
- Keep section comments short (2-4 words typically)
- Place immediately before the group it describes
- Follow with blank line after the group
- Reserve 80-dash separators for major divisions only

**Common section comment patterns:**
- `# Default values` / `# Configuration`
- `# Derived paths` / `# Computed variables`
- `# Core message function`
- `# Conditional messaging functions`
- `# Helper functions` / `# Utility functions`
- `# Business logic` / `# Main logic`
- `# Validation functions`

**Key principle:** Simple `# Section name` comments create logical groups. Keep short, descriptive, placed immediately before group.

**Ref:** See 04-section-comments.md for complete patterns, organization strategies

---

### Language Practices

**Use `[[ ]]` not `[ ]`, `(())` for arithmetic, avoid backticks, use `$()` for command substitution.**

```bash
# ✓ Modern Bash
[[ -f "$file" ]]
((count > 0))
output=$(command)
readonly -- VAR

# ✗ Old/deprecated
[ -f "$file" ]
[ "$count" -gt 0 ]
output=`command`
declare -r VAR
```

**Key:** Modern Bash 5.2+ constructs, avoid legacy syntax.

**Ref:** See 05-language-practices.md

---

### Development Practices

**ShellCheck Compliance (COMPULSORY):**
```bash
# Document intentional violations with reason
#shellcheck disable=SC2046  # Intentional word splitting
set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"

# Run shellcheck
shellcheck -x myscript.sh
```

**Script Termination:**
```bash
# Always end with #fin (or #end) marker
main "$@"
#fin
```

**Defensive Programming:**
```bash
# Default values for critical variables
: "${VERBOSE:=0}"
: "${DEBUG:=0}"

# Validate inputs early
[[ -n "$1" ]] || die 1 'Argument required'

# Guard against unset
set -u
```

**Performance Considerations:**
- Minimize subshells
- Use built-in string operations over external commands
- Batch operations when possible
- Use process substitution over temp files

**Testing Support:**
- Make functions testable
- Use dependency injection for external commands
- Support verbose/debug modes
- Return meaningful exit codes

**Key principle:** ShellCheck is mandatory. End scripts with `#fin`. Use defensive programming. Prefer builtins for performance.

**Ref:** See 06-development-practices.md for complete checklist, testing patterns, CI/CD integration

---

## Advanced Patterns

10 production patterns: debugging (set -x, PS4), dry-run mode, secure temp files (mktemp), environment variables, regex, background jobs, structured logging, performance profiling, testing, and progressive state management.

---

### Debugging and Development

**Enable debugging features for development and troubleshooting.**

```bash
# Debug mode implementation
declare -i DEBUG="${DEBUG:-0}"

# Enable trace when DEBUG set
((DEBUG)) && set -x

# Enhanced PS4 for better trace output
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# Conditional debug output
debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}

# Usage
DEBUG=1 ./script.sh  # Run with debug output
```

**Key principle:** Use `DEBUG` flag with `set -x` for tracing. Enhance `PS4` to show file, line, and function. Provide `debug()` function for conditional output.

**Ref:** See 01-debugging.md for advanced debugging, breakpoints, verbose modes

---

### Dry-Run Pattern

**Implement preview mode for operations that modify system state, allowing users to see what would happen without making changes.**

```bash
# Declare dry-run flag
declare -i DRY_RUN=0

# Parse from command-line
-n|--dry-run) DRY_RUN=1 ;;
-N|--not-dry-run) DRY_RUN=0 ;;

# Pattern: Check flag, show preview, return early
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi

  # Actual build operations
  make standalone || die 1 'Build failed'
}

install_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would install:' \
         "  $BIN_DIR/mailheader" \
         "  $BIN_DIR/mailmessage" \
         "  $BIN_DIR/mailheaderclean"
    return 0
  fi

  # Actual installation
  install -m 755 build/bin/mailheader "$BIN_DIR"/
  install -m 755 build/bin/mailmessage "$BIN_DIR"/
  install -m 755 build/bin/mailheaderclean "$BIN_DIR"/
}

update_man_database() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would update man database'
    return 0
  fi

  # Actual update
  mandb -q 2>/dev/null || true
}
```

**Pattern structure:**
1. Check `((DRY_RUN))` at start of functions that modify state
2. Display preview message with `[DRY-RUN]` prefix using `info`
3. Return early (exit code 0) without performing operations
4. Proceed with real operations only when dry-run disabled

**Benefits:**
- Safe preview of destructive operations
- Users verify paths, files, commands before execution
- Useful for debugging installation scripts
- Maintains identical control flow (same functions, same logic)

**Key principle:** Separate decision logic from action. Script flows through same functions whether in dry-run or not, making it easy to verify logic without side effects.

**Ref:** See 02-dry-run.md for nested dry-run, verbose mode integration, complex operation previews

---

### Temporary File Handling

**Always use `mktemp` + `trap EXIT` for temp files. Never hard-code paths. mktemp creates files atomically with secure 0600 permissions. EXIT trap guarantees cleanup even on script failure or Ctrl-C.**

**Rationale:**
- **Security**: Prevents predictable temp file names (security risk) and ensures 0600 permissions
- **Uniqueness**: mktemp guarantees no collisions between concurrent script instances
- **Cleanup guarantee**: trap EXIT runs even on failures, interrupts, or early returns

```bash
# Single temp file
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file
echo 'data' > "$temp_file"

# Multiple temp files - cleanup function pattern
declare -a TEMP_FILES=()
cleanup() { for f in "${TEMP_FILES[@]}"; do [[ -f "$f" ]] && rm -f "$f"; [[ -d "$f" ]] && rm -rf "$f"; done; }
trap cleanup EXIT
TEMP_FILES+=("$(mktemp)")
TEMP_FILES+=("$(mktemp -d)")
```

**Anti-pattern:** `temp="/tmp/app.txt"` → not unique, collisions, no cleanup, security risk
**Anti-pattern:** `temp="/tmp/app_$$.txt"` → still predictable, race condition
**Anti-pattern:** No trap → temp files accumulate, resource leak
**Anti-pattern:** Multiple traps → later traps overwrite earlier ones, incomplete cleanup

**Ref:** See 03-temp-files.md for security validation, signal handling, --keep-temp option, edge cases

---

### Environment Variable Best Practices

**Proper handling of environment variables.**

```bash
# Required environment validation (script exits if not set)
: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"
: "${DATABASE_URL:?DATABASE_URL must be set}"

# Optional with defaults
: "${OPTIONAL_VAR:=default_value}"
: "${LOG_LEVEL:=INFO}"

# Export with validation
export DATABASE_URL="${DATABASE_URL:-localhost:5432}"
export API_KEY="${API_KEY:?API_KEY environment variable required}"

# Check multiple required variables
declare -a REQUIRED=(DATABASE_URL API_KEY SECRET_TOKEN)

check_required_env() {
  local -- var
  for var in "${REQUIRED[@]}"; do
    [[ -n "${!var:-}" ]] || {
      error "Required environment variable '$var' not set"
      return 1
    }
  done
}
```

**Key principle:** Use `:` builtin with parameter expansion for validation. `:?` for required, `:=` for defaults, `:-` for optional with fallback.

**Ref:** See 04-env-variables.md for .env file loading, secret handling, validation patterns

---

### Regular Expression Guidelines

**Best practices for regex in Bash.**

```bash
# POSIX character classes for portability
[[ "$var" =~ ^[[:alnum:]]+$ ]]      # Alphanumeric only
[[ "$var" =~ [[:space:]] ]]         # Contains whitespace
[[ "$var" =~ ^[[:digit:]]+$ ]]      # Digits only

# Store complex patterns in readonly variables
readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
readonly -- IPV4_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

# Usage
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 'Invalid email'

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
fi
```

**Key principle:** Use POSIX character classes for portability. Store complex patterns in readonly variables. Access captures with `BASH_REMATCH`.

**Ref:** See 05-regex.md for advanced patterns, lookaheads, validation examples

---

### Background Job Management

**Managing background processes and jobs.**

```bash
# Start and track PID
long_running_command &
PID=$!

# Check if still running
kill -0 "$PID" 2>/dev/null && info "Process $PID is running"

# Wait with timeout
if timeout 10 wait "$PID"; then
  success 'Process completed'
else
  warn 'Process timed out or failed'
  kill "$PID" 2>/dev/null || true
fi

# Multiple background jobs
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done

# Wait for all
for pid in "${PIDS[@]}"; do
  wait "$pid"
done
```

**Job control with error handling:**
```bash
run_with_timeout() {
  local -i timeout="$1"; shift
  local -- command="$*"

  timeout "$timeout" bash -c "$command" &
  local -i pid=$!

  if wait "$pid"; then
    return 0
  else
    local -i exit_code=$?
    ((exit_code == 124)) && error "Timed out after ${timeout}s"
    return "$exit_code"
  fi
}
```

**Key principle:** Track background jobs with `$!`, use `wait` to collect exit codes, use `kill -0` to check if running, handle timeouts with `timeout` command.

**Ref:** See 06-background-jobs.md for parallel processing, job arrays, signal handling

---

### Logging Best Practices

**Structured logging for production scripts (simplified pattern).**

```bash
# Simple file logging
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Ensure log directory exists
[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"

# Structured logging function
log() {
  local -- level="$1"
  local -- message="${*:2}"

  # Format: ISO8601 timestamp, script name, level, message
  printf '[%s] [%s] [%-5s] %s\n' \
    "$(date -Ins)" \
    "$SCRIPT_NAME" \
    "$level" \
    "$message" >> "$LOG_FILE"
}

# Convenience functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
```

**Key principle:** Structured logs with timestamp, script name, level, and message. Use convenience wrappers for common log levels.

**Ref:** See 07-logging.md for log rotation, filtering by level, advanced patterns

---

### Performance Profiling

**Simple performance measurement patterns.**

```bash
# Using SECONDS builtin
profile_operation() {
  local -- operation="$1"
  SECONDS=0
  eval "$operation"
  info "Operation completed in ${SECONDS}s"
}

# High-precision timing with EPOCHREALTIME
timer() {
  local -- start end runtime
  start=$EPOCHREALTIME
  "$@"
  end=$EPOCHREALTIME
  runtime=$(awk "BEGIN {print $end - $start}")
  info "Execution time: ${runtime}s"
}
```

**Key principle:** Use `SECONDS` builtin for simple timing, `EPOCHREALTIME` for high-precision measurement.

**Ref:** See 08-profiling.md for detailed profiling, benchmarking patterns

---

### Testing Support Patterns

**Dependency injection for testing:**
```bash
# Define mockable functions
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }
declare -f CURL_CMD >/dev/null || CURL_CMD() { curl "$@"; }

# In production
find_files() {
  FIND_CMD "$@"
}

# In tests, override:
FIND_CMD() { echo 'mocked_file1.txt mocked_file2.txt'; }
```

**Test mode flag:**
```bash
declare -i TEST_MODE="${TEST_MODE:-0}"

# Conditional behavior
if ((TEST_MODE)); then
  DATA_DIR='./test_data'
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR='/var/lib/app'
  RM_CMD() { rm "$@"; }
fi
```

**Assert function:**
```bash
assert() {
  local -- expected="$1"
  local -- actual="$2"
  local -- message="${3:-Assertion failed}"

  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
}
```

**Test runner pattern:**
```bash
run_tests() {
  local -i passed=0 failed=0
  local -- test_func

  # Find all functions starting with test_
  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1
      echo "✓ $test_func"
    else
      failed+=1
      echo "✗ $test_func"
    fi
  done

  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```

**Key principle:** Make scripts testable through dependency injection, test mode flags, and mockable functions. Use assert() for validation and test runner for automation.

**Ref:** See 09-testing.md for complete test frameworks, mocking strategies, CI/CD patterns

---

### Progressive State Management

**Modify boolean flags based on runtime conditions, separating decision logic from execution.**

```bash
# 1. Initial flags
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0

# 2. Parse args
--builtin) INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1 ;;

# 3. Adjust based on runtime
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0  # User override

if ! check_builtin_support; then
  if ((BUILTIN_REQUESTED)); then
    install_bash_builtins || INSTALL_BUILTIN=0  # Try, disable on fail
  else
    INSTALL_BUILTIN=0  # Didn't request, just skip
  fi
fi

# 4. Execute based on final state
((INSTALL_BUILTIN)) && install_builtin
```

**Pattern:** Parse → Validate → Adjust flags → Execute

**Benefits:** Clean separation, traceable state, fail-safe.

**Key:** Flags change through script based on conditions, actions use final state.

**Ref:** See 10-progressive-state.md

---

#fin
