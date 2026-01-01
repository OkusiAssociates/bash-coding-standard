## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from terminating script.**

**Core Problem:** `(())` returns 1 (failure) when false �' `set -e` exits script.

**Rationale:**
- `|| :` provides safe fallback (`:` always returns 0)
- Traditional Unix idiom for "ignore this error"

**Pattern:**

```bash
declare -i complete=0

# ✗ DANGEROUS: Script exits if complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ SAFE: Script continues
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Use `:` over `true`:** Traditional, concise (1 char), built-in, no PATH lookup.

**When to use:** Optional declarations, conditional exports, feature-gated actions, optional logging.

**When NOT to use:** Critical operations needing explicit error handling �' use `if` statement instead.

**Anti-patterns:**

```bash
# ✗ Missing || : - exits on false
((flag)) && action

# ✗ Suppressing critical operations
((confirmed)) && delete_files || :

# ✓ Critical ops need explicit handling
if ((confirmed)); then
  delete_files || die 1 'Failed'
fi
```

**Ref:** BCS0606
