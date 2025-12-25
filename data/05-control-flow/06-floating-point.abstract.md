### Floating-Point Operations

**Use `bc -l` or `awk` for floating-point arithmetic; Bash only supports integers natively.**

---

#### Tools

| Tool | Use Case |
|------|----------|
| `bc -l` | Arbitrary precision, math functions |
| `awk` | Inline calculations, formatting |
| `printf` | Output formatting only |

---

#### Core Patterns

```bash
# bc: calculation with precision
result=$(echo 'scale=4; 10 / 3' | bc -l)

# bc: comparison (returns 1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then

# awk: formatted calculation
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# awk: comparison
if awk -v a="$a" -v b="$b" 'BEGIN {exit !(a > b)}'; then
```

---

#### Anti-Patterns

```bash
# ✗ Integer division loses precision
result=$((10 / 3))  # �' 3, not 3.333

# ✗ String comparison on floats
[[ "$a" > "$b" ]]  # Lexicographic!

# ✓ Use bc/awk for numeric comparison
(($(echo "$a > $b" | bc -l)))
```

**Ref:** BCS0706
