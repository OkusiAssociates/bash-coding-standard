## Arithmetic Operations

**Always declare integers with `declare -i` (BCS0201).** Use `i+=1` or `((i+=1))` for increments. Never `((i++))` - returns old value, fails with `set -e` when i=0.

**Rationale:**
- **Type safety**: `declare -i` enables automatic arithmetic, catches non-numeric errors
- **set -e safety**: `((i++))` returns 0 when i=0, causing exit
- **Performance**: Eliminates repeated `$(())` overhead

**Core patterns:**

```bash
declare -i count=0 max=10

# Safe increments
i+=1              # Preferred
((i+=1))          # Always returns 0 (success)

# Expressions
((result = x * y + z))
result=$((a + b))

# Conditionals - use (()) not [[ ]]
((count > 10)) && process
if ((i < max)); then echo 'Continue'; fi
```

**Operators:** `+ - * / % **` | **Comparisons:** `< <= > >= == !=` (native C-style in `(())`)

**Anti-patterns:**

```bash
# âœ— Post-increment â†' âœ“ Use +=1
((i++))              # Fails when i=0 with set -e
i+=1

# âœ— [[ ]] for integers â†' âœ“ Use (())
[[ "$count" -gt 10 ]]
((count > 10))       # No quotes needed

# âœ— External expr â†' âœ“ Native arithmetic
result=$(expr $i + $j)
result=$((i + j))

# âœ— $ inside (()) â†' âœ“ No $ needed
((result = $i + $j))
((result = i + j))
```

**Gotcha:** Integer division truncates: `((result = 10 / 3))` â†' 3. Use `bc`/`awk` for floating point.

**Ref:** BCS0705
