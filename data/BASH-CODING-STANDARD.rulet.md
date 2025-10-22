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
- [BCS0102] Use one of three allowable shebangs: `#!/bin/bash` (most portable), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability via PATH).
- [BCS0102] Place the shebang on the first line, followed by optional global `#shellcheck` directives with explanatory comments, then a brief description comment, then `set -euo pipefail` as the first command.
## Strict Mode and Shell Options
- [BCS0101] Always use `set -euo pipefail` as the first command after shebang/comments/shellcheck (Step 4) to enable strict error handling before any other commands execute.
- [BCS0105] Always use `shopt -s inherit_errexit shift_verbose extglob` for critical error propagation, shift error detection, and extended pattern matching.
- [BCS0105] Choose either `shopt -s nullglob` (for arrays/loops - unmatched globs expand to empty) or `shopt -s failglob` (for strict scripts - unmatched globs cause error); never rely on default bash behavior where unmatched globs remain as literal strings.
- [BCS0105] Use `shopt -s globstar` optionally when recursive `**` matching is needed, but beware performance impact on deep directory trees.
## Script Metadata
- [BCS0103] Always declare standard metadata variables immediately after `shopt` settings (Step 6): `VERSION='1.0.0'`, `SCRIPT_PATH=$(realpath -- "$0")`, `SCRIPT_DIR=${SCRIPT_PATH%/*}`, `SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Use `realpath -- "$0"` (not `readlink`) to resolve SCRIPT_PATH reliably; this is the canonical BCS approach and supports loadable builtins for maximum performance.
- [BCS0103] Make metadata variables readonly as a group after all assignments: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0103] Derive SCRIPT_DIR and SCRIPT_NAME from SCRIPT_PATH using parameter expansion (`${SCRIPT_PATH%/*}` and `${SCRIPT_PATH##*/}`) rather than external commands.
## Global Variable Declarations
- [BCS0101] Declare all global variables up front (Step 7) with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Group all global declarations together after metadata and before color definitions; never scatter declarations throughout the file.
- [BCS0101] For variables modified during argument parsing, declare them mutable first, then make readonly after parsing is complete.
## Color Definitions
- [BCS0101] Conditionally define color codes (Step 8) based on terminal detection: `if [[ -t 1 && -t 2 ]]; then readonly -- RED=$'\033[0;31m' ...; else readonly -- RED='' ...; fi`.
- [BCS0101] Skip color definitions entirely if your script doesn't use colored output.
## Function Organization Pattern
- [BCS0107,BCS0101] Always organize functions bottom-up in 7 layers: (1) messaging functions, (2) documentation functions, (3) helper/utility functions, (4) validation functions, (5) business logic functions, (6) orchestration functions, (7) `main()` function.
- [BCS0107] Each function can only call functions defined above it (earlier in the file); dependencies flow downward, never upward.
- [BCS0107] Place all messaging functions first (`_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`) as the lowest-level primitives used by everything.
- [BCS0107] Define business logic functions after utilities and validation, so they can safely call lower-layer functions.
## Main Function and Script Invocation
- [BCS0101] Use a `main()` function (Step 11) for scripts over ~200 lines; place it last before script invocation.
- [BCS0101] Parse command-line arguments inside `main()`, make variables readonly after parsing, then execute workflow in clear sequence.
- [BCS0101] Invoke main with `main "$@"` (Step 12), always quoting `"$@"` to preserve argument array properly.
## End Marker
- [BCS0101] Always end scripts with `#fin` or `#end` marker (Step 13) to visually confirm the file is complete and not truncated.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be both executed and sourced, define all library functions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`.
- [BCS010201] Only apply `set -euo pipefail` and `shopt` settings in the executable section (after the early return), never when sourced, to avoid modifying the caller's shell environment.
- [BCS010201] Guard metadata initialization with `if [[ ! -v VARIABLE ]]` to allow safe re-sourcing without errors.
- [BCS010201] Export functions with `declare -fx` if they need to be available to subshells.
## FHS Compliance
- [BCS0104] Design installation scripts to follow Filesystem Hierarchy Standard (FHS): use `$PREFIX/bin/` for executables, `$PREFIX/share/` for data, `$PREFIX/lib/` for libraries, `$PREFIX/etc/` or `/etc/` for configuration.
- [BCS0104] Support PREFIX customization via environment variable: `PREFIX="${PREFIX:-/usr/local}"` to enable user install, local install, and system install scenarios.
- [BCS0104] Search multiple FHS locations when loading resources: script directory (development), `/usr/local/share/` (local install), `/usr/share/` (system install), `${XDG_DATA_HOME:-$HOME/.local/share}/` (user install).
- [BCS0104] For user-specific files, follow XDG Base Directory specification: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME` with appropriate fallbacks.
## File Extensions
- [BCS0106] Use no extension for executables that will be in PATH; use `.sh` extension for executables in local/project directories.
- [BCS0106] Always use `.sh` extension for libraries; libraries should not be executable unless they're dual-purpose scripts.
## Complete Structure Summary
- [BCS0101] Follow the mandatory 13-step structure: (1) shebang, (2) shellcheck directives (optional), (3) brief description, (4) `set -euo pipefail`, (5) `shopt` settings, (6) script metadata, (7) global variables, (8) color definitions (optional), (9) utility functions, (10) business logic functions, (11) `main()` function, (12) script invocation `main "$@"`, (13) end marker `#fin`.
- [BCS0101] Scripts under ~200 lines may skip the `main()` function (steps 11-12) and run directly, but all other steps remain required.
## Anti-Patterns to Avoid
- [BCS010102] Never declare variables after they're used; always declare all globals up front in Step 7.
- [BCS010102] Never define business logic before utility functions; utilities must come first so business logic can call them.
- [BCS010102] Never make variables readonly before argument parsing if they need to be modified during parsing.
- [BCS010102] Never mix global declarations with function definitions; keep all declarations grouped together.
- [BCS010102] Never use `$0` directly without `realpath` for SCRIPT_PATH; relative paths and symlinks must be resolved.
## Edge Cases
- [BCS010103] Sourced library files should skip `set -e`, `main()`, and script invocation to avoid modifying caller's shell.
- [BCS010103] Scripts requiring external configuration should source config files between metadata and business logic, then make variables readonly afterward.
- [BCS010103] Scripts with cleanup requirements should define cleanup function in utilities layer, then set trap after function definition but before business logic: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS010103] Tiny scripts under ~200 lines can skip `main()` function and run business logic directly, but must still follow other structural requirements.


---


**Rule: BCS0200**

## Variable Declarations & Constants - Rulets
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


---


**Rule: BCS0300**

