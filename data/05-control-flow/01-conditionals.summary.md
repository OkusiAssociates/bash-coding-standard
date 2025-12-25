## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic:**

```bash
# String and file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists'
[[ -f "$file" ]] || die 1 "File not found: $file"
[[ "$status" == 'success' ]] && continue

# Arithmetic tests - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((var > 5)) || return 1
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Complex conditionals - combine both
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi

# Short-circuit evaluation
[[ -f "$file" ]] && source "$file"
((VERBOSE)) || return 0
```

**Rationale for `[[ ]]` over `[ ]`:**

1. **No word splitting/glob expansion** on variables
2. **Pattern matching** with `==` and `=~` operators
3. **Logical operators** `&&` and `||` work inside (no `-a`/`-o`)
4. **More operators**: `<`, `>` for lexicographic string comparison

**Comparison:**

```bash
var="two words"

# ✗ [ ] requires quotes or fails
[ $var = "two words" ]  # ERROR: too many arguments

# ✓ [[ ]] handles safely (still quote for clarity)
[[ "$var" == "two words" ]]

# Pattern matching (only [[ ]])
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$input" =~ ^[0-9]+$ ]] && echo "Number"

# Logical operators inside [[ ]]
[[ -f "$file" && -r "$file" ]] && cat "$file"

# vs [ ] requires separate tests
[ -f "$file" ] && [ -r "$file" ] && cat "$file"
```

**Arithmetic conditionals - use `(())`:**

```bash
# ✓ Correct - natural C-style syntax
((count > 0)) && echo "Count: $count"
((i >= MAX)) && die 1 'Limit exceeded'

# ✗ Wrong - using [[ ]] for arithmetic (verbose)
[[ "$count" -gt 0 ]]  # Unnecessary

# Operators: > >= < <= == !=
((a > b))   # Greater than
((a >= b))  # Greater or equal
```

**Pattern matching:**

```bash
# Glob pattern
[[ "$filename" == *.@(jpg|png|gif) ]] && process_image "$filename"

# Regular expression
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Valid email"
else
  die 22 "Invalid email: $email"
fi

# Case-insensitive (bash 3.2+)
shopt -s nocasematch
[[ "$input" == "yes" ]]  # Matches YES, Yes, yes
shopt -u nocasematch
```

**Short-circuit evaluation:**

```bash
# Execute second only if first succeeds
[[ -f "$config" ]] && source "$config"
((DEBUG)) && set -x

# Execute second only if first fails
[[ -d "$dir" ]] || mkdir -p "$dir"
((count > 0)) || die 1 'No items to process'
```

**Anti-patterns:**

```bash
# ✗ Wrong - using old [ ] syntax
[ -f "$file" ]  # Use [[ ]] instead

# ✗ Wrong - using -a and -o in [ ]
[ -f "$file" -a -r "$file" ]  # Deprecated, fragile

# ✓ Correct - use [[ ]] with && and ||
[[ -f "$file" && -r "$file" ]]

# ✗ Wrong - arithmetic with [[ ]] using -gt/-lt
[[ "$count" -gt 10 ]]  # Verbose

# ✓ Correct - use (()) for arithmetic
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
| `-z "$str"` | String is empty (zero length) |
| `-n "$str"` | String is not empty |
| `"$a" == "$b"` | Strings are equal |
| `"$a" != "$b"` | Strings are not equal |
| `"$a" < "$b"` | Lexicographic less than |
| `"$a" > "$b"` | Lexicographic greater than |
| `"$str" =~ regex` | String matches regex |
| `"$str" == pattern` | String matches glob pattern |
