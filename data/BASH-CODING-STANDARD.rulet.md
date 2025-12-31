# Bash Coding Standard - Rulets

**Highly concise, actionable coding rules for Bash 5.2+**

This is the rulet tier: extracted rules in 1-2 sentence format with BCS code references for quick reference and AI consumption.

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler."

**Critical:** Do not over-engineer scripts; remove unused functions and variables.

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

## Script Structure & Layout - Rulets
## Mandatory 13-Step Structure
- [BCS0101] Every Bash script must follow the exact 13-step layout: (1) shebang, (2) shellcheck directives, (3) description, (4) `set -euo pipefail`, (5) `shopt` settings, (6) script metadata, (7) global variables, (8) color definitions, (9) utility functions, (10) business logic functions, (11) `main()`, (12) script invocation, (13) `#fin` marker.
- [BCS0101] Place `set -euo pipefail` at line 4 (after shebang, shellcheck, and description comment) before any commands execute to enable strict error handling immediately.
- [BCS0101] Scripts over 100 lines must use a `main()` function as the single entry point for execution flow; smaller scripts may run code directly.
- [BCS0101] Always end scripts with the `#fin` or `#end` marker to visually confirm file completeness and prevent truncation errors.
## Shebang
- [BCS0102] Use one of three acceptable shebangs: `#!/bin/bash` (most portable Linux), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability via PATH search).
- [BCS0102] Place the shebang as the absolute first line (line 1) of every script with no leading whitespace or comments.
## Script Metadata
- [BCS0103] Declare standard metadata immediately after `shopt` settings using: `declare -r VERSION='1.0.0'`, `declare -r SCRIPT_PATH=$(realpath -- "$0")`, `declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Always use `realpath` (not `readlink`) to resolve `SCRIPT_PATH` to canonical absolute paths, catching missing scripts early; disable shellcheck SC2155 with explanatory comment: `#shellcheck disable=SC2155`.
- [BCS0103] Make metadata variables readonly at declaration using `declare -r` to prevent accidental modification throughout script execution.
- [BCS0103] Use `SCRIPT_DIR` for loading companion files and resources relative to script location, not `PWD` which reflects current working directory.
## Global Variables
- [BCS0101] Declare all global variables immediately after metadata (step 7) with explicit type declarations: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Group all global variable declarations in one location before any function definitions to make script state visible at a glance.
- [BCS0101] Defer `readonly` declarations until after argument parsing for variables that need modification during initialization; make them readonly before business logic executes.
## Color Definitions
- [BCS0101] Define color variables conditionally based on terminal detection: `if [[ -t 1 && -t 2 ]]; then readonly -- RED=$'\033[0;31m' ...; else readonly -- RED='' ...; fi`.
- [BCS0101] Make color variables readonly immediately after conditional assignment to prevent modification: `readonly -- RED GREEN YELLOW CYAN NC`.
- [BCS0101] Skip color definitions entirely if your script produces no colored terminal output.
## Standard shopt Settings
- [BCS0105] Always enable `shopt -s inherit_errexit shift_verbose extglob nullglob` in all scripts for proper error handling, argument safety, extended patterns, and safe glob expansion.
- [BCS0105] The `inherit_errexit` setting is critical: without it, `set -e` does not apply inside command substitutions `$(...)` or subshells `(...)`, causing silent failures.
- [BCS0105] Choose `nullglob` for scripts with file loops (unmatched globs expand to empty, loop skips) or `failglob` for strict scripts (unmatched globs cause errors).
- [BCS0105] Use `extglob` to enable advanced patterns: `!(*.txt)` excludes .txt files, `@(jpg|png)` matches alternatives, `+(pattern)` matches one or more.
## Function Organization (Bottom-Up)
- [BCS0107] Always organize functions bottom-up in 7 layers: (1) messaging functions, (2) documentation functions, (3) helper/utility functions, (4) validation functions, (5) business logic functions, (6) orchestration functions, (7) `main()` function.
- [BCS0107] Place messaging functions (`_msg()`, `info()`, `warn()`, `error()`, `die()`) first as lowest-level primitives used by everything; they must have zero dependencies.
- [BCS0107] Each function may only call functions defined above it (earlier in file), establishing clear dependency hierarchy flowing downward from primitives to composition.
- [BCS0107] Place `main()` function last before script invocation, as the highest-level orchestrator that calls all other layers.
- [BCS0107] Use section comments to visually separate function layers: `# ============================================================================` `# Layer 3: Helper/Utility Functions` `# ============================================================================`.
## Utility Functions
- [BCS0101] Implement standard messaging functions in step 9: `_msg()` (core), `vecho()` (verbose), `info()`, `warn()`, `success()`, `error()`, `die()`, `yn()` (yes/no prompt), `noarg()` (argument validation).
- [BCS0101] Place all utility functions before business logic functions since business logic depends on messaging, validation, and helper utilities.
- [BCS0101] Remove unused utility functions before production deployment to reduce script size, but keep them during development for flexibility.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be both executed and sourced, place all function definitions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` before any executable code.
- [BCS010201] Apply `set -euo pipefail` and `shopt` settings only in the executable section (after the early return check), never when sourced, to avoid modifying the caller's shell environment.
- [BCS010201] Use visual separator comment `# ----------------------------------------------------------------------------` to clearly mark the boundary between sourceable functions and executable code.
- [BCS010201] Guard metadata initialization with idempotent check: `if [[ ! -v SCRIPT_VERSION ]]; then declare -x SCRIPT_VERSION='1.0.0'; ...; fi` to allow safe re-sourcing.
- [BCS010201] Export functions with `declare -fx function_name` when they need to be available in subshells.
## FHS Compliance
- [BCS0104] Follow Filesystem Hierarchy Standard (FHS) for scripts that install system-wide: executables in `$PREFIX/bin`, data files in `$PREFIX/share/appname`, libraries in `$PREFIX/lib/appname`, config in `$PREFIX/etc/appname`.
- [BCS0104] Support customizable `PREFIX` via environment variable with default: `declare -- PREFIX="${PREFIX:-/usr/local}"` to enable user installs, system installs, and package manager integration.
- [BCS0104] Search multiple FHS locations when loading resources: script directory (development), `/usr/local/share/app` (local install), `/usr/share/app` (system install), `${XDG_DATA_HOME:-$HOME/.local/share}/app` (user install).
- [BCS0104] Use XDG Base Directory specification for user-specific files: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME` with fallbacks to `$HOME/.config`, `$HOME/.local/share`, etc.
- [BCS0104] Preserve existing user configuration files during upgrades: `[[ -f "$CONFIG_FILE" ]] || install config.example "$CONFIG_FILE"` instead of unconditional overwrites.
## File Extensions
- [BCS0106] Use no extension for executables installed to PATH (e.g., `myapp` not `myapp.sh`) for cleaner command-line interface.
- [BCS0106] Use `.sh` extension for library files meant to be sourced (not executed directly) and for executables not in PATH.
- [BCS0106] Make library files non-executable (`chmod 644`) to clearly indicate they should be sourced, not run.
## Script Invocation
- [BCS0101] Invoke `main()` function at step 12 with quoted argument array: `main "$@"` to preserve all arguments with proper spacing and special characters.
- [BCS0101] For small scripts without `main()`, write business logic directly at step 12, but still follow all other structural requirements.
## Anti-Patterns to Avoid
- [BCS010102] Never place business logic before utility functions; this creates forward references where functions call utilities that aren't defined yet.
- [BCS010102] Never declare variables after they're first used; with `set -u`, this causes "unbound variable" errors.
- [BCS010102] Never make variables readonly before argument parsing if they need modification during initialization; use progressive readonly after parsing.
- [BCS010102] Never skip `set -euo pipefail` or place it after commands execute; errors in early commands will be silently ignored.
- [BCS010102] Never use `$0` directly without `realpath` for SCRIPT_PATH; relative paths and symlinks will break resource loading.
## Edge Cases
- [BCS010103] Tiny scripts under 100 lines may skip `main()` function and run code directly, but must still follow all other 13 steps.
- [BCS010103] Library files meant only for sourcing should skip `set -e` (would modify caller), `main()`, and script invocation; just define functions and end with `#fin`.
- [BCS010103] Scripts with cleanup requirements should define cleanup function in step 9 (utilities), then set trap after function definition: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS010103] Scripts sourcing external configuration should source config files between step 7 (globals) and step 9 (utilities), then make variables readonly after sourcing.
- [BCS010103] Handle edge case of script in root directory: `SCRIPT_DIR=${SCRIPT_PATH%/*}; [[ -z "$SCRIPT_DIR" ]] && SCRIPT_DIR='/'` since parameter expansion returns empty string for `/script`.
## Complete Example References
- [BCS010101] See BCS010101 for a comprehensive 462-line installation script demonstrating all 13 steps with dry-run mode, force mode, systemd integration, and full argument parsing.
- [BCS010102] See BCS010102 for eight common anti-patterns with side-by-side wrong/correct comparisons showing proper fixes.
- [BCS010103] See BCS010103 for five edge cases covering tiny scripts, sourced libraries, external config, platform detection, and cleanup traps.


