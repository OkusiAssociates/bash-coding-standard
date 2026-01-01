## Dry-Run Pattern

**Implement preview mode for state-modifying operations using `DRY_RUN` flag with early-return pattern.**

### Implementation

```bash
declare -i DRY_RUN=0
-n|--dry-run) DRY_RUN=1 ;;

deploy() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would deploy to' "$TARGET"
    return 0
  fi
  rsync -av "$SRC" "$TARGET"/
}
```

### Pattern

1. Check `((DRY_RUN))` at function start
2. Display `[DRY-RUN]` prefixed message via `info`
3. `return 0` without performing operations
4. Real operations only when flag is 0

### Key Points

- **Same control flow** â†' identical function calls in both modes
- **Safe preview** â†' verify paths/commands before execution
- **Debug installs** â†' essential for system modification scripts

**Anti-pattern:** Scattering dry-run checks throughout code â†' use function-level guards instead.

**Ref:** BCS1208
