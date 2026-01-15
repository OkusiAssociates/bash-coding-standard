## Main Function

**Use `main()` for scripts >200 lines as single entry point; place `main "$@"` at bottom before `#fin`.**

**Rationale:** Single entry point for testability; functions can be sourced without execution; centralized exit code handling.

**When to use:** >200 lines, multiple functions, argument parsing, complex logic. Skip for trivial scripts <200 lines.

**Structure:**
```bash
#!/bin/bash
set -euo pipefail

helper_function() { : ...; }

main() {
  local -i verbose=0
  while (($#)); do case $1 in
    -v) verbose=1 ;; -h) show_help; return 0 ;;
    *) die 22 "Invalid: ${1@Q}" ;;
  esac; shift; done
  readonly -- verbose
  return 0
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
main "$@"
#fin
```

**Anti-patterns:**
- `main` without `"$@"` â†' args not passed
- Parsing args outside main â†' consumed before main runs
- Functions defined after `main "$@"` â†' not available during execution

**Ref:** BCS0403
