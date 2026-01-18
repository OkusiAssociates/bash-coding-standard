## shopt

**Configure shell options for robust error handling and glob behavior.**

### Recommended Settings

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

### Critical Options

| Option | Effect |
|--------|--------|
| `inherit_errexit` | Makes `set -e` work in `$(...)` subshells |
| `shift_verbose` | Error on shift when no args remain |
| `extglob` | Extended patterns: `!(*.txt)`, `@(jpg|png)` |
| `nullglob` | Unmatched glob → empty (for loops/arrays) |
| `failglob` | Unmatched glob → error (strict mode) |
| `globstar` | Enable `**` recursive matching (slow on deep trees) |

### Why `inherit_errexit` is Critical

```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!
# With inherit_errexit: exits as expected
```

### `nullglob` vs Default

```bash
# ✗ Default: unmatched glob stays literal
for f in *.txt; do rm "$f"; done  # Tries to delete "*.txt"!

# ✓ nullglob: unmatched → empty, loop skips
shopt -s nullglob
for f in *.txt; do rm "$f"; done  # Safe
```

**Ref:** BCS0105
