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

## Variable Expansion & Parameter Substitution - Rulets
## Default Form
- [BCS0302] Always use `"$var"` without braces as the default form for standalone variables: `"$HOME"`, `"$SCRIPT_DIR"`, `"$1"`.
- [BCS0302] Only use braces `"${var}"` when syntactically necessary; braces add visual noise and should make necessary cases stand out.
## Required Brace Usage
- [BCS0301,BCS0302] Use braces for parameter expansion operations: `"${var##*/}"` (remove prefix), `"${var%/*}"` (remove suffix), `"${var:-default}"` (default value), `"${var:0:5}"` (substring), `"${var//old/new}"` (substitution), `"${var,,}"` (case conversion).
- [BCS0302] Use braces for variable concatenation without separators: `"${var1}${var2}${var3}"` or `"${prefix}suffix"` when variable immediately followed by alphanumeric.
- [BCS0301,BCS0302] Use braces for array access: `"${array[index]}"`, `"${array[@]}"`, `"${#array[@]}"`.
- [BCS0301,BCS0302] Use braces for special parameter expansion: `"${@:2}"` (positional parameters from 2nd), `"${10}"` (parameters beyond $9), `"${!var}"` (indirect expansion).
## Path Concatenation
- [BCS0302] Use simple form for path concatenation with separators: `"$PREFIX"/bin` or `"$PREFIX/bin"`, never `"${PREFIX}"/bin`.
- [BCS0302] Mix quoted variables with unquoted literals/separators in assignments and commands: `"$path"/file.txt`, `"$HOME"/.config/"$APP"/settings`, `[[ -f "$dir"/subdir/file ]]`.
## String Interpolation
- [BCS0302] Use simple form in echo/info strings: `echo "Installing to $PREFIX/bin"`, `info "Found $count files"`, never `echo "Installing to ${PREFIX}/bin"`.
- [BCS0302] Use simple form in conditionals: `[[ -d "$path" ]]`, `[[ -f "$SCRIPT_DIR"/file ]]`, never `[[ -d "${path}" ]]`.
## Edge Cases
- [BCS0302] Use braces when next character is alphanumeric with no separator: `"${var}_suffix"` (prevents `$var_suffix` interpretation), `"${prefix}123"` (prevents `$prefix123` interpretation).
- [BCS0302] Omit braces when separator present: `"$var-suffix"` (dash), `"$var.suffix"` (dot), `"$var/path"` (slash).
## Key Principle
- [BCS0300,BCS0302] Default to `"$var"` for simplicity and readability; reserve `"${var}"` exclusively for cases where shell requires braces for correct parsing.


---


**Rule: BCS0400**

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


**Rule: BCS0500**

