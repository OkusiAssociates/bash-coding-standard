### Quoting Anti-Patterns

**Avoid quoting mistakes that cause word splitting, glob expansion, or unnecessary verbosity.**

---

#### Critical Categories

**1. Static strings** â†' Use single quotes: `'literal'` not `"literal"`

**2. Variables** â†' Always quote: `"$var"` not `$var`

**3. Braces** â†' Omit unless needed: `"$HOME"/bin` not `"${HOME}/bin"`
- Braces required: `${var:-default}`, `${file##*/}`, `"${array[@]}"`

**4. Arrays** â†' Always quote: `"${items[@]}"` not `${items[@]}`

---

#### Minimal Example

```bash
# âœ— Anti-patterns
info "Static message"
[[ -f $file ]]
echo "${HOME}/bin"

# âœ“ Correct
info 'Static message'
[[ -f "$file" ]]
echo "$HOME"/bin
```

---

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static | `'text'` | `"text"` |
| Variable | `"$var"` | `$var` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Ref:** BCS0307
