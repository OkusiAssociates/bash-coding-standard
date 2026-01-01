## Naming Conventions

**Use UPPER_CASE for globals/constants, lower_case for locals, underscore prefix for private functions.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `MAX_RETRIES=3` |
| Locals | lower_case | `local file_count=0` |
| Private functions | _prefix | `_validate_input()` |

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -i VERBOSE=1
process_data() {
  local -i line_count=0
  local -- temp_file
}
_internal_helper() { :; }
```

**Why:** UPPER_CASE signals script-wide scope; lower_case prevents shadowing; underscore prefix marks internal-only. Avoid shell reserved names (`PATH`, `HOME`, single-letter).

**Ref:** BCS0203
