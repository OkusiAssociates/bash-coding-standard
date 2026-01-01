### Quoting Anti-Patterns

**Avoid common quoting mistakes that cause word splitting, glob expansion, and inconsistent code.**

---

#### Critical Anti-Patterns

**Static strings:** Use single quotes â†' `info 'message'` not `info "message"`

**Unquoted variables:** Always quote â†' `"$var"` not `$var`

**Unnecessary braces:** Omit when not needed â†' `"$HOME"/bin` not `"${HOME}/bin"`

**Braces required for:** `${var:-default}`, `${file##*/}`, `"${array[@]}"`, `${var1}${var2}`

**Arrays:** Always quote â†' `"${items[@]}"` not `${items[@]}`

**Glob danger:** `echo "$pattern"` preserves literal; `echo $pattern` expands

**Here-docs:** Quote delimiter for literal content â†' `<<'EOF'` not `<<EOF`

---

#### Example

```bash
# âœ— Wrong
info "Starting..."
[[ -f $file ]]
echo "${HOME}/bin"

# âœ“ Correct
info 'Starting...'
[[ -f "$file" ]]
echo "$HOME"/bin
```

---

#### Quick Reference

| Context | Correct | Wrong |
|---------|---------|-------|
| Static | `'literal'` | `"literal"` |
| Variable | `"$var"` | `$var` |
| Path | `"$HOME"/bin` | `"${HOME}/bin"` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Ref:** BCS0307