## Variable Expansion & Parameter Substitution - Rulets
## Default Form
- [BCS0302] Always use `"$var"` as the default form for variable expansion; only add braces when syntactically required.
- [BCS0302] Never use braces for standalone variables like `"${var}"`, `"${HOME}"`, or `"${SCRIPT_DIR}"` - use simple form `"$var"` instead.
## Parameter Expansion Operations
- [BCS0301] Use braces for parameter expansion operations: `${var##pattern}` for prefix removal, `${var%pattern}` for suffix removal, `${var:-default}` for defaults.
- [BCS0301] Use braces for substring extraction `${var:0:5}`, pattern substitution `${var//old/new}`, and case conversion `${var,,}` or `${var^^}`.
- [BCS0301] Use braces for array operations: `${array[index]}` for element access, `${array[@]}` for all elements, `${#array[@]}` for length.
- [BCS0301] Use braces for special parameter expansion: `${@:2}` for positional parameters from 2nd onward, `${10}` for parameters beyond $9, `${!var}` for indirect expansion.
## Path Concatenation
- [BCS0302] Use `"$var"/path` or `"$var/path"` for path concatenation with separators - quotes handle concatenation without requiring braces.
- [BCS0302] Never use `"${PREFIX}"/bin` or `"${PREFIX}/bin"` when a separator (slash) is present - use `"$PREFIX"/bin` or `"$PREFIX/bin"` instead.
- [BCS0302] The pattern `"$var"/literal/"$var"` (mixing quoted variables with unquoted literals/separators) is preferred in assignments, conditionals, and command arguments.
## Variable Concatenation
- [BCS0302] Use braces for variable concatenation without separators: `"${var1}${var2}${var3}"` or `"${prefix}suffix"` when immediately followed by alphanumeric characters.
- [BCS0302] Use braces to prevent ambiguity when next character is alphanumeric: `"${var}_suffix"` prevents `$var_suffix` interpretation, `"${prefix}123"` prevents `$prefix123` interpretation.
- [BCS0302] No braces needed when separator is present: `"$var-suffix"`, `"$var.suffix"`, `"$var/path"` - the separator naturally delimits.
## Strings and Messages
- [BCS0302] Use simple form in echo/info strings: `echo "Installing to $PREFIX/bin"` and `info "Found $count files"` - separators (spaces, slashes) make braces unnecessary.
- [BCS0302] Never use braces in string interpolation when separators are present: `echo "Binary: $BIN_DIR/file"` not `echo "Binary: ${BIN_DIR}/file"`.
## Conditionals
- [BCS0302] Use simple form in conditionals: `[[ -d "$path" ]]`, `[[ -f "$SCRIPT_DIR"/file ]]`, `if [[ "$var" == 'value' ]]` - braces add unnecessary noise.
## Rationale
- [BCS0302] Braces add visual noise without providing value when not required; using them only when necessary makes code cleaner and necessary cases stand out.


---


**Rule: BCS0400**

