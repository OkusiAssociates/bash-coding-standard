### Dependency Management

**Use `command -v` to verify external dependencies exist before use, with clear error messages.**

#### Rationale
- Clear errors for missing tools vs cryptic failures
- Enables graceful degradation with optional deps
- Documents script requirements explicitly

#### Dependency Check

```bash
# Single/multiple checks
command -v curl >/dev/null || die 1 'curl required'

for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done
```

#### Optional Dependencies

```bash
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && result=$(jq -r '.f' <<<"$json")
```

#### Version Check

```bash
((BASH_VERSINFO[0] < 5)) && die 1 "Requires Bash 5+"
```

#### Anti-Patterns

- `which curl` â†' `command -v curl` (POSIX compliant)
- Silent `curl "$url"` â†' Check first with helpful message

**Ref:** BCS0408
