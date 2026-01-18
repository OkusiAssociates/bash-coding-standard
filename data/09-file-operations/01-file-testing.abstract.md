## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests.**

### Key Operators

| Op | Test | Op | Test |
|----|------|----|------|
| `-f` | Regular file | `-r` | Readable |
| `-d` | Directory | `-w` | Writable |
| `-e` | Exists (any) | `-x` | Executable |
| `-L` | Symlink | `-s` | Non-empty |
| `-nt` | Newer than | `-ot` | Older than |

### Rationale

- `"$var"` prevents word splitting/glob expansion
- `[[ ]]` more robust than `[ ]` or `test`
- Test before use → prevents missing file errors

### Pattern

```bash
# Validate file exists and readable
[[ -f "$file" ]] || die 2 "Not found ${file@Q}"
[[ -r "$file" ]] || die 5 "Cannot read ${file@Q}"

# Ensure writable directory
[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ -w "$dir" ]] || die 5 "Not writable ${dir@Q}"
```

### Anti-Patterns

```bash
# ✗ Unquoted → breaks with spaces
[[ -f $file ]]
# ✓ Always quote
[[ -f "$file" ]]

# ✗ Silent failure
[[ -d "$dir" ]] || mkdir "$dir"
# ✓ Catch errors
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Failed ${dir@Q}"
```

**Ref:** BCS0901
