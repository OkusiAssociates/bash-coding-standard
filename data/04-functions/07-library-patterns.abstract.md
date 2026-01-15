### Library Patterns

**Rule: BCS0407**

**Libraries must prevent direct execution and define functions without side effects.**

#### Rationale
- Code reuse across scripts with consistent interfaces
- Namespace isolation prevents function collisions
- Easier testing via explicit initialization

#### Pattern

```bash
#!/usr/bin/env bash
# lib-validation.sh - Source only

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: Must be sourced, not executed'; exit 1
}

declare -rx LIB_VALIDATION_VERSION=1.0.0

valid_email() {
  [[ $1 =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
declare -fx valid_email
```

#### Sourcing

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR"/lib-validation.sh

# With check
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing ${lib_path@Q}"
```

#### Anti-Patterns

- `source lib.sh` with immediate side effects â†' Define functions only, use `lib_init` for initialization
- Unprefixed functions â†' Use namespace prefix: `myapp_init`, `myapp_cleanup`

**Ref:** BCS0407
