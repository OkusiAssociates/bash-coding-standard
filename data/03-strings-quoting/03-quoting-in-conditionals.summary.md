### Quoting in Conditionals

**Rule: BCS0303**

**Always quote variables** in conditionals. Static comparison values follow normal rules (single quotes for literals).

```bash
# ✓ Correct - variable quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]
[[ "$count" -eq 0 ]]

# ✗ Wrong - unquoted variable
[[ -f $file ]]
[[ $name == value ]]
```

---

#### Rationale

- **Word splitting**: `$file` with spaces becomes multiple arguments
- **Glob expansion**: `$file` with `*` expands to matching files
- **Empty values**: Unquoted empty variables cause syntax errors
- **Security**: Prevents injection attacks

---

#### Common Patterns

```bash
# File tests
[[ -f "$file" ]]
[[ -d "$directory" && -r "$directory" ]]

# String comparisons (variable quoted, literal single-quoted)
[[ "$action" == 'start' ]]
[[ -z "$value" ]]

# Numeric comparisons
declare -i count=0
((count > 10))

# Pattern matching (pattern unquoted for globbing)
[[ "$filename" == *.txt ]]        # Glob match
[[ "$filename" == '*.txt' ]]      # Literal match

# Regex (pattern variable unquoted)
pattern='^[0-9]+$'
[[ "$input" =~ $pattern ]]        # ✓ Pattern unquoted
[[ "$input" =~ "$pattern" ]]      # ✗ Becomes literal
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted variable
[[ -f $file ]]              # Breaks with spaces

# ✗ Wrong - double quotes for static literal
[[ "$mode" == "production" ]]

# ✓ Correct
[[ "$mode" == 'production' ]]
[[ "$mode" == production ]]  # One-word literal OK
```

---

**Key principle:** Quote all variables in conditionals: `[[ -f "$file" ]]`.

#fin
