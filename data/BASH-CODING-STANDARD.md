# Bash Coding Standard (BCS)

**Concise, actionable coding rules for BCS Bash 5.2+**

Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).
Target audience: both human programmers and AI assistants.

[BCS Bash 5.2 Reference](/ai/scripts/Okusi/BCS/docs/BCS-bash/index.md) -- the `bash(1)` man page rewritten for BCS assumptions (`set -euo pipefail`, `[[ ]]` only, no POSIX compat, etc).

[Example exemplar BCS-compliant scripts directory](/ai/scripts/Okusi/BCS/examples/)

Templates for new scripts: [complete.sh.template](/ai/scripts/Okusi/BCS/examples/templates/complete.sh.template), [basic.sh.template](/ai/scripts/Okusi/BCS/examples/templates/basic.sh.template), [minimal.sh.template](/ai/scripts/Okusi/BCS/examples/templates/minimal.sh.template), [library.sh.template](/ai/scripts/Okusi/BCS/examples/templates/library.sh.template)

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler."
- **Critical:** Do not over-engineer scripts; **remove unused functions and variables**

## Contents
01. Script Structure & Layout
02. Variables & Data Types
03. Strings & Quoting
04. Functions & Libraries
05. Control Flow
06. Error Handling
07. I/O & Messaging
08. Command-Line Arguments
09. File Operations
10. Security
11. Concurrency & Jobs
12. Style & Development

---

# Section 01: Script Structure & Layout

## BCS0100 Section Overview

Every BCS-compliant script follows a 13-step structure. Scripts must be self-contained, predictable, and safe. This section defines the canonical ordering and required elements.

## BCS0101 Strict Mode

`set -euo pipefail` is *mandatory* before script execution starts, and must be the first executable command after shebang, comments, and shellcheck directives.

```bash
# correct
#!/usr/bin/bash
#shellcheck disable=SC???? # (optional)
# Brief description (recommended)
set -euo pipefail
shopt -s inherit_errexit

# wrong — strict mode after variable declarations
#!/usr/bin/bash
declare -r VERSION=1.0.0
set -euo pipefail
```

Add `shopt -s inherit_errexit` immediately after.

- `inherit_errexit`: makes `set -e` work in command substitutions (critical)

**When appropriate**, the following setting could also be added:

- `shift_verbose`: makes `shift` fail visibly when no args remain
- `extglob`: enables `@()`, `!()`, `+()` patterns
- `nullglob`: unmatched globs expand to nothing instead of literal string

Choose `failglob` instead of `nullglob` for strict scripts where unmatched globs should be errors.

## BCS0102 Shebang

First line of any script must be a shebang. Three acceptable forms:

```bash
#!/usr/bin/bash       # Preferred for Linux systems
#!/bin/bash           # Acceptable
#!/usr/bin/env bash   # Maximum portability
```

*Any* one of these shebangs are acceptable.

Follow with optional `#shellcheck` or `#bcscheck` directives, then a brief description comment.

```bash
#!/usr/bin/bash
#shellcheck disable=SC2015
# myscript - brief description of what this script does
set -euo pipefail
shopt -s inherit_errexit
```

## BCS0103 Script Metadata

Declare metadata immediately after `shopt`. Use `realpath` (not `readlink`).

Standard metavars are VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME

**Note:** Not all scripts will require all Script Metadata variables.

```bash
# correct
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# wrong — readlink, separate readonly
#shellcheck disable=SC2155
SCRIPT_PATH=$(readlink -f "$0")
readonly SCRIPT_PATH
```

Use `#shellcheck disable=SC2155` before the `SCRIPT_PATH` line. The failure mode (command doesn't exist) should cause immediate termination anyway.

## BCS0104 FHS Compliance

Search for resources in FHS order:

```bash
# correct — FHS search path
local -a search_paths=(
  "$SCRIPT_DIR"/data
  "$PREFIX"/share/myapp/data
  /usr/local/share/myapp/data
  /usr/share/myapp/data
)
for dir in "${search_paths[@]}"; do
  [[ -d $dir ]] && { DATA_DIR="$dir"; break; }
done
```

Support `PREFIX` customization and XDG directories:

```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=${XDG_CONFIG_HOME:-"$HOME"/.config}/myapp
```

## BCS0105 Global Variables and Colors

Declare all global variables up front with explicit types.

```bash
# correct
declare -i VERBOSE=1 DEBUG=0 DRY_RUN=0
declare -- OUTPUT_DIR='./output'
declare -a FILES=()

# wrong — no type, scattered declarations
VERBOSE=1
# ... 50 lines later ...
DEBUG=0
```

Define colors conditionally on terminal detection:

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

Always check BOTH stdout AND stderr: `[[ -t 1 && -t 2 ]]`.

## BCS0106 File Extensions and Dual-Purpose Scripts

Executables: `.sh` extension or no extension. Globally available executables via PATH must have no extension. Libraries must have `.sh` or `.bash` extension and should not be executable.

**Dual-purpose scripts** (can be sourced or executed) use a source fence to separate library functions from script mode. Either fence pattern is acceptable:

```bash
# correct — BASH_SOURCE fence (supports conditional actions in the guard)
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# correct — return 0 fence (single builtin, also valid in POSIX sh)
return 0 2>/dev/null ||:
```

Define functions above the fence, strict mode and mainline below:

```bash
# correct — dual-purpose script
my_function() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx my_function

# --- source fence ---
return 0 2>/dev/null ||:

# --- Script mode only below ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

Never apply `set -euo pipefail` when sourced — it alters the calling shell's environment.

See also: [Source Guard Reference](/ai/scripts/Okusi/BCS/benchmarks/source-guard-reference.md) — full comparison of source fence mechanisms with benchmark data.

## BCS0107 Function Organization

Organize functions bottom-up in 7 layers:

1. Messaging functions (lowest level)
2. Documentation functions (help, usage)
3. Helper/utility functions
4. Validation functions
5. Business logic functions
6. Orchestration/flow functions
7. `main()` function (highest level)

```bash
# correct — bottom-up, each function calls only previously defined functions
_msg() { :; }
info() { _msg "$@"; }
show_help() { cat <<HELP
...
HELP
}
validate_input() { :; }
process_file() { validate_input "$1"; }
main() { process_file "$@"; }
main "$@"
#fin
```

Never define `main()` at the top. Never define business logic before the utilities it calls. In some cases, nested functions are permissible within other functions.

## BCS0108 Main Function and Script Invocation

Generally, use `main()` for scripts over ~200 lines. Parse arguments within `main()`, then make configuration variables readonly after parsing.

```bash
# correct
main() {
  while (($#)); do case $1 in
    -n|--dry-run)     DRY_RUN=1 ;;
    -N|--not-dry-run) DRY_RUN=0 ;;
    -v|--verbose)     VERBOSE=1 ;;
    -q|--quiet)       VERBOSE=0 ;;
  esac; shift; done
  readonly VERBOSE DRY_RUN

  # Business logic here
  : ...
}

