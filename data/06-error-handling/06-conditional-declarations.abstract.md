## Conditional Declarations with Exit Code Handling

**Append `|| :` to `((cond)) && action` patterns under `set -e` to prevent false conditions from exiting.**

**Why:** `(())` returns exit code 1 when false → `set -e` terminates script. `:` is a no-op returning 0.

**Core pattern:**
```bash
set -euo pipefail
declare -i flag=0

# ✗ DANGEROUS: exits if flag=0
((flag)) && declare -g VAR=value

# ✓ SAFE: continues when flag=0
((flag)) && declare -g VAR=value || :
```

**Use for:** Optional declarations, conditional exports, feature-gated logging, verbose output.

**Anti-patterns:**
- `((cond)) && action` without `|| :` → script exits on false
- `((cond)) && critical_op || :` → hides critical failures; use explicit `if` with error handling instead

**When NOT to use:** Critical operations requiring error handling—use explicit `if` blocks with proper failure checks.

**Prefer `:` over `true`:** Traditional idiom, 1 char, no PATH lookup.

**Ref:** BCS0606
