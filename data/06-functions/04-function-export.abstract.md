## Function Export

**Export functions with `declare -fx` when they must be available to subshells or child processes.**

```bash
# Export wrapper functions
grep() { /usr/bin/grep "$@"; }
find() { /usr/bin/find "$@"; }
declare -fx grep find
```

**Rationale:** Functions are not inherited by subshells unless explicitly exported; `-fx` makes them available to child processes.

**Anti-pattern:** Defining functions without export when subshells need them ’ function not found errors.

**Ref:** BCS0604
