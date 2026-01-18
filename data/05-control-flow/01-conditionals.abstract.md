## Conditionals

**Use `[[ ]]` for string/file tests, `(())` for arithmetic.**

### Why `[[ ]]` over `[ ]`
- No word splitting/glob expansion on variables
- Pattern matching (`==`, `=~`), logical ops (`&&`, `||`) inside
- `<`/`>` for lexicographic comparison

### Core Pattern
```bash
[[ -f "$file" ]] && source "$file" ||:
[[ "$var" == pattern* ]] && process ||:
((count > MAX)) && die 1 'Limit exceeded' ||:
if [[ -n "$var" ]] && ((count)); then process; fi
```

### Anti-Patterns
- `[ ]` → use `[[ ]]`; `[ -a ]`/`[ -o ]` → use `[[ && ]]`/`[[ || ]]`
- `[[ "$n" -gt 5 ]]` → use `((n > 5))`

### File Tests (`[[ ]]`)
`-e` exists | `-f` file | `-d` dir | `-r` read | `-w` write | `-x` exec | `-s` non-empty | `-L` link | `-nt` newer | `-ot` older

### String Tests (`[[ ]]`)
`-z` empty | `-n` non-empty | `==` equal | `!=` not equal | `=~` regex | `<`/`>` lexicographic

**Ref:** BCS0501
