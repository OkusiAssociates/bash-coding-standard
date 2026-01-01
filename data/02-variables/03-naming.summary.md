## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Constants | UPPER_CASE | `readonly MAX_RETRIES=3` |
| Global variables | UPPER_CASE or CamelCase | `VERBOSE=1` or `ConfigFile='/etc/app.conf'` |
| Local variables | lower_case with underscores | `local file_count=0` |
| Internal/private functions | prefix with _ | `_validate_input()` |
| Environment variables | UPPER_CASE with underscores | `export DATABASE_URL` |

**Examples:**
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

**Rationale:**
- UPPER_CASE for globals/constants: Visible as script-wide scope, matches shell conventions
- lower_case for locals: Distinguishes from globals, prevents accidental shadowing
- Underscore prefix for private functions: Signals internal use, prevents namespace conflicts
- Avoid lowercase single-letter names (`a`, `b`, `n`) and shell reserved names (`PATH`, `HOME`, `USER`)
