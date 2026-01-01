## Function Organization

**Organize functions bottom-up: lowest-level primitives first (messaging, utilities), then composition layers, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; functions must exist before being called
- **Readability**: Primitives first, then compositions - readers understand dependencies immediately
- **Testability**: Low-level functions can be tested independently before testing compositions
- **Maintainability**: Clear dependency hierarchy shows where to add new functions

**Standard 7-layer organization:**

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
  if ((UNINSTALL)); then
    uninstall_files
    return 0
  fi
  build_standalone
  install_standalone
  show_completion_message
}

main "$@"
#fin
```

**Dependency flow (each layer can only call layers above it):**

```
Top of file
     ↓
[Layer 1: Messaging] ← Can call nothing (primitives)
     ↓
[Layer 2: Documentation] ← Can call Layer 1
     ↓
[Layer 3: Utilities] ← Can call Layers 1-2
     ↓
[Layer 4: Validation] ← Can call Layers 1-3
     ↓
[Layer 5: Business Logic] ← Can call Layers 1-4
     ↓
[Layer 6: Orchestration] ← Can call Layers 1-5
     ↓
[Layer 7: main()] ← Can call all layers
     ↓
main "$@" invocation
#fin
```

**Layer descriptions:**

| Layer | Functions | Purpose | Used By |
|-------|-----------|---------|---------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()` | Output messages | Everything |
| 2 | `show_help()`, `show_version()` | Display help/usage | Argument parsing, main() |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities | Validation, business logic |
| 4 | `check_root()`, `check_prerequisites()`, `validate_input()` | Verify preconditions | main(), business logic |
| 5 | `build_project()`, `process_file()`, `deploy_app()` | Core functionality | Orchestration, main() |
| 6 | `run_build_phase()`, `run_deploy_phase()`, `cleanup()` | Coordinate business logic | main() |
| 7 | `main()` | Top-level script flow | Script invocation |

**Anti-patterns:**

```bash
# ✗ Wrong - main() at the top (forward references required)
main() {
  build_project  # build_project not defined yet!
  deploy_app     # deploy_app not defined yet!
}
build_project() { ... }
deploy_app() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
deploy_app() { ... }
main() {
  build_project
  deploy_app
}

# ✗ Wrong - business logic before utilities it calls
process_file() {
  validate_input "$1"  # validate_input not defined yet!
}
validate_input() { ... }

# ✓ Correct - utilities before business logic
validate_input() { ... }
process_file() {
  validate_input "$1"
}

# ✗ Wrong - messaging functions scattered throughout
info() { ... }
build() { ... }
warn() { ... }
deploy() { ... }
error() { ... }

# ✓ Correct - all messaging together at top
info() { ... }
warn() { ... }
error() { ... }
die() { ... }
build() { ... }
deploy() { ... }

# ✗ Wrong - circular dependencies (A calls B, B calls A)
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic to lower-level function
common_logic() { ... }
function_a() { common_logic; ... }
function_b() { common_logic; ... }
```

**Within-layer ordering guidelines:**

- **Layer 1 (Messaging)**: Order by severity: `_msg()` �' `info()` �' `success()` �' `debug()` �' `warn()` �' `error()` �' `die()`
- **Layer 3 (Helpers)**: Alphabetically or by frequency of use
- **Layer 4 (Validation)**: By execution sequence (functions called early first)
- **Layer 5 (Business Logic)**: By logical workflow sequence

**Edge cases:**

**1. Circular dependencies** - Extract common logic:
```bash
shared_validation() { ... }  # Common code
function_a() { shared_validation; ... }
function_b() { shared_validation; ... }
```

**2. Sourced libraries** - Place after messaging layer:
```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"  # After messaging
validate_email() { ... }  # Can use both messaging AND library
```

**3. Private functions** - Place in same layer as public functions:
```bash
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Bottom-up organization mirrors how programmers think: understand primitives first, then compositions. This eliminates forward reference issues and makes scripts immediately understandable.
