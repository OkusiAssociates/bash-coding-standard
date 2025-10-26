## Static Strings and Constants

**Always use single quotes for string literals with no variables.**

**Rationale:**
1. **Performance**: Faster (no parsing)
2. **Clarity**: Signals literal string
3. **Safety**: Prevents accidental expansion of `$`, `` ` ``, `\`, `!`

**Core pattern:**

```bash
# Single quotes - static strings
info 'Checking prerequisites...'
DEFAULT_PATH='/usr/local/bin'
[[ "$status" == 'success' ]]

# Double quotes - variables needed
info "Found $count files"
msg="Current time: $(date)"
```

**Anti-patterns:**

```bash
#  Double quotes for static
info "Checking prerequisites..."  # ’ Use single quotes
msg="The cost is \$5.00"          # ’ msg='The cost is $5.00'

#  Variables in single quotes
greeting='Hello, $name'  # Not expanded ’ greeting="Hello, $name"
```

**Rule:** Single quotes `'...'` for all static strings. Double quotes `"..."` only when variables or command substitution needed.

**Ref:** BCS0401
