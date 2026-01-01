### Quoting in Conditionals

**Always quote variables in conditionals** — prevents word splitting, glob expansion, empty-value errors, and injection.

```bash
[[ -f "$file" ]]                    # ✓ Variable quoted
[[ "$action" == 'start' ]]          # ✓ Literal single-quoted
[[ "$filename" == *.txt ]]          # ✓ Glob unquoted (pattern match)
[[ "$input" =~ $pattern ]]          # ✓ Regex pattern unquoted
```

**Why:** `$file` with spaces/globs breaks; empty vars cause syntax errors.

**Anti-patterns:** `[[ -f $file ]]` �' breaks with spaces | `[[ "$x" == "literal" ]]` �' use single quotes for static strings

**Exception:** Regex `=~` right-hand side must be unquoted for pattern matching.

**Ref:** BCS0303