main "$@"
#fin
```

Always quote `"$@"` to preserve the argument array. Scripts under 200 lines may run directly without `main()`.

## BCS0109 End Marker

Every script must end with `#fin\n` OR `#end\n` as the mandatory final line.

```bash
# correct — last line of file
main "$@"
#fin

```

```bash
# wrong — missing end marker, or extra content after
main "$@"
```

The end marker confirms the file is complete and not truncated.

## BCS0110 Cleanup and Traps

Scripts requiring cleanup must define the cleanup function and set the trap before any code that creates temporary resources.

```bash
# correct
declare -- TEMP_DIR
#...
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  [[ -z ${TEMP_DIR:-} ]] || rm -rf "$TEMP_DIR"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
#...
TEMP_DIR=$(mktemp -d)
```

Always disable traps inside the cleanup function to prevent recursion.

## BCS0111 Configuration File Loading

Use `read_conf()` to source the first matching `.conf` file from a priority-ordered search path. User configuration overrides system defaults.

```bash
# correct — standard read_conf() function
read_conf() {
  local -- conf_file=''
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-$HOME/.config}"/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME".conf
    /usr/local/etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/share/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/lib/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  )

  for conf_file in "${search_paths[@]}"; do
    if [[ -f $conf_file ]]; then
      # shellcheck source=/dev/null
      source "$conf_file"
      return 0
    fi
  done

  return 1
}
```

Search path priority (first match wins):

1. `$XDG_CONFIG_HOME/name/name.conf` — user config (XDG standard)
2. `/etc/name/name.conf` — system config (directory)
3. `/etc/name.conf` — system config (flat file)
4. `/usr/local/etc/name/name.conf` — locally-installed defaults
5. `/usr/share/name/name.conf` — package-provided defaults
6. `/usr/lib/name/name.conf` — library-provided defaults

Call `read_conf` early in `main()`, before argument parsing if config values set defaults, or after parsing if CLI options should override config:

```bash
# correct — config sets defaults, CLI overrides
main() {
  read_conf ||:
  while (($#)); do case $1 in
    # options override config values...
    : ...
  esac; shift; done
}
```

Configuration files are sourced as Bash — they execute in the calling shell's context. Only source config files from trusted locations with appropriate permissions.

---

# Section 02: Variables & Data Types

## BCS0200 Section Overview

**All variables must have explicit type declarations.** This section covers declaration patterns, scoping, naming conventions, arrays, parameter expansion, and boolean flags.

## BCS0201 Type-Specific Declarations

Use explicit type declarations to make variable intent clear.

```bash
# correct
declare -i count=0           # integer
declare -- filename=''       # string (semantic; see note)
declare -a files=()          # indexed array
declare -A config=()         # associative array
declare -r VERSION=1.0.0     # readonly constant string
local -- path=$1             # local string
local -i retval=0            # local integer

# wrong — no type, no separator
count=0
local filename=$1
```

The `--` separator for string variable types is **purely semantic** -- it signals a conscious variable type choice, completing the pattern alongside `-i`, `-a`, and `-A`.

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
readonly MAX_RETRIES=3                # UPPER_CASE for constants/globals
declare -i VERBOSE=1                  # UPPER_CASE for global state

