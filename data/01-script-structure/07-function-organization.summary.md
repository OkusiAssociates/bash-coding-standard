## Function Organization

**Organize functions bottom-up: lowest-level primitives first (messaging, utilities), then composition layers, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; dependency order ensures functions exist before use
- **Readability/Debugging**: Understanding primitives first, then compositions reduces cognitive load
- **Maintainability/Testability**: Clear dependency hierarchy; low-level functions testable independently

**Standard 7-layer organization pattern:**

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
yn() { ... }

# 2. Helper/utility functions (used by validation and business logic)
noarg() { ... }

# 3. Documentation functions (no dependencies)
show_help() { ... }

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

**Dependency flow diagram:**

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

| Layer | Functions | Purpose | Used by |
|-------|-----------|---------|---------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()` | Output messages | Everything |
| 2 | `show_help()`, `show_version()` | Display help/usage | Argument parsing, main() |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities | Validation, business logic |
| 4 | `check_root()`, `check_prerequisites()`, `validate_input()` | Verify preconditions | main(), business logic |
| 5 | `build_project()`, `process_file()`, `deploy_app()` | Core functionality | Orchestration, main() |
| 6 | `run_build_phase()`, `run_deploy_phase()`, `cleanup()` | Coordinate operations | main() |
| 7 | `main()` | Top-level script flow | Script invocation |

**Anti-patterns:**

```bash
# ✗ Wrong - main() at the top (forward references required)
main() {
  build_project  # build_project not defined yet!
}
build_project() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Wrong - business logic before utilities it calls
process_file() {
  validate_input "$1"  # validate_input not defined yet!
}
validate_input() { ... }

# ✓ Correct - utilities before business logic
validate_input() { ... }
process_file() { validate_input "$1"; }

# ✗ Wrong - messaging functions scattered throughout
info() { ... }
build() { ... }
warn() { ... }
deploy() { ... }

# ✓ Correct - all messaging together at top
info() { ... }
warn() { ... }
error() { ... }
build() { ... }
deploy() { ... }

# ✗ Wrong - circular dependencies (A calls B, B calls A)
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic to lower-level function
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering:**

- **Layer 1 (Messaging)**: Order by severity: `_msg()` �' `info()` �' `success()` �' `warn()` �' `error()` �' `die()`
- **Layer 3-4 (Helpers/Validation)**: Alphabetically or by frequency of use
- **Layer 5 (Business Logic)**: By logical workflow sequence

**Edge cases:**

**1. Circular dependencies:**
```bash
# Extract common logic to lower layer
shared_validation() { ... }  # Lower layer
function_a() { shared_validation; ... }
function_b() { shared_validation; ... }
```

**2. Sourced libraries:**
```bash
# Place source statements after messaging layer
info() { ... }
warn() { ... }
source "$SCRIPT_DIR"/lib/common.sh  # After messaging
validate_email() { ... }  # Can use both messaging AND library
```

**3. Private functions:**
```bash
# Prefix with _, place in same layer as public functions that use them
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Each function can safely call functions defined ABOVE it. Dependencies flow downward—higher functions call lower functions, never upward. This mirrors how programmers think and eliminates forward reference issues.
