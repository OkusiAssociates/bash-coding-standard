## Error Suppression

**Only suppress errors when failure is expected, non-critical, and safe. Always document WHY.**

**Rationale:** Masks bugs, silent failures, debugging nightmare, security risk.

### Safe to Suppress

- Command existence: `command -v tool >/dev/null 2>&1`
- Optional files: `[[ -f "$optional" ]]`
- Cleanup: `rm -f /tmp/app_* 2>/dev/null || true`
- Idempotent ops: `install -d "$dir" 2>/dev/null || true`

### NEVER Suppress

- Critical file ops â†' must verify success
- Data processing â†' silent data loss
- System config â†' `systemctl` must check
- Security ops â†' `chmod 600` must succeed
- Required deps â†' fail early

### Patterns

```bash
# Suppress stderr, check return
if ! command 2>/dev/null; then handle_error; fi

# Ignore return (stderr visible)
command || true

# Full suppression (document why!)
# Rationale: temp files may not exist
rm -f /tmp/app_* 2>/dev/null || true
```

### Anti-Patterns

```bash
# âœ— Suppressing critical op
cp "$file" "$backup" 2>/dev/null || true

# âœ— Undocumented suppression
some_cmd 2>/dev/null || true

# âœ— Block suppression
set +e; critical_op; set -e

# âœ“ Check critical ops
cp "$file" "$dest" || die 1 'Failed'
```

**Key:** Every suppression needs a comment explaining why failure is safe to ignore.

**Ref:** BCS0605
