## Arithmetic Operations

**Use `declare -i` for integers, `(())` for comparisons, and `i+=1` for increments.**

### Core Rules

- **Declare integers**: `declare -i count=0` â€” enables auto-arithmetic, type safety
- **Increment**: `i+=1` ONLY â†' requires `declare -i`; `((i++))` exits with `set -e` when i=0
- **Comparisons**: Use `(())` not `[[ -eq ]]` â†' `((count > 10))` not `[[ "$count" -gt 10 ]]`
- **Truthiness**: `((count))` not `((count > 0))` â€” non-zero is truthy

### Pattern

```bash
declare -i i=0 max=5
while ((i < max)); do
  process_item
  i+=1
done
((i < max)) || die 1 'Max reached'
```

### Anti-Patterns

```bash
# âœ— NEVER - exits with set -e when i=0
((i++))

# âœ— Verbose/old-style
[[ "$count" -gt 10 ]]

# âœ“ Correct
((count > 10))
i+=1
```

### Why `((i++))` Fails

```bash
set -e; i=0
((i++))  # Returns 0 (old value) = "false" â†' script exits!
```

### Operators

| Op | Use | Note |
|----|-----|------|
| `+=` | `i+=1` | Only increment form |
| `(())` | Comparisons | `<` `>` `==` `!=` `<=` `>=` |
| `$(())` | Expressions | `result=$((a + b))` |

**Ref:** BCS0505
