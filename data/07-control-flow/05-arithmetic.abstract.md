## Arithmetic Operations

**Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity.**

```bash
declare -i counter=0 max_retries=3
```

**Increment operations:**

```bash
# ✓ Use these safe patterns
i+=1              # Clearest
((i+=1))          # Always returns 0 (success)
((++i))           # Pre-increment, safe

# ✗ NEVER use post-increment
((i++))           # Returns old value - exits if i=0 with set -e!
```

**Rationale:** With `set -e`, `((i++))` when `i=0` returns 0 (false), triggering script exit. Pre-increment `((++i))` returns new value (1), always safe.

**Arithmetic expressions:**

```bash
# In (()) - no $ needed for variables
((result = x * y + z))
((total = sum / count))

# With $(()), for assignments/commands
result=$((x * y + z))
echo "$((i * 2))"
```

**Arithmetic conditionals - use `(())` not `[[ ]]`:**

```bash
((count > 0)) && process_items
((i >= max_retries)) && die 'Too many attempts'

if ((i < j)); then
  echo 'Less than'
fi
```

**Operators:** `+` `-` `*` `/` (integer division), `%` (modulo), `**` (exponent), `+=` `-=`, comparisons: `<` `<=` `>` `>=` `==` `!=`

**Anti-patterns:**

```bash
# ✗ Old-style test
[[ "$count" -gt 10 ]]  → ((count > 10))

# ✗ External expr
result=$(expr $i + $j)  → result=$((i + j))

# ✗ Unnecessary $ inside (())
((result = $i + $j))  → ((result = i + j))

# ✗ Post-increment
((i++))  → i+=1
```

**Ref:** BCS0705
