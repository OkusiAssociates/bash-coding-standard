## Blank Line Usage

**Use single blank lines to visually separate logical blocks.**

**Guidelines:**
- One blank between functions, logical sections, section comments, variable groups
- Blank lines before/after multi-line conditionals/loops
- Never multiple consecutive blanks → one is sufficient
- No blank needed between short related statements

```bash
#!/bin/bash
set -euo pipefail

declare -r VERSION=1.0.0
                                # ← After variable group
check_prerequisites() {
  info 'Checking...'
                                # ← Between logical sections
  if ! command -v gcc &>/dev/null; then
    die 1 "'gcc' not found"
  fi
}
                                # ← Between functions
main() {
  check_prerequisites
}

main "$@"
```

**Anti-patterns:** Multiple consecutive blanks → wastes space, inconsistent separation → harder to scan

**Ref:** BCS1203
