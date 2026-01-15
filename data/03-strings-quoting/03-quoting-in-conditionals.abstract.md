### Quoting in Conditionals

**Always quote variables in conditionals.** Unquoted â†' word splitting, glob expansion, empty-value errors, injection risk.

```bash
# Variables always quoted
[[ -f "$file" ]]
[[ "$name" == 'value' ]]

# Pattern/regex: pattern UNQUOTED
[[ "$file" == *.txt ]]           # Glob match
[[ "$input" =~ $pattern ]]       # Regex (quoting makes literal)
```

**Anti-patterns:** `[[ -f $file ]]` â†' breaks on spaces/globs; `[[ "$x" =~ "$pattern" ]]` â†' pattern treated as literal.

**Ref:** BCS0303
