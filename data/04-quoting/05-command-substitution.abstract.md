## Command Substitution in Strings

**Always use double quotes when including command substitution** - enables variable expansion and preserves output as single argument.

```bash
# Command substitution in messages
echo "Current time: $(date +%T)"
info "Found $(wc -l "$file") lines"

# Assignment with command substitution
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
```

**Ref:** BCS0405
