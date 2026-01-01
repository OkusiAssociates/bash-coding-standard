## Variable Scoping

**Always declare function variables with `local` to prevent namespace pollution.**

```bash
main() {
  local -a specs=()      # Local array
  local -i depth=3       # Local integer
  local -- file="$1"     # Local string
}
```

**Why:** Without `local`, variables become global â†' overwrite globals, persist after return, break recursion.

**Anti-patterns:**
- `file=$1` â†' overwrites global `$file`
- Recursive functions without `local` share state across calls

**Ref:** BCS0202
