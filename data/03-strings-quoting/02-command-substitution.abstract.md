### Command Substitution

**Quote `$()` in strings; omit quotes for simple assignment; always quote when using result.**

#### Rules

- **In strings:** `echo "Time: $(date)"` — double quotes required
- **Simple assignment:** `VAR=$(cmd)` — no quotes needed
- **Concatenation:** `VAR="$(cmd)".suffix` — quotes required
- **Usage:** `echo "$VAR"` — always quote to prevent word splitting

#### Example

```bash
# Assignment (no quotes needed)
VERSION=$(git describe --tags 2>/dev/null || echo 'unknown')

# Concatenation (quotes required)
VERSION="$(git describe --tags)".beta

# Usage (always quote)
echo "$VERSION"
```

#### Anti-patterns

- `VERSION="$(cmd)"` �' unnecessary quotes on simple assignment
- `echo $result` �' word splitting occurs without quotes

**Ref:** BCS0302
