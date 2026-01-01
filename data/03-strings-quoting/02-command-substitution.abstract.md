### Command Substitution

**Always double-quote strings containing `$()` and quote variables holding command output to prevent word splitting.**

#### Core Pattern

```bash
# âœ“ Correct
echo "Time: $(date +%T)"
VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"
result=$(cmd); echo "$result"
```

#### Anti-Pattern

`echo $result` â†' word splitting on whitespace

**Ref:** BCS0302
