## Process Substitution

**Use `<(cmd)` for input and `>(cmd)` for output to treat command I/O as files, eliminating temp files and avoiding subshell variable scope issues.**

### Key Benefits
- **No temp files**: Data streams via FIFOs, no disk I/O
- **Preserves scope**: Unlike pipes, variables survive while loops
- **Parallel execution**: Multiple substitutions run simultaneously

### Core Patterns

```bash
# Compare outputs (no temp files)
diff <(sort file1) <(sort file2)

# Avoid subshell in while loop
declare -i count=0
while read -r line; do ((count++)); done < <(cat file)
echo "$count"  # Correct!

# Parallel processing with tee
cat log | tee >(grep ERROR > err.txt) >(wc -l > cnt.txt) >/dev/null
```

### Anti-Patterns

```bash
# ✗ Pipe to while (subshell loses variables)
cat file | while read -r line; do count+=1; done
# ✗ Unquoted variables inside substitution
diff <(sort $file1) <(sort $file2)
```

→ Use `<<<` for simple variable input instead of `< <(echo "$var")`
→ Use direct `grep pattern file` instead of `grep pattern < <(cat file)`

**Ref:** BCS0903
