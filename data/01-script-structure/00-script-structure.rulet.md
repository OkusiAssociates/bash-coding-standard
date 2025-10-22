# Script Structure & Layout - Rulets
## Shebang and Initial Setup
- [BCS0102] Use one of three allowable shebangs: `#!/bin/bash` (most portable), `#!/usr/bin/bash` (BSD systems), or `#!/usr/bin/env bash` (maximum portability via PATH).
- [BCS0102] Place the shebang on the first line, followed by optional global `#shellcheck` directives with explanatory comments, then a brief description comment, then `set -euo pipefail` as the first command.
## Strict Mode and Shell Options
- [BCS0101] Always use `set -euo pipefail` as the first command after shebang/comments/shellcheck (Step 4) to enable strict error handling before any other commands execute.
- [BCS0105] Always use `shopt -s inherit_errexit shift_verbose extglob` for critical error propagation, shift error detection, and extended pattern matching.
- [BCS0105] Choose either `shopt -s nullglob` (for arrays/loops - unmatched globs expand to empty) or `shopt -s failglob` (for strict scripts - unmatched globs cause error); never rely on default bash behavior where unmatched globs remain as literal strings.
- [BCS0105] Use `shopt -s globstar` optionally when recursive `**` matching is needed, but beware performance impact on deep directory trees.
## Script Metadata
- [BCS0103] Always declare standard metadata variables immediately after `shopt` settings (Step 6): `VERSION='1.0.0'`, `SCRIPT_PATH=$(realpath -- "$0")`, `SCRIPT_DIR=${SCRIPT_PATH%/*}`, `SCRIPT_NAME=${SCRIPT_PATH##*/}`.
- [BCS0103] Use `realpath -- "$0"` (not `readlink`) to resolve SCRIPT_PATH reliably; this is the canonical BCS approach and supports loadable builtins for maximum performance.
- [BCS0103] Make metadata variables readonly as a group after all assignments: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0103] Derive SCRIPT_DIR and SCRIPT_NAME from SCRIPT_PATH using parameter expansion (`${SCRIPT_PATH%/*}` and `${SCRIPT_PATH##*/}`) rather than external commands.
## Global Variable Declarations
- [BCS0101] Declare all global variables up front (Step 7) with explicit types: `declare -i` for integers, `declare --` for strings, `declare -a` for indexed arrays, `declare -A` for associative arrays.
- [BCS0101] Group all global declarations together after metadata and before color definitions; never scatter declarations throughout the file.
- [BCS0101] For variables modified during argument parsing, declare them mutable first, then make readonly after parsing is complete.
## Color Definitions
- [BCS0101] Conditionally define color codes (Step 8) based on terminal detection: `if [[ -t 1 && -t 2 ]]; then readonly -- RED=$'\033[0;31m' ...; else readonly -- RED='' ...; fi`.
- [BCS0101] Skip color definitions entirely if your script doesn't use colored output.
## Function Organization Pattern
- [BCS0107,BCS0101] Always organize functions bottom-up in 7 layers: (1) messaging functions, (2) documentation functions, (3) helper/utility functions, (4) validation functions, (5) business logic functions, (6) orchestration functions, (7) `main()` function.
- [BCS0107] Each function can only call functions defined above it (earlier in the file); dependencies flow downward, never upward.
- [BCS0107] Place all messaging functions first (`_msg()`, `info()`, `warn()`, `error()`, `die()`, `success()`) as the lowest-level primitives used by everything.
- [BCS0107] Define business logic functions after utilities and validation, so they can safely call lower-layer functions.
## Main Function and Script Invocation
- [BCS0101] Use a `main()` function (Step 11) for scripts over ~200 lines; place it last before script invocation.
- [BCS0101] Parse command-line arguments inside `main()`, make variables readonly after parsing, then execute workflow in clear sequence.
- [BCS0101] Invoke main with `main "$@"` (Step 12), always quoting `"$@"` to preserve argument array properly.
## End Marker
- [BCS0101] Always end scripts with `#fin` or `#end` marker (Step 13) to visually confirm the file is complete and not truncated.
## Dual-Purpose Scripts
- [BCS010201] For scripts that can be both executed and sourced, define all library functions first, then use early return pattern: `[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0`.
- [BCS010201] Only apply `set -euo pipefail` and `shopt` settings in the executable section (after the early return), never when sourced, to avoid modifying the caller's shell environment.
- [BCS010201] Guard metadata initialization with `if [[ ! -v VARIABLE ]]` to allow safe re-sourcing without errors.
- [BCS010201] Export functions with `declare -fx` if they need to be available to subshells.
## FHS Compliance
- [BCS0104] Design installation scripts to follow Filesystem Hierarchy Standard (FHS): use `$PREFIX/bin/` for executables, `$PREFIX/share/` for data, `$PREFIX/lib/` for libraries, `$PREFIX/etc/` or `/etc/` for configuration.
- [BCS0104] Support PREFIX customization via environment variable: `PREFIX="${PREFIX:-/usr/local}"` to enable user install, local install, and system install scenarios.
- [BCS0104] Search multiple FHS locations when loading resources: script directory (development), `/usr/local/share/` (local install), `/usr/share/` (system install), `${XDG_DATA_HOME:-$HOME/.local/share}/` (user install).
- [BCS0104] For user-specific files, follow XDG Base Directory specification: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME` with appropriate fallbacks.
## File Extensions
- [BCS0106] Use no extension for executables that will be in PATH; use `.sh` extension for executables in local/project directories.
- [BCS0106] Always use `.sh` extension for libraries; libraries should not be executable unless they're dual-purpose scripts.
## Complete Structure Summary
- [BCS0101] Follow the mandatory 13-step structure: (1) shebang, (2) shellcheck directives (optional), (3) brief description, (4) `set -euo pipefail`, (5) `shopt` settings, (6) script metadata, (7) global variables, (8) color definitions (optional), (9) utility functions, (10) business logic functions, (11) `main()` function, (12) script invocation `main "$@"`, (13) end marker `#fin`.
- [BCS0101] Scripts under ~200 lines may skip the `main()` function (steps 11-12) and run directly, but all other steps remain required.
## Anti-Patterns to Avoid
- [BCS010102] Never declare variables after they're used; always declare all globals up front in Step 7.
- [BCS010102] Never define business logic before utility functions; utilities must come first so business logic can call them.
- [BCS010102] Never make variables readonly before argument parsing if they need to be modified during parsing.
- [BCS010102] Never mix global declarations with function definitions; keep all declarations grouped together.
- [BCS010102] Never use `$0` directly without `realpath` for SCRIPT_PATH; relative paths and symlinks must be resolved.
## Edge Cases
- [BCS010103] Sourced library files should skip `set -e`, `main()`, and script invocation to avoid modifying caller's shell.
- [BCS010103] Scripts requiring external configuration should source config files between metadata and business logic, then make variables readonly afterward.
- [BCS010103] Scripts with cleanup requirements should define cleanup function in utilities layer, then set trap after function definition but before business logic: `trap 'cleanup $?' SIGINT SIGTERM EXIT`.
- [BCS010103] Tiny scripts under ~200 lines can skip `main()` function and run business logic directly, but must still follow other structural requirements.
