# Security Considerations

**Security-first practices covering SUID/SGID prohibition, PATH lockdown, IFS safety, eval avoidance, and input sanitization.**

## Core Rules

- **Never SUID/SGID** on bash scripts â†' inherent privilege escalation risk
- **Lock PATH**: `PATH='/usr/local/bin:/usr/bin:/bin'` or validate explicitly
- **IFS safety**: Reset to default `$' \t\n'` before word-splitting operations
- **Avoid eval**: Injection risk; require explicit justification if unavoidable
- **Sanitize input early**: Validate/clean user input at entry points

## Rationale

1. Bash scripts ignore SUID bit but SGID still exploitable via environment manipulation
2. Unvalidated PATH enables command hijacking via malicious executables
3. Modified IFS causes unexpected word-splitting in `read`, loops, command substitution

## Example

```bash
#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
readonly INPUT="${1:-}"
[[ "$INPUT" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "Invalid input" >&2; exit 1; }
```

## Anti-Patterns

- `eval "$user_input"` â†' command injection
- Trusting inherited PATH/IFS â†' environment-based attacks

**Ref:** BCS1000
