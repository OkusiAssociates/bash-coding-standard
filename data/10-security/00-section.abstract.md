# Security Considerations

**Prevent privilege escalation, command injection, and input attacks through PATH control, eval avoidance, and input sanitization.**

## Core Rules

- **No SUID/SGID**: Never set on bash scripts (security risk)
- **PATH**: Lock down or validate explicitly; prevent command hijacking
- **IFS**: Reset to default (`$' \t\n'`) to prevent word-splitting exploits
- **eval**: Avoid; if unavoidable, document justification and sanitize all inputs
- **Input**: Validate/sanitize user input at entry point

## Minimal Pattern

```bash
readonly PATH='/usr/local/bin:/usr/bin:/bin'
IFS=$' \t\n'
[[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid input"
```

## Anti-Patterns

- `eval "$user_input"` → injection vector
- Unvalidated PATH → command hijacking

**Ref:** BCS1000
