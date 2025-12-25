### printf Patterns

**Single-quote format strings; double-quote variable arguments. Prefer printf over echo -e.**

#### Core Pattern

```bash
printf '%s: %d files\n' "$name" "$count"  # Format static, args quoted
echo 'Static message'                      # No vars: single quotes
echo "$SCRIPT_NAME $VERSION"               # With vars: double quotes
```

#### Anti-Patterns

- `echo -e "Line1\nLine2"` â†' `printf 'Line1\nLine2\n'` (echo -e varies by system)
- Unquoted variables in printf args â†' Always double-quote: `"$var"`

**Ref:** BCS0305
