# Variables & Data Types - Rulets
## Type-Specific Declarations
- [BCS0201] Always use explicit type declarations to make variable intent clear: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0201] Declare integer variables with `declare -i count=0` to enable automatic arithmetic evaluation and type enforcement; non-numeric values become 0.
- [BCS0201] Use `declare --` for string variables; the `--` separator prevents option injection if variable name starts with `-`.
- [BCS0201] Declare indexed arrays with `declare -a files=()` for ordered lists; never assign scalars to array variables.
- [BCS0201] Declare associative arrays with `declare -A config=()` for key-value maps; requires Bash 4.0+.
- [BCS0201] Use `readonly --` for constants that should never change after initialization: `readonly -- VERSION=1.0.0`.
- [BCS0201] Always use `local --` with the `--` separator for function variables: `local -- filename=$1`.
- [BCS0201] Combine type and scope modifiers when needed: `local -i count=0`, `local -a files=()`, `readonly -A CONFIG=()`.
## Variable Scoping
- [BCS0202] Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.
- [BCS0202] Without `local`, function variables become global, overwrite same-named variables, persist after function returns, and break recursive calls.
- [BCS0202] Use `local --` for strings, `local -i` for integers, `local -a` for arrays in functions.
## Naming Conventions
- [BCS0203] Use UPPER_CASE for constants and global variables: `readonly MAX_RETRIES=3`, `declare -i VERBOSE=1`.
- [BCS0203] Use lower_case with underscores for local variables: `local -- file_count=0`.
- [BCS0203] Prefix private/internal functions with underscore: `_validate_input()`.
- [BCS0203] Never use lowercase single-letter names or shell built-in variable names like `PATH`, `HOME`, `USER`.
## Constants and Environment Variables
- [BCS0204] Use `readonly` for values that never change: script metadata, configuration paths, constants.
- [BCS0204] Use `declare -x` or `export` for variables that child processes need: `declare -x DATABASE_URL='...'`.
- [BCS0204] Combine both with `declare -rx BUILD_ENV=production` for constants that are also exported.
- [BCS0204] Don't export constants that child processes don't need; don't make user-configurable variables readonly too early.
## Readonly After Group Pattern
- [BCS0205] For non-metadata variable groups, declare variables first with values, then make them all readonly in a single statement: `readonly -- PREFIX BIN_DIR SHARE_DIR`.
- [BCS0205] Group logically related variables together: path constants group, color definitions group, configuration defaults group.
- [BCS0205] Use the three-step progressive readonly workflow for arguments: declare with defaults, parse and modify in main(), make readonly after parsing complete.
- [BCS0205] For script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME), prefer `declare -r` for immediate readonly declaration per BCS0103.
- [BCS0205] Always use `--` separator with readonly to prevent option injection: `readonly -- VAR1 VAR2`.
## Readonly Declaration
- [BCS0206] Use `declare -r` or `readonly` for constants to prevent accidental modification: `declare -ra REQUIRED=(pandoc git)`.
- [BCS0206] Use `#shellcheck disable=SC2155` before `declare -r` with command substitution: `declare -r SCRIPT_PATH=$(realpath -- "$0")`.
## Arrays
- [BCS0207] Always quote array expansions to preserve element boundaries: `"${array[@]}"` not `${array[@]}`.
- [BCS0207] Append elements with `+=`: `paths+=("$1")`, `args+=("$arg1" "$arg2")`.
- [BCS0207] Check array length with `${#array[@]}`; check if empty with `((${#array[@]} == 0))`.
- [BCS0207] Read command output into arrays with `readarray -t lines < <(command)` or `mapfile -t`.
- [BCS0207] Build commands safely with arrays: `local -a cmd=(myapp --config "$file"); "${cmd[@]}"`.
- [BCS0207] Never use `${array[*]}` in iteration; always use `${array[@]}`.
- [BCS0207] Never create arrays with word splitting `array=($string)`; use `readarray -t array <<< "$string"`.
## Derived Variables
- [BCS0209] Derive paths from base variables to implement DRY: `BIN_DIR="$PREFIX"/bin` not `BIN_DIR=/usr/local/bin`.
- [BCS0209] Group derived variables with section comments explaining their dependencies.
- [BCS0209] When base variables change (especially during argument parsing), update all derived variables.
- [BCS0209] Document hardcoded exceptions that don't derive from base values with explanatory comments.
- [BCS0209] Make derived variables readonly only after all parsing and derivation is complete.
## Parameter Expansion & Braces Usage
- [BCS0210] Use `"$var"` as the default form; only use braces `"${var}"` when syntactically necessary.
- [BCS0210] Braces are required for: parameter expansion `${var##*/}`, concatenation without separator `${prefix}suffix`, array access `${array[@]}`, positional params > 9 `${10}`.
- [BCS0210] Braces are not required for standalone variables `"$var"` or path concatenation with separators `"$PREFIX"/bin`.
- [BCS0210] Common parameter expansions: `${var:-default}` (default value), `${var##*/}` (basename), `${var%/*}` (dirname), `${var//old/new}` (replace all).
## Boolean Flags Pattern
- [BCS0211] Use integer variables with `declare -i` or `local -i` for boolean flags: `declare -i DRY_RUN=0`.
- [BCS0211] Initialize boolean flags explicitly to `0` (false) or `1` (true).
- [BCS0211] Test flags with arithmetic conditional `((FLAG))` which returns true for non-zero: `((DRY_RUN)) && info 'Dry-run mode'`.
- [BCS0211] Name boolean flags descriptively in ALL_CAPS: `DRY_RUN`, `VERBOSE`, `INSTALL_BUILTIN`.
