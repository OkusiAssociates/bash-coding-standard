### Library Patterns

**Rule: BCS0607** (New)

Patterns for creating reusable Bash libraries.

---

#### Rationale

Well-designed libraries provide:
- Code reuse across multiple scripts
- Consistent behavior and interface
- Easier testing and maintenance
- Namespace isolation

---

#### Pure Function Library

```bash
#!/usr/bin/env bash
# lib-validation.sh - Validation function library
#
# Usage: source lib-validation.sh

# Prevent execution
[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
  >&2 echo 'Error: This file must be sourced, not executed'
  exit 1
}

# Library version
declare -rx LIB_VALIDATION_VERSION=1.0.0

# Validation functions
valid_ip4() {
  local -- ip=$1
  [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || return 1
  local -a octets
  IFS='.' read -ra octets <<< "$ip"
  for octet in "${octets[@]}"; do
    ((octet <= 255)) || return 1
  done
  return 0
}
declare -fx valid_ip4

valid_email() {
  local -- email=$1
  [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
declare -fx valid_email

#fin
```

#### Library with Configuration

```bash
#!/usr/bin/env bash
# lib-config.sh - Configuration management library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || return 1

# Configurable defaults (can be overridden before sourcing)
: "${CONFIG_DIR:=/etc/myapp}"
: "${CONFIG_FILE:=$CONFIG_DIR/config}"

load_config() {
  [[ -f "$CONFIG_FILE" ]] || return 1
  source "$CONFIG_FILE"
}
declare -fx load_config

get_config() {
  local -- key=$1 default=${2:-}
  local -- value
  value=$(grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2-)
  echo "${value:-$default}"
}
declare -fx get_config

#fin
```

#### Namespace Pattern

```bash
#!/usr/bin/env bash
# lib-myapp.sh - Namespaced library

[[ "${BASH_SOURCE[0]}" != "$0" ]] || exit 1

# All functions prefixed with namespace
myapp_init() { :; }
myapp_cleanup() { :; }
myapp_process() { :; }

declare -fx myapp_init myapp_cleanup myapp_process

#fin
```

#### Sourcing Libraries

```bash
# Source with path resolution
SCRIPT_DIR=${BASH_SOURCE[0]%/*}
source "$SCRIPT_DIR/lib-validation.sh"

# Source with existence check
lib_path='/usr/local/lib/myapp/lib-utils.sh'
[[ -f "$lib_path" ]] && source "$lib_path" || die 1 "Missing library ${lib_path@Q}"

# Source multiple libraries
for lib in "$LIB_DIR"/*.sh; do
  [[ -f "$lib" ]] && source "$lib"
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - library has side effects on source
source lib.sh  # Immediately modifies global state

# ✓ Correct - library only defines functions
source lib.sh  # Only defines functions
lib_init       # Explicit initialization call
```

---

**See Also:** BCS0606 (Dual-Purpose Scripts), BCS0608 (Dependency Management)

**Full implementation:** See `examples/exemplar-code/internetip/validip`
