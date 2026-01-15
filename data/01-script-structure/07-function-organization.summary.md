## Function Organization

**Always organize functions bottom-up: lowest-level primitives first, ending with `main()` as the highest-level orchestrator.**

**Rationale:**
- **No Forward References**: Bash reads top-to-bottom; defining functions in dependency order ensures called functions exist before use
- **Readability**: Readers understand primitives first, then see how they're composed
- **Maintainability**: Clear dependency hierarchy makes it obvious where to add new functions
- **Testability**: Low-level functions can be tested independently before higher-level compositions

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

**Dependency flow principle:**

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

| Layer | Functions | Purpose | Dependencies |
|-------|-----------|---------|--------------|
| 1 | `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()` | Output messages | None |
| 2 | `show_help()`, `show_version()` | Display help/usage | May use messaging |
| 3 | `yn()`, `noarg()`, `trim()` | Generic utilities | May use messaging |
| 4 | `check_root()`, `check_prerequisites()`, `validate_input()` | Verify preconditions | Utilities, messaging |
| 5 | `build_project()`, `process_file()`, `deploy_app()` | Core functionality | All lower layers |
| 6 | `run_build_phase()`, `run_deploy_phase()`, `cleanup()` | Coordinate business logic | Business logic, validation |
| 7 | `main()` | Top-level script flow | Can call any function |

**Anti-patterns to avoid:**

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
function_b() { function_a; }  # Circular dependency!

# ✓ Correct - extract common logic to lower-level function
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering guidelines:**

| Layer | Ordering Strategy |
|-------|-------------------|
| 1 (Messaging) | By severity: `_msg()` �' `info()` �' `success()` �' `warn()` �' `error()` �' `die()` |
| 3 (Helpers) | Alphabetically or by frequency of use |
| 4 (Validation) | By execution sequence |
| 5 (Business Logic) | By logical workflow sequence |

**Edge cases:**

**1. Circular dependencies:**
```bash
# Extract common logic to lower layer
shared_validation() { ... }
function_a() { shared_validation; ... }
function_b() { shared_validation; ... }
```

**2. Sourced libraries:**
```bash
# Place source statements after messaging layer
info() { ... }
warn() { ... }
error() { ... }
die() { ... }

source "$SCRIPT_DIR"/lib/common.sh  # May define additional utilities

validate_email() { ... }  # Can now use both messaging AND library functions
```

**3. Private functions:**
```bash
# Functions prefixed with _ are private/internal
# Place in same layer as public functions that use them
_msg() { ... }  # Private core utility
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Key principle:** Bottom-up organization mirrors how programmers think: understand primitives first, then compositions. This pattern eliminates forward reference issues and makes scripts immediately understandable.
