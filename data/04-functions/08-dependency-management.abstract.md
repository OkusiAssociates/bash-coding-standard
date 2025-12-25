### Dependency Management

**Use `command -v` for dependency checks; provide helpful error messages for missing tools.**

#### Core Pattern

```bash
# Single check
command -v curl >/dev/null || die 1 'curl required'

# Multiple with collection
check_dependencies() {
  local -a missing=()
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
  done
  ((${#missing[@]})) && { error "Missing: ${missing[*]}"; return 1; }
}
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1
((HAS_JQ)) && result=$(jq -r '.field' <<<"$json")
```

#### Version Check

```bash
check_bash_version() {
  ((BASH_VERSINFO[0] < 5)) && die 1 "Requires Bash 5.2+"
}
```

#### Anti-Patterns

- `which curl` â†' `command -v curl` (which is non-POSIX, unreliable)
- Silent failures â†' Explicit check with install hints

**Ref:** BCS0608
