### Dual-Purpose Scripts

**Scripts that work both as executables AND sourceable libraries must apply `set -euo pipefail` only when executed directly, never when sourced.**

Sourcing applies shell options to the caller's environment, breaking error handling.

**Detection:** `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`

**Pattern:**
```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0
# --- Executable section ---
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**Key Rules:**
- Functions defined BEFORE detection line (available in both modes)
- `set`/`shopt` AFTER detection (executable only)
- Use `return` not `exit` for sourced errors
- Guard metadata: `[[ ! -v VAR ]] && declare...` for idempotence

**Anti-patterns:**
- `set -e` before detection â†' pollutes caller's shell
- `exit 1` in sourced mode â†' terminates caller's shell

**Ref:** BCS010201
