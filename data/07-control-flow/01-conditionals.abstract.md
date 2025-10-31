## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

```bash
# String/file tests - use [[ ]]
[[ -d "$path" ]] && echo 'Directory exists'
[[ "$status" == 'success' ]] && continue

# Arithmetic - use (())
((VERBOSE==0)) || echo 'Verbose mode'
((count >= MAX_RETRIES)) && die 1 'Too many retries'

# Combined
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi
```

**Why `[[ ]]` over `[ ]`:** No word splitting/glob expansion, pattern matching (`==`, `=~`), logical operators (`&&`, `||`) work inside, more operators (`<`, `>` for strings).

**Pattern matching:**
```bash
[[ "$file" == *.txt ]] && echo "Text file"
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || die 22 'Invalid'
```

**Anti-patterns:** `[ ]` syntax ’ use `[[ ]]`; `-a`/`-o` operators ’ use `&&`/`||`; arithmetic with `-gt`/`-lt` ’ use `(())`

**Common operators:**
- File: `-e` (exists), `-f` (file), `-d` (dir), `-r` (readable), `-w` (writable), `-x` (executable), `-s` (not empty)
- String: `-z` (empty), `-n` (not empty), `==`/`!=` (equal/not), `<`/`>` (lexicographic), `=~` (regex)
- Arithmetic: `>`, `>=`, `<`, `<=`, `==`, `!=` (use in `(())`)

**Ref:** BCS0701
