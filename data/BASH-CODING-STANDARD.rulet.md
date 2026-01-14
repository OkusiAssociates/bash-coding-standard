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
## Shebang and Initial Setup
- [BCS0102] First line must be shebang (`#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash`), followed by optional `#shellcheck` directives, brief description comment, then `set -euo pipefail` as the first command.
- [BCS0102] Use `#!/bin/bash` for known Linux systems, `#!/usr/bin/bash` for BSD systems, `#!/usr/bin/env bash` for maximum portability across diverse environments.
## Strict Mode and Shell Options
- [BCS0101] `set -euo pipefail` is mandatory and must be the first command before any other commands execute (except shebang/comments/shellcheck).
- [BCS0105] Always use `shopt -s inherit_errexit shift_verbose extglob nullglob` for recommended shell behavior; `inherit_errexit` is critical as it makes `set -e` work in subshells and command substitutions.
- [BCS0105] Choose `nullglob` for scripts processing file lists (unmatched globs become empty) or `failglob` for strict scripts (unmatched globs cause errors); never use default behavior which expands unmatched globs to literal strings.
## Script Metadata
- [BCS0103] Declare standard metadata immediately after shopt: `declare -r VERSION=1.0.0`, then `declare -r SCRIPT_PATH=$(realpath -- "$0")`, then `declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Use `realpath` (not `readlink`) to resolve SCRIPT_PATH; it provides canonical absolute paths, fails early if file doesn't exist, and has a loadable builtin available for performance.
- [BCS0103] Disable SC2155 for SCRIPT_PATH declaration with comment; the failure mode (script doesn't exist) should cause immediate termination anyway: `#shellcheck disable=SC2155`.
## Global Variables and Colors
- [BCS0101] Declare all global variables up front with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Define terminal-aware colors conditionally: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ...; else declare -r RED='' ...; fi` to avoid escape codes in non-terminal output.
## Utility Functions
- [BCS0101] Implement standard messaging functions (`_msg`, `info`, `warn`, `error`, `die`, `success`, `vecho`) in Layer 1; remove unused functions only after script is mature.
- [BCS0101] Use `_msg()` as core message function with `FUNCNAME[1]` dispatch for consistent prefix formatting across all message types.
- [BCS0101] `die()` must take exit code as first argument: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
## Function Organization
- [BCS0107] Organize functions bottom-up in 7 layers: (1) messaging, (2) documentation, (3) utilities, (4) validation, (5) business logic, (6) orchestration, (7) `main()`; each layer can only call functions from layers above it.
- [BCS0107] Never define `main()` at the top of the file; it must be the last function defined before the `main "$@"` invocation.
- [BCS0107] Avoid circular dependencies between functions; extract common logic to a lower layer if two functions need to call each other.
## Main Function and Script Invocation
- [BCS0101] Use `main()` function for scripts over ~200 lines; scripts under 200 lines may run directly without `main()`.
- [BCS0101] Parse arguments in `main()`, then make configuration variables readonly after parsing complete: `readonly -- PREFIX CONFIG_FILE`.
- [BCS0101] Invoke script with `main "$@"` and always quote `"$@"` to preserve argument array properly.
## End Marker
- [BCS0101] Every script must end with `#fin` or `#end` as the mandatory final line to confirm the file is complete and not truncated.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be sourced or executed, define all functions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` before `set -euo pipefail`.
- [BCS010201] Never apply `set -euo pipefail` or `shopt` changes when sourced; these would alter the calling shell's environment.
- [BCS010201] Guard metadata initialization for idempotent re-sourcing: `if [[ ! -v SCRIPT_VERSION ]]; then declare -xr SCRIPT_VERSION=1.0.0; ...; fi`.
## FHS Compliance
- [BCS0104] Search for resources in FHS order: script directory (development), `"$PREFIX"/share/` (custom install), `/usr/local/share/` (local install), `/usr/share/` (system install), then XDG user directories.
- [BCS0104] Support PREFIX customization: `PREFIX=${PREFIX:-/usr/local}` and derive all paths from it: `BIN_DIR="$PREFIX"/bin`, `SHARE_DIR="$PREFIX"/share/myapp`.
- [BCS0104] Use XDG Base Directory spec for user-specific files: `${XDG_CONFIG_HOME:-"$HOME"/.config}`, `${XDG_DATA_HOME:-"$HOME"/.local/share}`.
## File Extensions
- [BCS0106] Executables should have `.sh` extension or no extension; globally available executables via PATH must have no extension.
- [BCS0106] Libraries must have `.sh` extension and should not be executable.
## Anti-Patterns
- [BCS010102] Never declare variables after they are used; with `set -u` this causes "unbound variable" errors.
- [BCS010102] Never define business logic functions before utility functions they call; organize bottom-up.
- [BCS010102] Never make variables readonly before argument parsing is complete if they need to be modified during parsing.
- [BCS010102] Never scatter global declarations throughout the file; group all globals together before functions.
- [BCS010102] Never source files that modify the caller's shell settings (`set -e`, `shopt`) without protection.
## Edge Cases
- [BCS010103] Sourced library files may skip `set -euo pipefail`, `main()`, and script invocation; they provide functions only.
- [BCS010103] Platform-specific scripts should detect platform early and set derived variables conditionally before making them readonly.
- [BCS010103] Scripts requiring cleanup must define cleanup function before setting trap, and set trap before any code that creates temporary resources.


---


**Rule: BCS0200**

## Variables & Data Types - Rulets
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


**Rule: BCS0300**

