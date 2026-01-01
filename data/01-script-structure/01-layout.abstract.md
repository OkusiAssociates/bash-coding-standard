## Script Structure Layout

**All scripts follow 13-step bottom-up layout: infrastructure â†' implementation â†' orchestration.**

### The 13 Steps

1. `#!/bin/bash` (or `#!/usr/bin/env bash`)
2. `#shellcheck` directives (if needed, with comments)
3. Brief description comment
4. `set -euo pipefail` â€” **MANDATORY before any commands**
5. `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. Metadata: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` â†' `declare -r`
7. Global declarations with types (`declare -i`, `declare --`, `declare -a`)
8. Color definitions (if terminal output)
9. Utility functions (messaging: `info`, `warn`, `error`, `die`)
10. Business logic functions
11. `main()` with argument parsing
12. `main "$@"`
13. `#fin` or `#end`

### Core Rationale
- Error handling before any code runs
- Bottom-up: utilities before business logic before `main()`
- Testable: source script to test individual functions

### Minimal Example
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
declare -r VERSION=1.0.0
main() { echo "Hello $VERSION"; }
main "$@"
#fin
```

### Anti-patterns
- `set -euo pipefail` after commands â†' **breaks safety**
- Business logic before utility functions â†' **undefined calls**
- No `main()` in scripts >100 lines â†' **untestable**

**Ref:** BCS0101
