## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `DRY_RUN` flag with early return.**

### Pattern

```bash
declare -i DRY_RUN=0
-n|--dry-run) DRY_RUN=1 ;;

func() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would do X'
    return 0
  fi
  # actual operations
}
```

### Key Points

- Check `((DRY_RUN))` at function start → show `[DRY-RUN]` prefix → `return 0`
- Same control flow in both modes (identical function calls/logic paths)
- Safe preview of destructive ops; verify paths/commands before execution

### Anti-Patterns

- `if ! ((DRY_RUN)); then ...` → inverted logic obscures intent
- Skipping dry-run for "minor" operations → inconsistent preview

**Ref:** BCS1208
