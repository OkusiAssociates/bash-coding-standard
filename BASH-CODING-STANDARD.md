# Bash Coding Standard

This document defines a comprehensive Bash coding standard and presumes Bash 5.2 and higher; this is not a compatibility standard.

NOTE: Do not over-engineer scripts; functions and varaibles not required for the operation of the script should not be included and/or removed.

## Contents
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
14. [Summary](#summary)
15. [Advanced Topics](#advanced-topics)

## Script Structure

### Standard Script Layout
1. Shebang
2. Global shellcheck directives (where required)
3. Script description comment
4. `set -euo pipefail`
5. Script metadata (VERSION, SCRIPT_NAME, etc.)
6. Global variable declarations
7. Color definitions (if terminal output)
8. Utility functions
9. Business logic functions
10. `main()` function
11. Script invocation: `main "$@"`
12. End marker: `#fin`

### Shebang and Initial Setup
First lines of all scripts must include a `#!shebang`, global `#shellcheck` definitions (optional), a brief description of the script, and first command `set -euo pipefail`.

```bash
#!/usr/bin/env bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

### Script Metadata
```bash
VERSION='1.0.0'
SCRIPT_PATH=$(readlink -en -- "$0") # Full path to script
SCRIPT_DIR=${SCRIPT_PATH%/*}        # Script directory
SCRIPT_NAME=${SCRIPT_PATH##*/}      # Script basename
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
```

#### shopt

**Recommended settings for most scripts:**

```bash
# STRONGLY RECOMMENDED - apply to all scripts
shopt -s inherit_errexit  # Critical: makes set -e work in subshells, command substitutions
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE based on use case:
shopt -s nullglob   # For arrays/loops: unmatched globs → empty (no error)
# OR
shopt -s failglob   # For strict scripts: unmatched globs → error

# OPTIONAL based on needs:
shopt -s globstar   # Enable ** for recursive matching (can be slow on deep trees)
```

Example for typical script:
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

### File Extensions
- Executables should have `.sh` extension or no extension
- Libraries must have `.sh` extension and should not be executable
- If the executable will be available globally via PATH, always use no extension

## Variable Declarations

### Type-Specific Declarations
```bash
declare -i VERBOSE=1         # Integer variables
declare -- STRING_VAR=''     # String variables
declare -a MY_ARRAY=()      # Indexed arrays
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

| Constants | UPPER_CASE |
| Global variables | UPPER_CASE or CamelCase |
| Local variables | lower_case with underscores; CamelCase acceptable for important local variables |
| Internal/private functions | prefix with _ |
| Environment variables | UPPER_CASE with underscores |

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
yn() { ... }             # Yes/no prompt
```

### Production Script Optimization
Once a script is mature and ready for production:
- Remove unused utility functions (e.g., if `yn()`, `decp()`, `trim()`, `s()` are not used)
- Remove unused global variables (e.g., `PROMPT`, `DEBUG` if not referenced)
- Remove unused messaging functions that your script doesn't call
- Keep only the functions and variables your script actually needs
- This reduces script size, improves clarity, and eliminates maintenance burden

Example: A simple script may only need `error()` and `die()`, not the full messaging suite.

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

# Arithmetic conditionals use (())
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
    # ... ;;
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
SCRIPT_NAME=${SCRIPT_PATH##*/} # Remove longest prefix pattern
SCRIPT_DIR=${SCRIPT_PATH%/*}   # Remove shortest suffix pattern
${var:-default}                # Default value
${var:0:1}                     # Substring
${#array[@]}                   # Array length
${var,,}                       # Lowercase conversion
"${@:2}"                       # All args starting from 2nd
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
[[ -d "$path" ]]               # Correct
[[ -d $path ]]                 # Wrong

# Quote array expansions
"${array[@]}"                  # All elements as separate words
"${array[*]}"                  # All elements as single word

# Always prefer single quotes for string literals
var='A script message'         # Correct
var="A script message"         # Incorrect; unnecessary use of double quotes
var="A 'script' message"       # Correct
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
cmd_args=( -o "$output" --verbose )
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
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
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

### Standardized Messaging and Color Support
```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard colors
[[ -t 1 && -t 2 ]] && declare -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m' || declare -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
readonly -- RED GREEN YELLOW CYAN NC
```

### STDOUT vs STDERR
- All error messages should go to `STDERR`
- Place `>&2` at the *beginning* commands for clarity

```bash
# Preferred format
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Also acceptable
somefunc() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

### Core Message Functions
```bash
# Core message function using FUNCNAME for context
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
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
  >&2 read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}$1${NC} y/n " reply
  >&2 echo
  [[ ${reply,,} == y ]]
}
```

### Usage Documentation
```bash
usage() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Detailed description.

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -h|--help         This help message
  -v|--verbose      Enable verbose output

Examples:
  # Example 1
  $SCRIPT_NAME -v file.txt
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
readonly -- SCRIPT_PATH="$(readlink -en -- "$0")"
readonly -a REQUIRED=(pandoc git md2ansi)
```

## Security Considerations

### SUID/SGID
- **Never** use SUID/SGID in Bash scripts
- Too many security vulnerabilities possible
- Use `sudo` to provide elevated access when needed

### PATH Security
Lock down PATH to prevent command injection and trojan attacks.

```bash
# Lock down PATH at script start
readonly PATH="/usr/local/bin:/usr/bin:/bin"
export PATH

# Or validate existing PATH
[[ "$PATH" =~ \. ]] && die 1 "PATH contains current directory"
[[ "$PATH" =~ ^: ]] && die 1 "PATH starts with empty element"
[[ "$PATH" =~ :: ]] && die 1 "PATH contains empty element"
[[ "$PATH" =~ :$ ]] && die 1 "PATH ends with empty element"
```

### IFS Manipulation Safety
When changing IFS, always save and restore it.

```bash
# Save and restore IFS
OLD_IFS="$IFS"
IFS=$'\n'
# ... operations requiring newline separator ...
IFS="$OLD_IFS"

# Or use subshell to isolate IFS changes
(
  IFS=','
  read -ra array <<< "$csv_data"
  # IFS change limited to subshell
)
```

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
declare -i i j result

# Increment operations - avoid ++ due to return value issues
i+=1              # **Preferred** for declared integers
((i+=1))          # Always returns 0 (success)
((++i))           # Returns value AFTER increment (safe)
((i++))           # DANGEROUS: Returns value BEFORE increment
                  # If i=0, returns 0 (falsey), triggers set -e
                  # Example: i=0; ((i++)) && echo "never prints"

# Arithmetic expressions
((result = x * y + z))
j=$((i * 2 + 5))

# Arithmetic conditionals
if ((i < j)); then
  echo "i is less than j"
fi

# Short-form evaluation
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

Follow these guidelines to ensure consistent, robust, reliable, and maintainable Bash scripts.

## Advanced Topics

### Debugging and Development

Enable debugging features for development and troubleshooting.

```bash
# Debug mode implementation
declare -i DEBUG="${DEBUG:-0}"

# Enable trace mode when DEBUG is set
((DEBUG)) && set -x

# Enhanced PS4 for better trace output
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# Conditional debug output function
debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}

# Usage
DEBUG=1 ./script.sh  # Run with debug output
```

### Temporary File Handling

Safe creation and cleanup of temporary files and directories.

```bash
# Safe temporary file creation
TMPFILE=$(mktemp) || die 1 "Failed to create temp file"
trap 'rm -f "$TMPFILE"' EXIT

# Temporary file with custom template
TMPFILE=$(mktemp /tmp/script.XXXXXX) || die 1 "Failed to create temp file"

# Temporary directory
TMPDIR=$(mktemp -d) || die 1 "Failed to create temp directory"
trap 'rm -rf "$TMPDIR"' EXIT

# Multiple temp files with cleanup function
declare -a TEMP_FILES=()
cleanup_temps() {
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
  done
}
trap cleanup_temps EXIT

# Add temp files to cleanup list
TEMP_FILES+=("$(mktemp)")
```

### Input Sanitization

Validate and sanitize user input to prevent security issues.

```bash
# Validate filename - no directory traversal
sanitize_filename() {
  local -- name="$1"
  # Remove directory traversal attempts
  name="${name//\.\./}"
  name="${name//\//}"
  # Allow only safe characters
  if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die 1 "Invalid filename: contains unsafe characters"
  fi
  echo "$name"
}

# Validate numeric input
validate_number() {
  local -- input="$1"
  if [[ ! "$input" =~ ^-?[0-9]+$ ]]; then
    die 1 "Invalid number: '$input'"
  fi
  echo "$input"
}

# Validate email format
validate_email() {
  local -- email="$1"
  local -- regex='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
  [[ "$email" =~ $regex ]] || die 1 "Invalid email format"
  echo "$email"
}

# Escape special characters for safe display
escape_html() {
  local -- text="$1"
  text="${text//&/&amp;}"
  text="${text//</&lt;}"
  text="${text//>/&gt;}"
  text="${text//\"/&quot;}"
  text="${text//\'/&#39;}"
  echo "$text"
}
```

### Environment Variable Best Practices

Proper handling of environment variables.

```bash
# Required environment validation (script exits if not set)
: "${REQUIRED_VAR:?Environment variable REQUIRED_VAR not set}"
: "${DATABASE_URL:?DATABASE_URL must be set}"

# Optional with defaults
: "${OPTIONAL_VAR:=default_value}"
: "${LOG_LEVEL:=INFO}"

# Export with validation
export DATABASE_URL="${DATABASE_URL:-localhost:5432}"
export API_KEY="${API_KEY:?API_KEY environment variable required}"

# Check multiple required variables
check_required_env() {
  local -a required=(DATABASE_URL API_KEY SECRET_TOKEN)
  local -- var
  for var in "${required[@]}"; do
    if [[ -z "${!var:-}" ]]; then
      die 1 "Required environment variable '$var' not set"
    fi
  done
}
```

### Regular Expression Guidelines

Best practices for using regular expressions in Bash.

```bash
# Use POSIX character classes for portability
[[ "$var" =~ ^[[:alnum:]]+$ ]]      # Alphanumeric only
[[ "$var" =~ [[:space:]] ]]         # Contains whitespace
[[ "$var" =~ ^[[:digit:]]+$ ]]      # Digits only
[[ "$var" =~ ^[[:xdigit:]]+$ ]]     # Hexadecimal

# Store complex patterns in readonly variables
readonly EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
readonly IPV4_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
readonly UUID_REGEX='^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$'

# Usage
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 "Invalid email format"

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
fi
```

### Background Job Management

Managing background processes and jobs.

```bash
# Start background job and track PID
long_running_command &
PID=$!

# Check if process is still running
if kill -0 "$PID" 2>/dev/null; then
  info "Process $PID is still running"
fi

# Wait with timeout
if timeout 10 wait "$PID"; then
  success "Process completed successfully"
else
  warn "Process timed out or failed"
  kill "$PID" 2>/dev/null || true
fi

# Multiple background jobs
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done

# Wait for all background jobs
for pid in "${PIDS[@]}"; do
  wait "$pid"
done

# Job control with error handling
run_with_timeout() {
  local -i timeout="$1"; shift
  local -- command="$*"

  timeout "$timeout" bash -c "$command" &
  local -i pid=$!

  if wait "$pid"; then
    return 0
  else
    local -i exit_code=$?
    if ((exit_code == 124)); then
      error "Command timed out after ${timeout}s"
    fi
    return "$exit_code"
  fi
}
```

### Logging Best Practices

Structured logging for production scripts.

```bash
# Simple file logging
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Ensure log directory exists
[[ -d "${LOG_FILE%/*}" ]] || mkdir -p "${LOG_FILE%/*}"

# Log levels as integers for comparison
declare -A LOG_LEVELS=(
  [DEBUG]=0
  [INFO]=1
  [WARN]=2
  [ERROR]=3
  [FATAL]=4
)

# Structured logging function
log() {
  local -- level="$1"
  local -- message="${*:2}"
  local -i level_int="${LOG_LEVELS[$level]:-1}"
  local -i current_level="${LOG_LEVELS[$LOG_LEVEL]:-1}"

  # Skip if below current log level
  ((level_int >= current_level)) || return 0

  # Format: ISO8601 timestamp, script name, level, message
  printf '[%s] [%s] [%-5s] %s\n' \
    "$(date -Ins)" \
    "$SCRIPT_NAME" \
    "$level" \
    "$message" >> "$LOG_FILE"
}

# Convenience functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_fatal() { log FATAL "$@"; die 1; }

# Log rotation check
check_log_rotation() {
  local -i max_size=$((10 * 1024 * 1024))  # 10MB
  if [[ -f "$LOG_FILE" ]] && (( $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) > max_size )); then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    log_info "Log rotated"
  fi
}
```

### Performance Profiling

Simple performance measurement patterns.

```bash
# Using SECONDS builtin
profile_operation() {
  local -- operation="$1"
  SECONDS=0

  # Run operation
  eval "$operation"

  info "Operation completed in ${SECONDS}s"
}

# High-precision timing with EPOCHREALTIME
timer() {
  local -- start end runtime
  start=$EPOCHREALTIME

  "$@"

  end=$EPOCHREALTIME
  runtime=$(awk "BEGIN {print $end - $start}")
  info "Execution time: ${runtime}s"
}

# Memory usage tracking
check_memory() {
  local -i pid="${1:-$$}"
  local -i mem_kb

  if [[ -f "/proc/$pid/status" ]]; then
    mem_kb=$(grep VmRSS "/proc/$pid/status" | awk '{print $2}')
    info "Memory usage: $((mem_kb / 1024))MB"
  fi
}

# Benchmark comparisons
benchmark() {
  local -- name="$1"
  local -i iterations="${2:-100}"
  shift 2

  local -- start end
  start=$EPOCHREALTIME

  for ((i=0; i<iterations; i+=1)); do
    "$@" >/dev/null 2>&1
  done

  end=$EPOCHREALTIME
  local -- total_time=$(awk "BEGIN {print $end - $start}")
  local -- avg_time=$(awk "BEGIN {print $total_time / $iterations}")

  printf '%s: %d iterations, %.3fs total, %.6fs average\n' \
    "$name" "$iterations" "$total_time" "$avg_time"
}
```

### Testing Support Patterns

Patterns for making scripts testable.

```bash
# Dependency injection for testing
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
declare -f DATE_CMD >/dev/null || DATE_CMD() { date "$@"; }
declare -f CURL_CMD >/dev/null || CURL_CMD() { curl "$@"; }

# In production
find_files() {
  FIND_CMD "$@"
}

# In tests, override:
FIND_CMD() { echo "mocked_file1.txt mocked_file2.txt"; }

# Test mode flag
declare -i TEST_MODE="${TEST_MODE:-0}"

# Conditional behavior for testing
if ((TEST_MODE)); then
  # Use test data directory
  DATA_DIR="./test_data"
  # Disable destructive operations
  RM_CMD() { echo "TEST: Would remove $*"; }
else
  DATA_DIR="/var/lib/app"
  RM_CMD() { rm "$@"; }
fi

# Assert function for tests
assert() {
  local -- expected="$1"
  local -- actual="$2"
  local -- message="${3:-Assertion failed}"

  if [[ "$expected" != "$actual" ]]; then
    >&2 echo "ASSERT FAIL: $message"
    >&2 echo "  Expected: '$expected'"
    >&2 echo "  Actual:   '$actual'"
    return 1
  fi
  return 0
}

# Test runner pattern
run_tests() {
  local -i passed=0 failed=0
  local -- test_func

  # Find all functions starting with test_
  for test_func in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    if "$test_func"; then
      passed+=1
      echo "✓ $test_func"
    else
      failed+=1
      echo "✗ $test_func"
    fi
  done

  echo "Tests: $passed passed, $failed failed"
  ((failed == 0))
}
```

#fin
