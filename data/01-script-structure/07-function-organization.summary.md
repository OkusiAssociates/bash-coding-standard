## Function Organization

**Organize functions bottom-up: lowest-level primitives first, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; dependency order ensures called functions exist before use
- **Readability/Debugging**: Understand primitives first, then compositions; dependencies immediately clear
- **Maintainability/Testability**: Clear dependency hierarchy; low-level functions testable independently

**Standard 7-layer pattern:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging functions (lowest level - used by everything)
_msg() { ... }
success() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
info() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation functions (no dependencies)
show_help() { ... }

# 3. Helper/utility functions (used by validation and business logic)
yn() { ... }
noarg() { ... }

# 4. Validation functions (check prerequisites, dependencies)
check_root() { ... }
check_prerequisites() { ... }

# 5. Business logic functions (domain-specific operations)
build_standalone() { ... }
install_standalone() { ... }

# 6. Orchestration/flow functions
show_completion_message() { ... }
uninstall_files() { ... }

# 7. Main function (highest level - orchestrates everything)
main() {
  check_root
  check_prerequisites
  build_standalone
  install_standalone
  show_completion_message
}

main "$@"
#fin
```

**Dependency flow (each layer can call layers above it):**

```
[Layer 1: Messaging] ← Primitives (call nothing)
[Layer 2: Documentation] ← Can call Layer 1
[Layer 3: Utilities] ← Can call Layers 1-2
[Layer 4: Validation] ← Can call Layers 1-3
[Layer 5: Business Logic] ← Can call Layers 1-4
[Layer 6: Orchestration] ← Can call Layers 1-5
[Layer 7: main()] ← Can call all layers
```

**Layer details:**
| Layer | Functions | Purpose |
|-------|-----------|---------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()` | Output messages |
| 2 | `show_help()`, `show_version()` | Display documentation |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities |
| 4 | `check_root()`, `validate_input()` | Verify preconditions |
| 5 | `build_project()`, `process_file()` | Core domain operations |
| 6 | `run_build_phase()`, `cleanup()` | Coordinate business logic |
| 7 | `main()` | Top-level script flow |

**Within-layer ordering:**
- **Messaging**: Order by severity: `_msg()` �' `info()` �' `warn()` �' `error()` �' `die()`
- **Validation**: Order by execution sequence (early checks first)
- **Business Logic**: Order by logical workflow sequence

**Anti-patterns:**

```bash
# ✗ Wrong - main() at top (forward references)
main() {
  build_project  # Not defined yet!
  deploy_app     # Not defined yet!
}
build_project() { ... }
deploy_app() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
deploy_app() { ... }
main() { build_project; deploy_app; }

# ✗ Wrong - messaging scattered throughout
info() { ... }
build() { ... }
warn() { ... }
deploy() { ... }

# ✓ Correct - all messaging together at top
info() { ... }
warn() { ... }
die() { ... }
build() { ... }
deploy() { ... }

# ✗ Wrong - circular dependencies
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Edge cases:**

**1. Sourced libraries** - Place source statements after messaging layer:
```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"  # After messaging
validate_email() { ... }  # Can use both messaging AND library
```

**2. Private functions** - Place in same layer as public functions using them:
```bash
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Bottom-up organization mirrors how programmers think—understand primitives first, then compositions. This eliminates forward reference issues and makes scripts immediately understandable.
