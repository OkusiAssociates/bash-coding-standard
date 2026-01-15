## Conditional Declarations with Exit Code Handling

**When using arithmetic conditionals for optional declarations under `set -e`, append `|| :` to prevent false conditions from triggering script exit.**

**Rationale:**
- `(())` returns exit code 0 when true, 1 when false
- Under `set -euo pipefail`, exit code 1 terminates the script
- `|| :` provides safe fallback (colon always returns 0)
- Traditional Unix idiom for "ignore this error"

**The problem and solution:**

```bash
#!/bin/bash
set -euo pipefail
declare -i complete=0

# ✗ DANGEROUS: Script exits here if complete=0!
((complete)) && declare -g BLUE=$'\033[0;34m'
# (( complete )) returns 1, && short-circuits, set -e terminates script

# ✓ SAFE: Script continues even when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# || : triggers on false, returns 0, script continues
```

**Why `:` over `true`:**

```bash
# ✓ PREFERRED: Colon command
((condition)) && action || :
# - Traditional Unix idiom (Bourne shell)
# - Built-in (no fork), 1 character, POSIX standard

# ✓ ACCEPTABLE: true command
((condition)) && action || true
# - More explicit for beginners, also built-in
```

**Common patterns:**

```bash
# Pattern 1: Conditional variable declaration
declare -i complete=0 verbose=0
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
((verbose)) && declare -p NC RED GREEN YELLOW || :

# Pattern 2: Nested conditional declarations
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
else
  declare -g NC='' RED=''
  ((complete)) && declare -g BLUE='' MAGENTA='' || :
fi

# Pattern 3: Conditional block execution
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :

# Pattern 4: Multiple conditional actions
if ((flags)); then
  declare -ig VERBOSE=${VERBOSE:-1}
  ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
fi
```

**When to use `|| :`:**

1. **Optional variable declarations** based on feature flags
   ```bash
   ((DEBUG)) && declare -g DEBUG_OUTPUT=/tmp/debug.log || :
   ```

2. **Conditional exports**
   ```bash
   ((PRODUCTION)) && export PATH=/opt/app/bin:$PATH || :
   ```

3. **Feature-gated actions** (silent when disabled)
   ```bash
   ((VERBOSE)) && echo "Processing $file" || :
   ```

4. **Optional logging**
   ```bash
   ((LOG_LEVEL >= 2)) && log_debug "Variable value: $var" || :
   ```

**When NOT to use:**

```bash
# ✗ Wrong - suppresses critical errors
((required_flag)) && critical_operation || :

# ✓ Correct - check explicitly
if ((required_flag)); then
  critical_operation || die 1 'Critical operation failed'
fi

# ✗ Wrong - hides failure
((condition)) && risky_operation || :

# ✓ Correct - handle failure
if ((condition)) && ! risky_operation; then
  error 'risky_operation failed'
  return 1
fi
```

**Anti-patterns:**

```bash
# ✗ WRONG: No || :, script exits when condition is false
((complete)) && declare -g BLUE=$'\033[0;34m'

# ✗ WRONG: Using true (verbose, less idiomatic)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

# ✗ WRONG: Complex fallback
((complete)) && declare -g BLUE=$'\033[0;34m' || { true; }

# ✗ WRONG: Suppressing critical operations
((user_confirmed)) && delete_all_files || :

# ✓ CORRECT: Check critical operations explicitly
if ((user_confirmed)); then
  delete_all_files || die 1 'Failed to delete files'
fi
```

**Alternatives comparison:**

```bash
# Alternative 1: if statement (most explicit, best for complex logic)
if ((complete)); then
  declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
fi

# Alternative 2: Arithmetic test with || : (concise, safe)
((complete)) && declare -g BLUE=$'\033[0;34m' || :

# Alternative 3: Double-negative (works but less readable)
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# ✗ Alternative 4: Temporarily disable errexit (NOT recommended)
set +e
((complete)) && declare -g BLUE=$'\033[0;34m'
set -e
```

**Testing the pattern:**

```bash
#!/bin/bash
set -euo pipefail

test_false_condition() {
  local -i flag=0
  ((flag)) && echo "This won't print" ||:
  echo "Test passed: false condition didn't exit"
}

test_true_condition() {
  local -i flag=1
  local -- output=''
  ((flag)) && output="executed" || :
  [[ "$output" == "executed" ]] || { echo "Test failed"; return 1; }
  echo 'Test passed: true condition executed action'
}

test_nested_conditionals() {
  local -i outer=1 inner=0 executed=0
  ((outer)) && {
    executed=1
    ((inner)) && executed=2 || :
  } || :
  ((executed == 1)) || { echo "Test failed: expected 1, got $executed"; return 1; }
  echo 'Test passed: nested conditionals work correctly'
}

test_false_condition
test_true_condition
test_nested_conditionals
echo 'All tests passed!'
```

**Summary:**
- Use `|| :` after `((condition)) && action` to prevent `set -e` exit on false
- Colon `:` preferred over `true` (traditional, concise)
- Only for optional operations - critical ops need explicit error handling
- Cross-reference: BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Key principle:** `((condition)) && action || :` means "do this if true, continue if false."
