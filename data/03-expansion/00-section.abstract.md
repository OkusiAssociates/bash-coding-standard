# Variable Expansion & Parameter Substitution

**Default to `"$var"` without braces; use `"${var}"` only when syntactically required.**

**When braces required:**
- Parameter expansion: `"${var##pattern}"`, `"${var:-default}"`, `"${var/pattern/replacement}"`
- Array expansion: `"${array[@]}"`, `"${array[*]}"`
- Concatenation: `"${var1}${var2}"`, `"${var}_suffix"`
- Disambiguation: `"${var}text"` (prevents parsing ambiguity)

**When braces NOT required:**
- Simple expansion: `"$var"` not `"${var}"`
- Command substitution: `"$(command)"` not `"${$(command)}"`
- Arithmetic: `"$((expr))"` not `"${$((expr))}"`
- In conditionals: `[[ -f "$file" ]]` not `[[ -f "${file}" ]]`

**Rationale:** Reduces visual noise, matches standard shell idioms, reserves braces for operations that genuinely require them.

**Example:**
```bash
# ✓ Correct - braces only where needed
name='deploy'
version='1.0.0'
file="${name}-${version}.tar.gz"    # Concatenation
default_path="${HOME:-/tmp}/bin"    # Parameter expansion
echo "Installing $file to $default_path"  # Simple expansion

# ✗ Wrong - unnecessary braces
echo "Installing ${file} to ${default_path}"
```

**Anti-patterns:**
- `"${var}"` when `"$var"` works → Unnecessary complexity
- `"$var1$var2"` without braces → Fails to concatenate properly (use `"${var1}${var2}"`)

**Ref:** BCS0300
