## Strings with Variables

**Use double quotes when strings contain variables needing expansion.**

```bash
die 1 "Unknown option '$1'"
info "Installing to $PREFIX/bin"
echo "$SCRIPT_NAME $VERSION"
```

**Ref:** BCS0403
