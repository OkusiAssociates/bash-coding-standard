### Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of user input in error messages and logging.**

`${parameter@Q}` expands to shell-quoted value preventing injection attacks.

**When to use:** Error messages, logging, dry-run output.
**Not for:** Normal expansion, comparisons.

```bash
# âœ— Injection risk â†' âœ“ Safe display
die 2 "Unknown option $1"      # dangerous
die 2 "Unknown option ${1@Q}"  # safe

# Dry-run: display command safely
printf -v quoted '%s ' "${cmd[@]@Q}"
info "[DRY-RUN] Would execute: $quoted"
```

**Behavior comparison:**
- `$var` on `$(date)` â†' executes command
- `${var@Q}` on `$(date)` â†' outputs `'$(date)'` (literal)

**Ref:** BCS0306
