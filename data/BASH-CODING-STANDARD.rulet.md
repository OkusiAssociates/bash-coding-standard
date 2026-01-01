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

I have all the content I need from the user's message which provides the complete.md files. Let me now extract the rulets from all the provided files.
# Script Structure & Layout - Rulets
## Section Overview
- [BCS0100] Script Structure defines the mandatory 13-step layout: shebang → shellcheck → description → `set -euo pipefail` → shopt → metadata → globals → colors → utilities → business logic → main() → invocation → `#fin`.
## The 13-Step Layout (BCS0101)
- [BCS0101] Follow the 13-step layout in order: (1) shebang, (2) shellcheck directives, (3) description comment, (4) `set -euo pipefail`, (5) shopt settings, (6) metadata, (7) globals, (8) colors, (9) utilities, (10) business logic, (11) main(), (12) `main "$@"`, (13) `#fin`.
- [BCS0101] Place `set -euo pipefail` as the first executable command; it must come before any other commands except shebang, comments, and shellcheck directives.
- [BCS0101] Organize functions bottom-up: messaging functions first, then utilities, validation, business logic, orchestration, and finally `main()` at the bottom.
- [BCS0101] Use `main()` function for scripts over ~200 lines; scripts under 200 lines may run code directly.
- [BCS0101] End every script with `#fin` or `#end` marker to confirm file completeness.
- [BCS0101] Declare all global variables up front with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Make configuration variables `readonly` only after argument parsing is complete, not before.
- [BCS0101] Always quote `"$@"` in script invocation: `main "$@"`.
## Complete Working Example (BCS010101)
- [BCS010101] Production scripts should implement all 13 steps including: metadata with VERSION/SCRIPT_PATH/SCRIPT_DIR/SCRIPT_NAME, color detection, standard messaging functions, dry-run support, and proper argument parsing.
- [BCS010101] Use `noarg "$@"` pattern to validate that options requiring arguments receive them.
- [BCS010101] Implement dry-run mode by checking `((DRY_RUN))` before any operation and showing what would happen: `info "[DRY-RUN] Would create directory ${dir@Q}"`.
- [BCS010101] Use derived paths pattern where dependent paths update when PREFIX changes: `BIN_DIR="$PREFIX"/bin`.
## Common Anti-Patterns (BCS010102)
- [BCS010102] Never omit `set -euo pipefail`; errors will fail silently and cause corruption.
- [BCS010102] Never declare variables after using them; this causes "unbound variable" errors with `set -u`.
- [BCS010102] Never define business logic functions before the utility functions they call; always bottom-up organization.
- [BCS010102] Never make variables `readonly` before argument parsing; this prevents users from overriding defaults.
- [BCS010102] Never scatter global declarations throughout the file; group all globals together after metadata.
- [BCS010102] Never apply `set -euo pipefail` in scripts that may be sourced; use dual-purpose pattern instead.
- [BCS010102] Never omit the `#fin` end marker; readers cannot verify file completeness without it.
## Edge Cases (BCS010103)
- [BCS010103] Small scripts under 200 lines may skip `main()` and run code directly after function definitions.
- [BCS010103] Library files meant only to be sourced should skip `set -e`, `main()`, and script invocation; only define functions.
- [BCS010103] When sourcing external config files, place `source "$CONFIG_FILE"` between metadata and business logic.
- [BCS010103] Set cleanup traps after the cleanup function is defined but before any code that creates temporary resources.
- [BCS010103] For platform-specific scripts, detect platform with `case $(uname -s) in` and set platform-specific globals accordingly.
## Dual-Purpose Scripts (BCS010201)
- [BCS010201] For scripts that work both as executables and sourceable libraries, use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`.
- [BCS010201] Place all function definitions before the sourced/executed detection check; only apply `set -euo pipefail` in the executable section after the check.
- [BCS010201] Guard metadata initialization with `[[ ! -v VARIABLE ]]` to allow safe re-sourcing: `[[ -v SCRIPT_VERSION ]] || { declare -xr SCRIPT_VERSION=1.0.0; ... }`.
- [BCS010201] Export functions with `declare -fx function_name` if they need to be available in subshells.
- [BCS010201] Use `return` (not `exit`) for errors when script is sourced to avoid terminating the caller's shell.
## Shebang and Initial Setup (BCS0102)
- [BCS0102] Use one of three acceptable shebangs: `#!/bin/bash` (most portable Linux), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability).
- [BCS0102] Place `#shellcheck disable=` directives immediately after shebang with explanatory comments: `#shellcheck disable=SC2034  # Variables used by sourcing scripts`.
- [BCS0102] Include a brief one-line description comment after shebang/directives: `# Comprehensive installation script with configurable paths`.
- [BCS0102] First executable command must be `set -euo pipefail`; nothing else may execute before it.
## Script Metadata (BCS0103)
- [BCS0103] Declare standard metadata immediately after shopt: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`.
- [BCS0103] Use `realpath -- "$0"` or `realpath -- "${BASH_SOURCE[0]}"` for SCRIPT_PATH to resolve symlinks and get canonical absolute paths.
- [BCS0103] Derive SCRIPT_DIR and SCRIPT_NAME from SCRIPT_PATH using parameter expansion: `SCRIPT_DIR=${SCRIPT_PATH%/*}` and `SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Declare metadata as readonly immediately: `declare -r VERSION=1.0.0` and `declare -r SCRIPT_PATH=$(realpath -- "$0")`.
- [BCS0103] Suppress shellcheck SC2155 for metadata declarations with realpath: `#shellcheck disable=SC2155`.
- [BCS0103] Handle edge case of script in root directory: `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`.
## FHS Compliance (BCS0104)
- [BCS0104] Search for resources in FHS order: script directory (development), `/usr/local/share/` (local install), `/usr/share/` (system install), `~/.local/share/` (user install).
- [BCS0104] Use PREFIX variable for installation paths and respect environment override: `PREFIX=${PREFIX:-/usr/local}`.
- [BCS0104] Derive installation paths from PREFIX: `BIN_DIR="$PREFIX"/bin`, `SHARE_DIR="$PREFIX"/share/myapp`, `LIB_DIR="$PREFIX"/lib/myapp`.
- [BCS0104] Follow XDG Base Directory for user-specific files: `${XDG_CONFIG_HOME:-$HOME/.config}`, `${XDG_DATA_HOME:-$HOME/.local/share}`.
- [BCS0104] Preserve existing user configuration on upgrade: `[[ -f "$CONFIG" ]] || install -m 644 config.example "$CONFIG"`.
- [BCS0104] Strip trailing slash from PREFIX: `PREFIX=${PREFIX%/}`.
## shopt Settings (BCS0105)
- [BCS0105] Use standard shopt settings: `shopt -s inherit_errexit shift_verbose extglob nullglob`.
- [BCS0105] Always enable `inherit_errexit` to make `set -e` work in command substitutions and subshells.
- [BCS0105] Always enable `shift_verbose` to catch argument parsing bugs when shift has no arguments.
- [BCS0105] Always enable `extglob` for extended patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`.
- [BCS0105] Choose `nullglob` (empty globs expand to nothing) for loops/arrays OR `failglob` (unmatched globs cause error) for strict scripts; never use neither.
- [BCS0105] Enable `globstar` only when needed for recursive `**` matching; it can be slow on deep directory trees.
## File Extensions (BCS0106)
- [BCS0106] Use `.sh` extension or no extension for executables; globally installed scripts in PATH should have no extension.
- [BCS0106] Libraries must have `.sh` extension and should not be executable (no execute permission).
- [BCS0106] Dual-purpose scripts (both sourceable and executable) may use either `.sh` or no extension.
## Function Organization (BCS0107)
- [BCS0107] Organize functions in 7 layers bottom-up: (1) messaging, (2) documentation, (3) helpers, (4) validation, (5) business logic, (6) orchestration, (7) main().
- [BCS0107] Layer 1 (messaging): `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`, `debug()`, `vecho()` - no dependencies.
- [BCS0107] Layer 2 (documentation): `show_help()`, `show_version()` - may use messaging.
- [BCS0107] Layer 3 (helpers): `yn()`, `noarg()`, generic utilities - may use messaging.
- [BCS0107] Layer 4 (validation): `check_root()`, `check_prerequisites()` - may use helpers and messaging.
- [BCS0107] Layer 5 (business logic): domain-specific operations - may use all lower layers.
- [BCS0107] Layer 6 (orchestration): coordinate multiple operations - may use business logic.
- [BCS0107] Layer 7 (main): `main()` at bottom can call any function; handles argument parsing and workflow.
- [BCS0107] Never create circular dependencies; extract common logic to a lower layer if functions need to call each other.
- [BCS0107] Prefix private/internal functions with underscore: `_msg()`, `_internal_parser()`.


---


**Rule: BCS0200**

## Variables & Data Types - Rulets
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
- [BCS0301] Use single quotes for static strings and double quotes only when variable expansion is needed: `info 'Processing...'` vs `info "Found $count files"`.
- [BCS0301] Nest single quotes inside double quotes to display literal values: `die 1 "Unknown option '$1'"`.
- [BCS0301] Single-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted but quoting is preferred for consistency: `STATUS='success'` not `STATUS=success`.
- [BCS0301] Always quote strings containing spaces, special characters (`@`, `*`, `$`), or empty values: `EMAIL='user@domain.com'`, `PATTERN='*.log'`, `VAR=''`.
- [BCS0301] Quote variable portions separately from literal paths for clarity: `"$PREFIX"/bin` and `"$SCRIPT_DIR"/data/"$filename"` rather than `"$PREFIX/bin"`.
## Command Substitution
- [BCS0302] Use double quotes when strings include command substitution: `VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"`.
- [BCS0302] Always quote command substitution results to prevent word splitting: `echo "$result"` not `echo $result`.
## Quoting in Conditionals
- [BCS0303] Always quote variables in conditionals: `[[ -f "$file" ]]` and `[[ "$name" == 'value' ]]`, never `[[ -f $file ]]`.
- [BCS0303] Use single quotes for static comparison values: `[[ "$action" == 'start' ]]` not `[[ "$action" == "start" ]]`.
- [BCS0303] Leave glob patterns unquoted for matching, quote for literal: `[[ "$filename" == *.txt ]]` matches globs, `[[ "$filename" == '*.txt' ]]` matches literal.
- [BCS0303] Leave regex pattern variables unquoted: `[[ "$input" =~ $pattern ]]` not `[[ "$input" =~ "$pattern" ]]`.
## Here Documents
- [BCS0304] Use unquoted delimiter `<<EOF` when variable expansion is needed; quote delimiter `<<'EOF'` for literal content with no expansion.
- [BCS0304] Quote here-doc delimiters for SQL, JSON, or any content where `$` should be literal: `cat <<'EOF'` prevents injection risks.
- [BCS0304] Use `<<-EOF` to strip leading tabs (not spaces) for indented heredocs within control structures.
## printf Patterns
- [BCS0305] Use single quotes for printf format strings and double quotes for variable arguments: `printf '%s: %d files\n' "$name" "$count"`.
- [BCS0305] Prefer `printf` over `echo -e` for consistent escape sequence handling across shells: `printf 'Line1\nLine2\n'` not `echo -e "Line1\nLine2"`.
- [BCS0305] Use `$'...'` syntax as alternative for escape sequences: `echo $'Line1\nLine2'`.
## Parameter Quoting with @Q
- [BCS0306] Use `${parameter@Q}` to safely display user input in error messages: `die 2 "Unknown option ${1@Q}"` prevents injection.
- [BCS0306] Use `@Q` for dry-run output to show exact commands: `printf -v quoted_cmd '%s ' "${cmd[@]@Q}"`.
- [BCS0306] Never use `@Q` for normal variable expansion or comparisons—only for display/logging of untrusted input.
## Anti-Patterns
- [BCS0307] Never use double quotes for static strings: `info 'Checking...'` not `info "Checking..."`.
- [BCS0307] Never leave variables unquoted: `rm "$temp_file"` not `rm $temp_file`.
- [BCS0307] Never use unnecessary braces around simple variables: `"$HOME"/bin` not `"${HOME}/bin"`. Braces only for `${var:-default}`, `${file##*/}`, `"${array[@]}"`, `"${var1}${var2}"`.
- [BCS0307] Always quote array expansions: `for item in "${items[@]}"` not `for item in ${items[@]}`.
- [BCS0307] Never echo unquoted glob patterns: `echo "$pattern"` not `echo $pattern` when `pattern='*.txt'`.


---


**Rule: BCS0400**

The existing rulet file is already well-structured and comprehensive. I can see it covers all the BCS0400-0408 rules. Let me review it against the source complete.md files to ensure completeness and make any necessary refinements.
# Functions - Rulets
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
## Conditional Tests
- [BCS0501] Always use `[[ ]]` for string and file tests; use `(())` for arithmetic comparisons: `[[ -f "$file" ]]`, `((count > 5))`.
- [BCS0501] Use `[[ ]]` advantages over `[ ]`: no word splitting on variables, pattern matching with `==` and `=~`, logical operators `&&`/`||` work inside.
- [BCS0501] Quote variables in `[[ ]]` conditionals for clarity even though word splitting doesn't occur: `[[ "$var" == 'value' ]]`.
- [BCS0501] Use arithmetic truthiness directly instead of explicit comparisons: `((count))` not `((count > 0))`, `((VERBOSE))` not `((VERBOSE == 1))`.
- [BCS0501] Use short-circuit evaluation for concise conditionals: `[[ -f "$config" ]] && source "$config" ||:`, `((DEBUG)) && set -x ||:`.
- [BCS0501] Never use `[ ]` with `-a`/`-o` operators; use `[[ ]]` with `&&`/`||` instead.
- [BCS0501] Use `=~` for regex matching: `[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]`.
## Case Statements
- [BCS0502] Use `case` statements for multi-way branching on a single variable against multiple patterns; use `if/elif` for multiple variable tests or complex conditions.
- [BCS0502] Do not quote the case expression: `case ${1:-} in` not `case "${1:-}" in`.
- [BCS0502] Do not quote literal patterns: `start)` not `"start)"`.
- [BCS0502] Always include a default `*)` case to handle unexpected values explicitly.
- [BCS0502] Use compact format (single-line actions, aligned `;;`) for simple flag setting in argument parsing.
- [BCS0502] Use expanded format (action on next line, `;;` on separate line) for multi-line logic or complex operations.
- [BCS0502] Align actions consistently at column 14-18 for visual clarity.
- [BCS0502] Use alternation for multiple patterns: `-h|--help|help)` for OR matching.
- [BCS0502] Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+(pattern)`.
## Loops
- [BCS0503] Always quote array expansion in for loops: `for item in "${array[@]}"` not `for item in ${array[@]}`.
- [BCS0503] Use `for` loops for arrays, globs, and known ranges; use `while` loops for reading input and condition-based iteration.
- [BCS0503] Use `i+=1` for loop increments, never `i++` or `((i++))`: `for ((i=0; i<10; i+=1))`.
- [BCS0503] Use arithmetic truthiness in while conditions: `while (($#))` not `while (($# > 0))`.
- [BCS0503] Use `while ((1))` for infinite loops (fastest); use `while :` only for POSIX compatibility; avoid `while true` (15-22% slower).
- [BCS0503] Declare loop variables with `local` BEFORE the loop, not inside: `local -- file; for file in *.txt; do`.
- [BCS0503] Specify break level for nested loops: `break 2` to exit both loops.
- [BCS0503] Always use `IFS= read -r` when reading input in while loops.
- [BCS0503] Never parse `ls` output; use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
## Process Substitution
- [BCS0504] Never pipe to while loops; use process substitution instead: `while read -r line; done < <(command)` not `command | while read -r line; done`.
- [BCS0504] Piping to while creates a subshell where variable modifications are lost when the pipe ends.
- [BCS0504] Use `readarray -t array < <(command)` to collect lines into an array without subshell issues.
- [BCS0504] Use here-strings for single variables: `while read -r line; done <<< "$input"`.
- [BCS0504] Use `readarray -d '' -t files < <(find ... -print0)` for null-delimited input to handle filenames with newlines.
## Integer Arithmetic
- [BCS0505] Declare all integer variables with `declare -i` or `local -i` before use.
- [BCS0505] Use `i+=1` as the ONLY acceptable increment form; never use `((i++))`, `((++i))`, or `((i+=1))`.
- [BCS0505] The `((i++))` form returns the original value and fails with `set -e` when `i=0`.
- [BCS0505] Use `(())` for arithmetic conditionals, not `[[ ... -eq ... ]]`: `((exit_code == 0))` not `[[ "$exit_code" -eq 0 ]]`.
- [BCS0505] No `$` prefix needed for variables inside `(())`: `((result = a + b))` not `((result = $a + $b))`.
- [BCS0505] Use `$(())` for arithmetic in assignments or command arguments: `result=$((x * y))`.
- [BCS0505] Integer division truncates toward zero: `((10 / 3))` equals 3, not 3.333.
## Floating-Point Operations
- [BCS0506] Bash only supports integer arithmetic natively; use `bc` or `awk` for floating-point calculations.
- [BCS0506] Use `bc -l` for arbitrary precision: `result=$(echo '3.14 * 2.5' | bc -l)`.
- [BCS0506] Use `awk` for inline floating-point with formatting: `result=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')`.
- [BCS0506] Compare floats with bc or awk, never string comparison: `if (($(echo "$a > $b" | bc -l)))` not `[[ "$a" > "$b" ]]`.


