### Dual-Purpose Scripts

**Scripts executable AND sourceable must apply `set -euo pipefail`/`shopt` ONLY when executed directly, never when sourced.**

**Why:** Sourcing applies settings to caller's shell, breaking its error handling/glob behavior.

**Pattern:**
```bash
#!/bin/bash
my_func() { local -- arg="$1"; echo "$arg"; }
declare -fx my_func

# Early return when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable section only
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
my_func "$@"
```

**Rules:**
- Functions BEFORE source detection
- `return 0` for sourced mode (not `exit`)
- Guard metadata: `[[ ! -v VAR ]]` for idempotence

**Anti-patterns:**
- `set -euo pipefail` at top of dual-purpose script â†' breaks caller's shell
- Using `exit` when sourced â†' terminates caller's shell

**Ref:** BCS010201
