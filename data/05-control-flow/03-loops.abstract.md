## Loops

**Use `for` for arrays/globs/ranges, `while` for input streams/conditions. Always quote arrays `"${array[@]}"`, use process substitution `< <(cmd)` to avoid subshell scope loss.**

### Key Patterns

**For loops:** `for item in "${array[@]}"` | `for file in *.txt` | `for ((i=0; i<n; i+=1))`

**While input:** `while IFS= read -r line; do ... done < file` or `< <(command)`

**Infinite:** `while ((1))` (fastest) â†' `while :` (POSIX) â†' avoid `while true` (15-22% slower)

**Arg parsing:** `while (($#)); do case $1 in ... esac; shift; done`

### Core Example

```bash
local -- file
local -i count=0

# Process command output (preserves variable scope)
while IFS= read -r -d '' file; do
  [[ -f "$file" ]] || continue
  count+=1
done < <(find . -name '*.sh' -print0)

echo "Processed $count files"
```

### Critical Anti-Patterns

| Wrong | Correct |
|-------|---------|
| `for f in $(ls *.txt)` | `for f in *.txt` |
| `cat file \| while read` | `while read < file` or `< <(cat)` |
| `for x in ${array[@]}` | `for x in "${array[@]}"` |
| `for ((i=0;i<n;i++))` | `for ((i=0;i<n;i+=1))` |
| `while (($# > 0))` | `while (($#))` |
| `local x` inside loop | declare locals before loop |

### Essential Rules

- Enable `nullglob` for glob loops (empty match = zero iterations)
- Use `break 2` for nested loop exit (explicit level)
- Use `IFS= read -r` always (preserves whitespace/backslashes)
- Declare loop variables before loop, not inside

**Ref:** BCS0503
