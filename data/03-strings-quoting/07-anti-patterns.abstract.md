### Quoting Anti-Patterns

**Avoid common quoting mistakes: staticâ†'single, varsâ†'double-quoted, minimal braces.**

#### Critical Anti-Patterns

**Static strings:** `info "text"` â†' `info 'text'`

**Unquoted vars:** `[[ -f $file ]]` â†' `[[ -f "$file" ]]` (word-split/glob risk)

**Unnecessary braces:** `"${HOME}/bin"` â†' `"$HOME/bin"` (braces only for: `${var:-}`, `${var##}`, `${arr[@]}`, `${v1}${v2}`)

**Arrays:** `${arr[@]}` â†' `"${arr[@]}"`

**Here-docs:** Unquoted delimiter expands vars; use `<<'EOF'` for literals

#### Example

```bash
# âœ— Anti-patterns
info "Starting..."
[[ -f $file ]]
echo "${HOME}/bin"

# âœ“ Correct
info 'Starting...'
[[ -f "$file" ]]
echo "$HOME/bin"
```

| Context | Correct | Wrong |
|---------|---------|-------|
| Static | `'text'` | `"text"` |
| Variable | `"$var"` | `$var` |
| Array | `"${arr[@]}"` | `${arr[@]}` |

**Ref:** BCS0307
