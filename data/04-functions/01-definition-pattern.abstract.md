## Function Definition Pattern

**Use single-line syntax for simple operations; multi-line with `local --` for complex functions.**

```bash
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

main() {
  local -i exitcode=0
  local -- variable
  return "$exitcode"
}
```

**Anti-pattern:** `local file="$1"` â†' `local -- file="$1"` (always use `--` separator)

**Ref:** BCS0401
