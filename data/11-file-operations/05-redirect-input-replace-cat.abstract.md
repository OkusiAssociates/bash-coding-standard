## Input Redirection vs Cat: Performance Optimization

**Replace `cat filename` with `< filename` in performance-critical contexts for 3-100x speedup.**

**Rationale:** Eliminates process fork/exec overhead. Critical in loops and command substitution.

**Use `< filename` for:**

- **Command substitution** (107x faster): `content=$(< file.txt)` not `$(cat file.txt)`
- **Single input**: `grep "pattern" < file.txt` not `cat file.txt | grep "pattern"`
- **Loops**: `data=$(< "$file")` not `data=$(cat "$file")`

**Example:**
```bash
# Recommended - 100x faster
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

# Avoid - forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
    process "$data"
done
```

**Use `cat` when:**

- Multiple files: `cat file1 file2`
- Need options: `cat -n file`
- Concatenation required

**Anti-pattern:**
```bash
# ✗ Wrong - 100x slower
content=$(cat file.txt)

# ✓ Correct
content=$(< file.txt)
```

**Ref:** BCS1105
