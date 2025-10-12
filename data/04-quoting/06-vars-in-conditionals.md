### Variables in Conditionals

Always quote variables in test expressions (regardless of single/double quote choice for static strings):

```bash
# Always quote variables in conditionals
[[ -d "$path" ]]                 # ✓ Correct
[[ -d $path ]]                   # ✗ Wrong - word splitting danger

# Static comparison values - multiple acceptable forms
[[ "$var" == 'value' ]]          # ✓ Correct - var quoted, static value in single quotes
[[ "$var" == value ]]            # ✓ Also correct - one-word literal unquoted
[[ "$var" == "value" ]]          # ✗ Unnecessary - static value doesn't need double quotes
```
