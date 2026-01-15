### Floating-Point Operations

**Rule: BCS0706**

Performing floating-point arithmetic in Bash using external tools.

---

#### Rationale

Bash only supports integer arithmetic natively. For floating-point:
- Use `bc` for arbitrary precision calculations
- Use `awk` for inline floating-point operations
- Use `printf` for formatting floating-point output

---

#### Using bc (Basic Calculator)

```bash
# Simple calculation
result=$(echo '3.14 * 2.5' | bc -l)

# With variables
declare -- width='10.5'
declare -- height='7.25'
area=$(echo "$width * $height" | bc -l)

# Set precision (scale)
pi=$(echo 'scale=10; 4*a(1)' | bc -l)  # Pi to 10 decimal places

# Comparison (bc returns 1 for true, 0 for false)
if (($(echo "$a > $b" | bc -l))); then
  info "$a is greater than $b"
fi
```

#### Using awk

```bash
# Inline calculation
result=$(awk "BEGIN {printf \"%.2f\", 3.14 * 2.5}")

# With variables
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# Comparison
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then
  info "$a is greater than $b"
fi

# Percentage calculation
pct=$(awk -v used="$used" -v total="$total" 'BEGIN {printf "%.1f", used/total*100}')
```

#### Using printf for Formatting

```bash
printf '%.2f\n' "$value"
printf 'Area: %.2f sq units\n' "$(echo "$w * $h" | bc -l)"
```

#### Common Patterns

```bash
# Human-readable byte sizes
bytes_to_human() {
  local -i bytes=$1
  if ((bytes >= 1073741824)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fG", b/1073741824}'
  elif ((bytes >= 1048576)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fM", b/1048576}'
  elif ((bytes >= 1024)); then
    awk -v b="$bytes" 'BEGIN {printf "%.1fK", b/1024}'
  else
    echo "${bytes}B"
  fi
}

# Percentage with rounding
calc_percentage() {
  local -i part=$1 total=$2
  awk -v p="$part" -v t="$total" 'BEGIN {printf "%.0f", p/t*100}'
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - Bash integer division loses precision
result=$((10 / 3))  # Returns 3, not 3.333

# ✓ Correct - use bc for float division
result=$(echo '10 / 3' | bc -l)  # Returns 3.333...
```

```bash
# ✗ Wrong - comparing floats as strings
if [[ "$a" > "$b" ]]; then  # String comparison!

# ✓ Correct - use bc or awk for numeric comparison
if (($(echo "$a > $b" | bc -l))); then
```

---

**See Also:** BCS0705 (Integer Arithmetic)

**Full implementation:** See `examples/exemplar-code/hr2int` and `examples/exemplar-code/int2hr`
