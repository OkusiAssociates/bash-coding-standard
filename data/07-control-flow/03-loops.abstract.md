## Loops

**Use `for` for collections/ranges, `while` for streams/conditions. Quote arrays `"${array[@]}"`, use `< <(cmd)` to avoid subshell, use `break`/`continue` for control.**

**Rationale:** For loops iterate arrays/globs safely. While with process substitution avoids subshell scope issues.

**For loops:**
```bash
for file in "${files[@]}"; do process "$file"; done  # Array
for file in *.txt; do process "$file"; done  # Glob
for ((i=0; i<10; i+=1)); do echo "$i"; done  # C-style (i+=1 not i++)
for i in {1..10}; do echo "$i"; done  # Brace
```

**While loops:**
```bash
while IFS= read -r line; do process "$line"; done < file.txt  # File
while IFS= read -r line; do ((count+=1)); done < <(cmd)  # Cmd
while (($#)); do case $1 in -v) V=1 ;; esac; shift; done  # Args
```

**Infinite:**
```bash
while ((1)); do process; done  # Fastest
while :; do process; done  # POSIX (+9-14%)
# Avoid: while true (+15-22%)
```

**Control:**
```bash
[[ "$f" =~ $pat ]] && break  # Early exit
[[ ! -r "$f" ]] && continue  # Skip
((i*j>50)) && break 2  # Nested break
```

**Anti-patterns:**
```bash
# ✗ cat file | while read line; do ((c+=1)); done  # Subshell
# ✓ while read -r line; do ((c+=1)); done < <(cat file)

# ✗ for item in ${array[@]}; do  # Unquoted
# ✓ for item in "${array[@]}"; do

# ✗ for f in $(ls *.txt); do  # Parse ls
# ✓ for f in *.txt; do
```

**Ref:** BCS0703
