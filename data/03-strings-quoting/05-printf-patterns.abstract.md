### printf Patterns

**Single-quote format strings, double-quote variable arguments; prefer printf over echo -e.**

#### Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format: single, vars: double
echo 'Static text'                         # No vars: single quotes
printf '%s\n' "$var"                       # %s=string %d=int %f=float %%=literal
```

#### Anti-patterns

- `echo -e "...\n..."` â†' Use `printf '...\n...\n'` or `$'...\n...'` (echo -e behavior varies)
- `printf "$fmt"` â†' Format strings must be single-quoted (security, escapes)

**Ref:** BCS0305
