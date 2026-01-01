### Dependency Management

**Use `command -v` for dependency checks; provide clear errors for missing tools; support graceful degradation with availability flags.**

#### Core Rationale
- Clear errors vs cryptic failures from missing tools
- Enables optional dependency fallbacks
- Documents requirements explicitly

#### Pattern

```bash
# Required dependencies
for cmd in curl jq; do
  command -v "$cmd" >/dev/null || die 1 "Required: $cmd"
done

# Optional with fallback
declare -i HAS_JQ=0
command -v jq >/dev/null && HAS_JQ=1 ||:
((HAS_JQ)) && jq -r '.f' <<< "$json" || grep -oP '"f":"\K[^"]+'
```

#### Anti-Patterns

`which curl` â†' `command -v curl` (POSIX compliant)

Silent `curl "$url"` â†' explicit check first with helpful install message

**Ref:** BCS0408
