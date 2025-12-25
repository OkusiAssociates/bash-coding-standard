## Variable Scoping

**Always declare function variables with `local` to prevent namespace pollution and recursion failures.**

Globals at top with `declare`; function vars with `local -a|-i|--`.

```bash
main() {
  local -i count=0     # Local integer
  local -- file="$1"   # Local string (-- separator)
}
```

**Anti-patterns:**
- `file="$1"` in function â†' overwrites globals, breaks recursion
- Missing `local` in recursive functions â†' each call resets shared var

**Ref:** BCS0202
