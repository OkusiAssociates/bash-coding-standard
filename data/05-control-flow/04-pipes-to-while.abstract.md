## Pipes to While Loops

**Never pipe to while loops—pipes create subshells where variable changes are lost. Use `< <(cmd)` or `readarray` instead.**

### Why It Fails

Pipes spawn subshells; variables modified inside vanish when the pipe ends. No error—just wrong values.

### Solutions

**Process substitution** (variables persist):
```bash
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep ERROR "$log")
echo "$count"  # Correct!
```

**readarray** (collect lines):
```bash
readarray -d '' -t files < <(find /data -print0)
```

**Here-string** (input in variable):
```bash
while read -r line; do count+=1; done <<< "$input"
```

### Anti-Patterns

```bash
# ✗ Pipe loses state
cat file | while read -r l; do arr+=("$l"); done  # arr stays empty!

# ✓ Process substitution
while read -r l; do arr+=("$l"); done < <(cat file)
```

### Key Points

- `| while` = subshell = lost variables (counters=0, arrays=empty)
- `< <(cmd)` runs loop in current shell
- `readarray -d ''` for null-delimited (safe filenames)
- Silent failure—test with actual data

**Ref:** BCS0504
