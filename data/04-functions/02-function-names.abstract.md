## Function Names

**Use `lowercase_with_underscores`; prefix private functions with `_`.**

### Pattern
```bash
process_file() { â€¦ }      # Public
_validate() { â€¦ }         # Private (internal use)
```

### Key Points
- Matches Unix conventions (`grep`, `sed`)
- Avoids conflict with builtins and variables
- CamelCase/UPPER_CASE reserved for other purposes

### Anti-Patterns
- `MyFunction()` â†' confuses with variables
- `cd() { â€¦ }` â†' overriding builtins dangerous; use `change_dir()` instead
- `my-function()` â†' dashes cause issues

**Ref:** BCS0402
