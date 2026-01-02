### Quoting Fundamentals

**Rule: BCS0301** (Merged from BCS0401 + BCS0402 + BCS0403 + BCS0404)

Core quoting rules for strings, variables, and literals.

---

#### The Fundamental Rule

**Single quotes** for static strings, **double quotes** when variable expansion needed.

```bash
# ✓ Correct - single quotes for static
info 'Checking prerequisites...'
error 'Failed to connect'
[[ "$status" == 'success' ]]

# ✓ Correct - double quotes for variables
info "Found $count files"
die 1 "File '$SCRIPT_DIR/testfile' not found"
echo "$SCRIPT_NAME $VERSION"
```

---

#### Why Single Quotes for Static Strings

1. **Performance**: Slightly faster (no variable/escape parsing)
2. **Clarity**: Signals "this is literal, no substitution"
3. **Safety**: Prevents accidental expansion
4. **No escaping**: `$`, `` ` ``, `\` are literal

```bash
# Single quotes preserve special characters
msg='The variable $PATH will not expand'
sql='SELECT * FROM users WHERE name = "John"'
regex='^\$[0-9]+\.[0-9]{2}$'
```

---

#### Mixed Quoting Pattern

Nest single quotes inside double quotes for literal display:

```bash
# Variable with visible quotes around value
die 1 "Unknown option '$1'"
warn "Cannot access '$file_path'"
error "Permission denied for '$dir'"
```

---

#### One-Word Literal Exception

Simple alphanumeric values (containing only `a-zA-Z0-9_-./`) may be unquoted:

```bash
# ✓ Acceptable and Standard
STATUS=success
VERSION=1.0.0
[[ "$level" == INFO ]]

# ✓ Acceptable
STATUS='success'
VERSION='1.0.0'
[[ "$level" == 'INFO' ]]
```

**Mandatory quoting required for:**
- Spaces: `'File not found'`
- Special characters: `'user@domain.com'`, `'*.txt'`
- Empty strings: `''`
- Values with `$`, quotes, backslashes

---

#### Anti-Patterns

```bash
# ✗ Wrong - double quotes for static strings
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == active ]]
```

```bash
# ✗ Wrong - special characters unquoted
EMAIL=user@domain.com
PATTERN=*.log

# ✓ Correct
EMAIL='user@domain.com'
PATTERN='*.log'
```

---

#### Path Concatenation Quoting

When concatenating variables with literal paths, quote the variable portion separately from the literal:

```bash
# ✓ RECOMMENDED - separate quoting for clarity
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
cat "$dir"/"$file"
[[ -f "$CONFIG_DIR"/hosts.conf ]]
install -m 755 "$TEMP_DIR"/"$file" "$INSTALL_DIR"/"$file"

# ACCEPTABLE - variable and literal combined
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
cat "$dir/$file"
```

**Rationale:**
- Makes variable boundaries visually explicit
- Improves readability when paths have multiple variables
- Consistent with how shell parses (variable ends at unquoted character)

**Note:** Both forms work correctly. The separate quoting is a style preference that improves clarity, especially in complex paths.

---

#### Quick Reference

| Content | Quote Type | Example |
|---------|------------|---------|
| Static text | Single | `'Processing...'` |
| With variable | Double | `"Found $count files"` |
| Variable in quotes | Mixed | `"Option '$1' invalid"` |
| One-word literal | Optional | `STATUS=success` or `STATUS='success'` |
| Special chars | Single | `'user@example.com'` |
| Empty string | Single | `VAR=''` |
| Path with separator | Separate | `"$var"/path` |

**Key principle:** Use single quotes as the default. Switch to double quotes only when expansion is needed.
