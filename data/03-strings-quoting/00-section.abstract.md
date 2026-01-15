# Strings & Quoting

**Single quotes for literals, double quotes for expansion.**

## Rules (7)

| Rule | Purpose |
|------|---------|
| BCS0301 | Quoting fundamentals: static vs dynamic |
| BCS0302 | Quote `$(...)` command substitution |
| BCS0303 | Variable quoting in `[[ ]]` |
| BCS0304 | Heredoc delimiter quoting |
| BCS0305 | printf format/argument quoting |
| BCS0306 | `${param@Q}` safe display |
| BCS0307 | Common quoting anti-patterns |

## Core Pattern

```bash
readonly STATIC='literal text'     # Single: no expansion
msg="Hello, ${name}"               # Double: expansion needed
```

## Key Anti-Patterns

- `$var` â†' `"$var"` (unquoted variables cause word-splitting)
- `echo $@` â†' `echo "$@"` (preserve argument boundaries)

**Ref:** BCS0300