process_log_file() {                  # lower_case for functions
  local -- file_count=0               # lower_case for locals
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

---

# Section 03: Strings & Quoting

## BCS0300 Section Overview

Single quotes signal "literal text"; double quotes signal "shell processing needed." This semantic distinction clarifies intent for both developers and AI assistants.

## BCS0301 Quoting Fundamentals

Use single quotes for static strings. Use double quotes only when variable expansion is needed.

```bash
# correct
info 'Checking prerequisites...'
info "Processing $count files"
die 1 "Unknown option ${1@Q}"
EMAIL='user@domain.com'
VAR=''

# wrong — double quotes for static string
info "Checking prerequisites..."
EMAIL="user@domain.com"
VAR=""
```

One-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted: `STATUS=success`, `[[ "$level" == INFO ]]`. When in doubt, quote everything.

In general, quote variable portions separately from literal path components for clarity:

```bash
# recommended — clear boundaries
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"

# acceptable but less clear
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

## BCS0302 Command Substitution

Use double quotes when strings include command substitution.

```bash
# correct
echo "Current time: $(date +%T)"
result=$(git describe --tags)        # simple assignment, quotes optional
VERSION="$(git describe)".beta       # concatenation needs quotes
echo "$result"                       # always quote when using

# wrong
echo $result                         # unquoted usage
```

## BCS0303 Quoting in Conditionals

Inside `[[ ]]`, **no word splitting or pathname expansion occurs** — variables are safe unquoted in any position. Quoting only matters for the right-hand side of `==`/`!=` (where it controls pattern vs literal matching) and `=~` (where it disables regex).

```bash
# correct — all unquoted forms are safe inside [[ ]]
[[ -f $file ]]
[[ -d $dir && -r $dir ]]
[[ $name == "$expected" ]]           # quoted RHS: literal comparison
[[ $mode == production ]]            # static value, quotes optional

# correct — glob matching (right side unquoted)
[[ $filename == *.txt ]]

# correct — regex (right side unquoted)
[[ $email =~ ^[a-z]+@[a-z]+$ ]]

# wrong
[ -f $file ]                         # **never** use [ ]; it requires quoting
[[ $input =~ "$pattern" ]]           # quoted regex disables matching
```

## BCS0304 Here Documents

Use quoted delimiter `<<'EOF'` for literal content. Use unquoted delimiter `<<EOF` for variable expansion. Use descriptive names for the delimiter.

```bash
# correct — no expansion needed
cat <<'VARS'
Variables like $HOME are literal text.
VARS

# correct — expansion needed
cat <<EOT
Hello $USER, your home is $HOME
EOT

# correct — indented (strips leading tabs, not spaces)
if true; then
	cat <<-CONTENT
	indented content
	CONTENT
fi
```

Quote here-doc delimiters for JSON, SQL, or any content with `$` characters.

## BCS0305 Printf Patterns

Use single quotes for format strings, double quotes for variable arguments.

```bash
# correct
printf '%s: %d files\n' "$name" "$count"
printf 'Line1\nLine2\n'

# wrong
echo -e "Line1\nLine2"              # inconsistent escape handling
```

Use `$'...'` syntax as an alternative for escape sequences: `echo $'Line1\nLine2'`.

## BCS0306 Parameter Quoting with @Q

Use `${parameter@Q}` to safely display user input in error messages.

```bash
# correct
die 22 "Invalid option ${1@Q}"
error "File not found ${file@Q}"
info "[DRY-RUN] Would execute ${cmd@Q}"

# wrong — no safe quoting for display
die 22 "Invalid option $1"          # special chars break output
die 2 "Invalid argument '$1'"       # special chars break output
```

Never use `@Q` for normal variable expansion or comparisons.

## BCS0307 Anti-Patterns

```bash
# wrong — double quotes for static strings
info "Starting backup..."           # use single quotes
echo "${HOME}/bin"                  # unnecessary braces

# wrong — unquoted variables
echo $result
rm $temp_file
for item in ${items[@]}

# correct
info 'Starting backup...'
echo "$HOME"/bin
echo "$result"
rm "$temp_file"
for item in "${items[@]}"
```

Use braces only when required: `${var:-default}`, `${file##*/}`, `${array[@]}`, `${var1}${var2}`.

---

# Section 04: Functions & Libraries

## BCS0400 Section Overview

Organize functions bottom-up: messaging first, then helpers, then business logic, with `main()` last. Each function can safely call previously defined functions.

## BCS0401 Function Definition

Use single-line format for simple operations, multi-line for complex functions.

```bash
# correct — single-line
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# correct — multi-line
process_file() {
  local -- filename=$1
  local -i line_count=0

  [[ -f $filename ]] || return 1

  while IFS= read -r line; do
    line_count+=1
  done < "$filename"

  return 0
}
```

Declare local variables before use, grouped near the function top when practical. Declarations may appear mid-body (e.g., after early-return guards, inside conditionals, or between logical sections), but must not appear inside loops. Always use proper types and `return` explicitly from complex functions.

## BCS0402 Function Names

```bash
# correct
process_log_file() { :; }           # lowercase with underscores
_validate_input() { :; }            # underscore prefix for private

# wrong
ProcessLogFile() { :; }             # camelCase
PROCESS_FILE() { :; }               # UPPER_CASE
my-function() { :; }                # dashes (invalid in some contexts)
cd() { :; }                         # overriding built-in
```

Never use dashes in function names. Never override built-in commands without good reason.

## BCS0403 Main Function

Include `main()` for scripts longer than ~200 lines. Place `main "$@"` at the bottom just before `#fin`.

```bash
# correct
main() {
  # Parse arguments
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)    show_help; exit 0 ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac; shift; done

  # Make parsed variables readonly
  readonly VERBOSE DRY_RUN

  # Business logic
  process_files
}

main "$@"
#fin
```

Always call main with all arguments: `main "$@"`, never just `main`.

## BCS0404 Function Export

Export functions needed by subshells with `declare -fx`.

```bash
# correct — define first, then export
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

## BCS0405 Production Optimization

Remove unused utility functions from production scripts.

```bash
# wrong — keeping unused functions
yn() { :; }          # never called in this script
trim() { :; }        # never called in this script
debug() { :; }       # DEBUG never set in this script
```

Keep only functions and variables the script actually needs. Remove unused globals too.

## BCS0406 Dual-Purpose Scripts

For scripts that can be sourced or executed, define functions before the source fence and strict mode after it. Either fence pattern is acceptable:

```bash
# correct — BASH_SOURCE fence with conditional export
my_function() {
  local -- name=$1
  echo "Hello, $name"
}

# --- source fence ---
[[ ${BASH_SOURCE[0]} == "$0" ]] || { declare -fx my_function; return 0; }

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

```bash
# correct — return 0 fence (export unconditionally before fence)
my_function() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx my_function

return 0 2>/dev/null ||:

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

Use idempotent initialization with version guard:

```bash
[[ -v MY_LIB_VERSION ]] || {
  declare -rx MY_LIB_VERSION=1.0.0
  # other initialization
}
```

## BCS0407 Library Patterns

Pure libraries must reject direct execution.

```bash
# correct — library pattern
[[ ${BASH_SOURCE[0]} != "$0" ]] || {
  >&2 echo "Error: ${0@Q} must be sourced"
  exit 1
}

declare -rx LIB_VALIDATION_VERSION=1.0.0

# Namespace all functions
myapp_init() { :; }
myapp_cleanup() { :; }
myapp_process() { :; }
declare -fx myapp_init myapp_cleanup myapp_process
```

Libraries should only define functions, not have side effects on source. Allow configuration override before sourcing: `: "${CONFIG_DIR:=/etc/myapp}"`.

Source libraries with existence check:

```bash
[[ -f $lib_path ]] && source "$lib_path" || die 1 "Missing library ${lib_path}"
```

## BCS0408 Dependency Management

Use `command -v` for dependency checks, never `which`. POSIX/coreutils commands guaranteed on any Bash 5.2+ system (e.g., `sed`, `awk`, `grep`, `cat`, `date`, `tput`, `wc`, `stty`, `mkdir`, `rm`, `cp`, `mv`) do not require checks — only verify non-standard or separately packaged tools.

```bash
# correct — check non-standard tools
command -v curl >/dev/null || die 18 'curl required: apt install curl'

# correct — check multiple non-standard tools
for cmd in curl jq pandoc; do
  command -v "$cmd" >/dev/null || die 18 "Required: ${cmd@Q}"
done

# correct — optional dependency
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:

# correct — check bash version
((BASH_VERSINFO[0] >= 5 && BASH_VERSINFO[1] >= 2)) || die 1 'Requires Bash 5.2+'

# wrong — using which
which curl &>/dev/null

# wrong — checking coreutils commands
command -v sed >/dev/null || die 18 'sed required'
```

Use lazy loading for expensive resources: initialize only when first needed.

---

# Section 05: Control Flow

## BCS0500 Section Overview

Use `[[ ]]` for string and file tests, `(())` for arithmetic. Never use `[ ]`. This section covers conditionals, case statements, loops, arithmetic, and floating-point operations.

## BCS0501 Conditionals

```bash
# correct — [[ ]] for strings/files, (()) for arithmetic
[[ -f $file ]]
[[ $name == "$expected" ]]
((count > 5))

# correct — arithmetic truthiness
((count))                            # true if non-zero
((VERBOSE)) || return 0

# correct — pattern matching
[[ $file == *.txt ]]                 # glob
[[ $input =~ ^[0-9]+$ ]]             # regex

# correct — short-circuit
[[ -f $file ]] && source "$file"
command -v curl >/dev/null || die 18 'curl required'

# wrong
[ -f "$file" ]                       # never use [ ]
((count > 0))                        # use ((count)) instead
((VERBOSE == 1))                     # use ((VERBOSE)) instead
```

## BCS0502 Case Statements

Use `case` for multi-way branching on a single variable.

```bash
# correct — no quotes on case expression or literal patterns
case ${1:-} in
  start)          start_service ;;
  stop)           stop_service ;;
  help|-h|--help) show_help ;;
  *.txt|*.md)     process_text "$1" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              die 2 "Unknown command ${1@Q}" ;;
esac

# wrong
case "${1:-}" in                     # unnecessary quotes on expression
  "start")                           # unnecessary quotes on pattern
```

Always include default case `*)`  to handle unexpected values. Align actions consistently for readability. Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`.

## BCS0503 Loops

```bash
# correct — for with arrays and globs
for file in "${files[@]}"; do
  process "$file"
done
for f in ./*.txt; do
  echo "$f"
done

# correct — while for argument parsing
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done

# correct — while for reading input
while IFS= read -r line; do
  process "$line"
done < "$input_file"

# correct — C-style loop
for ((i=0; i<10; i+=1)); do
  echo "$i"
done

# wrong
for f in $(ls *.txt); do             # never parse ls
for ((i=0; i<10; i++)); do           # never use i++
while (($# > 0)); do                 # use (($#)) instead
```

