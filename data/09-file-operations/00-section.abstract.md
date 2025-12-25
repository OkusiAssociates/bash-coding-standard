# File Operations

**Safe file handling to prevent data loss and handle edge cases reliably.**

**Core Requirements:**
- Always quote variables in file tests: `[[ -f "$file" ]]` never `[[ -f $file ]]`
- Use explicit paths for wildcards: `rm ./*` never `rm *` (prevents accidental root deletion)
- Use `< <(command)` process substitution instead of pipes to `while` loops (avoids subshell variable loss)
- File test operators: `-e` (exists), `-f` (regular file), `-d` (directory), `-r` (readable), `-w` (writable), `-x` (executable)

**Anti-Patterns:**
- `rm *` ’ Expands to `rm /` if run in empty directory with `nullglob`
- `cat file | while read line` ’ Variables modified in loop are lost (subshell)
- `[[ -f $file ]]` ’ Breaks with filenames containing spaces or special chars

**Minimal Example:**
```bash
shopt -s nullglob
declare -- file='/path/to/file'

[[ -f "$file" ]] || die "File not found: $file"
[[ -r "$file" ]] || die "File not readable: $file"

# Safe wildcard (explicit path)
for f in ./*.txt; do
  process "$f"
done

# Process substitution (preserves variables)
while IFS= read -r line; do
  count+=1
done < <(command)
```

**Ref:** BCS1100