---


**Rule: BCS0200**

## Variable Declarations & Constants - Rulets
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


---


**Rule: BCS0300**

## Quoting & String Literals - Rulets
## General Principles
- [BCS0400] Use single quotes (`'...'`) for static string literals and double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.
- [BCS0400] Single quotes signal "literal text" while double quotes signal "shell processing needed" - this semantic distinction clarifies intent for both developers and AI assistants.
## Static Strings and Constants
- [BCS0401] Always use single quotes for string literals that contain no variables: `info 'Checking prerequisites...'` not `info "Checking prerequisites..."`.
- [BCS0401] Single quotes prevent accidental variable expansion, command substitution, and eliminate the need to escape special characters like `$`, `` ` ``, `\`, `!`.
- [BCS0401] Use double quotes only when the string requires variable expansion or command substitution: `info "Processing $count files"`.
- [BCS0401] For empty strings, prefer single quotes for consistency: `var=''` not `var=""`.
## One-Word Literals
- [BCS0402] Literal one-word values containing only safe characters (alphanumeric, underscore, hyphen, dot, slash) may be left unquoted in variable assignments and conditionals, but quoting is more defensive and recommended: `ORGANIZATION=Okusi` is acceptable but `ORGANIZATION='Okusi'` is better.
- [BCS0402] Values with spaces, wildcards, special characters (`@`, `*`, `?`, etc.), or starting with hyphens must always be quoted: `EMAIL='user@domain.com'`, `PATTERN='*.txt'`, `MESSAGE='Hello world'`.
- [BCS0402] When in doubt, quote everything - the reduction in visual noise from omitting quotes on one-word literals is not worth the mental overhead or risk of bugs when values change.
## Strings with Variables
- [BCS0403] Use double quotes when strings contain variables that need expansion: `error "'$compiler' not found"`, `info "Installing to $PREFIX/bin"`.
- [BCS0403] Do not use braces around variables unless required for parameter expansion, array access, or adjacent variables: `echo "$PREFIX/bin"` not `echo "${PREFIX}/bin"`.
- [BCS0403] RECOMMENDED: Quote variable portions separately from literal path components for clarity: `"$PREFIX"/bin` and `"$SCRIPT_DIR"/data/"$filename"` rather than `"$PREFIX/bin"` and `"$SCRIPT_DIR/data/$filename"`.
- [BCS0403] Use `${var@Q}` for safe display of user-provided values in error messages: `error "File not found: ${file@Q}"` properly quotes values with special characters.
## Mixed Quoting
- [BCS0404] When a string contains both static text and variables, use double quotes with nested single quotes for literal protection: `die 2 "Unknown option '$1'"`, `warn "Cannot access '$file_path'"`.
## Command Substitution
- [BCS0405] Always use double quotes when including command substitution: `echo "Current time: $(date +%T)"`, `info "Found $(wc -l "$file") lines"`.
## Variables in Conditionals
- [BCS0406] Always quote variables in test expressions to prevent word splitting and glob expansion, even when the variable is guaranteed to contain a safe value: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS0406] Quote variables in all conditional contexts: file tests `[[ -d "$path" ]]`, string comparisons `[[ "$name" == "$expected" ]]`, integer comparisons `[[ "$count" -eq 0 ]]`, logical operators `[[ -f "$file" && -r "$file" ]]`.
- [BCS0406] Static comparison values follow normal quoting rules - use single quotes for multi-word literals or special characters `[[ "$message" == 'file not found' ]]`, but one-word literals can be unquoted `[[ "$action" == start ]]`.
- [BCS0406] For glob pattern matching, leave the right-side pattern unquoted: `[[ "$filename" == *.txt ]]`; for literal matching, quote it: `[[ "$filename" == '*.txt' ]]`.
- [BCS0406] For regex matching with `=~`, keep the pattern unquoted or in an unquoted variable: `[[ "$email" =~ ^[a-z]+@[a-z]+$ ]]` or `pattern='^test'; [[ "$input" =~ $pattern ]]`.
## Array Expansions
- [BCS0407] Always quote array expansions to preserve element boundaries: `"${array[@]}"` for separate elements, `"${array[*]}"` for a single concatenated string.
- [BCS0407] Use `"${array[@]}"` for iteration, function arguments, and command arguments: `for item in "${array[@]}"`, `my_function "${array[@]}"`.
- [BCS0407] Use `"${array[*]}"` for display, logging, or creating comma-separated values with custom IFS: `echo "Items: ${array[*]}"`, `IFS=','; csv="${array[*]}"`.
- [BCS0407] Unquoted array expansions undergo word splitting and glob expansion, breaking elements with spaces and losing empty elements - never use unquoted: `${array[@]}`.
## Here Documents
- [BCS0408] Use single-quoted delimiter for literal here-docs with no expansion: `cat <<'EOF'` preserves `$VAR` and `$(command)` as literal text.
- [BCS0408] Use unquoted delimiter (or double-quoted, which is equivalent) for here-docs requiring variable/command expansion: `cat <<EOF` expands `$VAR` and `$(command)`.
## Echo and Printf
- [BCS0409] Use single quotes for static echo/printf strings: `echo 'Installation complete'`, `printf '%s\n' 'Processing files'`.
- [BCS0409] Use double quotes for echo/printf with variables: `echo "$SCRIPT_NAME $VERSION"`, `printf 'Found %d files in %s\n' "$count" "$dir"`.
## Anti-Patterns
- [BCS0411] Never use double quotes for static strings with no variables: `info "Checking prerequisites..."` is wrong, use `info 'Checking prerequisites...'`.
- [BCS0411] Never leave variables unquoted in conditionals, assignments, or commands: `[[ -f $file ]]`, `rm $temp_file`, `for item in ${items[@]}` are all wrong.
- [BCS0411] Never use braces when not required: `echo "${HOME}/bin"` should be `echo "$HOME/bin"`; use braces only for parameter expansion `"${var##pattern}"`, arrays `"${array[@]}"`, defaults `"${var:-default}"`, or adjacent variables `"${var1}${var2}"`.
- [BCS0411] Never mix quote styles inconsistently within similar contexts: pick single quotes for all static strings and stick with it.
- [BCS0411] Never use unquoted variables with glob characters or special characters: `pattern='*.txt'; echo $pattern` expands to all `.txt` files.
## Helper Functions
- [BCS0412] Trim whitespace from strings: `trim() { local v="$*"; v="${v#"${v%%[![:blank:]]*}"}"; echo -n "${v%"${v##*[![:blank:]]}"}";}`.
- [BCS0413] Display declared variables without type decorations: `decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }`.
- [BCS0414] Pluralization helper for output messages: `s() { (( ${1:-1} == 1 )) || echo -n 's'; }` prints 's' unless count is 1.


---


**Rule: BCS0400**

## Functions & Libraries - Rulets

## Function Definition Pattern

- [BCS0401] Use single-line format for simple functions: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0401] Multi-line functions must declare local variables with type at function start: `local -i exitcode=0` for integers, `local -- variable` for strings.
- [BCS0401] Always return explicit exit codes: `return "$exitcode"` or `return 0`.

## Function Naming

- [BCS0402] Use lowercase with underscores for function names: `process_log_file()` not `ProcessLogFile()`.
- [BCS0402] Prefix private/internal functions with underscore: `_validate_input()`.
- [BCS0402] Never override built-in commands; use alternative names: `change_dir()` not `cd()`.
- [BCS0402] Avoid dashes in function names: `my_function()` not `my-function()`.

## Main Function

- [BCS0403] Always include `main()` function for scripts exceeding ~200 lines.
- [BCS0403] Place `main "$@"` at script bottom, just before `#fin` marker.
- [BCS0403] Parse all arguments inside `main()`, not at global scope.
- [BCS0403] Declare option variables as local in main: `local -i verbose=0; local -- output_file=''`
- [BCS0403] Make parsed options readonly after parsing: `readonly -- verbose dry_run output_file`
- [BCS0403] Use `[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"` pattern for testable scripts.
- [BCS0403] Main orchestrates; heavy lifting belongs in helper functions called by main.
- [BCS0403] Track errors using counters: `local -i errors=0` then `((errors+=1))` on failures.
- [BCS0403] Use `trap cleanup EXIT` at main start for guaranteed cleanup.
- [BCS0403] Never define functions after `main "$@"` call; never parse arguments in global scope.
- [BCS0403] Never call main without `"$@"`: use `main "$@"` not `main`.

## Function Export

- [BCS0404] Export functions for subshell access with `declare -fx`: `grep() { /usr/bin/grep "$@"; }; declare -fx grep`
- [BCS0404] Group related function exports: `declare -fx func1 func2 func3`

## Production Optimization

- [BCS0405] Remove unused utility functions from mature production scripts.
- [BCS0405] Remove unused global variables and messaging functions not called by script.
- [BCS0405] Keep only functions and variables the script actually needs; a simple script may only need `error()` and `die()`.

## Dual-Purpose Scripts

- [BCS0406] Define all functions BEFORE `set -euo pipefail` in dual-purpose scripts.
- [BCS0406] Use source-mode exit after function definitions: `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0`
- [BCS0406] Place `set -euo pipefail` AFTER the source check, never before.
- [BCS0406] Export all library functions: `my_func() { :; }; declare -fx my_func`
- [BCS0406] Use idempotent initialization to prevent double-loading: `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION='1.0.0'`

## Library Patterns

- [BCS0407] Pure libraries should reject execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || { echo "Must be sourced" >&2; exit 1; }`
- [BCS0407] Declare library version: `declare -rx LIB_VALIDATION_VERSION='1.0.0'`
- [BCS0407] Use namespace prefixes for all functions: `myapp_init()`, `myapp_cleanup()`, `myapp_process()`
- [BCS0407] Libraries should only define functions on source; explicit init call for side effects: `source lib.sh; lib_init`
- [BCS0407] Source libraries with existence check: `[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing: $lib_path"`

## Dependency Management

- [BCS0408] Check dependencies with `command -v`, never `which`: `command -v curl >/dev/null || die 1 'curl required'`
- [BCS0408] Collect missing dependencies for helpful error messages: `local -a missing=(); for cmd in curl jq; do command -v "$cmd" >/dev/null || missing+=("$cmd"); done`
- [BCS0408] Check Bash version when using modern features: `((BASH_VERSINFO[0] >= 5)) || die 1 "Requires Bash 5+"`
- [BCS0408] Use availability flags for optional features: `declare -i HAS_JQ=0; command -v jq >/dev/null && HAS_JQ=1`
- [BCS0408] Lazy-load expensive resources only when needed.

## Function Organization

- [BCS0400] Organize functions bottom-up: messaging first, then helpers, then business logic, with `main()` last.
- [BCS0400] Each function should safely call only previously-defined functions above it.


---


**Rule: BCS0500**

## Control Flow - Rulets
## Conditionals
- [BCS0701] Always use `[[ ]]` for string and file tests, `(())` for arithmetic comparisons: `[[ -f "$file" ]]` for files, `((count > 0))` for numbers.
- [BCS0701] Never use `[ ]` for conditionals; use `[[ ]]` which handles unquoted variables safely, supports pattern matching with `==` and `=~`, and allows `&&`/`||` operators inside brackets.
- [BCS0701] Use short-circuit evaluation for concise conditionals: `[[ -f "$file" ]] && source "$file"` executes second command only if first succeeds, `((VERBOSE)) || return 0` executes second only if first fails.
- [BCS0701] Quote variables in `[[ ]]` conditionals for clarity even though not strictly required: `[[ "$var" == "value" ]]` not `[[ $var == "value" ]]`.
## Case Statements
- [BCS0702] Use case statements for multi-way branching based on pattern matching of a single variable; they're more readable and efficient than long if/elif chains.
- [BCS0702] The case expression doesn't require quoting since word splitting doesn't apply: `case ${1:-} in` is correct; quotes are harmless but unnecessary: `case "${1:-}" in`.
- [BCS0702] Never quote literal patterns in case statements: `*.txt)` not `"*.txt")` - quoting disables pattern matching.
- [BCS0702] Use compact format (all on one line with aligned `;;`) for simple single-action cases like argument parsing: `-v|--verbose) VERBOSE=1 ;;`
- [BCS0702] Use expanded format (action on next line, `;;` on separate line) for multi-line logic or complex operations requiring comments.
- [BCS0702] Always include a default `*)` case to handle unexpected values explicitly: `*) die 22 "Invalid option: $1" ;;`
- [BCS0702] Use alternation with `|` for multiple patterns: `-h|--help|help)` matches any of the three forms.
- [BCS0702] Enable extglob for advanced patterns: `shopt -s extglob` allows `@(pattern)` (exactly one), `+(pattern)` (one or more), `*(pattern)` (zero or more), `?(pattern)` (zero or one), `!(pattern)` (anything except).
- [BCS0702] Align actions at consistent column (14-18 characters) for visual clarity in compact format.
- [BCS0702] Never use case for testing multiple variables or complex conditional logic; use if/elif with `[[ ]]` instead.
## Loops
- [BCS0703] Use for loops for arrays, globs, and known ranges; while loops for reading input, argument parsing, and condition-based iteration; avoid until loops (prefer while with opposite condition).
- [BCS0703] Always quote array expansion in for loops: `for file in "${files[@]}"` preserves element boundaries including spaces.
- [BCS0703] Use C-style for loops for numeric iteration: `for ((i=0; i<10; i+=1))` with explicit increment `i+=1` never `i++`.
- [BCS0703] Never parse `ls` output; use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
- [BCS0703] Use `while IFS= read -r line; do` for line-by-line file processing; always include `IFS=` and `-r` flags.
- [BCS0703] Use `while (($#))` not `while (($# > 0))` for argument parsing loops; non-zero values are truthy in arithmetic context, making the comparison redundant.
- [BCS0703] Use `while ((1))` for infinite loops (fastest, recommended), `while :` for POSIX compatibility, never `while true` (15-22% slower due to command execution overhead).
- [BCS0703] Use `break` for early loop exit and `continue` for conditional skipping; specify break level for nested loops: `break 2` exits two levels.
- [BCS0703] Enable `nullglob` to handle empty glob matches safely: `shopt -s nullglob` makes `for file in *.txt` execute zero iterations if no matches.
- [BCS0703] Never iterate over unquoted strings with spaces; always use arrays: `files=('file 1.txt' 'file 2.txt')` then `for file in "${files[@]}"`.
- [BCS0703] Declare local variables BEFORE loops, not inside: `local -- target; for link in "$dir"/*; do target=$(readlink "$link"); done` - local inside a loop is wasteful and misleading since it doesn't create per-iteration scope.
## Pipes to While Loops
- [BCS0704] Never pipe commands to while loops; pipes create subshells where variable assignments don't persist outside the loop, causing silent failures.
- [BCS0704] Always use process substitution instead of pipes: `while read -r line; do ((count+=1)); done < <(command)` keeps loop in current shell so variables persist.
- [BCS0704] Use `readarray -t array < <(command)` when collecting lines into an array; it's cleaner and faster than manual while loop appending.
- [BCS0704] Use here-string `while read -r line; done <<< "$var"` when input is already in a variable.
- [BCS0704] For null-delimited input (filenames with newlines), use `while IFS= read -r -d '' file; done < <(find . -print0)` or `readarray -d '' -t files < <(find . -print0)`.
- [BCS0704] Remember pipe creates process tree: parent shell → subshell (while loop with modified variables) → subshell exits → changes discarded; process substitution avoids this.
## Arithmetic Operations
- [BCS0705] Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity: `declare -i count=0 total=0`.
- [BCS0705] Use `i+=1` for ALL increments (requires prior `declare -i` or `local -i`); NEVER use `((i++))`, `((++i))`, or `i++` - only `i+=1` is acceptable.
- [BCS0705] Use `(())` for arithmetic operations without `$` on variables: `((result = x * y + z))` not `((result = $x * $y + $z))`.
- [BCS0705] Use `$(())` for arithmetic in assignments or command arguments: `result=$((i * 2 + 5))` or `echo "$((count / total))".`
- [BCS0705] Always use `(())` for arithmetic conditionals, never `[[ ]]` with `-gt`/`-lt`: `((count > 10))` not `[[ "$count" -gt 10 ]]`.
- [BCS0705] Remember integer division truncates toward zero: `((result = 10 / 3))` gives 3 not 3.33; use `bc` or `awk` for floating point.
- [BCS0705] Never use `expr` command for arithmetic; it's slow, external, and error-prone: use `$(())` or `(())` instead.
- [BCS0705] Use arithmetic truthiness directly: `((count))` not `((count > 0))`, `((VERBOSE)) && echo 'Verbose'` not `((VERBOSE == 1))` - non-zero is truthy, making explicit comparisons redundant.


---


**Rule: BCS0600**

## Error Handling - Rulets

## Exit on Error Configuration

- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` to make command substitutions inherit `set -e` behavior.
- [BCS0601] Allow specific commands to fail using `command || true` pattern; never disable `set -e` globally.
- [BCS0601] When capturing output from commands that may fail, use `if result=$(command); then` or `result=$(command) || die 1 "Failed"`.
- [BCS0601] With `set -e`, checking `$?` after assignment like `result=$(failing_command)` is unreachable—the script already exited.

## Exit Codes

- [BCS0602] Use standard exit codes: `0` (success), `1` (general error), `2` (misuse/usage error), `22` (invalid argument/EINVAL), `5` (permission denied).
- [BCS0602] Implement `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error exits.
- [BCS0602] Define exit codes as readonly constants for readability: `readonly -i ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3`.
- [BCS0602] Avoid exit codes 126-255 for custom errors; these conflict with shell-reserved codes and signal numbers (128+n).

## Trap Handling

- [BCS0603] Install traps early, before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS0603] Always disable traps inside cleanup function to prevent recursion: `trap - SIGINT SIGTERM EXIT`.
- [BCS0603] Preserve exit code by capturing `$?` in trap command: `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`.
- [BCS0603] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT`.
- [BCS0603] Create cleanup function for non-trivial cleanup; avoid complex inline trap commands.
- [BCS0603] Handle cleanup failures gracefully: `rm -rf "$temp_dir" || warn "Failed to remove temp directory"`.

## Return Value Checking

- [BCS0604] Always check return values of critical operations; `set -e` doesn't catch all failures (pipelines, conditionals, command substitution).
- [BCS0604] Provide context in error messages: `mv "$file" "$dest" || die 1 "Failed to move $file to $dest"` not just `"Move failed"`.
- [BCS0604] Check command substitution results explicitly: `output=$(command) || die 1 "Command failed"`.
- [BCS0604] Use `PIPESTATUS` array to check individual pipeline command results: `((PIPESTATUS[0] != 0)) && die 1 "First command failed"`.
- [BCS0604] Capture exit code immediately after command if needed: `command; exit_code=$?` before any other operations.
- [BCS0604] Clean up on failure using command groups: `cp "$src" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }`.

## Error Suppression

- [BCS0605] Only suppress errors when failure is expected, non-critical, and safe to ignore; always document WHY with a comment.
- [BCS0605] Use `|| true` to ignore return code while keeping stderr visible; use `2>/dev/null` to suppress messages while checking return code.
- [BCS0605] Use `2>/dev/null || true` only when both error messages and return code are irrelevant.
- [BCS0605] Safe to suppress: optional tool checks (`command -v optional_tool >/dev/null 2>&1`), cleanup operations (`rm -f /tmp/myapp_* 2>/dev/null || true`), idempotent operations (`install -d "$dir" 2>/dev/null || true`).
- [BCS0605] Never suppress: critical file operations, data processing, security operations, required dependency checks.
- [BCS0605] Verify system state after suppressed operations when possible: `install -d "$dir" 2>/dev/null || true; [[ -d "$dir" ]] || die 1 "Failed"`.

## Conditional Declarations with Exit Code Handling

- [BCS0606] Append `|| :` to `((condition)) && action` patterns under `set -e` to prevent false conditions from exiting: `((verbose)) && echo "Debug" || :`.
- [BCS0606] Prefer colon `:` over `true` for no-op fallback (traditional shell idiom, single character, no PATH lookup).
- [BCS0606] Use for optional variable declarations: `((complete)) && declare -g EXTRA_VAR=value || :`.
- [BCS0606] Use for feature-gated actions: `((DRY_RUN)) && echo "Would execute: $cmd" || :`.
- [BCS0606] Never use `|| :` for critical operations that must succeed—use explicit `if` statement with error handling instead.
- [BCS0606] For complex conditional logic, prefer explicit `if ((condition)); then action; fi` over `((condition)) && action || :`.


---


**Rule: BCS0700**

## Input/Output & Messaging - Rulets
## Color Support
- [BCS0901] Declare global flags for messaging control: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0901] Only initialize color variables when both stdout and stderr are terminals: `if [[ -t 1 && -t 2 ]]; then` set colors, `else` set empty strings.
- [BCS0901] Use ANSI escape sequences in `$'...'` format for colors: `RED=$'\033[0;31m'`, `GREEN=$'\033[0;32m'`, `YELLOW=$'\033[0;33m'`, `CYAN=$'\033[0;36m'`, `NC=$'\033[0m'`.
- [BCS0901] Always make color variables readonly after initialization: `readonly -- RED GREEN YELLOW CYAN NC`.
## Stream Handling
- [BCS0902] All error messages must go to stderr, not stdout.
- [BCS0902] Place `>&2` at the beginning of commands for clarity: `>&2 echo "error message"` not `echo "error message" >&2`.
## Core Messaging Functions
- [BCS0903] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine formatting and prefix based on the calling function name.
- [BCS0903] Use `_msg()` as the single source of message formatting logic; all public messaging functions (`info`, `warn`, `error`, `success`, `debug`) should call `_msg()` to avoid duplication.
- [BCS0903] Conditional messaging functions (`vecho`, `info`, `warn`, `success`) must check the VERBOSE flag and return early if not enabled: `((VERBOSE)) || return 0`.
- [BCS0903] Debug output function must check DEBUG flag: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS0903] Error messages must always display regardless of verbosity: `error() { >&2 _msg "$@"; }`.
- [BCS0903] The `die()` function must accept exit code as first parameter, then optional message arguments: `die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }`.
- [BCS0903] Use symbol prefixes in messages for visual scanning: `✓` (success), `▲` (warning), `◉` (info), `✗` (error), `DEBUG:` (debug).
- [BCS0903] Send all operational messages to stderr using `>&2`: `success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }`.
- [BCS0903] The `yn()` prompt function must respect the PROMPT flag for non-interactive mode: `((PROMPT)) || return 0`.
- [BCS0903] Format `_msg()` case statement to detect calling function: `case "${FUNCNAME[1]}" in success) prefix+=" ${GREEN}✓${NC}" ;; ... esac`.
## Usage Documentation
- [BCS0904] Use here-documents for help text with `cat <<EOT` containing usage, options, and examples.
- [BCS0904] Include script name and version in help output: `$SCRIPT_NAME $VERSION - Brief description`.
- [BCS0904] Document all options with both short and long forms: `-v|--verbose`, `-h|--help`.
- [BCS0904] Provide concrete examples section showing common use cases.
## Echo vs Messaging Functions
- [BCS0905] Use messaging functions (`info`, `warn`, `error`, `success`) for operational status updates that should go to stderr and respect verbosity settings.
- [BCS0905] Use plain `echo` for data output to stdout, help text, structured reports, and output that must always display regardless of verbosity.
- [BCS0905] Never use messaging functions for data output that will be captured or piped: use `echo` to stdout instead.
- [BCS0905] Use `echo` with here-documents for multi-line formatted output like help text or reports, not multiple messaging function calls.
- [BCS0905] Functions that return data must use `echo` to stdout: `get_value() { echo "$result"; }` not `info "$result"`.
- [BCS0905] Separate operational messages (stderr via messaging functions) from data output (stdout via echo) to enable proper script composition and piping.
- [BCS0905] Version and help output should use `echo` (always display), never messaging functions that respect VERBOSE.
## Color Management Library
- [BCS0906] For scripts requiring sophisticated color management beyond inline declarations, use a dedicated color management library with basic (5 variables) and complete (12 variables) tiers.
- [BCS0906] Implement `color_set()` function supporting options: `basic` (default 5 colors), `complete` (12 colors), `auto` (terminal detection), `always` (force on), `never` (force off), `verbose` (show declarations), `flags` (set BCS globals).
- [BCS0906] Basic tier provides: `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN`; complete tier adds: `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE`.
- [BCS0906] Auto-detection must test both stdout AND stderr are terminals: `[[ -t 1 && -t 2 ]] && color=1 || color=0`.
- [BCS0906] The `flags` option should initialize BCS messaging control variables: `VERBOSE=${VERBOSE:-1}`, and with complete tier: `DEBUG=0 DRY_RUN=1 PROMPT=1`.
- [BCS0906] Implement dual-purpose pattern so library can be sourced (`source color-set.sh && color_set complete`) or executed for demonstration (`./color-set.sh complete verbose`).
- [BCS0906] Export the `color_set` function for library usage: `declare -fx color_set`.


---


**Rule: BCS0800**

## Command-Line Arguments - Rulets
## Standard Parsing Pattern
- [BCS1001] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing - arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`.
- [BCS1001] Support both short and long options in case patterns: `-v|--verbose)` for user flexibility.
- [BCS1001] Call `noarg "$@"` before shifting when an option requires an argument to validate the argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`.
- [BCS1001] Place mandatory `shift` at end of loop after `esac` to advance to next argument - without this, infinite loop results.
- [BCS1001] Use `case $1 in` instead of if/elif chains for cleaner, more scannable option handling.
- [BCS1001] Implement `noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }` to validate option arguments exist before capturing them.
## Options and Arguments
- [BCS1001] For options with arguments, use pattern: `noarg "$@"; shift; variable=$1 ;;` - first shift moves to value, second shift (at loop end) moves past it.
- [BCS1001] For boolean flags, just set variables without shifting: `-v|--verbose) VERBOSE+=1 ;;` - shift happens at loop end.
- [BCS1001] For options that exit immediately, use `exit 0` and no shift needed: `-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;`.
- [BCS1001] Use `+=1` for stackable options to allow `-vvv` to set `VERBOSE=3`.
- [BCS1001] Catch invalid options with `-*) die 22 "Invalid option '$1'" ;;` before positional argument case.
- [BCS1001] Collect positional arguments in default case: `*) files+=("$1") ;;`.
## Short Option Bundling
- [BCS1005] Support short option bundling with pattern `-[ovnVh]*)` that explicitly lists valid short options - prevents incorrect disaggregation of unknown options.
- [BCS1005] Use pure bash method for 68% performance improvement (318 iter/sec vs 190 iter/sec) and no external dependencies: `opt=${1:1}; new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`.
- [BCS1005] Alternative grep method (current standard): `set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"` requires `#shellcheck disable=SC2046`.
- [BCS1005] Alternative fold method: `set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"` is 3% faster than grep but still requires external command.
- [BCS1005] Place bundling case before `-*)` invalid option handler and after all explicit option cases.
- [BCS1005] Options requiring arguments cannot be in middle of bundle: `-vno output.txt` works (expands to `-v -n -o output.txt`), but `-von output.txt` fails (`-o` captures "n" as argument).
## Version Output
- [BCS1002] Format version output as `$SCRIPT_NAME $VERSION` without the word "version" between them: `echo "$SCRIPT_NAME $VERSION"; exit 0` produces "myscript 1.2.3".
## Validation
- [BCS1003] Validate required arguments after parsing loop, before making variables readonly: `((${#files[@]} > 0)) || die 2 'No input files specified'`.
- [BCS1003] Validate option values and detect conflicts: `[[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"`.
## Parsing Location
- [BCS1004] Place argument parsing inside `main()` function for better testability, cleaner scoping, and easier mocking - not at top level.
- [BCS1004] Make variables readonly after parsing completes: `readonly -- VERBOSE DRY_RUN output_file` prevents accidental modification.
- [BCS1004] For very simple scripts (<200 lines) without `main()`, top-level parsing is acceptable.


