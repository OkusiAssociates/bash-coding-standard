## Conditional Declarations with Exit Code Handling

**Append `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit.**

**Rationale:**
- Arithmetic `(())` returns 0 (true) or 1 (false); under `set -e`, exit code 1 terminates script
- False condition in `((x)) && action` returns 1, causing unwanted exit
- `|| :` provides safe fallback (colon always returns 0, traditional Unix idiom)

**Example:**

```bash
set -euo pipefail
declare -i complete=0

# ✗ Script exits when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✓ Script continues
((complete)) && declare -g BLUE=$'\033[0;34m' || :
```

**Common patterns:**

```bash
# Conditional declarations
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :

# Feature-gated actions
((VERBOSE)) && echo "Processing $file" || :

# Nested conditionals
((outer)) && {
  action1
  ((inner)) && action2 || :
} || :
```

**Use when:** Optional declarations, feature flags, debug output, tier-based variables

**Don't use for:** Critical operations (use explicit error handling)

**Anti-patterns:**

```bash
# ✗ Missing || :, exits on false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ Suppressing critical errors
((confirmed)) && delete_all_files || :

# ✓ Explicit check for critical ops
if ((confirmed)); then
  delete_all_files || die 1 "Failed"
fi
```

**Ref:** BCS0806
