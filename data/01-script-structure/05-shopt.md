### shopt

**Recommended settings for most scripts:**

```bash
# STRONGLY RECOMMENDED - apply to all scripts
shopt -s inherit_errexit  # Critical: makes set -e work in subshells,
                          # command substitutions
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE based on use case:
shopt -s nullglob   # For arrays/loops: unmatched globs → empty (no error)
                # OR
shopt -s failglob   # For strict scripts: unmatched globs → error

# OPTIONAL based on needs:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

Example for typical script:
```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```
