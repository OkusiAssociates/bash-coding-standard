### printf Patterns

**Rule: BCS0305**

Quoting rules for printf and echo.

---

#### Basic Pattern

```bash
# Format string: single quotes (static)
# Variables: double-quoted as arguments
printf '%s: %d files found\n' "$name" "$count"

# Static strings - single quotes
echo 'Installation complete'
printf '%s\n' 'Processing files'

# With variables - double quotes
echo "$SCRIPT_NAME $VERSION"
printf 'Found %d files in %s\n' "$count" "$dir"
```

---

#### Format String Escapes

```bash
# Common format specifiers
printf '%s\n'   "$string"       # String
printf '%d\n'   "$integer"      # Decimal
printf '%f\n'   "$float"        # Float
printf '%x\n'   "$hex"          # Hexadecimal
printf '%%\n'                   # Literal %
```

---

#### Prefer printf Over echo -e

```bash
# ✗ Avoid - echo -e behavior varies
echo -e "Line1\nLine2"

# ✓ Prefer - printf is consistent
printf 'Line1\nLine2\n'

# Or use $'...' for escape sequences
echo $'Line1\nLine2'
```

---

**Key principle:** Single quotes for format strings, double quotes for variable arguments.
