## Blank Line Usage

Use blank lines to create visual separation between logical blocks:

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
                                          # ê Blank line after metadata group

# Default values                          # ê Blank line before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ê Blank line after variable group

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
                                          # ê Blank line before function
check_prerequisites() {
  info 'Checking prerequisites...'

  # Check for gcc                         # ê Blank line after info call
  if ! command -v gcc &> /dev/null; then
    die 1 "'gcc' compiler not found."
  fi

  success 'Prerequisites check passed'    # ê Blank line between checks
}
                                          # ê Blank line between functions
main() {
  check_prerequisites
  install_files
}

main "$@"
#fin
```

**Guidelines:**
- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- One blank line between variable groups
- Blank lines before/after multi-line conditionals or loops
- Avoid multiple consecutive blank lines
- No blank line between short, related statements