---


**Rule: BCS0600**

## Error Handling - Rulets
## Exit on Error (set -euo pipefail)
- [BCS0601] Always use `set -euo pipefail` at script start: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.
- [BCS0601] Add `shopt -s inherit_errexit` so command substitutions inherit `set -e` behavior.
- [BCS0601] Allow expected failures with `command || true` or `if command; then ...; fi` patterns.
- [BCS0601] Capture exit code when needed: `set +e; result=$(failing_command); set -e` or use `if result=$(cmd); then`.
- [BCS0601] Never use `result=$(failing_command)` without error handling—command substitution failures don't exit with `set -e` alone.
## Exit Codes
- [BCS0602] Use standard exit codes: 0=success, 1=general error, 2=misuse/missing argument, 22=invalid argument (EINVAL), 5=permission denied.
- [BCS0602] Implement `die()` for consistent exits: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0602] Use `die 22 "Invalid option ${1@Q}"` for argument errors, matching errno EINVAL convention.
- [BCS0602] Avoid exit codes 126-255 for custom errors; these conflict with signal handling (128+n = fatal signal n).
- [BCS0602] Define exit code constants for readability: `readonly -i ERR_USAGE=2 ERR_CONFIG=3 ERR_NETWORK=4`.
## Trap Handling
- [BCS0603] Install traps early, before creating resources: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS0603] Always preserve exit code in traps: use `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`.
- [BCS0603] Disable trap inside cleanup to prevent recursion: `cleanup() { trap - SIGINT SIGTERM EXIT; ... }`.
- [BCS0603] Use single quotes in trap commands to delay variable expansion: `trap 'rm -f "$temp_file"' EXIT`.
- [BCS0603] Handle multiple signals by combining in cleanup function; avoid multiple separate traps for same signal.
- [BCS0603] For temp files: `temp_file=$(mktemp) || die 1 'Failed to create temp'; trap 'rm -f "$temp_file"' EXIT`.
## Return Value Checking
- [BCS0604] Always check return values of critical operations with informative error messages: `mv "$src" "$dst" || die 1 "Failed to move ${src@Q}"`.
- [BCS0604] Use `|| { cleanup; exit 1; }` pattern when failure requires cleanup before exit.
- [BCS0604] Check PIPESTATUS array for pipeline failures: `((PIPESTATUS[0] != 0))` checks first command.
- [BCS0604] Command substitution needs explicit check: `output=$(cmd) || die 1 'cmd failed'`.
- [BCS0604] Capture exit code immediately: `command; exit_code=$?` before any other commands that would overwrite `$?`.
- [BCS0604] Use `if ! operation; then die 1 'msg'; fi` for operations needing contextual error messages.
- [BCS0604] Functions should use meaningful return codes: `return 2` for not found, `return 5` for permission denied, `return 22` for invalid input.
## Error Suppression
- [BCS0605] Only suppress errors when failure is expected, non-critical, and safe—always document WHY with a comment.
- [BCS0605] Use `2>/dev/null` to suppress error messages while still checking return value.
- [BCS0605] Use `|| true` or `|| :` to ignore return code while keeping stderr visible.
- [BCS0605] Use `2>/dev/null || true` only when both error messages and return code are irrelevant.
- [BCS0605] Safe to suppress: existence checks (`command -v`), cleanup of optional files (`rm -f /tmp/opt_* 2>/dev/null || true`), idempotent operations (`install -d`).
- [BCS0605] Never suppress: file operations, data processing, system configuration, security operations, required dependency checks.
- [BCS0605] Verify after suppressed operations when possible: `install -d "$dir" 2>/dev/null || true; [[ -d "$dir" ]] || die 1 'Failed'`.
## Conditional Declarations with Exit Code Handling
- [BCS0606] Append `|| :` to `((condition)) && action` patterns under `set -e`: `((verbose)) && echo 'msg' || :`.
- [BCS0606] Arithmetic conditionals return exit code 1 when false, which triggers `set -e`—`|| :` prevents this.
- [BCS0606] Prefer `:` over `true` for the null command—it's the traditional Unix idiom and slightly faster.
- [BCS0606] Use for optional variable declarations: `((complete)) && declare -g EXTRA=$'\033[0;34m' || :`.
- [BCS0606] Use for feature-gated actions: `((DRY_RUN)) && echo "Would execute: $cmd" || :`.
- [BCS0606] Never use `|| :` for critical operations that must succeed—use explicit error handling instead.
- [BCS0606] For complex logic, prefer explicit `if ((condition)); then action; fi` over `((condition)) && action || :`.


