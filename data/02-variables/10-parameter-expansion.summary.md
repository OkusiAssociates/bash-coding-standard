### Parameter Expansion & Braces Usage

**Rule: BCS0210**

Use `"$var"` as default. Only use braces `"${var}"` when syntactically necessary—braces add visual noise without value when not required.

---

#### Parameter Expansion Operations

```bash
# Pattern removal
SCRIPT_NAME=${SCRIPT_PATH##*/}  # Remove longest prefix
SCRIPT_DIR=${SCRIPT_PATH%/*}    # Remove shortest suffix

# Default values
${var:-default}                 # Use default if unset/null
${var:=default}                 # Set default if unset/null
${var:+alternate}               # Use alternate if set and non-null

# Substrings
${var:0:5}                      # First 5 characters
${var:(-3)}                     # Last 3 characters

# Pattern substitution
${var//old/new}                 # Replace all occurrences
${var/old/new}                  # Replace first occurrence

# Case conversion (Bash 4.0+)
${var,,}  ${var^^}              # All lower/uppercase

# Special parameters
"${@:2}"  "${10}"  ${#var}      # Args from 2nd, param >9, length
```

---

#### When Braces Are REQUIRED

1. **Parameter expansion operations:** `"${var##*/}"` `"${var:-default}"` `"${var:0:5}"`
2. **Concatenation (no separator):** `"${var1}${var2}"` `"${prefix}suffix"`
3. **Array access:** `"${array[index]}"` `"${array[@]}"` `"${#array[@]}"`
4. **Special parameters:** `"${@:2}"` `"${10}"` `"${!var}"`

---

#### When Braces Are NOT Required

```bash
# ✓ Standalone variables
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✓ Path concatenation with separators
"$PREFIX"/bin
"$SCRIPT_DIR"/build/lib

# ✓ In strings with separators
echo "Installing to $PREFIX/bin"

# ✗ Wrong - unnecessary braces
"${var}"  "${PREFIX}"/bin  "${count} files"
```

---

#### Edge Cases

```bash
# Braces required - next char alphanumeric AND no separator
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"  "$var.suffix"  "$var/path"
```

---

#### Summary Table

| Situation | Form | Example |
|-----------|------|---------|
| Standalone variable | `"$var"` | `"$HOME"` |
| Path with separator | `"$var"/path` | `"$BIN_DIR"/file` |
| Parameter expansion | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation (no sep) | `"${var1}${var2}"` | `"${prefix}${suffix}"` |
| Array access | `"${array[i]}"` | `"${args[@]}"` |

**Key Principle:** Use `"$var"` by default. Only add braces when required for correct parsing.

#fin
