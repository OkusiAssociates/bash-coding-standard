# Script Structure & Layout - Rulets
## Shebang and Initial Setup
- [BCS0102] First line must be shebang (`#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash`), followed by optional `#shellcheck` directives, brief description comment, then `set -euo pipefail` as the first command.
- [BCS0102] Use `#!/bin/bash` for known Linux systems, `#!/usr/bin/bash` for BSD systems, `#!/usr/bin/env bash` for maximum portability across diverse environments.
## Strict Mode and Shell Options
- [BCS0101] `set -euo pipefail` is mandatory and must be the first command before any other commands execute (except shebang/comments/shellcheck).
- [BCS0105] Always use `shopt -s inherit_errexit shift_verbose extglob nullglob` for recommended shell behavior; `inherit_errexit` is critical as it makes `set -e` work in subshells and command substitutions.
- [BCS0105] Choose `nullglob` for scripts processing file lists (unmatched globs become empty) or `failglob` for strict scripts (unmatched globs cause errors); never use default behavior which expands unmatched globs to literal strings.
## Script Metadata
- [BCS0103] Declare standard metadata immediately after shopt: `declare -r VERSION=1.0.0`, then `declare -r SCRIPT_PATH=$(realpath -- "$0")`, then `declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Use `realpath` (not `readlink`) to resolve SCRIPT_PATH; it provides canonical absolute paths, fails early if file doesn't exist, and has a loadable builtin available for performance.
- [BCS0103] Disable SC2155 for SCRIPT_PATH declaration with comment; the failure mode (script doesn't exist) should cause immediate termination anyway: `#shellcheck disable=SC2155`.
## Global Variables and Colors
- [BCS0101] Declare all global variables up front with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Define terminal-aware colors conditionally: `if [[ -t 1 && -t 2 ]]; then declare -r RED=$'\033[0;31m' ...; else declare -r RED='' ...; fi` to avoid escape codes in non-terminal output.
## Utility Functions
- [BCS0101] Implement standard messaging functions (`_msg`, `info`, `warn`, `error`, `die`, `success`, `vecho`) in Layer 1; remove unused functions only after script is mature.
- [BCS0101] Use `_msg()` as core message function with `FUNCNAME[1]` dispatch for consistent prefix formatting across all message types.
- [BCS0101] `die()` must take exit code as first argument: `die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }`.
## Function Organization
- [BCS0107] Organize functions bottom-up in 7 layers: (1) messaging, (2) documentation, (3) utilities, (4) validation, (5) business logic, (6) orchestration, (7) `main()`; each layer can only call functions from layers above it.
- [BCS0107] Never define `main()` at the top of the file; it must be the last function defined before the `main "$@"` invocation.
- [BCS0107] Avoid circular dependencies between functions; extract common logic to a lower layer if two functions need to call each other.
## Main Function and Script Invocation
- [BCS0101] Use `main()` function for scripts over ~200 lines; scripts under 200 lines may run directly without `main()`.
- [BCS0101] Parse arguments in `main()`, then make configuration variables readonly after parsing complete: `readonly -- PREFIX CONFIG_FILE`.
- [BCS0101] Invoke script with `main "$@"` and always quote `"$@"` to preserve argument array properly.
## End Marker
- [BCS0101] Every script must end with `#fin` or `#end` as the mandatory final line to confirm the file is complete and not truncated.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be sourced or executed, define all functions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0` before `set -euo pipefail`.
- [BCS010201] Never apply `set -euo pipefail` or `shopt` changes when sourced; these would alter the calling shell's environment.
- [BCS010201] Guard metadata initialization for idempotent re-sourcing: `if [[ ! -v SCRIPT_VERSION ]]; then declare -xr SCRIPT_VERSION=1.0.0; ...; fi`.
## FHS Compliance
- [BCS0104] Search for resources in FHS order: script directory (development), `"$PREFIX"/share/` (custom install), `/usr/local/share/` (local install), `/usr/share/` (system install), then XDG user directories.
- [BCS0104] Support PREFIX customization: `PREFIX=${PREFIX:-/usr/local}` and derive all paths from it: `BIN_DIR="$PREFIX"/bin`, `SHARE_DIR="$PREFIX"/share/myapp`.
- [BCS0104] Use XDG Base Directory spec for user-specific files: `${XDG_CONFIG_HOME:-"$HOME"/.config}`, `${XDG_DATA_HOME:-"$HOME"/.local/share}`.
## File Extensions
- [BCS0106] Executables should have `.sh` extension or no extension; globally available executables via PATH must have no extension.
- [BCS0106] Libraries must have `.sh` extension and should not be executable.
## Anti-Patterns
- [BCS010102] Never declare variables after they are used; with `set -u` this causes "unbound variable" errors.
- [BCS010102] Never define business logic functions before utility functions they call; organize bottom-up.
- [BCS010102] Never make variables readonly before argument parsing is complete if they need to be modified during parsing.
- [BCS010102] Never scatter global declarations throughout the file; group all globals together before functions.
- [BCS010102] Never source files that modify the caller's shell settings (`set -e`, `shopt`) without protection.
## Edge Cases
- [BCS010103] Sourced library files may skip `set -euo pipefail`, `main()`, and script invocation; they provide functions only.
- [BCS010103] Platform-specific scripts should detect platform early and set derived variables conditionally before making them readonly.
- [BCS010103] Scripts requiring cleanup must define cleanup function before setting trap, and set trap before any code that creates temporary resources.
