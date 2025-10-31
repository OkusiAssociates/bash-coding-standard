## Parameter Expansion

### Rationale

Parameter expansion enables string manipulation, default values, and substring operations without external commands. Braces are **required** when expansion syntax demands them (operators, array access, concatenation), otherwise prefer simple `"$var"` form for readability.

### When Braces Are Required

**Expansion operators** (patterns, defaults, substrings):
```bash
SCRIPT_NAME=${SCRIPT_PATH##*/}    # Remove longest prefix match
SCRIPT_DIR=${SCRIPT_PATH%/*}      # Remove shortest suffix match
${var:-default}                   # Use default if unset/null
${var:=default}                   # Assign default if unset/null
${var:+alternate}                 # Use alternate if set
${var:?error}                     # Error if unset/null
${var:offset:length}              # Substring extraction
${#var}                           # String length
${var,,}                          # Convert to lowercase
${var^^}                          # Convert to uppercase
${var//pattern/replacement}       # Global pattern replacement
```

**Array operations**:
```bash
${array[@]}                       # All elements (word splitting)
${array[*]}                       # All elements (single string)
${#array[@]}                      # Array length
${array[index]}                   # Specific element
"${@:2}"                          # Positional params from 2nd onward
```

**Variable concatenation** (disambiguates boundaries):
```bash
echo "${prefix}${suffix}"         # Required: no separator between vars
echo "${var}text"                 # Required: appending literal text
```

### When Braces Are Optional

Simple variable references without operators:
```bash
echo "$var"                       # Preferred (not "${var}")
[[ -f "$file" ]]                  # Preferred (not "${file}")
command "$arg1" "$arg2"           # Preferred
```

Use braces only when technically required - they add visual noise without benefit for basic references.

### Pattern Removal Examples

**Prefix removal** (`#` = shortest, `##` = longest):
```bash
path=/usr/local/bin/script.sh
${path#*/}                        # usr/local/bin/script.sh
${path##*/}                       # script.sh (basename)
```

**Suffix removal** (`%` = shortest, `%%` = longest):
```bash
filename=archive.tar.gz
${filename%.*}                    # archive.tar
${filename%%.*}                   # archive (remove all extensions)
${path%/*}                        # /usr/local/bin (dirname)
```

### Default Values Pattern

**Use `:-` for providing defaults**:
```bash
# Command-line arg or default
OUTPUT_DIR=${1:-/tmp/output}

# Environment variable or fallback
LOG_LEVEL=${LOG_LEVEL:-INFO}

# Optional config with sensible default
TIMEOUT=${TIMEOUT:-30}
```

**Difference between operators**:
```bash
${var:-default}                   # If unset OR null, use default (common)
${var-default}                    # If unset only (rare - allows explicit null)
${var:=default}                   # Assign default if unset/null (modifies var)
${var:+alternate}                 # If set, use alternate value
${var:?error_msg}                 # Exit with error if unset/null
```

### Substring Extraction

```bash
${var:offset}                     # From offset to end
${var:offset:length}              # From offset, length chars
${var:0:1}                        # First character
${var: -3}                        # Last 3 chars (space before - required)
```

**Note**: Negative offset requires space `${var: -n}` or parentheses `${var:(-n)}` to distinguish from `${var:-default}`.

### Case Conversion (Bash 4.0+)

```bash
${var,,}                          # All lowercase
${var^^}                          # All uppercase
${var,}                           # First char lowercase
${var^}                           # First char uppercase
${var,,pattern}                   # Lowercase matching chars
${var^^pattern}                   # Uppercase matching chars
```

### Pattern Replacement

```bash
${var/pattern/string}             # Replace first match
${var//pattern/string}            # Replace all matches (global)
${var/#pattern/string}            # Replace at beginning
${var/%pattern/string}            # Replace at end
${var/pattern}                    # Delete first match (empty replacement)
${var//pattern}                   # Delete all matches
```

**Example**:
```bash
path=/usr/local/bin:/usr/bin
${path//:/,}                      # /usr/local/bin,/usr/bin (colons to commas)
```

### Length Operations

```bash
${#var}                           # String length in characters
${#array[@]}                      # Number of array elements
${#array[3]}                      # Length of element at index 3
```

### Anti-Patterns

**L Unnecessary braces on simple references**:
```bash
echo "${HOME}/bin"                # Excessive (operator not needed)
echo "$HOME/bin"                  # Correct
```

**L Unquoted expansions**:
```bash
file=${1:-default.txt}
cat $file                         # Wrong - word splitting/globbing
cat "$file"                       # Correct
```

**L Incorrect negative substring**:
```bash
${var:-3}                         # Wrong - means "default value is -3"
${var: -3}                        # Correct - last 3 chars (note space)
${var:(-3)}                       # Also correct - parentheses
```

**L Using external commands instead of expansion**:
```bash
basename "$path"                  # Spawns process
${path##*/}                       # Pure bash (faster)

dirname "$path"                   # Spawns process
${path%/*}                        # Pure bash (faster)
```

### Edge Cases

**Empty values vs unset**:
```bash
unset var
${var:-default}                   # Returns "default" (var unset)

var=""
${var:-default}                   # Returns "default" (var null)
${var-default}                    # Returns "" (var set, even if empty)
```

**Array slicing**:
```bash
args=("$@")
"${args[@]:1}"                    # All args except first
"${args[@]:0:2}"                  # First two args
"${args[@]: -2}"                  # Last two args (space required)
```

**Pattern matching with extglob**:
```bash
shopt -s extglob
file=test.backup.old
${file%%.*(@(bak|old|tmp))}       # Advanced pattern with extglob
```
