## Arithmetic Operations

> **See Also:** BCS0201 for complete guidance on declaring integer variables with `declare -i`

**Declare integer variables explicitly:**

```bash
# Always declare integer variables with -i flag
declare -i i j result count total

# Or declare with initial value
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:**
- Automatic arithmetic context (no need for `$(())`)
- Type safety catches non-numeric value errors
- Performance: faster for repeated operations
- Clarity: signals numeric values
- Required for BCS compliance (BCS0201)

**Increment operations:**

```bash
# ✓ PREFERRED: Simple increment
i+=1              # Clearest, most readable
((i+=1))          # Also safe, always returns 0 (success)

# ✓ SAFE: Pre-increment (returns value AFTER increment)
((++i))           # Returns new value, safe with set -e

# ✗ DANGEROUS: Post-increment (returns value BEFORE increment)
((i++))           # AVOID! Returns old value
                  # If i=0, returns 0 (false), triggers set -e exit!
```

**Why `((i++))` is dangerous:**

```bash
#!/usr/bin/env bash
set -e  # Exit on error

i=0
((i++))  # Returns 0 (the old value), which is "false"
         # Script exits here with set -e!
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed for variables
((result = x * y + z))
((total = sum / count))

# With $(()), for use in assignments or commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Arithmetic operators:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `+` `-` | Addition, Subtraction | `((i = a + b))` |
| `*` `/` `%` | Multiply, Divide, Modulo | `((i = a * b))` |
| `**` | Exponentiation | `((i = a ** b))` |
| `++` / `--` | Increment/Decrement | Use `i+=1` instead |
| `+=` / `-=` | Compound assignment | `((i+=5))` |

**Arithmetic conditionals:**

```bash
# Use (()) for arithmetic comparisons
if ((i < j)); then
  echo 'i is less than j'
fi

((count > 0)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators in (()):**

| Operator | Meaning |
|----------|---------|
| `<` `<=` `>` `>=` | Less/greater than (or equal) |
| `==` `!=` | Equal, Not equal |

**Complex expressions:**

```bash
# Parentheses for grouping
((result = (a + b) * (c - d)))

# Ternary operator (bash 5.2+)
((max = a > b ? a : b))

# Bitwise operations
((flags = flag1 | flag2))  # Bitwise OR
((masked = value & 0xFF))  # Bitwise AND
```

**Anti-patterns to avoid:**

### Using Test Command for Arithmetic Comparisons

```bash
# ✗ WRONG - Using [[ ]] for integer comparison
if [[ "$exit_code" -eq 0 ]]; then
  echo 'Success'
fi

# ✗ WRONG - Requires quotes and verbose syntax
[[ "$count" -gt 10 ]] && process_items

# ✓ CORRECT - Use (()) for integer comparison
if ((exit_code == 0)); then
  echo 'Success'
fi

# ✓ CORRECT - Clean arithmetic syntax, no quotes needed
((count > 10)) && process_items
```

**Why `(())` is better:**
- No quoting required
- Native operators: `>`, `<`, `==`, `!=` instead of `-gt`, `-lt`, `-eq`, `-ne`
- More readable: looks like arithmetic, not string comparison
- Faster: no external test command
- Type-safe: works with `declare -i` variables

### Other Common Anti-Patterns

```bash
# ✗ Wrong - using [[ ]] for arithmetic
[[ "$count" -gt 10 ]]  # Verbose, old-style

# ✓ Correct - use (())
((count > 10))

# ✗ Wrong - post-increment
((i++))  # Dangerous with set -e when i=0

# ✓ Correct - use +=1
i+=1

# ✗ Wrong - expr command (slow, external)
result=$(expr $i + $j)

# ✓ Correct - use $(()) or (())
result=$((i + j))

# ✗ Wrong - $ inside (()) on left side
((result = $i + $j))  # Unnecessary $

# ✓ Correct - no $ inside (())
((result = i + j))
```

**Integer division gotcha:**

```bash
# Integer division truncates (rounds toward zero)
((result = 10 / 3))  # result=3, not 3.333...

# For floating point, use bc or awk
result=$(bc <<< "scale=2; 10 / 3")  # result=3.33
```

**Practical examples:**

```bash
# Loop counter
declare -i i
for ((i=0; i<10; i+=1)); do
  echo "Iteration $i"
done

# Retry logic
declare -i attempts=0
declare -i max_attempts=5
while ((attempts < max_attempts)); do
  if process_item; then
    break
  fi
  attempts+=1
  ((attempts < max_attempts)) && sleep 1
done
((attempts >= max_attempts)) && die 1 'Max attempts reached'

# Percentage calculation
declare -i total=100
declare -i completed=37
declare -i percentage=$((completed * 100 / total))
echo "Progress: $percentage%"
```
