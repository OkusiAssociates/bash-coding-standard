# Bash Coding Style Guide

This document defines the comprehensive Bash coding standards for our organization, as exemplified by the `cln` utility and other production scripts.  This standard presumes Bash 5.2 and higher; all other variants are ignored. This is not a compatibility standard.

## Table of Contents
1. [Script Structure](#script-structure)
2. [Variable Declarations](#variable-declarations)
3. [Functions](#functions)
4. [Error Handling](#error-handling)
5. [Control Flow](#control-flow)
6. [String Operations](#string-operations)
7. [Arrays](#arrays)
8. [Command-Line Arguments](#command-line-arguments)
9. [Output and Messaging](#output-and-messaging)
10. [File Operations](#file-operations)
11. [Calling Commands](#calling-commands)
12. [Security Considerations](#security-considerations)
13. [Best Practices](#best-practices)

## Script Structure

### 1. Shebang and Initial Setup
```bash
#!/usr/bin/env bash                 # #!/usr/bin/bash is also acceptable
#shellcheck disable=SC1090,SC1091   # Document shellcheck global exceptions
# Brief description of script purpose
set -euo pipefail                   # !! Strict error handling
```

### 2. File Header
- Start each file with a description of its contents straight after the global shellcheck line
- Keep description concise and informative

```bash
#!/usr/bin/bash
#shellcheck disable=SC8080
# Get directory sizes and report usage statistics
```

### 3. Script Metadata
```bash
VERSION='1.0.0'
PRG0=$(readlink -en -- "$0")       # Full path to script
PRG=${PRG0##*/}                    # Script basename
PRGDIR=${PRG0%/*}                  # Script directory
readonly -- VERSION PRG0 PRG PRGDIR
```

### 4. Standard Script Layout
1. Shebang and shellcheck directives
2. Script description comment
3. `set -euo pipefail`
4. Script metadata (VERSION, PRG, etc.)
5. Global variable declarations
6. Colour definitions (if terminal output)
7. Utility functions
8. Business logic functions
9. `main()` function
10. Script invocation: `main "$@"`
11. End marker: `#fin`

### 5. File Extensions
- Executables should have `.sh` extension or no extension
- Libraries must have `.sh` extension and should not be executable
- If the executable will be available globally via PATH, always use no extension

## Variable Declarations

### Type-Specific Declarations
```bash
declare -i VERBOSE=1         # Integer variables
declare -- STRING_VAR=''     # String variables
declare -a ARRAY_VAR=()      # Indexed arrays
declare -A HASH_VAR=()       # Associative arrays
readonly -- CONSTANT='val'   # Read-only constants
```

### Variable Scoping
```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path              # Local string
}
```

### Local Variables
- Always declare function-specific variables as `local`
```bash
my_func() {
  local -- name="$1"
  local -- dir
  dir=$(dirname "$name")
  # ...
}
```

### Naming Conventions
- Constants: `UPPER_CASE`
- Global variables: `UPPER_CASE` or `CamelCase`
- Local variables: `lower_case` with underscores
- Internal/private functions: prefix with `_`
- Environment variables: `UPPER_CASE` with underscores

### Constants and Environment Variables
```bash
# Constants
readonly -- PATH_TO_FILES='/some/path'

# Environment variables
declare -x ORACLE_SID='PROD'
```

## Functions

### Function Definition Pattern
```bash
# Single-line functions for simple operations
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line functions with local variables
main() {
  local -i exitcode=0
  local -- variable
  # Function body
  return "$exitcode"
}
```

### Function Names
- Use lowercase with underscores
```bash
# Good
my_function() {
  …
}

# Private functions can use leading underscore
_my_private_function() {
  …
}
```

### Main Function
- Always include a `main()` function for scripts longer than ~40 lines
- Helps with organization and testing

```bash
main() {
  # Main logic here
  local -i rc=0
  # Process arguments, call functions
  return "$rc"
}

# Call main with all arguments
main "$@"
#fin
```

### Function Export
```bash
# Export functions when needed by subshells
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

### Standard Utility Functions
```bash
# Messaging functions
_msg() { ... }           # Core message function
vecho() { ... }          # Verbose echo
success() { ... }        # Success messages
warn() { ... }           # Warning messages
info() { ... }           # Information messages
error() { ... }          # Error messages (to stderr)
die() { ... }            # Exit with error

# Helper functions
noarg() { ... }          # Validate argument presence
decp() { ... }           # Debug print variable declaration
trim() { ... }           # Trim whitespace
s() { ... }              # Pluralization helper
yn() { ... }             # yes/no prompt
```

## Error Handling

### Exit on Error
```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

### Exit Codes
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success
die 1 'General error'    # General error
die 2 'Missing argument' # Missing argument
die 22 'Invalid option'  # Invalid argument
```

### Trap Handling
```bash
cleanup() {
  local -i exitcode=${1:-0}
  # Cleanup operations
  #...
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Error Suppression
```bash
# Suppress errors when appropriate
command 2>/dev/null || true
```

## Control Flow

### Conditionals
```bash
# Prefer [[ ]] over [ ]
[[ -d "$path" ]] && echo 'Directory exists'

# Arithmetic conditionals use (( ))
((VERBOSE==0)) || echo 'Verbose mode'
((var > 5)) || return 1

# Complex conditionals
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi

# Short-circuit evaluation
[[ -f "$file" ]] && source "$file"
((VERBOSE)) || return 0
```

### Case Statements
```bash
case "$1" in
  -h|--help)      usage 0 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac
```

### Loops
```bash
# For loops with arrays
for spec in "${Specs[@]}"; do
  find_expr+=(-name "$spec" -o)
done

# While loops for argument parsing
while (($#)); do
  case "$1" in
    # ...
  esac
  shift
done

# Reading command output
readarray -t found_files < <(find ... 2>/dev/null || true)
```

### Pipes to While
Prefer process substitution or `readarray` instead of piping to while.

```bash
# Good - process substitution
while IFS= read -r line; do
  echo "$line"
done < <(my_command)

# Good - readarray
readarray -t my_array < <(my_command)

# Bad - creates subshell where variables don't persist
my_command | while read -r line; do
  echo "$line"
done
```

## String Operations

### Parameter Expansion
```bash
PRG=${PRG0##*/}              # Remove longest prefix pattern
PRGDIR=${PRG0%/*}            # Remove shortest suffix pattern
${var:-default}              # Default value
${var:0:1}                   # Substring
${#array[@]}                 # Array length
${var,,}                     # Lowercase conversion
"${@:2}"                     # All args starting from 2nd
```

### Variable Expansion Guidelines
- Always quote your variables: `"$var"`
- Only use `"${var}"` over `"$var"` where necessary:
  - When concatenating: `"${var1}${var2}${var3}"`
  - For array access: `"${array[index]}"`
  - With parameter expansion: `"${var##*/}"`
- Don't brace-delimit single character shell specials unless necessary (e.g., `"${10}"`)

### Quoting Rules
```bash
# Always quote variables in conditionals
[[ -d "$path" ]]             # Correct
[[ -d $path ]]               # Wrong

# Quote array expansions
"${array[@]}"                # All elements as separate words
"${array[*]}"                # All elements as single word

# !! Always prefer single quotes for string literals
var='A script message'       # Correct
var="A script message"       # Incorrect; unnecessary use of double quotes
```

### String Trimming
```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

### Display Declared Variables
```bash
decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }
```

### Pluralisation Helper
```bash
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```

## Arrays

### Array Declaration and Usage
```bash
# Indexed arrays
declare -a DELETE_FILES=('*~' '~*' '.~*')
local -a Paths=()

# Adding elements
Paths+=("$1")
add_specs+=("$spec")

# Array iteration
for path in "${Paths[@]}"; do
  process "$path"
done

# Array length
((${#Paths[@]})) || Paths=('.')

# Reading into array
IFS=',' read -ra ADD_SPECS <<< "$1"
readarray -t found_files < <(command)

# Unset array element
unset 'find_expr[${#find_expr[@]}-1]'
```

### Arrays for Safe List Handling
Use arrays to store lists of elements safely, especially for command arguments.

```bash
# Declare arrays explicitly
declare -a Elements
declare -- element

# Initialize and iterate
Elements=(one two three)
for element in "${Elements[@]}"; do
  echo "$element"
done

# Arrays for command arguments - avoids quoting issues
declare -a cmd_args
cmd_args=( -o "${output}" --verbose )
mycmd "${cmd_args[@]}"
```

## Command-Line Arguments

### Standard Argument Parsing Pattern
```bash
while (($#)); do case "$1" in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth="$1" ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;
  -p|--prompt)    PROMPT=1; VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;
  -V|--version)   echo "$PRG $VERSION"; exit 0 ;;
  -h|--help)      usage 0 ;;
  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

### Argument Validation
```bash
noarg() {
  if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then
    die 2 "Missing argument for option '$1'"
  fi
  return 0
}
```

## Output and Messaging

### Standardized Messaging and Colour Support
```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard colours
[[ -t 2 ]] && declare -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m' || declare -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
readonly -- RED GREEN YELLOW CYAN NC
```

### STDOUT vs STDERR
- All error messages should go to `STDERR`
- Place `>&2` at the beginning of the command for clarity

```bash
# Preferred format
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Also acceptable
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

### Core Message Functions
```bash
# Core message function using FUNCNAME for context
_msg() {
  local -- status="${FUNCNAME[1]}" prefix="$PRG:" msg
  case "$status" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${WARN}DEBUG${NC}:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
# Conditional output based on verbosity
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
# Unconditional output
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
# yes/no
yn() {
  ((PROMPT)) || return 0
  local -- reply
  read -r -n1 -p "$PRG: ${YELLOW}$1${NC} y/n " reply
  echo
  [[ ${reply,,} == y ]]
}
```

### Usage Documentation
```bash
usage() {
  cat <<EOT
$PRG $VERSION - Brief description

Detailed description.

Usage: $PRG [Options] [arguments]

Options:
  -h|--help         This help message
  -v|--verbose      Enable verbose output
                    $(decp VERBOSE)

Examples:
  # Example 1
  $PRG -v file.txt
EOT
  exit "${1:-0}"
}
```

## File Operations

### Safe File Testing
```bash
[[ -d "$path" ]] || die 1 "Not a directory '$path'"
[[ -f "$file" ]] && source "$file"
[[ -r "$file" ]] || warn "Cannot read '$file'"
```

### Wildcard Expansion
Always use explicit path when doing wildcard expansion to avoid issues with filenames starting with `-`.

```bash
# Correct - explicit path prevents flag interpretation
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

# Incorrect - filenames starting with - become flags
rm -v *
```

### Process Substitution
```bash
# Compare command outputs
diff <(sort file1) <(sort file2)

# Read command output into array
readarray -t array < <(command)

# Process lines from command
while IFS= read -r line; do
  process "$line"
done < <(command)
```

### Here Documents
Use for multi-line strings or input.

```bash
# No variable expansion (note single quotes)
cat <<'EOF'
This is a multi-line
string with no variable
expansion.
EOF

# With variable expansion
cat <<EOF
User: $USER
Home: $HOME
EOF
```

## Calling Commands

### Checking Return Values
Always check return values and give informative error messages.

```bash
# Explicit check with informative error
if ! mv "$file_list" "$dest_dir/"; then
  >&2 echo "Unable to move $file_list to $dest_dir"
  exit 1
fi

# Simple cases with ||
mv "$file_list" "$dest_dir/" || die 1 "Failed to move files"

# Group commands for error handling
mv "$file_list" "$dest_dir/" || {
  >&2 echo "Move failed: $file_list -> $dest_dir"
  cleanup
  exit 1
}
```

### Builtin Commands vs External Commands
Always prefer shell builtins over external commands for performance.

```bash
# Good - bash builtins
addition=$((x + y))
string=${var^^}  # uppercase
if [[ -f "$file" ]]; then

# Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ -f "$file" ]; then
```

### Readonly Declaration
Use `readonly` for constants to prevent accidental modification.

```bash
readonly -- SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly -a REQUIRED_TOOLS=(git docker kubectl)
```

## Security Considerations

### SUID/SGID
- **Never** use SUID/SGID in Bash scripts
- Too many security vulnerabilities possible
- Use `sudo` to provide elevated access when needed

### Eval Command
`eval` should be avoided wherever possible due to security risks.

```bash
# Dangerous - avoid
eval "$user_input"

# Safer alternatives
# Use indirect expansion for variable references
var_name="HOME"
echo "${!var_name}"

# Use arrays for building commands
declare -a cmd=(ls -la "$dir")
"${cmd[@]}"
```

## Best Practices

### 1. Indentation
- !! Use 2 spaces for indentation (NOT tabs)
- Maintain consistent indentation throughout

### 2. Line Length
- Keep lines under 100 characters when practical
- Long file paths and URLs can exceed 100 chars when necessary
- Use line continuation with `\` for long commands

### 3. Comments
```bash
# Section separator (80 dashes)
# --------------------------------------------------------------------------------

# Function description above function
# Brief inline comments for complex logic
((max_depth > 0)) || max_depth=255  # -1 means unlimited
```

### 4. Arithmetic Operations
```bash
# Always declare integer variables explicitly
declare -i i j count

# Increment operations - avoid ++ due to return value issues
i+=1              # Preferred for declared integers
((i+=1))          # Always returns 0
((i++))           # Avoid: returns original value, can cause issues with set -e

# Arithmetic expressions
((result = x * y + z))
j=$((i * 2 + 5))

# Arithmetic conditionals
if ((i < j)); then
  echo "i is less than j"
fi

# Short form
((x > y)) && echo 'x is greater'
```

### 5. Command Substitution
```bash
# Always use $() instead of backticks
var=$(command)       # Correct
var=`command`        # Wrong!
```

### 6. ShellCheck Compliance
ShellCheck is **compulsory** for all scripts. Use `#shellcheck disable=...` only for documented exceptions.

```bash
# Document intentional violations with reason
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"

# Run shellcheck as part of development
shellcheck -x myscript.sh
```

### 7. Script Termination
```bash
# Always end scripts with #fin marker
main "$@"
#fin

```

### 8. Defensive Programming
```bash
# Default values for critical variables
: "${VERBOSE:=0}"
: "${DEBUG:=0}"

# Validate inputs early
[[ -n "$1" ]] || die 1 'Argument required'

# Guard against unset variables
set -u
```

### 9. Performance Considerations
```bash
# Minimize subshells
# Use built-in string operations over external commands
# Batch operations when possible
# Use process substitution over temp files
```

### 10. Testing Support
```bash
# Make functions testable
# Use dependency injection for external commands
# Support verbose/debug modes
# Return meaningful exit codes
```

## Summary

This coding style emphasizes:
- **Robustness**: Strict error handling, proper quoting, defensive programming
- **Readability**: Clear structure, consistent naming, good documentation
- **Maintainability**: Modular functions, proper scoping, standardized patterns
- **Performance**: Efficient constructs, minimal subshells, built-in operations

Follow these guidelines to ensure consistent, reliable, and maintainable Bash scripts across the organization.

#fin