### Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no parsing, `$` `\` `` ` `` literal
- **Double quotes**: Variable expansion required
- **Mixed**: `"Option '$1' invalid"` â€” literal display with variable
- **One-word exception**: Simple alphanumeric (`a-zA-Z0-9_-.`) may be unquoted

```bash
info 'Static message'           # Single: no expansion
info "Found $count files"       # Double: expansion needed
die 1 "Unknown option '$1'"     # Mixed: literal quotes shown
STATUS=success                  # Unquoted: simple alphanumeric
EMAIL='user@domain.com'         # Quoted: special char @
```

#### Path Concatenation

Prefer separate quoting for clarity:
```bash
"$PREFIX"/bin                   # Variable quoted separately
"$dir"/"$file"                  # Clear variable boundaries
```

#### Anti-Patterns

- `info "Static..."` â†' `info 'Static...'` (use single for static)
- `EMAIL=user@domain.com` â†' `EMAIL='user@domain.com'` (quote special chars)
- `PATTERN=*.log` â†' `PATTERN='*.log'` (quote globs)

**Ref:** BCS0301