## Arrays - Rulets
## Array Declaration
- [BCS0501] Always declare indexed arrays explicitly with `declare -a array=()` to signal array type, prevent scalar assignment, and enable type safety.
- [BCS0501] Use `local -a` for array declarations inside functions to prevent global pollution and control scope.
- [BCS0501] Initialize arrays with elements using parentheses syntax: `declare -a colors=('red' 'green' 'blue')`.
## Array Expansion and Iteration
- [BCS0501] Always quote array expansion with `"${array[@]}"` to preserve element boundaries and handle spaces safely; never use unquoted `${array[@]}`.
- [BCS0501] Use `"${array[@]}"` for iteration where each element becomes a separate word; never use `"${array[*]}"` which creates a single string.
- [BCS0501] Iterate over array values directly with `for item in "${array[@]}"` rather than iterating over indices with `"${!array[@]}"`.
## Array Modification
- [BCS0501] Append single elements with `array+=("value")` and multiple elements with `array+=("val1" "val2" "val3")`.
- [BCS0501] Get array length with `${#array[@]}`; check for empty arrays with `((${#array[@]} == 0))` or `((${#array[@]})) || default_action`.
- [BCS0501] Delete array elements with `unset 'array[i]'` (quoted to prevent glob expansion); clear entire array with `array=()`.
- [BCS0501] Access last element with `${array[-1]}` (Bash 4.3+) and extract slices with `"${array[@]:start:length}"`.
## Reading Into Arrays
- [BCS0501] Use `readarray -t array < <(command)` to read command output into arrays; `-t` removes trailing newlines and `< <()` avoids subshells.
- [BCS0501] Split delimited strings with `IFS=',' read -ra fields <<< "$csv_line"` but prefer arrays over IFS manipulation for list handling.
- [BCS0501] Read files into arrays with `readarray -t lines < file.txt` where each line becomes one array element.
## Safe List Handling with Arrays
- [BCS0502] Always use arrays to store lists of files, arguments, or any elements that may contain spaces, special characters, or wildcards; never use space/newline-separated strings.
- [BCS0502] Arrays preserve element boundaries without word splitting or glob expansion when expanded with `"${array[@]}"`, unlike string-based lists which break on spaces.
- [BCS0502] Build command arguments in arrays and execute with `"${array[@]}"` to safely handle arguments containing spaces, quotes, or special characters.
## Safe Command Construction
- [BCS0502] Construct complex commands by building argument arrays and conditionally adding elements: `cmd_args+=('-flag')` if condition met, then execute with `"${cmd_args[@]}"`.
- [BCS0502] Never concatenate strings for command arguments (`cmd="arg1 $arg2"`); use arrays (`cmd_args=('arg1' "$arg2")`) to avoid word splitting and eval dangers.
- [BCS0502] For SSH, rsync, find, tar, or any command with dynamic arguments, build the full command in an array: `ssh_args+=('-i' "$keyfile")` then `ssh "${ssh_args[@]}"`.
## File List Processing
- [BCS0502] Collect glob results directly into arrays with `files=(*.txt)` using `nullglob` to handle no-matches safely, then iterate with `for file in "${files[@]}"`.
- [BCS0502] Gather files from commands with null-delimited output: `while IFS= read -r -d '' file; do array+=("$file"); done < <(find ... -print0)`.
- [BCS0502] Check if glob matched anything by testing array length: `((${#files[@]} > 0))` or `[[ ${#files[@]} -eq 0 ]]`.
## Function Argument Passing
- [BCS0502] Pass arrays to functions with `function_name "${array[@]}"` and receive with `local -a items=("$@")` to preserve all elements as separate arguments.
- [BCS0502] Return arrays from functions by printing elements with `printf '%s\n' "${array[@]}"` and capturing with `readarray -t result < <(function_name)`.
## Anti-Patterns to Avoid
- [BCS0501,BCS0502] Never iterate with unquoted `${array[@]}` or use `for item in "$array"` (without `[@]`) which only processes the first element.
- [BCS0501] Never assign scalars to array variables; use array syntax even for single elements: `files=('item')` not `files='item'`.
- [BCS0502] Never use `eval` with constructed commands; build commands in arrays and execute directly with `"${array[@]}"`.
- [BCS0502] Never parse `ls` output into strings (`files=$(ls *.txt)`); use globs directly into arrays (`files=(*.txt)`).
- [BCS0502] Never manipulate IFS for iteration over lists; use arrays which handle element boundaries naturally without IFS changes.
## Array Operators Summary
- [BCS0501] Key array operators: `declare -a arr=()` (create), `arr+=("val")` (append), `${#arr[@]}` (length), `"${arr[@]}"` (all elements), `"${arr[i]}"` (single element), `"${arr[-1]}"` (last element), `"${arr[@]:start:len}"` (slice), `unset 'arr[i]'` (delete element), `"${!arr[@]}"` (indices).
## Special Cases
- [BCS0502] Empty arrays iterate safely (zero iterations) and can be passed to functions (zero arguments received); no special handling needed.
- [BCS0502] Arrays safely preserve elements containing spaces, quotes, dollars, wildcards, and newlines when expanded with `"${array[@]}"`.
- [BCS0502] Merge multiple arrays with `combined=("${arr1[@]}" "${arr2[@]}" "${arr3[@]}")` to concatenate all elements into a new array.


---


**Rule: BCS0600**

