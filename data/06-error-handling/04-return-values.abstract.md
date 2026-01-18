## Checking Return Values

**Always check return values explicitly—`set -e` misses pipelines, command substitution, and conditionals.**

### Rationale
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution assignments
- Explicit checks enable contextual error messages and controlled cleanup

### Core Patterns

```bash
# Pattern 1: || die (concise)
mv "$src" "$dst/" || die 1 "Failed: ${src@Q} → ${dst@Q}"

# Pattern 2: || { } for cleanup
mv "$tmp" "$final" || { rm -f "$tmp"; die 1 "Move failed"; }

# Pattern 3: Command substitution
output=$(cmd) || die 1 'cmd failed'

# Pattern 4: Pipelines - use PIPESTATUS
cat f | grep p | sort
((PIPESTATUS[0] == 0)) || die 1 'cat failed'
```

### Critical Settings

```bash
set -euo pipefail
shopt -s inherit_errexit  # Bash 4.4+: cmd subst inherits set -e
```

### Anti-Patterns

- `mv "$f" "$d"`→No check, silent failure
- `cmd1; cmd2; (($?))`→Checks cmd2, not cmd1
- `die 1 'failed'`→No context; use `die 1 "Failed: ${var@Q}"`
- `out=$(cmd)` alone→Failure undetected without `|| die`

**Ref:** BCS0604