## Strings & Quoting - Rulets
## Quoting Fundamentals
- [BCS0301] Use single quotes for static strings and double quotes when variable expansion is needed: `info 'Processing...'` vs `info "Found $count files"`.
- [BCS0301] Nest single quotes inside double quotes to display literal values: `die 1 "Unknown option '$1'"`.
- [BCS0301] One-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted: `STATUS=success` or `[[ "$level" == INFO ]]`.
- [BCS0301] Always quote strings containing spaces, special characters, `$`, quotes, backslashes, or empty strings: `EMAIL='user@domain.com'`, `VAR=''`.
- [BCS0301] Quote variable portions separately from literal path components for clarity: `"$PREFIX"/bin` and `"$SCRIPT_DIR"/data/"$filename"`.
## Command Substitution
- [BCS0302] Use double quotes when strings include command substitution: `echo "Current time: $(date +%T)"`.
- [BCS0302] Omit quotes around simple variable assignments: `VERSION=$(git describe --tags)` not `VERSION="$(git describe --tags)"`.
- [BCS0302] Use double quotes when concatenating command substitution with other values: `VERSION="$(git describe)".beta`.
- [BCS0302] Always quote command substitution results when used: `echo "$result"` never `echo $result`.
## Quoting in Conditionals
- [BCS0303] Always quote variables in conditionals: `[[ -f "$file" ]]` never `[[ -f $file ]]`.
- [BCS0303] Leave glob patterns unquoted for matching: `[[ "$filename" == *.txt ]]` matches globs, `[[ "$filename" == '*.txt' ]]` matches literal.
- [BCS0303] Leave regex pattern variables unquoted: `[[ "$input" =~ $pattern ]]` not `[[ "$input" =~ "$pattern" ]]`.
- [BCS0303] Use single quotes or no quotes for static comparison values: `[[ "$mode" == 'production' ]]` or `[[ "$mode" == production ]]`.
## Here Documents
- [BCS0304] Use unquoted delimiter `<<EOF` when variable expansion is needed; use quoted delimiter `<<'EOF'` for literal content.
- [BCS0304] Quote here-doc delimiters for JSON, SQL, or any content with `$` characters that should not expand: `cat <<'EOF'`.
- [BCS0304] Use `<<-EOF` to strip leading tabs (not spaces) for indented heredocs within control structures.
## printf Patterns
- [BCS0305] Use single quotes for printf format strings and double quotes for variable arguments: `printf '%s: %d files\n' "$name" "$count"`.
- [BCS0305] Prefer printf over `echo -e` for consistent escape sequence handling: `printf 'Line1\nLine2\n'` not `echo -e "Line1\nLine2"`.
- [BCS0305] Use `$'...'` syntax as alternative for escape sequences in echo: `echo $'Line1\nLine2'`.
## Parameter Quoting with @Q
- [BCS0306] Use `${parameter@Q}` to safely display user input in error messages: `die 2 "Unknown option ${1@Q}"`.
- [BCS0306] Use `${var@Q}` for dry-run output to show exact command that would execute: `info "[DRY-RUN] ${cmd@Q}"`.
- [BCS0306] Never use `@Q` for normal variable expansion or comparisons; use standard quoting: `process "$file"`, `[[ "$var" == "$value" ]]`.
## Anti-Patterns
- [BCS0307] Never use double quotes for static strings: `info 'Checking...'` not `info "Checking..."`.
- [BCS0307] Never leave variables unquoted: `echo "$result"` not `echo $result`, `rm "$temp_file"` not `rm $temp_file`.
- [BCS0307] Avoid unnecessary braces around variables: `echo "$HOME"/bin` not `echo "${HOME}/bin"`.
- [BCS0307] Use braces only when required: `${var:-default}`, `${file##*/}`, `${array[@]}`, `${var1}${var2}`.
- [BCS0307] Always quote array expansions: `for item in "${items[@]}"` never `for item in ${items[@]}`.
- [BCS0307,BCS0304] Quote here-doc delimiters to prevent SQL injection and unintended variable expansion in templates.


---


**Rule: BCS0400**

## Functions - Rulets
## Section Overview
- [BCS0400] Organize functions bottom-up: messaging functions first, then helpers, then business logic, with `main()` last—each function can safely call previously defined functions.
## Function Definition Pattern
- [BCS0401] Use single-line format for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`
- [BCS0401] Use multi-line format with local variables for complex functions; always `return "$exitcode"` explicitly.
- [BCS0401] Declare local variables at function start with `local -i` for integers and `local --` for strings.
## Function Names
- [BCS0402] Use lowercase with underscores for function names: `process_log_file()` not `ProcessLogFile()` or `PROCESS_FILE()`.
- [BCS0402] Prefix private/internal functions with underscore: `_validate_input()`, `_my_private_function()`.
- [BCS0402] Never override built-in commands without good reason; if wrapping built-ins, use a different name: `change_dir()` not `cd()`.
- [BCS0402] Never use dashes in function names: `my_function()` not `my-function()`.
## Main Function
- [BCS0403] Always include a `main()` function for scripts longer than ~200 lines; place `main "$@"` at the bottom just before `#fin`.
- [BCS0403] Parse arguments inside `main()`, not at script level; make parsed option variables readonly after parsing.
- [BCS0403] Always call main with all arguments: `main "$@"` never just `main`.
- [BCS0403] Define all helper functions before `main()` so they exist when main executes.
- [BCS0403] For testable scripts, use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `set -euo pipefail` to allow sourcing.
- [BCS0403] Use `trap cleanup EXIT` in main for setup/cleanup patterns with temporary resources.
- [BCS0403] Return appropriate exit codes from main: `((error_count == 0))` for boolean success/failure.
## Function Export
- [BCS0404] Export functions needed by subshells using `declare -fx`: `declare -fx grep find my_function`.
- [BCS0404] Define function first, then export: `my_func() { :; }; declare -fx my_func`.
## Production Optimization
- [BCS0405] Remove unused utility functions from production scripts: if `yn()`, `trim()`, `debug()` are not called, delete them.
- [BCS0405] Remove unused global variables: if `SCRIPT_DIR`, `DEBUG`, `PROMPT` are not referenced, delete them.
- [BCS0405] Keep only functions and variables the script actually needs to reduce size and maintenance burden.
## Dual-Purpose Scripts
- [BCS0406] For dual-purpose scripts, define functions before any `set -e`, then check `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before enabling strict mode.
- [BCS0406] Place `set -euo pipefail` AFTER the sourced check, not before—library code should not impose error handling on caller.
- [BCS0406] Use idempotent initialization with version guard: `[[ -v MY_LIB_VERSION ]] || { declare -rx MY_LIB_VERSION=1.0.0; ... }`.
- [BCS0406] Export all functions intended for use when sourced: `my_function() { :; }; declare -fx my_function`.
## Library Patterns
- [BCS0407] Pure libraries must reject execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || { >&2 echo 'Error: must be sourced'; exit 1; }`.
- [BCS0407] Define library version as readonly export: `declare -rx LIB_VALIDATION_VERSION=1.0.0`.
- [BCS0407] Use namespace prefixes for all library functions to avoid conflicts: `myapp_init()`, `myapp_cleanup()`, `myapp_process()`.
- [BCS0407] Allow configuration override before sourcing: `: "${CONFIG_DIR:=/etc/myapp}"`.
- [BCS0407] Libraries should only define functions, not have side effects on source; use explicit initialization calls.
- [BCS0407] Source libraries with existence check: `[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library"`.
## Dependency Management
- [BCS0408] Use `command -v` for dependency checks, never `which`: `command -v curl >/dev/null || die 1 'curl required'`.
- [BCS0408] Check multiple dependencies in a loop: `for cmd in curl jq awk; do command -v "$cmd" >/dev/null || die 1 "Required ${cmd@Q}"; done`.
- [BCS0408] For optional dependencies, set availability flag: `declare -i HAS_JQ=0; command -v jq >/dev/null && HAS_JQ=1 ||:`.
- [BCS0408] Check Bash version at script start: `((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)) || die 1 'Requires Bash 5.2+'`.
- [BCS0408] Provide helpful error messages for missing dependencies: `die 1 'curl required: apt install curl'`.
- [BCS0408] Use lazy loading for expensive resources: initialize only when first needed, not at script start.


