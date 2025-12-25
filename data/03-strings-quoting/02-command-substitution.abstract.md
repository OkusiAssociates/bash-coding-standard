### Command Substitution

**Always double-quote command substitutions to prevent word splitting and preserve whitespace.**

#### Core Pattern

```bash
# ✓ Quoted substitution and result usage
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
echo "Found $(wc -l < "$file") lines"
result=$(cmd); echo "$result"
```

#### Anti-Pattern

```bash
echo $result  # ✗ Word splitting on whitespace/globs
```

**Ref:** BCS0302
