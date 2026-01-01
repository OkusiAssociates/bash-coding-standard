### printf Patterns

**Single-quote format strings; double-quote variable arguments. Prefer printf over echo -e.**

#### Pattern

```bash
printf '%s: %d found\n' "$name" "$count"  # Format static, args quoted
echo 'Done'                                # Static: single quotes
echo "$SCRIPT_NAME $VERSION"               # Variables: double quotes
```

#### Key Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

#### Anti-Patterns

`echo -e "a\nb"` â†' `printf 'a\nb\n'` or `echo $'a\nb'`

**Ref:** BCS0305
