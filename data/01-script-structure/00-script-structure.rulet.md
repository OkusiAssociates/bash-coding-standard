I have all the content I need from the user's message which provides the complete.md files. Let me now extract the rulets from all the provided files.
# Script Structure & Layout - Rulets
## Section Overview
- [BCS0100] Script Structure defines the mandatory 13-step layout: shebang → shellcheck → description → `set -euo pipefail` → shopt → metadata → globals → colors → utilities → business logic → main() → invocation → `#fin`.
## The 13-Step Layout (BCS0101)
- [BCS0101] Follow the 13-step layout in order: (1) shebang, (2) shellcheck directives, (3) description comment, (4) `set -euo pipefail`, (5) shopt settings, (6) metadata, (7) globals, (8) colors, (9) utilities, (10) business logic, (11) main(), (12) `main "$@"`, (13) `#fin`.
- [BCS0101] Place `set -euo pipefail` as the first executable command; it must come before any other commands except shebang, comments, and shellcheck directives.
- [BCS0101] Organize functions bottom-up: messaging functions first, then utilities, validation, business logic, orchestration, and finally `main()` at the bottom.
- [BCS0101] Use `main()` function for scripts over ~200 lines; scripts under 200 lines may run code directly.
- [BCS0101] End every script with `#fin` or `#end` marker to confirm file completeness.
- [BCS0101] Declare all global variables up front with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Make configuration variables `readonly` only after argument parsing is complete, not before.
- [BCS0101] Always quote `"$@"` in script invocation: `main "$@"`.
## Complete Working Example (BCS010101)
- [BCS010101] Production scripts should implement all 13 steps including: metadata with VERSION/SCRIPT_PATH/SCRIPT_DIR/SCRIPT_NAME, color detection, standard messaging functions, dry-run support, and proper argument parsing.
- [BCS010101] Use `noarg "$@"` pattern to validate that options requiring arguments receive them.
- [BCS010101] Implement dry-run mode by checking `((DRY_RUN))` before any operation and showing what would happen: `info "[DRY-RUN] Would create directory ${dir@Q}"`.
- [BCS010101] Use derived paths pattern where dependent paths update when PREFIX changes: `BIN_DIR="$PREFIX"/bin`.
## Common Anti-Patterns (BCS010102)
- [BCS010102] Never omit `set -euo pipefail`; errors will fail silently and cause corruption.
- [BCS010102] Never declare variables after using them; this causes "unbound variable" errors with `set -u`.
- [BCS010102] Never define business logic functions before the utility functions they call; always bottom-up organization.
- [BCS010102] Never make variables `readonly` before argument parsing; this prevents users from overriding defaults.
- [BCS010102] Never scatter global declarations throughout the file; group all globals together after metadata.
- [BCS010102] Never apply `set -euo pipefail` in scripts that may be sourced; use dual-purpose pattern instead.
- [BCS010102] Never omit the `#fin` end marker; readers cannot verify file completeness without it.
## Edge Cases (BCS010103)
- [BCS010103] Small scripts under 200 lines may skip `main()` and run code directly after function definitions.
- [BCS010103] Library files meant only to be sourced should skip `set -e`, `main()`, and script invocation; only define functions.
- [BCS010103] When sourcing external config files, place `source "$CONFIG_FILE"` between metadata and business logic.
- [BCS010103] Set cleanup traps after the cleanup function is defined but before any code that creates temporary resources.
- [BCS010103] For platform-specific scripts, detect platform with `case $(uname -s) in` and set platform-specific globals accordingly.
## Dual-Purpose Scripts (BCS010201)
- [BCS010201] For scripts that work both as executables and sourceable libraries, use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`.
- [BCS010201] Place all function definitions before the sourced/executed detection check; only apply `set -euo pipefail` in the executable section after the check.
- [BCS010201] Guard metadata initialization with `[[ ! -v VARIABLE ]]` to allow safe re-sourcing: `[[ -v SCRIPT_VERSION ]] || { declare -xr SCRIPT_VERSION=1.0.0; ... }`.
- [BCS010201] Export functions with `declare -fx function_name` if they need to be available in subshells.
- [BCS010201] Use `return` (not `exit`) for errors when script is sourced to avoid terminating the caller's shell.
## Shebang and Initial Setup (BCS0102)
- [BCS0102] Use one of three acceptable shebangs: `#!/bin/bash` (most portable Linux), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability).
- [BCS0102] Place `#shellcheck disable=` directives immediately after shebang with explanatory comments: `#shellcheck disable=SC2034  # Variables used by sourcing scripts`.
- [BCS0102] Include a brief one-line description comment after shebang/directives: `# Comprehensive installation script with configurable paths`.
- [BCS0102] First executable command must be `set -euo pipefail`; nothing else may execute before it.
## Script Metadata (BCS0103)
- [BCS0103] Declare standard metadata immediately after shopt: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`.
- [BCS0103] Use `realpath -- "$0"` or `realpath -- "${BASH_SOURCE[0]}"` for SCRIPT_PATH to resolve symlinks and get canonical absolute paths.
- [BCS0103] Derive SCRIPT_DIR and SCRIPT_NAME from SCRIPT_PATH using parameter expansion: `SCRIPT_DIR=${SCRIPT_PATH%/*}` and `SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Declare metadata as readonly immediately: `declare -r VERSION=1.0.0` and `declare -r SCRIPT_PATH=$(realpath -- "$0")`.
- [BCS0103] Suppress shellcheck SC2155 for metadata declarations with realpath: `#shellcheck disable=SC2155`.
- [BCS0103] Handle edge case of script in root directory: `[[ -n "$SCRIPT_DIR" ]] || SCRIPT_DIR='/'`.
## FHS Compliance (BCS0104)
- [BCS0104] Search for resources in FHS order: script directory (development), `/usr/local/share/` (local install), `/usr/share/` (system install), `~/.local/share/` (user install).
- [BCS0104] Use PREFIX variable for installation paths and respect environment override: `PREFIX=${PREFIX:-/usr/local}`.
- [BCS0104] Derive installation paths from PREFIX: `BIN_DIR="$PREFIX"/bin`, `SHARE_DIR="$PREFIX"/share/myapp`, `LIB_DIR="$PREFIX"/lib/myapp`.
- [BCS0104] Follow XDG Base Directory for user-specific files: `${XDG_CONFIG_HOME:-$HOME/.config}`, `${XDG_DATA_HOME:-$HOME/.local/share}`.
- [BCS0104] Preserve existing user configuration on upgrade: `[[ -f "$CONFIG" ]] || install -m 644 config.example "$CONFIG"`.
- [BCS0104] Strip trailing slash from PREFIX: `PREFIX=${PREFIX%/}`.
## shopt Settings (BCS0105)
- [BCS0105] Use standard shopt settings: `shopt -s inherit_errexit shift_verbose extglob nullglob`.
- [BCS0105] Always enable `inherit_errexit` to make `set -e` work in command substitutions and subshells.
- [BCS0105] Always enable `shift_verbose` to catch argument parsing bugs when shift has no arguments.
- [BCS0105] Always enable `extglob` for extended patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`.
- [BCS0105] Choose `nullglob` (empty globs expand to nothing) for loops/arrays OR `failglob` (unmatched globs cause error) for strict scripts; never use neither.
- [BCS0105] Enable `globstar` only when needed for recursive `**` matching; it can be slow on deep directory trees.
## File Extensions (BCS0106)
- [BCS0106] Use `.sh` extension or no extension for executables; globally installed scripts in PATH should have no extension.
- [BCS0106] Libraries must have `.sh` extension and should not be executable (no execute permission).
- [BCS0106] Dual-purpose scripts (both sourceable and executable) may use either `.sh` or no extension.
## Function Organization (BCS0107)
- [BCS0107] Organize functions in 7 layers bottom-up: (1) messaging, (2) documentation, (3) helpers, (4) validation, (5) business logic, (6) orchestration, (7) main().
- [BCS0107] Layer 1 (messaging): `_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`, `debug()`, `vecho()` - no dependencies.
- [BCS0107] Layer 2 (documentation): `show_help()`, `show_version()` - may use messaging.
- [BCS0107] Layer 3 (helpers): `yn()`, `noarg()`, generic utilities - may use messaging.
- [BCS0107] Layer 4 (validation): `check_root()`, `check_prerequisites()` - may use helpers and messaging.
- [BCS0107] Layer 5 (business logic): domain-specific operations - may use all lower layers.
- [BCS0107] Layer 6 (orchestration): coordinate multiple operations - may use business logic.
- [BCS0107] Layer 7 (main): `main()` at bottom can call any function; handles argument parsing and workflow.
- [BCS0107] Never create circular dependencies; extract common logic to a lower layer if functions need to call each other.
- [BCS0107] Prefix private/internal functions with underscore: `_msg()`, `_internal_parser()`.
