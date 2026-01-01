## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variables don't persist. Use `< <(cmd)` or `readarray`.**

### Why It Fails

```bash
# ✗ Variables lost in subshell
count=0
cmd | while read -r x; do count+=1; done
echo "$count"  # Always 0!
```

### Solutions

**Process substitution** (most common):
```bash
# ✓ Loop runs in current shell
while IFS= read -r line; do
  count+=1
done < <(command)
```

**readarray** (collecting lines):
```bash
# ✓ Direct to array
readarray -t lines < <(command)
readarray -d '' -t files < <(find . -print0)  # null-delimited
```

**Here-string** (variable input):
```bash
while read -r x; do ...; done <<< "$var"
```

### Anti-Patterns

```bash
# ✗ Counter stays 0
grep PAT file | while read -r l; do n+=1; done

# ✗ Array stays empty
find . | while read -r f; do arr+=("$f"); done

# ✗ Assoc array empty
cat cfg | while IFS='=' read -r k v; do m[$k]=$v; done

# ✓ All fixed with: done < <(command)
```

### Key Points

- Subshell vars discarded when pipe ends �' silent bugs
- No error messages—script runs with wrong values
- `< <(cmd)` keeps loop in current shell
- `readarray -d ''` for null-delimited (filenames with spaces)
- For counts only: `grep -c` avoids the issue

**Ref:** BCS0504
