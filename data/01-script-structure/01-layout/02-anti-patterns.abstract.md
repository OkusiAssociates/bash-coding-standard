### Layout Anti-Patterns

**Critical violations of BCS0101 13-step layout that cause silent failures and structural bugs.**

---

#### Critical Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Missing `set -euo pipefail` | Silent failures, script continues after errors | Add immediately after shebang |
| Variables after use | "Unbound variable" with `set -u` | Declare all globals before `main()` |
| Business logic before utilities | Functions call undefined helpers | Bottom-up: utilities â†' business â†' main |
| No `main()` (>40 lines) | Can't test, can't source, scattered parsing | Wrap execution in `main()` |
| Missing `#fin` | Can't detect truncated files | Always end with `#fin` |
| Premature `readonly` | Can't modify during arg parsing | `readonly` after parsing complete |
| Scattered globals | Hard to audit state | Group all declarations together |

---

#### Dual-Purpose Pattern

```bash
#!/usr/bin/env bash
# Functions available when sourced
die() { >&2 echo "ERROR: ${*:2}"; exit "${1:-1}"; }

# Exit early if sourced
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

# Execution starts here
set -euo pipefail
main() { : ...; }
main "$@"
#fin
```

**Key:** `set -euo pipefail` and `main "$@"` only run when executed, not sourced.

**Ref:** BCS010102
