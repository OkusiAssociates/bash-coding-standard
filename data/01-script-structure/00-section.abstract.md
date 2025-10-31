# Script Structure & Layout

**Scripts must follow mandatory 13-step layout for consistency and safe initialization.**

Steps: (1) Shebang `#!/usr/bin/env bash`, (2) ShellCheck directives if needed, (3) Brief description comment, (4) `set -euo pipefail`, (5) `shopt -s inherit_errexit shift_verbose extglob nullglob`, (6) Metadata (`VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` made `readonly`), (7) Global variables, (8) Colors if terminal output, (9) Utility functions (messaging, helpers), (10) Business logic functions, (11) `main()` for scripts >40 lines, (12) Script invocation `main "$@"`, (13) End marker `#fin`.

**Function organization: bottom-up.** Define messaging functions first (lowest level), then helpers, validators, business logic, with `main()` last (highest orchestration level). Each function safely calls functions defined above it.

**Dual-purpose scripts** (executable and sourceable): Check `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` early. When sourced, skip `set -e` to avoid modifying caller's shell.

**FHS compliance:** Install to `/usr/local/share/{org}/{project}/` (local) or `/usr/share/{org}/{project}/` (system). Support uninstalled mode (script directory) for development.

**File extensions:** Omit `.sh` for user-facing commands; use `.sh` for libraries and internal tools.

**Ref:** BCS01
