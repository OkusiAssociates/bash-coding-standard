## Conditional Declarations with Exit Code Handling

**When using arithmetic conditionals for optional declarations or actions under `set -e`, append `|| :` to prevent false conditions from triggering script exit.**

**Rationale:**

- `(())` returns 0 when true, 1 when false - under `set -euo pipefail`, non-zero returns exit the script
- `|| :` provides safe fallback - colon `:` is a no-op returning 0, the traditional Unix idiom for "ignore this error"
- Conditional execution like `((condition)) && action` should continue when condition is false, not exit

**The core problem:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

#  DANGEROUS: Script exits here if complete=0!
((complete)) && declare -g BLUE=$'\033[0;34m'
# When complete=0:
#   1. (( complete )) returns 1
#   2. && short-circuits, declare never runs
#   3. Overall exit code is 1
#   4. set -e terminates the script!

echo "This line never executes"
```

**The solution:**

```bash
#!/bin/bash
set -euo pipefail

declare -i complete=0

#  SAFE: Script continues even when complete=0
((complete)) && declare -g BLUE=$'\033[0;34m' || :
# When complete=0:
#   1. (( complete )) returns 1
#   2. && short-circuits
#   3. || : triggers, returns 0
#   4. Script continues normally

echo "This line executes correctly"
```

**Why `:` over `true`:**

```bash
#  PREFERRED: Colon command
((condition)) && action || :
# - Traditional Unix idiom (Bourne shell)
# - 1 character (concise)
# - Slightly faster (no PATH lookup)

#  ACCEPTABLE: true command
((condition)) && action || true
# - More explicit/readable for beginners
# - 4 characters

# Both are built-ins that return 0; colon is traditional
```

**Common patterns:**

**Pattern 1: Conditional variable declaration**

```bash
declare -i complete=0 verbose=0

# Declare extended variables only in complete mode
((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :

# Print variables only in verbose mode
((verbose)) && declare -p NC RED GREEN YELLOW || :
```

**Pattern 2: Nested conditional declarations**

```bash
if ((color)); then
  declare -g NC=$'\033[0m' RED=$'\033[0;31m'
  ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' || :
else
  declare -g NC='' RED=''
  ((complete)) && declare -g BLUE='' MAGENTA='' || :
fi
```

**Pattern 3: Conditional block execution**

```bash
((verbose)) && {
  declare -p NC RED GREEN
  ((complete)) && declare -p BLUE MAGENTA || :
} || :
```

**Real-world example from color-set.sh:**

```bash
#!/bin/bash
# Dual-purpose script: sourceable library + executable demo

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0

  # Parse arguments to set flags
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose)  verbose=1 ;;
      always)   color=1 ;;
      never)    color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "$FUNCNAME: error: Invalid mode ${1@Q}"
                return 1 ;;
    esac
    shift
  done

  # Auto-detect if color not explicitly set
  ((color== -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }

  # Declare flag variables only if flags mode active
  if ((flags)); then
    declare -ig VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m'
    ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' || :
  else
    declare -g NC='' RED='' GREEN=''
    ((complete)) && declare -g BLUE='' MAGENTA='' BOLD='' || :
  fi

  # Print variables only in verbose mode
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE || :
    declare -p NC RED GREEN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT || :
      declare -p BLUE MAGENTA BOLD
    } || :
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: only execute when run directly
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0
#!/bin/bash #semantic
set -euo pipefail

color_set "$@"

#fin
```

**When to use this pattern:**

** Use `|| :` when:**

1. Optional variable declarations based on feature flags
2. Conditional exports for environment variables
3. Feature-gated actions that should be silent when disabled
4. Optional logging or debug output
5. Tier-based variable sets (like basic vs complete colors)

** Don't use when:**

1. **The action must succeed** - use explicit error handling instead
   ```bash
   #  Wrong - suppresses critical errors
   ((required_flag)) && critical_operation || :

   #  Correct - check explicitly
   if ((required_flag)); then
     critical_operation || die 1 "Critical operation failed"
   fi
   ```

2. **You need to know if it failed** - capture the exit code
   ```bash
   #  Wrong - hides failure
   ((condition)) && risky_operation || :

   #  Correct - handle failure
   if ((condition)) && ! risky_operation; then
     error "risky_operation failed"
     return 1
   fi
   ```

**Anti-patterns:**

```bash
#  WRONG: No || :, script exits when condition is false
((complete)) && declare -g BLUE=$'\033[0;34m'

#  WRONG: Double negative, less readable
((complete==0)) || declare -g BLUE=$'\033[0;34m'

#  WRONG: Using true instead of : (verbose, less idiomatic)
((complete)) && declare -g BLUE=$'\033[0;34m' || true

#  WRONG: Suppressing critical operations
((user_confirmed)) && delete_all_files || :
# If delete_all_files fails, error is hidden!

#  CORRECT: Check critical operations explicitly
if ((user_confirmed)); then
  delete_all_files || die 1 "Failed to delete files"
fi
```

**Comparison of alternatives:**

```bash
# Alternative 1: if statement (most explicit, best for complex logic)
if ((complete)); then
  declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
fi

# Alternative 2: Arithmetic test with || : (concise, safe, preferred for simple cases)
((complete)) && declare -g BLUE=$'\033[0;34m' || :

# Alternative 3: Double-negative pattern (confusing, avoid)
((complete==0)) || declare -g BLUE=$'\033[0;34m'

# Alternative 4: Temporarily disable errexit (never use - disables error checking)
set +e
((complete)) && declare -g BLUE=$'\033[0;34m'
set -e
```

**Testing the pattern:**

```bash
#!/bin/bash
set -euo pipefail

# Test 1: Verify false condition doesn't exit
test_false_condition() {
  local -i flag=0
  ((flag)) && echo "This won't print" || :
  echo "Test 1 passed: false condition didn't exit"
}

# Test 2: Verify true condition executes action
test_true_condition() {
  local -i flag=1
  local -- output=''
  ((flag)) && output="executed" || :
  [[ "$output" == "executed" ]] || {
    echo "Test 2 failed: true condition didn't execute"
    return 1
  }
  echo "Test 2 passed: true condition executed action"
}

# Test 3: Verify nested conditionals
test_nested_conditionals() {
  local -i outer=1 inner=0 executed=0
  ((outer)) && {
    executed=1
    ((inner)) && executed=2 || :
  } || :
  ((executed == 1)) || {
    echo "Test 3 failed: expected executed=1, got $executed"
    return 1
  }
  echo "Test 3 passed: nested conditionals work correctly"
}

# Run tests
test_false_condition
test_true_condition
test_nested_conditionals

echo "All tests passed!"

#fin
```

**Summary:**

- Use `|| :` after `((condition)) && action` to prevent false conditions from triggering `set -e` exit
- Colon `:` is preferred over `true` (traditional shell idiom, concise)
- Only for optional operations - critical operations need explicit error handling
- Test both paths - verify behavior when condition is true and false
- Cross-reference: See BCS0705 (Arithmetic Operations), BCS0805 (Error Suppression), BCS0801 (Exit on Error)

**Key principle:** When you want conditional execution without risking script exit, use `((condition)) && action || :`. This makes your intent explicit: "Do this if condition is true, but don't exit if condition is false."
