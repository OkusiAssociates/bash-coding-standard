## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to eliminate temp files, avoid subshell scope issues, and enable parallel processing.**

**Why:** No temp file cleanup; preserves variable scope (unlike pipes); multiple substitutions run in parallel; efficient FIFO/fd streaming.

**Core patterns:**

```bash
# Compare command outputs
diff <(sort file1) <(sort file2)

# Array from command (avoids subshell)
readarray -t arr < <(cmd)

# While loop preserving scope
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(cat file)
echo "$count"  # Correct!

# Parallel output processing
cat log | tee >(grep ERR > e.log) >(wc -l > n.txt) >/dev/null
```

**Anti-patterns:**

```bash
# ✗ Pipe to while (subshell loses vars)
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# ✗ Temp files for diff
sort f1 > /tmp/a; sort f2 > /tmp/b; diff /tmp/a /tmp/b

# ✗ Unquoted variables inside substitution
diff <(sort $file1) <(sort $file2)

# ✗ Overcomplicated - use here-string
cmd < <(echo "$var")  # �' cmd <<< "$var"
```

**When NOT to use:** Simple `result=$(cmd)` or `grep pat file` — don't overcomplicate.

**Ref:** BCS0903
