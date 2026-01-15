## Function Organization

**Organize functions bottom-up: primitives first, `main()` last. Dependencies flow downward only.**

### Rationale
- **No forward references**: Bash reads top-to-bottom; functions must exist before called
- **Debugging**: Read top-down, understand dependencies immediately
- **Testability**: Low-level functions tested independently

### 7-Layer Pattern
```bash
# 1. Messaging: _msg(), info(), warn(), error(), die()
# 2. Helpers: noarg(), trim()
# 3. Documentation: show_help(), show_version()
# 4. Validation: check_root(), check_prerequisites()
# 5. Business logic: build_project(), process_file()
# 6. Orchestration: run_build_phase(), cleanup()
# 7. main() - calls all layers

main() {
  check_prerequisites
  run_build_phase
}
main "$@"
```

### Anti-patterns
```bash
# ✗ main() at top �' forward references
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✓ main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Circular dependencies
func_a() { func_b; }
func_b() { func_a; }  # Bad!

# ✓ Extract common logic
common() { ... }
func_a() { common; }
func_b() { common; }
```

**Ref:** BCS0107
