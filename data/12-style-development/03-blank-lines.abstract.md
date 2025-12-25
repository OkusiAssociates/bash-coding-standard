## Blank Line Usage

**Strategic blank lines improve readability by separating logical blocks.**

**Core rules:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between variable groups
- Blank lines before/after multi-line conditionals or loops
- Never use multiple consecutive blank lines
- No blank line between short, related statements

**Minimal example:**

```bash
#!/bin/bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")

PREFIX=/usr/local
DRY_RUN=0

BIN_DIR="$PREFIX"/bin
LIB_DIR="$PREFIX"/lib

check_prerequisites() {
  info 'Checking prerequisites...'

  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'
}

main() {
  check_prerequisites
  install_files
}

main "$@"
#fin
```

**Anti-patterns:**
- `function1() { ... }\nfunction2() { ... }` → No blank line between functions
- Multiple consecutive blank lines → Use single blank line only

**Ref:** BCS1303
