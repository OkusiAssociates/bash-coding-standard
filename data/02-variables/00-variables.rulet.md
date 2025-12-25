# Variable Declarations & Constants - Rulets
## Type-Specific Declarations
- [BCS0201] Always use explicit type declarations to make variable intent clear: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0201] Always use `--` separator with `local` declarations to prevent option injection: `local -- file="$1"` not `local file="$1"`.
- [BCS0201] Declare integer variables with `declare -i count=0` to enable automatic arithmetic evaluation and type enforcement.
- [BCS0201] Use `declare --` for string variables with `--` separator to prevent option injection when variable names start with `-`.
- [BCS0201] Declare indexed arrays with `declare -a files=()` for ordered lists; never assign scalars to array variables.
- [BCS0201] Declare associative arrays with `declare -A config=()` for key-value maps; requires Bash 4.0+.
- [BCS0201] Use `readonly --` to declare constants that should never change after initialization.
- [BCS0201] Always declare function variables as `local` (with type modifiers like `local -i`, `local -a`) to prevent global namespace pollution.
## Variable Scoping
- [BCS0202] Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.
- [BCS0202] Without `local`, function variables become global and can overwrite global variables, persist after function returns, and interfere with recursive calls.
## Naming Conventions
- [BCS0203] Use UPPER_CASE for constants and environment variables: `readonly MAX_RETRIES=3`, `export DATABASE_URL`.
- [BCS0203] Use lower_case with underscores for local variables: `local file_count=0`; CamelCase is acceptable for important locals.
- [BCS0203] Prefix internal/private functions with underscore: `_validate_input()` to signal internal use only.
- [BCS0203] Avoid lowercase single-letter names (reserved for shell) and all-caps shell variables like `PATH`, `HOME`, `USER`.
## Constants and Environment Variables
- [BCS0204] Use `readonly --` for values that never change: script metadata, configuration paths, derived constants.
- [BCS0204] Use `declare -x` or `export` for variables needed by child processes: environment configuration, settings inherited by subshells.
- [BCS0204] Combine `readonly` and `export` for constants that must be available in subprocesses: `declare -rx BUILD_ENV='production'`.
- [BCS0204] Never export constants unnecessarily; only make readonly if child processes don't need the value.
## Readonly After Group Pattern
- [BCS0205] When declaring multiple readonly variables, initialize them first with values, then make them all readonly in a single statement: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0205] Group logically related variables together for readability: script metadata, color definitions, path constants, configuration defaults.
- [BCS0205] Exception: Script metadata (VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME) should use `declare -r` for immediate readonly declaration as of BCS v1.0.1.
- [BCS0205] Always use `--` separator in readonly statements to prevent option injection bugs.
- [BCS0205] For conditional initialization (like terminal colors), ensure all variables are defined before making the group readonly.
- [BCS0205] Make variables readonly as early as possible once values are final; for argument-parsed values, make readonly after parsing completes.
## Readonly Declaration
- [BCS0206] Use `readonly -a` for constant arrays and `readonly --` for constant strings to prevent accidental modification.
- [BCS0206] Always use `--` separator with readonly declarations: `readonly -- SCRIPT_PATH="$(realpath -- "$0")"`.
## Boolean Flags Pattern
- [BCS0207] Declare boolean flags as integers with explicit initialization: `declare -i DRY_RUN=0`, `declare -i VERBOSE=1`.
- [BCS0207] Test flags in conditionals using `((FLAG))` which returns true for non-zero, false for zero.
- [BCS0207] Name flags descriptively in ALL_CAPS: `DRY_RUN`, `INSTALL_BUILTIN`, `NON_INTERACTIVE`.
- [BCS0207] Avoid mixing boolean flags with integer counters; use separate variables for distinct purposes.
## Derived Variables Pattern
- [BCS0209] Derive variables from base values to maintain single source of truth: `BIN_DIR="$PREFIX/bin"`, `CONFIG_FILE="$CONFIG_DIR/config.conf"`.
- [BCS0209] Group derived variables with section comments explaining dependencies: "# Derived from PREFIX" or "# Derived paths".
- [BCS0209] When base variables change during execution (especially argument parsing), update all derived variables immediately using dedicated update functions.
- [BCS0209] Use environment fallbacks for XDG paths: `CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"`, then derive app-specific paths.
- [BCS0209] Document hardcoded values that don't derive: explain special cases like system-wide paths that must be fixed regardless of PREFIX.
- [BCS0209] Make derived variables readonly only after all parsing and derivation is complete to allow updates when base values change.
