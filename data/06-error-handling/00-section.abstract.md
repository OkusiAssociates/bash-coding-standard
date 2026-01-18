# Error Handling

**Configure `set -euo pipefail` with `shopt -s inherit_errexit` before any commands to catch failures early.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures; prefer conditional checks over blanket suppression.

## Anti-patterns
- ✗ Missing `set -e` → silent failures propagate
- ✗ `set -e` after other commands → early errors missed

**Ref:** BCS0600
