### Quoting in Conditionals

**Always quote variables in `[[ ]]` conditionals.** Static literals use single quotes.

**Why:** Unquoted variables break with spaces/globs, empty values cause syntax errors, security risk.

```bash
# âœ“ Correct
[[ -f "$file" ]]
[[ "$action" == 'start' ]]
[[ "$input" =~ $pattern ]]    # Regex pattern unquoted

# âœ— Wrong
[[ -f $file ]]                # â†' breaks with spaces
[[ "$mode" == "production" ]] # â†' double quotes for literal
```

**Exception:** Regex patterns (`=~`) and glob patterns must be unquoted to match.

**Ref:** BCS0303
