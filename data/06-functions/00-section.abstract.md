# Functions

**Use lowercase_with_underscores naming; require `main()` for scripts >200 lines; organize bottom-up (messaging’helpers’business logic’main).**

**Rationale:** Bottom-up organization ensures dependencies exist before use; `main()` enables testing/sourcing without execution; consistent naming improves readability.

**Pattern:**
```bash
#!/usr/bin/env bash
set -euo pipefail

_msg() { local lvl=$1; shift; >&2 echo "[$lvl] $*"; }
error() { _msg ERROR "$@"; }
die() { error "$@"; exit 1; }

process_file() {
  local file=$1
  [[ -f "$file" ]] || die "File not found: $file"
  # business logic
}

main() {
  process_file "$1"
}

main "$@"
#fin
```

**Export for libraries:** `declare -fx function_name` after definition.

**Production optimization:** Remove unused utility functions once scripts mature.

**Anti-patterns:** `function` keyword (omit it); top-down organization; missing `main()` in large scripts.

**Ref:** BCS0600
