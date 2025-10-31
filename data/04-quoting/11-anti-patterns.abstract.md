## Anti-Patterns (What NOT to Do)

**Avoid quoting mistakes causing security flaws, word splitting bugs, and poor maintainability.**

**Critical rationale:**
- **Security:** Improper quoting enables injection attacks
- **Reliability:** Unquoted variables cause word splitting/glob expansion

**Top anti-patterns:**

1. **Double quotes for static** �' `info 'text'` not `info "text"`
2. **Unquoted variables** �' `[[ -f "$file" ]]` not `[[ -f $file ]]`
3. **Unnecessary braces** �' `"$HOME/bin"` not `"${HOME}/bin"`
4. **Unquoted arrays** �' `"${items[@]}"` not `${items[@]}`

**Example:**

```bash
# ✗ Wrong
info "Starting..."          # Use single quotes
[[ -f $file ]]              # Quote variable
path="${HOME}/bin"          # Braces not needed
for x in ${arr[@]}; do      # Quote array

# ✓ Correct
info 'Starting...'
[[ -f "$file" ]]
path="$HOME/bin"
for x in "${arr[@]}"; do
```

**Quick check:**

```bash
'static'                 ✓
"static"                 ✗
"text $var"              ✓  # No braces
"text ${var}"            ✗  # Unnecessary
[[ -f "$file" ]]         ✓
[[ -f $file ]]           ✗  # Dangerous
"${array[@]}"            ✓  # Needs braces+quotes
${array[@]}              ✗
```

**Key:** Quote variables always, single quotes for static text, avoid unnecessary braces.

**Ref:** BCS0411
