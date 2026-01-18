## Development Practices

**ShellCheck is compulsory; end scripts with `#fin`; program defensively.**

### Core Requirements

1. **ShellCheck**: Run `shellcheck -x` on all scripts; disable only with documented reason
2. **Termination**: End with `main "$@"` then `#fin` marker
3. **Defensive**: Use `set -u`, validate inputs early, provide defaults

### Rationale
- ShellCheck catches 80%+ common bugs automatically
- Markers enable tooling to verify complete scripts

### Example
```bash
#!/usr/bin/env bash
set -euo pipefail
: "${VERBOSE:=0}"
[[ -n "${1:-}" ]] || { echo "Arg required" >&2; exit 1; }
main "$@"
#fin
```

### Anti-patterns
- `#shellcheck disable` without comment → unexplained exceptions
- Missing `set -u` → silent failures from typos

**Ref:** BCS1206
