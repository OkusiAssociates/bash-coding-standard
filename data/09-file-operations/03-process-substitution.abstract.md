## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to eliminate temp files and avoid subshell variable scope issues.**

**Rationale:** No temp file cleanup; preserves variables unlike pipes; enables parallel processing.

**Core patterns:**

```bash
# Compare outputs (no temp files)
diff <(sort file1) <(sort file2)

# Avoid subshell - variables preserved
declare -i count=0
while read -r line; do ((count+=1)); done < <(cat file)
echo "$count"  # Correct!

# Populate array safely
readarray -t files < <(find /data -type f -print0)
```

**Anti-patterns:**

```bash
# âœ— Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# âœ— Temp files when process sub works
temp=$(mktemp); sort file > "$temp"; diff "$temp" other; rm "$temp"
# â†' Use: diff <(sort file) other
```

**When NOT to use:** Simple cases where direct methods work:
- `result=$(command)` â†' not `result=$(cat <(command))`
- `grep pat file` â†' not `grep pat < <(cat file)`
- `cmd <<< "$var"` â†' not `cmd < <(echo "$var")`

**Ref:** BCS0903
