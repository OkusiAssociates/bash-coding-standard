# Error Handling

**Consolidated section covering automatic error detection, exit codes, traps, return checking, and safe error suppression.**

**Core mandate:** `set -euo pipefail` plus `shopt -s inherit_errexit` before any commands. Catches undefined variables, pipeline failures, command errors. Configure at line 4 after description comment.

**Exit codes:** 0=success, 1=general error, 2=misuse, 5=IO error, 22=invalid argument, 126=not executable, 127=not found, 128+N=signal N, 130=Ctrl-C.

**Traps:** Use `trap cleanup_function EXIT ERR` for guaranteed cleanup (temp files, locks). EXIT runs on normal/error exit. ERR runs on command failure. Place after `set -e` declaration.

**Return checking:** Test commands explicitly when needed: `if ! command; then error 'Failed'; fi` or `command || die 'Failed'`. Never ignore return codes silently.

**Safe suppression:** Three patterns:
- `|| true` - Ignore specific failure
- `|| :` - Same (`:` is no-op builtin)
- `if command; then ...; fi` - Conditional without error

**Arithmetic safety:** Use `i+=1` not `((i++))` - postfix returns original value, fails with `set -e` when i=0.

**Critical:** Error handling must be first executable code (after shebang/comments). Prevents silent failures during initialization.

**Ref:** BCS0800
