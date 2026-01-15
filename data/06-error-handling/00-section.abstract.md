# Error Handling

**Mandate `set -euo pipefail` + `shopt -s inherit_errexit` before any commands for automatic error detection.**

## Exit Codes
`0`=success, `1`=general, `2`=misuse, `5`=IO, `22`=invalid arg

## Core Pattern
```bash
set -euo pipefail
shopt -s inherit_errexit
trap 'cleanup' EXIT
```

## Error Suppression
Use `|| true` or `|| :` for intentional failures. Prefer conditionals over suppression.

## Anti-patterns
- ✗ Error handling after commands �' ✓ Configure first
- ✗ Unchecked return values �' ✓ Check or use `||`

**Ref:** BCS0600
