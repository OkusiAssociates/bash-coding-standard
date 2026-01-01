### Quoting Anti-Patterns

**Rule: BCS0307**

Common quoting mistakes to avoid.

---

#### Category 1: Double Quotes for Static Strings

```bash
# ✗ Wrong
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]
```

---

#### Category 2: Unquoted Variables

```bash
# ✗ Wrong - word splitting/glob expansion
[[ -f $file ]]
echo $result

# ✓ Correct
[[ -f "$file" ]]
echo "$result"
```

---

#### Category 3: Unnecessary Braces

```bash
# ✗ Wrong - braces not needed
echo "${HOME}/bin"

# ✓ Correct
echo "$HOME"/bin

# Braces ARE needed for:
"${var:-default}"     # Default value
"${file##*/}"         # Parameter expansion
"${array[@]}"         # Array expansion
"${var1}${var2}"      # Adjacent variables
```

---

#### Category 4: Unquoted Arrays

```bash
# ✗ Wrong
for item in ${items[@]}; do

# ✓ Correct
for item in "${items[@]}"; do
```

---

#### Category 5: Glob Expansion Danger

```bash
pattern='*.txt'

# ✗ Wrong
echo $pattern       # Expands to all .txt files!

# ✓ Correct
echo "$pattern"     # Outputs literal: *.txt
```

---

#### Category 6: Here-doc Delimiter

```bash
# ✗ Wrong - variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Correct - quoted for literal content
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static string | `'literal'` | `"literal"` |
| Variable | `"$var"` | `$var` |
| Path with var | `"$HOME"/bin` | `"${HOME}/bin"` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Key principle:** Single quotes for static text, double quotes for variables, avoid unnecessary braces, always quote variables.

#fin
