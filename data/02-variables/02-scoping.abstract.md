## Variable Scoping

**Always declare function variables as `local` to prevent namespace pollution.**

- Without `local`: variables become global, overwrite existing globals, persist after return, break recursion
- Globals at top with `declare`; function vars always `local`

```bash
main() {
  local -a items=()    # Local array
  local -i count=0     # Local integer
  local -- name=$1     # Local string
}
```

**Anti-pattern:** `file=$1` → `local -- file=$1`

**Ref:** BCS0202
