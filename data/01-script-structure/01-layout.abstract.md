## BCS0101: Script Layout

**All Bash scripts follow 13-step bottom-up structure: infrastructure before implementation, utilities before business logic.**

### Rationale
- **Safe initialization**: `set -euo pipefail` runs before any commands; functions defined before called
- **Predictability**: Standard locations—metadata step 6, utilities step 9, business step 10
- **Error prevention**: Structure prevents undefined functions/variables classes of bugs

### 13 Steps (Executable Scripts)
1. `#!/bin/bash` 2. ShellCheck directives 3. Description comment 4. `set -euo pipefail` (MANDATORY first command) 5. `shopt -s inherit_errexit shift_verbose extglob nullglob` 6. Metadata (`VERSION`, `SCRIPT_PATH/DIR/NAME`) 7. Global declarations 8. Colors (if terminal) 9. Utility functions 10. Business logic 11. `main()` with arg parsing 12. `main "$@"` 13. `#fin`

### Minimal Example
```bash
#!/bin/bash
# Brief description
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
main() { echo "Hello"; }
main "$@"
#fin
```

### Anti-Patterns
- ✗ Missing `set -euo pipefail` → script continues after errors
- ✗ Business logic before utilities → undefined function calls

**Ref:** BCS0101
