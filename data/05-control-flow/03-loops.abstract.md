## Loops

**Use `for` for arrays/globs/ranges, `while` for input/conditions; always quote arrays as `"${array[@]}"`, use `< <(cmd)` not pipes to avoid subshell issues.**

### Key Rationale
- Process substitution preserves variable scope (pipes create subshells)
- `while ((1))` is 15-22% faster than `while true`
- `nullglob` prevents literal pattern iteration on no-match

### Core Patterns

```bash
# Array iteration (safe with spaces)
for file in "${files[@]}"; do process "$file"; done

# Command output (preserves variables)
while IFS= read -r line; do count+=1; done < <(find . -name '*.txt')

# C-style (use i+=1, NEVER i++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Argument parsing
while (($#)); do case $1 in -v) VERBOSE=1 ;; esac; shift; done

# Infinite (fastest)
while ((1)); do work; ((done)) && break; done
```

### Anti-Patterns

```bash
# ✗ Pipe loses variables     �' ✓ Use < <(cmd)
cmd | while read -r x; do n+=1; done  # n stays 0!

# ✗ Parse ls output          �' ✓ Use glob directly
for f in $(ls *.txt); do ...          # for f in *.txt

# ✗ Unquoted array           �' ✓ Quote expansion
for x in ${arr[@]}; do ...            # "${arr[@]}"

# ✗ i++ fails at 0 with -e   �' ✓ Use i+=1
for ((i=0; i<n; i++)); do ...         # i+=1

# ✗ local inside loop        �' ✓ Declare before loop
for f in *; do local x; ...           # local x; for f in *
```

**Ref:** BCS0503
