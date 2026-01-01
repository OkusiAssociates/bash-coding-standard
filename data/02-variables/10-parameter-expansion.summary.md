### Parameter Expansion & Braces Usage

**Rule: BCS0210**

Use `"$var"` as default; add braces `"${var}"` only when syntactically required.

---

#### Parameter Expansion Operations

```bash
# Pattern removal
SCRIPT_NAME=${SCRIPT_PATH##*/}  # Remove longest prefix pattern
SCRIPT_DIR=${SCRIPT_PATH%/*}    # Remove shortest suffix pattern

# Default values
${var:-default}                 # Use default if unset or null
${var:=default}                 # Set default if unset or null
${var:+alternate}               # Use alternate if set and non-null

# Substrings
${var:0:5}                      # First 5 characters
${var:(-3)}                     # Last 3 characters

# Pattern substitution
${var//old/new}                 # Replace all occurrences
${var/old/new}                  # Replace first occurrence
${var/#pattern/replace}         # Replace prefix
${var/%pattern/replace}         # Replace suffix

# Case conversion (Bash 4.0+)
${var,,}                        # All lowercase
${var^^}                        # All uppercase
${var~}                         # Toggle first char
${var~~}                        # Toggle all chars

# Special parameters
"${@:2}"                        # All args from 2nd onwards
"${10}"                         # Positional param > 9
${#var}                         # String length
${!prefix@}                     # Variables starting with prefix
```

---

#### When Braces Are REQUIRED

1. **Parameter expansion operations:** `"${var##*/}"`, `"${var:-default}"`, `"${var:0:5}"`, `"${var//old/new}"`, `"${var,,}"`

2. **Variable concatenation (no separator):** `"${var1}${var2}"`, `"${prefix}suffix"`

3. **Array access:** `"${array[index]}"`, `"${array[@]}"`, `"${#array[@]}"`

4. **Special parameter expansion:** `"${@:2}"`, `"${10}"`, `"${!var}"`

---

#### When Braces Are NOT Required

```bash
# ✓ Correct - standalone variables
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✓ Correct - separators delimit naturally
"$PREFIX"/bin
"$PREFIX/bin"
echo "Installing to $PREFIX/bin"

# ✗ Wrong - unnecessary braces
"${var}"  "${HOME}"  "${PREFIX}"/bin
```

---

#### Edge Cases

```bash
# Braces required - alphanumeric follows without separator
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"        # Dash separates
"$var.suffix"        # Dot separates
"$var/path"          # Slash separates
```

---

#### Summary

| Situation | Form | Example |
|-----------|------|---------|
| Standalone variable | `"$var"` | `"$HOME"` |
| Path with separator | `"$var"/path` | `"$BIN_DIR"/file` |
| Parameter expansion | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation (no sep) | `"${var1}${var2}"` | `"${prefix}${suffix}"` |
| Array access | `"${array[i]}"` | `"${args[@]}"` |

**Key Principle:** Use `"$var"` by default. Only add braces when required for correct parsing.

#fin
