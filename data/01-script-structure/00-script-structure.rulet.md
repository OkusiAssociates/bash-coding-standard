# Script Structure & Layout - Rulets
## Mandatory 13-Step Structure
- [BCS0101] Every Bash script must follow the exact 13-step layout: (1) shebang, (2) shellcheck directives, (3) description, (4) `set -euo pipefail`, (5) `shopt` settings, (6) script metadata, (7) global variables, (8) color definitions, (9) utility functions, (10) business logic functions, (11) `main()`, (12) script invocation, (13) `#fin` marker.
- [BCS0101] Place `set -euo pipefail` at line 4 (after shebang, shellcheck, and description comment) before any commands execute to enable strict error handling immediately.
- [BCS0101] Scripts over 100 lines must use a `main()` function as the single entry point for execution flow; smaller scripts may run code directly.
- [BCS0101] Always end scripts with the `#fin` or `#end` marker to visually confirm file completeness and prevent truncation errors.
## Shebang
- [BCS0102] Use one of three acceptable shebangs: `#!/bin/bash` (most portable Linux), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability via PATH search).
- [BCS0102] Place the shebang as the absolute first line (line 1) of every script with no leading whitespace or comments.
## Script Metadata
- [BCS0103] Declare standard metadata immediately after `shopt` settings using: `declare -r VERSION='1.0.0'`, `declare -r SCRIPT_PATH=$(realpath -- "$0")`, `declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Always use `realpath` (not `readlink`) to resolve `SCRIPT_PATH` to canonical absolute paths, catching missing scripts early; disable shellcheck SC2155 with explanatory comment: `#shellcheck disable=SC2155`.
- [BCS0103] Make metadata variables readonly at declaration using `declare -r` to prevent accidental modification throughout script execution.
- [BCS0103] Use `SCRIPT_DIR` for loading companion files and resources relative to script location, not `PWD` which reflects current working directory.
## Global Variables
- [BCS0101] Declare all global variables immediately after metadata (step 7) with explicit type declarations: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Group all global variable declarations in one location before any function definitions to make script state visible at a glance.
- [BCS0101] Defer `readonly` declarations until after argument parsing for variables that need modification during initialization; make them readonly before business logic executes.
## Color Definitions
- [BCS0101] Define color variables conditionally based on terminal detection: `if [[ -t 1 && -t 2 ]]; then readonly -- RED=$'\033[0;31m' ...; else readonly -- RED='' ...; fi`.
- [BCS0101] Make color variables readonly immediately after conditional assignment to prevent modification: `readonly -- RED GREEN YELLOW CYAN NC`.
- [BCS0101] Skip color definitions entirely if your script produces no colored terminal output.
## Standard shopt Settings
- [BCS0105] Always enable `shopt -s inherit_errexit shift_verbose extglob nullglob` in all scripts for proper error handling, argument safety, extended patterns, and safe glob expansion.
- [BCS0105] The `inherit_errexit` setting is critical: without it, `set -e` does not apply inside command substitutions `$(...)` or subshells `(...)`, causing silent failures.
- [BCS0105] Choose `nullglob` for scripts with file loops (unmatched globs expand to empty, loop skips) or `failglob` for strict scripts (unmatched globs cause errors).
- [BCS0105] Use `extglob` to enable advanced patterns: `!(*.txt)` excludes .txt files, `@(jpg|png)` matches alternatives, `+(pattern)` matches one or more.
## Function Organization (Bottom-Up)
- [BCS0107] Always organize functions bottom-up in 7 layers: (1) messaging functions, (2) documentation functions, (3) helper/utility functions, (4) validation functions, (5) business logic functions, (6) orchestration functions, (7) `main()` function.
- [BCS0107] Place messaging functions (`_msg()`, `info()`, `warn()`, `error()`, `die()`) first as lowest-level primitives used by everything; they must have zero dependencies.
- [BCS0107] Each function may only call functions defined above it (earlier in file), establishing clear dependency hierarchy flowing downward from primitives to composition.
- [BCS0107] Place `main()` function last before script invocation, as the highest-level orchestrator that calls all other layers.
- [BCS0107] Use section comments to visually separate function layers: `# ============================================================================` `# Layer 3: Helper/Utility Functions` `# ============================================================================`.
## Utility Functions
- [BCS0101] Implement standard messaging functions in step 9: `_msg()` (core), `vecho()` (verbose), `info()`, `warn()`, `success()`, `error()`, `die()`, `yn()` (yes/no prompt), `noarg()` (argument validation).
- [BCS0101] Place all utility functions before business logic functions since business logic depends on messaging, validation, and helper utilities.
- [BCS0101] Remove unused utility functions before production deployment to reduce script size, but keep them during development for flexibility.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be both executed and sourced, place all function definitions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` before any executable code.
- [BCS010201] Apply `set -euo pipefail` and `shopt` settings only in the executable section (after the early return check), never when sourced, to avoid modifying the caller's shell environment.
- [BCS010201] Use visual separator comment `# ----------------------------------------------------------------------------` to clearly mark the boundary between sourceable functions and executable code.
- [BCS010201] Guard metadata initialization with idempotent check: `if [[ ! -v SCRIPT_VERSION ]]; then declare -x SCRIPT_VERSION='1.0.0'; ...; fi` to allow safe re-sourcing.
- [BCS010201] Export functions with `declare -fx function_name` when they need to be available in subshells.
## FHS Compliance
- [BCS0104] Follow Filesystem Hierarchy Standard (FHS) for scripts that install system-wide: executables in `$PREFIX/bin`, data files in `$PREFIX/share/appname`, libraries in `$PREFIX/lib/appname`, config in `$PREFIX/etc/appname`.
- [BCS0104] Support customizable `PREFIX` via environment variable with default: `declare -- PREFIX="${PREFIX:-/usr/local}"` to enable user installs, system installs, and package manager integration.
- [BCS0104] Search multiple FHS locations when loading resources: script directory (development), `/usr/local/share/app` (local install), `/usr/share/app` (system install), `${XDG_DATA_HOME:-$HOME/.local/share}/app` (user install).
- [BCS0104] Use XDG Base Directory specification for user-specific files: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME` with fallbacks to `$HOME/.config`, `$HOME/.local/share`, etc.
- [BCS0104] Preserve existing user configuration files during upgrades: `[[ -f "$CONFIG_FILE" ]] || install config.example "$CONFIG_FILE"` instead of unconditional overwrites.
## File Extensions
- [BCS0106] Use no extension for executables installed to PATH (e.g., `myapp` not `myapp.sh`) for cleaner command-line interface.
- [BCS0106] Use `.sh` extension for library files meant to be sourced (not executed directly) and for executables not in PATH.
- [BCS0106] Make library files non-executable (`chmod 644`) to clearly indicate they should be sourced, not run.
## Script Invocation
- [BCS0101] Invoke `main()` function at step 12 with quoted argument array: `main "$@"` to preserve all arguments with proper spacing and special characters.
- [BCS0101] For small scripts without `main()`, write business logic directly at step 12, but still follow all other structural requirements.
## Anti-Patterns to Avoid
- [BCS010102] Never place business logic before utility functions; this creates forward references where functions call utilities that aren't defined yet.
- [BCS010102] Never declare variables after they're first used; with `set -u`, this causes "unbound variable" errors.
- [BCS010102] Never make variables readonly before argument parsing if they need modification during initialization; use progressive readonly after parsing.
- [BCS010102] Never skip `set -euo pipefail` or place it after commands execute; errors in early commands will be silently ignored.
- [BCS010102] Never use `$0` directly without `realpath` for SCRIPT_PATH; relative paths and symlinks will break resource loading.
## Edge Cases
- [BCS010103] Tiny scripts under 100 lines may skip `main()` function and run code directly, but must still follow all other 13 steps.
- [BCS010103] Library files meant only for sourcing should skip `set -e` (would modify caller), `main()`, and script invocation; just define functions and end with `#fin`.
- [BCS010103] Scripts with cleanup requirements should define cleanup function in step 9 (utilities), then set trap after function definition: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS010103] Scripts sourcing external configuration should source config files between step 7 (globals) and step 9 (utilities), then make variables readonly after sourcing.
- [BCS010103] Handle edge case of script in root directory: `SCRIPT_DIR=${SCRIPT_PATH%/*}; [[ -z "$SCRIPT_DIR" ]] && SCRIPT_DIR='/'` since parameter expansion returns empty string for `/script`.
## Complete Example References
- [BCS010101] See BCS010101 for a comprehensive 462-line installation script demonstrating all 13 steps with dry-run mode, force mode, systemd integration, and full argument parsing.
- [BCS010102] See BCS010102 for eight common anti-patterns with side-by-side wrong/correct comparisons showing proper fixes.
- [BCS010103] See BCS010103 for five edge cases covering tiny scripts, sourced libraries, external config, platform detection, and cleanup traps.
