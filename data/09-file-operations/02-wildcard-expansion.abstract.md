## Wildcard Expansion

**Always use explicit path prefix (`./*`) with wildcards to prevent filenames starting with `-` from being interpreted as flags.**

```bash
# ✓ Correct
rm -v ./*
for f in ./*.txt; do process "$f"; done

# ✗ Wrong - `-rf` file becomes flag
rm *
```

**Rationale:** Files named `-rf` or `--help` become command flags without path prefix.

**Ref:** BCS0902
