### Library Patterns

**Rule:** Create sourced-only libraries with namespace prefixes and no side effects.

**Rationale:** Code reuse, consistent interfaces, testability, namespace isolation.

#### Core Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Must be sourced
[[ "${BASH_SOURCE[0]}" != "$0" ]] || { >&2 echo 'Must be sourced'; exit 1; }

declare -rx LIB_MYAPP_VERSION=1.0.0

myapp_validate() { [[ $1 =~ ^[0-9]+$ ]]; }
declare -fx myapp_validate
```

#### Sourcing

```bash
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR"/lib-myapp.sh
[[ -f "$lib" ]] && source "$lib" || die 1 "Missing ${lib@Q}"
```

#### Configurable Defaults

```bash
: "${CONFIG_DIR:=/etc/myapp}"  # Override before sourcing
```

#### Anti-Patterns

- `source lib.sh` that modifies global state → require explicit `lib_init` call
- Unprefixed functions → always use `libname_funcname` pattern

**See Also:** BCS0606, BCS0608

**Ref:** BCS0407
