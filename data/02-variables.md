# Section 2: Variables & Data Types

## BCS0200 Section Overview

All variables must have explicit type declarations. This section covers declaration patterns, scoping, naming conventions, arrays, parameter expansion, and boolean flags.

## BCS0201 Type-Specific Declarations

Use explicit type declarations to make variable intent clear.

```bash
# correct
declare -i count=0           # integer
declare -- filename=''       # string
declare -a files=()          # indexed array
declare -A config=()         # associative array
declare -r VERSION=1.0.0     # readonly constant
local -- path=$1             # local string
local -i retval=0            # local integer

# wrong — no type, no separator
count=0
local filename=$1
```

The `--` separator prevents option injection if a variable name starts with `-`.

## BCS0202 Variable Scoping

Always declare function-specific variables as `local`.

```bash
# correct
process_file() {
  local -- filename=$1
  local -i line_count=0
  # filename and line_count are scoped to this function
}

# wrong — pollutes global namespace
process_file() {
  filename=$1
  line_count=0
}
```

Without `local`, variables become global, overwrite same-named variables, persist after function return, and break recursive calls.

## BCS0203 Naming Conventions

```bash
# correct
readonly MAX_RETRIES=3              # UPPER_CASE for constants/globals
declare -i VERBOSE=1                   # UPPER_CASE for global state

process_log_file() {                   # lower_case for functions
  local -- file_count=0                # lower_case for locals
}

_validate_input() { :; }              # underscore prefix for private functions

# wrong
processLogFile() { :; }               # camelCase
my-function() { :; }                  # dashes in names
declare -i verbose=1                  # lowercase for global
```

Avoid use single-letter names or shell built-in names like `PATH`, `HOME`, `USER`.

## BCS0204 Constants and Environment Variables

Use `readonly` for values that never change. Use `declare -x` for variables needed by child processes.

```bash
# correct
readonly CONFIG_DIR=/etc/myapp
declare -x DATABASE_URL='postgres://localhost/mydb'
declare -rx BUILD_ENV=production     # readonly + exported

# wrong — exporting constants children don't need
export VERSION=1.0.0                 # children rarely need VERSION
```

Don't make user-configurable variables readonly before argument parsing is complete.

## BCS0205 Readonly Patterns

For script metadata, use `declare -r` for immediate readonly:

```bash
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

For other variable groups, declare first, then make readonly in a batch:

```bash
# correct — declare, then batch readonly
declare -- PREFIX=/usr/local
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp
readonly PREFIX BIN_DIR SHARE_DIR

# wrong — readonly before parsing complete
readonly VERBOSE=1    # can't change during arg parsing
```

Three-step workflow: (1) declare with defaults, (2) parse/modify in main, (3) readonly after parsing.

## BCS0206 Arrays

```bash
# correct
declare -a files=()
files+=("$1")                        # append
files+=("$arg1" "$arg2")             # append multiple
echo "${#files[@]}"                  # length

readarray -t lines < <(command)      # populate from command
mapfile -t data < "$file"            # populate from file

local -a cmd=(myapp --config "$file")
"${cmd[@]}"                          # execute safely

# wrong
array=($string)                      # word splitting creates array
for item in ${items[@]}; do          # unquoted expansion
```

Always quote array expansions: `"${array[@]}"`. Never use `${array[*]}` in iteration. Use `readarray -t` or `mapfile -t` instead of word-split assignment.

## BCS0207 Parameter Expansion

Use `"$var"` as the default form. Use braces only when syntactically necessary.

```bash
# correct — no braces needed
echo "$HOME"/bin
echo "$PREFIX/bin"
local -- name=$1

# correct — braces required
echo "${var##*/}"                    # parameter expansion
echo "${var:-default}"               # default value
echo "${array[@]}"                   # array access
echo "${10}"                         # positional > 9
echo "${var1}${var2}"                # adjacent variables

# wrong — unnecessary braces
echo "${HOME}/bin"
echo "${PREFIX}/bin"
```

Common expansions: `${var:-default}` (default), `${var##*/}` (basename), `${var%/*}` (dirname), `${var//old/new}` (replace all), `${var^^}` (uppercase), `${var,,}` (lowercase).

## BCS0208 Boolean Flags

Use integer variables for boolean flags.

```bash
# correct
declare -i DRY_RUN=0
declare -i VERBOSE=1

((DRY_RUN)) && info 'Dry-run mode' ||:
((VERBOSE)) || return 0

# wrong
DRY_RUN=false                        # string boolean
if [[ "$DRY_RUN" == "true" ]]; then  # string comparison
```

Initialize to `0` (false) or `1` (true). Test with `((FLAG))` — non-zero is true, zero is false.

## BCS0209 Derived Variables

Derive paths from base variables to implement DRY.

```bash
# correct
declare -- PREFIX=/usr/local
declare -- BIN_DIR="$PREFIX"/bin
declare -- SHARE_DIR="$PREFIX"/share/myapp

# wrong — hardcoded, not derived
declare -- BIN_DIR=/usr/local/bin
declare -- SHARE_DIR=/usr/local/share/myapp
```

Make derived variables readonly only after all parsing and derivation is complete. Document hardcoded exceptions with comments.
