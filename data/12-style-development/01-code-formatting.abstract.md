## Code Formatting

**Use 2 spaces for indentation (never tabs), maintain consistency, keep lines under 100 characters (except paths/URLs), use `\` for line continuation.**

**Rationale:**
- 2-space indentation balances readability with nesting depth in complex scripts
- 100-char limit ensures readability in split terminals/code reviews without horizontal scrolling

**Example:**
```bash
if [[ -f "$config_file" ]]; then
  long_command --option1 value1 \
    --option2 value2 \
    --option3 value3
fi
```

**Anti-patterns:**
- `’` Using tabs for indentation (breaks visual consistency across editors)
- `’` Lines exceeding 100 chars without continuation (forces horizontal scrolling)

**Ref:** BCS1301
