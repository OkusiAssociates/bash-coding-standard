## General Script Layout

**All scripts follow a mandatory 13-step structure ensuring safe initialization and bottom-up dependency resolution.**

### The 13 Steps

1. **Shebang** `#!/bin/bash` or `#!/usr/bin/env bash`
2. **ShellCheck directives** (if needed)
3. **Brief description** - one-line purpose
4. **`set -euo pipefail`** - MUST precede any commands
5. **`shopt -s inherit_errexit shift_verbose extglob nullglob`**
6. **Metadata** - `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`
7. **Global declarations** - typed (`-i`/`--`/`-a`/`-A`)
8. **Colors** (conditional on `[[ -t 1 && -t 2 ]]`)
9. **Utility functions** - messaging (`info`, `warn`, `error`, `die`)
10. **Business logic** - organized bottom-up
11. **`main()`** - argument parsing, orchestration
12. **`main "$@"`** - invocation
13. **`#fin`** - mandatory end marker

### Minimal Example

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
declare -r VERSION=1.0.0
die() { >&2 echo "error: ${2:-}"; exit "${1:-1}"; }
main() { echo 'Hello'; }
main "$@"
#fin
```

### Key Rationale

- **Bottom-up**: functions call only previously-defined functions
- **`set -euo pipefail` first**: error handling before execution
- **`main()` required** for scripts >100 lines (enables testing)

### Anti-Patterns

- âœ— Business logic before `set -euo pipefail` â†' runtime failures
- âœ— Missing `main()` in large scripts â†' untestable

**Ref:** BCS0101
