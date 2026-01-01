## Function Organization

**Organize functions bottom-up: primitives first, `main()` last. Dependencies flow downward—higher functions call lower functions.**

### 7-Layer Pattern

1. **Messaging** — `_msg()`, `info()`, `warn()`, `error()`, `die()`
2. **Documentation** — `show_help()`, `show_version()`
3. **Utilities** — `yn()`, `noarg()`, generic helpers
4. **Validation** — `check_prerequisites()`, input validation
5. **Business logic** — Domain-specific operations
6. **Orchestration** — Coordinate multiple operations
7. **main()** — Top-level script flow

### Rationale

- **No forward references** — Bash reads top-to-bottom; called functions must exist
- **Debuggability** — Read top-down to understand dependencies
- **Testability** — Test lower layers independently

### Example

```bash
# Layer 1: Messaging
_msg() { echo "[${FUNCNAME[1]}] $*"; }
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || >&2 _msg "${@:2}"; exit "${1:-0}"; }

# Layer 4: Validation
check_deps() { command -v git >/dev/null || die 1 'git required'; }

# Layer 5: Business logic
build() { info 'Building...'; make all; }

# Layer 7: main()
main() { check_deps; build; }
main "$@"
#fin
```

### Anti-Patterns

```bash
# ✗ main() at top (forward references)
main() { build; }  # build not defined!
build() { ... }

# ✗ Circular dependencies
func_a() { func_b; }
func_b() { func_a; }  # Extract common logic instead
```

**Ref:** BCS0107
