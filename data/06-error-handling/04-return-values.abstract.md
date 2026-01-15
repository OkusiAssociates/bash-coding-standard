## Checking Return Values

**Always check return values explicitlyâ€”`set -e` misses pipelines, command substitution, and conditionals.**

**Rationale:** Explicit checks enable contextual errors, controlled recovery, and catch failures `set -e` misses.

**`set -e` limitations:** Pipelines (except last), conditionals, command substitution in assignments.

**Patterns:**

```bash
# || die pattern
mv "$f" "$d/" || die 1 "Failed to move ${f@Q}"

# || block for cleanup
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Check command substitution
out=$(cmd) || die 1 "cmd failed"

# PIPESTATUS for pipelines
cat f | grep x; ((PIPESTATUS[0])) && die 1 "cat failed"
```

**Critical settings:**
```bash
set -euo pipefail
shopt -s inherit_errexit  # Subshells inherit set -e
```

**Anti-patterns:**
- `cmd1; cmd2; if (($?))` â†' checks cmd2 not cmd1
- `output=$(failing_cmd)` without `|| die` â†' silent failure
- Generic errors `die 1 "failed"` â†' no context for debugging

**Ref:** BCS0604
