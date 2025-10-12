### Function Organization

Organize functions in a logical order from lowest-level (messaging, utilities) to highest-level (main logic):

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging functions (lowest level - used by everything)
_msg() { ... }
success() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
info() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation functions (no dependencies)
show_help() { ... }

# 3. Helper/utility functions (used by validation and business logic)
yn() { ... }
noarg() { ... }

# 4. Validation functions (check prerequisites, dependencies)
check_root() { ... }
check_prerequisites() { ... }
check_builtin_support() { ... }

# 5. Business logic functions (domain-specific operations)
build_standalone() { ... }
build_builtin() { ... }
install_standalone() { ... }
install_builtin() { ... }
install_completions() { ... }
update_man_database() { ... }

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
  ((INSTALL_BUILTIN)) && build_builtin

  install_standalone
  install_completions
  ((INSTALL_BUILTIN)) && install_builtin

  update_man_database
  show_completion_message
}

main "$@"
#fin
```

**Rationale:** This bottom-up organization means each function can safely call functions defined above it. Readers can understand low-level primitives first, then see how they're composed into higher-level operations.

**Guidelines:**
- Group related functions with section comments (e.g., `# Validation functions`)
- Within each group, order alphabetically or by logical dependency
- Keep `main()` last (before the invocation line)
- Dependencies flow downward: higher functions call lower functions, never upward
