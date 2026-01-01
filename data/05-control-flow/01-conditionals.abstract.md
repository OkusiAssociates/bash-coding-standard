## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

**Why `[[ ]]` over `[ ]`:** No word splitting/glob expansion, pattern matching (`==`, `=~`), logical operators inside (`&&`, `||`), no `-a`/`-o` needed.

```bash
# String/file tests
[[ -f "$file" && -r "$file" ]] && source "$file" ||:
[[ "$name" == *.txt ]] && process "$name"

# Arithmetic tests
((count)) && echo "Items: $count"
((i >= MAX)) && die 1 'Limit exceeded'

# Combined
if [[ -n "$var" ]] && ((count)); then process; fi
```

**Key operators:** `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` executable, `-z` empty, `-n` not-empty, `=~` regex.

**Anti-patterns:**
- `[ ]` syntax â†' use `[[ ]]`
- `[ -f "$f" -a -r "$f" ]` â†' `[[ -f "$f" && -r "$f" ]]`
- `[[ "$count" -gt 10 ]]` â†' `((count > 10))`

**Ref:** BCS0501
