## Naming Conventions

**Use consistent case conventions to distinguish scope and avoid shell conflicts.**

| Type | Convention | Example |
|------|------------|---------|
| Constants/Globals | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Local variables | lower_case | `local file_count=0` |
| Private functions | _prefix | `_validate_input()` |

```bash
declare -r SCRIPT_VERSION=1.0.0
process_data() {
  local -i line_count=0
  local -- temp_file
}
_internal_helper() { :; }
```

**Rationale:** UPPER_CASE signals script-wide scope; lower_case prevents shadowing globals; underscore prefix marks internal functions.

**Anti-patterns:** Using shell reserved names (`PATH`, `HOME`) â†' variable collision; lowercase globals â†' confusion with locals.

**Ref:** BCS0203