---


**Rule: BCS0700**

## Input/Output & Messaging - Rulets
## Stream Separation
- [BCS0702] All error messages must go to STDERR; place `>&2` at the beginning of commands for clarity: `>&2 echo "error message"` rather than `echo "error message" >&2`.
- [BCS0702] Use STDOUT for data output that will be captured or piped; use STDERR for diagnostic/status messages that inform the user.
## Color Support
- [BCS0701] Declare message control flags as integers: `declare -i VERBOSE=1 PROMPT=1 DEBUG=0`.
- [BCS0701] Conditionally define color variables based on terminal detection: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ... NC=$'\033[0m'; else declare -r RED='' ... NC=''; fi`.
- [BCS0701] Always test both stdout AND stderr for terminal (`[[ -t 1 && -t 2 ]]`) before enabling colors.
## Core Message Functions
- [BCS0703] Implement a private `_msg()` core function that inspects `${FUNCNAME[1]}` to automatically determine formatting based on the calling function (info, warn, error, etc.).
- [BCS0703] Conditional output functions (`info`, `warn`, `success`) must check `((VERBOSE)) || return 0` before calling `_msg`.
- [BCS0703] The `error()` function must be unconditional (always displays) and output to stderr: `error() { >&2 _msg "$@"; }`.
- [BCS0703] Implement `die()` with exit code as first parameter: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
- [BCS0703] The `debug()` function must respect DEBUG flag: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS0703] Implement `yn()` prompt that respects PROMPT flag for non-interactive mode: `yn() { ((PROMPT)) || return 0; ... }`.
- [BCS0703] Use standard icons in message prefixes: `✓` (success/GREEN), `▲` (warn/YELLOW), `◉` (info/CYAN), `✗` (error/RED).
## Usage Documentation
- [BCS0704] Implement `show_help()` using a here-doc with sections: description, usage line, options (grouped logically), and examples.
- [BCS0704] Include `$SCRIPT_NAME $VERSION` in help header and reference them in usage line and version option description.
- [BCS0704] Group related options visually with blank lines; show both short and long forms: `-v|--verbose`.
## Echo vs Messaging Functions
- [BCS0705] Use messaging functions (`info`, `success`, `warn`, `error`) for operational status updates that should respect verbosity settings and go to stderr.
- [BCS0705] Use plain `echo` for data output to stdout (must be parseable/pipeable), help text, version output, structured reports, and output that must always display.
- [BCS0705] Never use `info()` for data output that needs to be captured—it goes to stderr and respects VERBOSE.
- [BCS0705] Help and version output must use `echo`/`cat`, never messaging functions, so they display regardless of VERBOSE setting.
- [BCS0705] Data-returning functions must use `echo` for output: `get_value() { echo "$result"; }` not `info "$result"`.
## Color Management Library
- [BCS0706] Use a two-tier color system: basic tier (5 variables: NC, RED, GREEN, YELLOW, CYAN) for minimal namespace pollution, complete tier (+7: BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE) when needed.
- [BCS0706] Support three color modes: `auto` (default, checks both stdout AND stderr for TTY), `always` (force on), `never`/`none` (force off).
- [BCS0706] Use the `flags` option to initialize BCS control variables: `color_set complete flags` sets VERBOSE, DEBUG, DRY_RUN, PROMPT.
- [BCS0706] Implement dual-purpose pattern for color libraries: sourceable with optional arguments (`source color-set complete`) and executable for demonstration.
## TUI Basics
- [BCS0707] Always check for terminal before using TUI elements: `if [[ -t 1 ]]; then progress_bar 50 100; else echo '50% complete'; fi`.
- [BCS0707] Hide cursor during TUI operations and restore on exit: `hide_cursor() { printf '\033[?25l'; }; trap 'show_cursor' EXIT`.
- [BCS0707] Use `printf '\r\033[K'` to clear the current line when updating progress indicators.
## Terminal Capabilities
- [BCS0708] Get terminal dimensions dynamically with fallbacks: `TERM_COLS=$(tput cols 2>/dev/null || echo 80)`.
- [BCS0708] Handle terminal resize with WINCH trap: `trap 'get_terminal_size' WINCH`.
- [BCS0708] Check for Unicode support via locale: `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`.
- [BCS0708] Use terminal-aware width for output: `printf '%-*s\n' "${TERM_COLS:-80}" "$text"` not hardcoded widths.
- [BCS0708,BCS0701] Never output raw ANSI escape codes without first checking terminal capability; provide plain text fallback for non-terminals.


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
- [BCS0801] Use `while (($#)); do case $1 in ... esac; shift; done` as the canonical argument parsing structure; `(($#))` is more efficient than `while [[ $# -gt 0 ]]`.
- [BCS0801] Support both short and long options for every option: `-V|--version`, `-h|--help`, `-v|--verbose`.
- [BCS0801] For options with arguments, always call `noarg "$@"` before `shift` to validate the argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`
- [BCS0801] For options that exit immediately (`-V`, `-h`), use `exit 0` (or `return 0` inside a function) without needing an additional shift.
- [BCS0801] Use `VERBOSE+=1` for stackable verbose flags allowing `-vvv` to set `VERBOSE=3`; requires prior `declare -i VERBOSE=0`.
- [BCS0801] Always include a mandatory `shift` at the end of the loop after `esac` to prevent infinite loops.
- [BCS0801] Catch invalid options with `-*) die 22 "Invalid option ${1@Q}" ;;` using exit code 22 (EINVAL).
- [BCS0801] Collect positional arguments in a default case: `*) files+=("$1") ;;`
## The noarg Helper
- [BCS0801] Define `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }` to validate option arguments exist.
- [BCS0801] Always call `noarg "$@"` BEFORE `shift` since it needs to inspect `$2` for the argument value.
## Version Output Format
- [BCS0802] Use format `<script_name> <version_number>` for version output: `echo "$SCRIPT_NAME $VERSION"` → "myscript 1.2.3".
- [BCS0802] Never include the words "version", "vs", or "v" between script name and version number.
## Argument Validation
- [BCS0803] Use `noarg()` for basic existence checking: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }`
- [BCS0803] Use `arg2()` for enhanced validation that prevents options being captured as values: `arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }`
- [BCS0803] Use `arg_num()` for numeric argument validation: `arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }`
- [BCS0803] Never shift before validating—always call the validator with `"$@"` first, then shift, then capture the value.
- [BCS0803] Use `${1@Q}` shell quoting in error messages to safely display option names with special characters.
## Parsing Location
- [BCS0804] Place argument parsing inside the `main()` function for better testability, cleaner scoping, and encapsulation.
- [BCS0804] For simple scripts (<200 lines) without a `main()` function, top-level parsing is acceptable.
- [BCS0804] Make parsed variables readonly after parsing is complete: `readonly -- VERBOSE DRY_RUN output_file`
## Short Option Bundling (Disaggregation)
- [BCS0805] Always include short option bundling support in argument parsing loops to allow `-vvn` instead of `-v -v -n`.
- [BCS0805] List all valid short options explicitly in the bundling pattern: `-[ovnVh]*)` to prevent disaggregation of unknown options.
- [BCS0805] Place the bundling case before the `-*)` invalid option case so unknown bundled options fall through correctly.
- [BCS0805] Grep method (one-liner): `set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` with `#shellcheck disable=SC2046`.
- [BCS0805] Fold method (alternative): `set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"` with `#shellcheck disable=SC2046`.
- [BCS0805] Pure bash method (recommended, 68% faster): use a while loop with `opt=${1:1}` and `new_args+=("-${opt:0:1}")` to build the expanded argument array.
- [BCS0805] Options requiring arguments cannot be bundled in the middle; document that they should be at the end of a bundle or used separately.
- [BCS0805] For high-performance scripts, prefer the pure bash method to avoid external command overhead.
## Anti-Patterns
- [BCS0801] Never use `while [[ $# -gt 0 ]]`; use `while (($#))` instead.
- [BCS0801] Never use if/elif chains for option parsing; use case statements for readability.
- [BCS0801] Never forget the `shift` at the end of the parsing loop—this causes infinite loops.
- [BCS0803] Never shift before validating option arguments; validation must inspect `$2`.
- [BCS0803] Never skip validation—`-o|--output) shift; OUTPUT=$1 ;;` silently captures `--verbose` as the filename if user forgets the argument.


