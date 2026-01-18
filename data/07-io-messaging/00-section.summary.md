# Input/Output & Messaging

Standardized messaging patterns with color support for terminal output and proper stream handling.

## Messaging Suite

| Function | Purpose |
|----------|---------|
| `_msg()` | Core function using FUNCNAME |
| `vecho()` | Verbose output |
| `success()` | Success messages |
| `warn()` | Warnings |
| `info()` | Informational |
| `debug()` | Debug output |
| `error()` | Unconditional error to stderr |
| `die()` | Exit with error |
| `yn()` | Yes/no prompts |

## Stream Separation

- **STDOUT**: Data output
- **STDERR**: Diagnostics, errors, messaging

## Key Rules

- Error output must always go to STDERR
- Place `>&2` at beginning of commands for clarity
- Use messaging functions over bare echo for consistency
