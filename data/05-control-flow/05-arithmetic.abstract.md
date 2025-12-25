## Arithmetic Operations

**Always use `declare -i` for integers; use `i+=1` for increment (NEVER `((i++))`).**

### Core Requirements

- `declare -i` mandatory for all integer variables (BCS0201)
- Use `(())` for arithmetic expressions and conditionals
- Use `$((expr))` only when value needed inline
- No `$` prefix inside `(())` for variables
- Use arithmetic truthiness: `((count))` not `((count > 0))`

### Increment Safety

```bash
declare -i i=0
i+=1              # âœ“ Safe, always succeeds
((i++))           # âœ— NEVER - returns 0 when i=0, exits with set -e
```

**Why `((i++))` fails:** Returns old value (0), which is false, causing `set -e` script exit.

### Operators

| Op | Use | Op | Use |
|----|-----|----|-----|
| `+ - * / %` | Math | `** ` | Power |
| `< <= > >=` | Compare | `== !=` | Equality |
| `+= -=` | Compound | `& \| ^` | Bitwise |

### Anti-Patterns

```bash
[[ "$n" -gt 10 ]]         # â†' ((n > 10))
result=$(expr $i + $j)    # â†' result=$((i + j))
((result = $i + $j))      # â†' ((result = i + j))
result="$((i + j))"       # â†' result=$((i + j))
```

### Practical Pattern

```bash
declare -i attempts=0 max=5
while ((attempts < max)); do
  process || { attempts+=1; continue; }
  break
done
((attempts >= max)) && die 1 'Max attempts'
```

**Ref:** BCS0505
