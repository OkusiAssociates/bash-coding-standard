## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

### Why `[[ ]]` over `[ ]`
- No word splitting/glob expansion on variables
- Pattern matching (`==`, `=~`) and logical ops (`&&`, `||`) inside
- `<`/`>` for lexicographic comparison

### Core Pattern
```bash
[[ -f "$file" ]] && source "$file" ||:
((count > MAX)) && die 1 'Limit exceeded' ||:
[[ -n "$var" ]] && ((count)) && process_data
[[ "$str" =~ ^[0-9]+$ ]] && echo "Number"
```

### Key Operators
**File:** `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` exec, `-s` non-empty
**String:** `-z` empty, `-n` non-empty, `==` equal, `=~` regex
**Arithmetic:** `>`, `>=`, `<`, `<=`, `==`, `!=`

### Anti-patterns
```bash
# ✗ Old [ ] syntax �' use [[ ]]
[ -f "$file" -a -r "$file" ]  # Deprecated -a/-o
# ✓ [[ -f "$file" && -r "$file" ]]

# ✗ Arithmetic with [[ ]] �' use (())
[[ "$count" -gt 10 ]]
# ✓ ((count > 10))
```

**Ref:** BCS0501
