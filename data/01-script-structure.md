# Section 1: Script Structure & Layout

## BCS0100 Section Overview

Every BCS-compliant script follows a 13-step structure. Scripts must be self-contained, predictable, and safe. This section defines the canonical ordering and required elements.

## BCS0101 Strict Mode

`set -euo pipefail` is *mandatory* before script execution starts, and must be the first executable command after shebang, comments, and shellcheck directives.

```bash
# correct
#!/usr/bin/bash
#shellcheck disable=SC???? # (optional)
# Brief description (recommended)
set -euo pipefail
shopt -s inherit_errexit

# wrong — strict mode after variable declarations
#!/usr/bin/bash
declare -r VERSION=1.0.0
set -euo pipefail
```

Add `shopt -s inherit_errexit` immediately after.

- `inherit_errexit`: makes `set -e` work in command substitutions (critical)

**When appropriate**, the following setting could also be added:

- `shift_verbose`: makes `shift` fail visibly when no args remain
- `extglob`: enables `@()`, `!()`, `+()` patterns
- `nullglob`: unmatched globs expand to nothing instead of literal string

Choose `failglob` instead of `nullglob` for strict scripts where unmatched globs should be errors.

## BCS0102 Shebang

First line of any script must be a shebang. Three acceptable forms:

```bash
#!/usr/bin/bash       # Preferred for Linux systems
#!/bin/bash           # Acceptable
#!/usr/bin/env bash   # Maximum portability
```

*Any* one of these shebangs are acceptable.

Follow with optional `#shellcheck` or `#bcscheck` directives, then a brief description comment.

```bash
#!/usr/bin/bash
#shellcheck disable=SC2015
# myscript - brief description of what this script does
set -euo pipefail
shopt -s inherit_errexit
```

## BCS0103 Script Metadata

Declare metadata immediately after `shopt`. Use `realpath` (not `readlink`).

Standard metavars are VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME

**Note:** Not all scripts will require all Script Metadata variables.

```bash
# correct
declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# wrong — readlink, separate readonly
#shellcheck disable=SC2155
SCRIPT_PATH=$(readlink -f "$0")
readonly SCRIPT_PATH
```

Use `#shellcheck disable=SC2155` before the `SCRIPT_PATH` line. The failure mode (command doesn't exist) should cause immediate termination anyway.

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
  [[ -d $dir ]] && { DATA_DIR="$dir"; break; }
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

Executables: `.sh` extension or no extension. Globally available executables via PATH must have no extension. Libraries must have `.sh` or `.bash` extension and should not be executable.

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
show_help() { cat <<HELP
...
HELP
}
validate_input() { :; }
process_file() { validate_input "$1"; }
main() { process_file "$@"; }
main "$@"
#fin
```

Never define `main()` at the top. Never define business logic before the utilities it calls. In some cases, nested functions are permissible within other functions.

## BCS0108 Main Function and Script Invocation

Generally, use `main()` for scripts over ~200 lines. Parse arguments within `main()`, then make configuration variables readonly after parsing.

```bash
# correct
main() {
  while (($#)); do case $1 in
    -n|--dry-run)     DRY_RUN=1 ;;
    -N|--not-dry-run) DRY_RUN=0 ;;
    -v|--verbose)     VERBOSE=1 ;;
    -q|--quiet)       VERBOSE=0 ;;
  esac; shift; done
  readonly VERBOSE DRY_RUN

  # Business logic here
  : ...
}

main "$@"
#fin
```

Always quote `"$@"` to preserve the argument array. Scripts under 200 lines may run directly without `main()`.

## BCS0109 End Marker

Every script must end with `#fin\n` OR `#end\n` as the mandatory final line.

```bash
# correct — last line of file
main "$@"
#fin

```

```bash
# wrong — missing end marker, or extra content after
main "$@"
```

The end marker confirms the file is complete and not truncated.

## BCS0110 Cleanup and Traps

Scripts requiring cleanup must define the cleanup function and set the trap before any code that creates temporary resources.

```bash
# correct
declare -- TEMP_DIR
#...
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  [[ -z ${TEMP_DIR:-} ]] || rm -rf "$TEMP_DIR"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
#...
TEMP_DIR=$(mktemp -d)
```

Always disable traps inside the cleanup function to prevent recursion.

## BCS0111 Configuration File Loading

Use `read_conf()` to source the first matching `.conf` file from a priority-ordered search path. User configuration overrides system defaults.

```bash
# correct — standard read_conf() function
read_conf() {
  local -- conf_file=''
  local -a search_paths=(
    "${XDG_CONFIG_HOME:-$HOME/.config}"/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME".conf
    /usr/local/etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/share/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/lib/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  )

  for conf_file in "${search_paths[@]}"; do
    if [[ -f $conf_file ]]; then
      # shellcheck source=/dev/null
      source "$conf_file"
      return 0
    fi
  done

  return 1
}
```

Search path priority (first match wins):

1. `$XDG_CONFIG_HOME/name/name.conf` — user config (XDG standard)
2. `/etc/name/name.conf` — system config (directory)
3. `/etc/name.conf` — system config (flat file)
4. `/usr/local/etc/name/name.conf` — locally-installed defaults
5. `/usr/share/name/name.conf` — package-provided defaults
6. `/usr/lib/name/name.conf` — library-provided defaults

Call `read_conf` early in `main()`, before argument parsing if config values set defaults, or after parsing if CLI options should override config:

```bash
# correct — config sets defaults, CLI overrides
main() {
  read_conf ||:
  while (($#)); do case $1 in
    # options override config values...
    : ...
  esac; shift; done
}
```

Configuration files are sourced as Bash — they execute in the calling shell's context. Only source config files from trusted locations with appropriate permissions.
