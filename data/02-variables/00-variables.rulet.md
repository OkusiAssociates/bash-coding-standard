# Variables & Data Types - Rulets
## Type-Specific Declarations
- [BCS0201] Always use explicit type declarations to make variable intent clear: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0201] Declare integer variables with `declare -i count=0` to enable automatic arithmetic evaluation and type enforcement; non-numeric assignments evaluate to 0.
- [BCS0201] Always use `--` separator with `declare`, `local`, and `readonly` to prevent option injection: `declare -- filename=$1` not `declare filename=$1`.
- [BCS0201] Never assign scalars to array variables; use array syntax: `files=('item')` not `files='item'`.
- [BCS0201] Always use `local` with type modifiers for function variables: `local -i count=0`, `local -a files=()`, `local -- path=$1`.
- [BCS0201] Combine readonly with type declarations for constants: `readonly -i MAX_RETRIES=3`, `readonly -a ACTIONS=(start stop)`.
- [BCS0201] Use `declare -A` explicitly for associative arrays; `declare CONFIG` creates a scalar that treats string keys as index 0.
## Variable Scoping
- [BCS0202] Always declare function-specific variables as `local` to prevent namespace pollution and global variable overwriting.
- [BCS0202] Without `local`, function variables become global, persist after return, and break recursive function calls.
## Naming Conventions
- [BCS0203] Use UPPER_CASE for constants and global variables: `readonly MAX_RETRIES=3`, `declare -i VERBOSE=1`.
- [BCS0203] Use lower_case with underscores for local variables: `local file_count=0`; CamelCase acceptable for important locals.
- [BCS0203] Prefix internal/private functions with underscore: `_validate_input()`.
- [BCS0203] Never use shell reserved names as variables: avoid `PATH`, `HOME`, `USER`, etc.
## Constants and Environment Variables
- [BCS0204] Use `readonly` for values that never change: script metadata, configuration paths, constants.
- [BCS0204] Use `declare -x` or `export` for variables needed by child processes; `readonly` alone does not export.
- [BCS0204] Combine both when needed: `declare -rx BUILD_ENV=production` makes a constant available to subprocesses.
- [BCS0204] Don't export constants unnecessarily; only export if child processes need the value.
## Readonly After Group Pattern
- [BCS0205] For non-metadata variable groups, initialize all values first, then make readonly in a single statement: declare values, then `readonly -- PREFIX BIN_DIR SHARE_DIR`.
- [BCS0205] Script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) should use `declare -r` for immediate readonly per BCS0103.
- [BCS0205] Group logically related variables together for readonly: colors group, path constants group, configuration defaults group.
- [BCS0205] For argument-parsed variables, use three-step pattern: declare with defaults, modify during parsing, make readonly after parsing complete.
- [BCS0205] Always use `--` separator with readonly: `readonly -- VAR1 VAR2` prevents option injection if names start with `-`.
## Readonly Declaration
- [BCS0206] Use `readonly` for constants to prevent accidental modification: `readonly -a REQUIRED=(pandoc git md2ansi)`.
- [BCS0206] Combine readonly with command substitution using ShellCheck disable comment: `#shellcheck disable=SC2155` then `readonly -- SCRIPT_PATH=$(realpath -- "$0")`.
## Arrays
- [BCS0207] Always quote array expansions to preserve element boundaries: `"${array[@]}"` not `${array[@]}`.
- [BCS0207] Declare arrays explicitly: `declare -a paths=()` for indexed, `declare -A config=()` for associative.
- [BCS0207] Append elements with `+=`: `paths+=("$1")` for single, `args+=("$arg1" "$arg2")` for multiple.
- [BCS0207] Read command output into arrays with `readarray -t lines < <(command)` not pipes to while loops.
- [BCS0207] Build commands safely with arrays: `local -a cmd=(myapp '--config' "$file")` then `"${cmd[@]}"`.
- [BCS0207] Check array length with `${#array[@]}`; check if empty with `((${#array[@]} == 0))`.
- [BCS0207] Use `[@]` for iteration, never `[*]`: `for item in "${array[@]}"` preserves element boundaries.
## Derived Variables
- [BCS0209] Derive variables from base values to maintain DRY principle: `BIN_DIR="$PREFIX"/bin` not `BIN_DIR=/usr/local/bin`.
- [BCS0209] Always update derived variables when base values change during argument parsing; use update functions for many variables.
- [BCS0209] Group derived variables with section comments explaining dependencies: `# Derived from PREFIX`.
- [BCS0209] Document hardcoded exceptions that don't derive: `PROFILE_DIR=/etc/profile.d  # Hardcoded - shell init requires fixed path`.
- [BCS0209] Make derived variables readonly only after all base values are finalized and all derivations updated.
## Parameter Expansion & Braces
- [BCS0210] Use `"$var"` as default form; only add braces `"${var}"` when syntactically required.
- [BCS0210] Braces required for: pattern operations `${var##*/}`, defaults `${var:-default}`, arrays `${array[@]}`, concatenation without separator `${prefix}suffix`.
- [BCS0210] Braces not required when separators delimit naturally: `"$PREFIX"/bin`, `"$var-suffix"`, `"$var.suffix"`.
- [BCS0210] Common expansions: `${var##*/}` basename, `${var%/*}` dirname, `${var:-default}` fallback, `${var//old/new}` replace all.
- [BCS0210] Case conversion (Bash 4.0+): `${var,,}` lowercase, `${var^^}` uppercase.
## Boolean Flags
- [BCS0211] Declare boolean flags as integers with explicit initialization: `declare -i DRY_RUN=0`, `declare -i VERBOSE=0`.
- [BCS0211] Test boolean flags with arithmetic evaluation: `((DRY_RUN)) && info 'Dry-run mode'` not `[[ $DRY_RUN -eq 1 ]]`.
- [BCS0211] Set flags from argument parsing: `--dry-run) DRY_RUN=1 ;;`.
- [BCS0211] Name boolean flags descriptively in ALL_CAPS: `DRY_RUN`, `SKIP_BUILD`, `NON_INTERACTIVE`.
