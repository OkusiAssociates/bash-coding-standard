## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Rationale:**
- `(())` returns exit code 1 when false �' `set -e` terminates script
- `|| :` (colon = no-op returning 0) provides safe fallback
- Traditional Unix idiom; `:` preferred over `true` (built-in, 1 char)

**Pattern:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ SAFE: continues when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use for:** optional declarations, conditional exports, feature-gated actions, debug output.

**Don't use for:** critical operations needing error handling �' use `if` with explicit error checks.

**Anti-patterns:**

```bash
# ✗ Missing || : - script exits on false
((flag)) && action

# ✗ Suppressing critical operations
((confirmed)) && delete_files || :  # hides failures!

# ✓ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606
