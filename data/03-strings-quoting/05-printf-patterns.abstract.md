### printf Patterns

**Single-quote format strings; double-quote variable arguments. Prefer `printf` over `echo -e`.**

#### Core Pattern

```bash
printf '%s: %d files\n' "$name" "$count"
echo 'Static message'  # No variables â†' single quotes
```

#### Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

#### Anti-Patterns

- `echo -e "...\n..."` â†' `printf '...\n...\n'` (portable)
- Double-quoted format: `printf "%s"` â†' `printf '%s'`

**Ref:** BCS0305
