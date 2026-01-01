## Function Organization

**Organize functions bottom-up: primitives first, `main()` last. Dependencies flow downward only.**

### Rationale
- No forward references—Bash reads top-to-bottom
- Readability—understand primitives before compositions
- Testability—low-level functions testable independently

### 7-Layer Pattern

1. **Messaging** `_msg()`, `info()`, `warn()`, `error()`, `die()`
2. **Documentation** `show_help()`, `show_version()`
3. **Utilities** `yn()`, `noarg()`, `trim()`
4. **Validation** `check_prerequisites()`, `validate_input()`
5. **Business logic** Domain operations
6. **Orchestration** `run_build_phase()`, `cleanup()`
7. **main()** Top-level flow �' `main "$@"` �' `#fin`

```bash
# Layer 1: Messaging (lowest)
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4: Validation
check_prerequisites() { info 'Checking...'; }

# Layer 5: Business logic
build_project() { check_prerequisites; make all; }

# Layer 7: main() (highest)
main() { build_project; }
main "$@"
#fin
```

### Anti-Patterns

```bash
# ✗ main() at top (forward references)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✗ Random ordering
cleanup(); build(); check_deps(); main()

# ✗ Circular dependencies
func_a() { func_b; }
func_b() { func_a; }  # Extract common logic instead
```

**Key:** Each function calls only functions defined above it.

**Ref:** BCS0107
