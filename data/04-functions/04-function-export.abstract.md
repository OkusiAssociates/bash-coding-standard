## Function Export

**Use `declare -fx` to export functions for subshell access.**

Required when functions must be available to: `xargs`, `find -exec`, parallel execution, or any child process.

```bash
grep() { /usr/bin/grep "$@"; }
declare -fx grep
```

Anti-pattern: `export -f func` â†' use `declare -fx func` instead (consistent with BCS declaration style).

**Ref:** BCS0404
