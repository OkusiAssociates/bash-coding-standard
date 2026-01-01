## shopt Settings

**Configure `shopt -s inherit_errexit shift_verbose extglob nullglob` for robust error handling and glob behavior.**

### Required Settings

| Option | Purpose |
|--------|---------|
| `inherit_errexit` | Makes `set -e` work in `$(...)` subshells |
| `shift_verbose` | Error on invalid shift (no silent failure) |
| `extglob` | Extended patterns: `!(*.txt)`, `+([0-9])` |

### Glob Behavior (Choose One)

- **`nullglob`** â†' Unmatched glob = empty (for loops/arrays)
- **`failglob`** â†' Unmatched glob = error (strict scripts)

### Why inherit_errexit is Critical

```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!
echo 'Still runs'  # Executes

shopt -s inherit_errexit
result=$(false)  # Script exits here
```

### Anti-Pattern

```bash
# âœ— Default: unmatched glob = literal string
for f in *.txt; do rm "$f"; done  # Tries "rm *.txt" if no match!

# âœ“ With nullglob: loop skipped if no matches
shopt -s nullglob
for f in *.txt; do rm "$f"; done
```

### Optional

`globstar` enables `**/*.sh` recursive matching (slow on deep trees).

**Ref:** BCS0105
