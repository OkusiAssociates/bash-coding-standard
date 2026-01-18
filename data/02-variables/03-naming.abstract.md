## Naming Conventions

**Use consistent case conventions: UPPER_CASE for constants/globals/exports, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Globals | UPPER_CASE/CamelCase | `VERBOSE=1` |
| Locals | lower_case | `local file_count=0` |
| Private funcs | _prefix | `_validate_input()` |
| Exports | UPPER_CASE | `export DATABASE_URL` |

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -i VERBOSE=1
process_data() {
  local -i line_count=0
}
_internal_helper() { :; }
```

**Why:** UPPER_CASE signals script-wide scope; lower_case locals prevent shadowing globals; underscore prefix prevents namespace conflicts.

**Anti-patterns:** `PATH`, `HOME`, `USER` as variable names → conflicts with shell; single lowercase letters (`a`, `n`) → reserved by shell.

**Ref:** BCS0203
