## Arithmetic Operations

**Use `declare -i` for integers; use `i+=1` for increments; use `(())` for comparisons.**

### Core Rules

- **`declare -i`**: Required for all integers (enables auto-arithmetic context)
- **Increment**: Only `i+=1` — never `((i++))` (fails with `set -e` when i=0)
- **Comparisons**: Use `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` for non-zero checks

### Operators

`+` `-` `*` `/` `%` `**` | Comparisons: `<` `<=` `>` `>=` `==` `!=`

### Example

```bash
declare -i i=0 max=5
while ((i < max)); do
  process_item
  i+=1
done
((i < max)) || die 1 'Max reached'
```

### Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `((i++))` | `i+=1` |
| `[[ "$x" -gt 5 ]]` | `((x > 5))` |
| `((result = $i + $j))` | `((result = i + j))` |
| `expr $i + $j` | `$((i + j))` |

**Note:** Integer division truncates; use `bc` for floats.

**Ref:** BCS0505
