## Boolean Flags Pattern

**Use `declare -i` for boolean state flags, test with `(())`.**

```bash
declare -i DRY_RUN=0
declare -i VERBOSE=0

# Test in conditionals
((DRY_RUN)) && info 'Dry-run enabled'

if ((VERBOSE)); then
  debug "Details here"
fi

# Set from arguments
--dry-run) DRY_RUN=1 ;;
```

**Rules:**
- `declare -i FLAG=0` → explicit integer declaration
- ALL_CAPS naming (DRY_RUN, SKIP_BUILD)
- Initialize to `0` (false) or `1` (true)
- Test: `((FLAG))` → true if non-zero
- Toggle: `((FLAG)) && FLAG=0 || FLAG=1`

**Anti-patterns:**
- `if [[ $FLAG -eq 1 ]]` → use `((FLAG))`
- `declare FLAG=false` → strings not testable with `(())`

**Ref:** BCS0207
