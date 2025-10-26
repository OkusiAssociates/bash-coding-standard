## Variables in Conditionals

**Always quote variables in test expressions; static comparison values use single quotes for literals or remain unquoted for one-word values.**

**Rationale:**
- Prevents word splitting/glob expansion on multi-word values or wildcards
- Empty variables cause syntax errors when unquoted
- Security: prevents injection via input manipulation

**Core patterns:**

```bash
# File tests - quote variable
[[ -f "$file" ]]           # ✓ Correct
[[ -f $file ]]             # ✗ Fails with spaces

# String comparison - quote variable, single-quote literal
[[ "$mode" == 'production' ]]  # ✓ Correct
[[ "$mode" == production ]]    # ✓ Also valid (one-word)
[[ "$mode" == "production" ]]  # ✗ Unnecessary double quotes

# Integer comparison - quote variable
[[ "$count" -eq 0 ]]       # ✓ Correct

# Pattern matching - quote variable, unquote pattern
[[ "$file" == *.txt ]]     # ✓ Glob matching
[[ "$file" == '*.txt' ]]   # ✓ Literal match

# Regex - quote variable, unquote pattern
pattern='^[0-9]+$'
[[ "$input" =~ $pattern ]] # ✓ Correct
[[ "$input" =~ "$pattern" ]] # ✗ Treats as literal
```

**Anti-patterns:**
- `[[ -f $file ]]` → Fails if `$file` contains spaces or wildcards
- `[[ -z $empty ]]` → Syntax error if `$empty` is unset/empty
- `[[ "$mode" == "production" ]]` → Use single quotes for static strings

**Ref:** BCS0406
