## Dry-Run Pattern

**Preview mode pattern: Check flag at function start, show preview message, return early without executing operations.**

```bash
declare -i DRY_RUN=0

# Parse options
-n|--dry-run) DRY_RUN=1 ;;

# Pattern in functions
build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi
  make standalone || die 1 'Build failed'
}
```

**Structure:**
1. Check `((DRY_RUN))` at function start
2. Display preview with `[DRY-RUN]` prefix via `info`
3. Return early (exit 0) without operations
4. Execute real operations when disabled

**Rationale:** Separates decision logic from action ’ script flows through same functions/logic paths whether previewing or executing ’ users verify paths/commands safely before destructive operations ’ maintains identical control flow for debugging.

**Anti-patterns:**
- `if ! ((DRY_RUN))` ’ Inverted logic harder to read
- Mixing dry-run checks with business logic ’ Test flag once at top, exit early

**Ref:** BCS1402
