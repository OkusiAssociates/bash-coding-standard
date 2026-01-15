# File Operations

**Use explicit paths, quote all variables, prefer process substitution over pipes.**

## File Tests
Always quote: `[[ -f "$file" ]]` `[[ -d "$dir" ]]` `[[ -r "$path" ]]`

## Safe Wildcards
`rm ./*` â†' never `rm *`; explicit path prevents catastrophic deletion

## Process Substitution
```bash
while IFS= read -r line; do
    ((count++))
done < <(command)
# Variables persist (no subshell)
```

## Anti-Patterns
- `rm *` â†' use `rm ./*`
- `cat file | while read` â†' use `while read < <(cat file)` or `< file`

**Ref:** BCS0900
