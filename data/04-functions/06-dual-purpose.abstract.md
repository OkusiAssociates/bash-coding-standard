### Dual-Purpose Scripts

**Scripts that execute directly OR source as libraries via `BASH_SOURCE[0]` detection.**

#### Key Points
- Functions before `set -e`; `set -e` AFTER source check (library shouldn't impose error handling)
- Use `declare -fx` to export functions for subshells
- Idempotent init: `[[ -v LIB_VERSION ]] || declare -rx LIB_VERSION=...`

#### Pattern

```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "${arg@Q}"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail

main() { my_func "$@"; }
main "$@"
```

#### Anti-Patterns
- `set -e` before source check → risky `return 0`
- Missing `declare -fx` → functions unavailable in subshells

**See Also:** BCS0607, BCS0604

**Ref:** BCS0406
