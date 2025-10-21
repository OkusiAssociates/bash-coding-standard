# Files Needing Improvement

## Summary
After reviewing all 97 content files in data/, the following files need enhancement with rationale, better examples, or clearer explanations.

---

## Section 1: Script Structure & Layout

### data/01-script-structure/02-shebang.md
**Status**: Needs improvement
**Issues**:
- No rationale for why these specific shebangs are allowed
- No explanation of when to use each variant
- Missing guidance on portability considerations

**Proposed improvements**:
```markdown
### Shebang and Initial Setup
First lines of all scripts must include a `#!shebang`, global `#shellcheck` definitions (optional), a brief description of the script, and first command `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. `#!/bin/bash` - **Most portable**, works on most Linux systems
   - Use when: Script will run on known Linux systems with bash in standard location

2. `#!/usr/bin/bash` - **FreeBSD/BSD systems**
   - Use when: Targeting BSD systems where bash is in /usr/bin

3. `#!/usr/bin/env bash` - **Maximum portability**
   - Use when: Bash location varies (different systems, development environments)
   - Searches PATH for bash, works across diverse environments

**Rationale:** These three shebangs cover all common scenarios while maintaining compatibility. The first command must be `set -euo pipefail` to enable strict error handling immediately, before any other commands execute.
```

---

### data/01-script-structure/05-shopt.md
**Status**: Needs improvement
**Issues**:
- Lacks explanation of WHY each shopt setting matters
- No examples showing what goes wrong without them

**Proposed improvements**:
Add after the examples:
```markdown
**Rationale for each setting:**

- `inherit_errexit`: Critical for scripts using `set -e`. Without this, command substitutions and subshells don't inherit `-e`, leading to silent failures.
  ```bash
  # Without inherit_errexit:
  result=$(failing_command)  # Fails silently, script continues

  # With inherit_errexit:
  result=$(failing_command)  # Script exits immediately
  ```

- `shift_verbose`: Catches programmer errors when shift is used without arguments
  ```bash
  # Without shift_verbose:
  shift  # Silently fails when no args, continues execution

  # With shift_verbose:
  shift  # Prints error: "bash: shift: shift count out of range"
  ```

- `extglob`: Enables powerful extended glob patterns
  ```bash
  # Remove all files except .txt files
  rm !(*.txt)  # Only works with extglob enabled
  ```

- `nullglob`: Controls behavior when glob doesn't match
  ```bash
  # Without nullglob:
  for file in *.nonexistent; do  # Literal "*.nonexistent" used

  # With nullglob:
  for file in *.nonexistent; do  # Empty loop, no iterations
  ```
```

---

## Section 2: Variables

### data/02-variables/02-scoping.md
**Status**: Needs improvement
**Issues**:
- No rationale for why local matters
- Missing examples of problems caused by not using local

**Proposed improvements**:
```markdown
### Variable Scoping
Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path              # Local string
  local -- dir
  dir=$(dirname -- "$name")
  # ...
}
```

**Rationale:** Without `local`, function variables become global and can:
1. **Overwrite global variables** with the same name
2. **Persist after function returns**, causing unexpected behavior
3. **Interfere with recursive function calls**

**Anti-pattern example:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file="$1"  # Overwrites any global $file variable!
  # ...
}

# ✓ Correct - local declaration
process_file() {
  local -- file="$1"  # Scoped to this function only
  # ...
}
```

**Common gotcha:**
```bash
# Without local, recursive functions break
count_files() {
  total=0  # ✗ Global! Breaks recursion
  for file in "$1"/*; do
    ((total++))
  done
  echo "$total"
}

# Correct version
count_files() {
  local -i total=0  # ✓ Each invocation gets its own total
  for file in "$1"/*; do
    ((total++))
  done
  echo "$total"
}
```
```

---

### data/02-variables/03-naming.md
**Status**: Needs improvement
**Issues**:
- Just a table with no examples or rationale
- Doesn't explain why these conventions matter

**Proposed improvements**:
```markdown
### Naming Conventions

