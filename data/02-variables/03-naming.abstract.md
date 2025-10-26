## Naming Conventions

**Use consistent naming to prevent conflicts and clarify scope.**

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Globals | UPPER_CASE | `VERBOSE=1` |
| Locals | lower_case | `local file_count=0` |
| Private functions | prefix _ | `_validate_input()` |
| Environment | UPPER_CASE | `export DATABASE_URL` |

**Example:**
```bash
# Constants/globals
readonly -- SCRIPT_VERSION='1.0.0'
declare -i VERBOSE=1

# Locals in functions
process_data() {
  local -i line_count=0
  local -- temp_file
}

# Private functions
_internal_helper() {
  # Internal use only
}
```

**Rationale:**
- UPPER_CASE for globals/constants: visible scope, shell conventions
- lower_case for locals: prevents shadowing globals
- Underscore prefix: signals internal use, prevents conflicts

**Anti-patterns:**
- Lowercase single letters (`a`, `b`, `n`) ’ shell reserved
- Shell variable names (`PATH`, `HOME`, `USER`) ’ causes conflicts

**Ref:** BCS0203
