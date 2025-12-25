### printf Patterns

**Rule: BCS0305**

Single quotes for format strings, double quotes for variable arguments.

---

#### Basic Pattern

```bash
# Format string: single quotes; variables: double-quoted arguments
printf '%s: %d files found\n' "$name" "$count"

# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
printf 'Found %d files in %s\n' "$count" "$dir"
```

#### Format Specifiers

```bash
printf '%s\n' "$string"    # String
printf '%d\n' "$integer"   # Decimal
printf '%f\n' "$float"     # Float
printf '%x\n' "$hex"       # Hexadecimal
printf '%%\n'              # Literal %
```

#### Prefer printf Over echo -e

```bash
# ✗ echo -e behavior varies across systems
echo -e "Line1\nLine2"

# ✓ printf is consistent
printf 'Line1\nLine2\n'

# ✓ Or $'...' for escape sequences
echo $'Line1\nLine2'
```

#fin
