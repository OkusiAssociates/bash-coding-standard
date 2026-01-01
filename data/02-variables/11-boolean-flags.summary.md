## Boolean Flags Pattern

Use integer variables with `declare -i` or `local -i` for boolean state:

```bash
declare -i DRY_RUN=0
declare -i VERBOSE=0
declare -i SKIP_BUILD=0

# Test with (()) - true for non-zero
((DRY_RUN)) && info 'Dry-run mode enabled'

if ((VERBOSE)); then
  show_details
fi

# Toggle
((VERBOSE)) && VERBOSE=0 || VERBOSE=1

# Set from args
case $1 in
  --dry-run) DRY_RUN=1 ;;
esac
```

**Guidelines:**
- Use `declare -i` for boolean flags, initialize to `0` or `1`
- Name descriptively in ALL_CAPS (e.g., `DRY_RUN`, `INSTALL_BUILTIN`)
- Test with `((FLAG))` - returns true for non-zero
- Keep boolean flags separate from integer counters
