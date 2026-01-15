## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe to continue. Always document WHY.**

**Rationale:** Masks real bugs; silent failures appear successful; creates debugging nightmares.

### Safe to Suppress

- **Command/file existence checks:** `command -v tool >/dev/null 2>&1`
- **Cleanup operations:** `rm -f /tmp/app_* 2>/dev/null || true`
- **Idempotent operations:** `install -d "$dir" 2>/dev/null || true`

### NEVER Suppress

- File operations, data processing, system config, security ops, required dependencies

### Suppression Patterns

| Pattern | Use When |
|---------|----------|
| `2>/dev/null` | Hide messages, still check return |
| `|| true` | Ignore return, keep stderr |
| Both combined | Both irrelevant |

### Example

```bash
# ✓ Safe - cleanup may have nothing to do
# Rationale: Temp files may not exist
rm -f "$CACHE"/*.tmp 2>/dev/null || true

# ✗ DANGEROUS - critical operation
cp "$config" "$dest" 2>/dev/null || true

# ✓ Correct - check critical operations
cp "$config" "$dest" || die 1 "Copy failed"
```

### Anti-Patterns

```bash
# ✗ Suppress without documenting why
some_cmd 2>/dev/null || true

# ✗ Suppress entire function
process() { ...; } 2>/dev/null

# ✗ Using set +e to suppress
set +e; critical_op; set -e
```

**Key:** Every suppression is a deliberate decision—document it with a comment.

**Ref:** BCS0605
