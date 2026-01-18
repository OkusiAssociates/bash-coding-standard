### Quoting Fundamentals

**Single quotes for static strings; double quotes when variable expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: When variables must expand
- **Mixed**: `"Unknown '$1'"` → literal quotes around expanded value
- **Unquoted**: Simple alphanumeric (`a-zA-Z0-9_-.`) allowed: `STATUS=success`

**Mandatory quoting**: spaces, `@`, `*`, empty strings `''`, `$`, quotes, backslashes.

#### Path Concatenation

```bash
# Preferred - explicit boundaries
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"

# Acceptable
"$PREFIX/bin"
```

#### Anti-Patterns

```bash
# ✗ Double quotes for static
info "Processing..."        # → info 'Processing...'
[[ "$x" == "active" ]]      # → [[ "$x" == active ]]

# ✗ Special chars unquoted
EMAIL=user@domain.com       # → EMAIL='user@domain.com'
```

#### Quick Reference

| Content | Quote | Example |
|---------|-------|---------|
| Static | Single | `'text'` |
| Variable | Double | `"$var"` |
| Special chars | Single | `'@*.txt'` |

**Ref:** BCS0301
