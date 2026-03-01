# Section 1: Script Structure & Layout

## BCS0100 Section Overview

Every BCS-compliant script follows a mandatory 13-step structure. Scripts must be self-contained, predictable, and safe. This section defines the canonical ordering and required elements.

## BCS0101 Strict Mode

`set -euo pipefail` is mandatory and must be the first command after shebang, comments, and shellcheck directives.

```bash
# correct
#!/usr/bin/env bash
# Brief description
set -euo pipefail

# wrong — strict mode after variable declarations
#!/usr/bin/env bash
declare -r VERSION=1.0.0
set -euo pipefail
```

Add `shopt -s inherit_errexit shift_verbose extglob nullglob` immediately after.

- `inherit_errexit`: makes `set -e` work in command substitutions (critical)
- `shift_verbose`: makes `shift` fail visibly when no args remain
- `extglob`: enables `@()`, `!()`, `+()` patterns
- `nullglob`: unmatched globs expand to nothing instead of literal string

Choose `failglob` instead of `nullglob` for strict scripts where unmatched globs should be errors.

## BCS0102 Shebang

First line must be a shebang. Three acceptable forms:

```bash
#!/bin/bash           # known Linux systems
#!/usr/bin/bash       # BSD systems
#!/usr/bin/env bash   # maximum portability
```

Follow with optional `#shellcheck` directives, then a brief description comment.

```bash
#!/bin/bash
#shellcheck disable=SC2015
# myscript - brief description of what this script does
set -euo pipefail
```

## BCS0103 Script Metadata

Declare metadata immediately after `shopt`. Use `realpath` (not `readlink`).

```bash
# correct
declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# wrong — readlink, separate readonly
SCRIPT_PATH=$(readlink -f "$0")
readonly SCRIPT_PATH
```

Use `#shellcheck disable=SC2155` before the `SCRIPT_PATH` line if needed. The failure mode (script doesn't exist) should cause immediate termination anyway.

## BCS0104 FHS Compliance

Search for resources in FHS order:

```bash
# correct — FHS search path
local -a search_paths=(
  "$SCRIPT_DIR"/data
  "$PREFIX"/share/myapp/data
  /usr/local/share/myapp/data
  /usr/share/myapp/data
)
for dir in "${search_paths[@]}"; do
  [[ -d "$dir" ]] && { DATA_DIR="$dir"; break; }
done
```

Support `PREFIX` customization and XDG directories:

```bash
declare -- PREFIX=${PREFIX:-/usr/local}
declare -- BIN_DIR="$PREFIX"/bin
declare -- CONFIG_DIR=${XDG_CONFIG_HOME:-"$HOME"/.config}/myapp
```

## BCS0105 Global Variables and Colors

Declare all global variables up front with explicit types.

```bash
# correct
declare -i VERBOSE=1 DEBUG=0 DRY_RUN=0
declare -- OUTPUT_DIR='./output'
declare -a FILES=()

# wrong — no type, scattered declarations
VERBOSE=1
# ... 50 lines later ...
DEBUG=0
```

Define colors conditionally on terminal detection:

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

Always check BOTH stdout AND stderr: `[[ -t 1 && -t 2 ]]`.

## BCS0106 File Extensions and Dual-Purpose Scripts

Executables: `.sh` extension or no extension. Globally available executables via PATH must have no extension. Libraries must have `.sh` extension and should not be executable.

**Dual-purpose scripts** (can be sourced or executed):

```bash
# correct — functions first, then sourced check, then strict mode
my_function() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx my_function

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# --- Script mode only below ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

Never apply `set -euo pipefail` when sourced — it alters the calling shell's environment.

## BCS0107 Function Organization

Organize functions bottom-up in 7 layers:

1. Messaging functions (lowest level)
2. Documentation functions (help, usage)
3. Helper/utility functions
4. Validation functions
5. Business logic functions
6. Orchestration/flow functions
7. `main()` function (highest level)

```bash
# correct — bottom-up, each function calls only previously defined functions
_msg() { :; }
info() { _msg "$@"; }
show_help() { cat <<HELP ... HELP; }
validate_input() { :; }
process_file() { validate_input "$1"; }
main() { process_file "$@"; }
main "$@"
#fin
```

Never define `main()` at the top. Never define business logic before the utilities it calls.

## BCS0108 Main Function and Script Invocation

Use `main()` for scripts over ~200 lines. Parse arguments in `main()`, then make configuration variables readonly after parsing.

```bash
# correct
main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
  esac; shift; done
  readonly -- VERBOSE DRY_RUN

  # Business logic here
}

main "$@"
#fin
```

Always quote `"$@"` to preserve the argument array. Scripts under 200 lines may run directly without `main()`.

## BCS0109 End Marker

Every script must end with `#fin` as the mandatory final line.

```bash
# correct — last line of file
main "$@"
#fin

# wrong — missing end marker, or extra content after
main "$@"
```

The end marker confirms the file is complete and not truncated.

## BCS0110 Cleanup and Traps

Scripts requiring cleanup must define the cleanup function and set the trap before any code that creates temporary resources.

```bash
# correct
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  [[ -n "${temp_dir:-}" ]] && rm -rf "$temp_dir"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

temp_dir=$(mktemp -d)
```

Always disable traps inside the cleanup function to prevent recursion.
