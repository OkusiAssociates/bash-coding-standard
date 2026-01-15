# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: STDOUT for data, STDERR for diagnostics.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core messaging (uses FUNCNAME) | varies |
| `error()` | Unconditional errors | STDERR |
| `die()` | Exit with error message | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDOUT |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDOUT |
| `vecho()` | Verbose output | STDOUT |
| `yn()` | Yes/no prompts | STDERR |

## Key Rules

- **STDERR redirect first**: `>&2 echo "error"` â†' NOT `echo "error" >&2`
- Data output â†' STDOUT (pipeable)
- Diagnostics/errors â†' STDERR

## Example

```bash
error() { >&2 echo "ERROR: $*"; }
die()   { error "$@"; exit 1; }
info()  { echo "INFO: $*"; }
```

## Anti-patterns

- `echo "Error" >&2` â†' Use `>&2 echo "Error"` (redirect first)
- Mixing data and diagnostics on same stream

**Ref:** BCS0700