## Functions - Rulets
## Function Definition Pattern
- [BCS0601] Use single-line functions for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0601] Use multi-line functions with local variables for complex operations, always declaring locals at the top of the function body.
- [BCS0601] Always return explicit exit codes from functions: `return "$exitcode"` not implicit returns.
## Function Naming
- [BCS0602] Always use lowercase_with_underscores for function names to match shell conventions and avoid conflicts with built-in commands.
- [BCS0602] Prefix private/internal functions with underscore: `_my_private_function()`, `_validate_input()`.
- [BCS0602] Never use CamelCase or UPPER_CASE for function names; avoid special characters like dashes.
- [BCS0602] Never override built-in commands unless absolutely necessary; if you must wrap built-ins, use a different name: `change_dir()` not `cd()`.
## Main Function
- [BCS0603] Always include a `main()` function for scripts longer than approximately 200 lines; place `main "$@"` at the bottom just before `#fin`.
- [BCS0603] Use `main()` as the single entry point to orchestrate script logic: parsing arguments, validating input, calling helper functions in the right order, and returning appropriate exit codes.
- [BCS0603] Parse command-line arguments inside `main()`, not in global scope; make parsed option variables readonly after validation.
- [BCS0603] Place `main()` function definition at the end of the script after all helper functions are defined; this ensures bottom-up function organization.
- [BCS0603] For testable scripts, use conditional invocation: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` to prevent execution when sourced.
- [BCS0603] Skip `main()` function only for trivial scripts (<200 lines) with no functions, linear flow, or simple wrappers.
## Function Organization
- [BCS0603,BCS0107] Organize functions bottom-up: messaging functions first (lowest level), then documentation/helpers, then validation, then business logic, then orchestration, with `main()` last (highest level).
- [BCS0603] Separate script into clear sections with comment dividers: messaging functions, documentation functions, helper functions, business logic functions, main function.
## Function Export
- [BCS0604] Export functions with `declare -fx` when they need to be available in subshells or when creating sourceable libraries.
- [BCS0604] Batch export related functions together: `declare -fx grep find` after defining wrapper functions.
## Production Optimization
- [BCS0605] Remove unused utility functions from mature production scripts: if `yn()`, `decp()`, `trim()`, `s()` are not called, delete them.
- [BCS0605] Remove unused global variables from production scripts: if `PROMPT`, `DEBUG` are not referenced, delete them.
- [BCS0605] Remove unused messaging functions your script doesn't call; keep only what your script actually needs to reduce size and improve clarity.
- [BCS0605] Simple scripts may only need `error()` and `die()`, not the full messaging suite; optimize accordingly.
## Error Handling in Main
- [BCS0603] Track errors in `main()` using counters: `local -i errors=0` then `((errors+=1))` on failures; return non-zero if `((errors > 0))`.
- [BCS0603] Use trap for cleanup in `main()`: `trap cleanup EXIT` at the start ensures cleanup happens on any exit path.
- [BCS0603] Make `main()` return 0 for success and non-zero for errors to enable `main "$@"` invocation at script level with `set -e`.
## Main Function Anti-Patterns
- [BCS0603] Never define functions after calling `main "$@"`; all functions must be defined before the main invocation.
- [BCS0603] Never parse arguments outside `main()` in global scope; this consumes `"$@"` before main receives it.
- [BCS0603] Never call main without passing arguments: use `main "$@"` not `main` to preserve all command-line arguments.
- [BCS0603] Never mix global and local state unnecessarily; prefer all logic and variables local to `main()` for clean scope.


---


**Rule: BCS0700**

## Control Flow - Rulets
## Conditionals
- [BCS0701] Always use `[[ ]]` for string and file tests, `(())` for arithmetic comparisons: `[[ -f "$file" ]]` for files, `((count > 0))` for numbers.
- [BCS0701] Never use `[ ]` for conditionals; use `[[ ]]` which handles unquoted variables safely, supports pattern matching with `==` and `=~`, and allows `&&`/`||` operators inside brackets.
- [BCS0701] Use short-circuit evaluation for concise conditionals: `[[ -f "$file" ]] && source "$file"` executes second command only if first succeeds, `((VERBOSE)) || return 0` executes second only if first fails.
- [BCS0701] Quote variables in `[[ ]]` conditionals for clarity even though not strictly required: `[[ "$var" == "value" ]]` not `[[ $var == "value" ]]`.
## Case Statements
- [BCS0702] Use case statements for multi-way branching based on pattern matching of a single variable; they're more readable and efficient than long if/elif chains.
- [BCS0702] Always quote the test variable but never quote literal patterns: `case "$filename" in` followed by `*.txt)` not `"*.txt")`.
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
## Pipes to While Loops
- [BCS0704] Never pipe commands to while loops; pipes create subshells where variable assignments don't persist outside the loop, causing silent failures.
- [BCS0704] Always use process substitution instead of pipes: `while read -r line; do ((count+=1)); done < <(command)` keeps loop in current shell so variables persist.
- [BCS0704] Use `readarray -t array < <(command)` when collecting lines into an array; it's cleaner and faster than manual while loop appending.
- [BCS0704] Use here-string `while read -r line; done <<< "$var"` when input is already in a variable.
- [BCS0704] For null-delimited input (filenames with newlines), use `while IFS= read -r -d '' file; done < <(find . -print0)` or `readarray -d '' -t files < <(find . -print0)`.
- [BCS0704] Remember pipe creates process tree: parent shell → subshell (while loop with modified variables) → subshell exits → changes discarded; process substitution avoids this.
## Arithmetic Operations
- [BCS0705] Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity: `declare -i count=0 total=0`.
- [BCS0705] Use `i+=1` for increment (clearest and safest) or `((++i))` (pre-increment, safe); never use `((i++))` which returns old value and fails with `set -e` when i=0.
- [BCS0705] Use `(())` for arithmetic operations without `$` on variables: `((result = x * y + z))` not `((result = $x * $y + $z))`.
- [BCS0705] Use `$(())` for arithmetic in assignments or command arguments: `result=$((i * 2 + 5))` or `echo "$((count / total))".`
- [BCS0705] Always use `(())` for arithmetic conditionals, never `[[ ]]` with `-gt`/`-lt`: `((count > 10))` not `[[ "$count" -gt 10 ]]`.
- [BCS0705] Remember integer division truncates toward zero: `((result = 10 / 3))` gives 3 not 3.33; use `bc` or `awk` for floating point.
- [BCS0705] Never use `expr` command for arithmetic; it's slow, external, and error-prone: use `$(())` or `(())` instead.


---


**Rule: BCS0800**

## Error Handling - Rulets
## Exit on Error
- [BCS0801] Always use `set -euo pipefail` at line 5 (after script description) to enable strict error detection: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` exits if any command in a pipeline fails.
- [BCS0801] Add `shopt -s inherit_errexit` to make command substitution inherit `set -e` behavior, ensuring `output=$(failing_command)` exits on failure.
- [BCS0801] Allow specific commands to fail using `command_that_might_fail || true` or wrap in conditional: `if command_that_might_fail; then ... else ... fi`.
- [BCS0801] Check if optional variables exist before using with: `[[ -n "${OPTIONAL_VAR:-}" ]]` to prevent exit on undefined variable with `set -u`.
- [BCS0801] Never capture command substitution in assignment without checking: `result=$(failing_command)` doesn't exit with `set -e`; use `result=$(cmd) || die 1` or enable `shopt -s inherit_errexit`.
## Exit Codes
- [BCS0802] Implement standard `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error handling with exit codes and messages.
- [BCS0802] Use standard exit codes: `0` for success, `1` for general error, `2` for misuse/missing argument, `22` for invalid argument (EINVAL), `5` for I/O error.
- [BCS0802] Never use exit codes above 125 for custom errors; codes 126-127 are reserved for shell errors, 128+n for fatal signals, and 255 is out of range.
- [BCS0802] Define exit code constants as readonly integers for readability: `readonly -i SUCCESS=0 ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3`.
- [BCS0802] Check exit codes in case statements to handle different failure modes: `case $? in 1) ... ;; 2) ... ;; *) ... ;; esac`.
## Trap Handling
- [BCS0803] Implement standard cleanup function pattern: capture exit code with `cleanup() { local -i exitcode=${1:-0}; trap - SIGINT SIGTERM EXIT; ... ; exit "$exitcode"; }`.
- [BCS0803] Install trap early before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT` ensures cleanup runs on normal exit, errors, Ctrl+C, and kill signals.
- [BCS0803] Always disable trap at start of cleanup function with `trap - SIGINT SIGTERM EXIT` to prevent recursion if cleanup itself fails.
- [BCS0803] Preserve exit code by capturing immediately: `trap 'cleanup $?' EXIT` passes original exit status; never use `trap 'cleanup' EXIT` as `$?` may change.
- [BCS0803] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` evaluates variables when trap fires, not when set.
- [BCS0803] Create temp files and directories before trap installation risks resource leaks; always use: `temp_file=$(mktemp) || die 1 'Failed'; trap 'rm -f "$temp_file"' EXIT`.
## Checking Return Values
- [BCS0804] Always check return values of critical operations with explicit conditionals: `if ! mv "$source" "$dest"; then die 1 "Failed to move $source to $dest"; fi`.
- [BCS0804] Provide informative error messages including context: `die 1 "Failed to move $source to $dest"` not just `die 1 "Move failed"`.
- [BCS0804] Check command substitution results explicitly: `output=$(command) || die 1 "command failed"` or enable `shopt -s inherit_errexit` to inherit `set -e` in subshells.
- [BCS0804] Use `set -o pipefail` to catch pipeline failures: without it, `cat missing_file | grep pattern` continues even if cat fails; with it, entire pipeline fails.
- [BCS0804] Check `PIPESTATUS` array for individual pipeline command exit codes: `if ((PIPESTATUS[0] != 0)); then die 1 "First command failed"; fi`.
- [BCS0804] Use cleanup on failure pattern: `operation || { error "Failed"; cleanup_resources; die 1; }` ensures partial state is cleaned up.
- [BCS0804,BCS0802] Capture and check exit codes when different codes require different actions: `cmd; exit_code=$?; case $exit_code in 0) ... ;; 1) ... ;; esac`.
## Error Suppression
- [BCS0805] Only suppress errors when failure is expected, non-critical, and explicitly documented: add comment explaining WHY suppression is safe before every `2>/dev/null` or `|| true`.
- [BCS0805] Never suppress critical operations like file copies, data processing, system configuration, security operations, or dependency checks; these must fail explicitly.
- [BCS0805] Use `2>/dev/null` to suppress only error messages while still checking return code: `if ! command 2>/dev/null; then error "command failed"; fi`.
- [BCS0805] Use `|| true` to ignore return code while keeping error messages visible for debugging.
- [BCS0805] Use combined suppression `2>/dev/null || true` only when both error messages and return code are completely irrelevant: `rmdir /tmp/maybe_exists 2>/dev/null || true`.
- [BCS0805] Appropriate suppression cases: checking if optional commands exist (`command -v tool >/dev/null 2>&1`), cleanup operations (`rm -f /tmp/files 2>/dev/null || true`), idempotent operations (`install -d "$dir" 2>/dev/null || true`).
- [BCS0805] Verify system state after suppressed operations when possible: after `install -d "$dir" 2>/dev/null || true`, check `[[ -d "$dir" ]] || die 1 "Failed to create $dir"`.
## Conditional Declarations
- [BCS0806] Append `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit: `((complete)) && declare -g BLUE=$'\033[0;34m' || :`.
- [BCS0806] Use colon `:` instead of `true` as no-op fallback; it's the traditional Unix idiom, built-in, and more concise.
- [BCS0806] Arithmetic conditionals `(())` return 0 (success) when true, 1 (failure) when false; under `set -e`, false conditions without `|| :` will exit the script.
- [BCS0806] Use `|| :` pattern only for optional operations like feature-gated variable declarations; never suppress critical operations that must succeed.
- [BCS0806] Prefer explicit `if` statements over `((condition)) && action || :` for complex logic with multiple statements or when clarity is more important than conciseness.
- [BCS0806,BCS0805] Never use `|| :` to suppress critical operation failures; use explicit error handling: `if ((flag)); then critical_op || die 1 "Failed"; fi`.


