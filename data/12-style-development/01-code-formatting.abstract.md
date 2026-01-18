## Code Formatting

**Use 2-space indentation (no tabs), lines under 100 chars.**

### Rules
- **Indentation**: 2 spaces, consistent throughout
- **Line length**: ≤100 chars; paths/URLs may exceed; use `\` for continuation

### Rationale
- 2-space aligns with Google Shell Style Guide
- Consistent indentation enables automated linting

### Example
```bash
process_files() {
  local file
  for file in "${files[@]}"; do
    validate "$file" \
      && process "$file"
  done
}
```

### Anti-patterns
- `→` Tabs or 4-space indent
- `→` Lines >100 chars without continuation

**Ref:** BCS1201
