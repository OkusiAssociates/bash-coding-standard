### Floating-Point Operations

**Use `bc -l` or `awk` for float math; Bash only supports integers.**

#### Rationale
- Bash `$((...))` truncates: `$((10/3))` → 3, not 3.333
- `bc` returns 1/0 for comparisons; `awk` uses exit codes

#### bc Usage
```bash
result=$(echo '3.14 * 2.5' | bc -l)
# Comparison (1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then ...
```

#### awk Usage
```bash
result=$(awk -v w="$w" -v h="$h" 'BEGIN {printf "%.2f", w * h}')
# Comparison via exit code
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then ...
```

#### Anti-Patterns
```bash
# ✗ Integer division loses precision
result=$((10 / 3))  # → 3
# ✗ String comparison on floats
[[ "$a" > "$b" ]]   # lexicographic!
# ✓ Use bc/awk for numeric comparison
```

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506
