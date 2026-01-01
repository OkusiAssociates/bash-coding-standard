## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic:**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists' ||:
[[ -f "$file" ]] || die 1 "File not found ${file@Q}"
[[ "$status" == success ]] && continue

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count)); then
  process_data
fi
```

**Rationale for `[[ ]]` over `[ ]`:**
1. No word splitting or glob expansion on variables
2. Pattern matching with `==` and `=~` operators
3. Logical operators `&&` and `||` work inside (no `-a`/`-o` needed)
4. `<`, `>` for lexicographic string comparison

**Comparison `[[ ]]` vs `[ ]`:**

```bash
var='two words'

# ✗ [ ] requires quotes or fails
[ $var = 'two words' ]  # ERROR: too many arguments

# ✓ [[ ]] handles unquoted variables (but quote anyway)
[[ "$var" == 'two words' ]]  # Recommended

# Pattern matching (only in [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file" ||:
```

**Arithmetic conditionals - use `(())`:**

```bash
declare -i count=0

# ✓ Correct - natural C-style syntax
if ((count)); then
  echo "Count: $count"
fi

((i >= MAX)) && die 1 'Limit exceeded'

# ✗ Wrong - using [[ ]] for arithmetic
if [[ "$count" -gt 0 ]]; then  # Unnecessary, verbose
  echo "Count: $count"
fi

# Comparison operators in (())
((a > b))   ((a >= b))  ((a < b))
((a <= b))  ((a == b))  ((a != b))
```

**Pattern matching:**

```bash
# Glob pattern matching
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename"

# Regular expression matching
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo 'Valid email'
else
  die 22 "Invalid email ${email@Q}"
fi

# Case-insensitive matching
shopt -s nocasematch
[[ "$input" == yes ]] && echo "Affirmative"  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
# Execute if first succeeds
[[ -f "$config" ]] && source "$config" ||:

# Execute if first fails
[[ -d "$dir" ]] || mkdir -p "$dir"
((count)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Wrong - old [ ] syntax
if [ -f "$file" ]; then echo 'Found'; fi

# ✗ Wrong - deprecated -a/-o in [ ]
[ -f "$file" -a -r "$file" ]  # Fragile

# ✓ Correct - use [[ ]] with &&/||
[[ -f "$file" && -r "$file" ]]

# ✗ Wrong - arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Correct - use (())
((count > 10))
```

**File test operators (`[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-e file` | File exists |
| `-f file` | Regular file |
| `-d dir` | Directory |
| `-r file` | Readable |
| `-w file` | Writable |
| `-x file` | Executable |
| `-s file` | Not empty (size > 0) |
| `-L link` | Symbolic link |
| `f1 -nt f2` | f1 newer than f2 |
| `f1 -ot f2` | f1 older than f2 |

**String test operators (`[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-z "$str"` | Empty string |
| `-n "$str"` | Non-empty string |
| `"$a" == "$b"` | Equal |
| `"$a" != "$b"` | Not equal |
| `"$a" < "$b"` | Lexicographic less |
| `"$a" > "$b"` | Lexicographic greater |
| `"$str" =~ regex` | Regex match |
| `"$str" == pattern` | Glob match |
