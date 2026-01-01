## Arithmetic Operations

> **See Also:** BCS0201 for integer variable declaration with `declare -i`

**Declare integer variables explicitly:**

```bash
declare -i i j result count total
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:**
- Automatic arithmetic context (no `$(())` needed for assignments)
- Type safety catches non-numeric assignment errors
- Slightly faster for repeated operations
- Required for BCS compliance (BCS0201)

**Increment operations:**

```bash
# ✓ CORRECT - The ONLY acceptable increment form
declare -i i=0    # MUST declare as integer first
i+=1              # Clearest, safest, most readable

# ✗ WRONG - NEVER use these increment forms
((i+=1))          # NEVER - (()) is unnecessary
((i++))           # NEVER - fails with set -e when i=0
((++i))           # NEVER - unnecessary complexity
i++               # NEVER - syntax error outside arithmetic context
```

**Critical rule:** Use `i+=1` for ALL increments. Requires `declare -i` or `local -i` first.

**Why `((i++))` is dangerous:**

```bash
#!/usr/bin/env bash
set -e  # Exit on error

i=0
((i++))  # Returns 0 (the old value), which is "false"
         # Script exits here with set -e!

echo "This never executes"
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed for variables
((result = x * y + z))
((total = sum / count))

# With $(()), for assignments or commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Arithmetic operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` `-` `*` `/` `%` | Basic math | `((i = a + b))` |
| `**` | Exponentiation | `((i = a ** b))` |
| `+=` `-=` | Compound assignment | `i+=5` |
| `++` `--` | Increment/Decrement | Use `i+=1` instead |

**Arithmetic conditionals:**

```bash
if ((i < j)); then
  echo 'i is less than j'
fi

((count)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators:** `<` `<=` `>` `>=` `==` `!=`

**Arithmetic truthiness:** Non-zero is truthy. Use directly instead of explicit comparisons:

```bash
# ✓ CORRECT - use truthiness directly
declare -i count=5
if ((count)); then echo 'Has items'; fi
((VERBOSE)) && echo 'Verbose mode enabled'

# ✗ WRONG - redundant comparison
if ((count > 0)); then echo 'Has items'; fi
if ((VERBOSE == 1)); then echo 'Verbose mode'; fi
```

**Complex expressions:**

```bash
((result = (a + b) * (c - d)))
((max = a > b ? a : b))           # Ternary (bash 5.2+)
((flags = flag1 | flag2))         # Bitwise OR
((masked = value & 0xFF))         # Bitwise AND
```

**Anti-pattern: Using [[ ]] for arithmetic:**

```bash
# ✗ WRONG - verbose, old-style
if [[ "$exit_code" -eq 0 ]]; then echo 'Success'; fi
[[ "$count" -gt 10 ]] && process_items

# ✓ CORRECT - clean arithmetic syntax
if ((exit_code == 0)); then echo 'Success'; fi
((count > 10)) && process_items ||:
```

**Why `(())` is better:** No quoting required, native operators (`>` vs `-gt`), more readable, faster (pure bash), type-safe.

**Other anti-patterns:**

```bash
# ✗ Wrong - expr command (slow, external)
result=$(expr $i + $j)
# ✓ Correct
result=$((i + j))

# ✗ Wrong - $ inside (())
((result = $i + $j))
# ✓ Correct
((result = i + j))

# ✗ Wrong - quotes around arithmetic
result="$((i + j))"
# ✓ Correct
result=$((i + j))
```

**Integer division:** Truncates toward zero. Use `bc` or `awk` for floating point:

```bash
((result = 10 / 3))                    # result=3
result=$(bc <<< "scale=2; 10 / 3")     # result=3.33
```

**Practical examples:**

```bash
# Loop counter
declare -i i
for ((i=0; i<10; i+=1)); do
  echo "Iteration $i"
done

# Retry logic
declare -i attempts=0 max_attempts=5
while ((attempts < max_attempts)); do
  process_item && break
  attempts+=1
  ((attempts > max_attempts)) || sleep 1
done
((attempts < max_attempts)) || die 1 'Max attempts reached'
```
