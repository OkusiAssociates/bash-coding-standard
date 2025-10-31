## Function Organization

**Always organize functions bottom-up: lowest-level primitives first, then composition layers, ending with `main()`. This eliminates forward reference issues and makes scripts readable and maintainable.**

**Rationale:**

- **No Forward References**: Bash reads top-to-bottom; dependency order ensures called functions exist before use
- **Readability**: Readers understand primitives first, then see compositions
- **Debugging/Maintainability**: Clear dependency hierarchy reveals where to add functions
- **Testability**: Low-level functions tested independently before higher-level compositions
- **Cognitive Load**: Understanding small pieces first reduces mental overhead

**Standard 7-layer pattern:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Messaging (lowest level - used by everything)
_msg() { ... }
info() { >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# 2. Documentation (no dependencies)
show_help() { ... }

# 3. Helpers/utilities
yn() { ... }
noarg() { ... }

# 4. Validation (check prerequisites)
check_root() { ... }
check_prerequisites() { ... }

# 5. Business logic (domain operations)
build_standalone() { ... }
install_standalone() { ... }

# 6. Orchestration
show_completion_message() { ... }

# 7. Main (highest level - orchestrates everything)
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

**Key principle:** Each function can safely call functions defined ABOVE it. Dependencies flow downward: higher functions call lower, never upward.

```
[Layer 1: Messaging] ← Primitives, no dependencies
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
```

**Layer descriptions:**

**1. Messaging** - `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`, `debug()`, `vecho()`. Pure I/O primitives, no dependencies.

**2. Documentation** - `show_help()`, `show_version()`, `show_usage()`. Display help/usage, may use messaging.

**3. Utilities** - `yn()`, `noarg()`, `trim()`, `s()`, `decp()`. Generic utilities, may use messaging.

**4. Validation** - `check_root()`, `check_prerequisites()`, `validate_input()`. Verify preconditions, use utilities/messaging.

**5. Business Logic** - Domain operations like `build_project()`, `process_file()`. Core functionality using all lower layers.

**6. Orchestration** - `run_build_phase()`, `cleanup()`. Coordinate multiple business functions.

**7. main()** - Top-level script flow, can call any function.

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0
declare -- BUILD_DIR='/tmp/build'

# Layer 1: Messaging
_msg() { echo "[${FUNCNAME[1]}] $*"; }
info() { >&2 _msg "$@"; }
warn() { >&2 _msg "WARNING: $*"; }
error() { >&2 _msg "ERROR: $*"; }
die() { local -i exit_code=$1; shift; (($#)) && error "$@"; exit "$exit_code"; }
success() { >&2 _msg "SUCCESS: $*"; }
debug() { ((VERBOSE)) && >&2 _msg "DEBUG: $*"; return 0; }

# Layer 2: Documentation
show_version() { echo "$SCRIPT_NAME $VERSION"; }
show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]
Options:
  -v, --verbose   Enable verbose output
  -n, --dry-run   Dry-run mode
  -h, --help      Show help
EOF
}

# Layer 3: Utilities
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(2>&1 warn "${1:-'Continue?'}") y/n "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
noarg() { (($# < 2)) && die 2 "Option $1 requires an argument"; }

# Layer 4: Validation
check_prerequisites() {
  info 'Checking prerequisites...'
  local -- cmd
  for cmd in git make tar; do
    command -v "$cmd" >/dev/null 2>&1 || die 1 "Required command not found: $cmd"
  done
  [[ -w "${BUILD_DIR%/*}" ]] || die 5 "Cannot write to: $BUILD_DIR"
  success 'Prerequisites OK'
}

validate_config() {
  [[ -f 'config.conf' ]] || die 2 'Configuration file not found'
  source 'config.conf'
  [[ -n "${APP_NAME:-}" ]] || die 22 'APP_NAME not set'
  [[ -n "${APP_VERSION:-}" ]] || die 22 'APP_VERSION not set'
}

# Layer 5: Business logic
clean_build_dir() {
  info "Cleaning: $BUILD_DIR"
  ((DRY_RUN)) && { info '[DRY-RUN] Would remove build directory'; return 0; }
  [[ -d "$BUILD_DIR" ]] && rm -rf "$BUILD_DIR"
  install -d "$BUILD_DIR"
  success "Build directory ready"
}

compile_sources() {
  info 'Compiling...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would compile'; return 0; }
  make -C src all BUILD_DIR="$BUILD_DIR"
  success 'Compiled'
}

run_tests() {
  info 'Testing...'
  ((DRY_RUN)) && { info '[DRY-RUN] Would test'; return 0; }
  make -C tests all
  success 'Tests passed'
}

create_package() {
  local -- package_file="$BUILD_DIR/app.tar.gz"
  ((DRY_RUN)) && { info "[DRY-RUN] Would create: $package_file"; return 0; }
  tar -czf "$package_file" -C "$BUILD_DIR" .
  success "Package: $package_file"
}

# Layer 6: Orchestration
run_build_phase() {
  clean_build_dir
  compile_sources
  run_tests
}

run_package_phase() {
  create_package
}

# Layer 7: Main
main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)    show_help; exit 0 ;;
    -V|--version) show_version; exit 0 ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            die 2 "Unexpected argument: $1" ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN

  info "Starting $SCRIPT_NAME $VERSION"
  ((DRY_RUN)) && info 'DRY-RUN MODE'

  check_prerequisites
  validate_config
  run_build_phase
  run_package_phase

  success "Completed"
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - main() at top (forward references)
main() { build_project; }  # Not defined yet!
build_project() { ... }

# ✓ Correct - main() at bottom
build_project() { ... }
main() { build_project; }

# ✗ Wrong - business logic before utilities
process_file() { validate_input "$1"; }  # Not defined yet!
validate_input() { ... }

# ✓ Correct - utilities first
validate_input() { ... }
process_file() { validate_input "$1"; }

# ✗ Wrong - random organization ignoring dependencies
cleanup() { ... }
build() { ... }
main() { ... }

# ✓ Correct - dependency order
check_deps() { ... }
build() { check_deps; ... }
main() { build; }

# ✗ Wrong - circular dependencies
function_a() { function_b; }
function_b() { function_a; }  # Circular!

# ✓ Correct - extract common logic
common_logic() { ... }
function_a() { common_logic; }
function_b() { common_logic; }
```

**Within-layer ordering:**

**Layer 1:** By severity: `_msg()` → `info()` → `success()` → `debug()` → `warn()` → `error()` → `die()`.

**Layer 3-5:** Alphabetically or by frequency/workflow order.

**Edge cases:**

**Circular dependencies:** Extract common logic to lower layer.

```bash
shared_validation() { ... }
function_a() { shared_validation; }
function_b() { shared_validation; }
```

**Sourced libraries:** Place after messaging layer.

```bash
info() { ... }
warn() { ... }
source "$SCRIPT_DIR/lib/common.sh"
validate_email() { ... }  # Can use both
```

**Private functions:** Place with public functions that use them.

```bash
_msg() { ... }  # Private
info() { >&2 _msg "$@"; }  # Public wrapper
```

**Summary:** Always organize bottom-up: messaging → utilities → validation → business → orchestration → main(). Dependencies flow downward. Use section comments. main() always last before invocation.