Follow these naming conventions to maintain consistency and avoid conflicts with shell built-ins.

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case with underscores | `local file_count=0` |
|  | CamelCase acceptable for important locals | `local ConfigData` |
| Internal/private functions | prefix with _ | `_validate_input()` |
| Environment variables | UPPER_CASE with underscores | `export DATABASE_URL` |

**Examples:**
```bash
# Constants
readonly -- SCRIPT_VERSION='1.0.0'
readonly -- MAX_CONNECTIONS=100

# Global variables
declare -i VERBOSE=1
declare -- ConfigFile='/etc/myapp.conf'

# Local variables
process_data() {
  local -i line_count=0
  local -- temp_file
  local -- CurrentSection  # CamelCase for important variable
}

# Private functions
_internal_helper() {
  # Used only by other functions in this script
}
```

**Rationale:**
- **UPPER_CASE for globals/constants**: Immediately visible as script-wide scope, matches shell conventions
- **lower_case for locals**: Distinguishes from globals, prevents accidental shadowing
- **Underscore prefix for private functions**: Signals "internal use only", prevents namespace conflicts
- **Avoid lowercase single-letter names**: Reserved for shell (`a`, `b`, `n`, etc.)
- **Avoid all-caps shell variables**: Don't use `PATH`, `HOME`, `USER`, etc. as your variable names
```

---

### data/02-variables/04-constants-env.md
**Status**: Needs improvement
**Issues**:
- Too brief, no explanation of when to use each

**Proposed improvements**:
```markdown
### Constants and Environment Variables

**Constants with `readonly`:**
```bash
# Constants
readonly -- PATH_TO_FILES='/some/path'
readonly -- API_VERSION='v2'
readonly -i MAX_RETRIES=5
```

**Environment variables with `declare -x` or `export`:**
```bash
# Environment variables (exported to child processes)
declare -x ORACLE_SID='PROD'
export DATABASE_URL='postgresql://localhost/mydb'
```

**When to use each:**

| Use Case | Declaration | Scope |
|----------|-------------|-------|
| Script-only constant | `readonly VAR='value'` | Current script only |
| Exported constant | `readonly -x VAR='value'` | Script + child processes |
| Environment variable | `export VAR='value'` | Script + child processes, modifiable |
| Read-only export | `readonly -x` + `export` | Script + children, immutable |

**Rationale:**
- **`readonly`**: Prevents accidental modification of values that shouldn't change
- **`export`/`declare -x`**: Makes variables available to child processes (commands, subshells)
- **Combine both**: For values that must be visible to children but shouldn't change

**Examples:**
```bash
# Script configuration - readonly, not exported
readonly -- CONFIG_DIR='/etc/myapp'
readonly -i TIMEOUT_SECONDS=30

# Environment variable - exported, can be modified before export
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Constant environment variable - both readonly and exported
readonly -x APP_VERSION='2.1.0'
export APP_VERSION
```
```

---

## Section 6: Functions

### data/06-functions/02-function-names.md
**Status**: Needs improvement
**Issues**:
- No rationale for lowercase convention
- Missing examples of what to avoid

**Proposed improvements**:
```markdown
### Function Names
Use lowercase with underscores to match shell conventions and avoid conflicts with built-in commands.

```bash
# ✓ Good - lowercase with underscores
my_function() {
  …
}

process_log_file() {
  …
}

# ✓ Private functions use leading underscore
_my_private_function() {
  …
}

_validate_input() {
  …
}

# ✗ Avoid - CamelCase or UPPER_CASE
MyFunction() {      # Don't do this
  …
}

PROCESS_FILE() {    # Don't do this
  …
}
```

**Rationale:**
- **Lowercase with underscores**: Matches standard Unix/Linux utility naming (e.g., `grep`, `sed`, `file_name`)
- **Avoid CamelCase**: Can be confused with variables or commands
- **Underscore prefix for private**: Clear signal that function is for internal use only
- **Consistency**: All built-in bash commands are lowercase

