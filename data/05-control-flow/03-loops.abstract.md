## Loops

**Use `for` for arrays/globs/ranges, `while` for streaming input/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

**Rationale:** Array iteration with quotes preserves element boundaries; pipe to while loses variable changes; `while ((1))` is 15-22% faster than `while true`.

**Core patterns:**

```bash
# Array iteration
for file in "${files[@]}"; do process "$file"; done

# Read file/command output (preserves variables)
while IFS= read -r line; do
  count+=1
done < <(find . -name '*.txt')

# C-style (use +=1 not ++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Infinite loop (fastest)
while ((1)); do work; [[ -f stop ]] && break; done
```

**Anti-patterns:**

```bash
# ✗ Pipe loses variables    → ✓ Use < <(cmd)
cat f | while read x; do n+=1; done  # n unchanged!

# ✗ Parse ls output         → ✓ Use glob directly
for f in $(ls *.txt); do  # for f in *.txt; do

# ✗ Unquoted array          → ✓ Quote expansion
for x in ${arr[@]}; do    # for x in "${arr[@]}"; do

# ✗ i++ fails at 0 with -e  → ✓ Use i+=1
for ((i=0; i<10; i++))    # for ((i=0; i<10; i+=1))

# ✗ Redundant comparison    → ✓ Arithmetic is truthy
while (($# > 0)); do      # while (($#)); do
```

**Ref:** BCS0503
