## Layout Anti-Patterns

**Avoid these 8 critical violations of the 13-step layout pattern.**

### Critical Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Missing `set -euo pipefail` | Silent failures, corruption | Always first after shebang |
| Variables after use | Unbound variable errors with `-u` | Declare all globals before functions |
| Business logic before utilities | Forward references, poor readability | Utilities → business logic → main |
| No `main()` in large scripts | Untestable, scattered args | Use `main()` for 200+ lines |
| Missing `#fin` | Can't detect truncation | Always end with `#fin` |
| Premature `readonly` | Can't modify during arg parsing | `readonly` after parsing complete |
| Scattered declarations | Hard to track state | Group all globals together |
| Unprotected sourcing | Modifies caller's shell | Guard with `[[ "${BASH_SOURCE[0]}" == "$0" ]]` |

### Correct Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -r VERSION=1.0.0
declare -- PREFIX=/usr/local  # mutable until parsed

die() { (($#<2)) || >&2 echo "ERROR: ${*:2}"; exit "${1:-0}"; }

main() {
  while (($#)); do case $1 in --prefix) shift; PREFIX=$1 ;; esac; shift; done
  readonly -- PREFIX
}

main "$@"
#fin
```

**Ref:** BCS010102
