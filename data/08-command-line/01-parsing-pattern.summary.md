## Standard Argument Parsing Pattern

**Pattern with short option bundling:**

```bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth=$1 ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; ((VERBOSE)) || VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  -[amLpvqVh]?*)  # Bundled short options
                  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern breakdown:**

| Component | Purpose |
|-----------|---------|
| `while (($#))` | Arithmetic test, true while arguments remain (more efficient than `[[ $# -gt 0 ]]`) |
| `case $1 in` | Match current argument; supports multiple patterns: `-a\|--add` |
| `noarg "$@"; shift` | Validate argument exists, then shift to capture value |
| `VERBOSE+=1` | Enables stacking: `-vvv` = `VERBOSE=3` |
| `-V\|--version)` | Print and exit; use `return 0` if within function |
| `-[opts]?*)` | Bundled shorts: `-vpL` �' `-v -pL` �' `-v -p -L` |
| `-*)` | Catch unrecognized options (exit code 22 = EINVAL) |
| `*)` | Default: positional arguments to array |
| `esac; shift; done` | Mandatory shift after every iteration (prevents infinite loop) |

**Short option bundling mechanism:**
```bash
-[VhamLpvq]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```
- `${1:0:2}` extracts first option (`-v` from `-vpL`)
- `"-${1:2}"` creates remaining (`-pL`)
- `${@:2}` preserves remaining arguments
- `continue` restarts loop to process extracted option

**The `noarg` helper:**
```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

**Complete example:**

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - Process files

Usage: $SCRIPT_NAME [OPTIONS] FILE...

Options:
  -o, --output FILE  Output file (required)
  -v, --verbose      Verbose output
  -n, --dry-run      Dry-run mode
  -V, --version      Show version
  -h, --help         Show this help
HELP
}

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift
                    output_file=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    -[ovnVh]?*)     set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
    -*)             die 22 "Invalid option ${1@Q}" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  ((VERBOSE)) && echo "Processing ${#files[@]} files" ||:
  ((DRY_RUN)) && echo '[DRY RUN] Would write to:' "$output_file" ||:

  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE)) && echo "Processing ${file@Q}" ||:
  done
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient
# ✓ Correct
while (($#)); do

# ✗ Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - forgetting shift at loop end
esac; done  # Infinite loop!
# ✓ Correct
esac; shift; done

# ✗ Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
esac
```

**Rationale:** Consistent structure for all scripts; handles options with/without arguments and bundled shorts; validates arguments exist before use; case statement more readable than if/elif; arithmetic `(($#))` faster than `[[ ]]`; follows Unix conventions.