Declare local variables before loops, not inside:

```bash
# correct
local -- file
for file in ./*.txt; do process "$file"; done

# wrong
for file in ./*.txt; do local -- file; done
```

Use `while ((1))` for infinite loops — it is pure arithmetic evaluation with no command lookup or dispatch, making it the fastest construct (~14% faster than `while :`, ~21% faster than `while true` at 1M iterations).

```bash
# correct — arithmetic evaluation, fastest
while ((1)); do
  process_item || break
done

# acceptable — special builtin, POSIX-compatible
while :; do
  process_item || break
done

# wrong — unquoted variable expansion as command (fragile, dangerous)
running=true
while $running; do
  running=false
done

# wrong — unnecessary string comparison on constants
while [[ 1 == 1 ]]; do
  break
done
```

The flag-variable pattern (`while $running`) executes the variable content as a command — if it contains anything other than `true` or `false`, arbitrary code runs. Use arithmetic flags instead:

```bash
# correct — arithmetic flag, safe
local -i running=1
while ((running)); do
  # ...
  running=0
done
```

Use `break N` for nested loops (`break 2` exits two enclosing levels).

See also: [While Loops Reference](/ai/scripts/Okusi/BCS/benchmarks/while-loops-reference.md) — full benchmark data and analysis of `while ((1))` vs `while :` vs `while true`.

## BCS0504 Process Substitution

Never pipe to while loops — pipes create subshells where variable modifications are lost.

```bash
# correct — process substitution preserves variables
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep -c '' "$file")

# correct — readarray for collecting lines
readarray -t lines < <(find . -name '*.txt')

# correct — null-delimited for special filenames
while IFS= read -r -d '' file; do
  process "$file"
done < <(find /data -type f -print0)

# wrong — subshell loses count
grep '' "$file" | while read -r line; do
  count+=1
done
# count is still 0 here!
```

Use here-string `<<< "$var"` when input is already in a variable.

## BCS0505 Arithmetic Operations

Always declare integer variables with `declare -i` or `local -i` before arithmetic.

```bash
# correct
declare -i count=0
count+=1                             # increment

# correct — arithmetic conditional
((count > 10)) && warn 'High count'
((result = x + y))                   # no $ needed inside (())

# wrong — NEVER use any form of ++
((count++))
((++count))
count++
((count+=1))                         # use plain count+=1
```

Use `i+=1` for ALL increments. Integer division truncates: `((10 / 3))` equals 3.

## BCS0506 Floating-Point Operations

Bash only supports integer arithmetic. Use `bc -l` or `awk` for floating-point.

```bash
# correct
result=$(echo 'scale=2; 10 / 3' | bc -l)
result=$(awk -v a="$a" -v b="$b" 'BEGIN {printf "%.2f", a * b}')

# correct — float comparison
if (($(echo "$a > $b" | bc -l))); then
  echo 'a is greater'
fi

# wrong
[[ "$a" > "$b" ]]                    # string comparison, not numeric
```

---

# Section 06: Error Handling

## BCS0600 Section Overview

Error handling covers strict mode, exit codes, traps, return value checking, and error suppression patterns. Every script must fail safely and provide clear error context.

## BCS0601 Exit on Error

`set -euo pipefail` provides three protections: `-e` exits on command failure, `-u` exits on undefined variables, `-o pipefail` fails pipeline if any command fails.

```bash
# correct — allow expected failures
command_that_might_fail || true
if command_that_might_fail; then
  process_result
fi

# correct — handle undefined optional variables
"${OPTIONAL_VAR:-}"

# correct — capture failing command safely
if result=$(failing_command); then
  echo "$result"
fi
output=$(cmd) || die 1 'cmd failed'

# wrong
set +e                               # never disable broadly
command
set -e
```

## BCS0602 Exit Codes

Use `die()` as the standard exit function.

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

Standard exit codes:

| Code | Use Case |
|------|----------|
| 0 | Success |
| 1 | General error |
| 2 | Usage / argument error |
| 3 | File/directory not found |
| 5 | I/O error |
| 8 | Required argument missing |
| 13 | Permission denied |
| 18 | Missing dependency |
| 19 | Configuration error |
| 22 | Invalid argument |
| 24 | Timeout |

```bash
# correct — include context
die 3 "Config not found ${config@Q}"
die 22 "Invalid option ${1@Q}"

# wrong — no context
die 3 'File not found'
```

Reserved: 64-78 (sysexits), 126 (cannot execute), 127 (not found), 128+n (signals).

## BCS0603 Trap Handling

Install cleanup traps early, before creating any resources.

```bash
# correct
declare -- TEMP_FILE
#...
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT         # prevent recursion
  [[ -z ${TEMP_FILE:-} ]] || rm -f "$TEMP_FILE"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
#...
TEMP_FILE=$(mktemp)
readonly TEMP_FILE
```

Use single quotes for trap commands to delay variable expansion. Use `||:` for cleanup operations that might fail.

```bash
# correct — single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# correct — kill background processes in cleanup
((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:

# wrong — double quotes expand immediately
trap "rm -f $temp_file" EXIT
```

Never combine multiple traps for the same signal (replaces previous). Use a single trap with a cleanup function.

## BCS0604 Checking Return Values

Always check return values of critical operations.

```bash
# correct
mv "$file" "$dest" || die 1 "Failed to move ${file@Q}"
output=$(command) || die 1 'Command failed'

# correct — command group with cleanup on failure
cp "$src" "$dst" || {
  rm -f "$dst"
  die 1 'Copy failed'
}

# correct — check PIPESTATUS for pipelines
sort "$file" | uniq > "$output"
((PIPESTATUS[0] == 0)) || die 1 'Sort failed'

# correct — check $? immediately
cmd1
local -i result=$?
```

## BCS0605 Error Suppression

Only suppress errors when failure is expected, non-critical, and explicitly safe to ignore.

```bash
# correct — safe to suppress
command -v optional_tool &>/dev/null
rm -f /tmp/optional_*
rmdir "$maybe_empty" 2>/dev/null ||:

# correct — suppress message but check return
if result=$(command 2>/dev/null); then
  process "$result"
fi

# wrong — suppressing critical operations
cp "$src" "$dst" 2>/dev/null || true
set +e                               # never disable broadly
```

Verify system state after suppressed operations when possible.

## BCS0606 Conditional Declarations

Prefer inverting the condition with `||` over `((condition)) && action ||:`.

```bash
# preferred — inverted condition avoids ||: entirely
((width >= 20)) || width=20
((padding >= 0)) || padding=0
((color_count < 256)) || HAS_COLOR=1

# acceptable — when && reads more naturally
((DRY_RUN)) && info 'Dry-run mode' ||:
((VERBOSE)) && echo "Processing $file" ||:
((DEBUG)) && set -x ||:

# wrong — exits script when condition is false under set -e
((DRY_RUN)) && info 'Dry-run mode'
```

