### Dual-Purpose Scripts

**BCS0606: Scripts usable as both executable and sourceable library.**

**Core Pattern:**
```bash
#!/usr/bin/env bash
my_func() { local -- arg=$1; echo "$arg"; }
declare -fx my_func

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail
main() { my_func "$@"; }
main "$@"
#fin
```

**Critical:** `set -e` AFTER source checkâ€”library shouldn't impose error handling on caller.

**Idempotent Init:** `[[ -v MY_LIB_VERSION ]] || declare -rx MY_LIB_VERSION='1.0.0'`

**Anti-pattern:** `my_func() { :; }` without `declare -fx` â†' can't call from subshells after sourcing.

**Ref:** BCS0606
