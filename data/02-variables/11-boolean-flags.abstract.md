## Boolean Flags

**Use `declare -i` integer variables for boolean state; test with `(())`.**

### Why
- Arithmetic truthiness (`((FLAG))`) is cleaner than string comparison
- Integer type prevents accidental non-numeric assignment

### Pattern
```bash
declare -i DRY_RUN=0
((DRY_RUN)) && info 'Dry-run mode'
case $1 in --dry-run) DRY_RUN=1 ;; esac
```

### Anti-patterns
- `DRY_RUN=false` â†' Use `0`/`1`, not strings
- `[[ "$FLAG" -eq 1 ]]` â†' Use `((FLAG))`

**Ref:** BCS0211
