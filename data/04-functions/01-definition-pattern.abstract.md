## Function Definition Pattern

**Use `fname() { }` syntax with `local` declarations at function start.**

### Key Rules
- Single-line for trivial ops: `fname() { cmd; }`
- Multi-line: `local -i` for integers, `local --` for strings
- Always `return "$exitcode"` with quoted variable

### Rationale
- `local` prevents variable leakage to global scope
- Typed locals (`-i`) catch assignment errors early

### Example
```bash
main() {
  local -i exitcode=0
  local -- result
  return "$exitcode"
}
```

### Anti-patterns
- `function fname` → use `fname()` (POSIX-compatible)
- Unquoted `return $var` → use `return "$var"`

**Ref:** BCS0401
