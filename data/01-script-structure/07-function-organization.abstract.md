## Function Organization

**Organize bottom-up: primitives first, `main()` last. Each layer calls only functions defined above.**

**Rationale:** No forward references; primitives understood before compositions; clear dependency flow.

**7-layer pattern:**

```bash
# 1. Messaging (lowest)
_msg() { echo "[$FUNCNAME[1]] $*"; }
info() { >&2 _msg "$@"; }
die() { error "$@"; exit "${1:-1}"; }

# 2. Documentation
show_help() { ... }

# 3. Helpers
noarg() { (($# < 2)) && die "Option $1 needs arg"; }

# 4. Validation
check_prerequisites() { ... }

# 5. Business logic
build_project() { ... }

# 6. Orchestration
run_build() { build_project; test_project; }

# 7. Main (highest)
main() {
  check_prerequisites
  run_build
}
main "$@"
```

**Layer definitions:**
1. Messaging - `_msg()`, `info()`, `warn()`, `error()`, `die()`
2. Documentation - `show_help()`, `show_version()`
3. Helpers - `yn()`, `noarg()`, utilities
4. Validation - `check_*()`, `validate_*()`
5. Business logic - domain operations
6. Orchestration - coordinate business logic
7. `main()` - top orchestrator

**Anti-patterns:**
```bash
# ✗ main() at top → forward references
main() { build(); }  # Not defined!

# ✗ Circular deps (A→B, B→A)
# ✓ Extract common logic to lower layer

# ✗ Random ordering
# ✓ Dependency-ordered
```

**Within-layer:** Order by severity (messaging) or logical sequence.

**Ref:** BCS0107
