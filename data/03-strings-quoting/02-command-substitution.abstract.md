### Command Substitution

**Use double quotes when strings include `$(...)`; always quote results to prevent word splitting.**

```bash
info "Found $(wc -l < "$file") lines"
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
result=$(cmd); echo "$result"  # âœ“ Quoted
```

`echo $result` â†' word splitting breaks multi-word output.

**Ref:** BCS0302
