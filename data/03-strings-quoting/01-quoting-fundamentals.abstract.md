### Quoting Fundamentals

**Single quotes for static strings; double quotes only when variable expansion needed.**

#### Core Rules

- **Single quotes**: Static text, no expansion â†' `info 'Processing...'`
- **Double quotes**: Variables needed â†' `info "Found $count files"`
- **Mixed**: Literal quotes around values â†' `die 1 "Unknown option '$1'"`

#### Why Single Quotes Default

1. **Safety**: Prevents accidental `$`, `` ` ``, `\` expansion
2. **Clarity**: Signals "no substitution here"
3. **Performance**: No parsing overhead

#### Path Concatenation

```bash
# âœ“ Recommended - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"

# âœ— Avoid - combined quoting
"$PREFIX/bin"
```

#### One-Word Exception

Simple alphanumeric (`a-zA-Z0-9_-./`) may be unquoted: `STATUS=success`

**Mandatory quotes for:** spaces, `@`, `*`, `$`, empty strings `''`

#### Anti-Patterns

```bash
# âœ— Double quotes for static
info "Checking prerequisites..."
â†' info 'Checking prerequisites...'

# âœ— Special chars unquoted
EMAIL=user@domain.com
â†' EMAIL='user@domain.com'
```

**Ref:** BCS0301
