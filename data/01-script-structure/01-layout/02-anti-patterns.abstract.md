### Common Layout Anti-Patterns

**Eight critical BCS0101 violations causing silent failures and runtime errors.**

1. **Missing `set -euo pipefail`** → Silent corruption. Place at line 4.

2. **Variables after use** → Unbound variable errors. Declare globals in Step 7 before functions.

3. **Business logic before utilities** → Calls undefined helpers. Order: messaging → helpers → business → main().

4. **No `main()` in large scripts** → Scattered execution, untestable. Required for scripts >40 lines.

5. **Missing `#fin`** → No completion proof. Always end with `#fin`.

6. **Readonly before parsing** → Cannot modify during argument parsing. Make readonly after values finalized.

7. **Scattered declarations** → Hard to track state. Group all globals in Step 7.

8. **Unprotected sourcing** → Modifies caller's shell. Use `[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0` before `set -e`.

**Wrong:**
```bash
#!/usr/bin/env bash
VERSION='1.0.0'  # No set -e!
readonly -- PREFIX  # Too early
process_files()  # Calls undefined die()
main "$@"  # No wrapper
```

**Correct:**
```bash
#!/usr/bin/env bash
set -euo pipefail
VERSION='1.0.0'
declare -- PREFIX='/usr'
die() { error "$*"; exit 1; }
process_files() { die "error"; }
main() { process_files; readonly -- PREFIX; }
main "$@"
#fin
```

**Ref:** BCS010102
