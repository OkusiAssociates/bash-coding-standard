# Quoting & String Literals

**Use single quotes for static text, double quotes when shell processing (variables/substitution/escapes) needed.**

**Rationale:**
- Prevents word-splitting/globbing errors in variables
- Semantic signal: `'literal'` vs `"$processed"`

**Core Patterns:**

```bash
# Static strings → single quotes
info 'Processing complete'

# Variables/substitution → double quotes
info "Found $count files in $dir"
echo "Result: $(command)"

# Conditionals → always quote variables
[[ -f "$file" ]] && [[ "$status" == 'active' ]]

# Arrays → quote expansion
for item in "${array[@]}"; do
  process "$item"
done
```

**Critical Anti-Patterns:**

```bash
# ✗ Wrong - double quotes for static text
echo "Processing files..."

# ✗ Wrong - unquoted variable in test
[[ -f $file ]]

# ✗ Wrong - unquoted array expansion
for item in ${array[@]}; do

# ✓ Correct
echo 'Processing files...'
[[ -f "$file" ]]
for item in "${array[@]}"; do
```

**Ref:** BCS0400
