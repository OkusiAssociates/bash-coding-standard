### Command Substitution

**Rule: BCS0302** (From BCS0405)

Quoting rules for command substitution.

---

#### Rule

Use double quotes when strings include command substitution:

```bash
# ✓ Correct
echo "Current time: $(date +%T)"
info "Found $(wc -l < "$file") lines"
```

Variable assignment: quotes only required when concatenating values:

```bash
# ✓ Correct - no quotes needed for simple assignment
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')
TIMESTAMP=$(date -Ins)
BASEDIR=$PREFIX

# ✗ Wrong - unnecessary quotes
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"

# ✓ Correct - quotes required for concatenation
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')".beta
TIMESTAMP="$(date -Ins)"-Jakarta
BASEDIR="$PREFIX"/config
```

---

#### Always Quote the Result

```bash
# ✓ Correct
result=$(command)
echo "$result"

# ✗ Wrong - word splitting occurs
echo $result
```

**Key principle:** Quote command substitution results to preserve whitespace and prevent word splitting.
