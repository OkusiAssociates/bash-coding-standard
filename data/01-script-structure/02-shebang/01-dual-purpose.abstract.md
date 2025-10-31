### Dual-Purpose Scripts (Executable and Sourceable)

**Dual-purpose scripts work as executables AND source libraries. Apply `set -euo pipefail` and `shopt` ONLY when executed, NOT when sourced (prevents modifying caller's shell state).**

**Pattern (early return - recommended):**
```bash
#!/bin/bash
# Functions first
my_function() {
  local -- arg="$1"
  echo "Processing: $arg"
}
declare -fx my_function

# Early return when sourced
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

# Executable section (only runs when executed)
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

my_function "$@"
#fin
```

**Key rules:**
- Functions before sourced/executed check
- Early return: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`
- `set`/`shopt` after early return (executable section only)
- Metadata guard: `[[ ! -v SCRIPT_VERSION ]]` for idempotence
- Use `return` (not `exit`) for errors when sourced
- Test both: `./script.sh` (execute), `source script.sh` (source)

**Alternative (if/else):**
```bash
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  set -euo pipefail  # Executed mode
  process_data
else
  return 0  # Sourced mode
fi
```

**Rationale:** Sourcing must not alter caller's error handling or glob behavior.

**Anti-pattern:** Applying `set -e` at script top (breaks sourced mode).

**Ref:** BCS010201
