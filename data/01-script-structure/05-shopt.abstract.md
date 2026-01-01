## shopt

**Configure shell options for robust error handling and glob behavior.**

**Recommended settings:**
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

### Critical Options

| Option | Purpose |
|--------|---------|
| `inherit_errexit` | Makes `set -e` work in `$(...)` subshells (CRITICAL) |
| `shift_verbose` | Error on `shift` when no args remain |
| `extglob` | Extended patterns: `!(*.txt)`, `+([0-9])`, `@(jpg|png)` |
| `nullglob` | Unmatched globs â†' empty (for loops/arrays) |
| `failglob` | Unmatched globs â†' error (strict scripts) |
| `globstar` | Enable `**` recursive matching (optional, slow) |

### Key Anti-Patterns

```bash
# âœ— Without inherit_errexit - error silently ignored
result=$(false); echo 'Still running'

# âœ— Default glob behavior - literal string if no match
for f in *.txt; do rm "$f"; done  # Deletes file named "*.txt"!
```

### Rationale

1. **`inherit_errexit`**: Without it, `set -e` doesn't apply inside command substitutionsâ€”errors silently continue
2. **`nullglob`/`failglob`**: Default bash passes literal glob string when no match, causing dangerous behavior

**Ref:** BCS0105
