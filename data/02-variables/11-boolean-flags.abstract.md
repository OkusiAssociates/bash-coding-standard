## Boolean Flags

**Use `declare -i` with 0/1 for boolean state; test with `(())`.**

### Why
- `(())` arithmetic returns proper exit codes (0=false, non-zero=true)
- Integer declaration prevents string pollution
- Explicit initialization prevents unset variable errors

### Pattern
```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && echo 'dry-run' ||:
if ((VERBOSE)); then debug_output; fi
```

### Anti-patterns
- `if [[ $FLAG == "true" ]]` → string comparison fragile
- `if [ $FLAG ]` → fails on unset or "0" string

**Ref:** BCS0211
