## Arithmetic Operations

> **See Also:** BCS0201 for declaring integer variables with `declare -i`

**Declare integers explicitly:**

```bash
declare -i i j result count total
declare -i counter=0
declare -i max_retries=3
```

**Rationale for `declare -i`:** Automatic arithmetic context (no `$(())` needed), type safety, performance, clarity, BCS0201 compliance.

**Increment operations:**

```bash
# ✓ CORRECT - The ONLY acceptable form
declare -i i=0    # MUST declare as integer first
i+=1              # Clearest, safest, most readable

# ✗ WRONG - NEVER use these
((i++))           # Returns old value, fails with set -e when i=0
((++i))           # Unnecessary complexity
i++               # Syntax error outside arithmetic context
```

**Why `((i++))` is dangerous:**

```bash
set -e
i=0
((i++))  # Returns 0 (old value) = "false", script exits!
echo "This never executes"
```

**Arithmetic expressions:**

```bash
# In (()) - no $ needed
((result = x * y + z))
((total = sum / count))

# With $(()) for assignments/commands
result=$((x * y + z))
echo "$((i * 2 + 5))"
```

**Operators:**

| Operator | Meaning | Note |
|----------|---------|------|
| `+` `-` `*` `/` `%` `**` | Basic arithmetic | `/` is integer division |
| `++` `--` | Increment/Decrement | Use `i+=1` instead |
| `+=` `-=` | Compound assignment | `((i+=5))` |

**Arithmetic conditionals:**

```bash
if ((i < j)); then echo 'i is less than j'; fi
((count > 0)) && process_items
((attempts >= max_retries)) && die 1 'Too many attempts'
```

**Comparison operators:** `<` `<=` `>` `>=` `==` `!=`

**Arithmetic truthiness (non-zero = true):**

```bash
# ✓ CORRECT - use truthiness directly
declare -i count=5
if ((count)); then echo 'Has items'; fi
((VERBOSE)) && echo 'Verbose mode enabled'
((DRY_RUN)) || execute_command

# ✗ WRONG - redundant comparison
if ((count > 0)); then echo 'Has items'; fi
((VERBOSE == 1)) && echo 'Verbose mode'
```

**Complex expressions:**

```bash
((result = (a + b) * (c - d)))
((max = a > b ? a : b))         # Ternary (bash 5.2+)
((flags = flag1 | flag2))       # Bitwise OR
((masked = value & 0xFF))       # Bitwise AND
```

**Anti-patterns:**

```bash
# ✗ WRONG - [[ ]] for arithmetic (verbose, old-style)
if [[ "$exit_code" -eq 0 ]]; then echo 'Success'; fi
[[ "$count" -gt 10 ]] && process_items

# ✓ CORRECT - use (())
if ((exit_code == 0)); then echo 'Success'; fi
((count > 10)) && process_items

# ✗ WRONG - expr command (slow, external)
result=$(expr $i + $j)

# ✓ CORRECT
result=$((i + j))

# ✗ WRONG - $ inside (()) on left side
((result = $i + $j))

# ✓ CORRECT - no $ inside (())
((result = i + j))

# ✗ WRONG - unnecessary quotes
result="$((i + j))"

# ✓ CORRECT
result=$((i + j))
```

**Integer division truncates:**

```bash
((result = 10 / 3))   # result=3
((result = -10 / 3))  # result=-3

# For floating point, use bc or awk
result=$(bc <<< "scale=2; 10 / 3")  # 3.33
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
  ((attempts < max_attempts)) && sleep 1
done
((attempts >= max_attempts)) && die 1 'Max attempts reached'

# Percentage calculation
declare -i total=100 completed=37
declare -i percentage=$((completed * 100 / total))
echo "Progress: $percentage%"
```
