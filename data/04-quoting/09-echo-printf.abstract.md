## Echo and Printf Statements

**Use single quotes for static strings, double quotes when variables/commands needed.**

```bash
# Static - single quotes
echo 'Installation complete'

# Variables - double quotes
echo "Installing to $PREFIX/bin"
printf 'Found %d files in %s\n' "$count" "$dir"
```

**Anti-pattern:** `echo "static string"` ’ wastes quoting, use `echo 'static string'`

**Ref:** BCS0409