---


**Rule: BCS0900**

## File Operations - Rulets
## Section Overview
- [BCS0900] File operations require safe handling practices including proper file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`), explicit path wildcards (`rm ./*` not `rm *`), process substitution (`< <(command)`) for avoiding subshell issues, and here documents for multi-line input.
## File Testing
- [BCS0901] Always quote variables and use `[[ ]]` for file tests: `[[ -f "$file" ]] && source "$file"`.
- [BCS0901] Test file existence before use and fail fast: `[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"`.
- [BCS0901] Combine readable and existence checks before sourcing: `[[ -f "$config" && -r "$config" ]] || die 3 "Config not found or not readable"`.
- [BCS0901] Use `-s` to check for non-empty files: `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS0901] Use `-nt` and `-ot` for file timestamp comparisons: `[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"`.
- [BCS0901] Use `-ef` to check if two paths reference the same file (same device and inode).
- [BCS0901] Never use `[ ]` or `test` command; always use `[[ ]]` for robust file testing.
- [BCS0901] Always catch mkdir failures: `[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: ${dir@Q}"`.
- [BCS0901] Include filename in error messages using `${var@Q}` for proper quoting in output.
## Wildcard Expansion
- [BCS0902] Always use explicit path with wildcards to prevent flag interpretation: `rm -v ./*` not `rm -v *`.
- [BCS0902] Use explicit path in for loops: `for file in ./*.txt; do process "$file"; done`.
## Process Substitution
- [BCS0903] Use `<(command)` to treat command output as a file-like input: `diff <(sort file1) <(sort file2)`.
- [BCS0903] Use `>(command)` to send output to a command as if writing to a file: `tee >(wc -l) >(grep ERROR)`.
- [BCS0903] Prefer process substitution over temp files to eliminate file management overhead.
- [BCS0903] Use `< <(command)` with while loops to avoid subshell variable scope issues: `while read -r line; do count+=1; done < <(cat file)`.
- [BCS0903] Use `readarray -t array < <(command)` to populate arrays from command output without subshell issues.
- [BCS0903] Handle special characters with null-delimited process substitution: `readarray -d '' -t files < <(find /data -type f -print0)`.
- [BCS0903] Never pipe to while loop when you need variable modifications preserved; use process substitution instead.
- [BCS0903] Use parallel processing with tee and multiple process substitutions: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) > /dev/null`.
- [BCS0903] Always quote variables inside process substitution: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS0903] For simple variable input, prefer here-strings over process substitution: `command <<< "$variable"` not `command < <(echo "$variable")`.
- [BCS0903] For simple command output to variable, use command substitution: `result=$(command)` not `result=$(cat <(command))`.
## Here Documents
- [BCS0904] Use `<<'EOF'` (single-quoted delimiter) to prevent variable expansion in here-documents.
- [BCS0904] Use `<<EOF` (unquoted delimiter) when variable expansion is needed in here-documents.
## Input Redirection Performance
- [BCS0905] Use `$(< file)` instead of `$(cat file)` for command substitution (100x+ speedup): `content=$(< file.txt)`.
- [BCS0905] Use `cmd < file` instead of `cat file | cmd` for single file input (3-4x speedup): `grep pattern < file.txt`.
- [BCS0905] In loops, prefer `$(< "$file")` over `$(cat "$file")` to avoid fork overhead multiplying per iteration.
- [BCS0905] Use `cat` when concatenating multiple files, using cat options (`-n`, `-b`, `-A`), or when `< file` alone produces no output.
- [BCS0905] Remember `< filename` alone does nothing; it only opens stdin without a command to consume it.
- [BCS0905] The exception is command substitution where bash reads file directly: `content=$(< file)` works standalone.


---


**Rule: BCS1000**

## Security Considerations - Rulets
## Overview
- [BCS1000] This section establishes security-first practices covering SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, input sanitization, and temporary file handling to prevent privilege escalation, command injection, and other attack vectors.
## SUID/SGID Prohibition
- [BCS1001] Never use SUID (`chmod u+s`) or SGID (`chmod g+s`) bits on Bash scripts; this is a critical security prohibition with no exceptions.
- [BCS1001] SUID/SGID shell scripts are vulnerable to IFS exploitation, PATH manipulation, library injection (`LD_PRELOAD`), shell expansion attacks, and race conditions.
- [BCS1001] Use `sudo` with configured `/etc/sudoers.d/` permissions instead of SUID: `username ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh`.
- [BCS1001] For compiled programs requiring specific privileges, use capabilities: `setcap cap_net_bind_service=+ep /usr/local/bin/myserver`.
- [BCS1001] When elevated script execution is absolutely required, use a compiled C setuid wrapper that sanitizes environment (`unsetenv("LD_PRELOAD"); unsetenv("IFS"); setenv("PATH", "/usr/bin:/bin", 1)`) before calling the script.
- [BCS1001] Audit systems regularly for SUID/SGID scripts: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`.
## PATH Security
- [BCS1002] Always set PATH explicitly at script start using `readonly PATH='/usr/local/bin:/usr/bin:/bin'; export PATH`.
- [BCS1002] Never include current directory (`.`), empty elements (`::`, leading `:`, trailing `:`), `/tmp`, or user home directories in PATH.
- [BCS1002] Validate PATH before use if you must accept inherited environment: `[[ "$PATH" =~ \. ]] && die 1 'PATH contains current directory'`.
- [BCS1002] For maximum security in critical scripts, use absolute paths for commands: `/bin/tar`, `/bin/rm`, `/usr/bin/systemctl`.
- [BCS1002] Verify critical commands resolve to expected locations: `command -v tar | grep -q '^/bin/tar$' || die 1 'Security: tar not from /bin/tar'`.
- [BCS1002] Check that no directories in PATH are world-writable: `find $(echo "$PATH" | tr ':' ' ') -maxdepth 0 -type d -writable 2>/dev/null`.
## IFS Safety
- [BCS1003] Never trust inherited IFS; set explicitly at script start: `IFS=$' \t\n'; readonly IFS; export IFS`.
- [BCS1003] Use subshell isolation for IFS changes: `( IFS=','; read -ra fields <<< "$data" )`.
- [BCS1003] Use one-line IFS assignment for single commands where IFS applies only to that command: `IFS=',' read -ra fields <<< "$csv_data"`.
- [BCS1003] Use `local -- IFS` in functions to scope IFS changes to that function: `local -- IFS; IFS=','`.
- [BCS1003] When manually saving/restoring IFS, always restore even on error: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`.
- [BCS1003] For reading files while preserving content exactly, use: `while IFS= read -r line; do ...; done < file.txt`.
- [BCS1003] For null-delimited input (e.g., `find -print0`), use: `while IFS= read -r -d '' file; do ...; done < <(find . -print0)`.
## Eval Command Avoidance
- [BCS1004] Never use `eval` with untrusted input; avoid `eval` entirely unless absolutely necessary.
- [BCS1004] Use arrays for dynamic command construction: `declare -a cmd=(find "$path" -type f); "${cmd[@]}"`.
- [BCS1004] Use indirect expansion instead of eval for variable references: `echo "${!var_name}"`.
- [BCS1004] Use `printf -v` for dynamic variable assignment: `printf -v "$var_name" '%s' "$value"`.
- [BCS1004] Use associative arrays for dynamic data: `declare -A data; data["$key"]="$value"; echo "${data[$key]}"`.
- [BCS1004] Use case statements or associative arrays for function dispatch instead of eval: `case "$action" in start) start_function ;; esac`.
- [BCS1004] For arithmetic with user input, validate strictly first: `[[ "$expr" =~ ^[0-9+\-*/\ ()]+$ ]] && result=$((expr))`.
## Input Sanitization
- [BCS1005] Always validate and sanitize user input before use; fail early with clear error messages.
- [BCS1005] Use whitelist validation (define what IS allowed) rather than blacklist (what isn't): `[[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 'Invalid filename'`.
- [BCS1005] Sanitize filenames by removing directory traversal and restricting characters: `name="${name//\.\./}"; name="${name//\//}"; [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]]`.
- [BCS1005] Validate paths are within allowed directories using realpath: `real_path=$(realpath -e -- "$input"); [[ "$real_path" == "$allowed_dir"* ]] || die 5 'Path outside allowed directory'`.
- [BCS1005] Validate integers with regex: `[[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: $input"`.
- [BCS1005] Validate against whitelists using array lookup: `for choice in "${valid_choices[@]}"; do [[ "$input" == "$choice" ]] && return 0; done; die 22 'Invalid choice'`.
- [BCS1005] Always use `--` separator before file arguments to prevent option injection: `rm -- "$user_file"`.
- [BCS1005] Never pass user input directly to shell commands without validation; use case statements for command selection.
## Temporary File Handling
- [BCS1006] Always use `mktemp` to create temporary files and directories; never hard-code temp file paths like `/tmp/myapp.txt`.
- [BCS1006] Always set up cleanup trap immediately after creating temp files: `temp_file=$(mktemp) || die 1 'Failed to create temp file'; trap 'rm -f "$temp_file"' EXIT`.
- [BCS1006] For temp directories, use `mktemp -d` and `rm -rf` in cleanup: `temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT`.
- [BCS1006] Check mktemp success before using temp file: `temp_file=$(mktemp) || die 1 'Failed to create temp file'`.
- [BCS1006] Use custom templates for recognizable temp files: `temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)`.
- [BCS1006] For multiple temp files, use array and cleanup function: `declare -a TEMP_FILES=(); cleanup() { for f in "${TEMP_FILES[@]}"; do rm -f "$f"; done }; trap cleanup EXIT`.
- [BCS1006] Make temp file variables readonly after assignment to prevent accidental modification: `readonly -- temp_file`.
- [BCS1006] Default mktemp permissions are secure (0600 for files, 0700 for directories); don't weaken them.
- [BCS1006] Add `--keep-temp` option for debugging: `((KEEP_TEMP)) && info "Keeping temp files" && return` in cleanup function.
- [BCS1006] Handle signals for cleanup: `trap cleanup EXIT SIGINT SIGTERM`.


---


**Rule: BCS1100**

## Concurrency & Jobs - Rulets
## Background Job Management
- [BCS1101] Start background jobs with `&` and immediately capture PID: `command & pid=$!`; never leave background processes untracked.
- [BCS1101] Track multiple background PIDs in an array: `pids+=($!)` after each background command.
- [BCS1101] Check if a process is running using signal 0: `kill -0 "$pid" 2>/dev/null`.
- [BCS1101] Always set up cleanup trap for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` to kill remaining processes on script exit.
- [BCS1101] Never use `$$` to reference background job PID; use `$!` which captures the last background process ID.
- [BCS1101] Prevent trap recursion by resetting traps at start of cleanup: `trap - SIGINT SIGTERM EXIT`.
## Parallel Execution
- [BCS1102] Capture parallel output to temp files then display in order: write each job's output to `"$temp_dir/$identifier.out"`, wait for all, then cat in sequence.
- [BCS1102] Implement concurrency limits by checking `${#pids[@]} >= max_jobs` and calling `wait -n` before spawning new jobs.
- [BCS1102] Never modify parent variables from background subshells; use temp files to collect results: `echo 1 >> "$temp_dir"/count` then `wc -l < "$temp_dir"/count`.
- [BCS1102] Clean up temp directories with EXIT trap: `trap 'rm -rf "$temp_dir"' EXIT`.
## Wait Patterns
- [BCS1103] Always capture wait exit code: `wait "$pid"; exit_code=$?`; never ignore the return value.
- [BCS1103] Track errors when waiting for multiple jobs: `for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done`.
- [BCS1103] Use `wait -n` (Bash 4.3+) to process jobs as they complete rather than waiting for all.
- [BCS1103] Update active PID list after `wait -n` by checking which PIDs still respond to `kill -0`.
- [BCS1103] Collect exit codes in associative array for per-job error reporting: `exit_codes[$server]=$?`.
## Timeout Handling
- [BCS1104] Always use `timeout` for network operations and potentially hanging commands: `timeout 30 long_running_command`.
- [BCS1104] Handle timeout exit code 124 specifically: `((exit_code == 124))` indicates the command timed out.
- [BCS1104] Use `--kill-after` for graceful shutdown: `timeout --signal=TERM --kill-after=10 60 command` sends SIGTERM first, SIGKILL after grace period.
- [BCS1104] Know timeout exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=killed by SIGKILL.
- [BCS1104] Use `read -t` for user input timeouts: `read -r -t 10 -p 'Prompt: ' var || var='default'`.
- [BCS1104] Set SSH connection timeouts: `ssh -o ConnectTimeout=10 -o BatchMode=yes "$server"`.
## Exponential Backoff
- [BCS1105] Implement exponential delay between retries: `delay=$((2 ** attempt))` doubles wait time each attempt.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Never use fixed-delay retry loops; always increase delay exponentially to reduce load on failing services.
- [BCS1105] Set maximum retry attempts and fail explicitly: `((attempt > max_attempts)) && die 1 'Max retries exceeded'`.
- [BCS1105,BCS1104] Combine timeout with backoff for robust network operations: wrap timed commands in retry loops with exponential delays.


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


---


**Rule: BCS1200**

## Style & Development - Rulets
## Code Formatting
- [BCS1201] Use 2 spaces for indentation, never tabs; maintain consistent indentation throughout the script.
- [BCS1201] Keep lines under 100 characters; long file paths and URLs may exceed this limit when necessary.
- [BCS1201] Use line continuation with `\` for long commands that would otherwise exceed line length limits.
## Comments
- [BCS1202] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT (which the code already shows).
- [BCS1202] Good comment patterns: explain non-obvious business rules, document intentional deviations, clarify complex logic, note why specific approaches were chosen, warn about gotchas.
- [BCS1202] Avoid commenting: simple variable assignments, obvious conditionals, standard patterns, self-explanatory code with good naming.
- [BCS1202] Use 80-dash section separators for major script divisions: `# --------------------------------------------------------------------------------`
- [BCS1202] Use only these documentation icons: info `◉`, debug `⦿`, warn `▲`, success `✓`, error `✗`; avoid other emoticons unless justified.
## Blank Line Usage
- [BCS1203] Use one blank line between functions, between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1203] Place blank lines before and after multi-line conditional or loop blocks for visual separation.
- [BCS1203] Avoid multiple consecutive blank lines (one is sufficient); no blank line needed between short, related statements.
## Section Comments
- [BCS1204] Use lightweight section comments with simple `# Description` format (no dashes, no box drawing) to organize code into logical groups.
- [BCS1204] Keep section comments short (2-4 words): `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`.
- [BCS1204] Place section comment immediately before the group it describes; follow with a blank line after the group.
- [BCS1204] Reserve 80-dash separators for major script divisions only; use section comments for grouping related variables, functions, or logical blocks.
## Language Practices
- [BCS1205] Always use `$()` for command substitution, never backticks: `var=$(command)` not `` var=`command` ``
- [BCS1205] Prefer shell builtins over external commands for 10-100x performance improvement: `$((x + y))` not `$(expr $x + $y)`.
- [BCS1205] Use builtin string operations: `${path##*/}` for basename, `${path%/*}` for dirname, `${var^^}` for uppercase, `${var,,}` for lowercase.
- [BCS1205] Use `[[ ]]` instead of `[ ]` for conditionals; use brace expansion `{1..10}` or `for ((i=1; i<=10; i+=1))` instead of `seq`.
- [BCS1205] External commands are acceptable when no builtin equivalent exists: `sha256sum`, `whoami`, `sort`.
## Development Practices
- [BCS1206] ShellCheck is compulsory for all scripts; use `#shellcheck disable=SC####` only for documented exceptions with reason comments.
- [BCS1206] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1206] Use defensive programming: provide default values with `: "${VAR:=default}"`, validate inputs early with `[[ -n "$1" ]] || die 1 'Argument required'`.
- [BCS1206] Minimize subshells, use built-in string operations, batch operations when possible, use process substitution over temp files.
- [BCS1206] Make functions testable: use dependency injection for external commands, support verbose/debug modes, return meaningful exit codes.
## Debugging
- [BCS1207] Implement debug mode with `declare -i DEBUG="${DEBUG:-0}"` and enable trace with `((DEBUG)) && set -x ||:`
- [BCS1207] Use enhanced PS4 for better trace output: `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '`
- [BCS1207] Implement conditional debug output: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`
- [BCS1207] Run scripts with debug output using: `DEBUG=1 ./script.sh`
## Dry-Run Mode
- [BCS1208] Declare dry-run flag as `declare -i DRY_RUN=0`; parse with `-n|--dry-run) DRY_RUN=1 ;;` and `-N|--not-dry-run) DRY_RUN=0 ;;`
- [BCS1208] In functions that modify state: check `((DRY_RUN))` first, display preview message with `[DRY-RUN]` prefix using `info`, return 0 early.
- [BCS1208] Dry-run pattern maintains identical control flow—same function calls, same logic paths—making it easy to verify logic without side effects.
## Testing Support
- [BCS1209] Use dependency injection for testability: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` then override in tests.
- [BCS1209] Implement test mode flag: `declare -i TEST_MODE="${TEST_MODE:-0}"` with conditional behavior for test vs production paths.
- [BCS1209] Use assert function pattern: `assert() { [[ "$1" == "$2" ]] || { >&2 echo "ASSERT FAIL: ${3:-Assertion failed}"; return 1; }; }`
- [BCS1209] Implement test runner: iterate over functions matching `test_*` pattern, track passed/failed counts, return `((failed == 0))`.
## Progressive State Management
- [BCS1210] Declare all boolean flags at the top with initial values: `declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0`
- [BCS1210] Use separate flags for user intent vs. runtime state: `BUILTIN_REQUESTED` tracks original request, `INSTALL_BUILTIN` tracks current state.
- [BCS1210] Apply state changes in logical order: parse → validate → execute; progressively disable features when prerequisites fail or operations error.
- [BCS1210] Never modify flags during execution phase—only in setup/validation; execute actions based on final flag state.
- [BCS1210] Use fail-safe pattern: `((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0` disables feature on failure.
#fin
