## Loops

**Use `for` for arrays/globs/ranges, `while` for input/conditions; always quote array expansion, use process substitution `< <(cmd)` to avoid subshell scope loss.**

**Rationale:**
- `"${array[@]}"` preserves element boundaries with spaces
- Pipes to while lose variable changes; process substitution preserves scope
- `i+=1` not `i++` (fails with `set -e` when i=0)

**Core patterns:**

```bash
# Array iteration (safest pattern)
local -- item
for item in "${files[@]}"; do process "$item"; done

# Read command output (preserves variable scope)
while IFS= read -r line; do
  ((count+=1))
done < <(find . -name '*.txt')

# C-style numeric (use i+=1 not i++)
for ((i=0; i<10; i+=1)); do echo "$i"; done

# Argument parsing
while (($#)); do
  case $1 in -v) VERBOSE=1 ;; esac
  shift
done
```

**Critical anti-patterns:**
- `for f in $(ls)` â†' parse ls output (NEVER)
- `cmd | while read` â†' subshell loses variables
- `for f in ${arr[@]}` â†' unquoted splits on spaces
- `((i++))` â†' fails with `set -e` when i=0
- `while (($# > 0))` â†' redundant; use `while (($#))`
- `local` inside loop â†' wasteful, declare before loop

**Performance:** `while ((1))` fastest; `while true` 15-22% slower.

**Ref:** BCS0503
