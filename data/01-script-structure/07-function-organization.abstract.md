## Function Organization

**Organize functions bottom-up: primitives first → compositions → `main()` last. Dependencies flow downward only.**

**Why:** No forward references (Bash reads top-to-bottom); clear dependency hierarchy; debugging reads naturally.

**7-layer pattern:**
1. Messaging (`_msg`, `info`, `warn`, `error`, `die`)
2. Utilities (`noarg`, `trim`)
3. Documentation (`show_help`)
4. Validation (`check_prerequisites`)
5. Business logic (domain operations)
6. Orchestration (coordinate business logic)
7. `main()` → `main "$@"` → `#fin`

```bash
# Layer 1: Messaging (lowest)
_msg() { ... }
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4-5: Validation/Business
check_deps() { ... }
build() { check_deps; ... }

# Layer 7: main (highest)
main() { build; deploy; }
main "$@"
```

**Anti-patterns:**
- `main()` at top → forward reference errors
- Circular dependencies → extract common logic to lower layer
- Scattered messaging functions → group all at top

**Ref:** BCS0107