---


**Rule: BCS0900**

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


**Rule: BCS1000**

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


**Rule: BCS1100**

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


**Rule: BCS1200**

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


**Rule: BCS1300**

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


---


**Rule: BCS1400**

## Advanced Patterns - Rulets
## Debugging & Development
- [BCS1401] Enable debug mode with `declare -i DEBUG="${DEBUG:-0}"` and activate trace output using `((DEBUG)) && set -x` for troubleshooting.
- [BCS1401] Customize trace output with `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '` to show filename, line number, and function name in debug traces.
- [BCS1401] Implement conditional debug output with a `debug()` function that checks `((DEBUG))` before calling `_msg()` to stderr.
## Dry-Run Pattern
- [BCS1402] Implement dry-run mode by declaring `declare -i DRY_RUN=0` and checking `((DRY_RUN))` at the start of functions that modify state, displaying preview messages with `[DRY-RUN]` prefix and returning early without performing actual operations.
- [BCS1402] Parse dry-run flags with `-n|--dry-run) DRY_RUN=1` and `-N|--not-dry-run) DRY_RUN=0` for toggling preview mode.
- [BCS1402] Structure dry-run functions to maintain identical control flow whether in preview or execution mode, ensuring logic verification without side effects.
## Temporary File Handling
- [BCS1403] Always use `mktemp` to create temporary files and directories with secure permissions (0600 for files, 0700 for directories), never hard-code temp file paths like `/tmp/myapp.txt`.
- [BCS1403] Set up cleanup traps immediately after creating temp resources: `temp_file=$(mktemp) || die 1 'Failed to create temp file'` followed by `trap 'rm -f "$temp_file"' EXIT`.
- [BCS1403] Store temp file paths in variables and make them readonly when possible: `readonly -- temp_file` to prevent accidental modification.
- [BCS1403] For multiple temp resources, use an array with a cleanup function: `declare -a TEMP_RESOURCES=()` and `cleanup() { for resource in "${TEMP_RESOURCES[@]}"; do rm -rf "$resource"; done }` with `trap cleanup EXIT`.
- [BCS1403] Never use hard-coded paths, PIDs in filenames, or manual temp file creation - these create security vulnerabilities and race conditions.
- [BCS1403] Use custom templates when helpful: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (minimum 3 X's required for uniqueness).
- [BCS1403] Verify temp file security by checking permissions (0600), ownership (current user), and file type (regular file) when handling sensitive data.
- [BCS1403] Implement `--keep-temp` option for debugging by checking the flag in cleanup function before removing temp resources.
## Environment Variables
- [BCS1404] Validate required environment variables with `: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"` to exit immediately if not set.
- [BCS1404] Provide defaults for optional environment variables using `: "${OPTIONAL_VAR:=default_value}"` or `export VAR="${VAR:-default}"`.
- [BCS1404] Check multiple required variables by iterating through an array and testing `[[ -n "${!var:-}" ]]` to ensure all are set before proceeding.
## Regular Expressions
- [BCS1405] Use POSIX character classes for portability: `[[:alnum:]]`, `[[:digit:]]`, `[[:space:]]`, `[[:xdigit:]]` instead of literal ranges.
- [BCS1405] Store complex regex patterns in readonly variables: `readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'` then use `[[ "$email" =~ $EMAIL_REGEX ]]`.
- [BCS1405] Access regex capture groups through `BASH_REMATCH` array after successful match: `major="${BASH_REMATCH[1]}"`.
## Background Job Management
- [BCS1406] Track background process PIDs with `command &` followed by `PID=$!` to enable monitoring and control.
- [BCS1406] Check if background process is still running using `kill -0 "$PID" 2>/dev/null` which returns 0 if process exists.
- [BCS1406] Use `timeout` command with `wait` for timed background operations: `timeout 10 wait "$PID"` returns 124 on timeout.
- [BCS1406] Manage multiple background jobs by storing PIDs in an array `PIDS+=($!)` and iterating with `for pid in "${PIDS[@]}"; do wait "$pid"; done`.
## Logging
- [BCS1407] Implement structured logging with ISO8601 timestamps, script name, log level, and message: `printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"`.
- [BCS1407] Define log file location with defaults and create log directory if needed: `readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"` followed by `mkdir -p "${LOG_FILE%/*}"`.
- [BCS1407] Provide convenience logging functions (`log_debug`, `log_info`, `log_warn`, `log_error`) that wrap the main `log()` function.
## Performance Profiling
- [BCS1408] Use the `SECONDS` builtin for simple timing by resetting `SECONDS=0` before operation and reading elapsed time after completion.
- [BCS1408] Use `EPOCHREALTIME` for high-precision timing: capture `start=$EPOCHREALTIME` before operation, `end=$EPOCHREALTIME` after, calculate with `awk "BEGIN {print $end - $start}"`.
## Testing Support
- [BCS1409] Implement dependency injection by declaring command wrappers as functions: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` allows test mocking.
- [BCS1409] Use `declare -i TEST_MODE="${TEST_MODE:-0}"` flag to enable test-specific behavior like using test data directories or disabling destructive operations.
- [BCS1409] Implement assert function for test validation: check expected vs actual values, output detailed failure message to stderr, return 1 on failure.
- [BCS1409] Create test runner that discovers functions matching `test_*` pattern, executes each, tracks passed/failed counts, and returns 0 only if all pass.
## Progressive State Management
- [BCS1410] Declare boolean flags with initial values at script start: `declare -i INSTALL_BUILTIN=0`, `declare -i BUILTIN_REQUESTED=0`, `declare -i SKIP_BUILTIN=0`.
- [BCS1410] Parse command-line arguments to set flags based on user input, tracking both user intent (e.g., `BUILTIN_REQUESTED`) and current state (e.g., `INSTALL_BUILTIN`).
- [BCS1410] Progressively adjust flags based on runtime conditions in logical order: parse arguments → validate dependencies → check build success → execute actions.
- [BCS1410] Separate decision logic from execution by modifying flags during validation phase, then executing actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin`.
- [BCS1410] Disable features when prerequisites fail by resetting flags: `check_builtin_support || INSTALL_BUILTIN=0` ensures fail-safe behavior.
- [BCS1410] Never modify flags during execution phase - only in setup and validation phases to maintain clear separation between decision-making and action.
#fin