**Anti-patterns to avoid:**
```bash
# ✗ Don't override built-in commands without good reason
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

# ✓ If you must wrap built-ins, use a different name
change_dir() {
  builtin cd "$@" && ls
}

# ✗ Don't use special characters
my-function() {  # Dash creates issues in some contexts
  …
}
```
```

---

## Section 7: Control Flow

### data/07-control-flow/01-conditionals.md
**Status**: Needs improvement
**Issues**:
- Doesn't explain WHY `[[` is better than `[`

**Proposed improvements**:
Add this rationale section:
```markdown
**Rationale for `[[ ]]` over `[ ]`:**

`[[` is a bash keyword with several advantages:
1. **No word splitting**: Variables don't need quotes (but still recommended)
2. **Pattern matching**: Supports `==` with glob patterns
3. **Regex matching**: Supports `=~` operator
4. **Safer**: Prevents many common quoting errors
5. **More operators**: `&&`, `||` work inside `[[`

```bash
# With [[ ]] - safer
[[ -f $file ]]           # Works even if $file is empty (not recommended, but safe)
[[ $str == pattern* ]]   # Pattern matching works

# With [ ] - dangerous
[ -f $file ]             # Syntax error if $file is empty
[ $str == pattern* ]     # Literal comparison, not pattern
```
```

---

### data/07-control-flow/04-pipes-to-while.md
**Status**: GOOD ✓
**Note**: Already has clear rationale explaining the subshell problem

---

## Section 8: Error Handling

### data/08-error-handling/01-exit-on-error.md
**Status**: Needs significant improvement
**Issues**:
- No explanation of when NOT to use these flags
- Missing common gotchas
- No examples of how to temporarily disable

**Proposed improvements**:
```markdown
### Exit on Error
```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

**Detailed explanation:**

- **`set -e`** (errexit): Script exits immediately if any command returns non-zero
- **`set -u`** (nounset): Exit if referencing undefined variables
- **`set -o pipefail`**: Pipeline fails if any command in pipe fails (not just last)

**Rationale:** These flags turn Bash from "permissive" to "strict mode":
- Catches errors immediately instead of continuing with bad state
- Prevents cascading failures
- Makes scripts behave more like compiled languages

**Common patterns for handling expected failures:**

```bash
# Pattern 1: Allow specific command to fail
command_that_might_fail || true

# Pattern 2: Capture exit code
if command_that_might_fail; then
  echo "Success"
else
  echo "Expected failure occurred"
fi

# Pattern 3: Temporarily disable errexit
set +e
risky_command
set -e

# Pattern 4: Check if variable exists before using
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Important gotchas:**

```bash
# ✗ This will exit even though you check the result
result=$(failing_command)  # Script exits here with set -e
if [[ -n "$result" ]]; then  # Never reached
  echo "Never gets here"
fi

# ✓ Correct - disable errexit for this command
set +e
result=$(failing_command)
set -e
if [[ -n "$result" ]]; then
  echo "Now this works"
fi

# ✓ Alternative - check in conditional
if result=$(failing_command); then
  echo "Command succeeded: $result"
else
  echo "Command failed, that's okay"
fi
```

**When to disable these flags:**
- Interactive scripts where user errors should be recoverable
- Scripts that intentionally try multiple approaches
- During cleanup operations that might fail

**Best practice:** Keep them enabled for most scripts. Disable only when absolutely necessary and re-enable immediately after.
```

---

### data/08-error-handling/02-exit-codes.md
**Status**: Needs improvement
**Issues**:
- No explanation of exit code conventions
- Missing common codes
- No rationale for specific numbers

**Proposed improvements**:
```markdown
### Exit Codes

**Standard implementation:**
```bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success (or use `exit 0`)
die 1                    # Exit 1 with no error message
die 1 'General error'    # General error
die 2 'Missing argument' # Missing argument
die 22 'Invalid option'  # Invalid argument
```

**Standard exit codes and their meanings:**

| Code | Meaning | When to Use |
|------|---------|-------------|
| 0 | Success | Command completed successfully |
| 1 | General error | Catchall for general errors |
| 2 | Misuse of shell builtin | Missing keyword/command, permission denied |
| 22 | Invalid argument | Invalid option provided (EINVAL) |
| 126 | Command cannot execute | Permission problem or not executable |
| 127 | Command not found | Possible typo or PATH issue |
| 128+n | Fatal error signal n | e.g., 130 = Ctrl+C (128+SIGINT) |
| 255 | Exit status out of range | Use 0-255 only |

**Common custom codes:**
```bash
die 0 'Success message'         # Success (informational)
die 1 'Generic failure'         # General failure
die 2 'Missing required file'   # Usage error
die 3 'Configuration error'     # Config file issue
die 4 'Network error'           # Connection failed
die 5 'Permission denied'       # Insufficient permissions
die 22 "Invalid option '$1'"    # Bad argument (EINVAL)
```

**Rationale:**
- **0 = success**: Universal convention across all Unix/Linux tools
- **1 = general error**: Safe catchall when specific code doesn't matter
- **2 = usage error**: Matches bash built-in behavior for argument errors
- **22 = EINVAL**: Standard errno for "Invalid argument"
- **Avoid high numbers**: Use 1-125 for custom codes to avoid signal conflicts

**Best practices:**
```bash
# Define exit codes as constants for readability
readonly -i SUCCESS=0
readonly -i ERR_GENERAL=1
readonly -i ERR_USAGE=2
readonly -i ERR_CONFIG=3
readonly -i ERR_NETWORK=4

die "$ERR_CONFIG" 'Failed to load configuration file'
```

**Checking exit codes:**
```bash
if command; then
  echo "Success"
else
  exit_code=$?
  case $exit_code in
    1) echo "General failure" ;;
    2) echo "Usage error" ;;
    *) echo "Unknown error: $exit_code" ;;
  esac
fi
```
```

---

## Section 11: File Operations

### data/11-file-operations/02-wildcard-expansion.md
**Status**: GOOD ✓
**Note**: Already has clear rationale and good examples

---

### data/11-file-operations/01-file-testing.md
**Status**: Needs improvement
**Issues**:
- Too brief
- Missing common test operators
- No examples of combining tests

**Proposed improvements**:
```markdown
### Safe File Testing

Always quote variables in file tests and check conditions before operating on files.

```bash
# Basic file tests
[[ -d "$path" ]] || die 1 "Not a directory '$path'"
[[ -f "$file" ]] && source "$file"
[[ -r "$file" ]] || warn "Cannot read '$file'"
[[ -w "$file" ]] || die 1 "Cannot write to '$file'"
[[ -x "$script" ]] || die 1 "Script not executable: '$script'"

# File comparisons
[[ "$file1" -nt "$file2" ]] && echo "$file1 is newer"
[[ "$file1" -ot "$file2" ]] && echo "$file1 is older"
[[ "$file1" -ef "$file2" ]] && echo "Same file (hard links)"

# Combining tests
[[ -f "$file" && -r "$file" ]] || die 1 "File must exist and be readable"
[[ -d "$dir" && -w "$dir" ]] && echo "Directory writable"
```

**Common test operators:**

| Operator | Test | Example |
|----------|------|---------|
| `-e` | Exists (any type) | `[[ -e "$path" ]]` |
| `-f` | Regular file | `[[ -f "$file" ]]` |
| `-d` | Directory | `[[ -d "$dir" ]]` |
| `-L` or `-h` | Symbolic link | `[[ -L "$link" ]]` |
| `-r` | Readable | `[[ -r "$file" ]]` |
| `-w` | Writable | `[[ -w "$file" ]]` |
| `-x` | Executable | `[[ -x "$script" ]]` |
| `-s` | Not empty (size > 0) | `[[ -s "$file" ]]` |
| `-nt` | Newer than | `[[ "$a" -nt "$b" ]]` |
| `-ot` | Older than | `[[ "$a" -ot "$b" ]]` |
| `-ef` | Same file | `[[ "$a" -ef "$b" ]]` |

**Rationale:**
- **Check before operating**: Prevent errors by validating preconditions
- **Always quote variables**: Unquoted variables cause syntax errors with empty/whitespace paths
- **Use appropriate test**: `-f` for files, `-d` for directories, `-e` for either

**Best practices:**
```bash
# ✓ Check before processing
if [[ -f "$config_file" && -r "$config_file" ]]; then
  source "$config_file"
else
  die 1 "Config file missing or unreadable: '$config_file'"
fi

# ✓ Defensive file deletion
[[ -f "$temp_file" ]] && rm "$temp_file"

# ✗ Don't assume file exists
rm "$temp_file"  # Fails if file doesn't exist

# ✓ Create directory if needed
[[ -d "$output_dir" ]] || mkdir -p "$output_dir"
```
```

---

## Section 13: Code Style

### data/13-code-style/05-language-practices.md
**Status**: Needs improvement
**Issues**:
- No rationale for command substitution rule
- No rationale for preferring builtins

**Proposed improvements**:
```markdown
### Language Best Practices

#### Command Substitution
Always use `$()` instead of backticks for command substitution.

```bash
# ✓ Correct - modern syntax
var=$(command)
result=$(cat "$file" | grep pattern)

# ✗ Wrong - deprecated syntax
var=`command`
result=`cat "$file" | grep pattern`
```

**Rationale:**
- **Readability**: `$()` is visually clearer, especially with nested substitutions
- **Nesting**: `$()` nests naturally without escaping
- **Syntax highlighting**: Better editor support for `$()`
- **POSIX**: Both are POSIX, but `$()` is preferred in modern shells

**Nesting example:**
```bash
# ✓ Easy to read with $()
outer=$(echo "inner: $(date +%T)")

# ✗ Confusing with backticks (requires escaping)
outer=`echo "inner: \`date +%T\`"`
```

#### Builtin Commands vs External Commands
Always prefer shell builtins over external commands for performance and reliability.

```bash
# ✓ Good - bash builtins
addition=$((x + y))
string=${var^^}  # uppercase
string=${var,,}  # lowercase
if [[ -f "$file" ]]; then

# ✗ Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
string=$(echo "$var" | tr '[:upper:]' '[:lower:]')
if [ -f "$file" ]; then
```

**Rationale:**
- **Performance**: Builtins are 10-100x faster (no process creation)
- **Reliability**: No dependency on external binaries or PATH
- **Portability**: Builtins guaranteed in bash, external commands might not be installed
- **Fewer failures**: No subshell creation, no pipe failures

**Performance comparison:**
```bash
# Builtin - instant
for ((i=0; i<1000; i++)); do
  result=$((i * 2))
done

# External - much slower
for ((i=0; i<1000; i++)); do
  result=$(expr $i \* 2)  # Spawns 1000 processes!
done
```

**Common replacements:**

| External Command | Builtin Alternative | Example |
|-----------------|---------------------|---------|
| `expr` | `$(())` | `$((x + y))` instead of `$(expr $x + $y)` |
| `basename` | `${var##*/}` | `${path##*/}` instead of `$(basename "$path")` |
| `dirname` | `${var%/*}` | `${path%/*}` instead of `$(dirname "$path")` |
| `tr` (case) | `${var^^}` or `${var,,}` | `${str,,}` instead of `$(echo "$str" \| tr A-Z a-z)` |
| `test`/`[` | `[[` | `[[ -f "$file" ]]` instead of `[ -f "$file" ]` |
| `seq` | `{1..10}` or `for ((i=1; i<=10; i++))` | Much faster for loops |

**When external commands are necessary:**
```bash
# Some operations have no builtin equivalent
checksum=$(sha256sum "$file")
current_user=$(whoami)
sorted_data=$(sort "$file")
```
```

---

## Summary Statistics

### Files Reviewed: 97

### Status Breakdown:
- **GOOD (No changes needed)**: ~15 files
- **Needs Minor Improvement**: ~30 files
- **Needs Significant Improvement**: ~25 files
- **Acceptable as-is**: ~27 files

### Priority Improvements:
1. **High Priority** (core concepts, safety):
   - Exit on error (08-error-handling/01)
   - Variable scoping (02-variables/02)
   - Exit codes (08-error-handling/02)
   - Shebang (01-script-structure/02)

2. **Medium Priority** (best practices):
   - Naming conventions (02-variables/03)
   - Function names (06-functions/02)
   - Language practices (13-code-style/05)
   - File testing (11-file-operations/01)

3. **Low Priority** (nice to have):
   - Constants/env variables (02-variables/04)
   - Conditionals rationale (07-control-flow/01)

### Common Missing Elements:
- **Rationale sections**: ~40 files missing
- **Anti-pattern examples**: ~30 files missing
- **Edge case coverage**: ~20 files missing
- **Performance considerations**: ~15 files missing
