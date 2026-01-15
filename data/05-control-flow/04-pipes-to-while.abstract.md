## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variable assignments are lost. Use `< <(command)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshell for while body �' variable modifications discarded on exit �' counters=0, arrays=empty, no errors shown.

### Rationale

- Variables modified in pipe subshell don't persist to parent
- Silent failure—script runs but produces wrong values
- Process substitution runs loop in current shell, preserving state

### Solutions

**Process substitution** (most common):
```bash
while IFS= read -r line; do
  count+=1
done < <(command)
```

**readarray** (collecting lines):
```bash
readarray -t lines < <(command)
```

**Here-string** (variable input):
```bash
while IFS= read -r line; do
  count+=1
done <<< "$input"
```

### Anti-Patterns

```bash
# ✗ Pipe loses state
cmd | while read -r x; do arr+=("$x"); done
echo "${#arr[@]}"  # 0!

# ✓ Process substitution preserves state
while read -r x; do arr+=("$x"); done < <(cmd)
```

### Edge Cases

- **Large files**: `readarray` loads all into RAM; while loop streams line-by-line
- **Null-delimited**: Use `read -r -d ''` and `find -print0`

**Ref:** BCS0504