A false arithmetic condition returns exit code 1, which triggers `set -e`. The inverted `||` form avoids this because the right-hand side (an assignment or command) returns 0. When `&&` reads more naturally (e.g., flag-guarded actions), append `||:` to make the expression safe. Use `:` over `true` (traditional shell idiom, built-in).

Never use `||:` for critical operations that must succeed.

---

# Section 07: I/O & Messaging

## BCS0700 Section Overview

All status messages go to stderr. Only data output goes to stdout. This separation enables script composition and piping.

## BCS0701 Message Control Flags

Declare message control flags as integers at script start.

```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
```

## BCS0702 STDOUT vs STDERR Separation

```bash
# correct — status to stderr, data to stdout
info 'Processing files...'           # → stderr (via messaging function)
echo "$result"                       # → stdout (data output)
printf '%s\n' "$result"              # → stdout (data output)

# correct — place >&2 at the BEGINNING
>&2 echo 'error: something failed'
>&2 printf '%s\n' 'error: something failed'

# wrong — >&2 at end (works but harder to spot)
echo 'error: something failed' >&2
printf '%s\n' 'error: something failed' >&2
```

Stream separation enables: `data=$(./script.sh)` captures only data, `./script.sh 2>errors.log` separates errors, `./script.sh | process` pipes data while showing messages.

## BCS0703 Core Message Functions

Implement `_msg()` as the core function using `FUNCNAME[1]` dispatch.

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" DEBUG:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

Rules:
- `error()` must be unconditional — always outputs to stderr
- `warn()` should be unconditional (warnings are important)
- `info()`, `success()`, `vecho()` respect VERBOSE flag
- `debug()` respects DEBUG flag
- `die()` takes exit code as first argument

## BCS0704 Usage Documentation

Structure help text with sections. Use heredoc with `cat`.

```bash
show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - a brief description of the script

Usage: $SCRIPT_NAME [OPTIONS] FILE [FILE ...]

A more detailed description of what the script does.

Options:
  -n, --dry-run           Dry run mode
  -v, --verbose           Verbose output (default)
  -q, --quiet             Quiet mode
  -V, --version           Show version
  -h, --help              Show this help

Examples:
  $SCRIPT_NAME file.txt
  $SCRIPT_NAME --dry-run *.csv
HELP
}
```

Never use messaging functions for help output. Help and version must always display regardless of VERBOSE setting.

## BCS0705 Echo vs Messaging Functions

```bash
# correct — messaging for status
info 'Validating environment...'
warn 'Deprecated option used'
error 'Connection failed'

# correct — echo for data and help
echo "$result"                       # data output
echo "$SCRIPT_NAME $VERSION"         # version output
# help text
cat <<HELP
...
HELP

# correct — functions returning data use echo
get_value() {
  echo "$result"                     # stdout for callers to capture
}

# wrong — mixing streams
info "$result"                       # data via messaging function
echo 'Processing...'                 # status via echo to stdout
```

Never mix data and status on the same stream.

## BCS0706 Color Definitions

Use a conditional block to define colors.

```bash
# correct — basic color set (5 variables)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

```bash
# extended set (add only when needed, and only those colours that are required)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m' \
      BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' ITALIC=$'\033[3m' UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC='' \
      BLUE='' MAGENTA='' BOLD='' ITALIC='' UNDERLINE='' DIM='' REVERSE=''
fi
```

Never scatter inline color declarations across scripts. Centralize in a single declaration block.

## BCS0707 TUI Basics

Check for terminal before using TUI elements.

```bash
# correct
if [[ -t 1 ]]; then
  progress_bar 50 100
else
  echo '50% complete'
fi

# correct — hide cursor during TUI, restore on exit
printf '\033[?25l'                   # hide cursor
trap 'printf "\033[?25h"' EXIT       # restore on exit
```

## BCS0708 Terminal Capabilities

Get terminal dimensions dynamically.

```bash
# correct
trap 'get_terminal_size' WINCH
cols=$(tput cols 2>/dev/null || echo 80)

# correct — check Unicode support
[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
```

Never hardcode terminal width. Provide graceful fallbacks for limited terminals.

## BCS0709 Yes/No Prompt

```bash
yn() {
  local -- REPLY
  read -r -n 1 -p "$(>&2 echo -n "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n ")"
  echo
  [[ ${REPLY,,} == y ]]
}

# usage
yn 'Deploy to production?' || die 0 'Cancelled'
```

## BCS0710 Standard Icons

| Icon | Purpose |
|------|---------|
| `◉` | Info |
| `⦿` | Debug |
| `▲` | Warning |
| `✓` | Success |
| `✗` | Error |
| `⚠` | Caution |

## BCS0711 Combined Redirection

Prefer `&>` and `&>>` over the verbose `>file 2>&1` and `>>file 2>&1` forms.

```bash
# correct — concise combined redirection
somecommand &>/dev/null
somecommand &>outfile
somecommand &>>logfile

# wrong — verbose combined redirection
somecommand >/dev/null 2>&1
somecommand >outfile 2>&1
somecommand >>logfile 2>&1
```

Use `2>/dev/null` or `2>file` when suppressing only stderr. The `&>` operator is for combined (stdout + stderr) redirection only.

---

# Section 08: Command-Line Arguments

## BCS0800 Section Overview

Use `while (($#)); do case $1 in ... esac; shift; done` as the standard argument parsing pattern. This section covers parsing, standard options, option bundling, validation, and version output.

## BCS0801 Standard Parsing Pattern

```bash
# correct
while (($#)); do case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -q|--quiet)   VERBOSE=0 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
  -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; FILES+=("$@"); break ;;
  -[vqnoVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac; shift; done

# wrong
while [[ $# -gt 0 ]]; do            # use (($#)) instead
```

Key rules:
- `(($#))` is more efficient than `[[ $# -gt 0 ]]`
- The mandatory `shift` at loop end is critical — omitting it causes infinite loops
- For options with arguments: `noarg "$@"; shift; variable=$1`
- For boolean flags: just set, no extra shift needed
- For exit options (`--help`, `--version`): use `exit 0`, no shift needed
- Use `continue` after option disaggregation to re-process expanded options

See also: [Argument Processing Reference](/ai/scripts/Okusi/BCS/benchmarks/args-processing-reference.md) — comparison of BCS while/case, getopts, GNU getopt, and simple while/case with benchmark data.

## BCS0802 Version Output

Format: `scriptname X.Y.Z` without the word "version".

```bash
# correct
echo "$SCRIPT_NAME $VERSION"
# output: myscript 1.0.0

# wrong
echo "$SCRIPT_NAME version $VERSION"
echo "Version: $VERSION"
```

## BCS0803 Argument Validation

Validate option arguments exist before capturing them.

```bash
# correct — noarg checks $2 exists
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# usage
-o|--output) noarg "$@"; shift; OUTPUT=$1 ;;

# wrong — no validation
-o|--output) shift; OUTPUT=$1 ;;     # --output --verbose captures --verbose
```

Always call validators BEFORE `shift` — they must inspect `$2`.

Validate required arguments after parsing:

```bash
((${#FILES[@]})) || die 2 'No input files specified'
[[ $mode =~ ^(normal|fast|safe)$ ]] || die 22 "Invalid mode ${mode@Q}"
```

## BCS0804 Parsing Location

Place argument parsing inside `main()` for better testability.

```bash
# correct
main() {
  while (($#)); do case $1 in
    # ...
  esac; shift; done
  readonly VERBOSE DRY_RUN OUTPUT

  process_files
}

# acceptable for simple scripts under 200 lines
while (($#)); do case $1 in
  # ...
esac; shift; done
```

Make variables readonly after parsing completes.

## BCS0805 Short Option Bundling

Support bundled short options like `-vvn` expanding to `-v -v -n`.

```bash
# correct — recommended disaggregation pattern (list valid short options explicitly)
-[vqnoVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;

# correct — pure bash method (68% faster, no external deps); only use if speed is absolutely essential
-[vqnoVh]?*)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}"
  ;;
```

Place bundling case before `-*)` invalid option handler and after all explicit option cases. List only valid short options in the pattern to prevent incorrect expansion.

Include arg-taking options in the character class. They work correctly when last in the bundle — the disaggregation peels them off as a separate `-X` flag, and `shift` in their case handler picks up the argument normally. Example: `-vno output.txt` disaggregates to `-v -n -o`, then `-o` consumes `output.txt` via `shift`. The user must place arg-taking options last; `-von file` would incorrectly disaggregate to `-v -o -n`.

## BCS0806 Standard Options

Use consistent option letters and variable names across all BCS-compliant scripts. Never reassign a standard letter to a different purpose.

**Strongly Recommended** — include in every script that uses options:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-V` | `--version` | — | — | Print version and exit |
| `-h` | `--help` | — | — | Print help and exit |

**Recommended** — include when the script produces output or performs actions:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-v` | `--verbose` | `VERBOSE` | `1` | Enable verbose output |
| `-q` | `--quiet` | `VERBOSE` | `0` | Suppress informational output |

**Optional** — use when the script needs these capabilities:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-n` | `--dry-run` | `DRY_RUN` | `0` or `1` | Preview without changes |
| `-N` | `--not-dry-run` | `DRY_RUN` | `0` | Execute changes (cancels dry-run) |
| `-f` | `--force` | `FORCE` | `0` | Skip confirmation prompts |
| `-D` | `--debug` | `DEBUG` | `0` | Enable debug output |
| `-p` | `--port` | `PORT` | varies | Network port |
| `-P` | `--prefix` | `PREFIX` | varies | Installation prefix |

Key rules:
- **Never reassign** a standard letter to a different purpose — `-v` is always verbose, never version
- **Toggle pairs:** `-n`/`-N` and `-v`/`-q` are complementary toggles sharing a variable
- **DRY_RUN=1 default** for destructive scripts — require `-N` to execute; use `DRY_RUN=0` for non-destructive scripts
- **Use `declare -i`** for all flag variables: `declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0`

```bash
# correct — standard options with consistent letters and variables
declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0

while (($#)); do case $1 in
  -v|--verbose)     VERBOSE=1 ;;
  -q|--quiet)       VERBOSE=0 ;;
  -n|--dry-run)     DRY_RUN=1 ;;
  -N|--not-dry-run) DRY_RUN=0 ;;
  -f|--force)       FORCE=1 ;;
  -D|--debug)       DEBUG=1 ;;
  -V|--version)     echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)        show_help; exit 0 ;;
  --)               shift; FILES+=("$@"); break ;;
  -[vqnNfDVh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)               die 22 "Invalid option ${1@Q}" ;;
  *)                FILES+=("$1") ;;
