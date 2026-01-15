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
die 1 "Unknown option '$1'"
warn "Cannot access '$file_path'"
```

---

#### One-Word Literal Exception

Simple alphanumeric values (`a-zA-Z0-9_-./`) may be unquoted:

```bash
# ✓ Both acceptable
STATUS=success
[[ "$level" == INFO ]]
STATUS='success'
```

**Mandatory quoting:** Spaces, special chars (`@`, `*`), empty strings, values with `$`/quotes/backslashes.

---

#### Anti-Patterns

```bash
# ✗ Wrong - double quotes for static strings
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]
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

Quote variable portion separately from literal for clarity:

```bash
# ✓ RECOMMENDED - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
[[ -f "$CONFIG_DIR"/hosts.conf ]]

# ACCEPTABLE - combined
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

Separate quoting makes variable boundaries visually explicit and improves readability in complex paths.

---

#### Quick Reference

| Content | Quote Type | Example |
|---------|------------|---------|
| Static text | Single | `'Processing...'` |
| With variable | Double | `"Found $count files"` |
| Variable in quotes | Mixed | `"Option '$1' invalid"` |
| One-word literal | Optional | `STATUS=success` |
| Special chars | Single | `'user@example.com'` |
| Empty string | Single | `VAR=''` |
| Path with separator | Separate | `"$var"/path` |

**Key principle:** Use single quotes as default. Double quotes only when expansion needed.
