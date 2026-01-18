### Dual-Purpose Scripts

**`set -euo pipefail` and `shopt` ONLY when executed directly, NEVER when sourced.** Sourcing applies settings to caller's shell, breaking their error handling.

**Pattern:** Functions first → early return for sourced → executable section with strict mode.

```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0
# --- Executable section ---
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
my_func "$@"
```

**Key points:**
- `return 0` exits cleanly when sourced; execution continues when run directly
- Guard metadata: `[[ ! -v VAR ]]` for safe re-sourcing
- Use `return` not `exit` for errors when sourced

**Anti-patterns:**
- `set -euo pipefail` at top of dual-purpose script → breaks caller's shell
- Missing `declare -fx` → functions unavailable to subshells when sourced

**Ref:** BCS010201
