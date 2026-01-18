# Input/Output & Messaging

**Use standardized messaging functions with proper stream separation: data→STDOUT, diagnostics→STDERR.**

## Core Functions

| Function | Purpose | Stream |
|----------|---------|--------|
| `_msg()` | Core (uses FUNCNAME) | varies |
| `error()` | Errors | STDERR |
| `die()` | Exit with error | STDERR |
| `warn()` | Warnings | STDERR |
| `info()` | Informational | STDERR |
| `debug()` | Debug output | STDERR |
| `success()` | Success messages | STDERR |
| `vecho()` | Verbose output | STDERR |
| `yn()` | Yes/no prompts | STDERR |

## Stream Rules

- **STDOUT**: Script data/results only (pipeable)
- **STDERR**: All diagnostics, prompts, progress
- Place `>&2` at command start: `>&2 echo "error"`

## Example

```bash
error() { >&2 printf '%s\n' "ERROR: $*"; }
die() { error "$@"; exit 1; }
info() { >&2 printf '%s\n' "INFO: $*"; }
```

## Anti-patterns

- `echo "Error"` → `>&2 echo "Error"` (errors must go to STDERR)
- `echo >&2 "msg"` → `>&2 echo "msg"` (redirection at start)

**Ref:** BCS0700
