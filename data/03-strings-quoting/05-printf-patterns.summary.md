### printf Patterns

**Rule: BCS0305** (From BCS0409)

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

#### Format Specifiers

`%s` string | `%d` decimal | `%f` float | `%x` hex | `%%` literal %

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

#fin
