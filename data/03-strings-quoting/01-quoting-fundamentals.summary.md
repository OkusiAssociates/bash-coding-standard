### Quoting Fundamentals

**Rule: BCS0301**

Core quoting rules for strings, variables, and literals.

---

#### The Fundamental Rule

**Single quotes** for static strings, **double quotes** when variable expansion needed.

```bash
# ✓ Single quotes for static
info 'Checking prerequisites...'
[[ "$status" == 'success' ]]

# ✓ Double quotes for variables
info "Found $count files"
die 1 "File '$SCRIPT_DIR/testfile' not found"
```

---

#### Why Single Quotes for Static Strings

1. **Performance**: No variable/escape parsing
2. **Clarity**: Signals literal content
3. **Safety**: Prevents accidental expansion
4. **No escaping**: `$`, `` ` ``, `\` are literal

```bash
msg='The variable $PATH will not expand'
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
# ✓ Acceptable
STATUS=success
[[ "$level" == INFO ]]

# ✓ Recommended - quote for consistency
STATUS='success'
[[ "$level" == 'INFO' ]]
```

**Mandatory quoting:** Spaces, special characters (`@`, `*`), empty strings (`''`), values with `$`/quotes/backslashes.

---

#### Anti-Patterns

```bash
# ✗ Wrong - double quotes for static
info "Checking prerequisites..."
[[ "$status" == "active" ]]

# ✓ Correct
info 'Checking prerequisites...'
[[ "$status" == 'active' ]]

# ✗ Wrong - special chars unquoted
EMAIL=user@domain.com
PATTERN=*.log

# ✓ Correct
EMAIL='user@domain.com'
PATTERN='*.log'
```

---

#### Path Concatenation Quoting

Quote variable portions separately from literals:

```bash
# ✓ RECOMMENDED - separate quoting
"$PREFIX"/bin
"$SCRIPT_DIR"/data/"$filename"
[[ -f "$CONFIG_DIR"/hosts.conf ]]

# ACCEPTABLE - combined
"$PREFIX/bin"
"$SCRIPT_DIR/data/$filename"
```

**Rationale:** Makes variable boundaries explicit, improves readability in complex paths.

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

**Key principle:** Single quotes as default; double quotes only when expansion needed.

#fin
