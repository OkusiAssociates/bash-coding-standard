### Command Substitution

**Quote command substitution in strings; quote results when used.**

Variable assignment: quotes only needed with concatenation.
- `VERSION=$(git describe)` ✓
- `VERSION="$(git describe)".beta` ✓ (concatenation)
- `VERSION="$(git describe)"` ✗ (unnecessary)

```bash
# Assignment: no quotes needed
result=$(command)
# Usage: always quote to prevent word splitting
echo "$result"
echo "Found $(wc -l < "$file") lines"
```

**Anti-pattern:** `echo $result` → word splitting on whitespace.

**Ref:** BCS0302
