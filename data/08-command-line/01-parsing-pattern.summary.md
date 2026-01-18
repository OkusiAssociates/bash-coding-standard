## Standard Argument Parsing Pattern

**Core pattern with short option bundling:**

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

**Pattern rationale:**
- `while (($#))` - Arithmetic test more efficient than `[[ $# -gt 0 ]]`
- Case statement more readable than if/elif chains, supports `|` for alternatives
- `noarg "$@"` validates argument exists before shifting
- `VERBOSE+=1` enables stacking (`-vvv` = 3)
- Exit options (`-V`, `-h`) need no shift
- Short bundling: `-vpL` iteratively splits via `set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue`
- Exit code 22 (EINVAL) for invalid options
- Mandatory `shift` after `esac` prevents infinite loop

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

declare -i VERBOSE=0
declare -i DRY_RUN=0
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

Examples:
  $SCRIPT_NAME -o output.txt file1.txt file2.txt
  $SCRIPT_NAME -vno result.txt *.txt
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

  ((VERBOSE)) && echo "Would write results to ${output_file@Q}" ||:
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - verbose loop test
while [[ $# -gt 0 ]]; do
# ✓ Correct
while (($#)); do

# ✗ Wrong - no argument validation
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - missing shift causes infinite loop
esac; done
# ✓ Correct
esac; shift; done

# ✗ Wrong - if/elif instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
```

**Edge cases:**
- Short bundling with value option: `-vno output.txt` → `-v -n -o output.txt`
- Stacked verbosity: `-vvv` sets VERBOSE=3
- Use `return 0` instead of `exit 0` when pattern is inside a function
