### Quoting Fundamentals

**Single quotes for static strings; double quotes only when variable expansion needed.**

#### Core Pattern

```bash
info 'Static message'              # Single - no expansion
info "Found $count files"          # Double - needs $count
die 1 "Unknown option '$1'"        # Mixed - literal quotes around var
```

#### Why Single Quotes Default

- **Performance**: No parsing overhead
- **Safety**: Prevents accidental `$`, `` ` ``, `\` expansion
- **Clarity**: Signals "literal text"

#### Path Concatenation

```bash
# âœ“ Recommended - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
```

#### Anti-Patterns

```bash
# âœ— Double quotes for static â†' info "Processing..."
# âœ“ Single quotes            â†' info 'Processing...'

# âœ— Unquoted special chars   â†' EMAIL=user@domain.com
# âœ“ Quoted                   â†' EMAIL='user@domain.com'
```

#### Quick Rules

| Content | Quote | Example |
|---------|-------|---------|
| Static | Single | `'text'` |
| With var | Double | `"$var"` |
| Special chars | Single | `'@*.txt'` |
| Empty | Single | `''` |

**Ref:** BCS0301