esac; shift; done

# wrong — reassigned letters
-d|--debug)         # -d is not standard for debug; use -D
-v|--version)       # -v is verbose, never version; use -V
```

See also: BCS0701 (message control flags), BCS0802 (version output format), BCS1207 (verbose pattern), BCS1208 (dry-run pattern).

---

# Section 09: File Operations

## BCS0900 Section Overview

Safe file testing, wildcard expansion, process substitution, here documents, and input redirection patterns to prevent common shell scripting pitfalls.

## BCS0901 Safe File Testing

Use `[[ ]]` for all file tests. Always include filenames in error messages for debugging.

```bash
# correct
[[ -f $file ]] || die 3 "Not found ${file@Q}"
[[ -f $file && -r $file ]] || die 5 "Cannot read ${file@Q}"
[[ -d $dir ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ -s $logfile ]] || warn 'Log file is empty'
[[ $source -nt $destination ]] && cp "$source" "$destination" ||:

# wrong
[ -f "$file" ]                       # old test syntax
```

## BCS0902 Wildcard Expansion

Always use explicit path prefix to prevent filenames starting with `-` from being interpreted as flags.

```bash
# correct
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

# wrong — dangerous
rm -v *                              # file named -rf would be catastrophic
for file in *.txt; do                # less safe
```

## BCS0903 Process Substitution

Use `< <(command)` with while loops to avoid subshell variable scope issues.

```bash
# correct — variables preserved in current shell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep 'pattern' "$file")

# correct — populate arrays
readarray -t lines < <(find . -name '*.txt')

# correct — compare outputs without temp files
diff <(sort "$file1") <(sort "$file2")

# correct — null-delimited for special filenames
while IFS= read -r -d '' file; do
  process "$file"
done < <(find /data -type f -print0)

# correct — tee for parallel output
tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) < logfile

# wrong — pipe loses variables
command | while read -r line; do count+=1; done
```

## BCS0904 Here Documents

```bash
# correct — no expansion (quoted delimiter)
cat <<'EOF'
Variables like $HOME are not expanded.
EOF

# correct — with expansion (unquoted delimiter)
cat <<EOF
Hello $USER, home is $HOME
EOF
```

## BCS0905 Input Redirection

Use `$(< file)` instead of `$(cat file)` — 107x faster (zero process fork).

```bash
# correct
content=$(< "$file")
grep pattern < "$file"

# wrong — unnecessary cat
content=$(cat "$file")
cat "$file" | grep pattern
```

Use `cat` only when concatenating multiple files or using cat-specific options (`-n`, `-A`, `-b`).

---

# Section 10: Security

## BCS1000 Section Overview

Five essential security areas: SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, and input sanitization. These prevent privilege escalation, command injection, and path traversal attacks.

## BCS1001 SUID/SGID Prohibition

Never use SUID or SGID bits on Bash scripts. No exceptions.

```bash
# wrong — catastrophically dangerous
chmod u+s script.sh

# correct — use sudo instead
sudo /usr/local/bin/myscript.sh
# or configure /etc/sudoers.d/myapp for specific commands
```

For elevated privileges, use sudo, capabilities (`setcap`), compiled wrappers, PolicyKit, or systemd services.

## BCS1002 PATH Security

Secure PATH at script start to prevent command hijacking.

```bash
# correct
declare -rx PATH=~/.local/bin:/usr/local/bin:/usr/bin:/bin

# correct — for production/security-critical scripts
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

