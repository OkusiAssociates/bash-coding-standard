## Wildcard Expansion

**Always use explicit `./*` path prefix for wildcard operations.**

Prevents filenames starting with `-` from being interpreted as command flags.

```bash
rm -v ./*                    # ✓ Safe
for f in ./*.txt; do         # ✓ Safe
# rm -v *                    # ✗ -file.txt becomes flag
```

**Ref:** BCS0902
