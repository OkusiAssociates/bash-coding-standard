## Error Suppression

**Only suppress when failure is expected, non-critical, and safe. Always document WHY. Suppression masks bugs.**

**Appropriate:**
- Optional checks: `command -v tool >/dev/null 2>&1`
- Cleanup: `rm -f /tmp/myapp_* 2>/dev/null || true`
- Idempotent: `install -d "$dir" 2>/dev/null || true`

**NEVER suppress:**

```bash
# ✗ Critical file ops
cp "$config" "$dest" 2>/dev/null || true
# ✓ Correct
cp "$config" "$dest" || die 1 "Copy failed"

# ✗ Data processing
process < in.txt > out.txt 2>/dev/null || true
# ✓ Correct
process < in.txt > out.txt || die 1 'Processing failed'

# ✗ Security ops
chmod 600 "$key" 2>/dev/null || true
# ✓ Correct
chmod 600 "$key" || die 1 "Failed to secure $key"
```

**Patterns:**
- `2>/dev/null` - Suppress messages, check return
- `|| true` - Ignore return code
- `2>/dev/null || true` - Suppress both

**Documentation required:**

```bash
# Suppress: temp files may not exist (non-critical)
rm -f /tmp/myapp_* 2>/dev/null || true

# ✗ WRONG - no reason
cmd 2>/dev/null || true
```

**Anti-patterns:**

```bash
# ✗ Function-wide suppression
process() { ...; } 2>/dev/null

# ✗ Using set +e
set +e; operation; set -e
```

**Principle:** Suppression is exceptional. Document every `2>/dev/null` and `|| true` with WHY.

**Ref:** BCS0805