---


**Rule: BCS0900**

## File Operations - Rulets
## Safe File Testing
- [BCS1101] Always quote variables in file tests with `[[ ]]`: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS1101] Use `[[ ]]` for file tests, never `[ ]` or `test` command.
- [BCS1101] Test file existence and readability before sourcing or processing: `[[ -f "$file" && -r "$file" ]] || die 3 "Cannot read: $file"`.
- [BCS1101] Use `-e` for any file type, `-f` for regular files only, `-d` for directories only.
- [BCS1101] Test file permissions before operations: `-r` for readable, `-w` for writable, `-x` for executable.
- [BCS1101] Use `-s` to test if file is non-empty (size > 0).
- [BCS1101] Compare file timestamps with `-nt` (newer than) or `-ot` (older than): `[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"`.
- [BCS1101] Check multiple conditions with `&&` or `||`: `[[ -f "$config" && -r "$config" ]] || die 3 "Config not found"`.
- [BCS1101] Always include filename in error messages for debugging: `die 2 "File not found: $file"`.
## Wildcard Expansion
- [BCS1102] Always use explicit path prefix with wildcards to prevent filenames starting with `-` being interpreted as flags: `rm ./*` not `rm *`.
- [BCS1102] Use explicit path in loops: `for file in ./*.txt; do` not `for file in *.txt; do`.
## Process Substitution
- [BCS1103] Use process substitution `<(command)` to provide command output as file-like input, eliminating temporary files and avoiding subshell issues.
- [BCS1103] Use input process substitution to compare command outputs: `diff <(sort file1) <(sort file2)`.
- [BCS1103] Use output process substitution `>(command)` to send data to commands as if writing to files: `tee >(wc -l) >(grep ERROR)`.
- [BCS1103] Avoid subshell variable scope issues in while loops with process substitution: `while read -r line; do ((count+=1)); done < <(cat file)` not `cat file | while read; do`.
- [BCS1103] Use `readarray` with process substitution to populate arrays from command output: `readarray -t users < <(getent passwd | cut -d: -f1)`.
- [BCS1103] Process files in parallel with tee and multiple output substitutions: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warn.txt) >/dev/null`.
- [BCS1103] Quote variables inside process substitution like normal: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS1103] Never use process substitution for simple command output; use command substitution instead: `result=$(command)` not `result=$(cat <(command))`.
- [BCS1103] Never use process substitution for single file input; use direct redirection: `grep pattern < file` not `grep pattern < <(cat file)`.
- [BCS1103] Use here-string for variable expansion, not process substitution: `command <<< "$var"` not `command < <(echo "$var")`.
- [BCS1103] Assign process substitution to file descriptors for delayed reading: `exec 3< <(long_command)` then `read -r line <&3`.
## Here Documents
- [BCS1104] Use here documents for multi-line strings: `cat <<'EOF' ... EOF` for literal text, `cat <<EOF ... EOF` for variable expansion.
- [BCS1104] Quote the delimiter with single quotes to prevent variable expansion: `cat <<'EOF'` preserves `$var` literally.
- [BCS1104] Omit quotes on delimiter to enable variable expansion: `cat <<EOF` expands `$USER` to actual value.
## Input Redirection Performance
- [BCS1105] Use `$(< file)` instead of `$(cat file)` in command substitution for 100x+ speedup by eliminating process fork overhead.
- [BCS1105] Use `command < file` instead of `cat file | command` for 3-4x speedup in single-file operations.
- [BCS1105] Replace `cat` with `<` redirection in loops to eliminate cumulative fork overhead: `for f in *.txt; do data=$(< "$f"); done`.
- [BCS1105] Never use `< file` alone without a consuming command; it opens stdin but produces no output.
- [BCS1105] Use `cat` when concatenating multiple files; `< file1 file2` is invalid syntax.
- [BCS1105] Use `cat` when needing options like `-n` (line numbers), `-A` (show all), `-b` (number non-blank), `-s` (squeeze blank).
- [BCS1105] Process creation overhead dominates I/O time even for large files, making `< file` consistently faster regardless of file size.


---


**Rule: BCS1000**

## Security Considerations - Rulets
## SUID/SGID Prohibition
- [BCS1201] Never use SUID (Set User ID) or SGID (Set Group ID) bits on Bash scripts under any circumstances; this is a critical security prohibition with no exceptions.
- [BCS1201] Use `sudo` with configured permissions instead of SUID bits: configure `/etc/sudoers` for specific commands and users.
- [BCS1201] SUID/SGID on shell scripts enables multiple attack vectors: IFS exploitation, PATH manipulation via interpreter resolution, library injection through `LD_PRELOAD`, shell expansion exploits, and TOCTOU race conditions.
- [BCS1201] The kernel executes the interpreter with SUID privileges before the script's security measures take effect, allowing attackers to inject malicious code during this window.
- [BCS1201] Find and audit all SUID/SGID scripts on your system: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.
- [BCS1201] Use compiled C wrapper programs with SUID if elevated privileges are absolutely required, never SUID shell scripts.
## PATH Security
- [BCS1202] Lock down PATH immediately at script start to prevent command substitution attacks: `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1202] Never include current directory (`.`), empty elements (`::` or leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1202] Validate inherited PATH if you cannot set it: reject paths containing `.`, empty elements, `/tmp`, or starting with `/home`.
- [BCS1202] Use absolute command paths for maximum security and defense in depth: `/bin/tar`, `/usr/bin/systemctl`, `/bin/rm`.
- [BCS1202] Place PATH setting in first few lines after `set -euo pipefail`, before any commands execute.
- [BCS1202] Verify critical commands are from expected locations: `[[ "$(command -v tar)" == "/bin/tar" ]] || die 1 "Security: tar not from expected location"`.
## IFS Safety
- [BCS1203] Set IFS to known-safe value at script start and make it readonly to prevent field splitting attacks: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1203] Use one-line IFS assignment for single commands to automatically restore IFS: `IFS=',' read -ra fields <<< "$csv_data"`.
- [BCS1203] Isolate IFS changes with subshells to prevent global side effects: `( IFS=','; read -ra fields <<< "$data"; process "${fields[@]}" )`.
- [BCS1203] Use `local -- IFS` in functions to scope IFS changes to function lifetime only.
- [BCS1203] Always save and restore IFS when modifying globally: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`.
- [BCS1203] Never trust inherited IFS values; attackers can manipulate IFS in the calling environment to exploit field splitting.
## Eval Command Prohibition
- [BCS1204] Never use `eval` with untrusted input; avoid `eval` entirely unless absolutely necessary, and seek alternatives first.
- [BCS1204] Use arrays for dynamic command construction instead of eval: `cmd=(find "$path" -name "*.txt"); "${cmd[@]}"`.
- [BCS1204] Use indirect expansion for variable references instead of eval: `echo "${!var_name}"` not `eval "echo \\$$var_name"`.
- [BCS1204] Use associative arrays for dynamic data instead of eval: `declare -A data; data[$key]=$value` not `eval "${key}=$value"`.
- [BCS1204] Use case statements or array lookups for function dispatch instead of eval: `case "$action" in start) start_func ;; esac`.
- [BCS1204] `eval` executes arbitrary code with full script privileges and performs expansion twice, enabling complete system compromise through code injection.
- [BCS1204] Use `printf -v "$var_name" '%s' "$value"` for safe variable assignment instead of `eval "$var_name='$value'"`.
## Input Sanitization
- [BCS1205] Always validate and sanitize user input to prevent injection attacks, directory traversal, and security vulnerabilities; fail early by rejecting invalid input before processing.
- [BCS1205] Sanitize filenames by removing directory traversal attempts (`..`, `/`) and allowing only safe characters: `[[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename"`.
- [BCS1205] Validate numeric input with regex before use: `[[ "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer"` and check ranges where applicable.
- [BCS1205] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$input"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 "Path outside allowed directory"`.
- [BCS1205] Use whitelist validation (define what IS allowed) over blacklist validation (define what isn't allowed); blacklists are always incomplete and bypassable.
- [BCS1205] Always use `--` separator in commands to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"` (prevents `--delete-all` attacks).
- [BCS1205] Never pass user input directly to shell commands or use eval with user input; use case statements to whitelist allowed commands.
- [BCS1205] Validate input type, format, range, and length; check for leading zeros in numbers, credentials in URLs, dangerous characters in filenames.


---


**Rule: BCS1100**

## Concurrency & Jobs - Rulets

## Background Job Management

- [BCS1101] Always track PIDs when starting background jobs: `command &; pid=$!` - never start jobs without capturing the PID for later management.
- [BCS1101] Use `kill -0 "$pid" 2>/dev/null` to check if a process is still running (signal 0 = existence check only).
- [BCS1101] Never use `$$` to reference background job PID; use `$!` which captures the last background process PID.
- [BCS1101] Implement cleanup traps for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` and kill all tracked PIDs in the cleanup function.
- [BCS1101] Store background PIDs in an array for batch management: `declare -a pids=(); command &; pids+=($!)`.
- [BCS1101] Reset trap handlers inside cleanup to prevent recursion: `trap - SIGINT SIGTERM EXIT`.

## Parallel Execution

- [BCS1102] Capture parallel output to temp files for ordered display: write each job's output to `"$temp_dir/$id.out"`, wait for all, then cat in original order.
- [BCS1102] Limit concurrent jobs by checking array size before starting new ones: `while ((${#pids[@]} >= max_jobs)); do wait -n; done`.
- [BCS1102] Never modify variables inside background subshells expecting parent visibility; use temp files to aggregate results: `echo 1 >> "$temp_dir/count"`.
- [BCS1102] Remove completed PIDs from tracking array by testing each with `kill -0 "$pid" 2>/dev/null`.

## Wait Patterns

- [BCS1103] Always capture wait exit code: `wait "$pid"; exit_code=$?` - never ignore the return value.
- [BCS1103] Track failures when waiting for multiple jobs: `for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done`.
- [BCS1103] Use `wait -n` (Bash 4.3+) to process jobs as they complete rather than waiting for all in sequence.
- [BCS1103] Store exit codes in associative array keyed by task identifier for detailed failure reporting: `declare -A exit_codes=()`.
- [BCS1103] Handle wait errors gracefully: `wait "$pid" || die 1 'Command failed'`.

## Timeout Handling

- [BCS1104] Always use `timeout` for network operations: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'`.
- [BCS1104] Check for timeout exit code 124 specifically: `if ((exit_code == 124)); then warn 'Command timed out'; fi`.
- [BCS1104] Use `--kill-after` for stubborn processes: `timeout --signal=TERM --kill-after=10 60 command`.
- [BCS1104] Know timeout exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=SIGKILL.
- [BCS1104] Use `read -t` for user input timeouts: `read -r -t 10 -p 'Enter value: ' value || value='default'`.
- [BCS1104] Set SSH connection timeouts explicitly: `ssh -o ConnectTimeout=10 -o BatchMode=yes "$server"`.

## Exponential Backoff

- [BCS1105] Use exponential backoff for retries: `delay=$((2 ** attempt))` - never use fixed delays that can flood services.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Set a maximum attempt limit and fail explicitly: `((attempt > max_attempts)) && die 1 'Max retries exceeded'`.
- [BCS1105] Validate success conditions beyond exit code when appropriate: check for non-empty output with `[[ -s "$temp_file" ]]`.

## General Concurrency Principles

- [BCS1100] Always clean up background jobs and handle partial failures gracefully.
- [BCS1101,BCS1103] Combine PID tracking with proper wait handling: track all PIDs at start, wait for each with error capture at end.
- [BCS1104,BCS1105] Combine timeouts with backoff for robust network operations: timeout prevents hangs, backoff handles transient failures.


---


**Rule: BCS1200**

## Code Style & Best Practices - Rulets
## Code Formatting
- [BCS1301] Use 2 spaces for indentation (NOT tabs) and maintain consistent indentation throughout.
- [BCS1301] Keep lines under 100 characters when practical; long file paths and URLs can exceed this limit when necessary.
- [BCS1301] Use line continuation with `\` for long commands.
## Comments
- [BCS1302] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT (which the code already shows).
- [BCS1302] Document intentional deviations, non-obvious business rules, edge cases, and why specific approaches were chosen: `# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile integration`.
- [BCS1302] Avoid commenting simple variable assignments, obvious conditionals, standard patterns, or self-explanatory code.
- [BCS1302] Use standardized emoticons only: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error).
## Blank Lines
- [BCS1303] Use one blank line between functions to create visual separation.
- [BCS1303] Use one blank line between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1303] Place blank lines before and after multi-line conditional or loop blocks; avoid multiple consecutive blank lines (one is sufficient).
- [BCS1303] Never use blank lines between short, related statements.
## Section Comments
- [BCS1304] Use lightweight section comments (`# Description`) without dashes or box drawing to organize code into logical groups.
- [BCS1304] Keep section comments short (2-4 words): `# Default values`, `# Derived paths`, `# Core message function`.
- [BCS1304] Place section comment immediately before the group it describes, followed by a blank line after the group.
- [BCS1304] Reserve 80-dash separators for major script divisions only; use simple section comments for grouping related variables, functions, or logical blocks.
## Language Best Practices
- [BCS1305] Always use `$()` instead of backticks for command substitution: `var=$(command)` not ``var=`command` ``.
- [BCS1305] Prefer shell builtins over external commands for 10-100x performance improvement and better reliability: `$((x + y))` not `$(expr "$x" + "$y")`.
- [BCS1305] Use builtin alternatives: `${var##*/}` for basename, `${var%/*}` for dirname, `${var^^}` for uppercase, `${var,,}` for lowercase, `[[` instead of `[` or `test`.
- [BCS1305] Avoid external commands (`expr`, `basename`, `dirname`, `tr` for case conversion, `seq`) when builtins exist; builtins are guaranteed in bash and require no PATH dependency.
## Development Practices
- [BCS1306] ShellCheck compliance is compulsory for all scripts; use `#shellcheck disable=SCxxxx` only for documented exceptions with explanatory comments.
- [BCS1306] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1306] Use defensive programming: default critical variables with `: "${VERBOSE:=0}"`, validate inputs early with `[[ -n "$1" ]] || die 1 'Argument required'`, and guard against unset variables with `set -u`.
- [BCS1306] Minimize subshells, use built-in string operations over external commands, batch operations when possible, and use process substitution over temp files for performance.
- [BCS1306] Make functions testable with dependency injection, support verbose/debug modes, and return meaningful exit codes for testing support.
## Emoticons
- [BCS1307] Standard severity icons: `◉` (info), `⦿` (debug), `▲` (warn), `✗` (error), `✓` (success).
- [BCS1307] Extended icons: `⚠` (caution/important), `☢` (fatal/critical), `↻` (redo/retry/update), `◆` (checkpoint), `●` (in progress), `○` (pending), `◐` (partial).
- [BCS1307] Action icons: `▶` (start/execute), `■` (stop), `⏸` (pause), `⏹` (terminate), `⚙` (settings/config), `☰` (menu/list).
- [BCS1307] Directional icons: `→` (forward/next), `←` (back/previous), `↑` (up/upgrade), `↓` (down/downgrade), `⇄` (swap), `⇅` (sync), `⟳` (processing/loading), `⏱` (timer/duration).
#fin
