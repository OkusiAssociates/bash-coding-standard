## STDOUT vs STDERR

**Errors → STDERR; place `>&2` at command start for clarity.**

### Rationale
- Enables `2>/dev/null` filtering without losing output
- Allows proper pipeline composition (stdout = data, stderr = diagnostics)

### Pattern
```bash
log_err() { >&2 echo "[$(date -Ins)]: $*"; }
```

### Anti-patterns
- `echo "Error"` → errors lost in stdout stream
- `echo "msg" >&2` → redirection at end less visible

**Ref:** BCS0702
