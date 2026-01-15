### Layout Anti-Patterns

**Avoid these 8 critical violations of BCS0101 13-step layout to prevent silent failures and unmaintainable code.**

#### Critical Anti-Patterns

| Anti-Pattern | Consequence |
|--------------|-------------|
| Missing `set -euo pipefail` | Silent failures, corrupt operations |
| Variables used before declaration | "Unbound variable" errors with `set -u` |
| Business logic before utilities | Forward references, harder to understand |
| No `main()` in large scripts (200+ lines) | No clear entry point, untestable |
| Missing `#fin` end marker | Cannot detect truncated files |
| `readonly` before argument parsing | Cannot modify config vars |
| Scattered global declarations | State variables hard to track |
| Unprotected sourcing | Modifies caller's shell, auto-runs |

#### Correct Pattern (Minimal)

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # Modified during parsing

die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do case $1 in --prefix) shift; PREFIX=$1 ;; esac; shift; done
  readonly -- PREFIX
}

main "$@"
#fin
```

#### Dual-Purpose Script Guard

```bash
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102
