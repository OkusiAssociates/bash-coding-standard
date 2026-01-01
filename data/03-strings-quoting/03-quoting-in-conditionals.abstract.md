### Quoting in Conditionals

**Always quote variables in conditionals.** Static values use single quotes.

```bash
[[ -f "$file" ]]              # Variable quoted
[[ "$name" == 'value' ]]      # Literal single-quoted
[[ "$input" =~ $pattern ]]    # Regex pattern unquoted
```

**Why:** Unquoted variables break on spaces/globs, empty values cause syntax errors, injection risk.

**Anti-patterns:** `[[ -f $file ]]` â†' breaks with spaces; `[[ "$x" == "literal" ]]` â†' use single quotes for static strings.

**Ref:** BCS0303