## Quoting & String Literals - Rulets
## Core Principle
- [BCS0400] Use single quotes (`'...'`) for static string literals; use double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.
## Static Strings and Constants
- [BCS0401] Always use single quotes for string literals that contain no variables: `info 'Checking prerequisites...'` not `info "Checking prerequisites..."`.
- [BCS0401] Use single quotes for SQL queries, regex patterns, and shell commands stored as strings to prevent accidental variable expansion: `regex='^\$[0-9]+\.[0-9]{2}$'`.
- [BCS0401] Single quotes require no escaping of special characters like `$`, `` ` ``, `\`, `!` - what you see is what you get.
## One-Word Literals Exception
- [BCS0402] Literal one-word values containing only alphanumeric, underscore, hyphen, dot, or slash may be left unquoted in assignments and conditionals, but quoting is more defensive: `VAR=value` or `VAR='value'`.
- [BCS0402] Never leave unquoted: values with spaces, wildcards (`*.txt`), special characters (`@`, `$`), empty strings, values starting with hyphen in conditionals, or any value with `()`, quotes, or backslashes.
- [BCS0402] Always quote variables even when concatenating with literals: `FILE="$basename.txt"` not `FILE=$basename.txt`.
## Strings with Variables
- [BCS0403] Use double quotes when strings contain variables that need expansion: `info "Installing to $PREFIX/bin"` or `echo "Processed $count files"`.
- [BCS0403] Combine double quotes with nested single quotes to protect literal quotes: `die 2 "Unknown option '$1'"`.
## Command Substitution
- [BCS0405] Use double quotes when including command substitution: `echo "Current time: $(date +%T)"` or `VERSION="$(git describe --tags)"`.
## Variables in Conditionals
- [BCS0406] Always quote variables in test expressions to prevent word splitting and glob expansion: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS0406] Quote variables in all file tests (`-f`, `-d`, `-r`, `-w`, `-x`), string comparisons, and integer comparisons: `[[ "$count" -eq 0 ]]`.
- [BCS0406] Static comparison values follow normal quoting rules: single quotes for multi-word literals (`[[ "$msg" == 'hello world' ]]`), optional quotes for one-word literals (`[[ "$action" == start ]]` or `[[ "$action" == 'start' ]]`).
- [BCS0406] For glob pattern matching, quote the variable but leave the pattern unquoted: `[[ "$filename" == *.txt ]]`; for literal matching, quote both: `[[ "$filename" == '*.txt' ]]`.
- [BCS0406] For regex matching with `=~`, quote the variable but leave the pattern unquoted: `[[ "$email" =~ ^[a-z]+@[a-z]+$ ]]` or store pattern in variable: `[[ "$input" =~ $pattern ]]`.
## Array Expansions
- [BCS0407] Always quote array expansions: `"${array[@]}"` for separate elements, `"${array[*]}"` for single concatenated string.
- [BCS0407] Use `"${array[@]}"` for iteration, function arguments, command arguments, and array copying: `for item in "${array[@]}"`.
- [BCS0407] Use `"${array[*]}"` for display, logging, or creating CSV with custom IFS: `IFS=','; csv="${array[*]}"`.
- [BCS0407] Unquoted array expansions undergo word splitting and lose empty elements; always quote to preserve element boundaries: `copy=("${original[@]}")` not `copy=(${original[@]})`.
## Here Documents
- [BCS0408] Use single quotes on delimiter for literal content (no expansion): `cat <<'EOF'` keeps `$VAR` and `$(command)` literal.
- [BCS0408] Use unquoted delimiter for variable expansion: `cat <<EOF` expands `$VAR` and `$(command)`.
## Echo and Printf
- [BCS0409] Use single quotes for static strings in echo/printf: `echo 'Installation complete'` not `echo "Installation complete"`.
- [BCS0409] Use double quotes when echo/printf contains variables: `echo "Installing to $PREFIX/bin"` or `printf 'Found %d files in %s\n' "$count" "$dir"`.
## Anti-Patterns
- [BCS0411] Never use double quotes for static strings with no variables: `info "Starting process..."` is wrong, use `info 'Starting process...'`.
- [BCS0411] Never leave variables unquoted in conditionals, assignments, or commands: `[[ -f $file ]]`, `rm $file`, `echo $result` are all wrong.
- [BCS0411] Never use braces when not required: `echo "${HOME}/bin"` should be `echo "$HOME/bin"`; braces only needed for `${var##pattern}`, `${var:-default}`, `${array[@]}`, `${var1}${var2}`.
- [BCS0411] Never mix quote styles inconsistently: pick single quotes for all static strings, double quotes for all strings with variables.
- [BCS0411] Never use unquoted glob patterns in variables: `pattern='*.txt'; echo $pattern` expands to all .txt files; use `echo "$pattern"` to preserve literal.
- [BCS0411] Never use quoted delimiter when variables needed in heredoc: `cat <<"EOF"` with `$VAR` inside prevents expansion; use `cat <<EOF`.
## Utility Functions
- [BCS0412] Use parameter expansion for string trimming: `v="${v#"${v%%[![:blank:]]*}"}"; v="${v%"${v##*[![:blank:]]}"}"` removes leading/trailing whitespace.
- [BCS0413] Display declared variables without the declare statement prefix: `decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }`.
- [BCS0414] Create pluralization helper that returns 's' for non-singular counts: `s() { (( ${1:-1} == 1 )) || echo -n 's'; }` for use like `echo "$count file$(s "$count")"`.


---


**Rule: BCS0500**

## Arrays - Rulets
## Array Declaration
- [BCS0501] Always declare arrays explicitly with `declare -a array=()` for indexed arrays to signal intent, ensure type safety, and prevent accidental scalar assignment.
- [BCS0501] Use `local -a array=()` for arrays within functions to prevent global scope pollution and maintain proper variable scoping.
- [BCS0501] Initialize arrays with elements using parentheses: `declare -a colors=('red' 'green' 'blue')` for immediate population.
## Array Expansion and Iteration
- [BCS0501] Always quote array expansion with `"${array[@]}"` to preserve element boundaries and prevent word splitting on spaces or special characters.
- [BCS0501] Never use unquoted array expansion `${array[@]}` or `"$array"` without `[@]`; the former breaks with spaces, the latter only processes the first element.
- [BCS0501] Use `"${array[@]}"` not `"${array[*]}"` for iteration; `[@]` expands each element as a separate word, `[*]` treats all elements as a single string.
## Array Modification
- [BCS0501] Append elements with `+=` operator: `array+=("element")` for single items, `array+=("item1" "item2")` for multiple items, or `array+=("${other_array[@]}")` to merge arrays.
- [BCS0501] Get array length with `${#array[@]}`; check if empty with `((${#array[@]} == 0))` or set default if empty with `((${#array[@]})) || array=('default')`.
- [BCS0501] Delete array elements with `unset 'array[index]'` (always quote the subscript), clear entire array with `array=()`, or access last element with `${array[-1]}` (Bash 4.3+).
## Reading Data into Arrays
- [BCS0501] Use `readarray -t array < <(command)` or `mapfile -t array < <(command)` to capture command output into arrays; `-t` removes trailing newlines, `< <()` avoids subshell issues.
- [BCS0501] Split strings into arrays with `IFS='delimiter' read -ra array <<< "$string"` for delimiter-separated values like CSV or PATH components.
- [BCS0501] Read files into arrays with `readarray -t lines < file.txt` to process one line per element, preserving spaces and special characters.
## Safe List Handling
- [BCS0502] Always use arrays to store lists of files, command arguments, or any collection where elements may contain spaces, special characters, or wildcards; string-based lists inevitably fail with edge cases.
- [BCS0502] Never use string concatenation for lists like `files="file1 file2 file3"`; word splitting breaks iteration and command arguments when elements contain spaces.
- [BCS0502] Build commands dynamically with arrays: `cmd_args=('-o' 'output.txt' '--verbose')` then execute with `"${cmd_args[@]}"` to safely handle arguments with spaces or special characters.
## Command Argument Construction
- [BCS0502] Construct commands with conditional arguments using arrays: initialize with `cmd=('base' 'args')`, add conditionally with `((flag)) && cmd+=('--option')`, execute with `"${cmd[@]}"`.
- [BCS0502] Build complex commands like `find` or `rsync` in arrays, adding options conditionally: `find_args=("$dir" '-type' 'f')`, then `[[ -n "$pattern" ]] && find_args+=('-name' "$pattern")`, finally `find "${find_args[@]}"`.
- [BCS0502] Never use `eval` or string concatenation for command building; arrays eliminate quoting issues and security risks associated with string-based command construction.
## Array Patterns
- [BCS0501] Collect dynamic arguments during parsing: `declare -a files=()`, then `files+=("$arg")` in parse loop, finally iterate with `for file in "${files[@]}"`.
- [BCS0501] Check array membership by iterating elements: `for element; do [[ "$element" == "$search" ]] && return 0; done; return 1` in a function receiving array as arguments.
- [BCS0501] Avoid iterating with indices `for i in "${!array[@]}"; do echo "${array[$i]}"; done` when you can iterate values directly with `for value in "${array[@]}"`.
## Glob and File Collection
- [BCS0502] Collect glob results directly into arrays: `files=(*.txt)` safely captures matching files; always use `shopt -s nullglob` to handle zero matches gracefully.
- [BCS0502] Never parse `ls` output into strings with `files=$(ls *.txt)`; use glob into array `files=(*.txt)` or `readarray -t files < <(find ...)` for complex searches.
- [BCS0502] Use `while IFS= read -r -d '' file; do array+=("$file"); done < <(find ... -print0)` for null-delimited file collection when filenames may contain newlines.
## Passing Arrays to Functions
- [BCS0502] Pass arrays to functions with `func "${array[@]}"` and receive with `local -a items=("$@")` to preserve all elements as separate arguments.
- [BCS0502] Return arrays from functions by printing elements with `printf '%s\n' "${array[@]}"` and capture with `readarray -t result < <(func)`.
- [BCS0502] Never pass arrays as single-quoted strings; always expand with `"${array[@]}"` so each element becomes a separate function argument.
## Array Anti-Patterns
- [BCS0501,BCS0502] Never use unquoted expansion `for item in ${array[@]}` or single-element reference `for item in "$array"`; both break safe iteration and element preservation.
- [BCS0502] Avoid IFS manipulation for splitting `IFS=','; for item in $string; do ...` when you can use `IFS=',' read -ra array <<< "$string"` followed by array iteration.
- [BCS0502] Never build file lists with string concatenation or command substitution into strings; word splitting destroys filenames with spaces and makes commands fail.
## Advanced Array Operations
- [BCS0502] Merge multiple arrays with `combined=("${arr1[@]}" "${arr2[@]}" "${arr3[@]}")` to create a new array containing all elements from source arrays.
- [BCS0502] Extract array slices with `"${array[@]:start:length}"` syntax: `"${array[@]:2:4}"` returns 4 elements starting at index 2.
- [BCS0502] Handle empty arrays safely; `for item in "${empty[@]}"` performs zero iterations without errors, and empty arrays pass zero arguments to functions.
## Key Principles
- [BCS0501,BCS0502] Arrays are the only safe way to handle lists in Bash; they preserve element boundaries, prevent word splitting, and eliminate glob expansion issues that plague string-based lists.
- [BCS0502] Always quote array expansion as `"${array[@]}"` never `${array[@]}` or `"${array[*]}"` to ensure each element is treated as a separate, intact word during iteration or argument passing.
- [BCS0502] Use arrays for all collections: file lists, command arguments, options, configuration values; string-based lists will fail with spaces, quotes, wildcards, or special characters.


---


**Rule: BCS0600**

## Functions - Rulets

## Function Definition Pattern

- [BCS0601] Use single-line format for simple operations: `vecho() { ((VERBOSE)) || return 0; _msg "$@"; }`.
- [BCS0601] Use multi-line format with local variables for complex functions: declare locals first, then function body, then explicit return.

## Function Naming

- [BCS0602] Always use lowercase with underscores for function names to match shell conventions: `my_function()`, `process_log_file()`.
- [BCS0602] Use leading underscore for private/internal functions: `_my_private_function()`, `_validate_input()`.
- [BCS0602] Never use CamelCase or UPPER_CASE for function names; this can be confused with variables or commands.
- [BCS0602] Never override built-in commands without good reason; if you must wrap built-ins, use a different name like `change_dir()` instead of `cd()`.
- [BCS0602] Never use special characters like dashes in function names: `my-function()` creates issues in some contexts.

## Main Function

- [BCS0603] Always include a `main()` function for scripts longer than approximately 200 lines to improve organization, testability, and maintainability.
- [BCS0603] Place `main "$@"` at the bottom of the script, just before the `#fin` marker, to ensure all helper functions are defined first.
- [BCS0603] Parse command-line arguments inside `main()` using local variables, not outside it with globals: `local -i verbose=0; while (($#)); do case $1 in -v) verbose=1 ;; esac; shift; done`.
- [BCS0603] Make parsed option variables readonly after parsing to prevent accidental modification: `readonly -- verbose dry_run output_dir`.
- [BCS0603] Use `main()` as the orchestrator that coordinates work by calling helper functions in the right order, not by doing the heavy lifting itself.
- [BCS0603] Return appropriate exit codes from `main()`: 0 for success, non-zero for errors.
- [BCS0603] Use `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` pattern to make scripts sourceable for testing without automatic execution.
- [BCS0603] Always pass all arguments to main with `main "$@"`, never call it without arguments.

## Function Export

- [BCS0604] Export functions with `declare -fx` when they need to be available in subshells or when creating sourceable libraries.
- [BCS0604] Group function exports together for readability: `declare -fx grep find` for multiple related functions.

## Production Optimization

- [BCS0605] Remove unused utility functions once a script is mature and ready for production: if `yn()`, `decp()`, `trim()`, `s()` are not used, delete them.
- [BCS0605] Remove unused global variables that are not referenced: `PROMPT`, `DEBUG`, color variables if terminal output is not used.
- [BCS0605] Remove unused messaging functions that your script doesn't call; a simple script may only need `error()` and `die()`, not the full messaging suite.
- [BCS0605] Keep only the functions and variables your script actually needs to reduce script size, improve clarity, and eliminate maintenance burden.

## Function Organization

- [BCS0600,BCS0603] Organize functions bottom-up: messaging functions first (lowest level), then helpers, then business logic, with `main()` last (highest level).
- [BCS0600,BCS0603] This bottom-up organization ensures each function can safely call previously defined functions and readers understand primitives before composition.


---


**Rule: BCS0700**

## Control Flow - Rulets

## Conditionals

- [BCS0701] Always use `[[ ]]` for string and file tests, `(())` for arithmetic tests: `[[ -f "$file" ]]` for files, `((count > 0))` for numbers.
- [BCS0701] Never use `[ ]` (old test syntax) - it requires quotes, doesn't support pattern matching, and lacks logical operators inside brackets.
- [BCS0701] Quote variables in `[[ ]]` tests even though not strictly required: `[[ "$var" == "value" ]]` for clarity and consistency.
- [BCS0701] Use pattern matching in `[[ ]]` with `==` for globs and `=~` for regex: `[[ "$file" == *.txt ]]` or `[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]`.
- [BCS0701] Use short-circuit evaluation for concise conditionals: `[[ -f "$file" ]] && source "$file"` or `((VERBOSE)) || return 0`.
- [BCS0701] Never use `-a` and `-o` operators inside `[ ]` - they are deprecated and fragile; use `[[ ]]` with `&&` and `||` instead.

## Case Statements

- [BCS0702] Use case statements for multi-way branching based on pattern matching a single value, not for testing multiple variables or complex conditions.
- [BCS0702] Choose compact format (single-line actions with aligned `;;`) for simple cases like argument parsing; use expanded format (multi-line actions with `;;` on separate line) for complex logic.
- [BCS0702] Always quote the test variable but don't quote literal patterns: `case "$filename" in` not `case $filename in`, and `*.txt)` not `"*.txt")`.
- [BCS0702] Always include default case `*)` to handle unexpected values explicitly and prevent silent failures.
- [BCS0702] Use alternation with `|` for multiple patterns: `-h|--help|help)` action `;;` instead of separate cases.
- [BCS0702] Enable `shopt -s extglob` for advanced patterns: `@(start|stop|restart)` for exactly one, `!(*.tmp|*.bak)` for exclusion, `+([0-9])` for one or more digits.
- [BCS0702] Align actions consistently at same column (typically 14-18 characters) in compact format for visual clarity.
- [BCS0702] Never attempt fall-through patterns - Bash doesn't support them; use explicit alternation: `200|201|204)` not separate cases expecting fall-through.
- [BCS0702] Use case for pattern matching (file extensions, option flags, action routing), use if/elif for complex conditions involving multiple variables or ranges.

## Loops

- [BCS0703] Always quote arrays in for loops: `for item in "${array[@]}"` not `for item in ${array[@]}` to preserve element boundaries with spaces.
- [BCS0703] Use for loops for arrays, globs, and known ranges; use while loops for reading input, argument parsing, and condition-based iteration.
- [BCS0703] Enable `shopt -s nullglob` before glob loops to handle zero matches gracefully: `for file in *.txt` expands to nothing if no matches instead of literal `*.txt`.
- [BCS0703] Use C-style for loops for numeric iteration: `for ((i=1; i<=10; i+=1))` not `for i in $(seq 1 10)` to avoid external commands.
- [BCS0703] Read files line-by-line with `while IFS= read -r line; do ... done < "$file"` preserving backslashes and avoiding word splitting.
- [BCS0703] Use `break N` to exit N levels of nested loops explicitly: `break 2` breaks both inner and outer loop for clarity.
- [BCS0703] Use `continue` to skip remaining loop body and proceed to next iteration for early conditional filtering.
- [BCS0703] Use `while ((1))` for infinite loops (fastest option, 15-22% faster than `while true`), or `while :` for POSIX compatibility.
- [BCS0703] Never parse `ls` output - use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
- [BCS0703] Use process substitution for null-delimited input: `while IFS= read -r -d '' file; do ... done < <(find . -print0)` to handle filenames with newlines.
- [BCS0703] Avoid redundant comparisons in arithmetic context: use `while (($#))` not `while (($# > 0))` since non-zero is truthy.

## Pipes to While Loops

- [BCS0704] Never pipe commands to while loops - pipes create subshells where variable assignments don't persist outside the loop; use process substitution `< <(command)` instead.
- [BCS0704] Use `readarray -t array < <(command)` when collecting command output into array - simpler and more efficient than while loop.
- [BCS0704] Use here-string `<<< "$variable"` when input is already in a variable: `while read -r line; done <<< "$input"`.
- [BCS0704] The pipe subshell issue is silent - counters stay at 0, arrays stay empty, flags stay unset - no error messages, script continues with wrong values.
- [BCS0704] With `set -e`, command failures in process substitution are detected properly: `< <(failing_command)` exits script, but pipe may not.

## Arithmetic Operations

- [BCS0705] Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity: `declare -i count=0 total max_retries=3`.
- [BCS0705] Use `i+=1` or `((i+=1))` for increment; never use `((i++))` - it returns the original value and fails with `set -e` when i=0.
- [BCS0705] Use `((++i))` only if you need the incremented value returned (pre-increment); `((i+=1))` always returns 0 (success) regardless of value.
- [BCS0705] Use `(())` for arithmetic assignments without $ on variables inside: `((result = x * y + z))` not `((result = $x * $y + $z))`.
- [BCS0705] Use `(())` for arithmetic conditionals not `[[ ]]` with `-gt/-lt`: `((count > 10))` not `[[ "$count" -gt 10 ]]` for clarity and conciseness.
- [BCS0705] Never use `expr` command for arithmetic - it's slow and external; use `$(())` or `(())` instead: `result=$((i + j))`.
- [BCS0705] Remember Bash only does integer arithmetic - division truncates: `((result = 10 / 3))` gives 3 not 3.333; use `bc` or `awk` for floating-point.
- [BCS0705] Use ternary operator in arithmetic for conditional assignment: `((max = a > b ? a : b))` (Bash 5.2+).


---


**Rule: BCS0800**

## Error Handling - Rulets

## Exit on Error Configuration

- [BCS0801] Always use `set -euo pipefail` immediately after the shebang to enable strict error handling: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` exits if any command in a pipeline fails.
- [BCS0801] Strongly recommend `shopt -s inherit_errexit` to make command substitution inherit errexit behavior: `output=$(failing_command)` will exit with set -e.
- [BCS0801] Handle expected failures explicitly using `command || true`, conditional checks `if command; then`, or temporarily disable errexit with `set +e; risky_command; set -e`.
- [BCS0801] Check if optional variables exist before using them: `[[ -n "${OPTIONAL_VAR:-}" ]]` prevents exit on undefined variable.

## Standard Exit Codes

- [BCS0802] Use standard exit codes consistently: `0` for success, `1` for general error, `2` for misuse/missing argument, `22` for invalid argument (EINVAL), `5` for I/O error.
- [BCS0802] Implement a standard `die()` function: `die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }` for consistent error exits with optional messages.
- [BCS0802] Define exit codes as readonly constants for readability: `readonly -i ERR_CONFIG=3 ERR_NETWORK=4` then use `die "$ERR_CONFIG" 'Failed to load config'`.
- [BCS0802] Never use exit codes above 125 for custom codes to avoid conflicts with signal codes (128+n) and shell reserved codes.

## Trap Handling for Cleanup

- [BCS0803] Always implement a `cleanup()` function with trap for resource cleanup: `trap 'cleanup $?' SIGINT SIGTERM EXIT` ensures cleanup runs on all exit paths.
- [BCS0803] Disable trap at the start of cleanup function to prevent recursion: `trap - SIGINT SIGTERM EXIT` must be first line in `cleanup()`.
- [BCS0803] Preserve the original exit code in cleanup: `cleanup() { local -i exitcode=${1:-0}; trap - SIGINT SIGTERM EXIT; # cleanup; exit "$exitcode"; }`.
- [BCS0803] Install traps early before creating resources to prevent leaks: set `trap 'cleanup $?' EXIT` before `temp_file=$(mktemp)`.
- [BCS0803] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT` not `trap "rm -f $temp_file" EXIT`.

## Return Value Checking

- [BCS0804] Always check return values of critical operations with explicit error messages: `mv "$source" "$dest" || die 1 "Failed to move $source to $dest"`.
- [BCS0804] Use `set -o pipefail` to catch pipeline failures: without it, `cat missing_file | grep pattern` continues even if cat fails.
- [BCS0804] Check command substitution results explicitly: `output=$(command) || die 1 "Command failed"` because `set -e` doesn't catch substitution failures.
- [BCS0804] Use different patterns for different needs: `if ! command; then error; exit 1; fi` for informative errors, `command || die 1 "msg"` for concise checks, `command || { cleanup; exit 1; }` for cleanup on failure.
- [BCS0804] Handle partial failures in loops by tracking counts: increment `success_count` and `fail_count`, return non-zero if any failures occurred.

## Error Suppression

- [BCS0805] Only suppress errors when failure is expected, non-critical, and safe to ignore; always document WHY with a comment above the suppression.
- [BCS0805] Never suppress critical operations like file operations, data processing, system configuration, or security operations: `cp "$important" "$backup" 2>/dev/null || true` is dangerous.
- [BCS0805] Use `|| true` to ignore return codes while keeping stderr visible; use `2>/dev/null` to suppress error messages while checking return code; use both only when both are irrelevant.
- [BCS0805] Appropriate suppression cases: checking if commands exist `command -v optional_tool >/dev/null 2>&1`, cleanup operations `rm -f /tmp/myapp_* 2>/dev/null || true`, idempotent operations `install -d "$dir" 2>/dev/null || true`.
- [BCS0805] Verify after suppressed operations when possible: after `install -d "$dir" 2>/dev/null || true`, check `[[ -d "$dir" ]] || die 1 "Failed to create $dir"`.

## Conditional Declarations with Exit Code Handling

- [BCS0806] Append `|| :` after arithmetic conditionals to prevent false conditions from triggering `set -e` exit: `((complete)) && declare -g BLUE=$'\033[0;34m' || :`.
- [BCS0806] Prefer colon `:` over `true` for no-op fallback as it's the traditional Unix idiom and more concise: `((condition)) && action || :`.
- [BCS0806] Use `|| :` only for optional operations like conditional variable declarations, feature-gated actions, or optional logging; never for critical operations that must succeed.
- [BCS0806] For critical operations, use explicit error handling instead: `if ((flag)); then critical_operation || die 1 "Operation failed"; fi` not `((flag)) && critical_operation || :`.
- [BCS0806] Use if statements for complex conditional logic with multiple statements; use `((condition)) && action || :` only for simple one-line conditional declarations.

## Configuration and Best Practices

- [BCS0800] Configure error handling with `set -euo pipefail` before any other commands run to catch failures early.
- [BCS0801,BCS0804] Remember that `set -e` has limitations: doesn't catch pipeline failures (except last command without pipefail), commands in conditionals, commands with `||`, or command substitution without `inherit_errexit`.
- [BCS0803,BCS0805] Document all error suppression and cleanup decisions with comments explaining the rationale and why it's safe.
- [BCS0804] Provide context in error messages including what failed and with what inputs: `die 1 "Failed to move $file to $dest"` not `die 1 "Move failed"`.
- [BCS0801,BCS0804] Test error paths to ensure failures are caught correctly and cleanup runs as expected; verify both success and failure scenarios.


---


**Rule: BCS0900**

## Input/Output & Messaging - Rulets

## Color Support

- [BCS0901] Detect terminal output before enabling colors: test both stdout AND stderr with `[[ -t 1 && -t 2 ]]`, then declare color variables or set them to empty strings.
- [BCS0901] Always make color variables readonly after initialization: `readonly -- RED GREEN YELLOW CYAN NC`.
- [BCS0901] Use ANSI escape codes with `$'\033[0;31m'` syntax for color definitions, not `\e` or `\x1b`.

## Stream Separation

- [BCS0902] Always send error messages to stderr by placing `>&2` at the beginning of the command for clarity: `>&2 echo "error message"`.
- [BCS0902] Separate data output (stdout) from diagnostic messages (stderr) so scripts can be piped without mixing streams.

## Core Message Functions

- [BCS0903] Implement a private `_msg()` core function that inspects `FUNCNAME[1]` to determine the calling function and format messages with appropriate prefixes and colors automatically.
- [BCS0903] Create conditional messaging functions that respect verbosity flags: `vecho()`, `info()`, `warn()`, `success()`, and `debug()` should check `((VERBOSE))` or `((DEBUG))` before outputting.
- [BCS0903] Always make `error()` unconditional (always displays) and send to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0903] Implement `die()` with exit code as first parameter: `die() { local -i exit_code=${1:-1}; shift; (($#)) && error "$@"; exit "$exit_code"; }`.
- [BCS0903] Send all conditional messaging functions (info, warn, success, debug) to stderr with `>&2` prefix so they don't interfere with data output.
- [BCS0903] Use consistent prefixes in all messages: include `$SCRIPT_NAME` and appropriate symbols (, �, �, ).
- [BCS0903] Implement `yn()` prompt function that respects `PROMPT` flag: `((PROMPT)) || return 0` for non-interactive mode.
- [BCS0903] Declare global control flags with integer type: `declare -i VERBOSE=0 DEBUG=0 PROMPT=1`.

## _msg Function Pattern

- [BCS0903] Use `case "${FUNCNAME[1]}" in` within `_msg()` to detect calling function and set appropriate prefix/color without duplicating logic across functions.
- [BCS0903] Loop through all arguments in `_msg()` to print each on a separate line: `for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done`.

## Usage Documentation

- [BCS0904] Create help text using heredocs with `cat <<EOT` for multi-line formatted output that always displays.
- [BCS0904] Include script name, version, description, usage pattern, options with short/long forms, and examples in help text.
- [BCS0904] Reference `$SCRIPT_NAME` and `$VERSION` variables in help text for consistency.

## Echo vs Messaging Functions

- [BCS0905] Use messaging functions (`info`, `success`, `warn`, `error`) for operational status updates that should respect verbosity settings and go to stderr.
- [BCS0905] Use plain `echo` for data output (stdout) that will be captured, piped, or parsed: `result=$(get_data)`.
- [BCS0905] Use plain `echo` or `cat` for help text and documentation that must always display regardless of verbosity settings.
- [BCS0905] Use plain `echo` for structured multi-line output like reports, tables, or formatted data.
- [BCS0905] Never use messaging functions (`info`, `warn`) for data that needs to be captured or piped; they go to stderr and won't be captured by command substitution.
- [BCS0905] Use `echo` for version output and final summary results that users explicitly requested.
- [BCS0905] Use messaging functions for progress indicators during data generation (go to stderr), while actual data goes to stdout via `echo`.

## Decision Matrix

- [BCS0905] If output is operational status or diagnostics � use messaging functions to stderr.
- [BCS0905] If output is data intended for capture/piping � use `echo` to stdout.
- [BCS0905] If output should respect verbosity flags � use messaging functions.
- [BCS0905] If output must always display � use `echo` (or `error()` for critical messages).
- [BCS0905] If output needs color/formatting/symbols � use messaging functions.

## Color Management Library

- [BCS0906] For sophisticated color management, use a dedicated library with two-tier system (basic 5 variables, complete 12 variables) instead of inline declarations.
- [BCS0906] Implement basic tier with: `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN` (default to minimize namespace pollution).
- [BCS0906] Implement complete tier with basic plus: `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE` (opt-in).
- [BCS0906] Provide `color_set` function with options: `basic`, `complete`, `auto`, `always`, `never`, `verbose`, `flags`.
- [BCS0906] Use `flags` option to initialize BCS control variables: `VERBOSE`, `DEBUG`, `DRY_RUN`, `PROMPT` for _msg system integration.
- [BCS0906] Implement dual-purpose pattern (BCS010201) in color library: sourceable as library or executable for demonstration.
- [BCS0906] Auto-detect terminal by testing both stdout AND stderr: `[[ -t 1 && -t 2 ]]` before enabling colors.
- [BCS0906] Export `color_set` function with `declare -fx color_set` for use in sourced mode.

## Production Optimization

- [BCS0903,BCS0905] Remove unused messaging functions before production deployment: if script never uses `yn()`, `debug()`, or `success()`, delete them to reduce script size.
- [BCS0903] Remove unused global control flags (PROMPT, DEBUG) if the script doesn't reference them.


---


**Rule: BCS1000**

## Command-Line Arguments - Rulets

## Standard Parsing Pattern

- [BCS1001] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing; arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`.
- [BCS1001] Support both short and long options in case branches: `-v|--verbose)` pattern for user flexibility.
- [BCS1001] For options requiring arguments, always call `noarg "$@"` before shifting to validate argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`.
- [BCS1001] Place mandatory `shift` at end of loop after `esac` to advance to next argument; without this, loop runs infinitely.
- [BCS1001] For options that exit immediately (help, version), use `exit 0` and no shift is needed: `-h|--help) show_help; exit 0 ;;`.
- [BCS1001] Implement `noarg()` helper function: `noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }`.
- [BCS1001] Catch invalid options with `-*)` case before positional arguments: `die 22 "Invalid option '$1'"` using exit code 22 (EINVAL).
- [BCS1001] Collect positional arguments in default case: `*) Paths+=("$1") ;;`.

## Short Option Bundling

- [BCS1005] Support short option bundling to allow `-vvn` instead of `-v -v -n` following Unix conventions.
- [BCS1005] Use pure bash method for 68% faster performance with no external dependencies: `opt=${1:1}; new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`.
- [BCS1005] Alternative grep method (slower, external dependency): `-[amLpvqVh]*) #shellcheck disable=SC2046; set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;`.
- [BCS1005] Alternative fold method (marginally faster than grep): `-[amLpvqVh]*) set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}" ;;`.
- [BCS1005] List valid short options explicitly in bundling pattern `-[ovnVh]*` to prevent incorrect disaggregation of unknown options.
- [BCS1005] Document that options requiring arguments must be placed at end of bundle or used separately: `-vno output.txt` works (becomes `-v -n -o output.txt`), but `-von output.txt` fails.

## Version Output

- [BCS1002] Format version output as `scriptname version-number` without the word "version": `echo "$SCRIPT_NAME $VERSION"; exit 0`.
- [BCS1002] Never include the word "version" between script name and version number; this follows GNU standards.

## Argument Validation

- [BCS1003] Validate option arguments with `noarg()`: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"; }`.
- [BCS1003] Check that next argument doesn't start with `-` to catch missing arguments: `[[ ${2:0:1} != '-' ]]`.

## Parsing Location

- [BCS1004] Place argument parsing inside `main()` function rather than at top level for better testability, cleaner variable scoping, and encapsulation.
- [BCS1004] Top-level parsing is acceptable only for very simple scripts (< 200 lines) without a `main()` function.
- [BCS1004] Make variables readonly after parsing completes: `readonly -- VERBOSE DRY_RUN output_file`.

## Flag Variables

- [BCS1001] Use integer flags for boolean options: `declare -i VERBOSE=0` with `VERBOSE+=1` for stackable flags like `-vvv`.
- [BCS1001] Use compound assignments for multi-flag options: `-p|--prompt) PROMPT=1; VERBOSE=1 ;;` to enable multiple behaviors.
- [BCS1001] Test boolean flags with arithmetic: `((VERBOSE))` or `((DRY_RUN))`.

## Required Arguments Validation

- [BCS1001,BCS1004] Validate required arguments after parsing completes: `((${#files[@]} > 0)) || die 2 'No input files specified'`.
- [BCS1001,BCS1004] Check for required options: `[[ -n "$output_file" ]] || die 2 'Output file required (use -o)'`.

## Performance Considerations

- [BCS1005] Pure bash disaggregation is ~318 iter/sec vs ~190 iter/sec for grep (68% faster) with no external dependencies or shellcheck warnings.
- [BCS1005] For scripts called frequently or in tight loops, always use pure bash method for short option bundling.
- [BCS1005] grep/fold methods are acceptable when argument parsing happens once at startup and performance is not critical.

## Edge Cases

- [BCS1005] Options requiring arguments cannot be in middle of bundle; document that they should be at end, separate, or use long-form.
- [BCS1005] Use `set -- '' "${new_args[@]}" "${@:2}"` with leading empty string to handle edge case where no options are provided.
- [BCS1001] Invalid option case `-*)` must come after bundling case to catch unrecognized options properly.


---


**Rule: BCS1100**

## File Operations - Rulets

## File Testing

- [BCS1101] Always quote variables in file tests and use `[[ ]]` not `[ ]` or `test`: `[[ -f "$file" ]]` not `[[ -f $file ]]` or `[ -f "$file" ]`.
- [BCS1101] Use `-f` for regular files, `-d` for directories, `-e` for any file type existence check.
- [BCS1101] Validate file prerequisites before use: `[[ -f "$config" ]] || die 3 "Config not found: $config"` then `[[ -r "$config" ]] || die 5 "Cannot read: $config"`.
- [BCS1101] Use `-r` to test readability, `-w` for writability, `-x` for executability before attempting operations.
- [BCS1101] Test file emptiness with `-s` (true if size > 0): `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS1101] Compare file modification times with `-nt` (newer than) or `-ot` (older than): `[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"`.
- [BCS1101] Combine file tests with `&&` or `||` in single conditional: `[[ -f "$file" && -r "$file" && -s "$file" ]]`.
- [BCS1101] Always include filename in error messages for debugging: `die 2 "File not found: $file"` not `die 2 "File not found"`.

## Wildcard Expansion Safety

- [BCS1102] Always use explicit path prefix for wildcard expansion to prevent filenames starting with `-` from being interpreted as flags: `rm -v ./*` not `rm -v *`.
- [BCS1102] Use explicit path in loops: `for file in ./*.txt; do` not `for file in *.txt; do`.

## Process Substitution

- [BCS1103] Use `<(command)` to provide command output as file-like input, eliminating temporary files and avoiding subshell variable scope issues.
- [BCS1103] Use `>(command)` to redirect output to a command as if writing to a file: `tee >(wc -l) >(grep ERROR) > output.txt`.
- [BCS1103] Prefer process substitution over pipes to while loops to preserve variable scope: `while read -r line; do ((count+=1)); done < <(command)` not `command | while read -r line; do`.
- [BCS1103] Use `readarray` with process substitution for populating arrays: `readarray -t users < <(cut -d: -f1 /etc/passwd)`.
- [BCS1103] Use process substitution with `diff` to compare command outputs without temporary files: `diff <(sort file1) <(sort file2)`.
- [BCS1103] Use `tee` with multiple output process substitutions for parallel processing: `cat log | tee >(grep ERROR > errors.log) >(grep WARN > warnings.log) > all.log`.
- [BCS1103] Quote variables inside process substitution like normal: `<(sort "$file1")` not `<(sort $file1)`.
- [BCS1103] Use null-delimited input with process substitution for safe filename handling: `while IFS= read -r -d '' file; do ...; done < <(find /data -print0)`.
- [BCS1103] Never use process substitution where simple command substitution suffices: use `result=$(command)` not `result=$(cat <(command))`.

## Here Documents

- [BCS1104] Use here documents for multi-line strings or input with appropriate quoting.
- [BCS1104] Use `<<'EOF'` (single quotes) to prevent variable expansion in here documents: `cat <<'EOF'\nLiteral $VAR\nEOF`.
- [BCS1104] Use `<<EOF` (no quotes) to enable variable expansion: `cat <<EOF\nExpanded: $VAR\nEOF`.

## Input Redirection Optimization

- [BCS1105] Use `< filename` instead of `cat filename` for single-file input to commands for 3-4x performance improvement: `grep pattern < file` not `cat file | grep pattern`.
- [BCS1105] Use `content=$(< file)` instead of `content=$(cat file)` in command substitution for 100x+ speedup.
- [BCS1105] Optimize loops by replacing `$(cat "$file")` with `$(< "$file")` to eliminate process fork overhead in every iteration.
- [BCS1105] Use `cat` when concatenating multiple files (redirection cannot combine multiple sources): `cat file1 file2 file3` not `< file1 file2 file3`.
- [BCS1105] Use `cat` when needing cat-specific options like `-n` (line numbers), `-A` (show all), `-E` (show ends), `-T` (show tabs), `-s` (squeeze blank).
- [BCS1105] Never use `< filename` alone without a command to consume input; it opens the file descriptor but produces no output.

## Combined Patterns

- [BCS1101,BCS1102] Validate before glob operations: `[[ -d "$dir" ]] || die 1 "Directory not found: $dir"` then `for file in "$dir"/*.txt; do`.
- [BCS1103,BCS1105] Use process substitution with redirection for maximum efficiency: `while read -r line; do ...; done < <(< "$file" grep pattern)`.
- [BCS1101,BCS1103] Test file existence before using in process substitution: `[[ -f "$config" ]] || die 3 "Not found: $config"` then `diff <(sort "$config") <(sort "$backup")`.


---


**Rule: BCS1200**

## Security Considerations - Rulets

## SUID/SGID Prohibition

- [BCS1201] Never use SUID (`chmod u+s`) or SGID (`chmod g+s`) bits on Bash scripts under any circumstances - catastrophically dangerous due to IFS exploitation, PATH manipulation, library injection, shell expansion exploits, race conditions, and interpreter vulnerabilities.
- [BCS1201] Use `sudo` with configured `/etc/sudoers` permissions instead of SUID scripts: `username ALL=(root) NOPASSWD: /usr/local/bin/script.sh`.
- [BCS1201] For compiled programs needing specific privileges, use capabilities (`setcap cap_net_bind_service=+ep`) instead of full SUID root.
- [BCS1201] If elevated privileges are absolutely required for a script, use a SUID wrapper written in C that validates input, sanitizes environment, and executes the script safely.
- [BCS1201] Audit systems regularly for SUID/SGID scripts: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.

## PATH Security

- [BCS1202] Always lock down PATH at script start to prevent command hijacking: `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1202] Set secure PATH immediately after `set -euo pipefail` - never trust inherited PATH from caller's environment.
- [BCS1202] Never include current directory (`.`), empty elements (`::` or leading/trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1202] Use absolute paths for critical commands as defense in depth: `/bin/tar`, `/usr/bin/systemctl`, `/bin/rm`.
- [BCS1202] Validate inherited PATH if you cannot set it: check for `.`, empty elements, `/tmp`, or writable directories using regex tests.
- [BCS1202] Verify critical commands resolve to expected locations: `[[ "$(command -v tar)" == "/bin/tar" ]] || die 1 "Security: tar not from /bin/tar"`.
- [BCS1202] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"` not `rm "$user_file"`.

## IFS Manipulation Safety

- [BCS1203] Set IFS explicitly to known-safe value at script start and make readonly: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1203] Use one-line IFS assignment for single commands (safest pattern): `IFS=',' read -ra fields <<< "$csv_data"` - IFS automatically resets after the command.
- [BCS1203] Isolate IFS changes in subshells: `( IFS=','; read -ra fields <<< "$data"; process "${fields[@]}" )` - change cannot leak.
- [BCS1203] Use `local -- IFS` in functions to scope changes: declare IFS local before modifying, automatic restoration on function return.
- [BCS1203] Always save and restore if modifying IFS: `saved_ifs="$IFS"; IFS=','; read -ra fields <<< "$data"; IFS="$saved_ifs"`.
- [BCS1203] Never trust inherited IFS - attacker can manipulate it in calling environment to exploit field splitting and enable command injection.

## Eval Command Prohibition

- [BCS1204] Never use `eval` with any user input - enables complete command injection and system compromise with no sandboxing.
- [BCS1204] Avoid `eval` entirely even with trusted input - better alternatives exist for all common use cases using arrays, indirect expansion, or proper data structures.
- [BCS1204] Use arrays for dynamic command construction: `cmd=(find "$path" -type f); [[ -n "$pattern" ]] && cmd+=(-name "$pattern"); "${cmd[@]}"`.
- [BCS1204] Use indirect expansion for variable references: `echo "${!var_name}"` not `eval "echo \\$$var_name"`.
- [BCS1204] Use associative arrays for dynamic data: `declare -A data; data[$key]=$value; echo "${data[$key]}"` not `eval "$key='$value'"`.
- [BCS1204] Use case statements or associative arrays for function dispatch: `case "$action" in start) start_function ;;` not `eval "${action}_function"`.
- [BCS1204] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"` not `eval "$var_name='$value'"`.
- [BCS1204] Even sanitized input can contain metacharacters that enable injection through eval's double-expansion behavior.

## Input Sanitization

- [BCS1205] Always validate and sanitize user input before use - never trust it even if it "looks safe".
- [BCS1205] Use whitelist validation (define what IS allowed) not blacklist (define what isn't) - blacklists are always incomplete and bypassable.
- [BCS1205] Validate filenames to prevent directory traversal: remove all `..` and `/`, allow only `[a-zA-Z0-9._-]+`, reject leading dots and excessive length.
- [BCS1205] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]]` for signed, `[[ "$input" =~ ^[0-9]+$ ]]` for unsigned, reject leading zeros.
- [BCS1205] Validate paths stay within allowed directory: `real_path=$(realpath -e -- "$input_path"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 "Path outside allowed directory"`.
- [BCS1205] Always use `--` separator in commands to prevent option injection: `rm -- "$user_file"` prevents `-rf` being interpreted as option.
- [BCS1205] Validate against whitelist for choice inputs: iterate allowed values, reject if no match: `for choice in "${valid[@]}"; do [[ "$input" == "$choice" ]] && return 0; done; die 22 "Invalid"`.
- [BCS1205] Validate early before any processing - fail securely with clear error messages on invalid input.
- [BCS1205] Check input type, format, range, and length constraints - comprehensive validation prevents injection and logic errors.


---


**Rule: BCS1300**

## Code Style & Best Practices - Rulets

## Code Formatting

- [BCS1301] Use 2 spaces for indentation, never tabs, and maintain consistent indentation throughout the script.
- [BCS1301] Keep lines under 100 characters when practical; long file paths and URLs may exceed this limit when necessary using line continuation with `\`.

## Comments

- [BCS1302] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT the code already shows.
- [BCS1302] Use comments to explain non-obvious business rules, edge cases, intentional deviations, complex logic, why specific approaches were chosen, and subtle gotchas or side effects.
- [BCS1302] Avoid commenting simple variable assignments, obvious conditionals, standard patterns already documented, or self-explanatory code with good naming.
- [BCS1302,BCS1307] In documentation use standardized icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error); avoid other emoticons unless justified.

## Blank Line Usage

- [BCS1303] Use one blank line between functions, between logical sections within functions, after section comments, between groups of related variables, and before/after multi-line conditional or loop blocks.
- [BCS1303] Avoid multiple consecutive blank lines; one blank line is sufficient for visual separation.
- [BCS1303] No blank line needed between short, related statements.

## Section Comments

- [BCS1304] Use simple `# Description` format (no dashes, no box drawing) for section comments to organize code into logical groups.
- [BCS1304] Keep section comments short and descriptive (2-4 words typically), place immediately before the group described, and follow with a blank line after the group.
- [BCS1304] Reserve 80-dash separators (`# ---...---`) for major script divisions only; use lightweight section comments for grouping related variables, functions, or logical blocks.
- [BCS1304] Common section comment patterns: `# Default values`, `# Derived paths`, `# Core message function`, `# Conditional messaging functions`, `# Unconditional messaging functions`, `# Helper functions`, `# Business logic`, `# Validation functions`.

## Language Best Practices

- [BCS1305] Always use `$()` for command substitution instead of backticks; it's more readable, nests naturally without escaping, and has better editor support.
- [BCS1305] Prefer shell builtins over external commands: use `$(())` instead of `expr`, `${var##*/}` instead of `basename`, `${var%/*}` instead of `dirname`, `${var^^}` or `${var,,}` instead of `tr` for case conversion, and `[[` instead of `[` or `test`.
- [BCS1305] Builtins are 10-100x faster than external commands because they avoid process creation, have no PATH dependency, and are guaranteed in bash.

## Development Practices

- [BCS1306] ShellCheck is compulsory for all scripts; use `#shellcheck disable=SCxxxx` only for documented exceptions with explanatory comments.
- [BCS1306] Always end scripts with `#fin` or `#end` marker after the `main "$@"` invocation.
- [BCS1306] Use defensive programming: set default values for critical variables with `: "${VAR:=default}"`, validate inputs early, and guard against unset variables with `set -u`.
- [BCS1306] Optimize performance by minimizing subshells, using built-in string operations over external commands, batching operations when possible, and using process substitution over temp files.
- [BCS1306] Make functions testable with dependency injection for external commands, support verbose/debug modes, and return meaningful exit codes.

## Emoticons

- [BCS1307] Standard severity icons: `◉` (info), `⦿` (debug), `▲` (warn), `✗` (error), `✓` (success).
- [BCS1307] Extended icons: `⚠` (caution/important), `☢` (fatal/critical), `↻` (redo/retry/update), `◆` (checkpoint), `●` (in progress), `○` (pending), `◐` (partial).
- [BCS1307] Action icons: `▶` (start/execute), `■` (stop), `⏸` (pause), `⏹` (terminate), `⚙` (settings/config), `☰` (menu/list).
- [BCS1307] Directional icons: `→` (forward/next), `←` (back), `↑` (up/upgrade), `↓` (down/downgrade), `⇄` (swap), `⇅` (sync/bidirectional).


---


**Rule: BCS1400**

## Advanced Patterns - Rulets

## Debugging and Development

- [BCS1401] Enable trace mode with `set -x` when `DEBUG=1` and enhance trace output with `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '` for readable debugging.
- [BCS1401] Implement conditional debug output with `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }` to show messages only when debugging is enabled.

## Dry-Run Pattern

- [BCS1402] Check dry-run flag at the start of state-modifying functions with `if ((DRY_RUN)); then info '[DRY-RUN] Would perform action'; return 0; fi` to preview operations safely.
- [BCS1402] Display preview messages with `[DRY-RUN]` prefix using `info` and return early (exit code 0) without performing actual operations.
- [BCS1402] Parse dry-run from command-line with `-n|--dry-run) DRY_RUN=1` and `-N|--not-dry-run) DRY_RUN=0` flags.
- [BCS1402] Maintain identical control flow in dry-run mode (same function calls, same logic paths) to verify logic without side effects.

## Temporary File Handling

- [BCS1403] Always use `mktemp` to create temporary files (`temp_file=$(mktemp)`) or directories (`temp_dir=$(mktemp -d)`), never hard-code temp file paths.
- [BCS1403] Set up cleanup trap immediately after creating temp resources: `trap 'rm -f "$temp_file"' EXIT` for files, `trap 'rm -rf "$temp_dir"' EXIT` for directories.
- [BCS1403] Check mktemp success with `|| die 1 'Failed to create temporary file'` and make temp file variables readonly after creation.
- [BCS1403] Use custom templates for recognizable temp files: `mktemp /tmp/"$SCRIPT_NAME".XXXXXX` (at least 3 X's required).
- [BCS1403] Register multiple temp resources in array with cleanup function: `TEMP_FILES+=("$temp_file")` and `trap cleanup_temp_files EXIT`.
- [BCS1403] Validate temp file security by checking permissions (0600 for files, 0700 for directories) and ownership when handling sensitive data.
- [BCS1403] Never overwrite EXIT trap when creating multiple temp files; use single trap with cleanup function or list all files: `trap 'rm -f "$temp1" "$temp2"' EXIT`.
- [BCS1403] Preserve exit code in cleanup function with `local -i exit_code=$?` and `return "$exit_code"` to maintain original script exit status.

## Environment Variable Best Practices

- [BCS1404] Validate required environment variables with `: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"` to exit script if not set.
- [BCS1404] Provide defaults for optional environment variables with `: "${OPTIONAL_VAR:=default_value}"` or `export VAR="${VAR:-default}"`.
- [BCS1404] Check multiple required variables in loop: `for var in "${REQUIRED[@]}"; do [[ -n "${!var:-}" ]] || error "Required variable '$var' not set"; done`.

## Regular Expression Guidelines

- [BCS1405] Use POSIX character classes for portability: `[[:alnum:]]` for alphanumeric, `[[:digit:]]` for digits, `[[:space:]]` for whitespace, `[[:xdigit:]]` for hexadecimal.
- [BCS1405] Store complex regex patterns in readonly variables: `readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'`.
- [BCS1405] Extract capture groups from `BASH_REMATCH` after successful regex match: `if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then major="${BASH_REMATCH[1]}"; fi`.

## Background Job Management

- [BCS1406] Start background jobs with `command &` and track PID with `PID=$!` for later process management.
- [BCS1406] Check if background process is still running with `kill -0 "$PID" 2>/dev/null` before attempting to wait or kill.
- [BCS1406] Wait for background jobs with timeout: `timeout 10 wait "$PID"` and kill on timeout with `kill "$PID" 2>/dev/null || true`.
- [BCS1406] Track multiple background jobs in array: `PIDS+=($!)` and wait for all with `for pid in "${PIDS[@]}"; do wait "$pid"; done`.

## Logging Best Practices

- [BCS1407] Create structured log entries with ISO8601 timestamp, script name, level, and message: `printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"`.
- [BCS1407] Ensure log directory exists before logging: `[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"`.
- [BCS1407] Provide convenience logging functions: `log_debug()`, `log_info()`, `log_warn()`, `log_error()` that call main `log()` function.

## Performance Profiling

- [BCS1408] Use `SECONDS` builtin for simple timing: `SECONDS=0; operation; info "Completed in ${SECONDS}s"`.
- [BCS1408] Use `EPOCHREALTIME` for high-precision timing: `start=$EPOCHREALTIME; "$@"; end=$EPOCHREALTIME; runtime=$(awk "BEGIN {print $end - $start}")`.

## Testing Support Patterns

- [BCS1409] Implement dependency injection by declaring command wrappers: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` for mockable external commands.
- [BCS1409] Use `TEST_MODE` flag to conditionally enable test behavior: `declare -i TEST_MODE="${TEST_MODE:-0}"` and override destructive operations in test mode.
- [BCS1409] Create assertion function for tests: `assert() { [[ "$expected" != "$actual" ]] && { >&2 echo "ASSERT FAIL: $message"; return 1; }; return 0; }`.
- [BCS1409] Implement test runner that finds and executes all `test_*` functions: `for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do "$test_func"; done`.

## Progressive State Management

- [BCS1410] Declare all boolean flags at the top with initial values: `declare -i INSTALL_BUILTIN=0`.
- [BCS1410] Progressively adjust flags based on runtime conditions: parse command-line arguments first, then validate dependencies, then check for failures.
- [BCS1410] Separate user intent from runtime state using distinct flags: `BUILTIN_REQUESTED=1` (what user asked for) vs `INSTALL_BUILTIN=0` (what will actually happen).
- [BCS1410] Disable features when prerequisites fail: `check_builtin_support || INSTALL_BUILTIN=0` to fail gracefully rather than error out.
- [BCS1410] Execute actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin` runs only if flag is still enabled after all checks.
- [BCS1410] Never modify flags during execution phase; only change them in setup/validation phases to maintain clear separation between decision logic and action.
- [BCS1410] Document state transitions with comments showing how flags change throughout script lifecycle.
#fin
