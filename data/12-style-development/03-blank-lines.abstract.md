## Blank Line Usage

**Use single blank lines to separate logical blocks; never use multiple consecutive blanks.**

### Guidelines

- One blank between functions, logical sections, variable groups
- One blank after section comments
- Blanks before/after multi-line conditionals/loops
- No blank needed between short related statements

### Pattern

```bash
declare -r VERSION=1.0.0
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
                                          # ← After metadata group
# Default values                          # ← Before section comment
declare -- PREFIX=/usr/local
declare -i DRY_RUN=0
                                          # ← Before function
check_prerequisites() {
  info 'Checking...'
                                          # ← Between logical blocks
  if ! command -v gcc &>/dev/null; then
    die 1 'gcc not found'
  fi
}
                                          # ← Between functions
main() {
  check_prerequisites
}
```

### Anti-Patterns

- `✗` Multiple consecutive blank lines �' `✓` Single blank sufficient
- `✗` No separation between unrelated blocks �' `✓` Add visual breaks

**Ref:** BCS1203
