## Function Definition Pattern

**Use single-line format for simple operations; multi-line with `local` declarations for complex functions.**

**Syntax:**
```bash
# Single-line: no local vars, simple logic
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }

# Multi-line: local vars, complex logic
main() {
  local -i exitcode=0
  local -- variable
  # body
  return "$exitcode"
}
```

**Rationale:** Single-line saves space for trivial functions; multi-line improves readability and enables proper variable scoping for complex logic.

**Anti-patterns:** `’` Mixing formats inconsistently; omitting `local` for function-scope variables.

**Ref:** BCS0601
