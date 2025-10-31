## Variable Expansion Guidelines

**General Rule:** Always quote variables with `"$var"` as the default form. Only use braces `"${var}"` when syntactically necessary.

**Rationale:** Braces add visual noise without value when not required. Using them only when necessary makes code cleaner and necessary cases stand out.

#### When Braces Are REQUIRED

1. **Parameter expansion operations:**
   ```bash
   "${var##*/}"      # Remove longest prefix pattern
   "${var%/*}"       # Remove shortest suffix pattern
   "${var:-default}" # Default value
   "${var:0:5}"      # Substring
   "${var//old/new}" # Pattern substitution
   "${var,,}"        # Case conversion
   ```

2. **Variable concatenation (no separator):**
   ```bash
   "${var1}${var2}${var3}"  # Multiple variables joined
   "${prefix}suffix"        # Variable immediately followed by alphanumeric
   ```

3. **Array access:**
   ```bash
   "${array[index]}"         # Array element access
   "${array[@]}"             # All array elements
   "${#array[@]}"            # Array length
   ```

4. **Special parameter expansion:**
   ```bash
   "${@:2}"                  # Positional parameters starting from 2nd
   "${10}"                   # Positional parameters beyond $9
   "${!var}"                 # Indirect expansion
   ```

#### When Braces Are NOT Required

**Default form for standalone variables:**
```bash
#  Correct - use simple form
"$var"
"$HOME"
"$SCRIPT_DIR"
"$1" "$2" ... "$9"

#  Wrong - unnecessary braces
"${var}"                    #  Don't do this
"${HOME}"                   #  Don't do this
"${SCRIPT_DIR}"             #  Don't do this
```

**Path concatenation with separators:**
```bash
#  Correct - quotes handle the concatenation
"$PREFIX"/bin               # When separate arguments
"$PREFIX/bin"               # When single string
"$SCRIPT_DIR"/build/lib/file.so

#  Wrong - unnecessary braces
"${PREFIX}"/bin             #  Unnecessary
"${PREFIX}/bin"             #  Unnecessary
"${SCRIPT_DIR}"/build/lib   #  Unnecessary
```

**Note:** The pattern `"$var"/literal/"$var"` (mixing quoted variables with unquoted literals/separators) is acceptable and preferred. Quotes protect variables while separators (/, -, ., etc.) naturally delimit:

```bash
result="$path"/file.txt
config="$HOME"/.config/"$APP"/settings
[[ -f "$dir"/subdir/file ]]
echo "$path"/build/output
```

**In strings and conditionals:**
```bash
#  Correct
echo "Installing to $PREFIX/bin"
info "Found $count files"
[[ -d "$path" ]]
[[ -f "$SCRIPT_DIR"/file ]]

#  Wrong - unnecessary braces
echo "Installing to ${PREFIX}/bin"  #  Slash separates, braces not needed
info "Found ${count} files"         #  Space separates, braces not needed
[[ -d "${path}" ]]                  #  Unnecessary
```

#### Edge Cases

**When next character is alphanumeric AND no separator:**
```bash
# Braces required - ambiguous without them
"${var}_suffix"             #  Prevents $var_suffix interpretation
"${prefix}123"              #  Prevents $prefix123 interpretation

# No braces needed - separator present
"$var-suffix"               #  Dash is separator
"$var.suffix"               #  Dot is separator
"$var/path"                 #  Slash is separator
```

#### Summary Table

| Situation | Form | Example |
|-----------|------|---------|
| Standalone variable | `"$var"` | `"$HOME"` |
| Path with separator | `"$var"/path` or `"$var/path"` | `"$BIN_DIR"/file` |
| Parameter expansion | `"${var%pattern}"` | `"${path%/*}"` |
| Concatenation (no separator) | `"${var1}${var2}"` | `"${prefix}${suffix}"` |
| Array access | `"${array[i]}"` | `"${args[@]}"` |
| In strings | `"$var"` | `echo "File: $path"` |
| Conditionals | `"$var"` | `[[ -f "$file" ]]` |

**Key Principle:** Use `"$var"` by default. Only add braces when the shell requires them for correct parsing.
