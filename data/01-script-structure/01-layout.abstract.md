## Script Layout

**All scripts follow 13-step bottom-up structure: infrastructure â†' implementation â†' orchestration.**

### Rationale
1. **Safe initialization** - `set -euo pipefail` runs before any commands
2. **Dependency resolution** - functions defined before they're called
3. **Predictability** - components always in same location

### The 13 Steps

| # | Element | Required |
|---|---------|----------|
| 1 | `#!/bin/bash` | âœ“ |
| 2 | `#shellcheck` directives | opt |
| 3 | Brief description | opt |
| 4 | `set -euo pipefail` | âœ“ |
| 5 | `shopt -s inherit_errexit extglob nullglob` | rec |
| 6 | Metadata: `VERSION`, `SCRIPT_PATH/DIR/NAME` | rec |
| 7 | Global declarations (`declare -i/-a/-A/--`) | rec |
| 8 | Color definitions (if terminal) | opt |
| 9 | Utility functions (messaging) | rec |
| 10 | Business logic functions | rec |
| 11 | `main()` with arg parsing | rec |
| 12 | `main "$@"` | rec |
| 13 | `#fin` or `#end` | âœ“ |

### Minimal Example

```bash
#!/bin/bash
set -euo pipefail
declare -r VERSION=1.0.0
declare -i VERBOSE=0

info() { ((VERBOSE)) && >&2 echo "â—‰ $*"; }
die() { (($#<2)) || >&2 echo "âœ— ${@:2}"; exit "${1:-1}"; }

main() {
  while (($#)); do case $1 in -v) VERBOSE=1;; *) break;; esac; shift; done
  info "Running..."
}
main "$@"
#fin
```

### Anti-Patterns
- **Missing `set -euo pipefail`** â†' errors silently ignored
- **Business logic before utilities** â†' undefined function calls

**Ref:** BCS0101
