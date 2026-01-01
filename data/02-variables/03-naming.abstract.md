## Naming Conventions

**Use case-based naming to distinguish scope and prevent conflicts with shell built-ins.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Globals | UPPER_CASE or CamelCase | `VERBOSE=1` |
| Locals | lower_case | `local file_count=0` |
| Private funcs | `_` prefix | `_validate_input()` |
| Env vars | UPPER_CASE | `export DATABASE_URL` |

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -i VERBOSE=1
process_data() {
  local -i line_count=0
  local -- temp_file
}
_internal_helper() { :; }
```

**Rationale:**
- UPPER_CASE globals visible as script-wide; lower_case locals prevent shadowing
- Underscore prefix signals internal use, prevents namespace conflicts
- Avoid shell reserved names (`PATH`, `HOME`, `a`, `b`, `n`)

**Anti-patterns:** `path=...` â†' shadows PATH; `local VERBOSE` â†' confuses scope

**Ref:** BCS0203