---


**Rule: BCS0500**

## Control Flow - Rulets
## Conditionals
- [BCS0501] Use `[[ ]]` for string and file tests, `(())` for arithmetic comparisons: `[[ -f "$file" ]]` for existence, `((count > 5))` for numbers.
- [BCS0501] Never use `[ ]` test syntax; `[[ ]]` provides pattern matching, `&&`/`||` operators, and no word splitting on variables.
- [BCS0501] Use arithmetic truthiness directly: `((count))` not `((count > 0))`, `((VERBOSE))` not `((VERBOSE == 1))`.
- [BCS0501] Pattern match with `[[ "$file" == *.txt ]]` for globs and `[[ "$input" =~ ^[0-9]+$ ]]` for regex.
- [BCS0501] Short-circuit evaluation: `[[ -f "$file" ]] && source "$file"` for conditional execution, `||` for fallback.
## Case Statements
- [BCS0502] Use `case` for multi-way branching on single variable pattern matching; use `if/elif` for multiple variables or complex conditions.
- [BCS0502] Do not quote the case expression: `case ${1:-} in` not `case "${1:-}" in`.
- [BCS0502] Do not quote literal patterns: `start)` not `"start)"`, but quote test variable: `case "$var" in`.
- [BCS0502] Always include default case `*)` to handle unexpected values explicitly.
- [BCS0502] Compact format for simple single-action cases with `;;` on same line; expanded format for multi-line logic with `;;` on separate line.
- [BCS0502] Align actions consistently at column 14-18 for readability.
- [BCS0502] Use alternation for multiple patterns: `-h|--help|help)` and wildcards: `*.txt|*.md)`.
- [BCS0502] Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`.
## Loops
- [BCS0503] Use for loops for arrays and globs: `for file in "${files[@]}"`, `for f in *.txt`.
- [BCS0503] Use while loops for reading input and argument parsing: `while (($#)); do case $1 in`.
- [BCS0503] Always quote array expansion in loops: `"${array[@]}"` to preserve element boundaries.
- [BCS0503] Never parse `ls` output; use glob patterns directly: `for f in *.txt` not `for f in $(ls *.txt)`.
- [BCS0503] Use `i+=1` for all increments in C-style loops: `for ((i=0; i<10; i+=1))`, never `i++` or `((i++))`.
- [BCS0503] Use `while ((1))` for infinite loops (fastest); `while :` for POSIX compatibility; avoid `while true` (15-22% slower).
- [BCS0503] Declare local variables before loops, not inside: `local -- file; for file in *.txt` not `for file in *.txt; do local -- file`.
- [BCS0503] Use `break N` for nested loops to specify level: `break 2` exits both inner and outer loop.
- [BCS0503] Use `while (($#))` not `while (($# > 0))` for argument parsing; non-zero is truthy in arithmetic context.
- [BCS0503] Always use `IFS= read -r` when reading input to preserve whitespace and backslashes.
## Pipes to While Loops
- [BCS0504] Never pipe to while loops; pipes create subshells where variable modifications are lost.
- [BCS0504] Use process substitution: `while read -r line; do count+=1; done < <(command)` to keep variables in current shell.
- [BCS0504] Use `readarray -t array < <(command)` when collecting lines into array; simpler and efficient.
- [BCS0504] Use here-string `<<< "$var"` when input is already in a variable.
- [BCS0504] Use `-d ''` with `read` and `-print0` with `find` for null-delimited input handling filenames with newlines.
## Arithmetic Operations
- [BCS0505,BCS0201] Always declare integer variables with `declare -i` or `local -i` before arithmetic operations.
- [BCS0505] Use `i+=1` for ALL increments; never use `((i++))`, `((++i))`, or `((i+=1))`.
- [BCS0505] Use `(())` for arithmetic conditionals: `((count > 10))` not `[[ "$count" -gt 10 ]]`.
- [BCS0505] No `$` needed inside `(())`: `((result = x + y))` not `((result = $x + $y))`.
- [BCS0505] Use arithmetic truthiness: `((count))` evaluates non-zero as true, zero as false.
- [BCS0505] Integer division truncates: `((10 / 3))` equals 3; use `bc` or `awk` for floating point.
## Floating-Point Operations
- [BCS0506] Bash only supports integer arithmetic; use `bc -l` or `awk` for floating-point calculations.
- [BCS0506] Use `bc` for precision: `result=$(echo 'scale=2; 10 / 3' | bc -l)`.
- [BCS0506] Use `awk` for inline float math: `result=$(awk -v a="$a" -v b="$b" 'BEGIN {printf "%.2f", a * b}')`.
- [BCS0506] Compare floats with `bc` or `awk`: `if (($(echo "$a > $b" | bc -l)))` not `[[ "$a" > "$b" ]]`.
- [BCS0506] Use `printf '%.2f'` to format floating-point output to specific decimal places.


---


**Rule: BCS0600**

## Error Handling - Rulets
## Exit on Error
- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` to ensure command substitutions inherit `set -e` behavior.
- [BCS0601] Allow expected failures with `command_that_might_fail || true` or by wrapping in conditional: `if command_that_might_fail; then ...`.
- [BCS0601] Handle undefined optional variables with default syntax: `"${OPTIONAL_VAR:-}"`.
- [BCS0601] Never use `set +e` broadly; only disable errexit for specific commands when absolutely necessary, then immediately re-enable.
- [BCS0601] Capture failing command output safely: `if result=$(failing_command); then ...` or `output=$(cmd) || die 1 'cmd failed'`.
## Exit Codes
- [BCS0602] Use `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }` as the standard exit function.
- [BCS0602] Exit 0 for success, 1 for general error, 2 for usage error, 3 for file not found, 5 for I/O error, 22 for invalid argument.
- [BCS0602] Use exit codes 8 (required argument missing), 9 (value out of range), 10 (wrong type/format) for validation errors.
- [BCS0602] Use exit codes 11 (operation not permitted), 12 (read-only), 13 (permission denied) for permission errors.
- [BCS0602] Use exit codes 18 (missing dependency), 19 (configuration error), 20 (environment error), 21 (invalid state) for environment issues.
- [BCS0602] Use exit codes 23 (network error), 24 (timeout), 25 (host unreachable) for network operations.
- [BCS0602] Never use exit codes 64-78 (sysexits), 126 (cannot execute), 127 (not found), or 128+n (signals) - these are reserved.
- [BCS0602] Include context in error messages: `die 3 "Config not found ${config@Q}"` not just `die 3 'File not found'`.
## Trap Handling
- [BCS0603] Install cleanup traps early with `trap 'cleanup $?' SIGINT SIGTERM EXIT` before creating any resources.
- [BCS0603] Always disable traps inside cleanup function first: `trap - SIGINT SIGTERM EXIT` to prevent recursion.
- [BCS0603] Preserve exit code by capturing `$?` immediately: `cleanup() { local -i exitcode=${1:-0}; ... exit "$exitcode"; }`.
- [BCS0603] Use single quotes for trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` not double quotes.
- [BCS0603] Use `||:` or `|| true` for cleanup operations that might fail: `rm -rf "$temp_dir" ||:`.
- [BCS0603] Kill background processes in cleanup: `((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:`.
- [BCS0603] Never combine multiple traps for same signal (replaces previous); use single trap with function or compound commands.
## Checking Return Values
- [BCS0604] Always check return values of critical operations even with `set -e`: `mv "$file" "$dest" || die 1 "Failed to move ${file@Q}"`.
- [BCS0604] Check command substitution results explicitly: `output=$(command) || die 1 'Command failed'` since `set -e` doesn't catch these.
- [BCS0604] Use `set -o pipefail` and verify with PIPESTATUS array for critical pipelines: `((PIPESTATUS[0] != 0))` checks first command.
- [BCS0604] Check `$?` immediately after command, not after other operations: `cmd1; result=$?; cmd2; # result is from cmd1`.
- [BCS0604] Use command group with cleanup on failure: `cp "$src" "$dst" || { rm -f "$dst"; die 1 "Copy failed"; }`.
- [BCS0604] Handle different exit codes with case statement: `case $? in 0) success;; 2) die 2 'Not found';; *) die 1 'Unknown error';; esac`.
- [BCS0604] Prefer process substitution over pipes to while loops to avoid subshell issues: `while read -r line; do ...; done < <(command)`.
## Error Suppression
- [BCS0605] Only suppress errors when failure is expected, non-critical, and explicitly safe to ignore; always document why.
- [BCS0605] Use `command 2>/dev/null` to suppress error messages while still checking return value.
- [BCS0605] Use `command || true` or `command ||:` to ignore return code while keeping stderr visible.
- [BCS0605] Use `command 2>/dev/null || true` only when both messages and return code are irrelevant.
- [BCS0605] Safe to suppress: `command -v optional_tool >/dev/null 2>&1`, `rm -f /tmp/optional_*`, `rmdir maybe_empty 2>/dev/null ||:`.
- [BCS0605] Never suppress: file copies, data processing, security operations, system configuration, or required dependency checks.
- [BCS0605] Never use `set +e` to suppress errors; use `|| true` for specific commands only.
- [BCS0605] Verify system state after suppressed operations when possible: `install -d "$dir" 2>/dev/null ||:; [[ -d "$dir" ]] || die 1 'Failed'`.
## Conditional Declarations with Exit Code Handling
- [BCS0606] Append `||:` to `((condition)) && action` patterns under `set -e`: `((complete)) && declare -g VAR=value ||:`.
- [BCS0606] Use colon `:` over `true` for the no-op (traditional shell idiom, built-in, single character).
- [BCS0606] False arithmetic conditions return exit code 1 which triggers `set -e`; `||:` makes overall expression return 0.
- [BCS0606] Use for optional declarations: `((DEBUG)) && declare -g DEBUG_LOG=/tmp/debug.log ||:`.
- [BCS0606] Use for conditional output: `((VERBOSE)) && echo "Processing $file" ||:`.
- [BCS0606] Use for tier-based features: `((complete)) && declare -g BLUE=$'\033[0;34m' ||:`.
- [BCS0606] Never use `||:` for critical operations that must succeed; use explicit if statement with error handling instead.
- [BCS0606] For nested conditionals, apply `||:` to each level: `((outer)) && { action; ((inner)) && nested ||:; } ||:`.


---


**Rule: BCS0700**

## Input/Output & Messaging - Rulets
## Color Support and Terminal Detection
- [BCS0701] Declare message control flags as integers at script start: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0701] Conditionally set color variables based on terminal detection: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ... else declare -r RED='' ... fi`.
- [BCS0701,BCS0708] Always check BOTH stdout AND stderr for terminal detection: `[[ -t 1 && -t 2 ]]`, not just `[[ -t 1 ]]`.
## STDOUT vs STDERR Separation
- [BCS0702] All error, warning, and informational messages must go to STDERR; only data output goes to STDOUT.
- [BCS0702] Place `>&2` at the BEGINNING of commands for clarity: `>&2 echo "message"` is preferred over `echo "message" >&2`.
- [BCS0702,BCS0705] Stream separation enables script composition: `data=$(./script.sh)` captures only data, `./script.sh 2>errors.log` separates errors, `./script.sh | process` pipes data while showing messages.
## Core Message Functions
- [BCS0703] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine the calling function and apply appropriate formatting automatically.
- [BCS0703] Standard messaging wrapper functions: `vecho()` (verbose), `success()` (green ✓), `warn()` (yellow ▲), `info()` (cyan ◉), `error()` (red ✗), `debug()` (DEBUG-controlled).
- [BCS0703] Conditional functions must check their flag before output: `info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }`.
- [BCS0703] The `error()` function must be unconditional and always output to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0703] Implement `die()` with exit code as first parameter: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0703] The `yn()` prompt function must respect the PROMPT flag for automation: `yn() { ((PROMPT)) || return 0; ... }`.
- [BCS0703] Never duplicate message logic across functions; use a single `_msg()` implementation with FUNCNAME inspection for DRY compliance.
## Usage Documentation
- [BCS0704] Structure help text with sections: script name/version, brief description, detailed description, Usage line, Options block, Examples.
- [BCS0704] Use heredoc with `cat <<EOT` for help text; never use messaging functions for help output.
- [BCS0704] Include version in help header and provide both `-V|--version` and `-h|--help` options.
## Echo vs Messaging Functions
- [BCS0705] Use messaging functions (`info`, `warn`, `error`) for operational status updates that should respect verbosity settings.
- [BCS0705] Use plain `echo` for data output, help text, structured reports, version output, and any parseable output.
- [BCS0705] Help text and version output must ALWAYS display regardless of VERBOSE setting; use `echo` or `cat`, never `info()`.
- [BCS0705] Functions returning data must use `echo` to stdout, never messaging functions: `get_value() { echo "$result"; }`.
- [BCS0705] Never mix data and status on the same stream; status to stderr via messaging functions, data to stdout via echo.
## Color Management Library
- [BCS0706] Use a two-tier color system: basic (5 variables: NC, RED, GREEN, YELLOW, CYAN) for minimal scripts, complete (12 variables adding BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE) when needed.
- [BCS0706] Provide three color modes: `auto` (detect terminal), `always` (force on), `never` (force off).
- [BCS0706] The `flags` option in color_set integrates with BCS _msg system by setting VERBOSE, DEBUG, DRY_RUN, PROMPT globals.
- [BCS0706] Implement dual-purpose pattern for color libraries: sourceable as library or executable for demonstration.
- [BCS0706] Never scatter inline color declarations across scripts; centralize in a color management library or single declaration block.
## TUI Basics
- [BCS0707] Always check for terminal before using TUI elements: `if [[ -t 1 ]]; then progress_bar 50 100; else echo '50% complete'; fi`.
- [BCS0707] Hide cursor during TUI operations and restore on exit: `hide_cursor() { printf '\033[?25l'; }; trap 'show_cursor' EXIT`.
- [BCS0707] Use ANSI escape sequences for cursor control: `\033[?25l` (hide), `\033[?25h` (show), `\033[2K\r` (clear line), `\033[%dA` (move up).
## Terminal Capabilities
- [BCS0708] Get terminal dimensions dynamically and update on resize: `trap 'get_terminal_size' WINCH`.
- [BCS0708] Use `tput` for capability checking with fallbacks: `tput cols 2>/dev/null || echo 80`.
- [BCS0708] Check for Unicode support via locale: `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`.
- [BCS0708] Never hardcode terminal width; use `${TERM_COLS:-80}` with dynamic detection.
- [BCS0708] Provide graceful fallbacks for limited terminals; never assume color or cursor control support.


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


**Rule: BCS0800**

## Command-Line Arguments - Rulets
## Standard Parsing Pattern
- [BCS0801] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing; prefer arithmetic test `(($#))` over `[[ $# -gt 0 ]]` for efficiency.
- [BCS0801] Support both short and long options with pipe patterns: `-v|--verbose) VERBOSE+=1 ;;`
- [BCS0801] For options requiring arguments, call `noarg "$@"` before shifting, then capture: `noarg "$@"; shift; OUTPUT=$1`
- [BCS0801] Use `exit 0` for `--help` and `--version` handlers (or `return 0` if inside a function).
- [BCS0801] Catch invalid options with: `-*) die 22 "Invalid option ${1@Q}" ;;`
- [BCS0801] Collect positional arguments in arrays: `*) FILES+=("$1") ;;`
- [BCS0801] The mandatory `shift` at loop end (`esac; shift; done`) is critical—omitting it causes infinite loops.
## Short Option Disaggregation
- [BCS0801,BCS0805] Always include short option bundling support in parsing loops to allow `-vvn` instead of `-v -v -n`: `-[vVhn]*) set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;`
- [BCS0805] List only valid short options in the disaggregation pattern: `-[ovnVh]*` documents valid options and prevents incorrect expansion of unknown options.
- [BCS0805] For performance-critical scripts, use pure bash disaggregation (68% faster): `local -- opt=${1:1}; local -a new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`
- [BCS0805] Options requiring arguments cannot be bundled mid-string; place them at end or use separately: `-vno output.txt` works, but `-von file` captures `n` as argument to `-o`.
## Version Output Format
- [BCS0802] Version output must be `scriptname X.Y.Z` without the word "version": `echo "$SCRIPT_NAME $VERSION"; exit 0`
- [BCS0802] Never include "version", "vs", or "v" between script name and version number.
## Argument Validation Helpers
- [BCS0803] Use `noarg()` for basic existence check: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }`
- [BCS0803] Use `arg2()` for enhanced validation with safe quoting: `arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }`
- [BCS0803] Use `arg_num()` for numeric argument validation: `arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }`
- [BCS0803] Always call validators BEFORE `shift`—they must inspect `$2` to work correctly.
- [BCS0803] Validators prevent silent failures like `--output --verbose` where `--verbose` becomes the filename.
## Parsing Location
- [BCS0804] Place argument parsing inside `main()` for better testability, cleaner scoping, and encapsulation.
- [BCS0804] Top-level parsing is acceptable only for simple scripts under 200 lines without a `main()` function.


---


**Rule: BCS0900**

## File Operations - Rulets
## Section Overview
- [BCS0900] File operations section covers safe file testing, wildcard expansion, process substitution, here documents, and input redirection patterns to prevent common shell scripting pitfalls.
## Safe File Testing
- [BCS0901] Always quote variables in file tests and use `[[ ]]` syntax: `[[ -f "$file" ]]` not `[[ -f $file ]]` or `[ -f "$file" ]`.
- [BCS0901] Test files before use with fail-fast pattern: `[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"`.
- [BCS0901] Combine permission checks when sourcing files: `[[ -f "$file" && -r "$file" ]] || die 5 "Cannot read ${file@Q}"`.
- [BCS0901] Use `-s` to check for non-empty files: `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS0901] Use `-nt` and `-ot` for timestamp comparisons: `[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"`.
- [BCS0901] Validate directory writability with combined checks: `[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"`.
- [BCS0901] Include filenames in error messages for debugging: `die 3 "File not found ${file@Q}"`.
## Wildcard Expansion
- [BCS0902] Always use explicit path prefix for wildcard expansion to prevent filenames starting with `-` from being interpreted as flags: `rm -v ./*` not `rm -v *`.
- [BCS0902] Use `./*.txt` pattern in loops: `for file in ./*.txt; do process "$file"; done`.
## Process Substitution
- [BCS0903] Use process substitution `< <(command)` with while loops to avoid subshell variable scope issues: `while read -r line; do count+=1; done < <(cat file)`.
- [BCS0903] Use `readarray -t array < <(command)` to populate arrays from command output without subshell issues.
- [BCS0903] Use process substitution to compare command outputs without temp files: `diff <(sort file1) <(sort file2)`.
- [BCS0903] Use `>(command)` with tee for parallel output processing: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt)`.
- [BCS0903] Use null-delimited process substitution for filenames with special characters: `while IFS= read -r -d '' file; do ...; done < <(find /data -type f -print0)`.
- [BCS0903] Quote variables inside process substitution: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS0903] Never use pipe to while when you need to preserve variable values: use `< <(command)` instead of `command | while`.
## Here Documents
- [BCS0904] Use single-quoted delimiter `<<'EOT'` to prevent variable expansion in here documents.
- [BCS0904] Use unquoted delimiter `<<EOT` when variable expansion is needed in here documents.
## Input Redirection vs Cat
- [BCS0905] Use `$(< file)` instead of `$(cat file)` for command substitution—107x faster due to zero process fork.
- [BCS0905] Use `< file` redirection instead of `cat file |` for single-file input to commands—3-4x faster: `grep pattern < file.txt` not `cat file.txt | grep pattern`.
- [BCS0905] Optimize loops by using `$(< "$file")` instead of `$(cat "$file")`—fork overhead multiplies across iterations.
- [BCS0905] Use `cat` when concatenating multiple files, when using cat options (`-n`, `-A`, `-b`), or when multiple file arguments are needed.
- [BCS0905] Remember `< filename` alone produces no output—it requires a command to consume the redirected input.


---


**Rule: BCS1000**

## Security Considerations - Rulets
## General Principles
- [BCS1000] Security practices cover five essential areas: SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, and input sanitization - these prevent privilege escalation, command injection, and path traversal attacks.
## SUID/SGID Prohibition
- [BCS1001] Never use SUID or SGID bits on Bash scripts under any circumstances - this is a critical security prohibition with no exceptions: `chmod u+s script.sh` is catastrophically dangerous.
- [BCS1001] Use sudo with configured permissions instead of SUID: `sudo /usr/local/bin/myscript.sh` or configure `/etc/sudoers.d/myapp` for specific commands.
- [BCS1001] SUID scripts are vulnerable to IFS exploitation, PATH manipulation, library injection via `LD_PRELOAD`, shell expansion attacks, and TOCTOU race conditions.
- [BCS1001] For elevated privileges, use sudo, capabilities (`setcap`), compiled setuid wrappers, PolicyKit (`pkexec`), or systemd services - never SUID shell scripts.
- [BCS1001] Find SUID/SGID scripts on your system with: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`
## PATH Security
- [BCS1002] Always secure PATH at script start to prevent command hijacking: `readonly -- PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`
- [BCS1002] Never include current directory (`.`), empty elements (`::`, leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1002] Validate inherited PATH if not locking it down: check for `\.`, `^:`, `::`, `:$`, and `/tmp` patterns with `[[ "$PATH" =~ pattern ]]`.
- [BCS1002] For maximum security, use absolute paths for critical commands: `/bin/tar`, `/bin/rm`, `/usr/bin/systemctl`.
- [BCS1002] Verify critical commands resolve to expected locations: `command -v tar | grep -q '^/bin/tar$' || die 1 'Security: tar not from /bin/tar'`
- [BCS1002] Place PATH setting in first few lines after `set -euo pipefail` - commands executed before PATH is set use inherited (potentially malicious) PATH.
## IFS Safety
- [BCS1003] Never trust inherited IFS values - always set IFS explicitly at script start: `IFS=$' \t\n'; readonly IFS; export IFS`
- [BCS1003] Use subshell isolation for IFS changes: `( IFS=','; read -ra fields <<< "$data" )` - IFS automatically reverts when subshell exits.
- [BCS1003] Use one-line IFS assignment for single commands: `IFS=',' read -ra fields <<< "$csv_data"` - IFS resets after the command.
- [BCS1003] Use `local -- IFS` in functions to scope IFS changes to that function only.
- [BCS1003] Always save and restore IFS if modifying globally: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"` - ensure restoration in error cases too.
- [BCS1003] For null-delimited input (e.g., `find -print0`), use: `while IFS= read -r -d '' file; do ...; done < <(find . -print0)`
## Eval Command Avoidance
- [BCS1004] Never use `eval` with untrusted input - avoid `eval` entirely unless absolutely necessary; almost every use case has a safer alternative.
- [BCS1004] Use arrays for dynamic command construction instead of eval: `cmd=(find "$path" -name "$pattern"); "${cmd[@]}"`
- [BCS1004] Use indirect expansion for variable references instead of eval: `echo "${!var_name}"` not `eval "echo \$$var_name"`
- [BCS1004] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"` not `eval "$var_name='$value'"`
- [BCS1004] Use associative arrays for dynamic data: `declare -A data; data["$key"]="$value"` not `eval "var_$key='$value'"`
- [BCS1004] Use case statements or array lookup for function dispatch: `case "$action" in start) start_fn ;; esac` not `eval "${action}_function"`
- [BCS1004] If eval seems necessary for parsing key=value pairs, use: `IFS='=' read -r key value <<< "$line"` then validate key before `declare -g "$key=$value"`
## Input Sanitization
- [BCS1005] Always validate and sanitize user input before use - never trust input even if it "looks safe"; use whitelist over blacklist approach.
- [BCS1005] Sanitize filenames by removing `..` and `/`, allowing only `[a-zA-Z0-9._-]+`, rejecting hidden files and names over 255 chars.
- [BCS1005] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: $input"` - check for leading zeros if octal interpretation is a concern.
- [BCS1005] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$path"); [[ "$real_path" == "$allowed_dir"* ]] || die`
- [BCS1005] Validate against whitelists for choices: iterate valid options and match, or use associative array with `-v` test.
- [BCS1005] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"`
- [BCS1005] Never pass user input directly to shell commands - validate first, use case statements for command whitelisting.
- [BCS1005] Validate early, fail securely with clear errors, and run with minimum necessary permissions.
## Temporary File Handling
- [BCS1006] Always use `mktemp` to create temporary files and directories - never hard-code temp file paths like `/tmp/myapp_temp.txt`.
- [BCS1006] Always set up cleanup trap immediately after creating temp resources: `temp_file=$(mktemp) || die 1 'Failed'; trap 'rm -f "$temp_file"' EXIT`
- [BCS1006] Check mktemp success explicitly: `temp_file=$(mktemp) || die 1 'Failed to create temp file'` - never assume success.
- [BCS1006] Use `-d` flag for temp directories and `-rf` for cleanup: `temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT`
- [BCS1006] Use custom templates for recognizable temp files: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (minimum 3 X's required).
- [BCS1006] For multiple temp files, use array and cleanup function: `declare -a TEMP_FILES=(); cleanup() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done }; trap cleanup EXIT`
- [BCS1006] Never use PID in filename (`/tmp/app_$$`), never create temp manually with `touch`/`chmod`, never change permissions to world-writable.
- [BCS1006] Default mktemp permissions are secure (0600 files, 0700 directories) - verify if handling sensitive data: `stat -c %a "$temp_file"`
- [BCS1006] Multiple trap statements overwrite each other - use single trap with combined cleanup or cleanup function for all resources.
- [BCS1006] Add `--keep-temp` option for debugging: check flag in cleanup function and skip deletion if set, printing preserved file paths.


---


**Rule: BCS1100**

## Concurrency & Jobs - Rulets
## Background Job Management
- [BCS1101] Always track PIDs when starting background jobs: `command &; pid=$!` — never leave background jobs unmanaged.
- [BCS1101] Use `$!` to capture the last background PID; never use `$$` which returns the parent PID.
- [BCS1101] Store multiple background PIDs in an array: `declare -a pids=(); command &; pids+=($!)`.
- [BCS1101] Check if a process is running with `kill -0 "$pid" 2>/dev/null` (signal 0 is existence check only).
- [BCS1101] Use `wait -n` (Bash 4.3+) to wait for any single job to complete rather than all jobs.
- [BCS1101] Implement cleanup traps for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` with trap reset inside cleanup to prevent recursion.
- [BCS1101] In cleanup functions, kill remaining PIDs with `kill "$pid" 2>/dev/null || true` to suppress errors for already-terminated processes.
## Parallel Execution Patterns
- [BCS1102] For parallel execution with ordered output, write results to temp files (`"$temp_dir/$server.out"`) then display in original order after all jobs complete.
- [BCS1102] Implement concurrency limits by checking `${#pids[@]}` against `max_jobs` and using `wait -n` to wait for slots.
- [BCS1102] Update active PID lists by testing each PID with `kill -0 "$pid" 2>/dev/null` and rebuilding the array.
- [BCS1102] Never modify variables in background subshells expecting parent visibility; use temp files for results: `echo 1 >> "$temp_dir"/count`.
- [BCS1102] Clean up temp directories with `trap 'rm -rf "$temp_dir"' EXIT` when using parallel output capture.
## Wait Patterns
- [BCS1103] Always capture wait exit codes: `wait "$pid"; exit_code=$?` — never discard return values.
- [BCS1103] Track errors across multiple waits: `declare -i errors=0; for pid in "${pids[@]}"; do wait "$pid" || errors+=1; done`.
- [BCS1103] Use `wait -n` in a loop with PID existence checks to process jobs as they complete rather than in start order.
- [BCS1103] For per-server error tracking, use associative arrays: `declare -A exit_codes=()` storing PID then replacing with actual exit code after wait.
- [BCS1103] Never ignore wait return values; use `wait $! || die 1 'Command failed'` to handle failures.
## Timeout Handling
- [BCS1104] Always wrap network operations with timeout: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'`.
- [BCS1104] Handle timeout exit code 124 specially: command timed out; 125 means timeout itself failed; 137 means killed by SIGKILL.
- [BCS1104] Use `--signal=TERM --kill-after=10` to send SIGTERM first with SIGKILL fallback after grace period.
- [BCS1104] For user input timeouts, use `read -r -t 10 -p 'prompt: ' var` and provide defaults on timeout.
- [BCS1104] Set SSH connection timeouts: `ssh -o ConnectTimeout=10 -o BatchMode=yes` and curl timeouts: `curl --connect-timeout 10 --max-time 60`.
- [BCS1104] Create reusable timeout wrapper functions that handle exit codes via case statement: 124 (timeout), 125 (timeout failed), default (command failed).
## Exponential Backoff
- [BCS1105] Use exponential backoff `sleep $((2 ** attempt))` for retries; never use fixed delays which fail to reduce load on struggling services.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay ||:`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Structure retry loops with attempt counter and max_attempts check: `while ((attempt <= max_attempts)); do ... attempt+=1; done`.
- [BCS1105] Validate success conditions beyond just exit code; check output validity: `[[ -s "$temp_file" ]]` for non-empty results.
- [BCS1105] Never retry immediately in a tight loop (`while ! curl "$url"; do :; done`); this floods failing services.


---


**Rule: BCS1200**

## Code Style & Best Practices - Rulets
## Code Formatting
- [BCS1201] Use 2 spaces for indentation (NOT tabs) and maintain consistent indentation throughout.
- [BCS1201] Keep lines under 100 characters when practical; long file paths and URLs can exceed this limit when necessary.
- [BCS1201] Use line continuation with `\` for long commands.
## Comments
- [BCS1202] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT (which the code already shows).
- [BCS1202] Document intentional deviations, non-obvious business rules, edge cases, and why specific approaches were chosen: `# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile integration`.
- [BCS1202] Avoid commenting simple variable assignments, obvious conditionals, standard patterns, or self-explanatory code.
- [BCS1202] Use standardized emoticons only: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error).
## Blank Lines
- [BCS1203] Use one blank line between functions to create visual separation.
- [BCS1203] Use one blank line between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1203] Place blank lines before and after multi-line conditional or loop blocks; avoid multiple consecutive blank lines (one is sufficient).
- [BCS1203] Never use blank lines between short, related statements.
## Section Comments
- [BCS1204] Use lightweight section comments (`# Description`) without dashes or box drawing to organize code into logical groups.
- [BCS1204] Keep section comments short (2-4 words): `# Default values`, `# Derived paths`, `# Core message function`.
- [BCS1204] Place section comment immediately before the group it describes, followed by a blank line after the group.
- [BCS1204] Reserve 80-dash separators for major script divisions only; use simple section comments for grouping related variables, functions, or logical blocks.
## Language Best Practices
- [BCS1205] Always use `$()` instead of backticks for command substitution: `var=$(command)` not ``var=`command` ``.
- [BCS1205] Prefer shell builtins over external commands for 10-100x performance improvement and better reliability: `$((x + y))` not `$(expr "$x" + "$y")`.
- [BCS1205] Use builtin alternatives: `${var##*/}` for basename, `${var%/*}` for dirname, `${var^^}` for uppercase, `${var,,}` for lowercase, `[[` instead of `[` or `test`.
- [BCS1205] Avoid external commands (`expr`, `basename`, `dirname`, `tr` for case conversion, `seq`) when builtins exist; builtins are guaranteed in bash and require no PATH dependency.
## Development Practices
- [BCS1206] ShellCheck compliance is compulsory for all scripts; use `#shellcheck disable=SCxxxx` only for documented exceptions with explanatory comments.
- [BCS1206] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1206] Use defensive programming: default critical variables with `: "${VERBOSE:=0}"`, validate inputs early with `[[ -n "$1" ]] || die 1 'Argument required'`, and guard against unset variables with `set -u`.
- [BCS1206] Minimize subshells, use built-in string operations over external commands, batch operations when possible, and use process substitution over temp files for performance.
- [BCS1206] Make functions testable with dependency injection, support verbose/debug modes, and return meaningful exit codes for testing support.
## Emoticons
- [BCS1207] Standard severity icons: `◉` (info), `⦿` (debug), `▲` (warn), `✗` (error), `✓` (success).
- [BCS1207] Extended icons: `⚠` (caution/important), `☢` (fatal/critical), `↻` (redo/retry/update), `◆` (checkpoint), `●` (in progress), `○` (pending), `◐` (partial).
- [BCS1207] Action icons: `▶` (start/execute), `■` (stop), `⏸` (pause), `⏹` (terminate), `⚙` (settings/config), `☰` (menu/list).
- [BCS1207] Directional icons: `→` (forward/next), `←` (back/previous), `↑` (up/upgrade), `↓` (down/downgrade), `⇄` (swap), `⇅` (sync), `⟳` (processing/loading), `⏱` (timer/duration).


---


**Rule: BCS1200**

## Style & Development - Rulets
## Code Formatting
- [BCS1201] Use 2 spaces for indentation, never tabs; maintain consistent indentation throughout the script.
- [BCS1201] Keep lines under 100 characters when practical; long file paths and URLs may exceed this limit when necessary.
- [BCS1201] Use line continuation with `\` for long commands that exceed the line length limit.
## Comments
- [BCS1202] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT the code already shows.
- [BCS1202] Good comment patterns: explain non-obvious business rules, document intentional deviations, clarify complex logic, note why specific approaches were chosen, warn about subtle gotchas.
- [BCS1202] Avoid commenting simple variable assignments, obvious conditionals, standard patterns documented in the style guide, or self-explanatory code with good naming.
- [BCS1202] Use standardized documentation icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error); avoid other emoticons unless justified.
- [BCS1202] Use 80-dash separator lines (`# ----...----`) only for major script divisions.
## Blank Lines
- [BCS1203] Use one blank line between functions, between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1203] Add blank lines before and after multi-line conditional or loop blocks.
- [BCS1203] Avoid multiple consecutive blank lines (one is sufficient); no blank line needed between short, related statements.
## Section Comments
- [BCS1204] Use simple `# Description` format for section comments (no dashes, no box drawing); keep them short and descriptive (2-4 words typically).
- [BCS1204] Place section comment immediately before the group it describes; follow the group with a blank line before the next section.
- [BCS1204] Common section comment patterns: `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`, `# Validation functions`.
- [BCS1204] Reserve 80-dash separators for major script divisions only; use lightweight section comments for organizing code into logical groups.
## Language Practices
- [BCS1205] Always use `$()` instead of backticks for command substitution: `var=$(command)` not `` var=`command` ``.
- [BCS1205] Prefer shell builtins over external commands for performance (10-100x faster) and reliability: `$((x + y))` not `$(expr $x + $y)`, `${var^^}` not `$(echo "$var" | tr a-z A-Z)`.
- [BCS1205] Common builtin replacements: `${path##*/}` for basename, `${path%/*}` for dirname, `${var^^}` or `${var,,}` for case conversion, `[[ ]]` for test/`[`, brace expansion `{1..10}` for seq.
## Development Practices
- [BCS1206] ShellCheck is compulsory for all scripts; use `#shellcheck disable=...` only for documented exceptions with explanatory comments.
- [BCS1206] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1206] Use defensive programming: provide default values for critical variables with `: "${VAR:=default}"`, validate inputs early, always use `set -u`.
- [BCS1206] Minimize subshells, use built-in string operations over external commands, batch operations when possible, use process substitution over temp files.
- [BCS1206] Make functions testable: use dependency injection for external commands, support verbose/debug modes, return meaningful exit codes.
## Debugging
- [BCS1207] Declare debug flag with default: `declare -i DEBUG=${DEBUG:-0}` and enable trace mode conditionally: `((DEBUG)) && set -x ||:`.
- [BCS1207] Set enhanced PS4 for better trace output: `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '`.
- [BCS1207] Implement conditional debug function: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS1207] Enable debug mode at runtime: `DEBUG=1 ./script.sh`.
## Dry-Run Pattern
- [BCS1208] Declare dry-run flag: `declare -i DRY_RUN=0` and parse from command-line: `-n|--dry-run) DRY_RUN=1 ;;`.
- [BCS1208] Pattern structure: check `((DRY_RUN))` at function start, display preview message with `[DRY-RUN]` prefix using `info`, return 0 early without performing actual operations.
- [BCS1208] Show detailed preview of what would happen: `info '[DRY-RUN] Would install:' "  $BIN_DIR/tool1" "  $BIN_DIR/tool2"`.
- [BCS1208] Dry-run maintains identical control flow (same function calls, same logic paths) to verify logic without side effects.
## Testing Support
- [BCS1209] Use dependency injection for testing: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` then override in tests: `FIND_CMD() { echo 'mocked_file.txt'; }`.
- [BCS1209] Implement test mode flag: `declare -i TEST_MODE="${TEST_MODE:-0}"` with conditional behavior for test data directories and disabled destructive operations.
- [BCS1209] Implement assert function comparing expected vs actual values with descriptive failure messages: `assert "$expected" "$actual" 'message'`.
- [BCS1209] Test runner pattern: find all `test_*` functions with `declare -F | awk '$3 ~ /^test_/ {print $3}'`, execute each, track passed/failed counts, exit with `((failed == 0))`.
## Progressive State Management
- [BCS1210] Declare all boolean flags at the top with initial values, then progressively adjust based on runtime conditions.
- [BCS1210] Separate user intent tracking from runtime state: `BUILTIN_REQUESTED=1` (what user asked for) vs `INSTALL_BUILTIN=0` (what will actually happen).
- [BCS1210] Apply state changes in logical order: parse → validate → execute; never modify flags during execution phase.
- [BCS1210] Disable features when prerequisites fail: `((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0`.
- [BCS1210] Execute actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin ||:` runs only if flag remains enabled after all checks.
#fin
