## Process Substitution

**Use `<(cmd)` for input, `>(cmd)` for output to avoid temp files and subshells.**

**Rationale:** Eliminates temp files, preserves variable scope (no subshell), enables parallelism.

**Input:** `<(cmd)` treats output as readable file:
```bash
diff <(sort file1) <(sort file2)
readarray -t users < <(getent passwd | cut -d: -f1)
while read -r line; do ((count+=1)); done < <(cat file)
```

**Output:** `>(cmd)` treats command as writable file:
```bash
cat log | tee >(grep ERROR > err.txt) >(wc -l > count.txt) > /dev/null
```

**Use cases:**
- Compare outputs: `diff <(ls dir1) <(ls dir2)`
- Avoid subshell in loops: `while read -r x; do count+=1; done < <(cmd)`
- Parallel processing: `cat log | tee >(process1) >(process2) > out`
- Multiple inputs: `paste <(cut -f1 file) <(cut -f2 file)`

**Anti-pattern:**
```bash
# ✗ Temp files
tmp=$(mktemp); sort file1 > "$tmp"; diff "$tmp" file2; rm "$tmp"
# ✓ Process substitution
diff <(sort file1) file2

# ✗ Pipe creates subshell
count=0; cat file | while read -r x; do ((count+=1)); done
echo "$count"  # Still 0!
# ✓ Preserves scope
count=0; while read -r x; do ((count+=1)); done < <(cat file)
```

**Ref:** BCS1103
