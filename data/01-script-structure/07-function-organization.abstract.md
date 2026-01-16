## Function Organization

**Organize functions bottom-up: primitives first, `main()` last. Dependencies flow downward only.**

**Rationale:** No forward references (Bash reads top-to-bottom); clear dependency hierarchy aids debugging/maintenance.

**7-Layer Pattern:**
1. Messaging (`_msg`, `info`, `warn`, `error`, `die`)
2. Documentation (`show_help`, `show_version`)
3. Utilities (`noarg`, `yn`, `trim`)
4. Validation (`check_root`, `check_prerequisites`)
5. Business logic (domain operations)
6. Orchestration (coordinate business logic)
7. `main()` â†' `main "$@"` invocation

```bash
# Layer 1: Messaging (no deps)
info() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# Layer 4: Validation (uses messaging)
check_deps() { command -v git || die 1 "git required"; }

# Layer 5: Business logic (uses all above)
build() { check_deps; make all; }

# Layer 7: main (calls everything)
main() { build; }
main "$@"
```

**Anti-patterns:**
- `main()` at top â†' forward references fail
- Circular deps (Aâ†”B) â†' extract shared logic to lower layer
- Random/alphabetical order ignoring deps â†' breaks call chain

**Ref:** BCS0107