# wrong — includes dangerous elements
PATH=.:$PATH                         # current directory
PATH="/tmp:$PATH"                    # world-writable directory
```

Never include `.`, empty elements (`::`, leading/trailing `:`), `/tmp`, or user home directories in PATH. Place PATH setting early, before any commands that depend on it.

## BCS1003 IFS Safety

Never trust inherited IFS values.

```bash
# correct — one-line IFS for single command
IFS=',' read -ar fields <<< "$csv_data"

# correct — subshell isolation
( IFS=','; read -ar fields <<< "$data" )

# correct — local scoping in functions
parse_csv() {
  local -- IFS=','
  read -ar fields <<< "$1"
}

# correct — null-delimited input
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -print0)

# wrong — modifying global IFS without restore
IFS=','
```

## BCS1004 Eval Avoidance

Never use `eval` with untrusted input. Almost every use case has a safer alternative.

```bash
# correct — arrays for dynamic commands
local -a cmd=(find "$path" -name "$pattern")
"${cmd[@]}"

# correct — indirect expansion
echo "${!var_name}"

# correct — printf -v for dynamic assignment
printf -v "$var_name" '%s' "$value"

# correct — associative arrays for dynamic data
declare -A data
data["$key"]="$value"

# correct — case for dispatch
case "$action" in
  start) start_fn ;;
  stop)  stop_fn ;;
esac

