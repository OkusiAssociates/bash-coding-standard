### printf Patterns

**Single-quote format strings, double-quote variable arguments. Prefer printf over echo -e for portable escape handling.**

#### Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format=single, args=double
echo 'Static text'                         # Static=single quotes
printf '%s\n' 'literal' "$var"            # Mixed: literal single, var double
```

#### Format Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

#### Anti-patterns

- `echo -e "text\n"` → behavior varies across shells; use `printf 'text\n'` or `$'text\n'`
- `printf "$var"` → format string injection; use `printf '%s' "$var"`

**Ref:** BCS0305
