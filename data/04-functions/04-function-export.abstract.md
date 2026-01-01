## Function Export

**Use `declare -fx` to export functions for subshell access.**

### Rationale
- Subshells don't inherit functions by default
- Essential for `xargs -P`, `find -exec`, parallel jobs

### Pattern
```bash
grep() { /usr/bin/grep "$@"; }
declare -fx grep
```

### Anti-Pattern
`export -f func` â†' Use `declare -fx` for consistency with variable exports.

**Ref:** BCS0404
