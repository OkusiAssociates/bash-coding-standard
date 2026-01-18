### Quoting in Conditionals

**Always quote variables in conditionals.** Static literals: single quotes or unquoted one-word.

**Why:** Unquoted vars break on spaces/globs, empty vars cause syntax errors, security risk.

```bash
[[ -f "$file" ]]              # ✓ Variable quoted
[[ "$action" == 'start' ]]    # ✓ Literal single-quoted
[[ "$name" == *.txt ]]        # ✓ Glob pattern unquoted
[[ "$input" =~ $pattern ]]    # ✓ Regex pattern unquoted
```

**Anti-patterns:** `[[ -f $file ]]` → breaks with spaces; `[[ "$x" =~ "$pattern" ]]` → becomes literal match.

**Ref:** BCS0303
