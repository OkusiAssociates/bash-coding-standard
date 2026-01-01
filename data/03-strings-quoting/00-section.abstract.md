# Strings & Quoting

**Single quotes for static strings; double quotes when variable expansion needed.**

## 7 Rules

| Code | Rule |
|------|------|
| BCS0301 | Quoting Fundamentals - static vs dynamic |
| BCS0302 | Command Substitution - quote `$(...)` |
| BCS0303 | Conditionals - quote vars in `[[ ]]` |
| BCS0304 | Here Documents - delimiter quoting |
| BCS0305 | printf - format string quoting |
| BCS0306 | Parameter Quoting - `${param@Q}` |
| BCS0307 | Anti-Patterns - common mistakes |

## Core Pattern

```bash
info 'Static message'           # Single quotes
info "Processing $file"         # Double quotes for vars
[[ -f "$path" ]]               # Always quote in conditionals
```

## Anti-Patterns

`echo $var` â†' `echo "$var"` (unquoted expansion)
`info "Literal text"` â†' `info 'Literal text'` (wrong quote type)

**Ref:** BCS0300
