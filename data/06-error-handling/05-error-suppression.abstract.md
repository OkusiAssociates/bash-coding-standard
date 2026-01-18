## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe; always document WHY.**

### Rationale
- Masks bugs, creates silent failures, security risks
- Suppressed errors make debugging impossible

### When Suppression is Safe
- **Existence checks**: `command -v tool >/dev/null 2>&1`
- **Optional cleanup**: `rm -f /tmp/app_* 2>/dev/null || true`
- **Idempotent ops**: `install -d "$dir" 2>/dev/null || true`

### When Suppression is DANGEROUS
- File operations, data processing, system config, security ops, required deps

```bash
# ✗ DANGEROUS - script continues with missing file
cp "$config" "$dest" 2>/dev/null || true

# ✓ Correct - fail explicitly
cp "$config" "$dest" || die 1 "Copy failed"
```

### Patterns
| Pattern | Use When |
|---------|----------|
| `2>/dev/null` | Suppress messages, still check return |
| `\|\| true` | Ignore return code |
| Both combined | Both irrelevant |

### Anti-Patterns
- `→` Suppressing critical ops (data, security, deps)
- `→` Suppressing without documenting why
- `→` Using `set +e` blocks instead of `|| true`
- `→` Redirecting entire function stderr

**Ref:** BCS0605
