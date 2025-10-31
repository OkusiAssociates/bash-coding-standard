# Input/Output & Messaging

**Standardized messaging with proper stream separation and color support.**

STDOUT = data, STDERR = diagnostics. Always prefix error output: `>&2 echo "error"`.

**Core messaging suite:**
- `_msg()` - Core using FUNCNAME for caller name
- `vecho()` - Verbose output (respects VERBOSE flag)
- `success()`, `warn()`, `info()`, `debug()` - Status messages
- `error()` - Unconditional stderr output
- `die()` - Exit with error message
- `yn()` - Yes/no prompts

**Implementation:**
```bash
_msg() { local level=$1 color=$2; shift 2; >&2 echo -e "${color}[${level}]${RESET} ${FUNCNAME[2]}: $*"; }
vecho() { ((VERBOSE)) && echo "$@"; }
success() { _msg SUCCESS "$GREEN" "$@"; }
warn() { _msg WARNING "$YELLOW" "$@"; }
info() { _msg INFO "$CYAN" "$@"; }
error() { _msg ERROR "$RED" "$@"; }
die() { error "$@"; exit "${2:-1}"; }
```

**Anti-patterns:** `echo "error" >&2` ’ use `>&2 echo "error"` (clarity); bare `echo` for diagnostics ’ use messaging functions.

**Ref:** BCS0900
