## STDOUT vs STDERR

**All error messages â†' STDERR; place `>&2` at beginning for clarity.**

```bash
>&2 echo "[$(date -Ins)]: $*"
```

Anti-pattern: `echo "error" >&2` â†' harder to spot redirection at line end.

**Ref:** BCS0702
