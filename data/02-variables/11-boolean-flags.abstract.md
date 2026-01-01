## Boolean Flags

**Use `declare -i` integers with `(())` for boolean state; 0=false, non-zero=true.**

```bash
declare -i DRY_RUN=0 VERBOSE=0
((DRY_RUN)) && info 'Dry-run mode'
case $1 in --dry-run) DRY_RUN=1 ;; esac
```

**Rules:** ALL_CAPS naming â†' initialize explicitly â†' test with `((FLAG))` â†' don't mix with counters

**Anti-pattern:** `[[ "$FLAG" == "true" ]]` â†' use `((FLAG))`

**Ref:** BCS0211
