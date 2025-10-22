# Variable Declarations & Constants - Rulets
## Type-Specific Declarations
- [BCS0201] Always use explicit type declarations to make variable intent clear: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0201] Declare integer variables with `declare -i count=0` to enable automatic arithmetic evaluation and type enforcement.
- [BCS0201] Use `declare --` with the `--` separator for string variables to prevent option injection when variable names might start with hyphens.
- [BCS0201] Declare indexed arrays with `declare -a files=()` for ordered lists; use quoted expansion `"${files[@]}"` to preserve spaces during iteration.
- [BCS0201] Declare associative arrays with `declare -A config=()` for key-value maps; Bash 4.0+ required.
- [BCS0201] Never assign scalars to array variables; use array syntax: `files=('item')` not `files='item'`.
## Variable Scoping
- [BCS0202] Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.
- [BCS0202] Use `local` for ALL function parameters and temporary variables: `local -- file="$1"` to prevent global leaks.
- [BCS0202] In recursive functions, always use `local` declarations; without them, each recursive call overwrites the same global variable causing failures.
## Naming Conventions
- [BCS0203] Use UPPER_CASE for constants and global variables: `readonly MAX_RETRIES=3`, `VERBOSE=1`.
- [BCS0203] Use lower_case with underscores for local variables: `local file_count=0`; CamelCase acceptable for important locals.
- [BCS0203] Prefix internal/private functions with underscore: `_validate_input()` to signal internal use only.
- [BCS0203] Never use lowercase single-letter variable names (reserved for shell) or all-caps shell built-in names like `PATH`, `HOME`, `USER`.
## Constants and Environment Variables
- [BCS0204] Use `readonly --` for values that never change: script metadata, configuration paths determined at startup.
- [BCS0204] Use `declare -x` or `export` for variables needed by child processes: `declare -x DATABASE_URL='...'`.
- [BCS0204] Combine `readonly` with `export` for constants that must be available in subprocesses: `declare -rx BUILD_ENV='production'`.
- [BCS0204] Never export constants unnecessarily (child processes don't need internal script constants); only use `readonly` for true script-internal constants.
## Readonly After Group Pattern
- [BCS0205] When declaring multiple readonly variables, initialize them first with values, then make them all readonly in a single statement: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0205] Group logically related variables together for readability: script metadata group, color definitions group, path constants group, configuration defaults group.
- [BCS0205] For conditional initialization (like terminal color detection), define all variables in both branches, then make readonly after the conditional: `readonly -- RED GREEN YELLOW CYAN NC`.
- [BCS0205] Initialize derived variables in dependency order before making readonly: base values first, then derived values, then group readonly statement.
- [BCS0205] For variables that can only be made readonly after argument parsing, make them readonly immediately after parsing completes: `readonly -- VERBOSE DRY_RUN`.
- [BCS0205,BCS0206] Never make variables readonly individually when they belong to a logical group; this improves maintainability and visual clarity.
## Readonly Declaration
- [BCS0206] Use `readonly` with type-specific flags when declaring constant arrays: `readonly -a REQUIRED=(pandoc git)`.
- [BCS0206] Always use `--` separator with readonly to prevent option injection: `readonly -- SCRIPT_PATH="$(realpath -- "$0")"`.
## Boolean Flags Pattern
- [BCS0207] Declare boolean flags as integers with explicit initialization: `declare -i DRY_RUN=0` for false, `declare -i VERBOSE=1` for true.
- [BCS0207] Test boolean flags in conditionals using `((FLAG))` arithmetic syntax: `((DRY_RUN)) && info 'Dry-run mode'`.
- [BCS0207] Name boolean flags descriptively in ALL_CAPS: `INSTALL_BUILTIN`, `NON_INTERACTIVE`, `SKIP_BUILD`.
- [BCS0207] Set boolean flags from command-line parsing with simple assignment: `--dry-run) DRY_RUN=1 ;;`.
## Derived Variables Pattern
- [BCS0209] Group derived variables together with clear section comments explaining their dependencies: `# Derived from PREFIX` or `# Derived paths`.
- [BCS0209] Always derive variables from base values rather than duplicating: `BIN_DIR="$PREFIX/bin"` not `BIN_DIR='/usr/local/bin'`.
- [BCS0209] When base variables change during argument parsing, create an update function to recalculate all derived variables: `update_derived_paths()`.
- [BCS0209] Use environment variable fallbacks with parameter expansion for flexible derivation: `CONFIG_BASE="${XDG_CONFIG_HOME:-$HOME/.config}"`.
- [BCS0209] Document hardcoded exceptions that don't derive from base values with explanatory comments: `# Hardcoded by design - system requirement`.
- [BCS0209] Make derived variables readonly only after all parsing and derivation is complete to allow updates when base values change.
- [BCS0209] Maintain consistent derivation patterns: if one path derives from `APP_NAME`, all related paths should derive from `APP_NAME`.
