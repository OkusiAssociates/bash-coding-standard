### Library Patterns

**Rule:** Create reusable libraries with source-only guards, exported functions, and namespace prefixes.

**Rationale:** Code reuse, consistent interfaces, testability, namespace isolation.

---

**Core Pattern:**
```bash
#!/usr/bin/env bash
# lib-myapp.sh - Description
[[ "${BASH_SOURCE[0]}" != "$0" ]] || { echo 'Source only' >&2; exit 1; }
declare -rx LIB_MYAPP_VERSION='1.0.0'

myapp_validate() {
  local -- input=$1
  [[ -n "$input" ]]
}
declare -fx myapp_validate
#fin
```

**Key Elements:**
- Source guard: `[[ "${BASH_SOURCE[0]}" != "$0" ]]`
- Version: `declare -rx LIB_NAME_VERSION`
- Namespace prefix: `libname_function()`
- Export functions: `declare -fx func_name`

**Sourcing:**
```bash
source "$SCRIPT_DIR/lib-myapp.sh"
[[ -f "$lib" ]] && source "$lib" || die 1 "Missing: $lib"
```

**Anti-pattern:** `source lib.sh` with immediate side effects â†' use explicit `lib_init` call.

**Ref:** BCS0607
