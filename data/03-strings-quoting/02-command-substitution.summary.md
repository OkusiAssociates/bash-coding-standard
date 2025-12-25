### Command Substitution

**Rule: BCS0302**

Use double quotes when strings include command substitution. Always quote results to preserve whitespace and prevent word splitting.

```bash
# ✓ Correct - double quotes for command substitution
echo "Current time: $(date +%T)"
info "Found $(wc -l < "$file") lines"
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"

# ✓ Correct - quoted result
result=$(command)
echo "$result"

# ✗ Wrong - unquoted result
echo $result    # Word splitting occurs!
```

#fin
