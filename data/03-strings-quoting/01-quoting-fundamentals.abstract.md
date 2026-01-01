### Quoting Fundamentals

**Single quotes for static strings; double quotes only when expansion needed.**

#### Core Pattern

```bash
info 'Static message'              # Single - no expansion
info "Found $count files"          # Double - variable needed
die 1 "Unknown option '$1'"        # Mixed - literal quotes in output
```

#### Path Concatenation (Recommended)

```bash
"$PREFIX"/bin                      # Separate quoting - clearer boundaries
"$SCRIPT_DIR"/data/"$filename"     # Variable boundaries explicit
```

#### Rationale

1. **Safety**: Single quotes prevent accidental expansion of `$`, backticks
2. **Clarity**: Quote type signals intent (literal vs. expansion)
3. **Path readability**: Separate quoting makes variable boundaries visible

#### Anti-Patterns

```bash
info "Checking..."        # â†' info 'Checking...'     (static = single)
EMAIL=user@domain.com     # â†' EMAIL='user@domain.com' (special chars)
[[ "$x" == "active" ]]    # â†' [[ "$x" == 'active' ]] (literal comparison)
```

#### Quick Rules

- Static text â†' single quotes
- Variables needed â†' double quotes
- Special chars (`@`, `*`, `$`) â†' always quote
- Empty string â†' `''`
- One-word alphanumeric â†' quotes optional but recommended

**Ref:** BCS0301
