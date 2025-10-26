## Parameter Expansion

**Use parameter expansion for string manipulation and defaults instead of external commands.**

**Rationale:** Native bash operations are 10-100x faster than subshells/external commands; reduces process creation overhead; enables atomic variable manipulation.

**Core patterns:**
```bash
# Pattern removal (paths)
SCRIPT_NAME=${SCRIPT_PATH##*/}   # Remove longest prefix (dirname)
SCRIPT_DIR=${SCRIPT_PATH%/*}     # Remove shortest suffix (basename)

# Defaults and substrings
${var:-default}                  # Use default if unset/null
${var:offset:length}             # Extract substring
${#var}                          # String length
${#array[@]}                     # Array length

# Case conversion (Bash 4.0+)
${var,,}                         # Lowercase
${var^^}                         # Uppercase

# Positional parameters
"${@:2}"                         # All args from 2nd onward
```

**Anti-patterns:**
- `$(basename "$file")` ’ Use `${file##*/}`
- `$(dirname "$file")` ’ Use `${file%/*}`
- `"${var:=$default}"` in readonly context ’ Use `${var:-$default}`

**Ref:** BCS0301
