### Library Patterns

**Create reusable libraries with source guards, namespacing, and explicit exports.**

---

#### Key Points

- Source guard prevents execution: `[[ "${BASH_SOURCE[0]}" != "$0" ]] || exit 1`
- Export functions with `declare -fx func_name`
- Namespace all functions: `myapp_init()`, `myapp_cleanup()`
- Configurable defaults: `: "${CONFIG_DIR:=/etc/myapp}"`

---

#### Library Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Namespaced library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: Must be sourced, not executed'
  exit 1
}

declare -rx LIB_MYAPP_VERSION=1.0.0

myapp_init() { :; }
myapp_process() { local -- input=$1; echo "$input"; }

declare -fx myapp_init myapp_process
#fin
```

#### Sourcing Libraries

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR/lib-utils.sh"

# With existence check
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing ${lib_path@Q}"
```

---

#### Anti-Patterns

- `source lib.sh` with immediate side effects â†' Correct: define functions only, call `lib_init` explicitly

---

**Ref:** BCS0407
