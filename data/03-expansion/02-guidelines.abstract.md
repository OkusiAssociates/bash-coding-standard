## Variable Expansion Guidelines

**Always use `"$var"` as default. Only use braces `"${var}"` when syntactically required.**

**Rationale:** Braces add visual noise without value. Using them only when necessary makes code cleaner and highlights actual requirements.

#### Braces Required

1. **Parameter expansion:** `"${var##*/}"`, `"${var%/*}"`, `"${var:-default}"`, `"${var:0:5}"`, `"${var//old/new}"`, `"${var,,}"`
2. **Concatenation (no separator):** `"${var1}${var2}"`, `"${prefix}suffix"`
3. **Arrays:** `"${array[i]}"`, `"${array[@]}"`, `"${#array[@]}"`
4. **Special parameters:** `"${@:2}"`, `"${10}"`, `"${!var}"`

#### Braces Not Required

```bash
# ✓ Correct - simple form
"$var"
"$HOME/path"
"$PREFIX"/bin
[[ -f "$SCRIPT_DIR"/file ]]
echo "Found $count files in $dir"

# ✗ Wrong - unnecessary braces
"${var}"
"${HOME}/path"
"${PREFIX}"/bin
```

**Path patterns:** `"$var"/literal/"$var"` → Quotes protect variables, separators (`/`, `-`, `.`) delimit naturally.

**Edge case - alphanumeric follows with no separator:**
```bash
"${var}_suffix"    # ✓ Required - prevents $var_suffix
"$var-suffix"      # ✓ No braces - dash separates
```

**Key Principle:** Default to `"$var"`. Add braces only when shell requires them for correct parsing.

**Ref:** BCS0302
