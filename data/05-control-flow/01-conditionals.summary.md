## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists' ||:
[[ -f "$file" ]] || die 1 "File not found ${file@Q}"
[[ "$status" == success ]] && continue ||:

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries' ||:

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count)); then
  process_data
fi
```

**Why `[[ ]]` over `[ ]`:**
- No word splitting or glob expansion on variables
- Pattern matching with `==` and `=~` operators
- Logical operators `&&`/`||` work inside (no `-a`/`-o` needed)
- String comparison with `<`, `>` (lexicographic)

**Comparison of `[[ ]]` vs `[ ]`:**

```bash
var='two words'

# ✗ [ ] requires quotes or fails
[ $var = 'two words' ]  # ERROR: too many arguments

# ✓ [[ ]] handles unquoted variables (but quote anyway)
[[ "$var" == 'two words' ]]  # Recommended

# Pattern matching (only works in [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file" ||:
```

**Arithmetic conditionals - use `(())`:**

```bash
# ✓ Correct - natural C-style syntax
((count)) && echo "Count: $count"
((i >= MAX)) && die 1 'Limit exceeded' ||:

# ✗ Wrong - using [[ ]] for arithmetic
[[ "$count" -gt 0 ]]  # Verbose, error-prone

# Comparison operators in (())
((a > b))   ((a >= b))  ((a < b))
((a <= b))  ((a == b))  ((a != b))
```

**Pattern matching:**

```bash
# Glob pattern matching
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename" ||:

# Regular expression matching
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo 'Valid email'
fi

# Case-insensitive matching
shopt -s nocasematch
[[ "$input" == yes ]] && echo "Affirmative"  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
[[ -f "$config" ]] && source "$config" ||:  # Execute if first succeeds
[[ -d "$dir" ]] || mkdir -p "$dir"          # Execute if first fails
((count)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Using old [ ] syntax
if [ -f "$file" ]; then  # Use [[ ]] instead

# ✗ Using -a and -o in [ ]
[ -f "$file" -a -r "$file" ]  # Deprecated, fragile

# ✓ Use [[ ]] with && and ||
[[ -f "$file" && -r "$file" ]]

# ✗ Arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Use (()) for arithmetic
((count > 10))
```

**File test operators (use with `[[ ]]`):**

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
| `file1 -nt file2` | file1 newer than file2 |
| `file1 -ot file2` | file1 older than file2 |

**String test operators (use with `[[ ]]`):**

| Operator | Meaning |
|----------|---------|
| `-z "$str"` | String is empty |
| `-n "$str"` | String is not empty |
| `"$a" == "$b"` | Strings equal |
| `"$a" != "$b"` | Strings not equal |
| `"$a" < "$b"` | Lexicographic less than |
| `"$a" > "$b"` | Lexicographic greater than |
| `"$str" =~ regex` | Matches regex |
| `"$str" == pattern` | Matches glob pattern |
