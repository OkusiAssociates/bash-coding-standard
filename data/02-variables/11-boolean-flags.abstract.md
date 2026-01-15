## Boolean Flags

**Use `declare -i` integers (0/1) for boolean state; test with `(())`.**

### Rationale
- Arithmetic `((FLAG))` eliminates string comparison bugs
- Integer declaration prevents accidental string assignment

### Pattern
```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && info 'Dry-run mode'
if ((VERBOSE)); then log_debug; fi
```

### Anti-patterns
- `if [[ "$FLAG" == "true" ]]` â†' use `((FLAG))`
- Uninitialized flags â†' always init to 0 or 1

**Ref:** BCS0211
