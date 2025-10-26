## Anti-Patterns (What NOT to Do)

**Avoid common quoting mistakes that cause bugs, security issues, maintenance problems.**

**Critical: Improper quoting enables injection attacks and word-splitting bugs.**

**Categories:**

1. **Double quotes for static** (most common)
```bash
# ✗ Wrong: info "Static text"
# ✓ Correct: info 'Static text'
```

2. **Unquoted variables** (dangerous)
```bash
# ✗ Wrong: [[ -f $file ]]
# ✓ Correct: [[ -f "$file" ]]
```

3. **Unnecessary braces**
```bash
# ✗ Wrong: echo "${HOME}/bin"
# ✓ Correct: echo "$HOME/bin"
```

4. **Mixed styles**
```bash
# ✗ Wrong: Mix "static" and 'static'
# ✓ Correct: All 'static'
```

5. **Glob expansion**
```bash
# ✗ Wrong: echo $pattern (expands!)
# ✓ Correct: echo "$pattern"
```

6. **Command substitution**
```bash
# ✗ Wrong: $(cat "${file}")
# ✓ Correct: $(cat "$file")
```

**Checklist:**
```bash
'literal'          ✓
"literal"          ✗
"text $var"        ✓
"text ${var}"      ✗ (braces not needed)
[[ -f "$file" ]]   ✓
[[ -f $file ]]     ✗
"${array[@]}"      ✓
${array[@]}        ✗
"${var##*/}"       ✓ (expansion needs braces)
"${HOME}"          ✗ (braces not needed)
```

**Rule:** Quote variables, single-quote statics, no unnecessary braces. Prevents injection/word-splitting.

**Ref:** BCS0411
