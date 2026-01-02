### Command Substitution

**Rule: BCS0302** (From BCS0405)

Quoting rules for command substitution.

---

#### Rule

Use double quotes when strings include command substitution:

```bash
# ✓ Correct - double quotes for command substitution
echo "Current time: $(date +%T)"
info "Found $(wc -l < "$file") lines"
```

When assigning variables, double quotes around the value are only required if there is concatenation of values in the string:

```
# ✓ Correct - double quotes for command substitution
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')
TIMESTAMP=$(date -Ins)
BASEDIR=$PREFIX

# ✗ Wrong - unnecessary double quotes
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
TIMESTAMP="$(date -Ins)"
BASEDIR="$PREFIX"

# ✓ Correct - double quotes for command substitution
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')".beta
TIMESTAMP="$(date -Ins)"-Jakarta
BASEDIR="$PREFIX"/config
```

---

#### Always Quote the Result

```bash
# ✓ Correct - quoted result
result=$(command)
echo "$result"

# ✗ Wrong - unquoted result
echo $result    # Word splitting occurs!
```

---

**Key principle:** Command substitution results should always be quoted to preserve whitespace and prevent word splitting.
