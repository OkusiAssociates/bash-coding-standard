### Dual-Purpose Scripts

**Scripts working as both executables and sourceable libraries must apply `set -euo pipefail` and `shopt` ONLY when executed directly, never when sourced.**

Sourcing a script with `set -e` alters the caller's shell state, breaking error handling.

**Pattern (early return):**
```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0
# --- Executable section ---
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

if [[ ! -v SCRIPT_VERSION ]]; then
  declare -x SCRIPT_VERSION=1.0.0
  readonly -- SCRIPT_VERSION
fi

my_func "$@"
#fin
```

**Structure:** Functions first â†' early return for sourced mode â†' `set`/`shopt` â†' guarded metadata â†' main logic.

**Anti-patterns:**
- `set -euo pipefail` before source detection â†' pollutes caller's shell
- Using `exit` instead of `return` when sourced â†' kills caller's shell

**Key:** Use `[[ ! -v VAR ]]` guard for idempotent re-sourcing; use `return` (not `exit`) for sourced errors.

**Ref:** BCS010201
