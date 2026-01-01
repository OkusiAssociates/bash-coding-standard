## Variable Scoping

**Always declare function variables as `local` to prevent namespace pollution.**

Without `local`: variables become global â†' overwrite globals, persist after return, break recursion.

```bash
process_file() {
  local -- file=$1    # âœ“ Scoped to function
  local -i count=0    # âœ“ Local integer
}
```

**Anti-patterns:** `file=$1` in function â†' overwrites global `$file`; recursive functions without `local` share state across calls.

**Ref:** BCS0202
