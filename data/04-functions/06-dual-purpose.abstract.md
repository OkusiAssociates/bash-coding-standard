### Dual-Purpose Scripts

**Scripts that execute directly OR source as libraries, using `BASH_SOURCE[0]` detection.**

#### Pattern

```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "${arg@Q}"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0

set -euo pipefail
main() { my_func "$@"; }
main "$@"
#fin
```

#### Critical Rules

- Define functions BEFORE `set -e` â†' sourcing parent controls error handling
- Export functions: `declare -fx func_name` â†' enables subshell access
- Idempotent init: `[[ -v LIB_VERSION ]] || declare -rx LIB_VERSION=1.0`

#### Anti-Patterns

```bash
# âœ— set -e before source check
set -euo pipefail
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0  # Risky

# âœ— Functions not exported â†' subshell access fails
my_func() { :; }
```

**Ref:** BCS0406
