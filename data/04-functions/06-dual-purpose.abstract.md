### Dual-Purpose Scripts

**Rule:** Scripts executable directly OR sourceable as libraries using `BASH_SOURCE[0]` check.

**Key:** `set -e` MUST come AFTER source checkâ€”library code must not impose error handling on caller.

**Rationale:** Reusable functions without duplication; testing flexibility (source functions independently).

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

**Idempotent:** Use `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION=1.0.0` to prevent double-init.

#### Anti-Patterns

`my_func() { :; }` without `declare -fx` â†' cannot call from subshells after sourcing.

`set -euo pipefail` before source check â†' risky `return 0` behavior.

**See Also:** BCS0607 (Library Patterns), BCS0604 (Function Export)

**Ref:** BCS0406
