### Parameter Expansion & Braces Usage

**Rule: BCS0210** (Merged from BCS0301 + BCS0302)

Variable expansion operations and when to use braces.

---

#### General Rule

Always quote variables with `"$var"` as the default form. Only use braces `"${var}"` when syntactically necessary.

**Rationale:** Braces add visual noise without providing value when not required. Using them only when necessary makes code cleaner and the necessary cases stand out.

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

1. **Parameter expansion operations:**
   ```bash
   "${var##*/}"        # Pattern removal
   "${var:-default}"   # Default value
   "${var:0:5}"        # Substring
   "${var//old/new}"   # Substitution
   "${var,,}"          # Case conversion
   ```

2. **Variable concatenation (no separator):**
   ```bash
   "${var1}${var2}"    # Adjacent variables
   "${prefix}suffix"   # Variable + alphanumeric
   ```

3. **Array access:**
   ```bash
   "${array[index]}"   # Element access
   "${array[@]}"       # All elements
   "${#array[@]}"      # Array length
   ```

4. **Special parameter expansion:**
   ```bash
   "${@:2}"            # Positional from 2nd
   "${10}"             # Positional > 9
   "${!var}"           # Indirect expansion
   ```

---

#### When Braces Are NOT Required

**Standalone variables:**
```bash
# ✓ Correct
"$var"  "$HOME"  "$SCRIPT_DIR"

# ✗ Wrong - unnecessary braces
"${var}"  "${HOME}"  "${SCRIPT_DIR}"
```

**Path concatenation with separators:**
```bash
# ✓ Correct - separators delimit naturally
"$PREFIX"/bin
"$PREFIX/bin"
"$SCRIPT_DIR"/build/lib

# ✗ Wrong - unnecessary braces
"${PREFIX}"/bin
"${SCRIPT_DIR}"/build
```

**In strings with separators:**
```bash
# ✓ Correct
echo "Installing to $PREFIX/bin"
info "Found $count files"

# ✗ Wrong
echo "Installing to ${PREFIX}/bin"
info "Found ${count} files"
```

---

#### Edge Cases

**When next character is alphanumeric AND no separator:**
```bash
# Braces required
"${var}_suffix"      # Prevents $var_suffix
"${prefix}123"       # Prevents $prefix123

# No braces needed - separator present
"$var-suffix"        # Dash separates
"$var.suffix"        # Dot separates
"$var/path"          # Slash separates
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
