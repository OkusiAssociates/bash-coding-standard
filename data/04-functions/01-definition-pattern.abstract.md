## Function Definition Pattern

**Use `name() { }` syntax; single-line for simple ops, multi-line with `local` declarations for complex functions.**

```bash
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
main() {
  local -i exitcode=0
  local -- variable
  return "$exitcode"
}
```

- `local -i` for integers, `local --` for strings
- `function` keyword â†' non-portable, avoid

**Ref:** BCS0401
