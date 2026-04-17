# Section 01: Script Structure & Layout

## BCS0100 Section Overview

Every BCS-compliant script follows a 13-step structure. Scripts must be self-contained, predictable, and safe. This section defines the canonical ordering and required elements.

## BCS0101 Strict Mode

**Tier:** core

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

**Tier:** recommended

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

**Tier:** recommended

Declare metadata immediately after `shopt`. Use `realpath` (not `readlink`) by default.

Standard metavars are VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME. Not all scripts need all four.

```bash
# correct — handles every install pattern, including symlinked wrappers
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

**Tier:** recommended

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

**Tier:** recommended

Declare all global variables up front with explicit types.

```bash
# correct
declare -i VERBOSE=1 DEBUG=0 DRY_RUN=0
declare -- OUTPUT_DIR=./output
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

**Tier:** core

Executables: `.sh` extension or no extension. Globally available executables via PATH must have no extension. Libraries must have `.sh` or `.bash` extension and should not be executable.

**Dual-purpose scripts** (can be sourced or executed) use a source fence to separate library functions from script mode. Either fence pattern is acceptable:

```bash
# correct — BASH_SOURCE fence (supports conditional actions in the guard)
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# correct — return 0 fence (single builtin, also valid in POSIX sh)
return 0 2>/dev/null ||:
```

Define functions above the fence, strict mode and mainline below:

```bash
# correct — dual-purpose script
my_function() {
  local -- name=$1
  echo "Hello, $name"
}
declare -fx my_function

# --- source fence ---
return 0 2>/dev/null ||:

# --- Script mode only below ---
set -euo pipefail
shopt -s inherit_errexit
my_function "$@"
#fin
```

Never apply `set -euo pipefail` when sourced — it alters the calling shell's environment.

See also: [Source Guard Reference](../benchmarks/source-guard-reference.md) — full comparison of source fence mechanisms with benchmark data.

## BCS0107 Function Organization

**Tier:** style

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

**Tier:** recommended

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

**Tier:** style

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

The #end marker simply confirms the file is complete and not truncated.

## BCS0110 Cleanup and Traps

**Tier:** core

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

**Tier:** recommended

Use `read_conf()` to cascade-source `.conf` files from a priority-ordered search path. System files load first, user files last, so user settings override system defaults key-by-key. Missing files are skipped silently.

```bash
# correct — standard read_conf() function (cascade mode)
read_conf() {
  local -- conf_file=''
  local -i loaded=0
  local -a search_paths=(
    /usr/lib/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/share/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /usr/local/etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME".conf
    /etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
    "${XDG_CONFIG_HOME:-$HOME/.config}"/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  )

  for conf_file in "${search_paths[@]}"; do
    [[ -f $conf_file ]] || continue
    # shellcheck source=/dev/null
    source "$conf_file"
    loaded+=1
  done

  ((loaded))
}
```

Cascade order (later entries override earlier):

1. `/usr/lib/name/name.conf` — library-provided defaults
2. `/usr/share/name/name.conf` — package-provided defaults
3. `/usr/local/etc/name/name.conf` — locally-installed defaults
4. `/etc/name.conf` — system config (flat file)
5. `/etc/name/name.conf` — system config (directory)
6. `$XDG_CONFIG_HOME/name/name.conf` — user config (XDG standard)

Because each file is sourced in the current shell, any variable assignments in a later file override earlier ones while unset keys inherit from earlier layers. This lets a user override one setting without re-declaring all defaults.

`read_conf` returns success when at least one file was loaded, failure when none matched. Call it early in `main()`, before argument parsing if config values set defaults, or after parsing if CLI options should override config:

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

Configuration files are sourced as Bash — they execute in the calling shell's context. Only source config files from trusted locations with appropriate permissions. Cascading increases attack surface linearly in the number of search paths, so never add user-writable paths to scripts that may run with elevated privileges.

The cascade `source`-based pattern is the standard approach. Scripts that intentionally use alternative methods (e.g., first-match-wins semantics, `readarray` for line-delimited data, or restricted parsing for security) should document the deviation. Similarly, scripts may adjust the search path order (e.g., adding `/etc/default/name`) provided the help text documents the actual paths used.