# wrong
eval "echo \$$var_name"
eval "$var_name='$value'"
eval "${action}_function"
```

## BCS1005 Input Sanitization

Validate and sanitize all user input. Use whitelist over blacklist.

```bash
# correct — validate integer
[[ $input =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: ${input@Q}"

# correct — validate path within allowed directory
real_path=$(realpath -e -- "$path")
[[ $real_path == "$allowed_dir"* ]] || die 13 'Path traversal blocked'

# correct — sanitize filename
[[ $name =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename ${name@Q}"

# correct — always use -- before file arguments
rm -- "$user_file"
cp -- "$source" "$dest"
```

Validate early, fail securely with clear errors, run with minimum necessary permissions.

## BCS1006 Temporary File Handling

Always use `mktemp`. Never hardcode temp file paths.

```bash
# correct
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

temp_dir=$(mktemp -d) || die 1 'Failed to create temp dir'
trap 'rm -rf "$temp_dir"' EXIT

# correct — custom template
mktemp /tmp/"$SCRIPT_NAME".XXXXXX

# wrong
echo data > /tmp/myapp_temp.txt      # predictable path
echo data > "/tmp/app_$$"            # PID-based (predictable)
```

Default `mktemp` permissions are secure (0600 files, 0700 directories). Multiple trap statements for the same signal overwrite each other — use a single cleanup function.

---

# Section 11: Concurrency & Jobs

## BCS1100 Section Overview

Background job management, parallel execution, wait patterns, timeouts, and retry logic. Never leave background jobs unmanaged.

## BCS1101 Background Job Management

Always track PIDs when starting background jobs.

```bash
# correct
command &
pid=$!

# correct — multiple PIDs
declare -a pids=()
command1 &
pids+=($!)
command2 &
pids+=($!)

# correct — check if process is running
kill -0 "$pid" 2>/dev/null           # signal 0 = existence check

# correct — cleanup in trap
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# wrong
command &                            # untracked background job
```

Use `$!` for the last background PID. Never use `$$` (that's the parent PID).

## BCS1102 Parallel Execution

For ordered output, write results to temp files then display in order.

```bash
# correct — parallel with ordered output
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
declare -a pids=()

for server in "${servers[@]}"; do
  check_server "$server" > "$temp_dir/$server.out" 2>&1 &
  pids+=($!)
done

# Wait and display in order
for server in "${servers[@]}"; do
  wait "${pids[0]}" || true
  pids=("${pids[@]:1}")
  cat "$temp_dir/$server.out"
done
```

Implement concurrency limits by checking `${#pids[@]}` against `max_jobs` and using `wait -n` to wait for slots.

Never modify variables in background subshells expecting parent visibility — use temp files for results.

## BCS1103 Wait Patterns

Always capture wait exit codes.

```bash
# correct — track errors across waits
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || errors+=1
done
((errors == 0)) || die 1 "$errors job(s) failed"

# correct — process as completed (Bash 4.3+)
while ((${#pids[@]})); do
  wait -n || errors+=1
done

# wrong — ignoring return value
wait $!
```

## BCS1104 Timeout Handling

Wrap network operations with timeout.

```bash
# correct
timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'
timeout --signal=TERM --kill-after=10 60 long_command

# correct — handle timeout exit code
case $? in
  0)   success 'Command completed' ;;
  124) error 'Command timed out' ;;
  125) error 'Timeout itself failed' ;;
  *)   error 'Command failed' ;;
esac

# correct — user input timeout with default
read -r -t 10 -p 'Enter value: ' value || value='default'

# correct — SSH and curl timeouts
ssh -o ConnectTimeout=10 -o BatchMode=yes "$host" 'command'
curl --connect-timeout 10 --max-time 60 "$url"
```

## BCS1105 Exponential Backoff

Use exponential backoff for retries. Never use fixed delays.

```bash
# correct
declare -i attempt=1 max_attempts=5 delay max_delay=60 jitter

while ((attempt <= max_attempts)); do
  if try_operation; then
    break
  fi

  delay=$((2 ** attempt))
  ((delay > max_delay)) && delay=$max_delay ||:

  # Add jitter to prevent thundering herd
  jitter=$((RANDOM % delay))
  sleep $((delay + jitter))

  attempt+=1
done

# wrong — tight retry loop
while ! curl "$url"; do :; done      # floods failing services
```

Validate success conditions beyond exit code — check output validity: `[[ -s "$temp_file" ]]`.

---

# Section 12: Style & Development

## BCS1200 Section Overview

Code formatting, comments, development practices, debugging, dry-run patterns, and testing support. These conventions ensure consistent, maintainable scripts.

## BCS1201 Code Formatting

```
- 2 spaces for indentation (never tabs)
- Lines under 120 characters (except URLs/paths)
- Use \ for line continuation
```

## BCS1202 Comments

Focus on WHY, not WHAT.

```bash
# correct — explains non-obvious decisions
# PROFILE_DIR hardcoded to /etc/profile.d for system-wide bash integration
declare -r PROFILE_DIR=/etc/profile.d

# correct — documents gotcha
# readarray quirk: single empty element means no results
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0

# wrong — restates the code
# Set verbose to 1
VERBOSE=1
# Check if file exists
[[ -f $file ]]
```

Use standard documentation icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error).

## BCS1203 Blank Lines

- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- Blank lines before and after multi-line blocks
- Never multiple consecutive blank lines
- No blank lines between short, related statements

## BCS1204 Section Comments

```bash
# correct — lightweight, 2-4 words
# Default values
declare -i VERBOSE=1 DEBUG=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin

# Core message function
_msg() { :; }

# wrong — heavy box drawing
#############################
# Default values            #
#############################
```

Reserve 80-dash separators for major script divisions only.

## BCS1205 Language Best Practices

Prefer shell builtins over external commands (10-100x faster).

```bash
# correct — builtins
$((x + y))                          # not $(expr $x + $y)
${path##*/}                         # not $(basename "$path")
${path%/*}                          # not $(dirname "$path")
${var^^}                            # not $(echo "$var" | tr a-z A-Z)
${var,,}                            # not $(echo "$var" | tr A-Z a-z)
[[ condition ]]                     # not [ condition ] or test
var=$(command)                      # not var=`command`
{1..10}                             # not $(seq 1 10)
```

## BCS1206 Static Analysis Directives

ShellCheck compliance is compulsory. Use `#shellcheck disable=SCxxxx` only for documented exceptions. Similarly, use `#bcscheck disable=BCSxxxx` to suppress specific BCS rules on the next line.

```bash
# correct — documented shellcheck exception
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")

# correct — documented bcscheck exception
#bcscheck disable=BCS0606
((DRY_RUN)) && info 'Dry-run mode' ||:
```

Always end scripts with `#fin` after `main "$@"`.

Use defensive programming:

```bash
: "${VERBOSE:=0}"                    # default critical variables
[[ -n $1 ]] || die 2 'Argument required'
```

Minimize subshells, use built-in string operations, batch operations, use process substitution over temp files.

## BCS1207 Debugging

```bash
# correct
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:

# enhanced trace output
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# debug function
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# runtime activation
DEBUG=1 ./script.sh
```

## BCS1208 Dry-Run Pattern

```bash
# correct
declare -i DRY_RUN=0
# parse: -n|--dry-run) DRY_RUN=1 ;;

deploy() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would deploy to production'
    return 0
  fi
  # actual deployment
}
```

Dry-run maintains identical control flow (same function calls, same logic paths) to verify logic without side effects. Show detailed preview of what would happen with `[DRY-RUN]` prefix.

## BCS1209 Testing Support

```bash
# correct — dependency injection
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
# override in tests: FIND_CMD() { echo 'mocked_file.txt'; }

# correct — test mode flag
declare -i TEST_MODE=${TEST_MODE:-0}

# correct — assert function
assert() {
  local -- expected=$1 actual=$2 msg=${3:-assertion}
  [[ $expected == "$actual" ]] || {
    error "FAIL: $msg: expected ${expected@Q}, got ${actual@Q}"
    return 1
  }
}

# correct — test runner
run_tests() {
  local -i passed=0 failed=0
  local -- fn
  while IFS= read -r _ _ fn; do
    if "$fn"; then
      passed+=1
    else
      failed+=1
    fi
  done < <(declare -F | grep 'test_')
  echo "Passed: $passed, Failed: $failed"
  ((failed == 0))
}
```

## BCS1210 Progressive State Management

Separate user intent from runtime state.

```bash
# correct
declare -i BUILTIN_REQUESTED=1       # user asked for it
declare -i INSTALL_BUILTIN=0         # what will actually happen

# validate prerequisites
if ((BUILTIN_REQUESTED)); then
  if build_builtin; then
    INSTALL_BUILTIN=1
  else
    warn 'Builtin build failed, skipping'
  fi
fi

# execute based on final state
((INSTALL_BUILTIN)) && install_builtin ||:
```

Apply state changes in logical order: parse, validate, execute. Never modify flags during execution phase.

## BCS1211 Utility Functions

Common helper functions:

```bash
# Argument validation
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Trim whitespace
trim() { local -- v="$*"; v="${v#"${v%%[![:blank:]]*}"}"; echo -n "${v%"${v##*[![:blank:]]}"}" ; }

# Debug variable display
decp() { declare -p "$@" 2>/dev/null | sed 's/^declare -[a-zA-Z-]* //'; }

# Pluralization
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

## BCS1212 Makefile Installation

Bash projects that install to the system must include a Makefile. The Makefile must be non-interactive, silent by default (no banners or colour output), and idempotent.

### Required Targets

```
install     Install all project files
uninstall   Remove all installed files
check       Verify installation (commands found in PATH)
test        Run project test suite (if tests exist)
help        Show targets and variables
```

`all` should alias `help`, not `install` — accidental `make` must never modify the system.

### Required Variables

```makefile
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=
```

`DESTDIR` enables staged installs for packaging (`make DESTDIR=/tmp/pkg install`). Never hardcode paths — always use variables.

### Installation Rules

- Use `install(1)`, not `cp` + `chmod`.
- Use `install -d` for directory creation.
- Executables: `install -m 755`.
- Data files (manpages, completions, libraries): `install -m 644`.
- Symlinks: `ln -sf`.
- If the project contains manpages (`.1`, `.8`, etc.), the `install` target must install them.
- If the project contains bash completion files, the `install` target must install them (skip gracefully if `COMPDIR` does not exist).
- `uninstall` must remove everything `install` creates.
- `check` must verify installed commands are callable. Skip `check` when `DESTDIR` is set (staged installs).

### Template

```makefile
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 myscript $(DESTDIR)$(BINDIR)/myscript
	@# Manpages (if present)
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 myscript.1 $(DESTDIR)$(MANDIR)/myscript.1
	@# Bash completion (if present, skip if dir missing)
	@if [ -d $(DESTDIR)$(COMPDIR) ]; then \
	  install -m 644 .bash_completion $(DESTDIR)$(COMPDIR)/myscript; \
	fi
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/myscript
	rm -f $(DESTDIR)$(MANDIR)/myscript.1
	rm -f $(DESTDIR)$(COMPDIR)/myscript

check:
	@command -v myscript >/dev/null 2>&1 \
	  && echo 'myscript: OK' \
	  || echo 'myscript: NOT FOUND (check PATH)'

test:
	cd tests && ./run_all_tests.sh

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
```

## BCS1213 Date and Time Formatting

Prefer `printf '%()T'` (Bash 5.0+ builtin strftime) over `$(date)` for date/time formatting — avoids fork overhead (~28x faster in benchmarks).

```bash
# correct — builtin, no fork
printf '%(%F)T' "$EPOCHSECONDS"
printf '%(%Y-%m-%d)T' -1
printf '%(%F %T)T' "$EPOCHSECONDS"
printf '%(%A %F %H:%M)T'

# correct — builtin, capture to variable (no subshell)
printf -v today '%(%F)T'

# correct — UTC via TZ prefix
TZ=UTC printf '%(%F %T)T'

# wrong — forks external process on every call
today=$(date +'%F %T')

# wrong — forks + unnecessary EPOCHSECONDS round-trip
date -d "@$EPOCHSECONDS" +'%Y-%m-%d'
```

Use `$EPOCHSECONDS` for integer epoch timestamps (second precision) and `$EPOCHREALTIME` for microsecond precision. Both are Bash builtins — no fork required.

`date(1)` is acceptable when `printf '%()T'` cannot provide the needed format (e.g., `date -d 'next Monday'` for relative date arithmetic).

See also: [Date Formatting Reference](/ai/scripts/Okusi/BCS/benchmarks/date-printf-reference.md) — full `date` → `printf '%()T'` equivalence table with examples.
