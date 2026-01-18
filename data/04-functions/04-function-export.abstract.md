## Function Export

**Use `declare -fx` to export functions for subshell/subprocess access.**

### Rationale
- Subshells don't inherit functions without explicit export
- `export -f` is equivalent but `declare -fx` is more consistent with variable exports

### Example
```bash
grep() { /usr/bin/grep "$@"; }
declare -fx grep
```

### Anti-pattern
`→` Defining functions without export, then wondering why subprocess can't find them

**Ref:** BCS0404
