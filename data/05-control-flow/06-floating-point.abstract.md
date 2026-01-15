### Floating-Point Operations

**Use `bc` or `awk` for float math; Bash only supports integers natively.**

#### Rationale
- Bash `$(())` truncates decimals â†' data loss
- `bc -l` provides arbitrary precision; `awk` handles inline ops
- Float string comparison (`[[ "$a" > "$b" ]]`) gives wrong results

#### Core Patterns

```bash
# bc: precision calculation
result=$(echo "$width * $height" | bc -l)

# awk: formatted output with variables
area=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')

# Float comparison (bc returns 1=true, 0=false)
if (($(echo "$a > $b" | bc -l))); then
  echo "$a is greater"
fi
```

#### Anti-Patterns

`result=$((10/3))` â†' returns 3, not 3.333 â†' use `echo '10/3' | bc -l`

`[[ "$a" > "$b" ]]` â†' string comparison â†' use `(($(echo "$a > $b" | bc -l)))`

**See Also:** BCS0705 (Integer Arithmetic)

**Ref:** BCS0506
