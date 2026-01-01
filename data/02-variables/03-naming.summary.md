## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case with underscores | `local file_count=0` |
|  | CamelCase acceptable for important locals | `local ConfigData` |
| Internal/private functions | prefix with _ | `_validate_input()` |
| Environment variables | UPPER_CASE with underscores | `export DATABASE_URL` |

```bash
# Constants
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_CONNECTIONS=100

# Global variables
declare -i VERBOSE=1
declare -- ConfigFile=/etc/myapp.conf

# Local variables
process_data() {
  local -i line_count=0
  local -- temp_file
  local -- CurrentSection  # CamelCase for important variable
}

# Private functions
_internal_helper() {
  # Used only by other functions in this script
}
```

**Rationale:** UPPER_CASE for globals/constants indicates script-wide scope; lower_case for locals prevents accidental shadowing; underscore prefix for private functions signals internal use. Avoid single-letter lowercase names (reserved for shell) and built-in variable names (`PATH`, `HOME`, `USER`).
