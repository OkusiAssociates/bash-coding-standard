### Dependency Management

**Rule: BCS0608** (New)

Checking and managing external dependencies in Bash scripts.

---

#### Rationale

Proper dependency management:
- Provides clear error messages for missing tools
- Enables graceful degradation
- Documents script requirements
- Supports portability checking

---

#### Basic Dependency Check

```bash
# Check single command
command -v curl >/dev/null || die 1 'curl is required but not installed'

# Check multiple commands
for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required ${cmd@Q}"
done
```

#### Dependency Check Function

```bash
check_dependencies() {
  local -a missing=()
  local -- cmd

  for cmd in "$@"; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
  done

  if ((${#missing[@]})); then
    error "Missing dependencies: ${missing[*]}"
    info 'Install with: sudo apt install ...'
    return 1
  fi
}

# Usage
check_dependencies curl jq sqlite3 || exit 1
```

#### Optional Dependencies

```bash
# Check and set availability flag
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:

# Use with fallback
if ((HAS_JQ)); then
  result=$(echo "$json" | jq -r '.field')
else
  result=$(echo "$json" | grep -oP '"field":\s*"\K[^"]+')
fi
```

#### Version Checking

```bash
check_bash_version() {
  local -i major=${BASH_VERSINFO[0]}
  local -i minor=${BASH_VERSINFO[1]}

  if ((major < 5 || (major == 5 && minor < 2))); then
    die 1 "Requires Bash 5.2+, found $BASH_VERSION"
  fi
}

check_tool_version() {
  local -- tool=$1 min_version=$2
  local -- current_version

  current_version=$("$tool" --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+')

  if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -1)" != "$min_version" ]]; then
    die 1 "$tool version $min_version+ required, found $current_version"
  fi
}
```

#### Lazy Loading

```bash
# Initialize expensive resources only when needed
declare -- SQLITE_DB=''

get_db() {
  if [[ -z "$SQLITE_DB" ]]; then
    command -v sqlite3 >/dev/null || die 1 'sqlite3 required'
    SQLITE_DB=$(mktemp)
    sqlite3 "$SQLITE_DB" 'CREATE TABLE cache (key TEXT, value TEXT)'
  fi
  echo "$SQLITE_DB"
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - using which (not POSIX, unreliable)
which curl >/dev/null

# ✓ Correct - use command -v (POSIX compliant)
command -v curl >/dev/null
```

```bash
# ✗ Wrong - silent failure on missing dependency
curl "$url"  # Cryptic error if curl missing

# ✓ Correct - explicit check with helpful message
command -v curl >/dev/null || die 1 'curl required: apt install curl'
curl "$url"
```

---

**See Also:** BCS0607 (Library Patterns)

#fin
