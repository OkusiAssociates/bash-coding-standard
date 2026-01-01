### Floating-Point Operations

**Bash only supports integer arithmetic; use `bc` (precision) or `awk` (inline) for floats.**

#### Tools

**bc** — arbitrary precision:
```bash
result=$(echo "$width * $height" | bc -l)
```

**awk** — inline with formatting:
```bash
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')
```

#### Comparisons

```bash
# bc returns 1=true, 0=false
if (($(echo "$a > $b" | bc -l))); then

# awk comparison
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then
```

#### Anti-Patterns

```bash
# ✗ Integer division loses precision
result=$((10 / 3))  # Returns 3, not 3.333
# ✓ Use bc
result=$(echo '10 / 3' | bc -l)

# ✗ String comparison of floats
[[ "$a" > "$b" ]]  # Wrong!
# ✓ Use bc/awk numeric comparison
```

**Ref:** BCS0506
