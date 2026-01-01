## Conditional Declarations with Exit Code Handling

**Append `|| :` to arithmetic conditionals under `set -e` to prevent false conditions from triggering script exit.**

**Rationale:**
- `(())` returns exit code 0 (true) or 1 (false); `set -e` exits on non-zero
- `|| :` provides safe fallback—colon is a no-op returning 0
- Colon `:` preferred over `true`: traditional Unix idiom, 1 char, no PATH lookup

**The Problem:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: Script exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'
# (()) returns 1, && short-circuits, set -e terminates script
```

**The Solution:**

```bash
# ✓ SAFE: Script continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# || : triggers on false, returns 0, script continues
```

**Common Patterns:**

```bash
# Pattern 1: Conditional variable declaration
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
((verbose)) && declare -p NC RED GREEN YELLOW || :

# Pattern 2: Nested conditionals
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' || :
fi

# Pattern 3: Conditional block
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :

# Pattern 4: Feature-gated actions
((VERBOSE)) && echo "Processing $file" || :
((DRY_RUN)) && echo "Would execute: $command" || :
((LOG_LEVEL >= 2)) && log_debug "Value: $var" || :
```

**When to Use:**
- Optional variable declarations based on feature flags
- Conditional exports: `((PRODUCTION)) && export PATH=/opt/app/bin:$PATH || :`
- Silent feature-gated actions, optional logging/debug output
- Tier-based variable sets (basic vs complete)

**When NOT to Use:**

```bash
# ✗ Don't suppress critical operations
((required_flag)) && critical_operation || :

# ✓ Check explicitly when action must succeed
if ((required_flag)); then
  critical_operation || die 1 'Critical operation failed'
fi

# ✗ Don't hide failures you need to know about
((condition)) && risky_operation || :

# ✓ Handle failure explicitly
if ((condition)) && ! risky_operation; then
  error 'risky_operation failed'
  return 1
fi
```

**Anti-Patterns:**

```bash
# ✗ No || :, script exits when condition false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ Double negative, less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# ✗ Verbose, less idiomatic (use : not true)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

# ✗ Suppressing critical operation errors
((user_confirmed)) && delete_all_files || :
```

**Alternatives Comparison:**

| Alternative | Use When |
|-------------|----------|
| `if ((cond)); then ... fi` | Complex logic, multiple statements |
| `((cond)) && action \|\| :` | Simple conditional declaration |
| Disable errexit temporarily | Never—use `\|\| :` instead |

**Edge Cases:**

1. **Nested conditionals**: Each level needs its own `|| :`
   ```bash
   ((outer)) && { ((inner)) && action || :; } || :
   ```

2. **Action failure vs condition failure**: `|| :` only handles condition being false—if action fails, error propagates correctly

**Cross-reference:** BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)
