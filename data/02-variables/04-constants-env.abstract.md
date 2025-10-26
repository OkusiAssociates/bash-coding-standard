## Constants and Environment Variables

**Use `readonly` for immutable values; `declare -x`/`export` for child process variables.**

```bash
# Constants (readonly)
readonly -- VERSION='1.0.0' MAX_RETRIES=3 CONFIG_DIR='/etc/myapp'

# Environment variables (export)
declare -x DATABASE_URL='postgresql://localhost/db' LOG_LEVEL='DEBUG'

# Combined (readonly + export)
declare -rx BUILD_ENV='production'
```

**When to use:**
- `readonly`: Script metadata, config paths, calculated constants (prevents modification)
- `declare -x`/`export`: Values needed by subprocesses, tool config, inherited settings

**Key difference:** readonly prevents changes; export passes to subprocesses.

**Anti-patterns:**
```bash
# ✗ Exporting unnecessary constants
export MAX_RETRIES=3  # Child processes don't need this
# ✓ Only readonly
readonly -- MAX_RETRIES=3

# ✗ Not protecting true constants
CONFIG_FILE='/etc/app.conf'  # Could be modified
# ✓ Make readonly
readonly -- CONFIG_FILE='/etc/app.conf'

# ✗ Making user-configurable readonly too early
readonly -- OUTPUT_DIR="$HOME/output"  # Can't override!
# ✓ Allow override first
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/output}"
readonly -- OUTPUT_DIR
```

**Ref:** BCS0204
